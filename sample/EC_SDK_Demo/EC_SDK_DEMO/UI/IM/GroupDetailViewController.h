//
//  GroupDetailViewController.h
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

#import <UIKit/UIKit.h>
@class GroupEntity;
@interface GroupDetailViewController : UIViewController
@property(nonatomic,strong)GroupEntity * groupModel;      // current group entity
@end
