//
//  ECConfInfo.h
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

#import <Foundation/Foundation.h>
#import "Defines.h"


typedef enum
{
    CONF_E_CONF_STATE_SCHEDULE = 0,    //预定状态
    CONF_E_CONF_STATE_CREATING,        //正在创建状态
    CONF_E_CONF_STATE_GOING,           //会议已经开始
    CONF_E_CONF_STATE_DESTROYED        //会议已经关闭
} CONF_E_CONF_STATE;

@interface ECConfInfo : NSObject
@property (nonatomic, copy) NSString *conf_id; //会议id
@property (nonatomic, copy) NSString *conf_subject; //会议主题
@property (nonatomic, copy) NSString *access_number; //会议介入码
@property (nonatomic, copy) NSString *chairman_pwd; //会议主席密码
@property (nonatomic, copy) NSString *general_pwd; //普通与会者密码
@property (nonatomic, copy) NSString *start_time; //会议开始时间
@property (nonatomic, copy) NSString *end_time; //会议结束时间
@property (nonatomic, copy) NSString *scheduser_number; //会议预约者号码
@property (nonatomic, copy) NSString *scheduser_name; //会议预约者名字
@property (nonatomic, assign) EC_CONF_MEDIATYPE media_type; //媒体类型
@property (nonatomic, assign) CONF_E_CONF_STATE conf_state; //会议状态
@property (nonatomic, assign) BOOL isHdConf; //是否高清视频会议
@property (nonatomic, copy) NSString *token; //会议token
@property (nonatomic, copy) NSString *chairJoinUri; //主持人加入会议uri链接
@property (nonatomic, copy) NSString *guestJoinUri; //来宾加入会议uri链接


@end
