//
//  ESpaceDetailMessagParser.m
//  eSpaceUI
//
//  Created by huawei on 15/4/1.
//  Copyright (c) 2015年 www.huawei.com. All rights reserved.
//

#import "ESpaceDetailMessagParser.h"
//#import "ESpaceUMResource.h"

#define TELNUM_MAX                            21



@interface ESpaceDetailMessagParser()

@property (nonatomic, strong) NSRegularExpression* emotionReg;
@property (nonatomic, strong) NSRegularExpression* telephoneReg;
@property (nonatomic, strong) NSRegularExpression* urlReg;
@property (nonatomic, strong) NSRegularExpression* umReg;
@property (nonatomic, strong) NSRegularExpression* emailReg;

@end

@implementation ESpaceDetailMessagParser

- (instancetype)init {
    if (self = [super init]) {
        //为兼容老版本表情前不带空格，匹配时需同时支持带空格和不带空格的表情，保证可以匹配到老版本发送的表情
        NSString* specialSpace = [NSString stringWithCString:"\u2060" encoding:NSUTF8StringEncoding];
        //_emotionReg = [NSRegularExpression regularExpressionWithPattern:@"/[^\\s|/]{2}" options:NSRegularExpressionCaseInsensitive error:nil];
        _emotionReg = [NSRegularExpression regularExpressionWithPattern:[NSString stringWithFormat:@"(%@/[^\\s|/]{2})|(%@)",specialSpace, @"/[^\\s|/]{2}"] options:NSRegularExpressionCaseInsensitive error:nil];
        _urlReg = [NSRegularExpression regularExpressionWithPattern:@"((http://|https://|ftp://|www\\.)[[^\u2060]&&[^\\s]&&[^[\u4E00-\u9Fa5]]]{1,})|(www.[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)|((http|https|ftp)+://[^\\s]*)|((http[s]{0,1}|ftp)://[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)" options:NSRegularExpressionCaseInsensitive error:nil];
        
        _emailReg = [NSRegularExpression regularExpressionWithPattern:@"[A-Z0-9a-z.%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}" options:NSRegularExpressionCaseInsensitive error:nil];
        _telephoneReg = [NSRegularExpression regularExpressionWithPattern:[NSString stringWithFormat:@"(?<![0-9])([0-9]{5,%d})(?![0-9])",TELNUM_MAX] options:NSRegularExpressionCaseInsensitive error:nil];
        _umReg = [NSRegularExpression regularExpressionWithPattern:@"/:um_begin\\{(.*?)\\}/:um_end" options:NSRegularExpressionCaseInsensitive error:nil];
    }
    return self;
}

+ (instancetype) sharedInstance {
    static dispatch_once_t onceToken;
    static ESpaceDetailMessagParser* parser;
    dispatch_once(&onceToken, ^{
        parser = [[ESpaceDetailMessagParser alloc] init];
    });
    return parser;
}

- (NSArray*) emotionMatches:(NSString*) content {
    if (!content) {
        return nil;
    }
    NSMutableArray* array = [NSMutableArray array];
    [_emotionReg enumerateMatchesInString:content options:NSMatchingReportCompletion range:NSMakeRange(0, content.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        if (result.range.location != NSNotFound) {
            NSString* subStr = [content substringWithRange:result.range];
            ESpaceEmotionItem* item = [[ESpaceEmotions sharedInstance] searchEmotion:subStr];
            if (item) {
                [array addObject:result];
            }
        }
    }];
    return array;
}

- (NSArray*) telphoneMatches:(NSString*) content {
    if (!content) {
        return nil;
    }
    return [_telephoneReg matchesInString:content
                                  options:NSMatchingReportCompletion
                                    range:NSMakeRange(0, [content length])];
}

- (NSArray*) urlMatches:(NSString*) content {
    if (!content) {
        return nil;
    }
    return [_urlReg matchesInString:content
                                  options:NSMatchingReportCompletion
                                    range:NSMakeRange(0, [content length])];
}

- (NSArray*) umMatches:(NSString*) content {
    if (!content) {
        return nil;
    }
    return [_umReg matchesInString:content options:NSMatchingReportCompletion range:NSMakeRange(0, [content length])];
}

