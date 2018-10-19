//
//  Notification.m
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

#import "Notification.h"

@implementation Notification

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
               data:(void*)data
{
    if (self = [super init])
    {
        _msgId = msgId;
        _param1 = param1;
        _param2 = param2;
        _data = data;
    }
    return self;
}

@end
