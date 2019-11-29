//
//  CallService.mm
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

#import "CallService.h"
#import "CallInfo+StructParase.h"
#import "CallData.h"
#include <netdb.h>
#include <net/if.h>
#include <ifaddrs.h>
#include <arpa/inet.h>
#include <dlfcn.h>
#include <sys/sysctl.h>
#import "ManagerService.h"
#include <string.h>
#import <UIKit/UIKit.h>
#import "Initializer.h"
#import "CallSessionModifyInfo.h"
#import "IPTConfig.h"
#import "LoginInfo.h"
#import "CommonUtils.h"
#import "CallLogMessage.h"

#import "tsdk_def.h"
#import "tsdk_error_def.h"
#import "tsdk_manager_def.h"
#import "tsdk_manager_interface.h"
#import "tsdk_call_interface.h"
#import "tsdk_ctd_def.h"
#import "tsdk_ctd_interface.h"
#import "tsdk_call_def.h"

#import "CallStatisticInfo.h"
#import "VideoStreamInfo.h"
#import "AudioStreamInfo.h"
#import "JoinConfIndInfo.h"


#define CHECKCSTR(str) (((str) == NULL) ? "" : (str))

#define CALLINFO_CALLNUMBER_KEY @"CALLINFO_CALLNUMBER_KEY"
#define CALLINFO_SIPNUMBER_KEY  @"CALLINFO_SIPNUMBER_KEY"

#define USER_AGENT_UC @"eSpace Mobile"

@interface CallService()<TupCallNotifacation>
{
    int _playHandle;
}

/**
 *Indicates local view
 *本地画面
 */
@property (nonatomic, strong)id localView;

/**
 *Indicates remote view
 *远端画面
 */
@property (nonatomic, strong)id remoteView;

/**
 *Indicates camera index, 1:front camera; 0:back camera
 *摄像头序号， 1为前置摄像头，0为后置摄像头
 */
@property (nonatomic,assign)CameraIndex cameraCaptureIndex;

/**
 *Indicates camera rotation, 0：90 1：180 2：270 3：360
 *摄像头方向，0：90 1：180 2：270 3：360
 */
@property (nonatomic,assign)NSInteger cameraRotation;

/**
 *Indicates video preview
 *视频预览
 */
@property (nonatomic, strong)id videoPreview;

/**
 *Indicates ctd call id
 *点击呼叫的呼叫id
 */
@property (nonatomic, assign)int ctdCallId;

/**
 *Indicates dictionary used to record callInfo,key:callID,value:callInfo
 *用于存储呼叫信息的词典
 */
@property (nonatomic,strong)NSMutableDictionary<NSString* , CallInfo*> *tsdkCallInfoDic;

/**
 *Indicates authorize token
 *鉴权token
 */
@property (nonatomic, copy)NSString *token;

@end

@implementation CallService

//creat getter and setter method of delegate
@synthesize delegate;

//creat getter and setter method of sipAccount
@synthesize sipAccount;

//creat getter and setter method of terminal
@synthesize terminal;

//creat getter and setter method of isShowTupBfcp
@synthesize isShowTupBfcp;

//creat getter and setter method of iptDelegate
@synthesize iptDelegate;

/**
 *This method is used to creat single instance of this class
 *创建该类的单例
 */
+(instancetype)shareInstance
{
    static CallService *_tupCallService = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _tupCallService = [[CallService alloc] init];
    });
    return _tupCallService;
}

/**
 *This method is used to init this class
 *初始化该类
 */
-(instancetype)init
{
    if (self = [super init])
    {
        [Initializer registerCallCallBack:self];
        _cameraRotation = 0;
        _cameraCaptureIndex = CameraIndexFront;
        _tsdkCallInfoDic = [NSMutableDictionary dictionary];
        _playHandle = -1;
        self.isShowTupBfcp = NO;
    }
    return self;
}

/**
 * This method is used to get call info with confId
 * 用confid获取呼叫信息
 *@param confId              Indicates conference Id
 *                           会议id
 *@return call Info          Return call info
 *                           返回值为呼叫信息
 *@return YES or NO
 */
- (CallInfo *)callInfoWithConfId:(NSString *)confId
{
    NSArray *array = [_tsdkCallInfoDic allValues];
    for (CallInfo *info in array) {
        if ([info.serverConfId isEqualToString:confId]) {
            return info;
        }
    }
    return nil;
}

/**
 * This method is used to hang up all call.
 * 挂断所有呼叫
 */
- (void)hangupAllCall
{
    NSArray *array = [_tsdkCallInfoDic allValues];
    for (CallInfo *info in array) {
        [self closeCall:info.stateInfo.callId];
    }
}

/**
 * This method is used to config bussiness token
 * 配置业务token
 *@param sipAccount         Indicates sip account
 *                          sip账号
 *@param terminal         Indicates terminal
 *                          terminal号码（长号）
 *@param token              Indicates token
 *                          鉴权token
 */
- (void)configBussinessAccount:(NSString *)sipAccount
                      terminal:(NSString *)terminal
                         token:(NSString *)token
{
    if (token.length > 0 || token != nil) {
        self.token = token;
    }
    if (sipAccount.length > 0 || sipAccount != nil) {
        self.sipAccount = sipAccount;
    }
    if (terminal.length > 0 || terminal != nil) {
        self.terminal = terminal;
    }
}

/**
 * This method is used to deel call event callback from service
 * 分发呼叫业务相关回调
 *@param module TUP_MODULE
 *@param notification Notification
 */
- (void)callModule:(TUP_MODULE)module notication:(Notification *)notification
{
    if (module == CALL_SIP_MODULE) {
        [self onRecvCallNotification:notification];
    }
    else {
        [self onRecvCTDNotification:notification];
    }
}

/**
 *This method is used to deel ctd notification
 *处理ctd回调业务
 *@param notify
 */
-(void)onRecvCTDNotification:(Notification *)notify
{
    switch (notify.msgId)
    {
        case TSDK_E_CTD_EVT_START_CALL_RESULT:
        {
            DDLogInfo(@"TSDK_E_CTD_EVT_START_CALL_RESULT callId: %d ,result: %d",notify.param1,notify.param2);
            BOOL result = notify.param2 == TSDK_SUCCESS ? YES : NO;
            NSDictionary *resultInfo = @{
                                         TSDK_CTD_CALL_RESULT_KEY : [NSNumber numberWithBool:result]
                                         };
            [self respondsCTDDelegateWithType:CTD_CALL_RESULT result:resultInfo];
        }
            break;
        case TSDK_E_CTD_EVT_END_CALL_RESULT:
        {
            DDLogInfo(@"TSDK_E_CTD_EVT_END_CALL_RESULT callId: %d ,result: %d",notify.param1,notify.param2);
            BOOL result = notify.param2 == TSDK_SUCCESS ? YES : NO;
            NSDictionary *resultInfo = @{
                                         TSDK_CTD_CALL_RESULT_KEY : [NSNumber numberWithBool:result]
                                         };
            [self respondsCTDDelegateWithType:CTD_CALL_END_RESULT result:resultInfo];
        }
            break;
        case TSDK_E_CTD_EVT_CALL_STATUS_NOTIFY:
        {
            DDLogInfo(@"TSDK_E_CTD_EVT_CALL_STATUS_NOTIFY callId: %d ,status: %d",notify.param1,notify.param2);
            TSDK_E_CTD_CALL_STATUS state =(TSDK_E_CTD_CALL_STATUS)notify.param2;
            NSDictionary *resultInfo = @{
                                         TSDK_CTD_CALL_STATE_KEY : [NSNumber numberWithInt:state]
                                         };
            [self respondsCTDDelegateWithType:CTD_CALL_STATE result:resultInfo];
        }
            break;
        default:
            break;
    }
}

/**
 *This method is used to deel call notification
 *处理call回调业务
 *@param notify
 */
