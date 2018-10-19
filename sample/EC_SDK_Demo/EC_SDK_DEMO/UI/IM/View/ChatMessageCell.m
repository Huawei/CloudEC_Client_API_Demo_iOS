//
//  ChatMessageCell.m
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

#import "ChatMessageCell.h"

@implementation ChatMessageCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    _bubbleImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(_msgBottomView.frame), CGRectGetHeight(_msgBottomView.frame))];
    [_bubbleImageView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    UIImage *image = [UIImage imageNamed:@"bubbleother_normal"];
    image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    _bubbleImageView.image = image;
    [_msgBottomView addSubview:_bubbleImageView];
    [_msgBottomView sendSubviewToBack:_bubbleImageView];
    
    _headImage.layer.cornerRadius = 20.f;
    _headImage.layer.masksToBounds = YES;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (CGFloat)cellHeightForChatMessage:(ChatMessageEntity *)entity
{
    return 0;
}

- (void)setMessage:(ChatMessageEntity *)message
{
    [_message removeObserver:self forKeyPath:@"transferStatus"];
    _message = message;
    [_message addObserver:self forKeyPath:@"transferStatus" options:NSKeyValueObservingOptionNew context:nil];
    
    
    _nameLabel.text = message.from.uiDisplayName;
    [_headImage setContactEntity:message.from];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM-dd HH:mm"];
    NSString *dateStr = [formatter stringFromDate:message.receiveTimestamp];
    self.timeLabel.text = dateStr;
    
    [self updateTransferStatus];
}


/**
 This method is used to update activity view and status image view
 */
- (void)updateTransferStatus
{
    switch (_message.transferStatus.integerValue) {
        case ESpaceMsgStatusSending:
        {
            [_activity setHidden:NO];
            [_activity startAnimating];
            [_statusImg setHidden:YES];
            break;
        }
        case ESpaceMsgStatusSended:
        {
            [_activity setHidden:YES];
            [_statusImg setHidden:YES];
            break;
        }
        case ESpaceMsgStatusSendFailed:
        case ESpaceMsgStatusSendCancelled:
        {
            [_activity setHidden:YES];
            [_statusImg setHidden:NO];
            break;
        }
        default:
            [_activity setHidden:YES];
            [_statusImg setHidden:YES];
            break;
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    __weak typeof(self) weakSelf = self;
    if ([keyPath isEqualToString:@"transferStatus"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self updateTransferStatus];
        });
    }
}

- (void)dealloc
{
    [_message removeObserver:self forKeyPath:@"transferStatus"];
}

@end
