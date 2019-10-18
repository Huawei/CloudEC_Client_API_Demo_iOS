//
//  ConfChatTableViewController.h
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

#import <UIKit/UIKit.h>
#import "ECBaseViewController.h"

@class ConfAttendeeInConf;
@interface ConfChatViewController : ECBaseViewController
@property (nonatomic, strong)NSArray *confAttendees;
@property (nonatomic, strong)ConfAttendeeInConf *selfInfo;

@end
