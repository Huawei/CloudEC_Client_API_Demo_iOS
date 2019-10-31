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
#include "tsdk_error_def.h"
#include "tsdk_call_def.h"
#include "tsdk_call_interface.h"

#include <arpa/inet.h>
#import <string.h>
#import "ConfAttendee+StructParase.h"
#import "ManagerService.h"
#import "ConfData.h"
#import "ConfAttendeeInConf.h"
#import "Initializer.h"
#import "LoginInfo.h"
#import "LoginServerInfo.h"
#import "Defines.h"
#import "ChatMsg.h"
#import "ConfBaseInfo.h"
#import "CommonUtils.h"
#import <CloudLinkMeetingScreenShare/ScreenShareManager.h>

#import "JoinConfIndInfo.h"
#import "SVCConfWatchAttendeeInfo.h"
#import "VideoStreamInfo.h"

#define CG2TCPoint(point) { .x = (int)point.x, .y = (int)point.y }

//数据共享线程
dispatch_queue_t espace_dataconf_datashare_queue = 0;

#define JOIN_NUMBER_LEN 256
@interface ConferenceService()<TupConfNotifacation>

@property (nonatomic, assign) int confHandle;                     // current confHandle
@property (nonatomic, assign) NSString *dataConfIdWaitConfInfo;   // get current confId
@property (nonatomic, copy)NSString *sipAccount;                  // current sipAccount
@property (nonatomic, copy)NSString *account;                     // current account
@property (nonatomic, copy) NSString *confCtrlUrl;              // recorde dateconf_uri
@property (nonatomic, strong) NSMutableDictionary *confTokenDic;  // update conference token in SMC
@property (nonatomic, assign) BOOL hasReportMediaxSpeak;          // has reportMediaxSpeak or not in Mediax
@property (nonatomic, retain) NSTimer *heartBeatTimer;            // NSTime record heart beat

//@property (nonatomic, assign) BOOL isStartScreenSharing;
@property (nonatomic, assign) int currentDataShareTypeId;
@property (nonatomic, assign) BOOL isJoinDataConfSuccess; // 是否加入数据会议
@property (nonatomic, strong) ScreenShareManager *screenShareManager;
@property (nonatomic, assign) TSDK_UINT32 mWidthPixels;
@property (nonatomic, assign) TSDK_UINT32 mHeightPixels;
@property (nonatomic, assign) TSDK_UINT32 mScreenShareType; // 屏幕共享类型
@property (nonatomic, assign) BOOL mIsStartScreenShareDelayed;
@property (nonatomic, assign) BOOL isAnonymousConf;

@end

@implementation ConferenceService
{
    //屏幕共享 远端ppi
    CGFloat _remotePpiX;
    CGFloat _remotePpiY;
}

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

@synthesize isVideoConfInvited;

@synthesize chatDelegate;

@synthesize currentConfBaseInfo;

@synthesize lastConfSharedData;

@synthesize isBeginAnnotation;

@synthesize imageScale;

@synthesize mIsScreenSharing;

@synthesize currentJoinConfIndInfo;

@synthesize currentCallId;

@synthesize watchAttendeesArray;

@synthesize currentBigViewAttendee;

@synthesize isStartScreenSharing;

@synthesize hasConfResumedFirstRewatch;

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
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            espace_dataconf_datashare_queue = dispatch_queue_create("com.huawei.espace.dataconf.datashare", 0);
        });
        [Initializer registerConfCallBack:self]; //注册回调，将回调消息分发代理设置为自己
        self.isJoinDataConf = NO;
        _confHandle = 0;
        self.haveJoinAttendeeArray = [[NSMutableArray alloc] init]; //会议与会者列表
        self.watchAttendeesArray = [[NSMutableArray alloc] init];
        self.uPortalConfType = CONF_TOPOLOGY_UC;
        _confTokenDic = [[NSMutableDictionary alloc]init];
        _confCtrlUrl = nil;
        self.selfJoinNumber = nil;
        _hasReportMediaxSpeak = NO;
        self.currentCallId = 0;
        self.isVideoConfInvited = NO;
        self.currentConfBaseInfo = [[ConfBaseInfo alloc]init];
        self.isStartScreenSharing = NO;
        self.isJoinDataConfSuccess = NO;
        _currentDataShareTypeId = -1;
        self.isBeginAnnotation = NO;
        self.imageScale = 1.0;
        self.mIsScreenSharing = NO;
        self.hasConfResumedFirstRewatch = NO;
        self.currentJoinConfIndInfo = [[JoinConfIndInfo alloc] init];
        self.currentBigViewAttendee = [[SVCConfWatchAttendeeInfo alloc] init];
        _isAnonymousConf = NO;
        
        [self initScreenShareManager];
    }
    return self;
}

- (void)initScreenShareManager {
    DDLogInfo(@"enter initScreenShareManager ");
    NSString *appGroup = @"group.eSpaceMclientV2";
    self.screenShareManager = [[ScreenShareManager alloc]initWithAppGroupIdentifier:appGroup];
    [self.screenShareManager listenForMessageWithIdentifier:@"screenshare" listener:^(id messageObject) {
        
        NSDictionary *dir = [messageObject valueForKey:@"screendata"];
        [self processImage:dir];
    }];
    
    [self.screenShareManager listenForMessageWithIdentifier:@"screenShareStateChange" listener:^(id messageObject) {
        long state = [[messageObject valueForKey:@"state"] longValue];
        if (state == 1) {
            if (self.isJoinDataConfSuccess) {
                self.mIsScreenSharing = YES;
                [self startDataConfAsPre];
                [self startDataShare];
                
            } else {
                NSError *error = [[NSError alloc] initWithDomain:@"ScreenShare" code:-1 userInfo:@{NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"the meeting is unavailable", nil)}];
                [self.screenShareManager passMessageObject:@{@"result" : error} identifier:@"StopBroadcast"];
            }
            
        } else if (state == 0) {
            [self confStopReplayKitBroadcast];
        
        }
    }];
}

- (void)confStopReplayKitBroadcast
{
    
    if (self.mIsScreenSharing) {
        TSDK_RESULT result = tsdk_app_share_stop(_confHandle);
    }
    
    [self confStopReplay];
}

- (void)confStopReplay
{
    NSError *error = [[NSError alloc] initWithDomain:@"ScreenShare" code:-1 userInfo:@{NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"stop_screen_share", nil)}];
    [self.screenShareManager passMessageObject:@{@"result" : error} identifier:@"StopBroadcast"];
    
    _mWidthPixels = 0;
    _mHeightPixels = 0;
    self.mIsScreenSharing = NO;
    _mIsStartScreenShareDelayed = NO;
}

- (BOOL)inviteDataShareWithNumber:(NSString *)number
{
    TSDK_RESULT result = tsdk_app_share_set_owner(_confHandle, (TSDK_CHAR*)[number UTF8String], TSDK_E_CONF_AS_ACTION_ADD);
    
    return result;
}

- (BOOL)cancelDataShareWithNumber:(NSString *)number
{
    TSDK_RESULT result = tsdk_app_share_set_owner(_confHandle, (TSDK_CHAR*)[number UTF8String], TSDK_E_CONF_AS_ACTION_DELETE);
    
    return result;
}


- (void)startDataShare
{
    TSDK_RESULT result = tsdk_app_share_start(_confHandle, TSDK_E_CONF_APP_SHARE_DESKTOP);
}

- (void) startDataConfAsPre {
    DDLogInfo(@"enter startDataConfAsPre _mIsScreenSharing: %d _mWidthPixels: %d _mHeightPixels: %d " , self.mIsScreenSharing, self.mWidthPixels , self.mHeightPixels);
    self.mIsStartScreenShareDelayed = NO;
    if (self.mWidthPixels == 0 || self.mHeightPixels == 0) {
        self.mIsStartScreenShareDelayed = YES;
        return;
    }
    TSDK_S_CONF_AS_VIRTUAL_VIEW_INFO virtual_view_info;
    memset(&virtual_view_info, 0, sizeof(TSDK_S_CONF_AS_VIRTUAL_VIEW_INFO));
    virtual_view_info.width = _mWidthPixels;
    virtual_view_info.height = _mHeightPixels;
    virtual_view_info.bit_count = 32;
    
    tsdk_app_share_set_virtual_view_info(_confHandle, &virtual_view_info);
    
}

