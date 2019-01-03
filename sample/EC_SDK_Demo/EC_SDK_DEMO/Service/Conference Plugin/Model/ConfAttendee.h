//
//  ConfAttendee.h
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

#import <Foundation/Foundation.h>
#import "Defines.h"

/**
 *This enum is about confctrl attendee type enum
 *与会者类型枚举值
 */
typedef NS_ENUM(NSUInteger, CONFCTRL_ATTENDEE_TYPE) {
    ATTENDEE_TYPE_NORMAL,
    ATTENDEE_TYPE_TELEPRESENCE,
    ATTENDEE_TYPE_SINGLE_CISCO_TP,
    ATTENDEE_TYPE_THREE_CISCO_TP,
    ATTENDEE_TYPE_H323
};

@interface ConfAttendee : NSObject
@property (nonatomic, copy)NSString *account;
@property (nonatomic, copy) NSString *number;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *email;
@property (nonatomic, copy) NSString *sms;
@property (nonatomic, assign) BOOL is_mute;
@property (nonatomic, assign) CONFCTRL_CONF_ROLE role;
@property (nonatomic, assign) CONFCTRL_ATTENDEE_TYPE type;

//Have join the conference property
@property (nonatomic, copy) NSString *participant_id;


@end
