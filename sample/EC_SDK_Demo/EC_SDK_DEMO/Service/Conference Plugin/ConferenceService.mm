//
//  ConferenceService.m
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

#import "ConferenceService.h"

#include "tsdk_conference_def.h"
#include "tsdk_conference_interface.h"
#import "tsdk_error_def.h"

#include <arpa/inet.h>
#import <string.h>
#import "ECConfInfo+StructParase.h"
#import "ConfAttendee+StructParase.h"
#import "ManagerService.h"
#import "ConfData.h"
#import "ECCurrentConfInfo.h"
#import "ConfAttendeeInConf.h"
#import "ConfStatus.h"
#import "Initializer.h"
#import "LoginInfo.h"
#import "LoginServerInfo.h"
#import "Defines.h"
#import "AppDelegate.h"
#import "ChatMsg.h"

@interface ConferenceService()<TupConfNotifacation>

@property (nonatomic, assign) int confHandle;                     // current confHandle
@property (nonatomic, assign) NSString *dataConfIdWaitConfInfo;   // get current confId
@property (nonatomic, copy)NSString *sipAccount;                  // current sipAccount
@property (nonatomic, copy)NSString *account;                     // current account
@property (nonatomic, strong) NSString *confCtrlUrl;              // recorde dateconf_uri
@property (nonatomic, strong) NSMutableDictionary *confTokenDic;  // update conference token in SMC
@property (nonatomic, assign) BOOL hasReportMediaxSpeak;          // has reportMediaxSpeak or not in Mediax
@property (nonatomic, retain) NSTimer *heartBeatTimer;            // NSTime record heart beat
@property (nonatomic, assign) int currentCallId;                  // current call id

@end

@implementation ConferenceService

//creat getter and setter method of delegate
@synthesize delegate;

//creat getter and setter method of isJoinDataConf
@synthesize isJoinDataConf;

//creat getter and setter method of haveJoinAttendeeArray
@synthesize haveJoinAttendeeArray;

//creat getter and setter method of uPortalConfType
@synthesize uPortalConfType;

//creat getter and setter method of selfJoinNumber
@synthesize selfJoinNumber;

@synthesize chatDelegate;

/**
 *This method is used to get sip account from call service
 *从呼叫业务获取sip账号
 */
-(NSString *)sipAccount
{
    NSString *sipAccount = [ManagerService callService].sipAccount;
    NSArray *array = [sipAccount componentsSeparatedByString:@"@"];
    NSString *shortSipNum = array[0];
    
    return shortSipNum;
}

/**
 *This method is used to get login account from login service
 *从登陆业务获取鉴权登陆账号
 */
- (NSString *)account
{
    LoginInfo *mine = [[ManagerService loginService] obtainCurrentLoginInfo];
    _account = mine.account;
    
    return _account;
}

/**
 *This method is used to init this class， give initial value
 *初始化方法，给变量赋初始值
 */
-(instancetype)init
{
    if (self = [super init])
    {
        [Initializer registerConfCallBack:self]; //注册回调，将回调消息分发代理设置为自己
        self.isJoinDataConf = NO;
        _confHandle = 0;
        self.haveJoinAttendeeArray = [[NSMutableArray alloc] init]; //会议与会者列表
        self.uPortalConfType = CONF_TOPOLOGY_UC;
        _confTokenDic = [[NSMutableDictionary alloc]init];
        _confCtrlUrl = nil;
        self.selfJoinNumber = nil;
        _hasReportMediaxSpeak = NO;
        _currentCallId = 0;
    }
    return self;
}

#pragma mark - EC 6.0

/**
 * This method is used to deel conference event callback from service
 * 分发回控业务相关回调
 *@param module TUP_MODULE
 *@param notification Notification
 */
- (void)confModule:(TUP_MODULE)module notication:(Notification *)notification
{
    if (module == CONF_MODULE) {
        [self onRecvTupConferenceNotification:notification];
    }else {
        
    }
}

/**
 * This method is used to deel conference event notification
 * 处理回控业务回调
 *@param notify
 */
