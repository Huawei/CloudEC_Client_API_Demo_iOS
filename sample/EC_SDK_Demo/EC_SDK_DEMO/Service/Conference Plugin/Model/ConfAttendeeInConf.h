//
//  ConfAttendeeInConf.h
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//
#import <Foundation/Foundation.h>
#import "Defines.h"
@interface ConfAttendeeInConf : NSObject


@property (nonatomic, copy) NSString *participant_id; //与会者id
@property (nonatomic, copy) NSString *name;  //与会者名字
@property (nonatomic, copy) NSString *number; //与会者号码
@property (nonatomic, assign) BOOL is_deaf; //与会者是否被禁音
@property (nonatomic, assign) BOOL is_mute; //与会者是否被禁言
@property (nonatomic, assign) BOOL hand_state; //与会者是否举手
@property (nonatomic, assign) CONFCTRL_CONF_ROLE role; //与会者角色
@property (nonatomic, assign) EC_CONF_MEDIATYPE type;  //会议类型
@property (nonatomic, assign) ATTENDEE_STATUS_TYPE state; //与会者状态

@property (nonatomic, copy) NSString *userID; //用户id
@property (nonatomic, assign) DataConfAttendeeMediaState dataState; //数据会议状态
@property (nonatomic, assign) DATACONF_USER_ROLE_TYPE dataRole; //数据会议角色
@property (nonatomic, assign) BOOL isJoinDataconf; //是否加入数据会议
@property (nonatomic, assign) BOOL isPresent; //是否是主讲人
@property (nonatomic, assign) BOOL isSelf; //是否是自己

@end


@interface ConfCtrlSpeaker : NSObject
@property (nonatomic, copy) NSString *number; //发言人号码
@property (nonatomic, assign) BOOL is_speaking; //是否在发言
@property (nonatomic, assign) int speaking_volume; //发言音量
@end
