//
//  TextMessageCell.m
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

#import "TextMessageCell.h"
#import "HeadImageView.h"
#import "EmojiTextAttachment.h"

#define TEXT_TOP_SPACE  50
#define TEXT_BOTTOM_SPACE 25
#define TEXT_MAX_WIDTH 200

@interface TextMessageCell ()
@property (nonatomic, weak)IBOutlet UILabel *contentLabel;      // show content
@end

@implementation TextMessageCell

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (CGFloat)cellHeightForChatMessage:(ChatMessageEntity *)entity
{
    CGSize size = [self textLabelSize:entity];
    return size.height + TEXT_TOP_SPACE + TEXT_BOTTOM_SPACE;
}

+ (CGSize)textLabelSize:(ChatMessageEntity *)entity
{
    UILabel *label = [[UILabel alloc] init];
    label.numberOfLines = 0;
    label.attributedText = [EmojiTextAttachment ESpaceEmotionForMessage:entity];;
    [label setFont:[UIFont systemFontOfSize:14]];
    CGSize size = [label sizeThatFits:CGSizeMake(TEXT_MAX_WIDTH, CGFLOAT_MAX)];
    return size;
}

- (void)setMessage:(ChatMessageEntity *)message
{
    [super setMessage:message];
    
    [self updateMessage];
}



- (void)updateMessage
{
    _contentLabel.attributedText = [EmojiTextAttachment ESpaceEmotionForMessage:self.message];
    
    CGSize size = [_contentLabel sizeThatFits:CGSizeMake(TEXT_MAX_WIDTH, CGFLOAT_MAX)];
    self.textWidthConstraint.constant = size.width + 29;
    self.textHeighConstraint.constant = size.height + 29;
}

@end