- (void)onRecvTupConferenceNotification:(Notification *)notify
{
    
    
    DDLogInfo(@"onReceiveConferenceNotification msgId : %d",notify.msgId);
    switch (notify.msgId)
    {
        case TSDK_E_CONF_EVT_BOOK_CONF_RESULT:
        {
            DDLogInfo(@"TSDK_E_CONF_EVT_BOOK_CONF_RESULT");
            BOOL result = notify.param1 == TSDK_SUCCESS;
            if (!result) {
                DDLogError(@"TSDK_E_CONF_EVT_BOOK_CONF_RESULT,error:%@",[NSString stringWithUTF8String:(TSDK_CHAR *)notify.data]);
                return;
            }
            
            TSDK_S_CONF_BASE_INFO *confListInfo = (TSDK_S_CONF_BASE_INFO *)notify.data;
            ECCurrentConfInfo *currentConfInfo = [[ECCurrentConfInfo alloc] init];
            if (confListInfo != NULL)
            {
                TSDK_S_CONF_BASE_INFO confInfo = (TSDK_S_CONF_BASE_INFO)confListInfo[0];
                ECConfInfo *ecConfInfo = [ECConfInfo returnECConfInfoWith:confListInfo[0]];
                currentConfInfo.confDetailInfo = ecConfInfo;
                _dataConfIdWaitConfInfo = currentConfInfo.confDetailInfo.conf_id;
                if (strlen(confInfo.token)) {
                    NSString *smcToken = [NSString stringWithUTF8String:confInfo.token];
                    [self updateSMCConfToken:smcToken inConf:currentConfInfo.confDetailInfo.conf_id];
                }
                
            }
            
            NSDictionary *resultInfo = @{
                                         ECCONF_RESULT_KEY : [NSNumber numberWithBool:result],
                                         ECCONF_BOOK_CONF_INFO_KEY : currentConfInfo
                                         };
            [self respondsECConferenceDelegateWithType:CONF_E_CREATE_RESULT result:resultInfo];
            
        }
            break;
        
        case TSDK_E_CONF_EVT_QUERY_CONF_LIST_RESULT:
        {
            DDLogInfo(@"TSDK_E_CONF_EVT_QUERY_CONF_LIST_RESULT");
            BOOL result = notify.param1 == TSDK_SUCCESS;
            if (!result) {
                DDLogError(@"TSDK_E_CONF_EVT_QUERY_CONF_LIST_RESULT,error:%@",[NSString stringWithUTF8String:(TSDK_CHAR *)notify.data]);
                return;
            }
            
            [self handleGetConfListResult:notify];
        }
            break;
            
        case TSDK_E_CONF_EVT_QUERY_CONF_DETAIL_RESULT:
        {
            DDLogInfo(@"TSDK_E_CONF_EVT_QUERY_CONF_DETAIL_RESULT");
            BOOL result = notify.param1 == TSDK_SUCCESS;
            if (!result) {
                DDLogError(@"TSDK_E_CONF_EVT_QUERY_CONF_DETAIL_RESULT,error:%@",[NSString stringWithUTF8String:(TSDK_CHAR *)notify.data]);
                return;
            }
            [self handleGetConfInfoResult:notify];
        }
            break;
            
        case TSDK_E_CONF_EVT_JOIN_CONF_RESULT:
        {
            DDLogInfo(@"TSDK_E_CONF_EVT_JOIN_CONF_RESULT");
            BOOL result = notify.param2 == TSDK_SUCCESS;
            if (!result) {
                DDLogError(@"TSDK_E_CONF_EVT_JOIN_CONF_RESULT,error:%@",[NSString stringWithUTF8String:(TSDK_CHAR *)notify.data]);
                return;
            }
            
            _confHandle = notify.param1;
            TSDK_S_JOIN_CONF_IND_INFO *confInfo = (TSDK_S_JOIN_CONF_IND_INFO *)notify.data;
            _currentCallId = confInfo->call_id;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                // go conference
                DDLogInfo(@"goConferenceRunView");
                [self goConferenceRunView:nil];
                [self respondsECConferenceDelegateWithType:CONF_E_CONNECT result:nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:TUP_CALL_REMOVE_CALL_VIEW_NOTIFY object:nil];
            });
        }
            break;
        
        case TSDK_E_CONF_EVT_GET_DATACONF_PARAM_RESULT:
        {
            DDLogInfo(@"TSDK_E_CONF_EVT_GET_DATACONF_PARAM_RESULT");
            BOOL result = notify.param2 == TSDK_SUCCESS;
            if (!result) {
                DDLogError(@"TSDK_E_CONF_EVT_GET_DATACONF_PARAM_RESULT,error:%@",[NSString stringWithUTF8String:(TSDK_CHAR *)notify.data]);
                return;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [self joinDataConference];
                [self startHeartBeatTimer];
            });
            
        }
            break;
        
        case TSDK_E_CONF_EVT_CONFCTRL_OPERATION_RESULT:
        {
            DDLogInfo(@"TSDK_E_CONF_EVT_CONFCTRL_OPERATION_RESULT");
            [self onRecvConfCtrlOperationNotification:notify];
        }
            break;
        
        case TSDK_E_CONF_EVT_INFO_AND_STATUS_UPDATE:
        {
            DDLogInfo(@"TSDK_E_CONF_EVT_INFO_AND_STATUS_UPDATE");
            
            [self handleAttendeeUpdateNotify:notify];
        }
            break;
            
        case TSDK_E_CONF_EVT_REQUEST_CONF_RIGHT_FAILED:
        {
            DDLogInfo(@"TSDK_E_CONF_EVT_REQUEST_CONF_RIGHT_FAILED");
            BOOL result = notify.param2 == TSDK_SUCCESS;
            if (!result) {
                DDLogError(@"TSDK_E_CONF_EVT_REQUEST_CONF_RIGHT_FAILED,error:%@",[NSString stringWithUTF8String:(TSDK_CHAR *)notify.data]);
                return;
            }
            
        }
            break;
        
        case TSDK_E_CONF_EVT_CONF_INCOMING_IND:
        {
            if (!self.selfJoinNumber) {
                self.selfJoinNumber = self.sipAccount;
            }
            
            DDLogInfo(@"TSDK_E_CONF_EVT_CONF_INCOMING_IND");
            int callID = notify.param2;
            _confHandle = notify.param1;
            TSDK_S_CONF_INCOMING_INFO *inComingInfo = (TSDK_S_CONF_INCOMING_INFO *)notify.data;
            
            CallInfo *tsdkCallInfo = [[CallInfo alloc]init];
            tsdkCallInfo.stateInfo.callId = callID;
            BOOL is_video_conf = NO;
            if (inComingInfo->conf_media_type == TSDK_E_CONF_MEDIA_VIDEO || inComingInfo->conf_media_type == TSDK_E_CONF_MEDIA_VIDEO_DATA) {
                is_video_conf = YES;
            }
            tsdkCallInfo.stateInfo.callType = is_video_conf?CALL_VIDEO:CALL_AUDIO;
            tsdkCallInfo.stateInfo.callNum = [NSString stringWithUTF8String:inComingInfo->number];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:EC_COMING_CONF_NOTIFY
                                                                object:nil
                                                              userInfo:@{TUP_CONF_INCOMING_KEY : tsdkCallInfo}];
        }
            break;
            
        case TSDK_E_CONF_EVT_CONF_END_IND:
        {
            DDLogInfo(@"TSDK_E_CONF_EVT_CONF_END_IND");
            [self respondsECConferenceDelegateWithType:CONF_E_END_RESULT result:nil];
            
        }
            break;
            
        case TSDK_E_CONF_EVT_JOIN_DATA_CONF_RESULT:
        {
            DDLogInfo(@"TSDK_E_CONF_EVT_JOIN_DATA_CONF_RESULT");
            NSDictionary *resultInfo = nil;
            BOOL isSuccess = notify.param2 == TSDK_SUCCESS;
            resultInfo = @{
                           UCCONF_RESULT_KEY :[NSNumber numberWithBool:isSuccess]
                           };
            [self respondsECConferenceDelegateWithType:DATA_CONF_JOIN_RESOULT result:resultInfo];
        }
            break;
            
        case TSDK_E_CONF_EVT_AS_STATE_CHANGE:
        {
            DDLogInfo(@"TSDK_E_CONF_EVT_AS_STATE_CHANGE");
            TSDK_S_CONF_AS_STATE_INFO *shareState = (TSDK_S_CONF_AS_STATE_INFO *)notify.data;
            TSDK_E_CONF_SHARE_STATE state =  shareState->state;
            if (state == TSDK_E_CONF_AS_STATE_NULL) {
                [self respondsECConferenceDelegateWithType:DATACONF_SHARE_SCREEN_DATA_STOP result:nil];
            }
        }
            break;
        case TSDK_E_CONF_EVT_AS_SCREEN_DATA_UPDATE:
        {
            DDLogInfo(@"TSDK_E_CONF_EVT_AS_SCREEN_DATA_UPDATE");
            [self handleScreenShareDataConfhandle:notify.param1];
        }
            break;
        case TSDK_E_CONF_EVT_RECV_CHAT_MSG:
        {
            TSDK_S_CONF_CHAT_MSG_INFO *chat_msg_info = (TSDK_S_CONF_CHAT_MSG_INFO*)notify.data;
            [self handleChatMSGdata:chat_msg_info];
            DDLogInfo(@"TSDK_E_CONF_EVT_RECV_CHAT_MSG");
            break;
        }
        
//        case CONFCTRL_E_EVT_FLOOR_ATTENDEE_IND:
//        {
//            //Speaker report in this place
//            DDLogInfo(@"CONFCTRL_E_EVT_FLOOR_ATTENDEE_IND handle is : %d",notify.param1);
//            CONFCTRL_S_FLOOR_ATTENDEE_INFO *floorAttendee = (CONFCTRL_S_FLOOR_ATTENDEE_INFO *)notify.data;
//            CONFCTRL_S_SPEAKER *speakers = floorAttendee->speakers;
//            NSMutableArray *tempArray = [[NSMutableArray alloc] init];
//            for (int i =0; i< floorAttendee->num_of_speaker; i++)
//            {
//                DDLogInfo(@"speakers[i].number :%s,speakers[i].is_speaking :%d",speakers[i].number,speakers[i].is_speaking);
//                ConfCtrlSpeaker *speaker = [[ConfCtrlSpeaker alloc] init];
//                speaker.number = [NSString stringWithUTF8String:speakers[i].number];
//                speaker.is_speaking = speakers[i].is_speaking;
//                speaker.speaking_volume = speakers[i].speaking_volume;
//                [tempArray addObject:speaker];
//            }
//
//            NSDictionary *resultInfo = @{
//                                         ECCONF_SPEAKERLIST_KEY : [NSArray arrayWithArray:tempArray]
//                                         };
//            [self respondsECConferenceDelegateWithType:CONF_E_SPEAKER_LIST result:resultInfo];
//        }
//            break;
        default:
            break;
    }
}

-(void)handleScreenShareDataConfhandle:(TSDK_UINT32 )confHandle
{
    TSDK_S_CONF_AS_SCREEN_DATA screenData;
    memset((void *)(&screenData), 0, sizeof(screenData));
    // 获取数据
    TSDK_RESULT dataRet = tsdk_app_share_get_screen_data(confHandle, &screenData);

    if (dataRet != TSDK_SUCCESS)
    {
        DDLogInfo(@"tsdk_app_share_get_screen_data failed:%d",dataRet);
        return;
    }
    DDLogInfo(@"tsdk_app_share_get_screen_data :%d",dataRet);
    char *data = (char *)screenData.data;
    TSDK_UINT32 ssize = *((TSDK_UINT32 *)((char *)data + sizeof(TSDK_UINT16)));
    NSData *imageData = [NSData dataWithBytes:data length:ssize];
    UIImage *image = [[UIImage alloc] initWithData:imageData];
    if (image == nil)
    {
        DDLogInfo(@"share image from data fail!");
        return;
    }
    NSDictionary *shareDataInfo = @{
                                    DATACONF_SHARE_DATA_KEY:image
                                    };
    [self respondsECConferenceDelegateWithType:DATA_CONF_AS_ON_SCREEN_DATA result:shareDataInfo];
}

/**
 * This method is used to deal chat message.
 * 聊天消息处理
 *@param pData void*
 */
