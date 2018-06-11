//
//  ConfDetailViewController.h
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

#import <UIKit/UIKit.h>
#import "ManagerService.h"
#import "ECConfInfo.h"
@interface ConfDetailViewController : UITableViewController
@property (nonatomic, strong)ECConfInfo *confInfo;
@end
