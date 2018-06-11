//
//  AttendeeListCell.h
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

#import <UIKit/UIKit.h>
@class ConfAttendeeInConf;

@interface AttendeeListCell : UITableViewCell
@property (nonatomic,strong) ConfAttendeeInConf *attendee;
@property (nonatomic,assign) BOOL isSpeaking;

- (void)startInvitingAnimation;
@end