-(void)handleChatMSGdata:(TSDK_S_CONF_CHAT_MSG_INFO*)pData
{
    
    TSDK_S_CONF_CHAT_MSG_INFO *chatMsg = (TSDK_S_CONF_CHAT_MSG_INFO *)pData;
    TSDK_CHAR charMsgC[chatMsg->chat_msg_len+1];
    memset(charMsgC, 0, chatMsg->chat_msg_len+1);
    memcpy(charMsgC, chatMsg->chat_msg, chatMsg->chat_msg_len);
    DDLogInfo(@"charMsgC: %s",charMsgC);
    NSString *msgStr = [NSString stringWithUTF8String:charMsgC];

    DDLogInfo(@"msgStr :%@,chatMsg->lpMsg :%s, chatMsg->sender_display_name :%s，chatMsg->nMsgLen:%d",msgStr,chatMsg->chat_msg,chatMsg->sender_display_name,chatMsg->chat_msg_len);
    ChatMsg *tupMsg = [[ChatMsg alloc] init];
    tupMsg.nMsgLen = chatMsg->chat_msg_len;
    tupMsg.time = chatMsg->time;
    tupMsg.lpMsg = msgStr;
    tupMsg.fromUserName = [NSString stringWithUTF8String:chatMsg->sender_display_name];;
    if (tupMsg.fromUserName.length == 0 || tupMsg.fromUserName == nil) {
        tupMsg.fromUserName = [NSString stringWithUTF8String:chatMsg->sender_number];;
    }
    if ([self.chatDelegate respondsToSelector:@selector(didReceiveChatMessage:)]) {
        [self.chatDelegate didReceiveChatMessage:tupMsg];
    }
}

/**
 * This method is used to send chat message in data conference.
 * 在数据会议中发送聊天信息
 *@param message chat message body.
 *@param username mine name in data conference
 *@param userId at p2p chat it represents receiver's user id, at public chat it's ignored
 *@return YES or NO. See call back didReceiveChatMessage:
 */
//- (BOOL)chatSendMsg:(NSString *)message
//       fromUsername:(NSString *)username
//           toUserId:(unsigned int)userId
//{
//    if (message.length == 0 || username.length == 0) {
//        return NO;
//    }
//    TSDK_S_CONF_CHAT_MSG_INFO chat_msg_info;
//    memset(&chat_msg_info, 0, sizeof(TSDK_S_CONF_CHAT_MSG_INFO));
//    chat_msg_info.chat_type = TSDK_E_CONF_CHAT_PUBLIC;
//    strcpy(chat_msg_info.sender_display_name, (TSDK_CHAR*)username.UTF8String);
//    chat_msg_info.chat_msg = (TSDK_CHAR*)message.UTF8String;
//    chat_msg_info.chat_msg_len = strlen(message.UTF8String);
//    TSDK_RESULT result = tsdk_send_chat_msg_in_conference(_confHandle, &chat_msg_info);
//    return result == TSDK_SUCCESS ? YES : NO;
//}

- (void)onRecvConfCtrlOperationNotification:(Notification *)notify
{
    TSDK_S_CONF_OPERATION_RESULT *operationResult = (TSDK_S_CONF_OPERATION_RESULT *)notify.data;
    BOOL result = operationResult->reason_code == TSDK_SUCCESS;
    if (!result) {
        DDLogError(@"onRecvConfCtrlOperationNotification error : %d,  description : %@",operationResult->reason_code, [NSString stringWithUTF8String:operationResult->description]);
    }
    DDLogInfo(@"onRecvConfCtrlOperationNotification operation type : %d",operationResult->operation_type);
    switch (operationResult->operation_type) {
        case TSDK_E_CONF_UPGRADE_CONF:
        {
            DDLogInfo(@"TSDK_E_CONF_UPGRADE_CONF");
            NSDictionary *resultInfo = @{
                                         ECCONF_RESULT_KEY : [NSNumber numberWithInt:result]
                                         };
            [self respondsECConferenceDelegateWithType:CONF_E_UPGRADE_RESULT result:resultInfo];
            
        }
            break;
            
        case TSDK_E_CONF_MUTE_CONF:
        {
            DDLogInfo(@"TSDK_E_CONF_MUTE_CONF");
            NSDictionary *resultInfo = @{
                                         ECCONF_MUTE_KEY: [NSNumber numberWithBool:YES],
                                         ECCONF_RESULT_KEY : [NSNumber numberWithInt:result]
                                         };
            [self respondsECConferenceDelegateWithType:CONF_E_MUTE_RESULT result:resultInfo];
        }
            break;
        case TSDK_E_CONF_UNMUTE_CONF:
        {
            DDLogInfo(@"TSDK_E_CONF_UNMUTE_CONF");
            NSDictionary *resultInfo = @{
                                         ECCONF_MUTE_KEY: [NSNumber numberWithBool:NO],
                                         ECCONF_RESULT_KEY : [NSNumber numberWithInt:result]
                                         };
            [self respondsECConferenceDelegateWithType:CONF_E_MUTE_RESULT result:resultInfo];
        }
            break;
        case TSDK_E_CONF_LOCK_CONF:
        {
            DDLogInfo(@"TSDK_E_CONF_LOCK_CONF");
            NSDictionary *resultInfo = @{
                                         ECCONF_RESULT_KEY : [NSNumber numberWithInt:result]
                                         };
            [self respondsECConferenceDelegateWithType:CONF_E_LOCK_STATUS_CHANGE result:resultInfo];
        }
            break;
        case TSDK_E_CONF_UNLOCK_CONF:
        {
            DDLogInfo(@"TSDK_E_CONF_UNLOCK_CONF");
            NSDictionary *resultInfo = @{
                                         ECCONF_RESULT_KEY : [NSNumber numberWithInt:result]
                                         };
            [self respondsECConferenceDelegateWithType:CONF_E_LOCK_STATUS_CHANGE result:resultInfo];
        }
            break;
        case TSDK_E_CONF_ADD_ATTENDEE:
        {
            DDLogInfo(@"TSDK_E_CONF_ADD_ATTENDEE");
            NSDictionary *resultInfo = @{
                                         ECCONF_RESULT_KEY : [NSNumber numberWithBool:result]
                                         };
            [self respondsECConferenceDelegateWithType:CONF_E_ADD_ATTENDEE_RESULT result:resultInfo];
        }
            break;
        case TSDK_E_CONF_REMOVE_ATTENDEE:
        {
            DDLogInfo(@"TSDK_E_CONF_REMOVE_ATTENDEE");
        }
            break;
            
        case TSDK_E_CONF_REDIAL_ATTENDEE:
        {
            DDLogInfo(@"TSDK_E_CONF_CALL_ATTENDEE");
        }
            break;
            
        case TSDK_E_CONF_HANG_UP_ATTENDEE:
        {
            DDLogInfo(@"TSDK_E_CONF_HANG_UP_ATTENDEE");
            NSDictionary *resultInfo = @{
                                         ECCONF_RESULT_KEY : [NSNumber numberWithInt:result]
                                         };
            [self respondsECConferenceDelegateWithType:CONF_E_HANGUP_ATTENDEE_RESULT result:resultInfo];
        }
            break;
        case TSDK_E_CONF_MUTE_ATTENDEE:
        {
            DDLogInfo(@"TSDK_E_CONF_MUTE_ATTENDEE");
            NSDictionary *resultInfo = @{
                                         ECCONF_RESULT_KEY : [NSNumber numberWithInt:result]
                                         };
            [self respondsECConferenceDelegateWithType:CONF_E_MUTE_ATTENDEE_RESULT result:resultInfo];
        }
            break;
        case TSDK_E_CONF_UNMUTE_ATTENDEE:
        {
            DDLogInfo(@"TSDK_E_CONF_UNMUTE_ATTENDEE");
            NSDictionary *resultInfo = @{
                                         ECCONF_RESULT_KEY : [NSNumber numberWithInt:result]
                                         };
            [self respondsECConferenceDelegateWithType:CONF_E_MUTE_ATTENDEE_RESULT result:resultInfo];
        }
            break;
        case TSDK_E_CONF_SET_HANDUP:
        {
            DDLogInfo(@"TSDK_E_CONF_SET_HANDUP");
            NSDictionary *resultInfo = @{
                                         ECCONF_RESULT_KEY : [NSNumber numberWithInt:result]
                                         };
            [self respondsECConferenceDelegateWithType:CONF_E_HANDUP_ATTENDEE_RESULT result:resultInfo];
        }
            break;
        case TSDK_E_CONF_CANCLE_HANDUP:
        {
            DDLogInfo(@"TSDK_E_CONF_CANCLE_HANDUP");
            NSDictionary *resultInfo = @{
                                         ECCONF_RESULT_KEY : [NSNumber numberWithInt:result]
                                         };
            [self respondsECConferenceDelegateWithType:CONF_E_RAISEHAND_ATTENDEE_RESULT result:resultInfo];
        }
            break;
        case TSDK_E_CONF_SET_VIDEO_MODE:
        {
            DDLogInfo(@"TSDK_E_CONF_SET_VIDEO_MODE");
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:EC_SET_CONF_MODE_NOTIFY
                                                                    object:nil
                                                                  userInfo:@{ECCONF_RESULT_KEY : [NSNumber numberWithBool:result]}];
            });
        }
            break;
        case TSDK_E_CONF_WATCH_ATTENDEE:
        {
            DDLogInfo(@"TSDK_E_CONF_WATCH_ATTENDEE");
        }
            break;
        case TSDK_E_CONF_BROADCAST_ATTENDEE:
        {
            DDLogInfo(@"TSDK_E_CONF_BROADCAST_ATTENDEE");
        }
            break;
        case TSDK_E_CONF_CANCEL_BROADCAST_ATTENDEE:
        {
            DDLogInfo(@"TSDK_E_CONF_CANCEL_BROADCAST_ATTENDEE");
        }
            break;
        case TSDK_E_CONF_REQUEST_CHAIRMAN:
        {
            DDLogInfo(@"TSDK_E_CONF_REQUEST_CHAIRMAN");
            NSDictionary *resultInfo = @{
                                         ECCONF_RESULT_KEY : [NSNumber numberWithInt:result]
                                         };
            [self respondsECConferenceDelegateWithType:CONF_E_REQUEST_CHAIRMAN_RESULT result:resultInfo];
        }
            break;
        case TSDK_E_CONF_RELEASE_CHAIRMAN:
        {
            DDLogInfo(@"TSDK_E_CONF_RELEASE_CHAIRMAN");
            NSDictionary *resultInfo = @{
                                         ECCONF_RESULT_KEY : [NSNumber numberWithInt:result]
                                         };
            [self respondsECConferenceDelegateWithType:CONF_E_RELEASE_CHAIRMAN_RESULT result:resultInfo];
        }
            break;
            
        default:
            break;
    }
    
}

