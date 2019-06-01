//
//  EmojiTextAttachment.m
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//
#import "EmojiTextAttachment.h"
#import "ESpaceEmotions.h"

@implementation EmojiTextAttachment
//- (CGRect)attachmentBoundsForTextContainer:(NSTextContainer *)textContainer proposedLineFragment:(CGRect)lineFrag glyphPosition:(CGPoint)position characterIndex:(NSUInteger)charIndex
//{
//    return CGRectMake(0, 0, _emojiSize.width, _emojiSize.height);
//}

- (CGRect)attachmentBoundsForTextContainer:(NSTextContainer *)textContainer proposedLineFragment:(CGRect)lineFrag glyphPosition:(CGPoint)position characterIndex:(NSUInteger)charIndex
{
    return (CGRect){{0,-(_emojiFont.ascender - _emojiFont.descender - _emojiFont.capHeight - 1.0) * 0.5},_emojiSize};
}

- (UIImage *)scaleImage:(UIImage *)image toScale:(float)scaleSize
{
    CGSize size = CGSizeMake(image.size.width * scaleSize, image.size.height * scaleSize);
    _emojiSize = size;
    UIGraphicsBeginImageContextWithOptions(size,NO, [UIScreen mainScreen].scale);
    [image drawInRect:CGRectMake(0, 0, image.size.width * scaleSize, image.size.height * scaleSize)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}
- (UIImage *)scaleImage:(UIImage *)image toSize:(CGSize)size
{
    UIFont *font =  [UIFont systemFontOfSize:17];
    _emojiSize = CGSizeMake(font.ascender - font.descender, font.ascender - font.descender);
    UIGraphicsBeginImageContextWithOptions(_emojiSize,NO, [UIScreen mainScreen].scale);
    [image drawInRect:CGRectMake(0, 0, _emojiSize.width, _emojiSize.height)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}
- (UIImage *)scaleImage:(UIImage *)image toFontSize:(CGFloat)fontSize
{
    _emojiFont =  [UIFont systemFontOfSize:fontSize];
    CGFloat width = _emojiFont.ascender - _emojiFont.descender;
    _emojiSize = CGSizeMake(width, width);
    UIGraphicsBeginImageContextWithOptions(_emojiSize,NO, [UIScreen mainScreen].scale);
    [image drawInRect:CGRectMake(0, 0, width, width)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}

+ (instancetype)ESpaceEmotionTextAttachmentWith:(UIImage *)image emotionStr:(NSString *)emotionStr fontSize:(CGFloat)fontSize
{
    EmojiTextAttachment *attachment = [[EmojiTextAttachment alloc] init];
    attachment.image = [attachment scaleImage:image toFontSize:fontSize];
    attachment.emojiString = emotionStr;
    return attachment;
}

/**
 *This method is used to transform string to espace systerm emotion
 *将字符串转为espace系统表情
 */
+ (NSAttributedString *)ESpaceEmotionTextWithString:(NSString *)string
{
    NSString* specialSpace = [NSString stringWithCString:"\u2060" encoding:NSUTF8StringEncoding];
    NSRegularExpression *emotionReg = [NSRegularExpression regularExpressionWithPattern:[NSString stringWithFormat:@"(%@/[^\\s|/]{2})|(%@)",specialSpace, @"/[^\\s|/]{2}"] options:NSRegularExpressionCaseInsensitive error:nil];
    NSMutableArray* array = [NSMutableArray array];
    NSMutableArray* itemArray = [NSMutableArray array];
    [emotionReg enumerateMatchesInString:string options:NSMatchingReportCompletion range:NSMakeRange(0, string.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        if (result.range.location != NSNotFound) {
            NSString* subStr = [string substringWithRange:result.range];
            ESpaceEmotionItem* item = [[ESpaceEmotions sharedInstance] searchEmotion:subStr];
            if (item) {
                [array addObject:result];
                [itemArray addObject:item];
            }
        }
    }];
    NSMutableAttributedString *att =  [[NSMutableAttributedString alloc] initWithString:string];
    ESpaceEmotionItem* item;
    NSTextCheckingResult *result;
    EmojiTextAttachment *attachment;
    for (NSInteger i = array.count; i > 0; i--) {
        result = array[i - 1];
        item = itemArray[i - 1];
        attachment = [EmojiTextAttachment ESpaceEmotionTextAttachmentWith:item.image emotionStr:item.escapeString fontSize:14.0];
        [att replaceCharactersInRange:result.range withAttributedString:[NSAttributedString attributedStringWithAttachment:attachment]];
    }
    
    return att;
}

/**
 *This method is used to transform message to espace systerm emotion
 *将消息转为espace系统表情
 */
+ (NSAttributedString*)ESpaceEmotionForMessage:(MessageEntity *)latestMessage
{
    if (latestMessage == nil) {
        return [[NSAttributedString alloc] initWithString:@""];
    }
    // 处理表情显示问题
    NSString* specialSpace = [NSString stringWithCString:"\u2060" encoding:NSUTF8StringEncoding];
    NSRegularExpression *emotionReg = [NSRegularExpression regularExpressionWithPattern:[NSString stringWithFormat:@"(%@/[^\\s|/]{2})|(%@)",specialSpace, @"/[^\\s|/]{2}"] options:NSRegularExpressionCaseInsensitive error:nil];
    NSMutableArray* array = [NSMutableArray array];
    NSMutableArray* itemArray = [NSMutableArray array];
    //                        NSMutableString *detailT = [NSMutableString string];
    [emotionReg enumerateMatchesInString:latestMessage.body options:NSMatchingReportCompletion range:NSMakeRange(0, latestMessage.body.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        if (result.range.location != NSNotFound) {
            NSString* subStr = [latestMessage.body substringWithRange:result.range];
            ESpaceEmotionItem* item = [[ESpaceEmotions sharedInstance] searchEmotion:subStr];
            if (item) {
                [array addObject:result];
                [itemArray addObject:item];
            }
        }
    }];
    NSMutableAttributedString *att =  [[NSMutableAttributedString alloc] initWithString:latestMessage.body];
    ESpaceEmotionItem* item;
    NSTextCheckingResult *result;
    EmojiTextAttachment *attachment;
    for (NSInteger i = array.count; i > 0; i--) {
        result = array[i - 1];
        item = itemArray[i - 1];
        attachment = [EmojiTextAttachment ESpaceEmotionTextAttachmentWith:item.image emotionStr:item.escapeString fontSize:14.0];
        [att replaceCharactersInRange:result.range withAttributedString:[NSAttributedString attributedStringWithAttachment:attachment]];
    }
    
    return att;
}

@end