-(void)onRecvCallNotification:(Notification *)notify
{
    switch (notify.msgId)
    {
        case TSDK_E_CALL_EVT_CALL_START_RESULT:
        {
            DDLogInfo(@"recv call notify :CALL_E_EVT_CALL_STARTCALL_RESULT :%d",notify.param2);
            break;
        }
        case TSDK_E_CALL_EVT_CALL_INCOMING:
        {
            DDLogInfo(@"recv call notify :TSDK_E_CALL_EVT_CALL_INCOMING callid:%d",notify.param1);
            
//            CALL_S_CALL_INFO *callInfo = (CALL_S_CALL_INFO *)notify.data;
//            CallInfo *tupCallInfo = [CallInfo transfromFromCallInfoStract:callInfo];
//            TUP_RESULT ret = tup_call_alerting_call((TUP_UINT32)tupCallInfo.stateInfo.callId);
//            DDLogInfo(@"tup_call_alerting_call,ret is %d",ret);
            
            TSDK_S_CALL_INFO *callInfo = (TSDK_S_CALL_INFO *)notify.data;
            CallInfo *tsdkCallInfo = [CallInfo transfromFromCallInfoStract:callInfo];
            
            [self resetUCVideoOrientAndIndexWithCallId:0];
            
            NSString *callId = [NSString stringWithFormat:@"%d", callInfo->call_id];
            [_tsdkCallInfoDic setObject:tsdkCallInfo forKey:callId];
            NSDictionary *resultInfo = @{
                                         TSDK_CALL_INFO_KEY : tsdkCallInfo
                                         };
            [self respondsCallDelegateWithType:CALL_INCOMMING result:resultInfo]; //post incoming call info to UI
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:TSDK_COMING_CALL_NOTIFY object:tsdkCallInfo];
                
            });
            
            CallLogMessage *callLogMessage = [[CallLogMessage alloc]init];
            callLogMessage.calleePhoneNumber = tsdkCallInfo.stateInfo.callNum;
            callLogMessage.durationTime = 0;
            callLogMessage.startTime = [self nowTimeString];
            callLogMessage.callLogType = MissedCall;
            callLogMessage.callId = tsdkCallInfo.stateInfo.callId;
            callLogMessage.isConnected = NO;
            if (!tsdkCallInfo.isFocus) {  //write call log message to local file
                NSMutableArray *array = [[NSMutableArray alloc]init];
                if ([self loadLocalCallHistoryData].count > 0) {
                    array = [self loadLocalCallHistoryData];
                }
                [array addObject:callLogMessage];
                [self writeToLocalFileWith:array];
            }
            break;
        }
        case TSDK_E_CALL_EVT_CALL_RINGBACK:
        {
            NSDictionary *resultInfo = @{
                                         TSDK_CALL_RINGBACK_KEY : [NSNumber numberWithBool:true]
                                         };
            [self respondsCallDelegateWithType:CALL_RINGBACK result:resultInfo];
            break;
        }
        case TSDK_E_CALL_EVT_CALL_OUTGOING:
        {
            DDLogInfo(@"TSDK_E_CALL_EVT_CALL_OUTGOING");
            TSDK_S_CALL_INFO *callInfo = (TSDK_S_CALL_INFO *)notify.data;
            CallInfo *tsdkCallInfo = [CallInfo transfromFromCallInfoStract:callInfo];
            NSString *callId = [NSString stringWithFormat:@"%d", tsdkCallInfo.stateInfo.callId];
            [_tsdkCallInfoDic setObject:tsdkCallInfo forKey:callId];
            NSDictionary *resultInfo = @{
                                         TSDK_CALL_INFO_KEY : tsdkCallInfo
                                         };
            [self respondsCallDelegateWithType:CALL_OUTGOING result:resultInfo];
            break;
        }
        case TSDK_E_CALL_EVT_CALL_CONNECTED:
        {
            DDLogInfo(@"Call_Log: recv call notify :CALL_E_EVT_CALL_CONNECTED");
            TSDK_S_CALL_INFO *callInfo = (TSDK_S_CALL_INFO *)notify.data;
            CallInfo *tsdkCallInfo = [CallInfo transfromFromCallInfoStract:callInfo];
            NSString *callId = [NSString stringWithFormat:@"%d", tsdkCallInfo.stateInfo.callId];
            [_tsdkCallInfoDic setObject:tsdkCallInfo forKey:callId];
            NSDictionary *resultInfo = @{
                                         TSDK_CALL_INFO_KEY : tsdkCallInfo
                                         };
            [self respondsCallDelegateWithType:CALL_CONNECT result:resultInfo];
            
            if ([self loadLocalCallHistoryData].count > 0) {
                NSArray *array = [self loadLocalCallHistoryData];
                for (CallLogMessage *message in array) {
                    if (message.callId == tsdkCallInfo.stateInfo.callId) {
                        if (message.callLogType == MissedCall) {
                            message.callLogType = ReceivedCall;
                        }
                        message.isConnected = YES;
                        [self writeToLocalFileWith:array];
                        break;
                    }
                }
            }
            break;
        }
        case TSDK_E_CALL_EVT_CALL_ENDED:
        {
            DDLogInfo(@"Call_Log: recv call notify :CALL_E_EVT_CALL_ENDED");
            TSDK_S_CALL_INFO *callInfo = (TSDK_S_CALL_INFO *)notify.data;
            CallInfo *tsdkCallInfo = [CallInfo transfromFromCallInfoStract:callInfo];
            NSDictionary *resultInfo = @{
                                         TSDK_CALL_INFO_KEY : tsdkCallInfo
                                         };
            [self respondsCallDelegateWithType:CALL_CLOSE result:resultInfo];
            
            NSString *callId = [NSString stringWithFormat:@"%d", tsdkCallInfo.stateInfo.callId];
            [_tsdkCallInfoDic removeObjectForKey:callId];
            
            self.isShowTupBfcp = NO;
            
            if ([self loadLocalCallHistoryData].count > 0) {
                NSArray *array = [self loadLocalCallHistoryData];
                for (CallLogMessage *message in array) {
                    if (message.callId == tsdkCallInfo.stateInfo.callId) {
                        if (message.callLogType != MissedCall && message.isConnected) {
                            NSDate *date = [NSDate date];
                            NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
                            [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                            NSTimeZone *timeZone = [NSTimeZone localTimeZone];
                            [formatter setTimeZone:timeZone];
                            NSTimeInterval timeInterval = [date timeIntervalSinceDate:[formatter dateFromString:message.startTime]];
                            message.durationTime = timeInterval;
                            [self writeToLocalFileWith:array];
                        }
                        break;
                    }
                }
                
            }
            
            // TODO: CHENZHIQIAN
            //            if ([ManagerService confService].isJoinDataConf)
            //            {
            //                [[ManagerService confService] restoreConfParamsInitialValue];
            //            }
            break;
        }
        case TSDK_E_CALL_EVT_CALL_DESTROY:
        {
            DDLogInfo(@"Call_Log: recv call notify :TSDK_E_CALL_EVT_CALL_DESTROY");

            [self respondsCallDelegateWithType:CALL_DESTROY result:nil];
        }
            break;
        case TSDK_E_CALL_EVT_REFRESH_VIEW_IND:
        {
            NSString* callId = [NSString stringWithFormat:@"%d", notify.param1];
            TSDK_S_VIDEO_VIEW_REFRESH *viewRefresh = (TSDK_S_VIDEO_VIEW_REFRESH *)notify.data;
            
            if(viewRefresh->view_type == TSDK_E_VIEW_VIDEO_VIEW && viewRefresh->event == TSDK_E_VIDEO_LOCAL_VIEW_ADD)
            {
                [self respondsCallDelegateWithType:CALL_VIEW_REFRESH result:nil];
            }
            break;
        }
        case TSDK_E_CALL_EVT_OPEN_VIDEO_REQ:
        {
            NSString *callId = [NSString stringWithFormat:@"%d",notify.param1];
            NSDictionary *callUpgradePassiveInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                                    callId,CALL_ID,
                                                    nil];
            [self respondsCallDelegateWithType:CALL_UPGRADE_VIDEO_PASSIVE result:callUpgradePassiveInfo];
            DDLogInfo(@"Call_Log: call revice CALL_E_EVT_CALL_ADD_VIDEO");
            break;
        }
        case TSDK_E_CALL_EVT_CLOSE_VIDEO_IND:
        {
            NSString *callId = [NSString stringWithFormat:@"%d",notify.param1];
            NSDictionary *callDowngradePassiveInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                                      callId,CALL_ID,
                                                      nil];
            [self respondsCallDelegateWithType:CALL_DOWNGRADE_VIDEO_PASSIVE result:callDowngradePassiveInfo];
            DDLogInfo(@"Call_Log: call CALL_E_EVT_CALL_DEL_VIDEO");
            break;
        }
        case TSDK_E_CALL_EVT_OPEN_VIDEO_IND:
        {
            NSString *callId = [NSString stringWithFormat:@"%d",notify.param1];
            NSDictionary *callUpgradePassiveInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                                      callId,CALL_ID,
                                                      nil];
            [self respondsCallDelegateWithType:CALL_REFUSE_OPEN_VIDEO result:callUpgradePassiveInfo];
            DDLogInfo(@"Call_Log: call CALL_E_EVT_CALL_DEL_VIDEO");
            break;
        }
//        case CALL_E_EVT_REFER_NOTIFY:
//        {
//            [self respondsCallDelegateWithType:CALL_REFER_NOTIFY result:nil];
//            break;
//        }
        case TSDK_E_CALL_EVT_CALL_ROUTE_CHANGE:
        {
            DDLogInfo(@"CALL_E_EVT_MOBILE_ROUTE_CHANGE");
            ROUTE_TYPE currentRoute = (ROUTE_TYPE)notify.param2;
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:NTF_AUDIOROUTE_CHANGED object:nil userInfo:@{AUDIO_ROUTE_KEY : @(currentRoute)}];
            });
            break;
        }
