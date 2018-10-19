//
//  CallInfo+StructParase.m
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//
#import "CallInfo+StructParase.h"

@implementation CallInfo (StructParase)

/**
 *This method is used to parse C struct CALL_S_CALL_INFO to instance of class CallInfo
 *将头文件的结构体CALL_S_CALL_INFO转换为类CallInfo的实例
 */
+ (CallInfo *)transfromFromCallInfoStract:(TSDK_S_CALL_INFO *)callInfo
{
    if (NULL == callInfo)
    {
        return nil;
    }
//    CALL_S_CALL_STATE_INFO callStateInfo = callInfo->stCallStateInfo;
    CallStateInfo *stateInfo = [[CallStateInfo alloc]init];
    stateInfo.callId = callInfo->call_id;
    stateInfo.callType = (callInfo->is_video_call == TSDK_TRUE)?CALL_VIDEO:CALL_AUDIO;
    stateInfo.callState = (CallState)callInfo->call_state;
    if (0 < strlen(callInfo->peer_number))
    {
        stateInfo.callNum = [NSString stringWithUTF8String:callInfo->peer_number];
    }
    else if (0 < strlen(callInfo->peer_display_name))
    {
        stateInfo.callNum = [NSString stringWithUTF8String:callInfo->peer_display_name];
    }
    else
    {
        stateInfo.callNum = @"";
    }
    if (0 < strlen(callInfo->peer_display_name))
    {
        stateInfo.callName = [NSString stringWithUTF8String:callInfo->peer_display_name];
    }
    stateInfo.reasonCode = callInfo->reason_code;
    
    CallInfo *info = [[CallInfo alloc]init];
    info.isFocus = callInfo->is_focus;
    info.stateInfo = stateInfo;
//    info.orientType = callInfo->ulOrientType;
    if (0 < strlen(callInfo->peer_number))
    {
        info.telNumTel = [NSString stringWithUTF8String:callInfo->peer_number];
    }
    if (0 < strlen(callInfo->conf_id))
    {
        info.serverConfId = [NSString stringWithUTF8String:callInfo->conf_id];
    }
    
    return info;
}

@end