/**
 *This method is used to post service handle result to UI by delegate
 *将业务处理结果消息通过代理分发给页面进行ui处理
 */
-(void)respondsECConferenceDelegateWithType:(EC_CONF_E_TYPE)type result:(NSDictionary *)resultDictionary
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(ecConferenceEventCallback:result:)])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate ecConferenceEventCallback:type result:resultDictionary];
        });
    }
}

/**
 *This method is used to handle conf info update notification
 *处理会议信息改变上报的回调
 */
-(void)handleAttendeeUpdateNotify:(Notification *)notify
{
    TSDK_S_CONF_STATUS_INFO *confStatusStruct = (TSDK_S_CONF_STATUS_INFO *)notify.data;
    ConfStatus *confStatus  = [[ConfStatus alloc] init];
    confStatus.num_of_participant = confStatusStruct->attendee_num;
    confStatus.size = confStatusStruct->size;
    confStatus.media_type = (EC_CONF_MEDIATYPE)confStatusStruct->conf_media_type;
    confStatus.conf_state = (EC_E_CONF_STATE)confStatusStruct->conf_state;
    confStatus.conf_id = [NSString stringWithUTF8String:confStatusStruct->conf_id];
    confStatus.call_id = _currentCallId;
    confStatus.createor = [NSString stringWithUTF8String:confStatusStruct->scheduser_account];
    confStatus.subject = [NSString stringWithUTF8String:confStatusStruct->subject];
    confStatus.record_status = confStatusStruct->is_record;
    confStatus.lock_state = confStatusStruct->is_lock;
    confStatus.is_all_mute = confStatusStruct->is_all_mute;
    TSDK_S_ATTENDEE *participants = confStatusStruct->attendee_list;
    
    
//    // attendee in haveJoinAttendeeArray
//    [self.haveJoinAttendeeArray enumerateObjectsUsingBlock:^(ConfAttendeeInConf* attendee, NSUInteger idx, BOOL * _Nonnull stop) {
//        BOOL isAttendeeInConf = NO;;
//        for (int i = 0; i<confStatusStruct->attendee_num; i++)
//        {
//            TSDK_S_ATTENDEE participant = participants[i];
//            if ([attendee.number isEqualToString:[NSString stringWithUTF8String:participant.base_info.number]]) {
//                attendee.name = [NSString stringWithUTF8String:participant.base_info.display_name];
//                attendee.number = [NSString stringWithUTF8String:participant.base_info.number];
//                attendee.participant_id = [NSString stringWithUTF8String:participant.base_info.account_id];
//                attendee.is_mute = (participant.status_info.is_mute == TUP_TRUE);
//                attendee.hand_state = (participant.status_info.is_handup == TUP_TRUE);
//                attendee.role = (CONFCTRL_CONF_ROLE)participant.base_info.role;
//                attendee.state = (ATTENDEE_STATUS_TYPE)participant.status_info.state;
//                isAttendeeInConf = YES;
//                break;
//            }
//        }
//        //if attendee is not in participants ,update to leave conf.
//        if (!isAttendeeInConf) {
//            attendee.state = ATTENDEE_STATUS_LEAVED;
//            attendee.role = CONF_ROLE_ATTENDEE;
//            attendee.hand_state = NO;
//            attendee.is_mute = NO;
//        }
//    }];
//
//    // new attendee
//    for (int i = 0; i<confStatusStruct->attendee_num; i++)
//    {
//        __block BOOL isExist = NO;
//        TSDK_S_ATTENDEE participant = participants[i];
//        [self.haveJoinAttendeeArray enumerateObjectsUsingBlock:^(ConfAttendeeInConf* attendee, NSUInteger idx, BOOL * _Nonnull stop) {
//            if ([attendee.number isEqualToString:[NSString stringWithUTF8String:participant.base_info.number]]) {
//                isExist = YES;
//                *stop = YES;
//            }
//        }];
//
//        if (!isExist) {
//            ConfAttendeeInConf *addAttendee = [[ConfAttendeeInConf alloc] init];
//            addAttendee.name = [NSString stringWithUTF8String:participant.base_info.display_name];
//            addAttendee.number = [NSString stringWithUTF8String:participant.base_info.number];
//            addAttendee.participant_id = [NSString stringWithUTF8String:participant.base_info.account_id];
//            addAttendee.is_mute = (participant.status_info.is_mute == TUP_TRUE);
//            addAttendee.hand_state = (participant.status_info.is_handup == TUP_TRUE);
//            addAttendee.role = (CONFCTRL_CONF_ROLE)participant.base_info.role;
//            addAttendee.state = (ATTENDEE_STATUS_TYPE)participant.status_info.state;
//
//            [self.haveJoinAttendeeArray addObject:addAttendee];
//        }
//
//        if ([self.selfJoinNumber isEqualToString:[NSString stringWithUTF8String:participant.base_info.number]]) {
//            // if conference'uPortalConfType is CONF_TOPOLOGY_MEDIAX and self role is CONFCTRL_E_CONF_ROLE_CHAIRMAN ,need to open report function ,only once time;
//            if (participant.base_info.role == TSDK_E_CONF_ROLE_CHAIRMAN && [self isUportalMediaXConf] && !_hasReportMediaxSpeak) {
//                _hasReportMediaxSpeak = YES;
//                [self configMediaxSpeakReport];
//            }
//        }
//    }
    
    
    [self.haveJoinAttendeeArray removeAllObjects];
    for (int i = 0; i<confStatusStruct->attendee_num; i++)
    {
        TSDK_S_ATTENDEE participant = participants[i];
        
        ConfAttendeeInConf *addAttendee = [[ConfAttendeeInConf alloc] init];
        addAttendee.name = [NSString stringWithUTF8String:participant.base_info.display_name];
        addAttendee.number = [NSString stringWithUTF8String:participant.base_info.number];
        addAttendee.participant_id = [NSString stringWithUTF8String:participant.status_info.participant_id];
        addAttendee.is_mute = (participant.status_info.is_mute == TSDK_TRUE);
        addAttendee.hand_state = (participant.status_info.is_handup == TSDK_TRUE);
        addAttendee.role = (CONFCTRL_CONF_ROLE)participant.base_info.role;
        addAttendee.state = (ATTENDEE_STATUS_TYPE)participant.status_info.state;
        addAttendee.isJoinDataconf = participant.status_info.is_join_dataconf;
        addAttendee.isPresent = participant.status_info.is_present;
        
        [self.haveJoinAttendeeArray addObject:addAttendee];
        if (!self.selfJoinNumber) {
            self.selfJoinNumber = self.sipAccount;
        }
//        if ([self.selfJoinNumber isEqualToString:[NSString stringWithUTF8String:participant.base_info.number]]) {
//            // if conference'uPortalConfType is CONF_TOPOLOGY_MEDIAX and self role is CONFCTRL_E_CONF_ROLE_CHAIRMAN ,need to open report function ,only once time;
//            if (participant.base_info.role == TSDK_E_CONF_ROLE_CHAIRMAN && [self isUportalMediaXConf] && !_hasReportMediaxSpeak) {
//                _hasReportMediaxSpeak = YES;
//                [self configMediaxSpeakReport];
//            }
//        }
    }
        
    dispatch_async(dispatch_get_main_queue(), ^{
        confStatus.participants = self.haveJoinAttendeeArray;
        NSDictionary *resultInfo = @{
                                     ECCONF_ATTENDEE_UPDATE_KEY: confStatus
                                     };
        [self respondsECConferenceDelegateWithType:CONF_E_ATTENDEE_UPDATE_INFO result:resultInfo];
    });
}