-(void)processImage:(NSDictionary *)dictionary {
    unsigned int width = [[dictionary objectForKey:@"width"] unsignedIntValue];
    unsigned int height = [[dictionary objectForKey:@"height"] unsignedIntValue];
    long orientation = [[dictionary objectForKey:@"orientation"] longValue];
    if (!self.mIsScreenSharing) {
        if (orientation == UIImageOrientationLeft
            || orientation == UIImageOrientationRight
            || orientation == UIImageOrientationLeftMirrored
            || orientation == UIImageOrientationRightMirrored) {
            self.mWidthPixels = height;
            self.mHeightPixels = width;
        } else {
            self.mWidthPixels = width;
            self.mHeightPixels = height;
        }
        if (self.mIsStartScreenShareDelayed) {
            [self startDataConfAsPre];
        }
        return;
    }
    
    unsigned int yPitch = [[dictionary objectForKey:@"yPitch"] unsignedIntValue];
    unsigned int cbCrPitch = [[dictionary objectForKey:@"yPitch"] unsignedIntValue];
    NSData *yData = [dictionary objectForKey:@"yData"];
    NSData *uvData = [dictionary objectForKey:@"uvData"];
    uint8_t *yBuffer = (unsigned char *)[yData bytes];
    uint8_t *cbCrBuffer = (unsigned char *)[uvData bytes];
    
    TSDK_S_CONF_AS_VIEW_DATA_INFO asViewUpdataData;
    memset(&asViewUpdataData, 0, sizeof(TSDK_S_CONF_AS_VIEW_DATA_INFO));
    asViewUpdataData.y_data = yBuffer;
    asViewUpdataData.cb_cr_data = cbCrBuffer;
    asViewUpdataData.y_data_size = yPitch;
    asViewUpdataData.cb_cr_data_size = cbCrPitch;
    asViewUpdataData.width = width;
    asViewUpdataData.height = height;
    asViewUpdataData.orientation = (TSDK_E_IMAGE_ORIENTATION)orientation;
    
    
    tsdk_app_share_update_view_data(_confHandle, &asViewUpdataData);
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
            if (confListInfo != NULL)
            {
                TSDK_S_CONF_BASE_INFO confInfo = (TSDK_S_CONF_BASE_INFO)confListInfo[0];
                
                if (self.currentConfBaseInfo == nil) {
                    self.currentConfBaseInfo = [[ConfBaseInfo alloc]init];
                }
                self.currentConfBaseInfo.conf_id = [NSString stringWithUTF8String:confInfo.conf_id];
                self.currentConfBaseInfo.conf_subject = [NSString stringWithUTF8String:confInfo.subject];
                self.currentConfBaseInfo.access_number = [NSString stringWithUTF8String:confInfo.access_number];
                self.currentConfBaseInfo.chairman_pwd = [NSString stringWithUTF8String:confInfo.chairman_pwd];
                self.currentConfBaseInfo.general_pwd = [NSString stringWithUTF8String:confInfo.guest_pwd];
                NSString *utcDataStartString = [NSString stringWithUTF8String:confInfo.start_time];
                self.currentConfBaseInfo.start_time = [CommonUtils getLocalDateFormateUTCDate:utcDataStartString];
                NSString *utcDataEndString = [NSString stringWithUTF8String:confInfo.end_time];
                self.currentConfBaseInfo.end_time = [CommonUtils getLocalDateFormateUTCDate:utcDataEndString];
                self.currentConfBaseInfo.scheduser_number = [NSString stringWithUTF8String:confInfo.scheduser_account];
                self.currentConfBaseInfo.scheduser_name = [NSString stringWithUTF8String:confInfo.scheduser_name];
                self.currentConfBaseInfo.media_type = (EC_CONF_MEDIATYPE)confInfo.conf_media_type;
                self.currentConfBaseInfo.conf_state = (CONF_E_STATE)confInfo.conf_state;
                self.currentConfBaseInfo.isHdConf = confInfo.is_hd_conf;
                self.currentConfBaseInfo.token = [NSString stringWithUTF8String:confInfo.token];
                self.currentConfBaseInfo.chairJoinUri = [NSString stringWithUTF8String:confInfo.chair_join_uri];
                self.currentConfBaseInfo.guestJoinUri = [NSString stringWithUTF8String:confInfo.guest_join_uri];
                
                _dataConfIdWaitConfInfo = self.currentConfBaseInfo.conf_id;
                
            }
            
            NSDictionary *resultInfo = @{
                                         ECCONF_RESULT_KEY : [NSNumber numberWithBool:result],
                                         //ECCONF_BOOK_CONF_INFO_KEY : currentConfInfo
                                         };
            [self respondsECConferenceDelegateWithType:CONF_E_CREATE_RESULT result:resultInfo];
            
        }
            break;
        case TSDK_E_CONF_EVT_CONF_BASE_INFO_IND:
    {
        TSDK_S_CONF_BASE_INFO *confListInfo = (TSDK_S_CONF_BASE_INFO *)notify.data;
        if (confListInfo != NULL)
        {
            TSDK_S_CONF_BASE_INFO confInfo = (TSDK_S_CONF_BASE_INFO)confListInfo[0];
            
            if (self.currentConfBaseInfo == nil) {
                self.currentConfBaseInfo = [[ConfBaseInfo alloc]init];
            }
            self.currentConfBaseInfo.conf_id = [NSString stringWithUTF8String:confInfo.conf_id];
            self.currentConfBaseInfo.conf_subject = [NSString stringWithUTF8String:confInfo.subject];
            self.currentConfBaseInfo.access_number = [NSString stringWithUTF8String:confInfo.access_number];
            self.currentConfBaseInfo.chairman_pwd = [NSString stringWithUTF8String:confInfo.chairman_pwd];
            self.currentConfBaseInfo.general_pwd = [NSString stringWithUTF8String:confInfo.guest_pwd];
            NSString *utcDataStartString = [NSString stringWithUTF8String:confInfo.start_time];
            self.currentConfBaseInfo.start_time = [CommonUtils getLocalDateFormateUTCDate:utcDataStartString];
            NSString *utcDataEndString = [NSString stringWithUTF8String:confInfo.end_time];
            self.currentConfBaseInfo.end_time = [CommonUtils getLocalDateFormateUTCDate:utcDataEndString];
            self.currentConfBaseInfo.scheduser_number = [NSString stringWithUTF8String:confInfo.scheduser_account];
            self.currentConfBaseInfo.scheduser_name = [NSString stringWithUTF8String:confInfo.scheduser_name];
            self.currentConfBaseInfo.media_type = (EC_CONF_MEDIATYPE)confInfo.conf_media_type;
            self.currentConfBaseInfo.conf_state = (CONF_E_STATE)confInfo.conf_state;
            self.currentConfBaseInfo.isHdConf = confInfo.is_hd_conf;
            self.currentConfBaseInfo.token = [NSString stringWithUTF8String:confInfo.token];
            self.currentConfBaseInfo.chairJoinUri = [NSString stringWithUTF8String:confInfo.chair_join_uri];
            self.currentConfBaseInfo.guestJoinUri = [NSString stringWithUTF8String:confInfo.guest_join_uri];
            
            _dataConfIdWaitConfInfo = self.currentConfBaseInfo.conf_id;
            
        }
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
        case TSDK_E_CONF_EVT_CONF_RESUMING_IND:
        {
            self.hasConfResumedFirstRewatch = YES;
            
            [self confStopReplay];
            
//            [self.watchAttendeesArray removeAllObjects];
//            [self restoreConfParamsInitialValue];
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:LOGIN_AND_CONF_RESUMING_NOTIFY object:nil];
            });
        }
            break;
        case TSDK_E_CONF_EVT_CONF_RESUME_RESULT:
    {
        DDLogInfo(@"TSDK_E_CONF_EVT_CONF_RESUME_RESULT");
        BOOL result = notify.param2 == TSDK_SUCCESS;
        if (!result) {
            DDLogError(@"TSDK_E_CONF_EVT_JOIN_CONF_RESULT,error:%@",[NSString stringWithUTF8String:(TSDK_CHAR *)notify.data]);
            [self restoreConfParamsInitialValue];
            return;
        }

        _confHandle = notify.param1;
        TSDK_S_RESUME_CONF_IND_INFO *confResumeInfo = (TSDK_S_RESUME_CONF_IND_INFO *)notify.data;
        TSDK_S_JOIN_CONF_IND_INFO* confInfo = (TSDK_S_JOIN_CONF_IND_INFO *)&confResumeInfo->join_conf_ind_info;
        self.currentCallId = confInfo->call_id;

        if (self.currentJoinConfIndInfo == nil) {
            self.currentJoinConfIndInfo = [[JoinConfIndInfo alloc] init];
        }
        self.currentJoinConfIndInfo.callId = confInfo->call_id;
        self.currentJoinConfIndInfo.confMediaType = confInfo->conf_media_type;
        self.currentJoinConfIndInfo.isHdConf = confInfo->is_hd_conf;
        self.currentJoinConfIndInfo.confEnvType = confInfo->conf_env_type;
        self.currentJoinConfIndInfo.isSvcConf = confInfo->is_svc_conf;
        self.currentJoinConfIndInfo.svcLableCount = confInfo->svc_label_count;
        NSMutableArray *lableArray = [[NSMutableArray alloc] init];
        TSDK_UINT32 *svc_lable = confInfo->svc_label;
        for (int i = 0; i <= self.currentJoinConfIndInfo.svcLableCount; i++) {
            TSDK_UINT32 lable = svc_lable[i];
            [lableArray addObject:[NSNumber numberWithInt:lable]];
        }
        self.currentJoinConfIndInfo.svcLable = [NSArray arrayWithArray:lableArray];


        if (confInfo->conf_media_type == TSDK_E_CONF_MEDIA_VIDEO || confInfo->conf_media_type == TSDK_E_CONF_MEDIA_VIDEO_DATA) {
            self.isVideoConfInvited = YES;
        }
        [self respondsECConferenceDelegateWithType:CONF_E_CONNECT result:nil];

        dispatch_async(dispatch_get_main_queue(), ^{
            // go conference
            DDLogInfo(@"goConferenceRunView");
            [[NSNotificationCenter defaultCenter] postNotificationName:TUP_CALL_REMOVE_CALL_VIEW_NOTIFY object:nil];

        });
    }
    break;
    
        case TSDK_E_CONF_EVT_JOIN_CONF_RESULT:
        {
            DDLogInfo(@"TSDK_E_CONF_EVT_JOIN_CONF_RESULT");
            BOOL result = notify.param2 == TSDK_SUCCESS;
            if (!result) {
                DDLogError(@"TSDK_E_CONF_EVT_JOIN_CONF_RESULT,error:%@",[NSString stringWithUTF8String:(TSDK_CHAR *)notify.data]);
                if (_isAnonymousConf) {
                    _isAnonymousConf = NO;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self confCtrlLeaveConference];
                    });
                    [self restoreConfParamsInitialValue];
                }
                
                return;
            }
            
            _confHandle = notify.param1;
            TSDK_S_JOIN_CONF_IND_INFO *confInfo = (TSDK_S_JOIN_CONF_IND_INFO *)notify.data;
            self.currentCallId = confInfo->call_id;
            
            if (self.currentJoinConfIndInfo == nil) {
                self.currentJoinConfIndInfo = [[JoinConfIndInfo alloc] init];
            }
            self.currentJoinConfIndInfo.callId = confInfo->call_id;
            self.currentJoinConfIndInfo.confMediaType = confInfo->conf_media_type;
            self.currentJoinConfIndInfo.isHdConf = confInfo->is_hd_conf;
            self.currentJoinConfIndInfo.confEnvType = confInfo->conf_env_type;
            self.currentJoinConfIndInfo.isSvcConf = confInfo->is_svc_conf;
            self.currentJoinConfIndInfo.svcLableCount = confInfo->svc_label_count;
            NSMutableArray *lableArray = [[NSMutableArray alloc] init];
            TSDK_UINT32 *svc_lable = confInfo->svc_label;
            for (int i = 0; i <= self.currentJoinConfIndInfo.svcLableCount; i++) {
                TSDK_UINT32 lable = svc_lable[i];
                [lableArray addObject:[NSNumber numberWithInt:lable]];
            }
            self.currentJoinConfIndInfo.svcLable = [NSArray arrayWithArray:lableArray];
            
            
            if (confInfo->conf_media_type == TSDK_E_CONF_MEDIA_VIDEO || confInfo->conf_media_type == TSDK_E_CONF_MEDIA_VIDEO_DATA) {
                self.isVideoConfInvited = YES;
            }
            [self respondsECConferenceDelegateWithType:CONF_E_CONNECT result:nil];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                // go conference
                DDLogInfo(@"goConferenceRunView");
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
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [[NSNotificationCenter defaultCenter] postNotificationName:CONF_QUITE_TO_CONFLISTVIEW object:nil];
//            });
//            [self respondsECConferenceDelegateWithType:CONF_E_END_RESULT result:nil];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self confCtrlLeaveConference];
            });
            [self restoreConfParamsInitialValue];
            
        }
            break;
            
        case TSDK_E_CONF_EVT_JOIN_DATA_CONF_RESULT:
        {
            DDLogInfo(@"TSDK_E_CONF_EVT_JOIN_DATA_CONF_RESULT");
            NSDictionary *resultInfo = nil;
            BOOL isSuccess = notify.param2 == TSDK_SUCCESS;
            self.isJoinDataConfSuccess = isSuccess;
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
            
            BOOL isStopSharing = NO;
            
            
            TSDK_E_CONF_SHARE_STATE state =  shareState->state;
            
            switch (state) {
                case TSDK_E_CONF_AS_STATE_NULL:
                {
                    self.isStartScreenSharing = NO;
                    isStopSharing = YES;
                }
                    break;
                case TSDK_E_CONF_AS_STATE_START:
                case TSDK_E_CONF_AS_STATE_VIEW:
                {
                    TSDK_S_CONF_AS_STATE_INFO *as_state_info = (TSDK_S_CONF_AS_STATE_INFO *)notify.data;
                    TSDK_UINT32 Annotation = as_state_info->sub_state;
                    
                    [self beginAnnotation:(Annotation == 512)];
                    
                    self.isStartScreenSharing = YES;
                    _currentDataShareTypeId = TSDK_E_COMPONENT_AS;
                    [self handleScreenShareDataConfhandle:notify.param1];
                }
                    break;
                default:
                    break;
            }
            
            if (isStopSharing) {
                __weak typeof(self) weakSelf = self;
                dispatch_async(espace_dataconf_datashare_queue, ^{
                    [weakSelf stopSharedData];
                    self.isStartScreenSharing = NO;
                });
            }
        }
            break;
        case TSDK_E_CONF_EVT_AS_SCREEN_DATA_UPDATE:
        {
            DDLogInfo(@"TSDK_E_CONF_EVT_AS_SCREEN_DATA_UPDATE");
            [self handleScreenShareDataConfhandle:notify.param1];
        }
            break;
        case TSDK_E_CONF_EVT_DS_DOC_NEW:
        {
            DDLogInfo(@"TSDK_E_CONF_EVT_DS_DOC_NEW");
        }
            break;
        case TSDK_E_CONF_EVT_DS_DOC_PAGE_NEW:
        {
            DDLogInfo(@"TSDK_E_CONF_EVT_DS_DOC_PAGE_NEW");

            [self handleDsDocShareDataConfHandle:notify.param1];
            
        }
            break;
        
        case TSDK_E_CONF_EVT_DS_DOC_CURRENT_PAGE_IND:
        {
//            dispatch_async(espace_dataconf_datashare_queue, ^{ //在espace_dataconf_datashare_queue线程中调用结束，确保无时序问题
                TSDK_S_DOC_PAGE_BASE_INFO *pageInfo = (TSDK_S_DOC_PAGE_BASE_INFO *)notify.data;
                [self handleDsDocCurrentPageInfoWithConfHandle:notify.param1 andPageInfo:pageInfo];
//                [self handleDsDocShareDataConfHandle:notify.param1];
            
//            });
            
        }
            break;
            
        case TSDK_E_CONF_EVT_DS_DOC_CURRENT_PAGE:
        {
            
        }
            break;
        case TSDK_E_CONF_EVT_DS_DOC_DRAW_DATA_NOTIFY:
        {
            [self handleDsDocShareDataConfHandle:notify.param1];
        }
            break;
        
        case TSDK_E_CONF_EVT_DS_DOC_DEL:
        {
            __weak typeof(self) weakSelf = self;
            dispatch_async(espace_dataconf_datashare_queue, ^{ //在espace_dataconf_datashare_queue线程中调用结束，确保无时序问题
                //dispatch_async(espace_dataconf_queue, ^{
                //    [weakSelf respondsECConferenceDelegateWithType:DATACONF_SHARE_SCREEN_DATA_STOP result:nil];
                //});
                
                [weakSelf stopSharedData];
                _currentDataShareTypeId = 0;
                
            });
        }
            break;
            
        case TSDK_E_CONF_EVT_WB_DOC_NEW:
        {
            DDLogInfo(@"TSDK_E_CONF_EVT_WB_DOC_NEW");
        }
            break;
        
        case TSDK_E_CONF_EVT_WB_DOC_CURRENT_PAGE_IND:
        {
            TSDK_S_DOC_PAGE_BASE_INFO *pageInfo = (TSDK_S_DOC_PAGE_BASE_INFO *)notify.data;
            [self handleDsDocCurrentPageInfoWithConfHandle:notify.param1 andPageInfo:pageInfo];
        }
            break;
        
        case TSDK_E_CONF_EVT_WB_DOC_DRAW_DATA_NOTIFY:
        {
            [self handleWbDocShareDataConfHandle:notify.param1];
        }
            break;
        
        case TSDK_E_CONF_EVT_WB_DOC_DEL:
        {
            __weak typeof(self) weakSelf = self;
            dispatch_async(espace_dataconf_datashare_queue, ^{ //在espace_dataconf_datashare_queue线程中调用结束，确保无时序问题
                //dispatch_async(espace_dataconf_queue, ^{
                //    [weakSelf respondsECConferenceDelegateWithType:DATACONF_SHARE_SCREEN_DATA_STOP result:nil];
                //});
                
                [weakSelf stopSharedData];
                _currentDataShareTypeId = 0;
                
            });
        }
            break;
            
        case TSDK_E_CONF_EVT_RECV_CHAT_MSG:
        {
            TSDK_S_CONF_CHAT_MSG_INFO *chat_msg_info = (TSDK_S_CONF_CHAT_MSG_INFO*)notify.data;
            [self handleChatMSGdata:chat_msg_info];
            DDLogInfo(@"TSDK_E_CONF_EVT_RECV_CHAT_MSG");
            break;
        }
            
        case TSDK_E_CONF_EVT_SPEAKER_IND:
        {
            DDLogInfo(@"TSDK_E_CONF_EVT_SPEAKER_IND");
            TSDK_S_CONF_SPEAKER_INFO *speaker_info = (TSDK_S_CONF_SPEAKER_INFO *)notify.data;
            TSDK_S_CONF_SPEAKER *speakers = speaker_info->speakers;
            NSMutableArray *tempArray = [[NSMutableArray alloc] init];
            for (int i = 0; i < speaker_info->speaker_num; i++) {
                TSDK_S_CONF_SPEAKER speaker = speakers[i];
//                DDLogInfo(@"speakers[i].number :%s,speakers[i].is_speaking :%d",speakers[i].number,speakers[i].is_speaking);
                ConfCtrlSpeaker *confSpeaker = [[ConfCtrlSpeaker alloc] init];
        
                NSString *number = [NSString stringWithUTF8String:speaker.base_info.number];
                if (number.length > 0) {
                    confSpeaker.number = [NSString stringWithUTF8String:speaker.base_info.number];
                }
                
                confSpeaker.is_speaking = speaker.is_speaking;
                confSpeaker.speaking_volume = speaker.speaking_volume;
                [tempArray addObject:confSpeaker];
            }
            
            NSDictionary *resultInfo = @{
                                         ECCONF_SPEAKERLIST_KEY : [NSArray arrayWithArray:tempArray]
                                         };
            [self respondsECConferenceDelegateWithType:CONF_E_SPEAKER_LIST result:resultInfo];
        }
            break;
        
        case TSDK_E_CONF_EVT_SHARE_STATUS_UPDATE_IND:
        {
            TSDK_S_SHARE_STATUS_INFO *statusInfo = (TSDK_S_SHARE_STATUS_INFO *)notify.data;
            [self onShareStatusUpateInd:statusInfo];
        }
            break;
            
        case TSDK_E_CONF_EVT_AS_OWNER_CHANGE:
        {
            TSDK_E_CONF_AS_ACTION_TYPE actionType = (TSDK_E_CONF_AS_ACTION_TYPE)notify.param2;
            TSDK_S_ATTENDEE *owner =  (TSDK_S_ATTENDEE *)notify.data;
            TSDK_BOOL isSelf = owner->status_info.is_self;
            if (@available(iOS 12, *)) {
                if (isSelf) {
                    if (actionType == TSDK_E_CONF_AS_ACTION_ADD) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [[NSNotificationCenter defaultCenter] postNotificationName:APP_START_SYSTEM_SHARE_VIEW object:nil];
                        });
                    }else if (actionType == TSDK_E_CONF_AS_ACTION_DELETE){
                        self.mIsScreenSharing = NO;
                        [self confStopReplay];
                    }else if (actionType == TSDK_E_CONF_AS_ACTION_REQUEST){
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [[NSNotificationCenter defaultCenter] postNotificationName:CONF_SHARE_REQUEST_ACTION
                                                                                object:nil];
                            
                        });
                    }
                }
            }
            
        }
            break;
        case TSDK_E_CONF_EVT_SVC_WATCH_INFO_IND:
        {
            TSDK_S_CONF_SVC_WATCH_INFO* svc_watch_info = (TSDK_S_CONF_SVC_WATCH_INFO*)notify.data;
            TSDK_S_CONF_SVC_WATCH_ATTENDEE *watch_attendees = svc_watch_info->watch_attendees;
            NSInteger currentLabel = [self.currentJoinConfIndInfo.svcLable[0] integerValue];
            for (int i = 0; i < svc_watch_info->watch_attendee_num; i ++) {
                TSDK_S_CONF_SVC_WATCH_ATTENDEE watchAttendees = (TSDK_S_CONF_SVC_WATCH_ATTENDEE)watch_attendees[i];
                if (watchAttendees.label == currentLabel) {
                    self.currentBigViewAttendee = [[SVCConfWatchAttendeeInfo alloc] init];
                    self.currentBigViewAttendee.name = [NSString stringWithUTF8String:watchAttendees.base_info.display_name];
                    self.currentBigViewAttendee.number = [NSString stringWithUTF8String:watchAttendees.base_info.number];
                    self.currentBigViewAttendee.role = (CONFCTRL_CONF_ROLE)watchAttendees.base_info.role;
                    self.currentBigViewAttendee.label = watchAttendees.label;
                    
                    [self respondsECConferenceDelegateWithType:CONF_E_SVC_WATCH_INFO_IND result:nil];
                }
            }
    
        }
            break;
        default:
            break;
    }
}