//        case CALL_E_EVT_SERVERCONF_DATACONF_PARAM:
//        {
//            CALL_S_DATACONF_PARAM *dataConfParam = (CALL_S_DATACONF_PARAM *)notify.data;
//            NSString *callIdKey = [NSString stringWithFormat:@"%d", dataConfParam->ulCallID];
//            CallInfo *callInfo = [_tsdkCallInfoDic objectForKey:callIdKey];
//            callInfo.serverConfId = [NSString stringWithUTF8String:dataConfParam->acDataConfID];
//            break;
//        }
//        case CALL_E_EVT_DATA_FRAMESIZE_CHANGE:
//        {
//            DDLogInfo(@"CALL_E_EVT_DATA_FRAMESIZE_CHANGE");
//            self.isShowTupBfcp = YES;
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"TupBfcpDealMessage" object:nil];
//            break;
//        }
//        case CALL_E_EVT_DATA_STOPPED:
//        {
//            DDLogInfo(@"CALL_E_EVT_DATA_STOPPED");
//            self.isShowTupBfcp = NO;
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"TupBfcpDealMessage" object:nil];
//            break;
//        }
//        case CALL_E_EVT_DATA_START_ERR:
//        {
//            DDLogInfo(@"CALL_E_EVT_DATA_START_ERR");
//            break;
//        }
        case TSDK_E_CALL_EVT_IPT_SERVICE_INFO:
        {
//            TSDK_UINT32 account_id = notify.param1;
            TSDK_S_IPT_SERVICE_INFO_SET *serviceInfoSet = (TSDK_S_IPT_SERVICE_INFO_SET *)notify.data;
            IPTConfig *iptConfig = [IPTConfig sharedInstance];
            
            iptConfig.hasDNDRight = serviceInfoSet->dnd.has_right;
            iptConfig.isDNDRegister = serviceInfoSet->dnd.is_enable;
            
            iptConfig.hasCWRight = serviceInfoSet->call_wait.has_right;
            iptConfig.isCWRegister = serviceInfoSet->call_wait.is_enable;
            
            iptConfig.hasCFURight = serviceInfoSet->cfu.has_right;
            iptConfig.isCFURegister = serviceInfoSet->cfu.is_enable;
            iptConfig.cfuNumber = [NSString stringWithUTF8String:serviceInfoSet->cfu.number];
   
            iptConfig.hasCFBRight = serviceInfoSet->cfb.has_right;
            iptConfig.isCFBRegister = serviceInfoSet->cfb.is_enable;
            iptConfig.cfbNumber = [NSString stringWithUTF8String:serviceInfoSet->cfb.number];

            iptConfig.hasCFNARight = serviceInfoSet->cfn.has_right;
            iptConfig.isCFNARegister = serviceInfoSet->cfn.is_enable;
            iptConfig.cfnaNumber = [NSString stringWithUTF8String:serviceInfoSet->cfn.number];
            
            iptConfig.hasCFNRRight = serviceInfoSet->cfo.has_right;
            iptConfig.isCFNRRegister = serviceInfoSet->cfo.is_enable;
            iptConfig.cfnrNumber = [NSString stringWithUTF8String:serviceInfoSet->cfo.number];
            
            NSString *accountId = [CommonUtils getUserDefaultValueWithKey:USER_ACCOUNT];
            NSData *archiveCarPriceData = [NSKeyedArchiver archivedDataWithRootObject:iptConfig]; //将iptConfig实例序列化，以便保存
            DDLogInfo(@"........%@", accountId);
            if (accountId.length == 0 || accountId == nil) {
                return;
            }
            NSDictionary *dicInfo = @{
                                      @"ACCOUNT" : accountId,
                                      @"IPT" : archiveCarPriceData
                                      };
            NSMutableArray *mutArray;
            NSArray *orginalArray;
            if ([[CommonUtils getUserDefaultValueWithKey:@"iptConfig"] isKindOfClass:[NSArray class]])
            {
                orginalArray= [CommonUtils getUserDefaultValueWithKey:@"iptConfig"];
                mutArray = [NSMutableArray arrayWithArray:orginalArray];
            }
            else
            {
                mutArray = [[NSMutableArray alloc] init];
            }
            if (orginalArray.count > 0)
            {
                for (NSDictionary *tempDic in orginalArray)
                {
                    NSString *account = tempDic[@"ACCOUNT"];
                    DDLogInfo(@",,,,,,,,,%@",account);
                    if ([account isEqualToString:accountId]) //如果该账号已存在保存的配置，先删除
                    {
                        [mutArray removeObject:tempDic];
                    }
                }
                [mutArray addObject:dicInfo];
            }
            else
            {
                [mutArray addObject:dicInfo];
            }
            [CommonUtils userDefaultSaveValue:[NSArray arrayWithArray:mutArray] forKey:@"iptConfig"];
            break;
        }
        
        case TSDK_E_CALL_EVT_STATISTIC_INFO:
        {
            VideoStreamInfo *dataStreamInfo = [[VideoStreamInfo alloc] init];
            if ([ManagerService confService].isStartScreenSharing) {
                dataStreamInfo = [[ManagerService confService] getSignalDataInfo];
            }
            
            TSDK_UINT32 call_id = notify.param1;
            TSDK_UINT32 signal_strength = notify.param2;
            TSDK_S_CALL_STATISTIC_INFO* statistic_info = (TSDK_S_CALL_STATISTIC_INFO*)notify.data;
            
            TSDK_S_AUDIO_STREAM_INFO audio_stream_info = statistic_info->audio_stream_info;
            TSDK_S_VIDEO_STREAM_INFO video_stream_info = statistic_info->video_stream_info;
            
            TSDK_S_VIDEO_STREAM_INFO *svc_stream_info = statistic_info->svc_stream_info;
            
            
            CallStatisticInfo *callInfo = [[CallStatisticInfo alloc] init];
            callInfo.callId = call_id;
            callInfo.signalStrength = signal_strength;
            callInfo.effectiveBitrate = statistic_info->effective_bitrate;
            callInfo.isSvcConf = statistic_info->is_svc_conf;
            
            AudioStreamInfo *audioStreamInfo = [[AudioStreamInfo alloc] init];
            audioStreamInfo.isSrtp = audio_stream_info.is_srtp;
            audioStreamInfo.encodeProtocol = [NSString stringWithUTF8String:audio_stream_info.encode_protocol];
            audioStreamInfo.sendBitRate = audio_stream_info.send_bit_rate;
            audioStreamInfo.sendLossFraction = audio_stream_info.send_loss_fraction;
            audioStreamInfo.sendDelay = audio_stream_info.send_delay;
            audioStreamInfo.sendJitter = audio_stream_info.send_jitter;
            audioStreamInfo.decodeProtocol = [NSString stringWithUTF8String:audio_stream_info.decode_protocol];
            audioStreamInfo.recvBitRate = audio_stream_info.recv_bit_rate;
            audioStreamInfo.recvLossFraction = audio_stream_info.recv_loss_fraction;
            audioStreamInfo.recvDelay = audio_stream_info.recv_delay;
            audioStreamInfo.recvJitter = audio_stream_info.recv_jitter;
            audioStreamInfo.recvAverageMos = audio_stream_info.recv_average_mos;
            callInfo.audioStreamInfo = audioStreamInfo;
            
            VideoStreamInfo *videoStreamInfo = [[VideoStreamInfo alloc] init];
            videoStreamInfo.isSrtp = video_stream_info.is_srtp;
            videoStreamInfo.bandWidth = video_stream_info.bandwidth;
            videoStreamInfo.encodeProtocol = [NSString stringWithUTF8String:video_stream_info.encode_protocol];
            videoStreamInfo.sendBitRate = video_stream_info.send_bit_rate;
            videoStreamInfo.sendFrameSize = [NSString stringWithUTF8String:video_stream_info.send_frame_size];
            videoStreamInfo.sendFrameRate = video_stream_info.send_frame_rate;
            videoStreamInfo.sendLossFraction = video_stream_info.send_loss_fraction;
            videoStreamInfo.sendDelay = video_stream_info.send_delay;
            videoStreamInfo.sendJitter = video_stream_info.send_jitter;
            videoStreamInfo.decodeProtocol = [NSString stringWithUTF8String:video_stream_info.decode_protocol];
            videoStreamInfo.recvBitRate = video_stream_info.recv_bit_rate;
            videoStreamInfo.recvFrameSize = [NSString stringWithUTF8String:video_stream_info.recv_frame_size];
            videoStreamInfo.recvLossFraction = video_stream_info.recv_loss_fraction;
            videoStreamInfo.recvFrameRate = video_stream_info.recv_frame_rate;
            videoStreamInfo.recvDelay = video_stream_info.recv_delay;
            videoStreamInfo.recvJitter = video_stream_info.recv_jitter;
            videoStreamInfo.recvSsrcLabel = video_stream_info.recv_ssrc_label;
            callInfo.videoStreamInfo = videoStreamInfo;
            
            callInfo.svcStreamCount = statistic_info->svc_stream_count;
            NSMutableArray *svcStreamInfoArray = [[NSMutableArray alloc] init];
            for (int i = 0; i < callInfo.svcStreamCount; i++) {
                TSDK_S_VIDEO_STREAM_INFO svcStreamInfo = svc_stream_info[i];
                VideoStreamInfo *videoStreamInfoM = [[VideoStreamInfo alloc] init];
                
                videoStreamInfoM.isSrtp = svcStreamInfo.is_srtp;
                videoStreamInfoM.bandWidth = svcStreamInfo.bandwidth;
                videoStreamInfoM.encodeProtocol = [NSString stringWithUTF8String:svcStreamInfo.encode_protocol];
                videoStreamInfoM.sendBitRate = svcStreamInfo.send_bit_rate;
                videoStreamInfoM.sendFrameSize = [NSString stringWithUTF8String:svcStreamInfo.send_frame_size];
                videoStreamInfoM.sendFrameRate = svcStreamInfo.send_frame_rate;
                videoStreamInfoM.sendLossFraction = svcStreamInfo.send_loss_fraction;
                videoStreamInfoM.sendDelay = svcStreamInfo.send_delay;
                videoStreamInfoM.sendJitter = svcStreamInfo.send_jitter;
                videoStreamInfoM.decodeProtocol = [NSString stringWithUTF8String:svcStreamInfo.decode_protocol];
                videoStreamInfoM.recvBitRate = svcStreamInfo.recv_bit_rate;
                videoStreamInfoM.recvFrameSize = [NSString stringWithUTF8String:svcStreamInfo.recv_frame_size];
                videoStreamInfoM.recvLossFraction = svcStreamInfo.recv_loss_fraction;
                videoStreamInfoM.recvFrameRate = svcStreamInfo.recv_frame_rate;
                videoStreamInfoM.recvDelay = svcStreamInfo.recv_delay;
                videoStreamInfoM.recvJitter = svcStreamInfo.recv_jitter;
                videoStreamInfoM.recvSsrcLabel = svcStreamInfo.recv_ssrc_label;
                
                [svcStreamInfoArray addObject:videoStreamInfoM];
            }
            callInfo.svcStreamInfoArray = [NSArray arrayWithArray:svcStreamInfoArray];
            
            callInfo.dataStreamInfo = dataStreamInfo;
            
            NSDictionary *callInDic = [NSDictionary dictionaryWithObjectsAndKeys:
                                                    callInfo,CALL_STATISTIC_INFO,
                                                    nil];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:CALL_STATISTIC_INFO_NOTIFY object:nil userInfo:callInDic];
            });

