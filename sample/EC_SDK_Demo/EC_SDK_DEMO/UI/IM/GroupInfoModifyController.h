//
//  GroupInfoModifyController.h
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

#import <UIKit/UIKit.h>
#import "Defines.h"

@class GroupEntity;
@interface GroupInfoModifyController : UIViewController
@property (nonatomic, strong)GroupEntity *group;                // current group entity
@property (nonatomic, assign)GroupInfoModifyType modifyType;    // current GroupInfoModifyType
@end