- (void)onShareStatusUpateInd:(TSDK_S_SHARE_STATUS_INFO *)statusInfo
{
    TSDK_E_SHARE_STATUS status = statusInfo->share_status;
    TSDK_E_COMPONENT_ID componetId = (TSDK_E_COMPONENT_ID)statusInfo->component_id;
    
    switch (status) {
        case TSDK_E_SHARE_STATUS_STOP: {
            _currentDataShareTypeId = 0;
            //            prevDataShareTypeId_ = 0;
            [self stopSharedData];
            return;
        }
        case TSDK_E_SHARE_STATUS_SHARING: {
            if (TSDK_E_COMPONENT_BASE == componetId || TSDK_E_COMPONENT_VIDEO == componetId || TSDK_E_COMPONENT_RECORD == componetId || TSDK_E_COMPONENT_POLLING == componetId || TSDK_E_COMPONENT_FT == componetId){
                _currentDataShareTypeId = 0;
                //                prevDataShareTypeId_ = 0;
                [self stopSharedData];
                return;
            }
            //            // 当前的模块纪录为上一次的模块
            //            prevDataShareTypeId_ = currentDataShareTypeId_;
            // 当前的模块变为新来的模块
            _currentDataShareTypeId = componetId;
            break;
        }
        default:
            break;
    }
}

