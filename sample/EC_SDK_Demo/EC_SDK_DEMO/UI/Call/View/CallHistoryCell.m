//
//  CallHistoryCell.m
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

#import "CallHistoryCell.h"
#import "CallLogMessage.h"

@interface CallHistoryCell()
@property (weak, nonatomic) IBOutlet UIImageView *callTypeImageView;    // show callType image view
@property (weak, nonatomic) IBOutlet UILabel *startTimeLabe;            // show start time
@property (weak, nonatomic) IBOutlet UILabel *durationTimeLabel;        // show duration time
@property (weak, nonatomic) IBOutlet UILabel *numberLable;              // show number

@end
@implementation CallHistoryCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setCallLogMessage:(CallLogMessage *)callLogMessage
{
    _callLogMessage = callLogMessage;
    _startTimeLabe.text = callLogMessage.startTime;
    [self refreshTipMessage:callLogMessage.durationTime];
    _numberLable.text = callLogMessage.calleePhoneNumber;
    
    UIImage *imageName = nil;
    switch (callLogMessage.callLogType) {
        case OutgointCall:
        {
            imageName = [UIImage imageNamed:@"cell_call"];
        }
            break;
        case MissedCall:
        {
            imageName = [UIImage imageNamed:@"cell_noanswer"];
        }
            break;
        case ReceivedCall:
        {
            imageName = [UIImage imageNamed:@"cell_answer"];
        }
            break;
        default:
            break;
    }
    _callTypeImageView.image = imageName;
}


/**
 This method is used to refresh duration time

 @param callDuration callDuration
 */
- (void)refreshTipMessage:(NSInteger)callDuration {
    NSString* tipMessage = nil;
    if ((long)callDuration/3600 > 0) {
        tipMessage = [NSString stringWithFormat:@"%.2ld:%.2ld:%.2ld",(long)callDuration/3600,(long)callDuration%3600/60,(long)callDuration%60];
    } else {
        tipMessage = [NSString stringWithFormat:@"%.2ld:%.2ld",(long)callDuration/60,(long)callDuration%60];
    }
    _durationTimeLabel.text = tipMessage;
}

@end