//            [self respondsCallDelegateWithType:CALL_EVT_STATISTIC_INFO result:callInDic];
            
        }
            break;
            
        default:
            break;
    }
    if (notify.msgId>=TSDK_E_CALL_EVT_HOLD_SUCCESS && notify.msgId<=TSDK_E_CALL_EVT_UNHOLD_FAILED)
    {
        [self handleCallHoldNotify:notify];
    }
    if (notify.msgId>=TSDK_E_CALL_EVT_DIVERT_FAILED && notify.msgId<=TSDK_E_CALL_EVT_SET_IPT_SERVICE_RESULT)
    {
        [self handleTransferNotify:notify];
    }
}

/**
 *This method is used to deel call transfer notification
 *处理转移业务回调
 *@param notify
 */
-(void)handleTransferNotify:(Notification *)notify
{
    DDLogInfo(@"handleTransferNotify id:%d",notify.msgId);
    switch (notify.msgId)
    {
        case TSDK_E_CALL_EVT_DIVERT_FAILED:
        {
            DDLogInfo(@"CALL_E_EVT_CALL_DIVERT_FAILED");
            [self respondsCallDelegateWithType:CALL_DIVERT_FAILED result:nil];
            break;
        }
        case TSDK_E_CALL_EVT_BLD_TRANSFER_SUCCESS:
        {
            DDLogInfo(@"CALL_E_EVT_CALL_BLD_TRANSFER_SUCCESS");
            NSDictionary *resultInfo = @{
                                         TSDK_CALL_TRANSFER_RESULT_KEY:[NSNumber numberWithBool:YES]
                                         };
            [self respondsCallDelegateWithType:CALL_TRANSFER_RESULT result:resultInfo];
            break;
        }
        case TSDK_E_CALL_EVT_BLD_TRANSFER_FAILED:
        {
            DDLogInfo(@"CALL_E_EVT_CALL_BLD_TRANSFER_FAILED");
            NSDictionary *resultInfo = @{
                                         TSDK_CALL_TRANSFER_RESULT_KEY:[NSNumber numberWithBool:NO]
                                         };
            [self respondsCallDelegateWithType:CALL_TRANSFER_RESULT result:resultInfo];
            break;
        }
            
        case TSDK_E_CALL_EVT_SET_IPT_SERVICE_RESULT:
        {
            TSDK_E_IPT_SERVICE_TYPE serviceCallType = (TSDK_E_IPT_SERVICE_TYPE)notify.param1;
            TSDK_S_SET_IPT_SERVICE_RESULT *setServiceResult = (TSDK_S_SET_IPT_SERVICE_RESULT *)notify.data;
            
            IPTConfigType type = [self getIPTConfigType:(CALL_SERVICE_TYPE)serviceCallType withIsEnable:setServiceResult->is_enable];
            if([self.iptDelegate respondsToSelector:@selector(iptConfigCallBack:result:)]){
                [self.iptDelegate iptConfigCallBack:type result:(setServiceResult->reason_code == 0)?YES:NO];
            }
            break;
        }
            
        default:
            break;
    }
}

/**
 *This method is used to get ipt config type
 *将sdk提供的ipt业务枚举转换为自定义枚举值
 *@param serviceCallType
 */
- (IPTConfigType)getIPTConfigType:(CALL_SERVICE_TYPE) serviceCallType withIsEnable:(BOOL) isEnable
{
    
    IPTConfigType type = IPT_REG_UN;
    
    switch (serviceCallType) {
        case CALL_SERVICE_TYPE_DND:
        {
            if(isEnable){
                type = IPT_REG_DND;
            }else{
                type = IPT_UNREG_DND;
            }
            break;
        }
        case CALL_SERVICE_TYPE_CALL_WAIT:
        {
            if(isEnable){
                type = IPT_CALL_WAIT_ACTIVE;
            }else{
                type = IPT_CALL_WAIT_DEACTIVE;
            }
            break;
        }
        case CALL_SERVICE_TYPE_CFU:
        {
            if(isEnable){
                type = IPT_FORWARD_UNCONDITION_Active;
            }else{
                type = IPT_FORWARD_UNCONDITION_Deactive;
            }
            break;
        }
        case CALL_SERVICE_TYPE_CFB:
        {
            if(isEnable){
                type = IPT_FORWARD_ONBUSY_Active;
            }else{
                type = IPT_FORWARD_ONBUSY_Deactive;
            }
            break;
        }
        case CALL_SERVICE_TYPE_CFN:
        {
            if(isEnable){
                type = IPT_FORWARD_NOREPLY_Active;
            }else{
                type = IPT_FORWARD_NOREPLY_Deactive;
            }
            break;
        }
        case CALL_SERVICE_TYPE_CFO:
        {
            if(isEnable){
                type = IPT_FORWARD_OFFLINE_Active;
            }else{
                type = IPT_FORWARD_OFFLINE_Deactive;
            }
            break;
        }
        default:
            break;
    }
    
    return type;
}

/**
 *This method is used to deel call hold notification
 *处理呼叫保持回调业务
 *@param notify
 */
-(void)handleCallHoldNotify:(Notification *)notify
{
    DDLogInfo(@"handleCallHoldNotify id:%d",notify.msgId);
    NSString *callId = [NSString stringWithFormat:@"%d",notify.param1];
    switch (notify.msgId)
    {
        case TSDK_E_CALL_EVT_HOLD_SUCCESS:
        {
            DDLogInfo(@"TSDK_E_CALL_EVT_HOLD_SUCCESS");
            NSDictionary *resultInfo = @{
                                         TSDK_CALL_HOLD_RESULT_KEY:[NSNumber numberWithBool:YES],
                                         CALL_ID : callId
                                         };
            [self respondsCallDelegateWithType:CALL_HOLD_RESULT result:resultInfo];
            break;
        }
        case TSDK_E_CALL_EVT_HOLD_FAILED:
        {
            DDLogInfo(@"TSDK_E_CALL_EVT_HOLD_FAILED");
            NSDictionary *resultInfo = @{
                                         TSDK_CALL_HOLD_RESULT_KEY:[NSNumber numberWithBool:NO],
                                         CALL_ID : callId
                                         };
            [self respondsCallDelegateWithType:CALL_HOLD_RESULT result:resultInfo];
            break;
        }
        case TSDK_E_CALL_EVT_UNHOLD_SUCCESS:
        {
            DDLogInfo(@"TSDK_E_CALL_EVT_UNHOLD_SUCCESS");
            NSDictionary *resultInfo = @{
                                         TSDK_CALL_UNHOLD_RESULT_KEY:[NSNumber numberWithBool:YES],
                                         CALL_ID : callId
                                         };
            [self respondsCallDelegateWithType:CALL_UNHOLD_RESULT result:resultInfo];
            break;
        }
        case TSDK_E_CALL_EVT_UNHOLD_FAILED:
        {
            DDLogInfo(@"TSDK_E_CALL_EVT_UNHOLD_FAILED");
            NSDictionary *resultInfo = @{
                                         TSDK_CALL_UNHOLD_RESULT_KEY:[NSNumber numberWithBool:NO],
                                         CALL_ID : callId
                                         };
            [self respondsCallDelegateWithType:CALL_UNHOLD_RESULT result:resultInfo];
            break;
        }
        default:
            break;
    }
}