-(void)handleScreenShareDataConfhandle:(TSDK_UINT32 )confHandle
{
    if (!self.isStartScreenSharing) {
        DDLogInfo(@"[Meeting] COMPT_MSG_AS_ON_SCREEN_DATA:current share type is not screen share!");
        return;
    }
    
    if (_currentDataShareTypeId != 0x0002 && _currentDataShareTypeId != 0 && _currentDataShareTypeId != -1) {
        return;
    }
    
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
    if (data == NULL) {
        return;
    }
    TSDK_UINT32 ssize = *((TSDK_UINT32 *)((char *)data + sizeof(TSDK_UINT16)));
    NSData *imageData = [NSData dataWithBytes:data length:ssize];
    if (imageData == nil)
    {
        DDLogInfo(@"share imageData from data fail!");
        return;
    }
//    NSDictionary *shareDataInfo = @{
//                                    DATACONF_SHARE_DATA_KEY:imageData
//                                    };
//    [self respondsECConferenceDelegateWithType:DATA_CONF_AS_ON_SCREEN_DATA result:shareDataInfo];
    __weak typeof(self) weakSelf = self;
    dispatch_async(espace_dataconf_datashare_queue, ^{
        [weakSelf receiveSharedData:imageData];
    });
}

- (void)handleDsDocShareDataConfHandle:(TSDK_UINT32)confHandle
{
//    if (_currentDataShareTypeId != 0x0001) {
//        return;
//    }
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(espace_dataconf_datashare_queue, ^{
        @autoreleasepool {
            TSDK_UINT32 iWidth = 0;
            TSDK_UINT32 iHeight = 0;
            TSDK_VOID *pData = tsdk_doc_share_get_surface_bmp(confHandle, TSDK_E_COMPONENT_DS, &iWidth, &iHeight);
            if (NULL == pData) {
                DDLogInfo(@"[Meeting] Data is null.");
                return;
            }
            char *pBmpData = (char *)pData;
            TSDK_UINT32 wSize = *(TSDK_UINT32 *)((char *)pBmpData + sizeof(TSDK_UINT16));
            NSData *imgData = [NSData dataWithBytes:(void*)pBmpData length:wSize];
            if (nil == imgData) {
                DDLogInfo(@"[Meeting] Make image from data failed.");
                return;
            }
            [weakSelf receiveSharedData:imgData];
        }
    });
}

- (void)handleDsDocCurrentPageInfoWithConfHandle:(TSDK_INT32)confHandle andPageInfo:(TSDK_S_DOC_PAGE_BASE_INFO *)pageInfo
{
    tsdk_doc_share_set_current_page(confHandle, pageInfo, NO);
    TSDK_S_DOC_PAGE_DETAIL_INFO detailInfo;
    memset(&detailInfo, 0, sizeof(TSDK_S_DOC_PAGE_DETAIL_INFO));
    
    TSDK_RESULT result = tsdk_doc_share_get_syn_document_info(confHandle, pageInfo->component_id, &detailInfo);
    
    if (result == TSDK_SUCCESS && (detailInfo.height > 0 && detailInfo.width > 0)) {
        TSDK_S_SIZE size;
        memset(&size, 0, sizeof(TSDK_S_DOC_PAGE_BASE_INFO));
        size.width = detailInfo.width;
        size.high = detailInfo.height;
        tsdk_doc_share_set_canvas_size(confHandle, pageInfo->component_id, &size, YES);
    }
}