- (BOOL) validateEmail:(NSString *)email
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

- (NSArray*) emailMatches:(NSString*) content {
    return nil;//由于字数过多时解析email比较耗时，暂时先屏蔽
//    if (!content) {
//        return nil;
//    }
//    return [_emailReg matchesInString:content options:NSMatchingReportCompletion range:NSMakeRange(0, [content length])];
}

/**
 *  实现ECSRichTextParserDelegate
 *  匹配优先级: 富媒体 > 链接 > 表情 > 电话号码
 *  使用分治法处理优先级：匹配富媒体，匹配个富媒体左边界url，匹配富媒体右侧url
 *  @param text 待分析的字符串
 *
 *  @return ECSControl数组
 */
//- (NSArray*) parseContent:(NSString*) text{
//    NSMutableArray* array = [NSMutableArray array];
//    if (text.length == 0) {
//        return array;
//    }
//    NSArray* ums = [self umMatches:text];
//    NSRange preResult = NSMakeRange(0, 0);
//
//    for (NSUInteger i=0; i<ums.count; ++i) {
//        NSTextCheckingResult* result = [ums objectAtIndex:i];
//        NSRange range = result.range;
//        if (i > 0) {
//            NSTextCheckingResult* pr = [ums objectAtIndex:i - 1];
//            preResult = pr.range;
//        }
//        NSString* leftString = [text substringWithRange:NSMakeRange(preResult.location + preResult.length, range.location - preResult.location - preResult.length)];
//        [array addObjectsFromArray:[self parseUrl:leftString]];
//        ESpaceUMResource* umResource = [[ESpaceUMResourceManager sharedInstance] umResourceFromString:[text substringWithRange:range]];
//
//        ESpaceUMPlaceHolder* placeHolder = [self parseUMPlaceHolderWithResource:umResource];
//        if (placeHolder) {
//            [array addObject:placeHolder];
//        }
//    }
//    NSTextCheckingResult* result = [ums lastObject];
//    if (result) {
//        NSString* lastToken = [text substringFromIndex:result.range.location + result.range.length];
//        [array addObjectsFromArray:[self parseUrl:lastToken]];
//    } else {
//        [array addObjectsFromArray:[self parseUrl:text]];
//    }
//    return array;
//}

//- (NSArray*) parseUrl:(NSString*) text {
//    NSMutableArray* ctrls = [NSMutableArray array];
//    if (text.length == 0) {
//        return ctrls;
//    }
//    NSRange preResult = NSMakeRange(0, 0);
//    NSArray* urls = [self urlMatches:text];
//    for (NSUInteger i=0; i<urls.count; ++i) {
//        NSTextCheckingResult* result = [urls objectAtIndex:i];
//        NSRange range = result.range;
//        if (i > 0) {
//            NSTextCheckingResult* pr = [urls objectAtIndex:i - 1];
//            preResult = pr.range;
//        }
//        NSString* leftString = [text substringWithRange:NSMakeRange(preResult.location + preResult.length, range.location - preResult.location - preResult.length)];
//        NSArray* leftTokens = [self parseEmotions:leftString];
//        [ctrls addObjectsFromArray:leftTokens];
//        ESpaceUrlLink* textLabel = [self parseUrlControl:[text substringWithRange:range]];
//        if (textLabel) {
//            [ctrls addObject:textLabel];
//        }
//    }
//    NSTextCheckingResult* result = [urls lastObject];
//    if (result) {
//        NSString* lastToken = [text substringFromIndex:result.range.location + result.range.length];
//        [ctrls addObjectsFromArray:[self parseEmotions:lastToken]];
//    } else {
//        return [self parseEmotions:text];
//    }
//    return ctrls;
//}

