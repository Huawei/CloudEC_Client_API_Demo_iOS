//
//  ESpaceRichTextBaseParser.m
//  XCoreText
//
//  Created by yemingxing on 3/23/15.
//  Copyright (c) 2015 Dylan. All rights reserved.
//

#import "ESpaceRichTextBaseParser.h"
#import "ECSRichTextView.h"
#import <CoreText/CoreText.h>
//#import "ESpaceUMResource.h"

@implementation ESpaceEmotion

- (id) initWithEmotionItem:(ESpaceEmotionItem*) emotionItem range:(NSRange) range {
    if (self = [self init]) {
        self.emotionItem = emotionItem;
        self.rangeInContent = range;
        self.text = emotionItem.escapeString;
    }
    return self;
}

- (UIImage*) emotionImage {
    if (!self.emotionItem) {
        return nil;
    }
    return self.emotionItem.image;
}

@end

@implementation ESpaceUMPlaceHolder

@end

@implementation ESpaceUrlLink

- (instancetype)init {
    if (self = [super init]) {
        self.textColor = [UIColor blueColor];
    }
    return self;
}

@end

@implementation ESpaceTelLink

- (instancetype)init {
    if (self = [super init]) {
        self.textColor = [UIColor blueColor];
    }
    return self;
}


@end

@implementation ESpaceEmailLink

- (instancetype)init {
    if (self = [super init]) {
        self.textColor = [UIColor blueColor];
        self.underlineStyle = NSUnderlineStyleSingle;
    }
    return self;
}

@end

@implementation ESpaceRichTextBaseParser

- (NSArray *)parseContent:(NSString *)content {
    return nil;
}

- (CGSize) suggestSizeWithContent:(NSString*) content maxWidth:(CGFloat) width font:(UIFont*) font lineSpace:(CGFloat) lineSpace lineBreakMode:(NSLineBreakMode) breakMode {
    if (!font) {
        font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
    }
    if (!content) {
        return CGSizeZero;
    }
    NSMutableAttributedString* attributedString = [ECSRichTextView attributeStringForSuggestSize:[self parseContent:content] maxWidth:width font:font lineSpace:lineSpace lineBreakMode:breakMode];
    CTFramesetterRef frameSetterRef = CTFramesetterCreateWithAttributedString((CFAttributedStringRef) attributedString);
    CGSize restrictSize = CGSizeMake(width, CGFLOAT_MAX);
    CGSize coreTextSize = CTFramesetterSuggestFrameSizeWithConstraints(frameSetterRef, CFRangeMake(0, 0), NULL, restrictSize, NULL);
    
    CFRelease(frameSetterRef);
    return coreTextSize;
}

- (CGSize) suggestSizeWithControls:(NSArray*) controls maxWidth:(CGFloat) width font:(UIFont*) font lineSpace:(CGFloat) lineSpace lineBreakMode:(NSLineBreakMode) breakMode {
    if (!font) {
        font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
    }
    if ([controls count] == 0) {
        return CGSizeZero;
    }
    NSMutableAttributedString* attributedString = [ECSRichTextView attributeStringForSuggestSize:controls maxWidth:width font:font lineSpace:lineSpace lineBreakMode:breakMode];
    CTFramesetterRef frameSetterRef = CTFramesetterCreateWithAttributedString((CFAttributedStringRef) attributedString);
    CGSize restrictSize = CGSizeMake(width, CGFLOAT_MAX);
    CGSize coreTextSize = CTFramesetterSuggestFrameSizeWithConstraints(frameSetterRef, CFRangeMake(0, 0), NULL, restrictSize, NULL);
    
    CFRelease(frameSetterRef);
    return coreTextSize;
}

-(NSArray*)returnMatchResultOfText:(NSString*)text  withRegularExpression:(NSString*)regularExpression option:(NSRegularExpressionOptions) options {
    //设置匹配规则
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regularExpression
                                                                           options:options
                                                                             error:nil];
    
    //匹配结果
    NSUInteger numberOfMatches = [regex numberOfMatchesInString:text
                                                        options:NSMatchingReportCompletion
                                                          range:NSMakeRange(0, [text length])];
    if (numberOfMatches == 0) {
        return nil;
    }
    NSArray *matches = [regex matchesInString:text
                                      options:NSMatchingReportCompletion
                                        range:NSMakeRange(0, [text length])];
    return matches;
}

@end