/**
 *This method is used to handle get conf info result notification
 *处理获取会议信息结果回调
 */
-(void)handleGetConfInfoResult:(Notification *)notify
{
    TSDK_S_CONF_DETAIL_INFO *confInfo = (TSDK_S_CONF_DETAIL_INFO*)notify.data;

    TSDK_S_CONF_BASE_INFO confListInfo = confInfo->conf_info;

    DDLogInfo(@"conf_id : %s, subject : %s, conf_media_type: %d,size:%d,scheduser_name:%s,scheduser_account:%s, start_time:%s, end_time:%s, conf_state: %d, confListInfo.chairman_pwd : %s",confListInfo.conf_id,confListInfo.subject,confListInfo.conf_media_type,confListInfo.size,confListInfo.scheduser_name,confListInfo.scheduser_account,confListInfo.start_time,confListInfo.end_time,confListInfo.conf_state,confListInfo.chairman_pwd);

    DDLogInfo(@"num_of_addendee :%d",confInfo->attendee_num);
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    TSDK_S_ATTENDEE_BASE_INFO* attendee = confInfo->attendee_list;
    for (int i = 0; i< confInfo->attendee_num; i++)
    {
        DDLogInfo(@"attendee->display_name :%s,attendee->number: %s",attendee[i].display_name,attendee[i].number);
        ConfAttendee *confAttendee = [ConfAttendee returnConfAttendeeWith:attendee[i]];
        [tempArray addObject:confAttendee];
    }

    ECCurrentConfInfo *currentConfInfo = [[ECCurrentConfInfo alloc] init];
    ECConfInfo *ecConfInfo = [ECConfInfo returnECConfInfoWith:confListInfo];
    currentConfInfo.confDetailInfo = ecConfInfo;
    currentConfInfo.attendeeArray = [NSArray arrayWithArray:tempArray];
    NSString *confID = ecConfInfo.conf_id;
    if (strlen(confListInfo.token)) {
        NSString *smcToken = [NSString stringWithUTF8String:confListInfo.token];
        [self updateSMCConfToken:smcToken inConf:confID];
    }
    
    NSDictionary *resultInfo = @{
                                 ECCONF_CURRENTCONF_DETAIL_KEY : currentConfInfo,
                                 ECCONF_RESULT_KEY : [NSNumber numberWithBool:YES]
                                 };
    //post current conf info detail to UI
    [self respondsECConferenceDelegateWithType:CONF_E_CURRENTCONF_DETAIL result:resultInfo];
}

/**
 *This method is used to handle get conf list result notification, if success refresh UI page
 *处理获取会议列表回调，如果成功，刷新UI页面
 */
-(void)handleGetConfListResult:(Notification *)notify
{
    TSDK_S_CONF_LIST_INFO *confListInfoResult = (TSDK_S_CONF_LIST_INFO*)notify.data;
    DDLogInfo(@"confListInfoResult->current_count----- :%d total_count-- :%d",confListInfoResult->current_count,confListInfoResult->total_count);
    TSDK_S_CONF_BASE_INFO *confList = confListInfoResult->conf_info_list;
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    for (int i = 0; i< confListInfoResult->current_count; i++)
    {
        ECConfInfo *confInfo = [ECConfInfo returnECConfInfoWith:confList[i]];
        if (confInfo.conf_state != CONF_E_CONF_STATE_DESTROYED)
        {
            [tempArray addObject:confInfo];
        }
    }
    NSDictionary *resultInfo = @{
                                 ECCONF_LIST_KEY : tempArray
                                 };
    [self respondsECConferenceDelegateWithType:CONF_E_GET_CONFLIST result:resultInfo];
}

/**
 *This method is used to switch to the conf running page
 *切换到正在召开的会议页面
 */
-(void)goConferenceRunView:(ConfStatus *)confStatus
{
//    if (needRemoveCallWindow) {
//        [[NSNotificationCenter defaultCenter] postNotificationName:TUP_CALL_REMOVE_CALL_VIEW_NOTIFY object:nil];
//    }
        [AppDelegate goConference:confStatus];
}

#pragma mark  public

/**
 *This method is used to give value to struct CONFCTRL_S_ATTENDEE by memberArray
 *用memberArray给结构体CONFCTRL_S_ATTENDEE赋值，为创会时的入参
 */
-(TSDK_S_ATTENDEE_BASE_INFO *)returnAttendeeWithArray:(NSArray *)memberArray
{
    
    TSDK_S_ATTENDEE_BASE_INFO *attendee = (TSDK_S_ATTENDEE_BASE_INFO *)malloc(memberArray.count*sizeof(TSDK_S_ATTENDEE_BASE_INFO));
    memset_s(attendee, memberArray.count *sizeof(TSDK_S_ATTENDEE_BASE_INFO), 0, memberArray.count *sizeof(TSDK_S_ATTENDEE_BASE_INFO));
    for (int i = 0; i<memberArray.count; i++)
    {
        ConfAttendee *tempAttendee = memberArray[i];
        if (tempAttendee.name.length > 0 && tempAttendee.name != nil) {
            strcpy(attendee[i].display_name, [tempAttendee.name UTF8String]);
        }
        if (tempAttendee.number.length > 0 && tempAttendee.number != nil) {
            strcpy(attendee[i].number, [tempAttendee.number UTF8String]);
            strcpy(attendee[i].account_id, [tempAttendee.number UTF8String]);
        }
        
        attendee[i].role = (TSDK_E_CONF_ROLE)tempAttendee.role;
        
//        strcpy(attendee[i].account_id, [@"ios172" UTF8String]);
//        strcpy(attendee[i].display_name, [@"苹果172" UTF8String]);
        
        if (tempAttendee.role == CONF_ROLE_CHAIRMAN) {
            self.selfJoinNumber = tempAttendee.number;
        }
        DDLogInfo(@"attendee is : %s, role : %d",attendee[i].number,attendee[i].role);
    }
    return attendee;
}

/**
 *This method is used to transform local date to UTC date
 *将本地时间转换为UTC时间
 */
-(NSString *)getUTCFormateLocalDate:(NSString *)localDate
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //input
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSDate *dateFormatted = [dateFormatter dateFromString:localDate];
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    [dateFormatter setTimeZone:timeZone];
    //output
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSString *dateString = [dateFormatter stringFromDate:dateFormatted];
    return dateString;
}

#pragma mark  interface

/**
 * This method is used to create conference
 * 创会
 *@param attendeeArray one or more attendees
 *@param mediaType EC_CONF_MEDIATYPE value
 *@return YES or NO
 */
-(BOOL)createConferenceWithAttendee:(NSArray *)attendeeArray mediaType:(EC_CONF_MEDIATYPE)mediaType subject:(NSString *)subject startTime:(NSDate *)startTime confLen:(int)confLen
{
    return [self tupConfctrlBookConf:attendeeArray mediaType:mediaType startTime:startTime confLen:confLen subject:subject];
}

/**
 * This method is used to create conference
 * 创会
 *@param attendeeArray one or more attendees
 *@param mediaType EC_CONF_MEDIATYPE value
 *@return YES or NO
 */