/**
 *This method is used to get incoming call number
 *获取来电号码
 *@param callInfo
 */
- (NSDictionary*)parseCallNumberForInfo:(CallInfo*)callInfo
{
    NSMutableDictionary* parseDic = [NSMutableDictionary dictionary];
    NSString *comingSipNum = callInfo.stateInfo.callNum;
    NSRange numSearchRange = [comingSipNum rangeOfString:@"@"];
    if (numSearchRange.length > 0)
    {
        comingSipNum = [comingSipNum substringToIndex:numSearchRange.location];
    }
    
    NSString *comingNum = callInfo.telNumTel;
    if (0 == [comingNum length])
    {
        comingNum = comingSipNum;
    }
    NSRange searchRange = [comingNum rangeOfString:@"@"];
    if (searchRange.length > 0)
    {
        comingNum = [comingNum substringToIndex:searchRange.location];
    }
    
    NSRange rangeSearched = [comingNum rangeOfString:@";cpc=ordinary" options:NSCaseInsensitiveSearch];
    if (rangeSearched.length > 0)
    {
        comingNum = [comingNum substringToIndex:rangeSearched.location];
    }
    
    [parseDic setObject:comingNum forKey:CALLINFO_CALLNUMBER_KEY];
    [parseDic setObject:comingSipNum forKey:CALLINFO_SIPNUMBER_KEY];
    
    return parseDic;
}

#pragma mark - Config


/**
 *This method is used to reset video orient and index
 *重设摄像头的方向和序号
 */
- (void)resetUCVideoOrientAndIndexWithCallId:(unsigned int)callid
{
    TSDK_S_VIDEO_ORIENT orient;
    orient.choice = 1;
    orient.portrait = 0;
    orient.landscape = 0;
    orient.seascape = 1;
    tsdk_set_video_orient(callid, CameraIndexFront, &orient);
}

/**
 * This method is used to update video window local view
 * 更新视频本地窗口画面
 *@param localVideoView     Indicates local video view
 *                          本地视频视图
 *@param remoteVideoView    Indicates remote video view
 *                          远端视频试图
 *@param bfcpVideoView      Indicates bfcp video view
 *                          bfcp视频试图
 *@param callId             Indicates call id
 *                          呼叫id
 *@return YES or NO
 */
- (BOOL)updateVideoWindowWithLocal:(id)localVideoView
                         andRemote:(id)remoteVideoView
                           andBFCP:(id)bfcpVideoView
                            callId:(unsigned int)callId
{

    TSDK_S_VIDEO_WND_INFO videoInfo[3];
    memset_s(videoInfo, sizeof(TSDK_S_VIDEO_WND_INFO) * 2, 0, sizeof(TSDK_S_VIDEO_WND_INFO) * 2);
    videoInfo[0].video_wnd_type = TSDK_E_VIDEO_WND_LOCAL;
    videoInfo[0].render = (TSDK_UPTR)localVideoView;
    videoInfo[0].display_mode = TSDK_E_VIDEO_WND_DISPLAY_CUT;
    videoInfo[1].video_wnd_type = TSDK_E_VIDEO_WND_REMOTE;
    videoInfo[1].render = (TSDK_UPTR)remoteVideoView;
    videoInfo[1].display_mode = TSDK_E_VIDEO_WND_DISPLAY_CUT;
    videoInfo[2].video_wnd_type = TSDK_E_VIDEO_WND_AUX_DATA;
    videoInfo[2].render = (TSDK_UPTR)bfcpVideoView;
    TSDK_RESULT ret;
    videoInfo[2].display_mode = TSDK_E_VIDEO_WND_DISPLAY_CUT;

    ret = tsdk_set_video_window((TSDK_UINT32)callId, 3, videoInfo);
    DDLogInfo(@"Call_Log: tsdk_set_video_window = %d",ret);
    
    return (TSDK_SUCCESS == ret);
}

/**
 * This method is used to open video preview, default open front camera
 * 打开视频预览,默认打开前置摄像头
 *@param cameraIndex         Indicates camera index
 *                           视频摄像头序号
 *@param viewHandler         Indicates view handle
 *                           视图句柄
 *@return YES or NO
 */
- (BOOL)videoPreview:(unsigned int)cameraIndex toView:(id) viewHandler
{
    _videoPreview = viewHandler;
    TSDK_RESULT ret = tsdk_open_video_preview((TSDK_UPTR)viewHandler, (TSDK_UINT32)cameraIndex);
    DDLogInfo(@"Camera_Log:tsdk_open_video_preview result is %d", ret);
    return ret == TSDK_SUCCESS ? YES : NO;
}


/**
 * This method is used to close video preview
 *关闭视频预览
 */
-(void)stopVideoPreview
{
    tsdk_close_video_preview();
}

/**
 *This method is used to start EC access number to join conference
 *EC接入码入会
 *@param confid                  Indicates confid
 *                               会议Id
 *@param acceseNum               Indicates accese number
 *                               会议接入码
 *@param psw                     Indicates password
 *                               会议密码
 *@return unsigned int           Return call id, equal zero mean start call fail.
 *                               返回呼叫id,失败返回0
 */
//- (unsigned int) startECAccessCallWithConfid:(NSString *)confid AccessNum:(NSString *)acceseNum andPsw:(NSString *)psw
//{
//    TSDK_UINT32 callid = 0;
//    CALL_S_CONF_PARAM *confParam = (CALL_S_CONF_PARAM *)malloc(sizeof(CALL_S_CONF_PARAM));
//    memset_s(confParam, sizeof(CALL_S_CONF_PARAM), 0, sizeof(CALL_S_CONF_PARAM));
//    if (confid.length > 0 && confid != nil) {
//        strcpy(confParam->confid, [confid UTF8String]);
//    }
//    if (psw.length > 0 && psw != nil) {
//        strcpy(confParam->conf_paswd, [psw UTF8String]);
//    }
//    if (acceseNum.length > 0 && acceseNum != nil) {
//        strcpy(confParam->access_code, [acceseNum UTF8String]);
//    }
//    //callType  默认使用CALL_E_CALL_TYPE_IPVIDEO
//    TUP_RESULT ret_ex = tup_call_serverconf_access_reservedconf_ex(&callid, CALL_E_CALL_TYPE_IPVIDEO, confParam);
//    return callid;
//
//}

/**
 *This method is used to start point to point audio call or video call
 *发起音视频呼叫
 *@param number                  Indicates number
 *                               呼叫的号码
 *@param callType audio/video    Indicates call type
 *                               呼叫类型
 *@return unsigned int           Return call id, equal zero mean start call fail.
 *                               返回呼叫id,失败返回0
 */
-(unsigned int)startCallWithNumber:(NSString *)number type:(TUP_CALL_TYPE)callType
{
    if (nil == number || number.length == 0) {
        return 0;
    }
    [self resetUCVideoOrientAndIndexWithCallId:0];
    TSDK_BOOL isVideo = ((TSDK_CALL_E_CALL_TYPE)callType==CALL_VIDEO)?TSDK_TRUE:TSDK_FALSE;
    TSDK_UINT32 callid = 0;
    TSDK_RESULT ret = tsdk_start_call(&callid,(TSDK_CHAR*)[number UTF8String], isVideo);
    
    
    DDLogInfo(@"Call_Log: tsdk_start_call = %d", ret);
    
    if (ret == 0) {
        CallLogMessage *callLogMessage = [[CallLogMessage alloc]init];
        callLogMessage.calleePhoneNumber = number;
        callLogMessage.durationTime = 0;
        callLogMessage.startTime = [self nowTimeString];
        callLogMessage.callLogType = OutgointCall;
        callLogMessage.callId = callid;
        callLogMessage.isConnected = NO;
        NSMutableArray *array = [[NSMutableArray alloc]init];
        if ([self loadLocalCallHistoryData].count > 0) {
            array = [self loadLocalCallHistoryData];
        }
        [array addObject:callLogMessage];
        [self writeToLocalFileWith:array];
    }
    
    return callid;
}

