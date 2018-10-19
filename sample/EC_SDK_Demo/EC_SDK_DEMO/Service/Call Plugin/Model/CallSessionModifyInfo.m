//
//  CallSessionModifyInfo.m
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

#import "CallSessionModifyInfo.h"

@implementation CallSessionModifyInfo

/**
 *This method is used to init this class with C struct CALL_S_SESSION_MODIFIED
 *使用结构体CALL_S_SESSION_MODIFIED的指针初始化该类
 */
//+(instancetype)initWithCallSessionModified:(CALL_S_SESSION_MODIFIED *)sessionModify
//{
//    CallSessionModifyInfo *tupSession = [[CallSessionModifyInfo alloc] init];
//    tupSession.callId = sessionModify->ulCallID;
//    tupSession.isFocus = sessionModify->bIsFocus;
//    tupSession.serverConfType = [NSString stringWithUTF8String:sessionModify->acServerConfType];
//    tupSession.serverConfID = [NSString stringWithUTF8String:sessionModify->acServerConfID];
//    tupSession.orientType = sessionModify->ulOrientType;
//    tupSession.localAddress = [NSString stringWithUTF8String:sessionModify->acLocalAddr];
//    tupSession.remoteAddress = [NSString stringWithUTF8String:sessionModify->acRemoteAddr];
//    tupSession.holdType = (CALL_REINVITE_TYPE)sessionModify->enHoldType;
//    tupSession.audioSendMode = (CALL_MEDIA_SENDMODE)sessionModify->enAudioSendMode;
//    tupSession.videoSendMode = (CALL_MEDIA_SENDMODE)sessionModify->enVideoSendMode;
//    tupSession.dataSendMode = (CALL_MEDIA_SENDMODE)sessionModify->enDataSendMode;
//    tupSession.isLowBWSwitchToAudio = sessionModify->bIsLowBWSwitchToAudio;
//    tupSession.confMediaType = (CALL_CONF_MEDIA_TYPE)sessionModify->ulConfMediaType;
//    tupSession.confTopology = (CALL_CONF_TOPOLOGY_TYPE)sessionModify->enConfTopology;
//    tupSession.isSvcCall = sessionModify->bIsSvcCall;
//    tupSession.svcLablecount = [NSString stringWithUTF8String:&sessionModify->iSvcLablecount];
//    tupSession.aulSvcLable = (int)sessionModify->aulSvcLable;
//    return tupSession;
//}
@end