-(BOOL)tupConfctrlBookConf:(NSArray *)attendeeArray mediaType:(EC_CONF_MEDIATYPE)mediaType startTime:(NSDate *)startTime confLen:(int)confLen subject:(NSString *)subject
{
    TSDK_S_BOOK_CONF_INFO *bookConfInfoUportal = (TSDK_S_BOOK_CONF_INFO *)malloc(sizeof(TSDK_S_BOOK_CONF_INFO));
    memset_s(bookConfInfoUportal, sizeof(TSDK_S_BOOK_CONF_INFO), 0, sizeof(TSDK_S_BOOK_CONF_INFO));
    if (subject.length > 0 && subject != nil) {
        strcpy(bookConfInfoUportal->subject, [subject UTF8String]);
    }
    bookConfInfoUportal->conf_type = TSDK_E_CONF_INSTANT;
    if (startTime != nil)
    {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
        NSString *startTimeStr = [dateFormatter stringFromDate:startTime];
        NSString *utcStr = [self getUTCFormateLocalDate:startTimeStr];
        DDLogInfo(@"start time : %@, utc time: %@",startTimeStr,utcStr);
        strcpy(bookConfInfoUportal->start_time, [utcStr UTF8String]);
        
        bookConfInfoUportal->duration = confLen;
        
        bookConfInfoUportal->conf_type = TSDK_E_CONF_RESERVED;
    }
    if (attendeeArray.count == 0)
    {
        bookConfInfoUportal->size = 5;
        bookConfInfoUportal->attendee_num = 0;
        bookConfInfoUportal->attendee_list = NULL;
    }
    else
    {
        bookConfInfoUportal->size = (TSDK_UINT32)attendeeArray.count * 2;
        bookConfInfoUportal->attendee_num = (TSDK_UINT32)attendeeArray.count;
        bookConfInfoUportal->attendee_list = [self returnAttendeeWithArray:attendeeArray];
    }
    
    bookConfInfoUportal->conf_media_type = (TSDK_E_CONF_MEDIA_TYPE)mediaType;
    bookConfInfoUportal->is_hd_conf = TSDK_FALSE;
    bookConfInfoUportal->is_multi_stream_conf = TSDK_FALSE;
    bookConfInfoUportal->is_auto_record = TSDK_FALSE;
    bookConfInfoUportal->is_auto_prolong = TSDK_TRUE;
    bookConfInfoUportal->is_auto_mute = TSDK_FALSE;
    bookConfInfoUportal->welcome_prompt = TSDK_E_CONF_WARNING_DEFAULT;
    bookConfInfoUportal->enter_prompt = TSDK_E_CONF_WARNING_DEFAULT;
    bookConfInfoUportal->leave_prompt = TSDK_E_CONF_WARNING_DEFAULT;
    bookConfInfoUportal->reminder = TSDK_E_CONF_REMINDER_NONE;
    
    // 默认语音提示播报为英文，如需中文播报，此字段赋值TSDK_E_CONF_LANGUAGE_ZH_CN即可。
    bookConfInfoUportal->language = TSDK_E_CONF_LANGUAGE_EN_US;
    
    TSDK_RESULT ret = tsdk_book_conference(bookConfInfoUportal);
    DDLogInfo(@"tsdk_book_conference result : %d",ret);
    free(bookConfInfoUportal);
    return ret == TSDK_SUCCESS ? YES : NO;
}

/**
 * This method is used to get conference list
 * 获取会议列表
 *@param pageIndex pageIndex default 1
 *@param pageSize pageSize default 10
 *@return YES or NO
 */
-(BOOL)obtainConferenceListWithPageIndex:(int)pageIndex pageSize:(int)pageSize
{
    TSDK_S_QUERY_CONF_LIST_REQ conflistInfo;
    memset(&conflistInfo, 0, sizeof(TSDK_S_QUERY_CONF_LIST_REQ));
    conflistInfo.conf_right = TSDK_E_CONF_RIGHT_CREATE_JOIN;
    conflistInfo.is_include_end = TSDK_FALSE;
    conflistInfo.page_index = pageIndex;
    conflistInfo.page_size = pageSize;
    int result = tsdk_query_conference_list(&conflistInfo);
    DDLogInfo(@"tsdk_query_conference_list result: %d",result);
    return result == TSDK_SUCCESS ? YES : NO;
}

/**
 * This method is used to get conference detail info
 * 获取会议详细信息
 *@param confId conference id
 *@param pageIndex pageIndex default 1
 *@param pageSize pageSize default 10
 *@return YES or NO
 */
-(BOOL)obtainConferenceDetailInfoWithConfId:(NSString *)confId Page:(int)pageIndex pageSize:(int)pageSize
{
    if (confId.length == 0)
    {
        DDLogInfo(@"current confId is nil");
        return NO;
    }
    TSDK_S_QUERY_CONF_DETAIL_REQ confInfo;
    memset(&confInfo, 0, sizeof(TSDK_S_QUERY_CONF_LIST_REQ));
    if (confId.length > 0 && confId != nil) {
        strcpy(confInfo.conf_id, [confId UTF8String]);
    }
    confInfo.page_size = pageSize;
    confInfo.page_index = pageIndex;
    
    int getConfInfoRestult = tsdk_query_conference_detail(&confInfo);
    DDLogInfo(@"tsdk_query_conference_detail result: %d",getConfInfoRestult);
    return getConfInfoRestult == TSDK_SUCCESS ? YES : NO;
}

/**
 * This method is used to join conference
 * 加入会议
 *@param confInfo conference
 *@param attendeeArray attendees
 *@return YES or NO
 */
-(BOOL)joinConferenceWithConfId:(NSString *)confId AccessNumber:(NSString *)accessNumber confPassWord:(NSString *)confPassWord joinNumber:(NSString *)joinNumber isVideoJoin:(BOOL)isVideoJoin
{
    TSDK_S_CONF_JOIN_PARAM confJoinParam;
    memset(&confJoinParam, 0, sizeof(TSDK_S_CONF_JOIN_PARAM));
    if (confId.length > 0 && confId != nil) {
        strcpy(confJoinParam.conf_id, [confId UTF8String]);
    }
    if (confPassWord.length > 0 && confPassWord != nil) {
        strcpy(confJoinParam.conf_password, [confPassWord UTF8String]);
    }
    if (accessNumber.length > 0 && accessNumber != nil) {
        strcpy(confJoinParam.access_number, [accessNumber UTF8String]);
    }
    
    TSDK_CHAR join_number;
    if (!self.selfJoinNumber) {
        self.selfJoinNumber = self.sipAccount;
    }
    strcpy(&join_number, [self.selfJoinNumber UTF8String]);
    
    TSDK_UINT32 call_id;
    
    BOOL result = tsdk_join_conference(&confJoinParam, &join_number, (TSDK_BOOL)isVideoJoin, &call_id);
    DDLogInfo(@"tsdk_join_conference = %d, call_id is :%d",result,call_id);
    return result == TSDK_SUCCESS ? YES : NO;
}

/**
 * This method is used accept conference comming call
 * 接听会议来电
 *@return YES or NO
 */
- (BOOL)acceptConfCallIsJoinVideoConf:(BOOL)isJoinVideoConf
{
    BOOL result = tsdk_accept_conference(_confHandle, isJoinVideoConf);
    DDLogInfo(@"tsdk_accept_conference = %d, _confHandle is :%d",result,_confHandle);
    return result == TSDK_SUCCESS ? YES : NO;
}

/**
 * This method is used reject conference comming call 
 * 拒绝接听会议来电
 *@return YES or NO
 */
- (BOOL)rejectConfCall
{
    BOOL result = tsdk_reject_conference(_confHandle);
    DDLogInfo(@"tsdk_reject_conference = %d, _confHandle is :%d",result,_confHandle);
    return result == TSDK_SUCCESS ? YES : NO;
}

/**
 * This method is used to leave conference
 * 离开会议
 *@return YES or NO
 */
-(BOOL)confCtrlLeaveConference
{
    int result = tsdk_leave_conference(_confHandle);
    DDLogInfo(@"tsdk_leave_conference = %d, _confHandle is :%d",result,_confHandle);
    return result == TSDK_SUCCESS ? YES : NO;
}

/**
 * This method is used to end conference (chairman)
 * 结束会议
 *@return YES or NO
 */
-(BOOL)confCtrlEndConference
{
    int result = tsdk_end_conference(_confHandle);
    DDLogInfo(@"tsdk_end_conference = %d, _confHandle is :%d",result,_confHandle);
    return result == TSDK_SUCCESS ? YES : NO;
}

/**
 * This method is used to upgrade audio conference to data conference
 * 语音会议升级为数据会议
 *@param hasVideo whether the conference has video
 *@return YES or NO
 */
-(BOOL)confCtrlVoiceUpgradeToDataConference:(BOOL)hasVideo
{
    int result = tsdk_upgrade_conference(_confHandle, NULL);
    DDLogInfo(@"tsdk_upgrade_conference = %d",result);
    return result == TSDK_SUCCESS ? YES : NO;
}

/**
 * This method is used to mute conference (chairman)
 * 主席闭音会场
 *@param isMute YES or NO
 *@return YES or NO
 */
