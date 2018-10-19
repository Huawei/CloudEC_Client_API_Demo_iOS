//
//  Notification.h
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

#import <Foundation/Foundation.h>
#import "tsdk_def.h"


@interface Notification : NSObject
@property (nonatomic, assign)TSDK_UINT32 msgId;    // the message ID
@property (nonatomic, assign)TSDK_UINT32 param1;   // the parameter 1
@property (nonatomic, assign)TSDK_UINT32 param2;   // the parameter 2
@property (nonatomic, assign)void *data;          // the message to attach data

/**
 * This method is used to init Notification.
 * 初始化Notification
 *@param msgId TUP_UINT32
 *@param param1 TUP_UINT32
 *@param param2 TUP_UINT32
 *@param data void*
 *@return Notification
 */
- (id)initWithMsgId:(TSDK_UINT32)msgId
             param1:(TSDK_UINT32)param1
             param2:(TSDK_UINT32)param2
               data:(void*)data;

@end
