//
//  CreateGroupController.h
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, CreateGroupType)
{
    ADD_USER				=	0,						//add user
    CREATE_GROUP			=	1,						//create group
};

@class GroupEntity;
@interface CreateGroupController : UIViewController
@property (nonatomic, strong)GroupEntity *currentGroup;          // current group entity
@property (nonatomic, assign)CreateGroupType createGroupType;    // current CreateGroupType
@end