-(BOOL)confCtrlMuteConference:(BOOL)isMute
{
    TSDK_BOOL tupBool = isMute ? TSDK_TRUE : TSDK_FALSE;
    int result = tsdk_mute_conference(_confHandle, tupBool);
    DDLogInfo(@"tsdk_mute_conference = %d, _confHandle is :%d, isMute:%d",result,_confHandle,isMute);
    return result == TSDK_SUCCESS ? YES : NO;
}

/**
 * This method is used to lock conference (chairman)
 * 主席锁定会场
 *@param isLock YES or NO
 *@return YES or NO
 */
-(BOOL)confCtrlLockConference:(BOOL)isLock
{
    TSDK_BOOL tupBool = isLock ? 1 : 0;
    int result = tsdk_lock_conference(_confHandle, tupBool);
    DDLogInfo(@"tsdk_lock_conference = %d, _confHandle is :%d, isLock:%d",result,_confHandle,isLock);
    return result == TSDK_SUCCESS ? YES : NO;
}

/**
 * This method is used to add attendee to conference
 * 添加与会者到会议中
 @param attendeeArray attendees
 @return YES or NO
 */
-(BOOL)confCtrlAddAttendeeToConfercene:(NSArray *)attendeeArray
{
    if (0 == attendeeArray.count)
    {
        return NO;
    }
    TSDK_S_ADD_ATTENDEES_INFO *attendeeInfo = (TSDK_S_ADD_ATTENDEES_INFO *)malloc( sizeof(TSDK_S_ADD_ATTENDEES_INFO));
    memset_s(attendeeInfo, sizeof(TSDK_S_ADD_ATTENDEES_INFO), 0, sizeof(TSDK_S_ADD_ATTENDEES_INFO));
    attendeeInfo->attendee_num = (TSDK_UINT32)attendeeArray.count;
    TSDK_S_ATTENDEE_BASE_INFO *attendee = (TSDK_S_ATTENDEE_BASE_INFO *)malloc(attendeeArray.count*sizeof(TSDK_S_ATTENDEE_BASE_INFO));
    memset_s(attendee, attendeeArray.count *sizeof(TSDK_S_ATTENDEE_BASE_INFO), 0, attendeeArray.count *sizeof(TSDK_S_ATTENDEE_BASE_INFO));

    for (int i=0; i<attendeeArray.count; i++)
    {
        ConfAttendee *cAttendee = attendeeArray[i];
        strcpy(attendee[i].display_name, [cAttendee.name UTF8String]);
        strcpy(attendee[i].number, [cAttendee.number UTF8String]);
        if (cAttendee.email.length != 0)
        {
            strcpy(attendee[i].email, [cAttendee.email UTF8String]);
        }
        if (cAttendee.sms.length != 0)
        {
            strcpy(attendee[i].sms, [cAttendee.sms UTF8String]);
        }
        attendee[i].role = (TSDK_E_CONF_ROLE)cAttendee.role;
        strcat(attendee[i].account_id, [@"ios173" UTF8String]);
        DDLogInfo(@"cAttendee number is %@,cAttendee role is %lu,attendee[i].role is : %d",cAttendee.number,(unsigned long)cAttendee.role,attendee[i].role);
    }
    attendeeInfo->attendee_list = attendee;
    int result = tsdk_add_attendee(_confHandle, attendeeInfo);
    DDLogInfo(@"tsdk_add_attendee = %d, _confHandle:%d",result,_confHandle);
    free(attendee);
    free(attendeeInfo);
    return result == TSDK_SUCCESS ? YES : NO;
}

/**
 * This method is used to remove attendee
 *  重播与会者
 *@param attendeeNumber attendee number
 *@return YES or NO
 */
-(BOOL)confCtrlRecallAttendee:(NSString *)attendeeNumber
{
    int result = tsdk_redial_attendee(_confHandle, (TSDK_CHAR*)[attendeeNumber UTF8String]);
    DDLogInfo(@"tsdk_redial_attendee = %d, _confHandle:%d, attendeeNumber:%@",result,_confHandle,attendeeNumber);
    return result == TSDK_SUCCESS ? YES : NO;
}

/**
 * This method is used to remove attendee
 * 移除与会者
 *@param attendeeNumber attendee number
 *@return YES or NO
 */
-(BOOL)confCtrlRemoveAttendee:(NSString *)attendeeNumber
{
    int result = tsdk_remove_attendee(_confHandle, (TSDK_CHAR*)[attendeeNumber UTF8String]);
    DDLogInfo(@"tsdk_remove_attendee = %d, _confHandle:%d, attendeeNumber:%@",result,_confHandle,attendeeNumber);
    return result == TSDK_SUCCESS ? YES : NO;
}

/**
 * This method is used to hang up attendee
 * 挂断与会者
 *@param attendeeNumber attendee number
 *@return YES or NO
 */
-(BOOL)confCtrlHangUpAttendee:(NSString *)attendeeNumber
{
    int result = tsdk_hang_up_attendee(_confHandle, (TSDK_CHAR*)[attendeeNumber UTF8String]);
    DDLogInfo(@"tsdk_hang_up_attendee = %d, _confHandle:%d",result,_confHandle);
    return result == TSDK_SUCCESS ? YES : NO;
}

/**
 * This method is used to mute attendee (chairman)
 * 主席闭音与会者
 *@param attendeeNumber attendee number
 *@param isMute YES or NO
 *@return YES or NO
 */
-(BOOL)confCtrlMuteAttendee:(NSString *)attendeeNumber isMute:(BOOL)isMute
{
    TSDK_BOOL tupBool = isMute ? 1 : 0;
    int result = tsdk_mute_attendee(_confHandle, (TSDK_CHAR *)[attendeeNumber UTF8String], tupBool);
    DDLogInfo(@"tsdk_mute_attendee = %d, _confHandle is :%d, isMute:%d, attendee is :%@",result,_confHandle,isMute,attendeeNumber);
    return result == TSDK_SUCCESS ? YES : NO;
}

/**
 * This method is used to raise hand (Attendee)
 * 与会者举手
 *@param raise YES raise hand, NO cancel raise
 *@param attendeeNumber join conference number
 *@return YES or NO
 */
- (BOOL)confCtrlRaiseHand:(BOOL)raise attendeeNumber:(NSString *)attendeeNumber
{
    TSDK_BOOL tupBool = raise ? TSDK_TRUE : TSDK_FALSE;
    int result = tsdk_set_handup(_confHandle, tupBool, (TSDK_CHAR *)[attendeeNumber UTF8String]);
    DDLogInfo(@"tsdk_set_handup = %d, attendee is :%@",result,attendeeNumber);
    return result == TSDK_SUCCESS ? YES : NO;
}

/**
 * This method is used to request chairman right (Attendee)
 * 申请主席权限
 *@param chairPwd chairman password
 *@param newChairNumber attendee's number in conference
 *@return YES or NO
 */
- (BOOL)confCtrlRequestChairman:(NSString *)chairPwd number:(NSString *)newChairNumber
{
    if (newChairNumber.length == 0) {
        return NO;
    }
    TSDK_RESULT ret_request_chairman = tsdk_request_chairman(_confHandle, (TSDK_CHAR *)[chairPwd UTF8String]);
    DDLogInfo(@"tsdk_request_chairman ret: %d", ret_request_chairman);
    return (TSDK_SUCCESS == ret_request_chairman);
}

/**
 * This method is used to release chairman right (chairman)
 * 释放主席权限
 *@param chairNumber chairman number in conference
 *@return YES or NO
 */
- (BOOL)confCtrlReleaseChairman:(NSString *)chairNumber
{
    if (chairNumber.length == 0) {
        return NO;
    }
    TSDK_RESULT ret_release_chairman = tsdk_release_chairman(_confHandle);
    DDLogInfo(@"ret_release_chairman ret: %d", ret_release_chairman);
    return ret_release_chairman == TSDK_SUCCESS;
}

#pragma mark  data conference
-(void)joinDataConference
{
    TSDK_RESULT result = tsdk_join_data_conference(_confHandle);
    DDLogInfo(@"tsdk_join_data_conference ret: %d", result);
}

/**
 * This method is used to set conf mode
 * 设置会议模式
 */
