//
//  CreateGroupController.h
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

#import <UIKit/UIKit.h>
#import "Defines.h"

@class GroupEntity;
@interface CreateGroupController : UIViewController
@property (nonatomic, strong)GroupEntity *currentGroup;          // current group entity
@property (nonatomic, assign)CreateGroupType createGroupType;    // current CreateGroupType
@end