- (void)handleWbDocShareDataConfHandle:(TSDK_UINT32)confHandle
{
    
//    if (_currentDataShareTypeId != 0x0200) {
//        return;
//    }
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(espace_dataconf_datashare_queue, ^{
        @autoreleasepool {
            TSDK_UINT32 iWidth = 0;
            TSDK_UINT32 iHeight = 0;
            TSDK_VOID *pData = tsdk_doc_share_get_surface_bmp(confHandle, TSDK_E_COMPONENT_WB, &iWidth, &iHeight);
            if (NULL == pData) {
                DDLogInfo(@"[Meeting] Data is null.");
                return;
            }
            
            char *pBmpData = (char *)pData;
            TSDK_UINT32 wSize = *(TSDK_UINT32 *)((char *)pBmpData + sizeof(TSDK_UINT16));
            NSData *imgData = [NSData dataWithBytes:(void*)pBmpData length:wSize];
            if (nil == imgData) {
                DDLogInfo(@"[Meeting] Make image from data failed.");
                return;
            }
            
//            NSDictionary *shareDataInfo = @{
//                                            DATACONF_SHARE_DATA_KEY:imgData
//                                            };
//            [weakSelf respondsECConferenceDelegateWithType:DATA_CONF_AS_ON_SCREEN_DATA result:shareDataInfo];
            [weakSelf receiveSharedData:imgData];
            
        }
        
        
    });
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

    NSString *msg = [msgStr stringByRemovingPercentEncoding];
    DDLogInfo(@"msgStr :%@,chatMsg->lpMsg :%s, chatMsg->sender_display_name :%s，chatMsg->nMsgLen:%d",msg,chatMsg->chat_msg,chatMsg->sender_display_name,chatMsg->chat_msg_len);
    ChatMsg *tupMsg = [[ChatMsg alloc] init];
    tupMsg.nMsgLen = chatMsg->chat_msg_len;
    tupMsg.time = chatMsg->time;
    tupMsg.lpMsg = msg;
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
- (BOOL)chatSendMsg:(NSString *)message
       fromUsername:(NSString *)username
           toUserId:(unsigned int)userId
{
    if (message.length == 0 || username.length == 0) {
        return NO;
    }
    TSDK_S_CONF_CHAT_MSG_INFO chat_msg_info;
    memset(&chat_msg_info, 0, sizeof(TSDK_S_CONF_CHAT_MSG_INFO));
    chat_msg_info.chat_type = TSDK_E_CONF_CHAT_PUBLIC;
    strcpy(chat_msg_info.sender_display_name, (TSDK_CHAR*)username.UTF8String);
    NSString * messageU = [message stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    chat_msg_info.chat_msg = (TSDK_CHAR*)messageU.UTF8String;
    chat_msg_info.chat_msg_len = strlen(messageU.UTF8String);
    TSDK_RESULT result = tsdk_send_chat_msg_in_conference(_confHandle, &chat_msg_info);
    return result == TSDK_SUCCESS ? YES : NO;
}

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
                                         ECCONF_RESULT_KEY : [NSNumber numberWithInt:YES]
                                         };
            [self respondsECConferenceDelegateWithType:CONF_E_MUTE_ATTENDEE_RESULT result:resultInfo];
        }
            break;
        case TSDK_E_CONF_UNMUTE_ATTENDEE:
        {
            DDLogInfo(@"TSDK_E_CONF_UNMUTE_ATTENDEE");
            NSDictionary *resultInfo = @{
                                         ECCONF_RESULT_KEY : [NSNumber numberWithInt:NO]
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
    
    if (self.currentConfBaseInfo == nil) {
        self.currentConfBaseInfo = [[ConfBaseInfo alloc]init];
    }
    self.currentConfBaseInfo.num_of_participant = confStatusStruct->attendee_num;
    self.currentConfBaseInfo.size = confStatusStruct->size;
    self.currentConfBaseInfo.media_type = (EC_CONF_MEDIATYPE)confStatusStruct->conf_media_type;
    self.currentConfBaseInfo.conf_state = (CONF_E_STATE)confStatusStruct->conf_state;
    self.currentConfBaseInfo.conf_id = [NSString stringWithUTF8String:confStatusStruct->conf_id];
    self.currentConfBaseInfo.call_id = self.currentCallId;
    self.currentConfBaseInfo.conf_subject = [NSString stringWithUTF8String:confStatusStruct->subject];
    self.currentConfBaseInfo.record_status = confStatusStruct->is_record;
    self.currentConfBaseInfo.lock_state = confStatusStruct->is_lock;
    self.currentConfBaseInfo.is_all_mute = confStatusStruct->is_all_mute;
    
    TSDK_S_ATTENDEE *participants = confStatusStruct->attendee_list;
    
    DDLogInfo(@"jinliang111,confStatusStruct->attendee_num:%lu",(unsigned long)confStatusStruct->attendee_num);
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
        addAttendee.isSelf = participant.status_info.is_self;
        addAttendee.isBroadcast = participant.status_info.is_broadcast;
        addAttendee.isShareOwner = participant.status_info.is_share_owner;
        addAttendee.isAnonymous = participant.status_info.is_anonymous;
        addAttendee.isVideo = participant.status_info.is_video;
        
        [self.haveJoinAttendeeArray addObject:addAttendee];
        if (!self.selfJoinNumber) {
            self.selfJoinNumber = self.sipAccount;
        }
        
        __block BOOL isAttendeeInConf = NO;
        [self.watchAttendeesArray enumerateObjectsUsingBlock:^(ConfAttendeeInConf* attendeeInfo, NSUInteger idx, BOOL * _Nonnull stop) {
            if([addAttendee.number isEqualToString:attendeeInfo.number]){
                if (addAttendee.state == ATTENDEE_STATUS_IN_CONF) {
                    attendeeInfo.name = [NSString stringWithUTF8String:participant.base_info.display_name];
                    attendeeInfo.number = [NSString stringWithUTF8String:participant.base_info.number];
                    attendeeInfo.participant_id = [NSString stringWithUTF8String:participant.status_info.participant_id];
                    attendeeInfo.is_mute = (participant.status_info.is_mute == TSDK_TRUE);
                    attendeeInfo.hand_state = (participant.status_info.is_handup == TSDK_TRUE);
                    attendeeInfo.role = (CONFCTRL_CONF_ROLE)participant.base_info.role;
                    attendeeInfo.state = (ATTENDEE_STATUS_TYPE)participant.status_info.state;
                    attendeeInfo.isJoinDataconf = participant.status_info.is_join_dataconf;
                    attendeeInfo.isPresent = participant.status_info.is_present;
                    attendeeInfo.isSelf = participant.status_info.is_self;
                    attendeeInfo.isBroadcast = participant.status_info.is_broadcast;
                    attendeeInfo.isShareOwner = participant.status_info.is_share_owner;
                    attendeeInfo.isAnonymous = participant.status_info.is_anonymous;
                    attendeeInfo.isVideo = participant.status_info.is_video;
                }
                
                isAttendeeInConf = YES;
                *stop = YES;
                if (*stop == YES) {
                    if (addAttendee.state == ATTENDEE_STATUS_LEAVED || !addAttendee.isVideo) {
                        [self.watchAttendeesArray removeObject:attendeeInfo];
                    }
                }
            }
        }];
        if(isAttendeeInConf == NO){
            if (addAttendee.state == ATTENDEE_STATUS_IN_CONF && addAttendee.isVideo && !addAttendee.isSelf) {
                [self.watchAttendeesArray addObject:addAttendee];
            }
        }
        
//        if ([self.selfJoinNumber isEqualToString:[NSString stringWithUTF8String:participant.base_info.number]]) {
//            // if conference'uPortalConfType is CONF_TOPOLOGY_MEDIAX and self role is CONFCTRL_E_CONF_ROLE_CHAIRMAN ,need to open report function ,only once time;
//            if (participant.base_info.role == TSDK_E_CONF_ROLE_CHAIRMAN && [self isUportalMediaXConf] && !_hasReportMediaxSpeak) {
//                _hasReportMediaxSpeak = YES;
//                [self configMediaxSpeakReport];
//            }
//        }
    }
    if (self.haveJoinAttendeeArray.count > 0) {
        [self.watchAttendeesArray enumerateObjectsUsingBlock:^(ConfAttendeeInConf* attendeeInfo, NSUInteger idx, BOOL * _Nonnull stop) {
            __block BOOL isAttendeeIArray = NO;
            
            [self.haveJoinAttendeeArray enumerateObjectsUsingBlock:^(ConfAttendeeInConf* joinAttendeeInfo, NSUInteger idx, BOOL * _Nonnull stop) {
                if([joinAttendeeInfo.number isEqualToString:attendeeInfo.number]){
                    
                    isAttendeeIArray = YES;
                    *stop = YES;
                    
                }
                
            }];
            
            if (isAttendeeIArray == NO) {
                [self.watchAttendeesArray removeObject:attendeeInfo];
            }
            
            
        }];
    }
    
        
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:CONF_ATTENDEE_STATUS_UPDATE_NOTIFY object:nil];
        [self respondsECConferenceDelegateWithType:CONF_E_ATTENDEE_UPDATE_INFO result:nil];
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

    if (self.currentConfBaseInfo == nil) {
        self.currentConfBaseInfo = [[ConfBaseInfo alloc]init];
    }
    self.currentConfBaseInfo.conf_id = [NSString stringWithUTF8String:confListInfo.conf_id];
    self.currentConfBaseInfo.conf_subject = [NSString stringWithUTF8String:confListInfo.subject];
    self.currentConfBaseInfo.access_number = [NSString stringWithUTF8String:confListInfo.access_number];
    self.currentConfBaseInfo.chairman_pwd = [NSString stringWithUTF8String:confListInfo.chairman_pwd];
    self.currentConfBaseInfo.general_pwd = [NSString stringWithUTF8String:confListInfo.guest_pwd];
    NSString *utcDataStartString = [NSString stringWithUTF8String:confListInfo.start_time];
    self.currentConfBaseInfo.start_time = [CommonUtils getLocalDateFormateUTCDate:utcDataStartString];
    NSString *utcDataEndString = [NSString stringWithUTF8String:confListInfo.end_time];
    self.currentConfBaseInfo.end_time = [CommonUtils getLocalDateFormateUTCDate:utcDataEndString];
    self.currentConfBaseInfo.scheduser_number = [NSString stringWithUTF8String:confListInfo.scheduser_account];
    self.currentConfBaseInfo.scheduser_name = [NSString stringWithUTF8String:confListInfo.scheduser_name];
    self.currentConfBaseInfo.media_type = (EC_CONF_MEDIATYPE)confListInfo.conf_media_type;
    self.currentConfBaseInfo.conf_state = (CONF_E_STATE)confListInfo.conf_state;
    self.currentConfBaseInfo.isHdConf = confListInfo.is_hd_conf;
    self.currentConfBaseInfo.token = [NSString stringWithUTF8String:confListInfo.token];
    self.currentConfBaseInfo.chairJoinUri = [NSString stringWithUTF8String:confListInfo.chair_join_uri];
    self.currentConfBaseInfo.guestJoinUri = [NSString stringWithUTF8String:confListInfo.guest_join_uri];
    
    NSDictionary *resultInfo = @{
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
        ConfBaseInfo *confBaseInfo = [[ConfBaseInfo alloc] init];
        
        confBaseInfo.conf_id = [NSString stringWithUTF8String:confList[i].conf_id];
        confBaseInfo.conf_subject = [NSString stringWithUTF8String:confList[i].subject];
        confBaseInfo.access_number = [NSString stringWithUTF8String:confList[i].access_number];
        confBaseInfo.chairman_pwd = [NSString stringWithUTF8String:confList[i].chairman_pwd];
        confBaseInfo.general_pwd = [NSString stringWithUTF8String:confList[i].guest_pwd];
        NSString *utcDataStartString = [NSString stringWithUTF8String:confList[i].start_time];
        confBaseInfo.start_time = [CommonUtils getLocalDateFormateUTCDate:utcDataStartString];
        NSString *utcDataEndString = [NSString stringWithUTF8String:confList[i].end_time];
        confBaseInfo.end_time = [CommonUtils getLocalDateFormateUTCDate:utcDataEndString];
        confBaseInfo.scheduser_number = [NSString stringWithUTF8String:confList[i].scheduser_account];
        confBaseInfo.scheduser_name = [NSString stringWithUTF8String:confList[i].scheduser_name];
        confBaseInfo.media_type = (EC_CONF_MEDIATYPE)confList[i].conf_media_type;
        confBaseInfo.conf_state = (CONF_E_STATE)confList[i].conf_state;
        confBaseInfo.isHdConf = confList[i].is_hd_conf;
        confBaseInfo.token = [NSString stringWithUTF8String:confList[i].token];
        confBaseInfo.chairJoinUri = [NSString stringWithUTF8String:confList[i].chair_join_uri];
        confBaseInfo.guestJoinUri = [NSString stringWithUTF8String:confList[i].guest_join_uri];
                
        if (confBaseInfo.conf_state != CONF_E_STATE_DESTROYED)
        {
            [tempArray addObject:confBaseInfo];
        }
    }
    NSDictionary *resultInfo = @{
                                 ECCONF_LIST_KEY : tempArray
                                 };
    [self respondsECConferenceDelegateWithType:CONF_E_GET_CONFLIST result:resultInfo];
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
        }
        if (tempAttendee.account.length > 0 && tempAttendee.account != nil) {
            strcpy(attendee[i].account_id, [tempAttendee.account UTF8String]);
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
    bookConfInfoUportal->is_hd_conf = TSDK_TRUE;
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
    
    TSDK_CHAR join_number[JOIN_NUMBER_LEN];
    
    NSString *realNumber = joinNumber;
    if (!realNumber || realNumber.length == 0) {
        if (!self.selfJoinNumber) {
            self.selfJoinNumber = self.sipAccount;
        }
        realNumber = self.selfJoinNumber;
    }
    if (realNumber == nil || realNumber.length == 0) {
        return NO;
    }
    strcpy(join_number, [realNumber UTF8String]);
    
    TSDK_UINT32 call_id;
    DDLogInfo(@"joinConferenceWithConfId,confid:%s,conf_password:%s,access_number:%s",confJoinParam.conf_id,confJoinParam.conf_password,confJoinParam.access_number);
    BOOL result = tsdk_join_conference(&confJoinParam, join_number, (TSDK_BOOL)isVideoJoin, &call_id);
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
    if (_confHandle == 0) {
        return NO;
    }
    
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
        if (cAttendee.account.length != 0) {
            strcpy(attendee[i].account_id, [cAttendee.account UTF8String]);
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
//    if (attendeeNumber.length == 0 && attendeeNumber == nil) {
//        TSDK_RESULT ret_watch_attendee = tsdk_watch_attendee(_confHandle, nil);
//        DDLogInfo(@"ret_watch_attendee: %d", ret_watch_attendee);
//        return;
//    }
    
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

-(void)watchAttendeeNumberArray:(NSArray *)attendeeArray labelArray:(NSArray *)labelArray
{
    if (self.hasConfResumedFirstRewatch == YES) {
        self.hasConfResumedFirstRewatch = NO;
    }
    TSDK_S_WATCH_ATTENDEES_INFO *attendeeInfo = (TSDK_S_WATCH_ATTENDEES_INFO *)malloc(sizeof(TSDK_S_WATCH_ATTENDEES_INFO));
    memset_s(attendeeInfo, sizeof(TSDK_S_WATCH_ATTENDEES_INFO), 0, sizeof(TSDK_S_WATCH_ATTENDEES_INFO));
    attendeeInfo->watch_attendee_num = (TSDK_UINT32)attendeeArray.count;
    
    TSDK_S_WATCH_ATTENDEES *attendeeList = (TSDK_S_WATCH_ATTENDEES *)malloc(sizeof(TSDK_S_WATCH_ATTENDEES) * attendeeArray.count);
    memset_s(attendeeList, sizeof(TSDK_S_WATCH_ATTENDEES) * attendeeArray.count, 0, sizeof(TSDK_S_WATCH_ATTENDEES) * attendeeArray.count);
    
    for (int i = 0; i < attendeeArray.count; i++) {
        NSInteger label = [labelArray[i] integerValue];
        strcpy(attendeeList[i].number, [attendeeArray[i] UTF8String]);
        if (self.currentJoinConfIndInfo.isSvcConf) {
            if (label == [self.currentJoinConfIndInfo.svcLable[0] integerValue]) {
                attendeeList[i].label = (TSDK_UINT32)label;
                attendeeList[i].width = 960;
                attendeeList[i].height = 540;
                
            }else{
                attendeeList[i].label = (TSDK_UINT32)label;
//                attendeeList[i].width = 320;
//                attendeeList[i].height = 180;
                attendeeList[i].width = 160;
                attendeeList[i].height = 90;
            }
        }
    }
    
    attendeeInfo->watch_attendee_list = attendeeList;
    
    TSDK_RESULT ret_watch_attendee = tsdk_watch_attendee(_confHandle, attendeeInfo);
//    DDLogInfo(@"ret_watch_attendee: %d", ret_watch_attendee);
}

/**
 * This method is used to boardcast attendee
 * 广播与会者
 */
- (void)broadcastAttendee:(NSString *)attendeeNumber isBoardcast:(BOOL)isBoardcast {
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

-(void)receiveSharedData:(NSData*)data{
    if ([data length] > 0 ) {
        [self willChangeValueForKey:@"lastConfSharedData"];
        self.lastConfSharedData = data;
        [self didChangeValueForKey:@"lastConfSharedData"];
    }
    
}
-(void)stopSharedData{
    [self willChangeValueForKey:@"lastConfSharedData"];
    self.lastConfSharedData = nil;
    [self didChangeValueForKey:@"lastConfSharedData"];
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
    dispatch_async(dispatch_get_main_queue(), ^{
        DDLogInfo(@"restoreConfParamsInitialValue");
        [_confTokenDic removeAllObjects];
        [self.haveJoinAttendeeArray removeAllObjects];
        [self.watchAttendeesArray removeAllObjects];
        self.isJoinDataConf = NO;
        _dataConfIdWaitConfInfo = nil;
        _confCtrlUrl = nil;
        self.selfJoinNumber = nil;
        _hasReportMediaxSpeak = NO;
        [self stopHeartBeat];
        self.currentCallId = 0;
        self.isVideoConfInvited = NO;
        self.currentConfBaseInfo = nil;
        self.lastConfSharedData = nil;
        self.isJoinDataConfSuccess = NO;
        self.isBeginAnnotation = NO;
        self.imageScale = 1.0;
        self.currentJoinConfIndInfo = nil;
        self.currentBigViewAttendee = nil;
        self.hasConfResumedFirstRewatch = NO;
        [self confStopReplay];
        [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
        [[NSNotificationCenter defaultCenter] postNotificationName:CONF_QUITE_TO_CONFLISTVIEW object:nil];
    });
}

/**
 * This method is used to judge whether is uportal mediax conf
 * 判断是否为mediax下的会议
 */
- (BOOL)isUportalMediaXConf
{
    //Mediax conference
    return  (CONF_TOPOLOGY_MEDIAX == self.uPortalConfType);
}

/**
 * This method is used to judge whether is uportal smc conf
 * 判断是否为smc下的会议
 */
- (BOOL)isUportalSMCConf
{
    //SMC conference
    return (CONF_TOPOLOGY_SMC == self.uPortalConfType);
}

/**
 * This method is used to judge whether is uportal UC conf
 * 判断是否为uc下的会议
 */
- (BOOL)isUportalUSMConf
{
    //UC conference
    return (CONF_TOPOLOGY_UC == self.uPortalConfType);
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

- (BOOL)joinConferenceWithDisPlayName:(NSString *)disPlayName ConfId:(NSString *)confID PassWord:(NSString *)passWord ServerAdd:(NSString *)serverAdd ServerPort:(int)serverPort
{
    TSDK_S_CONF_ANONYMOUS_JOIN_PARAM anonymousParam;
    memset(&anonymousParam, 0, sizeof(TSDK_S_CONF_ANONYMOUS_JOIN_PARAM));
    
    strcpy(anonymousParam.display_name, [disPlayName UTF8String]);
    strcpy(anonymousParam.conf_id, [confID UTF8String]);
    strcpy(anonymousParam.conf_password, [passWord UTF8String]);
    strcpy(anonymousParam.server_addr, [serverAdd UTF8String]);
    anonymousParam.server_port = serverPort;
    
    TSDK_RESULT joinConfResult = tsdk_join_conference_by_anonymous(&anonymousParam);
    
    _isAnonymousConf = YES;
    
    return joinConfResult == TSDK_SUCCESS;
}

/**
 开始标注
 */
- (void)beginAnnotation:(BOOL)shouldBegin {
    if (shouldBegin) {
        self.isBeginAnnotation = YES;
    }else{
        self.isBeginAnnotation = NO;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        DDLogInfo(@"Annotation beginAnnotation :%@", @(shouldBegin));
        [[NSNotificationCenter defaultCenter] postNotificationName:NTF_MULTI_MEDIA_CONF_SHOULD_HAS_ANNO
                                                            object:nil
                                                          userInfo:@{ @"annotationMode" : @(shouldBegin)}];
    });
}

- (void)annotationSetPenAndAnnotationColor:(unsigned int)color lineWidth:(int)lineWidth {
    
    TSDK_S_ANNOTATION_PEN_INFO newPenInfo;
    memset(&newPenInfo, 0, sizeof(TSDK_S_ANNOTATION_PEN_INFO));
    newPenInfo.style = TSDK_E_ANNOTATION_PEN_STYLE_SOLID;
    newPenInfo.color = color;
    newPenInfo.width = lineWidth;
    
    TSDK_S_ANNOTATION_PEN_INFO oldPenInfo;
    memset(&oldPenInfo, 0, sizeof(TSDK_S_ANNOTATION_PEN_INFO));
    
    
    TSDK_RESULT result = tsdk_annotation_set_pen(_confHandle, (TSDK_E_COMPONENT_ID)_currentDataShareTypeId, TSDK_E_ANNOTATION_PEN_NORMAL, &newPenInfo, &oldPenInfo);
    DDLogInfo(@"Annotation tsdk_annotation_set_pen: %d", result);
    
    
    TSDK_S_ANNOTATION_BRUSH_INFO newBrushInfo;
    memset(&newBrushInfo, 0, sizeof(TSDK_S_ANNOTATION_BRUSH_INFO));
    newBrushInfo.style = TSDK_E_ANNOTATION_BRUSH_SOLID;
    newBrushInfo.color = color;
    
    TSDK_S_ANNOTATION_BRUSH_INFO oldBrushInfo;
    memset(&oldBrushInfo, 0, sizeof(TSDK_S_ANNOTATION_BRUSH_INFO));
    
    TSDK_RESULT brushResult = tsdk_annotation_set_brush(_confHandle, (TSDK_E_COMPONENT_ID)_currentDataShareTypeId, &newBrushInfo, &oldBrushInfo);
    DDLogInfo(@"Annotation tsdk_annotation_set_brush: %d", brushResult);
    
}

-(void)conferenceCreateAnnotationWithStartPointx:(long)pointx Pointy:(long)pointy {
//    TSDK_S_DOC_PAGE_BASE_INFO page_info;
//    memset(&page_info, 0, sizeof(TSDK_S_DOC_PAGE_BASE_INFO));
//    page_info.component_id = (TSDK_E_COMPONENT_ID)_currentDataShareTypeId;
//    if (_currentDataShareTypeId == TSDK_E_COMPONENT_AS) {
//        page_info.document_id = 0;
//        page_info.page_count = 0;
//        page_info.page_index = 0;
//    } else if (_currentDataShareTypeId == TSDK_E_COMPONENT_DS) {
//        // TODO 白板标注时需要设置docid 和 pageid
//    }
    
    CGFloat hScale = [self heightScale];
    CGFloat wScale = [self widthScale];
    
    TSDK_S_POINT tsdkPoint;
    memset(&tsdkPoint, 0, sizeof(TSDK_S_POINT));
    tsdkPoint.x = (TSDK_INT32)pointx * wScale;
    tsdkPoint.y = (TSDK_INT32)pointy * hScale;
    
    tsdk_annotation_create_start(_confHandle, (TSDK_E_COMPONENT_ID)_currentDataShareTypeId, TSDK_NULL_PTR, TSDK_E_ANNOTATION_DRAWING, 1, &tsdkPoint);
}

- (void)conferenceUpdateAnnotationWithPointx:(long)pointx Pointy:(long)pointy {
    CGFloat hScale = [self heightScale];
    CGFloat wScale = [self widthScale];
    
    TSDK_S_ANNOTATION_DRAWING_DATA data;
    memset(&data, 0, sizeof(TSDK_S_ANNOTATION_DRAWING_DATA));
    data.point.x = (TSDK_INT32)pointx * wScale;
    data.point.y = (TSDK_INT32)pointy * hScale;
    
    tsdk_annotation_create_update(_confHandle, (TSDK_E_COMPONENT_ID)_currentDataShareTypeId, TSDK_E_ANNOTATION_DRAWING, &data);
}

- (void)conferenceFinishAnnotation {
    TSDK_UINT32 annotation_id = 0;
    tsdk_annotation_create_done(_confHandle, (TSDK_E_COMPONENT_ID)_currentDataShareTypeId, 0, &annotation_id);
}

- (void)conferenceCancelAnnotation {
    TSDK_UINT32 annotation_id = 0;
    tsdk_annotation_create_done(_confHandle, (TSDK_E_COMPONENT_ID)_currentDataShareTypeId, 1, &annotation_id);
}

- (CGFloat)widthScale {
    if (_currentDataShareTypeId == TSDK_E_COMPONENT_AS) {
        //若为屏幕共享，则cgpoint转化为twips 需要 scale 为 1440 / 对端ppi * 像素
        return _remotePpiX * self.imageScale * [UIScreen mainScreen].scale;
    } else if (_currentDataShareTypeId == TSDK_E_COMPONENT_WB) {
        // TODO 白板标注时需要另外计算
        //return _dsDageinfo.width / self.wbImageViewSize.width;
        return 1.0;
    } else {
        return 1.0;
    }
}


- (CGFloat)heightScale {
    if (_currentDataShareTypeId == TSDK_E_COMPONENT_AS) {
        return _remotePpiY * self.imageScale * [UIScreen mainScreen].scale;
    } else if (_currentDataShareTypeId == TSDK_E_COMPONENT_WB) {
        // TODO 白板标注时需要另外计算
        //return _dsDageinfo.height / self.wbImageViewSize.height;
        return 1.0;
    } else {
        return 1.0;
    }
}
- (void)conferenceShareGetParam {
    
    TSDK_S_SIZE sizeParam;
    memset(&sizeParam, 0, sizeof(TSDK_S_SIZE));
    
    TSDK_RESULT result = tsdk_get_remote_view_ppi_info(_confHandle, &sizeParam);
    if (TSDK_SUCCESS == result) {
        _remotePpiY = sizeParam.high;
        _remotePpiX = sizeParam.width;
    }
}

/**
 擦除线
 先通过线选选中需要删除的线，再调用删除接口进行删除
 
 @param startPoint 起始点
 @param endPoint 终止点
 */
- (void)conferenceEraseAnnotationsIntersectedBySegmentWithStartPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint {
    
    TSDK_S_ANNOTATION_HIT_TEST_LINE_INFO hit_test_line_info;
    memset(&hit_test_line_info, 0, sizeof(TSDK_S_ANNOTATION_HIT_TEST_LINE_INFO));
    hit_test_line_info.doc_page_info.component_id = (TSDK_E_COMPONENT_ID)_currentDataShareTypeId;
    hit_test_line_info.doc_page_info.document_id = 0;
    hit_test_line_info.doc_page_info.page_count = 0;
    hit_test_line_info.doc_page_info.page_index = 0;
    
    hit_test_line_info.component_id = (TSDK_E_COMPONENT_ID)_currentDataShareTypeId;
    
    CGFloat hScale = [self heightScale];
    CGFloat wScale = [self widthScale];
    hit_test_line_info.start_point.x = (TSDK_INT32)startPoint.x * wScale;
    hit_test_line_info.start_point.y = (TSDK_INT32)startPoint.y * hScale;
    
    hit_test_line_info.end_point.x = (TSDK_INT32)endPoint.x * wScale;
    hit_test_line_info.end_point.y = (TSDK_INT32)endPoint.y * hScale;
    
    hit_test_line_info.hit_test_mode = TSDK_E_ANNOTATION_HIT_TEST_SOMEONE;
    
    strcpy(hit_test_line_info.user_number, [self.selfJoinNumber UTF8String]);
    
    TSDK_UINT32 *selectedIds = NULL;
    
    TSDK_UINT32 idsCount = 0;
    
    TSDK_RESULT result = tsdk_annotation_hit_test_line(_confHandle, &hit_test_line_info, &selectedIds, &idsCount);
    DDLogInfo(@"tsdk_annotation_hit_test_line: %d", result);
    
    if (selectedIds && idsCount > 0) {
        TSDK_S_ANNOTATION_DELETE_INFO delete_info;
        delete_info.annotation_id_list = selectedIds;
        delete_info.count = idsCount;
        delete_info.doc_page_info.component_id = (TSDK_E_COMPONENT_ID)_currentDataShareTypeId;
        delete_info.doc_page_info.document_id = 0;
        delete_info.doc_page_info.page_count = 0;
        delete_info.doc_page_info.page_index = 0;
        
        delete_info.component_id = (TSDK_E_COMPONENT_ID)_currentDataShareTypeId;
        
        result = tsdk_annotation_delete_annotation(_confHandle, &delete_info);
        DDLogInfo(@"Annotation tsdk_annotation_delete_annotation: %d", result);
    }
}

- (void)conferenceEraseAnnotationAtLocation:(CGPoint)location {
    
    CGFloat scale = [self widthScale];
    CGPoint scaledLocation = CGPointMake(location.x * scale, location.y * scale);
    
    const CGFloat cgRectSideHalf = 5; //5 points in CG coordinate space as a half of the rectangle's side
    TSDK_INT32 tupRectSideHalf = (TSDK_INT32)(cgRectSideHalf * [self widthScale]); //same in TUP's coordinate space
    TSDK_S_POINT rectCenter = CG2TCPoint(scaledLocation);
    TSDK_INT32 minX = rectCenter.x - tupRectSideHalf;
    TSDK_INT32 minY = rectCenter.y - tupRectSideHalf;
    TSDK_INT32 maxX = rectCenter.x + tupRectSideHalf;
    TSDK_INT32 maxY = rectCenter.y + tupRectSideHalf;
    TSDK_S_RECTANGULAR rect = { .left = minX, .top = minY, .right = maxX, .bottom = maxY };
    [self conferenceEraseAnnotationsInRect:rect];
}


- (void)conferenceEraseAllAnnotations {
    TSDK_S_RECTANGULAR rect = { .left = 0, .top = 0, .right = (TSDK_INT32)INT_MAX, .bottom = (TSDK_INT32)INT_MAX };
    [self conferenceEraseAnnotationsInRect:rect];
}

- (void)conferenceEraseAnnotationsInRect:(TSDK_S_RECTANGULAR)rect {
    TSDK_UINT32 *selectedIds = NULL;
    TSDK_UINT32 idsCount = 0;
    TSDK_S_ANNOTATION_HIT_TEST_RECT_INFO hit_test_rect_info;
    hit_test_rect_info.doc_page_info.component_id = (TSDK_E_COMPONENT_ID)_currentDataShareTypeId;
    if (_currentDataShareTypeId == TSDK_E_COMPONENT_AS) {
        hit_test_rect_info.doc_page_info.document_id = 0;
        hit_test_rect_info.doc_page_info.page_count = 0;
        hit_test_rect_info.doc_page_info.page_index = 0;
    }
    hit_test_rect_info.hit_test_mode = TSDK_E_ANNOTATION_HIT_TEST_SOMEONE;
    hit_test_rect_info.rectangle_area.bottom = rect.bottom;
    hit_test_rect_info.rectangle_area.left = rect.left;
    hit_test_rect_info.rectangle_area.right = rect.right;
    hit_test_rect_info.rectangle_area.top = rect.top;
    strcpy(hit_test_rect_info.user_number, [self.selfJoinNumber UTF8String]);
    
    hit_test_rect_info.component_id = (TSDK_E_COMPONENT_ID)_currentDataShareTypeId;
    
    TSDK_RESULT result = tsdk_annotation_hit_test_rect(_confHandle, &hit_test_rect_info, &selectedIds, &idsCount);
    
    DDLogInfo(@"Annotation eraseAnnotationsInRect: tsdk_annotation_hit_test_rect returns: %d", result);
    
    if (selectedIds && idsCount > 0) {
        TSDK_S_ANNOTATION_DELETE_INFO delete_info;
        delete_info.annotation_id_list = selectedIds;
        delete_info.count = idsCount;
        delete_info.doc_page_info.component_id = (TSDK_E_COMPONENT_ID)_currentDataShareTypeId;
        delete_info.doc_page_info.document_id = 0;
        delete_info.doc_page_info.page_count = 0;
        delete_info.doc_page_info.page_index = 0;
        
        delete_info.component_id = (TSDK_E_COMPONENT_ID)_currentDataShareTypeId;
        
        result = tsdk_annotation_delete_annotation(_confHandle, &delete_info);
        DDLogInfo(@"Annotation eraseAnnotationsInRect: tsdk_annotation_delete_annotation returns: %d", result);
    }
}

/**
 * This method is used to set video window local view
 * 设置视频本地窗口画面
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
- (BOOL)setVideoWindowWithLocal:(id)localVideoView
                         andRemote:(id)remoteVideoView
{
    
    TSDK_S_VIDEO_WND_INFO videoInfo[2];
    memset_s(videoInfo, sizeof(TSDK_S_VIDEO_WND_INFO) * 2, 0, sizeof(TSDK_S_VIDEO_WND_INFO) * 2);
    videoInfo[0].video_wnd_type = TSDK_E_VIDEO_WND_LOCAL;
    videoInfo[0].render = (TSDK_UPTR)localVideoView;
    videoInfo[0].display_mode = TSDK_E_VIDEO_WND_DISPLAY_CUT;
    
    
    videoInfo[1].video_wnd_type = TSDK_E_VIDEO_WND_REMOTE;
    videoInfo[1].render = (TSDK_UPTR)remoteVideoView;
    videoInfo[1].display_mode = TSDK_E_VIDEO_WND_DISPLAY_CUT;
    TSDK_RESULT ret;
    ret = tsdk_set_video_window((TSDK_UINT32)self.currentCallId, 2, videoInfo);
    DDLogInfo(@"Call_Log: tsdk_set_video_window = %d",ret);
    
    [[ManagerService callService] updateVideoRenderInfoWithVideoIndex:CameraIndexFront withRenderType:TsdkVideoWindowlacal andCallId:self.currentCallId];
    [[ManagerService callService] updateVideoRenderInfoWithVideoIndex:CameraIndexFront withRenderType:TsdkVideoWindowRemote andCallId:self.currentCallId];
    return (TSDK_SUCCESS == ret);
}

- (BOOL)setSvcVideoWindowWithLocal:(id)localVideoView
{
    TSDK_RESULT ret = TSDK_UNKNOWN_ERR;
    
    if (localVideoView != nil) {
        TSDK_S_VIDEO_WND_INFO videoInfo[1];
        memset_s(videoInfo, sizeof(TSDK_S_VIDEO_WND_INFO) * 1, 0, sizeof(TSDK_S_VIDEO_WND_INFO) * 1);
        videoInfo[0].video_wnd_type = TSDK_E_VIDEO_WND_LOCAL;
        videoInfo[0].render = (TSDK_UPTR)localVideoView;
        videoInfo[0].display_mode = TSDK_E_VIDEO_WND_DISPLAY_CUT;
        
        ret = tsdk_set_video_window((TSDK_UINT32)self.currentCallId, 1, videoInfo);
        DDLogInfo(@"Call_Log: tsdk_set_video_window = %d",ret);
    }
        
    [[ManagerService callService] updateVideoRenderInfoWithVideoIndex:CameraIndexFront withRenderType:TsdkVideoWindowlacal andCallId:self.currentCallId];
    [[ManagerService callService] updateVideoRenderInfoWithVideoIndex:CameraIndexFront withRenderType:TsdkVideoWindowRemote andCallId:self.currentCallId];
    
    return (TSDK_SUCCESS == ret);
}

- (BOOL)setSvcVideoWindowWithFirstSVCView:(id)firstSVCView
                            secondSVCView:(id)SecondSVCView
                             thirdSVCView:(id)thirdSVCView
                                   remote:(id)remoteSVCView
{
    
    TSDK_S_SVC_VIDEO_WND_INFO svcWindow[4];
    memset_s(svcWindow, sizeof(TSDK_S_SVC_VIDEO_WND_INFO) * 4, 0, sizeof(TSDK_S_SVC_VIDEO_WND_INFO) * 4);
    
    svcWindow[0].render = (TSDK_UPTR)remoteSVCView;
    svcWindow[0].label = [self.currentJoinConfIndInfo.svcLable[0] intValue];
    svcWindow[0].width = 960;
    svcWindow[0].height = 540;
    svcWindow[0].max_bandwidth = 1300;
    
    svcWindow[1].render = (TSDK_UPTR)firstSVCView;
    svcWindow[1].label = [self.currentJoinConfIndInfo.svcLable[1] intValue];
    svcWindow[1].width = 160;
    svcWindow[1].height = 90;
    svcWindow[1].max_bandwidth = 100;
    
    svcWindow[2].render = (TSDK_UPTR)SecondSVCView;
    svcWindow[2].label = [self.currentJoinConfIndInfo.svcLable[2] intValue];
    svcWindow[2].width = 160;
    svcWindow[2].height = 90;
    svcWindow[2].max_bandwidth = 100;
    
    svcWindow[3].render = (TSDK_UPTR)thirdSVCView;
    svcWindow[3].label = [self.currentJoinConfIndInfo.svcLable[3] intValue];
    svcWindow[3].width = 160;
    svcWindow[3].height = 90;
    svcWindow[3].max_bandwidth = 100;
    
    
    TSDK_RESULT ret;
    ret = tsdk_set_svc_video_window((TSDK_UINT32)self.currentCallId, 4, svcWindow);
    
    [[ManagerService callService] updateVideoRenderInfoWithVideoIndex:CameraIndexFront withRenderType:TsdkVideoWindowlacal andCallId:self.currentCallId];
    [[ManagerService callService] updateVideoRenderInfoWithVideoIndex:CameraIndexFront withRenderType:TsdkVideoWindowRemote andCallId:self.currentCallId];
    
    return (TSDK_SUCCESS == ret);
}

- (VideoStreamInfo *)getSignalDataInfo
{
    TSDK_S_SHARE_STATISTIC_INFO share_statistic_info;
    memset(&share_statistic_info, 0, sizeof(TSDK_S_SHARE_STATISTIC_INFO));
    tsdk_get_share_statistic_info(_confHandle, &share_statistic_info);
    
    VideoStreamInfo *videoStreamInfo = [[VideoStreamInfo alloc] init];
    videoStreamInfo.sendBitRate = share_statistic_info.send_bit_rate;
    videoStreamInfo.sendFrameSize = [NSString stringWithFormat:@"%u*%u",share_statistic_info.send_frame_size_width,share_statistic_info.send_frame_size_height];
    videoStreamInfo.sendFrameRate = share_statistic_info.send_frame_rate;
    videoStreamInfo.sendLossFraction = share_statistic_info.send_pkt_loss;
    videoStreamInfo.sendDelay = share_statistic_info.send_rtt;
    videoStreamInfo.sendJitter = share_statistic_info.send_jitter;
    videoStreamInfo.recvBitRate = share_statistic_info.recv_bit_rate;
    videoStreamInfo.recvFrameSize = [NSString stringWithFormat:@"%u*%u",share_statistic_info.recv_frame_size_width,share_statistic_info.recv_frame_size_height];
    videoStreamInfo.recvLossFraction = share_statistic_info.recv_pkt_loss;
    videoStreamInfo.recvFrameRate = share_statistic_info.recv_frame_rate;
    videoStreamInfo.recvDelay = share_statistic_info.recv_rtt;
    videoStreamInfo.recvJitter = share_statistic_info.recv_jitter;
    
    return videoStreamInfo;
    
}

@end