- (void)setConfMode:(EC_CONF_MODE)mode {
    TSDK_E_CONF_VIDEO_MODE tupMode = TSDK_E_CONF_VIDEO_BROADCAST;
    switch (mode) {
        case EC_CONF_MODE_FIXED:
            tupMode = TSDK_E_CONF_VIDEO_BROADCAST;
            break;
        case EC_CONF_MODE_VAS:
            tupMode = TSDK_E_CONF_VIDEO_VAS;
            break;
        case EC_CONF_MODE_FREE:
            tupMode = TSDK_E_CONF_VIDEO_FREE;
            break;
        default:
            break;
    }
    
    TSDK_RESULT ret_set_video_mode = tsdk_set_video_mode(_confHandle, tupMode);
    DDLogInfo(@"ret_set_conf_mode: %d", ret_set_video_mode);
}

/**
 * This method is used to watch attendee
 * 选看与会者
 */
-(void)watchAttendeeNumber:(NSString *)attendeeNumber
{
    TSDK_S_WATCH_ATTENDEES_INFO *attendeeInfo = (TSDK_S_WATCH_ATTENDEES_INFO *)malloc(sizeof(TSDK_S_WATCH_ATTENDEES_INFO));
    memset_s(attendeeInfo, sizeof(TSDK_S_WATCH_ATTENDEES_INFO), 0, sizeof(TSDK_S_WATCH_ATTENDEES_INFO));
    attendeeInfo->watch_attendee_num = 1;
    TSDK_S_WATCH_ATTENDEES *attendeeList = (TSDK_S_WATCH_ATTENDEES *)malloc(sizeof(TSDK_S_WATCH_ATTENDEES));
    memset_s(attendeeList, sizeof(TSDK_S_WATCH_ATTENDEES), 0, sizeof(TSDK_S_WATCH_ATTENDEES));
    strcpy(attendeeList[0].number, [attendeeNumber UTF8String]);
    
    attendeeInfo->watch_attendee_list = attendeeList;
    
    TSDK_RESULT ret_watch_attendee = tsdk_watch_attendee(_confHandle, attendeeInfo);
    DDLogInfo(@"ret_watch_attendee: %d", ret_watch_attendee);
}

/**
 * This method is used to boardcast attendee
 * 广播与会者
 */
- (void)boardcastAttendee:(NSString *)attendeeNumber isBoardcast:(BOOL)isBoardcast {
    TSDK_RESULT ret_boardcast_attendee = tsdk_broadcast_attendee(_confHandle, (TSDK_CHAR *)[attendeeNumber UTF8String], (isBoardcast ? TSDK_TRUE : TSDK_FALSE));
    DDLogInfo(@"tsdk_broadcast_attendee number: %@, is boardcast: %d ret: %d", attendeeNumber, isBoardcast, ret_boardcast_attendee);
}

/**
 * This method is used to create _heartBeatTimer.
 * 创建定时器
 */
-(void)startHeartBeatTimer
{
    dispatch_async(dispatch_get_main_queue(), ^{
        _heartBeatTimer = [NSTimer scheduledTimerWithTimeInterval:0.03
                                                           target:self
                                                         selector:@selector(heartBeat)
                                                         userInfo:nil
                                                          repeats:YES];
    });
}

/**
 * This method is used to stop _heartBeatTimer.
 * 销毁_heartBeatTimer定时器
 */
-(void)stopHeartBeat
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        DDLogInfo(@"<INFO>: stopHeartBeat: enter!!! ");
        if ([self.heartBeatTimer isValid])
        {
            DDLogInfo(@"<INFO>: stopHeartBeat");
            [self.heartBeatTimer invalidate];
            self.heartBeatTimer = nil;
        }
    });
    
}

-(void)heartBeat
{
    tsdk_send_heart_beat(_confHandle);
}

/**
 * This method is used to set other user role (chairman)
 * 主席设置与会者角色
 *@param number number
 *@return YES or NO
 */
-(BOOL)setPresenterNumber:(NSString *)number;
{
    int result = tsdk_set_presenter(_confHandle, (TSDK_CHAR *)[number UTF8String]);
    DDLogInfo(@"tsdk_set_presenter result : %d",result);
    return result == TSDK_SUCCESS ? YES : NO;
}







/**
 * This method is used to dealloc conference params
 * 销毁会议参数信息
 */
-(void)restoreConfParamsInitialValue
{
    DDLogInfo(@"restoreConfParamsInitialValue");
    [_confTokenDic removeAllObjects];
    [self.haveJoinAttendeeArray removeAllObjects];
    self.isJoinDataConf = NO;
    _dataConfIdWaitConfInfo = nil;
    _confCtrlUrl = nil;
    self.selfJoinNumber = nil;
    _hasReportMediaxSpeak = NO;
    [self stopHeartBeat];
    _currentCallId = 0;
}

/**
 *This method is used to save token to token dictionary as the key of conf id if con network is SMC
 *smc组网下。将当前token以conf id为键存入token词典
 */
- (void)updateSMCConfToken:(NSString *)confToken inConf:(NSString *)confId
{
    BOOL isSMCConf = self.uPortalConfType == CONF_TOPOLOGY_SMC ? YES : NO;
    if (!isSMCConf)
    {
        DDLogWarn(@"not smc conf, ignore!");
        return;
    }
    if (nil == confToken || 0 == confToken.length || nil == confId || 0 == confId.length)
    {
        DDLogWarn(@"param is empty!");
        return;
    }
    @synchronized (_confTokenDic) {
        if ([_confTokenDic objectForKey:confId])
        {
            DDLogWarn(@"confToken in conf:%@ has already exist!", confId);
        }
        else
        {
            [_confTokenDic setObject:confToken forKey:confId];
        }
    }
}

/**
 *This method is used to get token from dictionary according to conf id
 *从token字典中拿出conf id对应的token
 */
- (NSString *)smcConfTokenByConfId:(NSString *)confId
{
    BOOL isSMCConf = self.uPortalConfType == CONF_TOPOLOGY_SMC ? YES : NO;
    if (!isSMCConf)
    {
        DDLogWarn(@"not smc conf, has no token!");
        return nil;
    }
    if (nil == confId || 0 == confId.length)
    {
        DDLogWarn(@"confId is empty!");
        return nil;
    }
    @synchronized (_confTokenDic) {
        return [_confTokenDic objectForKey:confId];
    }
}

/**
 *This method is used to remove token from dictionary according to conf id
 *从token字典中移除conf id对应的token
 */
- (void)clearSMCConfTokenByConfId:(NSString *)confId
{
    BOOL isSMCConf = self.uPortalConfType == CONF_TOPOLOGY_SMC ? YES : NO;
    if (!isSMCConf)
    {
        DDLogWarn(@"not smc conf, ignore!");
        return;
    }
    if (nil == confId || 0 == confId.length)
    {
        DDLogWarn(@"confId is empty!");
        return;
    }
    @synchronized (_confTokenDic) {
        [_confTokenDic removeObjectForKey:confId];
    }
}

//get mainConfId with confId in CONF_TOPOLOGY_MEDIAX
- (NSString *)mainConfIdByDBConfID:(NSString *)confId
{
    //if uPortalConfType is not CONF_TOPOLOGY_MEDIAX ,use current confId.
    BOOL isMediaXConf = self.uPortalConfType == CONF_TOPOLOGY_MEDIAX ? YES : NO;
    if (!isMediaXConf)
    {
        return confId;
    }
    NSString *mainConfId = confId;
    NSRange range = [confId rangeOfString:@"sub"];
    if (range.length > 0)
    {
        mainConfId = [confId substringToIndex:range.location];
    }
    DDLogInfo(@"confId is:%@, mainConfID is:%@", confId, mainConfId);
    return mainConfId;
}

/**
 * This method is used to judge whether is uportal mediax conf
 * 判断是否为mediax下的会议
 */
- (BOOL)isUportalMediaXConf
{
    
    //Mediax conference
//    return  (CONF_TOPOLOGY_MEDIAX == self.uPortalConfType);
    return YES;
}

/**
 * This method is used to judge whether is uportal smc conf
 * 判断是否为smc下的会议
 */
- (BOOL)isUportalSMCConf
{
    //SMC conference
//    return (CONF_TOPOLOGY_SMC == self.uPortalConfType);
    return YES;
}

/**
 * This method is used to judge whether is uportal UC conf
 * 判断是否为uc下的会议
 */
- (BOOL)isUportalUSMConf
{
    //UC conference
//    return (CONF_TOPOLOGY_UC == self.uPortalConfType);
    return NO;
}

///**
// *This method is used to enable or disable speaker report
// *开启或者关闭发言人上报
// */
//- (void)configMediaxSpeakReport
//{
//    TSDK_RESULT result = tup_confctrl_set_speaker_report(_confHandle, TUP_TRUE);
//    DDLogInfo(@"tup_confctrl_set_speaker_report, result : %d",result);
//}

@end
