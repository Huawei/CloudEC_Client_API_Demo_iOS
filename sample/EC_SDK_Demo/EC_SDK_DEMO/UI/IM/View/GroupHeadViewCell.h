//
//  GroupHeadViewCell.h
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

#import <UIKit/UIKit.h>
@class GroupEntity;
@interface GroupHeadViewCell : UITableViewCell
@property (nonatomic, strong) GroupEntity *group;                 // current groupEntity
@property (nonatomic, weak) UIViewController *parentViewCtrl;     // parent viewController
@end
