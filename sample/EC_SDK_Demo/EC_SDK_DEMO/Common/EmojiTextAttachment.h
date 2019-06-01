//
//  EmojiTextAttachment.h
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

#import <UIKit/UIKit.h>
#import "MessageEntity.h"

@interface EmojiTextAttachment : NSTextAttachment

@property(strong, nonatomic) NSString *emojiTag;
@property(assign, nonatomic) CGSize emojiSize;
@property(strong, nonatomic) NSString *emojiString;
@property (nonatomic, strong) UIFont *emojiFont;

+ (instancetype)ESpaceEmotionTextAttachmentWith:(UIImage *)image emotionStr:(NSString *)emotionStr fontSize:(CGFloat)fontSize;

/**
 *This method is used to transform string to espace systerm emotion
 *将字符串转为espace系统表情
 */
+ (NSAttributedString *)ESpaceEmotionTextWithString:(NSString *)string;

/**
 *This method is used to transform message to espace systerm emotion
 *将消息转为espace系统表情
 */
+ (NSAttributedString*)ESpaceEmotionForMessage:(MessageEntity *)latestMessage;

@end
