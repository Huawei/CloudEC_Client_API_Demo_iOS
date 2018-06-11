//
//  CallInfo.m
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

#import "CallInfo.h"

@implementation CallStateInfo

/**
 *This method is used to init CallStateInfo
 *初始化CallStateInfo
 */
- (id)init
{
    if (self = [super init])
    {
        _callId = 0;
        _callType = CALL_UNKNOWN;
        _callState = CallStateButt;
        _reasonCode = 0;
    }
    return self;
}

@end

@implementation CallInfo

/**
 *This method is used to init CallInfo，get an instance of CallStateInfo
 *初始化CallInfo,获取CallStateInfo实例
 */
- (id)init
{
    if (self = [super init])
    {
        _stateInfo = [[CallStateInfo alloc]init];
    }
    return self;
}

@end
