//
//  ConfStatus.h
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

#import <Foundation/Foundation.h>
#import "Defines.h"

/**
 *This enum is about conf state enum
 *会议状态枚举
 */
typedef enum
{
    CONF_STATE_SCHEDULE = 0,
    CONF_STATE_CREATING,
    CONF_STATE_GOING,
    CONF_STATE_DESTROYED
} EC_E_CONF_STATE;

@class ConfAttendeeInConf;
@interface ConfStatus : NSObject

@property (nonatomic, copy) NSString *conf_id; //会议id
@property (nonatomic, assign) int call_id; // call id
@property (nonatomic, copy) NSString *createor; //会议创建者
@property (nonatomic, copy) NSString *subject; //会议主题
@property (nonatomic, assign) int size; //会议大小
@property (nonatomic, assign) int num_of_participant; //与会者个数
@property (nonatomic, assign) EC_CONF_MEDIATYPE media_type; //会议类型
@property (nonatomic, assign) EC_E_CONF_STATE conf_state; //会议状态
@property (nonatomic, assign) BOOL record_status; //会议录制状态
@property (nonatomic, assign) BOOL lock_state; //会议锁定状态
@property (nonatomic, assign) BOOL is_all_mute; //是否全员禁言
@property (nonatomic, strong) NSArray *participants; //与会者
@property (nonatomic, assign) BOOL isHdConf; //是否高清视频会议

@end
