//
//  CallService.h
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

#import <Foundation/Foundation.h>
#import "CallInterface.h"

extern NSString* const TSDK_COMING_CALL_NOTIFY;              // 新来电通知

@class CallInfo;
@interface CallService : NSObject<CallInterface>

@end