/**
 *This method is used to answer the incoming call, select audio or video call
 *接听呼叫
 *@param callType                Indicates call type
 *                               呼叫类型
 *@param callId                  Indicate call id
 *                               呼叫id
 *@return YES or NO
 */
- (BOOL) answerComingCallType:(TUP_CALL_TYPE)callType callId:(unsigned int)callId
{
    TSDK_RESULT ret = tsdk_accept_call((TSDK_UINT32)callId, callType == CALL_AUDIO ? TSDK_FALSE : TSDK_TRUE);
    DDLogInfo(@"Call_Log:answer call type is %d,result is %d, callid: %d",callType,ret,callId);
    return ret == TSDK_SUCCESS ? YES : NO;
}

/**
 *This method is used to end call
 *结束通话
 *@param callId                  Indicates call id
 *                               呼叫id
 *@return YES or NO
 */
-(BOOL)closeCall:(unsigned int)callId
{
    TSDK_UINT32 callid = (TSDK_UINT32)callId;
    TSDK_RESULT ret = tsdk_end_call(callid);
    DDLogInfo(@"Call_Log: tsdk_end_call = %d, callid:%d",ret,callId);
    return ret == TSDK_SUCCESS ? YES : NO;
}

/**
 *This method is used to reply request of adding video call
 *回复是否接受音频转视频
 *@param accept                  Indicates whether accept
 *                               是否接受
 *@param callId                  Indicates call id
 *                               呼叫Id
 @return YES is success,NO is fail
 */
-(BOOL)replyAddVideoCallIsAccept:(BOOL)accept callId:(unsigned int)callId
{
    TSDK_BOOL isAccept = accept;
    TSDK_RESULT ret = tsdk_reply_add_video((TSDK_UINT32)callId , isAccept);
    return ret == TSDK_SUCCESS ? YES : NO;
}

/**
 *This method is used to upgrade audio to video call
 *将音频呼叫升级为视频呼叫
 *@param callId                  Indicates call id
 *                               呼叫id
 *@return YES is success,NO is fail
 */
-(BOOL)upgradeAudioToVideoCallWithCallId:(unsigned int)callId
{
    TSDK_RESULT ret = tsdk_add_video((TSDK_UINT32)callId);
    DDLogInfo(@"Call_Log: tsdk_add_video = %d",ret);
    return ret == TSDK_SUCCESS ? YES : NO;
}

/**
 *This method is used to transfer video call to audio call
 *将视频呼叫转为音频呼叫
 *@param callId                  Indicates call id
 *                               呼叫id
 *@return YES is success,NO is fail
 */
-(BOOL)downgradeVideoToAudioCallWithCallId:(unsigned int)callId
{
    TSDK_RESULT ret = tsdk_del_video((TSDK_UINT32)callId);
    DDLogInfo(@"Call_Log: tsdk_del_video = %d",ret);
    return ret == TSDK_SUCCESS ? YES : NO;
}

/**
 * This method is used to rotation camera capture
 * 转换摄像头采集
 *@param ratation                Indicates camera rotation {0,1,2,3}
 *                               旋转摄像头采集
 *@param callId                  Indicates call id
 *                               呼叫id
 *@return YES is success,NO is fail
 */
-(BOOL)rotationCameraCapture:(NSUInteger)ratation callId:(unsigned int)callId
{
    TSDK_RESULT ret = tsdk_set_capture_rotation((TSDK_UINT32)callId , (TSDK_UINT32)_cameraCaptureIndex, (TSDK_UINT32)ratation);
    DDLogInfo(@"Call_Log: tsdk_set_capture_rotation = %d",ret);
    return ret == TSDK_SUCCESS ? YES : NO;
}

/**
 * This method is used to rotation Video display
 * 旋转摄像头显示
 *@param orientation             Indicates camera orientation
 *                               旋转摄像头采集
 *@param callId                  Indicates call id
 *                               呼叫id
 *@return YES is success, NO is fail
 */
-(BOOL)rotationVideoDisplay:(NSUInteger)orientation callId:(unsigned int)callId isLocalWnd:(BOOL)isLocalWnd
{
    TSDK_E_VIDEO_WND_TYPE wndType = TSDK_E_VIDEO_WND_LOCAL;
    if (!isLocalWnd) {
        wndType = TSDK_E_VIDEO_WND_REMOTE;
    }
    TSDK_RESULT ret_rotation = tsdk_set_display_rotation((TSDK_UINT32)callId, wndType, (TSDK_UINT32)orientation);
    DDLogInfo(@"tsdk_set_display_rotation : %d", ret_rotation);
    return (TSDK_SUCCESS == ret_rotation);
    return NO;
}

/**
 *This interface is used to set set camera picture
 *设置视频采集文件
 */
-(BOOL)setVideoCaptureFileWithcallId:(unsigned int)callId
{
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"tup_call_closeCramea_img"
                                                          ofType:@"bmp"];
    TSDK_RESULT ret = tsdk_set_camera_picture((TSDK_UINT32)callId, (TSDK_CHAR *)[imagePath UTF8String]);
    DDLogInfo(@"Call_Log: tsdk_set_camera_picture = %@",(TSDK_SUCCESS == ret)?@"YES":@"NO");
    return ret == TSDK_SUCCESS ? YES : NO;
}

/**
 * This method is used to switch camera index
 * 切换摄像头
 *@param cameraCaptureIndex      Indicates camera capture index, Fort -1 Back -0
 *                               摄像头序号
 *@param callId                  Indicates call id
 *                               呼叫id
 *@return YES is success,NO is fail
 */
-(BOOL)switchCameraIndex:(NSUInteger)cameraCaptureIndex callId:(unsigned int)callId
{
    TSDK_S_VIDEO_ORIENT orient;
    memset(&orient, 0, sizeof(TSDK_S_VIDEO_ORIENT));
    orient.choice = 1;
    orient.portrait = 0;
    orient.landscape = 0;
    orient.seascape = 1;
    TSDK_RESULT result = tsdk_set_video_orient(callId, (TSDK_UINT32)cameraCaptureIndex, &orient);
    if (result == TSDK_SUCCESS)
    {
        _cameraCaptureIndex = cameraCaptureIndex == 1 ? CameraIndexFront : CameraIndexBack;
    }
    return result == TSDK_SUCCESS ? YES : NO;
}

/**
 *This method is used to update video  render info with video index
 *根据摄像头序号更新视频渲染
 */
- (void)updateVideoRenderInfoWithVideoIndex:(CameraIndex)index withRenderType:(TsdkVideoWindowType)renderType andCallId:(unsigned int)callid isLandscape:(BOOL)isLandscape
{
    if ([UIApplication sharedApplication].applicationState != UIApplicationStateActive) {
        return;
    }
    
    TSDK_UINT32 mirrorType = 0;
    TSDK_UINT32 displaytype = 1;
    TSDK_S_VIDEO_RENDER_INFO renderInfo;
    
    //本端视频，displaytype为1，镜像模式根据前后摄像头进行设置
    if (TsdkVideoWindowlacal == renderType)
    {
        //前置镜像模式为2（左右镜像），后置镜像模式为0（不做镜像）
        switch (index) {
            case CameraIndexBack:
            {
                mirrorType = 0;
                break;
            }
            case CameraIndexFront:
            {
                mirrorType = 2;
                break;
            }
            default:
                break;
        }
        
        displaytype = 2;
//        if ([ManagerService confService].currentJoinConfIndInfo.isSvcConf) {
//            displaytype = 1;
//        }
    }
    //远端视频，镜像模式为0(不做镜像)，显示模式为0（拉伸模式）
    else if (TsdkVideoWindowRemote == renderType)
    {
        mirrorType = 0;
        displaytype = 2;
        if ([ManagerService confService].currentJoinConfIndInfo.isSvcConf) {
            displaytype = TSDK_E_VIDEO_WND_DISPLAY_AUTO_ADAPT;
        }
        
        renderInfo.is_landscape = isLandscape;
    }
    else
    {
        DDLogInfo(@"rendertype is not remote or local");
    }
    
    renderInfo.render_type = (TSDK_E_VIDEO_WND_TYPE)renderType;
    renderInfo.display_type = (TSDK_E_VIDEO_WND_DISPLAY_MODE)displaytype;
    renderInfo.mirror_type = (TSDK_E_VIDEO_WND_MIRROR_TYPE)mirrorType;
    
    TSDK_RESULT ret_video_render_info = tsdk_set_video_render(callid, &renderInfo);
    DDLogInfo(@"tsdk_set_video_render : %d", ret_video_render_info);
}

/**
 * This method is used to get device list
 * 获取设备列表
 *@param deviceType                 Indicates device type,see CALL_E_DEVICE_TYPE
 *                                  设备类型，参考CALL_E_DEVICE_TYPE
 *@return YES is success,NO is fail
 */
