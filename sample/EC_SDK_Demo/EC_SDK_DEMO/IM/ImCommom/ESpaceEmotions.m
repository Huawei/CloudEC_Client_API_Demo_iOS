//
//  ESpaceEmotionParser.m
//  eSpaceUI
//
//  Created by yemingxing on 3/20/15.
//  Copyright (c) 2015 www.huawei.com. All rights reserved.
//

#import "ESpaceEmotions.h"
#import "ESpaceLocalDataManager.h"

@interface ESpaceEmotions () <NSXMLParserDelegate>
@property (nonatomic, strong) NSMutableArray* items;
@property (nonatomic, strong) NSMutableDictionary* itemsDic;
@property (nonatomic, strong) NSMutableString* tempString;
@property (nonatomic, strong) NSMutableString* mutRegExp;

+ (NSString*) escapeRegExp:(NSString*) exp;
@end

@interface ESpaceEmotionItem ()

- (void) _setEscapeString:(NSString*) string;
- (void) _setImageName:(NSString*) imageName;

@end

@implementation ESpaceEmotionItem

@synthesize escapeString = _escapeString;
@synthesize imageName = _imageName;
@synthesize image = _image;

- (void)_setEscapeString:(NSString *)string {
    _escapeString = [string copy];
    if (string) {
        _regExp = [[NSRegularExpression alloc] initWithPattern:[ESpaceEmotions escapeRegExp:string] options:0 error:nil];
    }
    
}

- (void)_setImageName:(NSString *)imageName {
    _imageName = [imageName copy];
}

- (UIImage *)image {
    if (!_image && _imageName) {
        _image = ECS_IMG(_imageName);
    }
    return _image;
}

- (void)clearImage{
    _image = nil;
}


@end



@implementation ESpaceEmotions

- (instancetype)init {
    if (self = [super init]) {
        self.items = [NSMutableArray array];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(clearMemory)
                                                     name:UIApplicationDidReceiveMemoryWarningNotification
                                                   object:nil];
        self.mutRegExp = [[NSMutableString alloc] init];
        self.itemsDic = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidReceiveMemoryWarningNotification
                                                  object:nil];
}

- (NSDictionary *)emotionDict{
    return self.itemsDic;
}

- (NSArray *)emotionItems {
    return _items;
}

- (NSString *)regExp {
    return _mutRegExp;
}

- (void)clearMemory {
    for (ESpaceEmotionItem* item in self.items) {
        [item clearImage];
    }
}

+ (instancetype) sharedInstance {
    static dispatch_once_t onceToken;
    static ESpaceEmotions* emotions;
    dispatch_once(&onceToken, ^{
        emotions = [[ESpaceEmotions alloc] init];
        [emotions parse];
    });
    return emotions;
}

- (void) parse {
    NSBundle* bundle = [ECSSandboxHelper shareInstance].UIResourceBundle;
    NSURL* emotionXml = [bundle URLForResource:@"emotion" withExtension:@"xml"];
    NSXMLParser* parser = [[NSXMLParser alloc] initWithContentsOfURL:emotionXml];
    parser.delegate = self;
    [parser parse];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    if ([elementName caseInsensitiveCompare:@"emotion"] == NSOrderedSame) {
        [_items addObject:[[ESpaceEmotionItem alloc] init]];
    } else if ([elementName caseInsensitiveCompare:@"filename"] == NSOrderedSame) {
        self.tempString = [NSMutableString string];
    } else if ([elementName caseInsensitiveCompare:@"character"] == NSOrderedSame) {
        self.tempString = [NSMutableString string];
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    if ([elementName caseInsensitiveCompare:@"filename"] == NSOrderedSame) {
        ESpaceEmotionItem* item = [_items lastObject];
        NSRange range = [self.tempString rangeOfString:@".png" options:NSCaseInsensitiveSearch];
        NSString* imageName = self.tempString;
        if (range.location != NSNotFound) {
            imageName = [imageName substringWithRange:NSMakeRange(0, imageName.length - range.length)];
        }
        [item _setImageName:imageName];
        self.tempString = nil;
    } else if ([elementName caseInsensitiveCompare:@"character"] == NSOrderedSame) {
        ESpaceEmotionItem* item = [_items lastObject];
        
        //防止链接+表情发送时解析错误，统一在表情前添加不可见的空格
        NSString* specialSpace = [NSString stringWithCString:"\u2060" encoding:NSUTF8StringEncoding];
        [item _setEscapeString:[NSString stringWithFormat:@"%@%@",specialSpace,self.tempString]];
        self.tempString = nil;
    } else if([elementName caseInsensitiveCompare:@"emotionconf"] == NSOrderedSame) {
        for (ESpaceEmotionItem* item in _items) {
            [self.itemsDic setObject:item forKey:item.escapeString];
        }
        for (NSUInteger i = 0; i<_items.count; ++i) {
            ESpaceEmotionItem* emotion = [_items objectAtIndex:i];
            if (i == 0) {
                [_mutRegExp appendFormat:@"(%@)", [ESpaceEmotions escapeRegExp:emotion.escapeString]];
            } else {
                [_mutRegExp appendFormat:@"|(%@)", [ESpaceEmotions escapeRegExp:emotion.escapeString]];
            }
        }
    }
}


- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    [self.tempString appendString:string];
}

+ (NSString*) escapeRegExp:(NSString*) exp{
    NSString* n = [exp stringByReplacingOccurrencesOfString:@"\\" withString:@"\\\\"];
    n = [n stringByReplacingOccurrencesOfString:@"(" withString:@"\\("];
    n = [n stringByReplacingOccurrencesOfString:@")" withString:@"\\)"];
    n = [n stringByReplacingOccurrencesOfString:@"*" withString:@"\\*"];
    n = [n stringByReplacingOccurrencesOfString:@"{" withString:@"\\{"];
    n = [n stringByReplacingOccurrencesOfString:@"}" withString:@"\\}"];
    n = [n stringByReplacingOccurrencesOfString:@"!" withString:@"\\!"];
    n = [n stringByReplacingOccurrencesOfString:@"^" withString:@"\\^"];
    n = [n stringByReplacingOccurrencesOfString:@"$" withString:@"\\$"];
    n = [n stringByReplacingOccurrencesOfString:@"." withString:@"\\."];
    n = [n stringByReplacingOccurrencesOfString:@"|" withString:@"\\|"];
    n = [n stringByReplacingOccurrencesOfString:@"+" withString:@"\\+"];
    n = [n stringByReplacingOccurrencesOfString:@"?" withString:@"\\?"];
    return n;
}

- (ESpaceEmotionItem*) searchEmotion:(NSString*) escapeStr {
    //为兼容老版本表情前不带空格，在匹配时需主动添加一个特殊空格，保证可以匹配到老版本发送的表情
    NSString* specialSpace = [NSString stringWithCString:"\u2060" encoding:NSUTF8StringEncoding];
    NSString* searchStr = escapeStr;
    if (NO == [escapeStr containsString:specialSpace]) {
        searchStr = [NSString stringWithFormat:@"%@%@", specialSpace, searchStr];
    }
    if (!escapeStr) return nil;
    return [self.itemsDic objectForKey:searchStr];
}


@end