//- (NSArray*) parseEmails:(NSString*) text {
//    NSMutableArray* ctrls = [NSMutableArray array];
//    if (text.length == 0) {
//        return ctrls;
//    }
//    NSArray* emails = [self emailMatches:text];
//    NSRange preResult = NSMakeRange(0, 0);
//    for (NSUInteger i=0; i<emails.count; ++i) {
//        NSTextCheckingResult* result = [emails objectAtIndex:i];
//        NSRange range = result.range;
//        if (i > 0) {
//            NSTextCheckingResult* pr = [emails objectAtIndex:i - 1];
//            preResult = pr.range;
//        }
//        NSString* leftString = [text substringWithRange:NSMakeRange(preResult.location + preResult.length, range.location - preResult.location - preResult.length)];
//        [ctrls addObjectsFromArray:[self parseTelephone:leftString]];
//        NSString* emailStr = [text substringWithRange:range];
//        ESpaceEmailLink* email = [self parseEmail:emailStr];
//        [ctrls addObject:email];
//    }
//    NSTextCheckingResult* result = [emails lastObject];
//    if (result) {
//        NSString* lastToken = [text substringFromIndex:result.range.location + result.range.length];
//        [ctrls addObjectsFromArray:[self parseTelephone:lastToken]];
//    } else {
//        return [self parseTelephone:text];
//    }
//    return ctrls;
//}

//- (NSArray*) parseEmotions:(NSString*) text{
//    NSMutableArray* ctrls = [NSMutableArray array];
//    if (text.length == 0) {
//        return ctrls;
//    }
//    NSArray* emotions = [self emotionMatches:text];
//    NSRange preResult = NSMakeRange(0, 0);
//    for (NSUInteger i=0; i<emotions.count; ++i) {
//        NSTextCheckingResult* result = [emotions objectAtIndex:i];
//        NSRange range = result.range;
//        if (i > 0) {
//            NSTextCheckingResult* pr = [emotions objectAtIndex:i - 1];
//            preResult = pr.range;
//        }
//        NSString* leftString = [text substringWithRange:NSMakeRange(preResult.location + preResult.length, range.location - preResult.location - preResult.length)];
//        [ctrls addObjectsFromArray:[self parseEmails:leftString]];
//        NSString* emotionStr = [text substringWithRange:range];
//        ESpaceEmotionItem* item = [[ESpaceEmotions sharedInstance] searchEmotion:emotionStr];
//        ESpaceEmotion* emotion = [[ESpaceEmotion alloc] initWithEmotionItem:item range:range];
//        emotion.replacement = @"简";
//        [ctrls addObject:emotion];
//    }
//    NSTextCheckingResult* result = [emotions lastObject];
//    if (result) {
//        NSString* lastToken = [text substringFromIndex:result.range.location + result.range.length];
//        [ctrls addObjectsFromArray:[self parseEmails:lastToken]];
//    } else {
//        return [self parseEmails:text];
//    }
//    return ctrls;
//}

//- (NSArray*) parseTelephone:(NSString*) text{
//    NSMutableArray* ctrls = [NSMutableArray array];
//    if (text.length == 0) {
//        return ctrls;
//    }
//    NSRange preResult = NSMakeRange(0, 0);
//    NSArray* tels = [self telphoneMatches:text];
//    for (NSUInteger i=0; i<tels.count; ++i) {
//        NSTextCheckingResult* result = [tels objectAtIndex:i];
//        NSRange range = result.range;
//        if (i > 0) {
//            NSTextCheckingResult* pr = [tels objectAtIndex:i - 1];
//            preResult = pr.range;
//        }
//        NSString* leftString = [text substringWithRange:NSMakeRange(preResult.location + preResult.length, range.location - preResult.location - preResult.length)];
//        ECSTextLabel* textLabel = [self parsePlainText:leftString];
//        if (textLabel) {
//            [ctrls addObject:textLabel];
//        }
//        if (range.length > 0) {
//            ESpaceTelLink* tel = [self parseTelControl:[text substringWithRange:range]];
//            if (tel) {
//                [ctrls addObject:tel];
//            }
//        }
//    }
//    NSTextCheckingResult* result = [tels lastObject];
//    if (result) {
//        NSString* lastToken = [text substringFromIndex:result.range.location + result.range.length];
//        if (lastToken.length > 0) {
//            ECSTextLabel* textLabel = [self parsePlainText:lastToken];
//            if (textLabel) {
//                [ctrls addObject:textLabel];
//            }
//        }
//    } else {
//        ECSTextLabel* textLabel = [self parsePlainText:text];
//        if (textLabel) {
//            [ctrls addObject:textLabel];
//        }
//    }
//    return ctrls;
//}

