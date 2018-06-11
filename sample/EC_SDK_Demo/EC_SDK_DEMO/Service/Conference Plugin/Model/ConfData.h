//
//  ConfData.h
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

#import <Foundation/Foundation.h>
#import "Defines.h"

/**
 *This enum is about attendee role enum
 *与会者角色枚举
 */
typedef NS_ENUM(NSUInteger, AttendeeRole) {
    ConfRoleAttendee,
    ConfRoleChairman,
    ConfRoleConfChain,
    ConfRoleChairmanDn,
    ConfRoleBUTT,
};

/**
 *This enum is about attendee state enum
 *与会者状态枚举
 */
typedef NS_ENUM(NSUInteger, AttendeeState) {
    AttendeeStateInviting,
    AttendeeStateInvitFailed,
    AttendeeStateAddFailed,
    AttendeeStateInConf,
    AttendeeStateOut,
    AttendeeStateBUTT
};


@interface ConfMember : NSObject

@property(nonatomic, assign)NSInteger memberId; //与会者id
@property(nonatomic, copy)NSString* number;  //与会者号码
@property(nonatomic, assign)AttendeeRole role; //与会者角色
@property(nonatomic, assign)AttendeeState state; //与会者状态
@property(nonatomic, assign)BOOL speakRight; //与会者是否有发言权
@property(nonatomic, assign)NSInteger dataConfStatus; //数据会议状态

@end

@interface ConfData : NSObject
@property(nonatomic, assign)unsigned int confId; //会议id
@property(nonatomic, assign)unsigned int callId; //呼叫id
@property(nonatomic, assign)ConfType confType; //会议类型
@property(nonatomic, retain)NSMutableArray* memberList; //与会者列表
@property(nonatomic, assign)BOOL isConfMute; //会议是否禁言
@property(nonatomic, assign)BOOL isLockConf; //会议是否被锁定


@end