//-(BOOL)obtainDeviceListWityType:(DEVICE_TYPE)deviceType
//{
//    DDLogInfo(@"current device type: %ld",deviceType);
//    TSDK_UINT32 deviceNum = 0;
//    TSDK_S_DEVICE_INFO *deviceInfo = nullptr;
//    memset(deviceInfo, 0, sizeof(TSDK_S_DEVICE_INFO));
//    TSDK_RESULT ret = tsdk_get_devices((TSDK_E_DEVICE_TYPE)deviceType, &deviceNum, deviceInfo);
//    DDLogInfo(@"Call_Log: tsdk_get_devices = %#x,count:%d",ret,deviceNum);
//    if (deviceNum>0)
//    {
//        DDLogInfo(@"again");
//        deviceInfo = new TSDK_S_DEVICE_INFO[deviceNum];
//        TSDK_RESULT rets = tsdk_get_devices((TSDK_E_DEVICE_TYPE)deviceType, &deviceNum, deviceInfo);
//        DDLogInfo(@"Call_Log: tsdk_get_devices = %#x,count:%d",rets,deviceNum);
//        for (int i = 0; i<deviceNum; i++)
//        {
//            DDLogInfo(@"Call_Log: ulIndex:%d,strName:%s,string:%@",deviceInfo[i].index,deviceInfo[i].device_name,[NSString stringWithUTF8String:deviceInfo[i].device_name]);
//        }
//    }
//    delete [] deviceInfo;
//    return ret == TSDK_SUCCESS ? YES : NO;
//}

/**
 * This method is used to switch camera open or close
 * 切换摄像头开关
 *@param openCamera               Indicates open camera, YES:open NO:close
 *                                是否打开摄像头
 *@param callId                   Indicates call id
 *                                呼叫id
 *@return YES is success,NO is fail
 */
-(BOOL)switchCameraOpen:(BOOL)openCamera callId:(unsigned int)callId
{
    if (openCamera)
    {
        [self videoControlWithCmd:OPEN_AND_START andModule:LOCAL_AND_REMOTE andIsSync:NO callId:callId];
        //reopen local camera
        _cameraRotation = 0;
        [self rotationCameraCapture:_cameraRotation callId:callId];
    }
    else
    {
        [self setVideoCaptureFileWithcallId:callId];
        [self videoControlWithCmd:STOP andModule:LOCAL_AND_REMOTE andIsSync:YES callId:callId];
//        [self pauseVideoCapture:YES callId:callId];
    }
    return YES;
}

/**
 *This method is used to control video
 *控制远端和近端的摄像头打开或者关闭
 */
-(void)videoControlWithCmd:(EN_VIDEO_OPERATION)control andModule:(EN_VIDEO_OPERATION_MODULE)module andIsSync:(BOOL)isSync callId:(unsigned int)callId
{
    DDLogInfo(@"videoControlWithCmd :%d module: %d isSync:%d",control,module,isSync);
    TSDK_S_VIDEO_CTRL_INFO videoControlInfos;
    memset_s(&videoControlInfos, sizeof(TSDK_S_VIDEO_CTRL_INFO), 0, sizeof(TSDK_S_VIDEO_CTRL_INFO));
    TSDK_UINT32 call_id = (TSDK_UINT32)callId;
    videoControlInfos.object = 6;
    videoControlInfos.operation = control;
    videoControlInfos.is_sync = isSync;
    TSDK_RESULT ret = tsdk_video_control(call_id, &videoControlInfos);
    DDLogInfo(@"Call_Log: tsdk_video_control result= %@",(TSDK_SUCCESS == ret)?@"YES":@"NO");
}

/**
 * This method is used to deal with video streaming, app enter background or foreground
 * 在app前后景切换时,控制视频流
 *@param active                    Indicates active YES: goreground NO: background
 *                                 触发行为
 *@param callId                    Indicates call id
 *                                 呼叫id
 *@return YES is success,NO is fail
 */
-(BOOL)controlVideoWhenApplicationResignActive:(BOOL)active callId:(unsigned int)callId
{
    if (active)
    {
        return [self switchCameraOpen:YES callId:callId];
    }
    else
    {
        return [self switchCameraOpen:NO callId:callId];
    }
}

/**
 * This method is used to play WAV music file
 * 播放wav音乐文件
 *@param filePath                  Indicates file path
 *                                 文件路径
 *@return YES is success,NO is fail
 */
-(BOOL)mediaStartPlayWithFile:(NSString *)filePath
{
    if (_playHandle >= 0)
    {
        return NO;
    }
    TSDK_RESULT result = tsdk_start_play_media(0, (TSDK_CHAR *)[filePath UTF8String], &_playHandle);
    DDLogInfo(@"Call_Log: tsdk_start_play_media result= %xd , playhandle = %d",result,_playHandle);
    return result == TSDK_SUCCESS ? YES : NO;
}

/**
 * This method is used to stop play music
 * 停止播放铃音
 *@return YES is success,NO is fail
 */
-(BOOL)mediaStopPlay
{
    TSDK_RESULT result = tsdk_stop_play_media(_playHandle);
    _playHandle = -1;
    DDLogInfo(@"Call_Log: tsdk_stop_play_media result= %d",result);
    return result == TSDK_SUCCESS ? YES : NO;
}

/**
 * This method is used to switch mute micphone
 * 打开或者关闭麦克风
 *@param mute                      Indicates switch microphone, YES is mute,NO is unmute
 *                                 打开或者关闭麦克风
 *@param callId                    Indicates call id
 *                                 呼叫id
 *@return YES is success,NO is fail
 */
-(BOOL)muteMic:(BOOL)mute callId:(unsigned int)callId
{
    TSDK_RESULT result = tsdk_mute_mic(callId , mute);
    DDLogInfo(@"Call_Log: tsdk_mute_mic result= %@",(TSDK_SUCCESS == result)?@"YES":@"NO");
    return result == TSDK_SUCCESS ? YES : NO;
}


/**
 * This method is used to set audio route
 * 设置音频路线
 *@param route                      Indicates audio route, see ROUTE_TYPE enum value
 *                                  音频路线
 *@return YES is success,NO is fail. Call back see NTF_AUDIOROUTE_CHANGED
 */
-(BOOL)configAudioRoute:(ROUTE_TYPE)route
{
    TSDK_E_MOBILE_AUIDO_ROUTE audioRoute = (TSDK_E_MOBILE_AUIDO_ROUTE)route;
    TSDK_RESULT result = tsdk_set_mobile_audio_route(audioRoute);
    DDLogInfo(@"tsdk_set_mobile_audio_route result is %@, audioRoute is :%d",result == TSDK_SUCCESS ? @"YES" : @"NO",audioRoute);
    return result == TSDK_SUCCESS ? YES : NO;
}

/**
 * This method is used to get audio route
 * 获取音频路线
 *@return ROUTE_TYPE
 */
-(ROUTE_TYPE)obtainMobileAudioRoute
{
    TSDK_E_MOBILE_AUIDO_ROUTE route;
    TSDK_RESULT result = tsdk_get_mobile_audio_route(&route);
    DDLogInfo(@"tsdk_get_mobile_audio_route result is %d, audioRoute is :%d",result,route);
    return (ROUTE_TYPE)route;
}

/**
 * This method is used to send DTMF
 * 发送dtmf
 *@param number                      Indicates dtmf number, 0-9 * #
 *                                   dtmf号码
 *@param callId                      Indicates call id
 *                                   呼叫id
 *@return YES is success,NO is fail
 */
- (BOOL)sendDTMFWithDialNum:(NSString *)number callId:(unsigned int)callId
{
    TSDK_E_DTMF_TONE dtmfTone = (TSDK_E_DTMF_TONE)[number intValue];
    if ([number isEqualToString:@"*"])
    {
        dtmfTone = TSDK_E_DTMF_STAR;
    }
    else if ([number isEqualToString:@"#"])
    {
        dtmfTone = TSDK_E_DTMF_POUND;
    }
    TSDK_UINT32 callid = callId;
    TSDK_RESULT ret = tsdk_send_dtmf((TSDK_UINT32)callid,(TSDK_E_DTMF_TONE)dtmfTone);
    DDLogInfo(@"Call_Log: tsdk_send_dtmf = %@",(TSDK_SUCCESS == ret)?@"YES":@"NO");
    return ret == TSDK_SUCCESS ? YES : NO;
}

#pragma mark - IPT
/**
 * This method is used to call is on going, hold this call, not hand up
 * 保持呼叫
 *@param callId                      Indicates call id
 *                                   呼叫id
 *@return YES is success,NO is fail
 */
-(BOOL)holdCallWithCallId:(unsigned int)callId
{
    TSDK_RESULT ret = tsdk_hold_call(callId);
    DDLogInfo(@"Call_Log: tsdk_hold_call = %@",(TSDK_SUCCESS == ret)?@"YES":@"NO");
    return ret == TSDK_SUCCESS ? YES : NO;
}