- (NSURL *)convertToURL:(NSString *)urlStr
{
    NSString *escapedUrl = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                               (CFStringRef)urlStr, CFSTR("#[]"), NULL, kCFStringEncodingUTF8));
        //NSString *escapedUrl = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSArray *array = [escapedUrl componentsSeparatedByString:@"#"];
    NSUInteger count = [array count];
    NSUInteger i;
    NSURL *retUrl;
    
    // 将含有“#”的NSString转换为NSURL
    if (count > 1) {
        retUrl = [NSURL URLWithString:(NSString *)array[0]];
        for (i = count - 1; retUrl != nil && i >= 1; i--) {
            retUrl = [NSURL URLWithString:[NSString stringWithFormat:@"#%@", array[i]] relativeToURL:retUrl];
        }
    } else {
        retUrl = [NSURL URLWithString:escapedUrl];
    }
    
    return retUrl;
}

- (NSURL*) formatUrl:(NSString*) urlStr {
    if (!urlStr) {
        return nil;
    }
    
    NSURL* url = [NSURL URLWithString:urlStr];
    if (!url) {
        NSMutableCharacterSet * set = [NSMutableCharacterSet characterSetWithCharactersInString:@"!*'();:@&=+$,/?%#[]"];
        [set formUnionWithCharacterSet:[NSCharacterSet URLQueryAllowedCharacterSet]];
        [set formUnionWithCharacterSet:[NSCharacterSet URLFragmentAllowedCharacterSet]];
        [set formUnionWithCharacterSet:[NSCharacterSet URLHostAllowedCharacterSet]];
        [set formUnionWithCharacterSet:[NSCharacterSet URLPasswordAllowedCharacterSet]];
        [set formUnionWithCharacterSet:[NSCharacterSet URLPathAllowedCharacterSet]];
        [set formUnionWithCharacterSet:[NSCharacterSet URLUserAllowedCharacterSet]];
        url = [NSURL URLWithString:[urlStr stringByAddingPercentEncodingWithAllowedCharacters:set]];
        if (!url) {
            url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@", urlStr]];
        }
        if (!url) {
            url = [self convertToURL:urlStr];
        }
    }
    return url;
}

//- (ESpaceUrlLink*) parseUrlControl:(NSString*) urlStr {
//    if (!urlStr) {
//        return nil;
//    }
//    ESpaceUrlLink* urlLink = [[ESpaceUrlLink alloc] init];
//    urlLink.url = [self formatUrl:urlStr];
//    urlLink.text = urlStr;
//    return urlLink;
//}
//
//- (ESpaceTelLink*) parseTelControl:(NSString*) telStr {
//    if (!telStr) {
//        return nil;
//    }
//    ESpaceTelLink* telLink = [[ESpaceTelLink alloc] init];
//    telLink.text = telStr;
//    return telLink;
//}

- (ECSTextLabel*) parsePlainText:(NSString*) plainText {
    if (!plainText) {
        return nil;
    }
    ECSTextLabel* text = [[ECSTextLabel alloc] init];
    text.text = plainText;
    return text;
}

//- (ESpaceEmailLink*) parseEmail:(NSString*) emailText {
//    if (!emailText) {
//        return nil;
//    }
//    ESpaceEmailLink* email = [[ESpaceEmailLink alloc] init];
//    email.text = emailText;
//    return email;
//}

//- (ESpaceUMPlaceHolder*) parseUMPlaceHolderWithResource:(ESpaceUMResource *)resource {
//    if (!resource) {
//        return nil;
//    }
//    ESpaceUMPlaceHolder* placeHolder = [[ESpaceUMPlaceHolder alloc] init];
//    placeHolder.umResource = resource;
//    placeHolder.text = [resource description];
//    return placeHolder;
//}

@end