/**
 * This method is used to unhold call
 * 取消保持呼叫
 *@param callId                      Indicates call id
 *                                   呼叫id
 *@return YES is success,NO is fail
 */
-(BOOL)unHoldCallWithCallId:(unsigned int)callId
{
    TSDK_RESULT ret = tsdk_unhold_call(callId);
    DDLogInfo(@"Call_Log: tsdk_unhold_call = %@",(TSDK_SUCCESS == ret)?@"YES":@"NO");
    return ret == TSDK_SUCCESS ? YES : NO;
}

/**
 * This method is used to blind transfer number
 * 盲转
 *@param number                      Indicates distination number
 *                                   盲转目的地号码
 *@param callId                      Indicates call id
 *                                   呼叫id
 *@return YES is success,NO is fail
 */
-(BOOL)blindTransferWithNumber:(NSString *)number callId:(unsigned int)callId
{
    TSDK_RESULT ret = tsdk_blind_transfer(callId , [number UTF8String]);
    DDLogInfo(@"Call_Log: tsdk_blind_transfer = %d, number = %@",ret,number);
    return ret == TSDK_SUCCESS ? YES : NO;
}

/**
 * This method is used to divert call
 * 偏转号码
 *@param number                      Indicates distination number
 *                                   偏转目的地号码
 *@param callId                      Indicates call id
 *                                   呼叫id
 *@return YES is success,NO is fail
 */
-(BOOL)divertCallWithNumber:(NSString *)number callId:(unsigned int)callId
{
    
    TSDK_RESULT ret = tsdk_divert_call(callId , [number UTF8String]);
    DDLogInfo(@"Call_Log: tsdk_divert_call = %d, number = %@",ret,number);
    return ret == TSDK_SUCCESS ? YES : NO;
}


/**
 * This method is used to set IPT service
 * 设置ipt业务
 *@param serviceType                     Indicates service type, see CALL_E_SERVICE_CALL_TYPE value
 *                                       ipt业务类型，参考CALL_E_SERVICE_CALL_TYPE
 *@param capable                         Indicates is enable
 *                                       是否开启
 *@param number                          Indicates destination number
 *                                       目标号码
 *@return YES or NO
 */
-(BOOL)setIPTService:(NSInteger)serviceType andCapable:(BOOL)isEnable andNumber:(NSString *)number
{
    TSDK_RESULT ret = tsdk_set_ipt_service((TSDK_E_IPT_SERVICE_TYPE)serviceType, isEnable, (TSDK_CHAR *)[number UTF8String]);
    DDLogInfo(@"Call_Log: tup_call_set_IPTservice = %#x",ret);
    return ret == TSDK_SUCCESS ? YES : NO;
}



#pragma mark - CTD

/**
 * This method is used to start CTD call
 * 发起ctd呼叫
 *@param callbackNumber           Indicates ctd callback number
 *                                ctd主叫号码
 *@param callee                   Indicates target number
 *                                ctd被叫号码
 *@return YES is success,NO is fail
 */
-(BOOL)startCTDCallWithCallbackNumber:(NSString *)callbackNumber
                         calleeNumber:(NSString *)callee
{
    TSDK_S_CTD_CALL_PARAM *ctdParam = (TSDK_S_CTD_CALL_PARAM *)malloc(sizeof(TSDK_S_CTD_CALL_PARAM));
    memset(ctdParam, 0, sizeof(TSDK_S_CTD_CALL_PARAM));
    strcpy(ctdParam->callee_number, [callee UTF8String]);
    strcpy(ctdParam->caller_number, [callbackNumber UTF8String]);
    if (self.terminal.length  > 0 || self.terminal != nil) {
        // 公有云环境需要用长号订阅
        strcpy(ctdParam->subscribe_number, [self.terminal UTF8String]);
    }else{
        strcpy(ctdParam->subscribe_number, [callbackNumber UTF8String]);
    }
    TSDK_INT32 ctdCallId;
    TSDK_RESULT result = tsdk_ctd_start_call(ctdParam, (TSDK_UINT32*)&ctdCallId);
    _ctdCallId = ctdCallId;
    DDLogInfo(@"tsdk_ctd_start_call result: %d",result);
    free(ctdParam);
    if (result == TSDK_SUCCESS) {
        CallLogMessage *callLogMessage = [[CallLogMessage alloc]init];
        callLogMessage.calleePhoneNumber = callbackNumber;
        callLogMessage.durationTime = 0;
        callLogMessage.startTime = [self nowTimeString];
        callLogMessage.callLogType = OutgointCall;
        callLogMessage.callId = ctdCallId;
        callLogMessage.isConnected = NO;
        NSMutableArray *array = [[NSMutableArray alloc]init];
        if ([self loadLocalCallHistoryData].count > 0) {
            array = [self loadLocalCallHistoryData];
        }
        [array addObject:callLogMessage];
        [self writeToLocalFileWith:array];
    }
    return TSDK_SUCCESS == result ? YES : NO;
}

/**
 * This method is used to close ctd call
 * 结束ctd呼叫
 @return YES is success,NO is fail
 */
-(BOOL)endCTDCall
{
    TSDK_RESULT ret = tsdk_ctd_end_call(_ctdCallId);
    DDLogInfo(@"Call_Log: tsdk_ctd_end_call = %d, callId:%d", ret, _ctdCallId);
    _ctdCallId = 0;
    return ret == TSDK_SUCCESS ? YES : NO;
}

/**
 * This method is used to config ip call
 * 设置ip呼叫
 */
-(BOOL)ipCallConfig
{
    //config local ip
    TSDK_S_LOCAL_ADDRESS local_ip;
    memset(&local_ip, 0, sizeof(TSDK_S_LOCAL_ADDRESS));
    NSString *ip = [CommonUtils getLocalIpAddressWithIsVPN:[CommonUtils checkIsVPNConnect]];
    strcpy(local_ip.ip_address, [ip UTF8String]);
    local_ip.is_try_resume = TSDK_FALSE;
    TSDK_RESULT configResult = tsdk_set_config_param(TSDK_E_CONFIG_LOCAL_ADDRESS, &local_ip);
    DDLogInfo(@"config local address result: %d; local ip is: %@", configResult, ip);
    
    TSDK_BOOL ip_call_switch = true;
    configResult = tsdk_set_config_param(TSDK_E_CONFIG_IPCALL_SWITCH, &ip_call_switch);
    DDLogInfo(@"config ip call result: %d", configResult);
    
    return configResult;
}


/**
 *This method is used to post call event call back to UI according to type
 *将呼叫回调事件分发给页面
 */
-(void)respondsCallDelegateWithType:(TUP_CALL_EVENT_TYPE)type result:(NSDictionary *)resultDictionary
{
    if ([self.delegate respondsToSelector:@selector(callEventCallback:result:)])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate callEventCallback:type result:resultDictionary];
        });
    }
}

/**
 *This method is used to post ctd event call back to UI according to type
 *将ctd回调事件分发给页面
 */
-(void)respondsCTDDelegateWithType:(TUP_CTD_EVENT_TYPE)type result:(NSDictionary *)resultDictionary
{
    if ([self.delegate respondsToSelector:@selector(ctdCallEventCallback:result:)])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate ctdCallEventCallback:type result:resultDictionary];
        });
    }
}


-(void)dealloc
{
}

#pragma mark - DBPath Deal

/**
 *This method is used to get call history database path, if not exist create it
 *获取呼叫历史记录本地存储路径
 */
- (NSString *)callHistoryDBPath
{
    NSString *logPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *plistName = [NSString stringWithFormat:@"%@_allHistory.plist",[ManagerService callService].sipAccount];
    NSString *filePath = [logPath stringByAppendingPathComponent:plistName];
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        if ([[NSFileManager defaultManager] createFileAtPath:filePath
                                                    contents:nil
                                                  attributes:nil]) {
            return filePath;
        }else {
            DDLogWarn(@"create callHistory.plist failed!");
            return nil;
        }
    }
    return filePath;
}

/**
 *This method is used to write message to local file
 *将信息写到本地文件中
 */
- (BOOL)writeToLocalFileWith:(NSArray *)array {
    NSString *path = [self callHistoryDBPath];
    if (path) {
        return [NSKeyedArchiver archiveRootObject:array toFile:path];
    }
    return NO;
}

/**
 *This method is used to local call history data
 *加载呼叫历史记录
 */
- (NSArray *)loadLocalCallHistoryData {
    NSString *path = [self callHistoryDBPath];
    if (path) {
        NSArray *array = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
        return array;
    }
    return nil;
}

/**
 *This method is used to get current time as appointed format
 *获取给定格式的当前时间
 */
- (NSString *)nowTimeString
{
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *nowTimeString = [formatter stringFromDate:date];
    return nowTimeString;
}


@end
