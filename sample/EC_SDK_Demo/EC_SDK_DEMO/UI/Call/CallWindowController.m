//
//  CallWindowController.m
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//
#import "CallWindowController.h"
#import "ManagerService.h"
#import "EAGLView.h"
#import "NetworkUtils.h"
#import "DeviceMotionManager.h"
#import "CallSessionModifyInfo.h"
#import "DialSecondPlate.h"
#import "TransferView.h"
#import "CallEndView.h"
#import "EAGLView.h"
#import "CallTipView.h"
#import "CallView.h"
#import "CommonUtils.h"
#import "CallTakingViewController.h"
#import "AppDelegate.h"
#import "ConfBaseInfo.h"
#import "CallService.h"
#import "JoinConfIndInfo.h"

#import <ReplayKit/ReplayKit.h>

#import "CallStatisticInfo.h"
#import "SignalDataScrollView.h"
#import "StatisticShowInfo.h"
#import "ImageViewBtn.h"

#import "tsdk_manager_interface.h"
#import "tsdk_manager_def.h"

#import "ECSDKProgressHud.h"

#import "NSTimer+Extension.h"
#import "LoginCenter.h"

#define SCREEN_WIDTH MIN(self.callWindow.rootViewController.view.bounds.size.width, self.callWindow.rootViewController.view.bounds.size.height)
#define SCREEN_HIGHT MAX(self.callWindow.rootViewController.view.bounds.size.height, self.callWindow.rootViewController.view.bounds.size.width)

@interface CallWindowController ()<CallServiceDelegate,CallViewDelegate,DialSecondPlateDelegate,CallEndViewDelegate>
@property (nonatomic, strong)UIWindow *callWindow;
@property (nonatomic, strong)CallTakingViewController *talkingCtrl;
@property (nonatomic)EAGLView *remoteView;
@property (nonatomic)EAGLView *locationView;

@property (nonatomic)EAGLView *firstSVCView;
@property (nonatomic)EAGLView *secondSVCView;
@property (nonatomic)EAGLView *thirdSVCView;

@property (nonatomic)EAGLView *bfcpView;
@property (nonatomic)UIScrollView *baseScrollView;
@property (nonatomic,assign)BOOL isCallVideoOpeartionStatus;

@property (nonatomic,assign)BOOL isMuteMic;
@property (nonatomic,strong)CallInfo *currentTupCallInfo;
@property (nonatomic,assign)BOOL callTimeOut;
@property (nonatomic, assign) BOOL isCallTransToConf;
@property (nonatomic,assign)NSInteger volume;//[0-100]
@property (nonatomic, strong)NSMutableArray *callViewArray;
@property (nonatomic, strong)NSMutableArray *callInfoArray;
@property (nonatomic,assign)BOOL hasAddView;
@property (nonatomic ,assign) BOOL isJoinConfCall;
@property (nonatomic ,assign) BOOL isSetSVCWindow;
@property (nonatomic ,assign) BOOL isSetAVCWindow;
@property (nonatomic, assign) BOOL isFirstSetWindow;

@property (nonatomic, strong) ImageViewBtn *signalBtn;
@property (nonatomic, strong) UIView *signalBackView;
@property (nonatomic, strong) SignalDataScrollView *signalDataScrollView;

@property (nonatomic, strong) RPSystemBroadcastPickerView *broadcastPickerView API_AVAILABLE(ios(12.0));

@property (nonatomic, retain) NSTimer *timeOutTimer;
@property (nonatomic, assign) BOOL isStartTimer;


@property (nonatomic, assign) BOOL needSetActiveLocalIp;
@property (nonatomic, copy) NSString *currentLocalIp;

@end
static CallWindowController *g_windowCtrl = nil;
@implementation CallWindowController

+ (instancetype)shareInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        g_windowCtrl = [[CallWindowController alloc] init];
    });
    return g_windowCtrl;
}

- (id)init
{
    if (self = [super init]) {
        _callWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _callWindow.windowLevel = UIWindowLevelNormal + 2;
        _talkingCtrl = [[CallTakingViewController alloc] init];
        _callWindow.rootViewController = _talkingCtrl;
        
        [ManagerService callService].delegate = self;
        [CallEndView shareInstance].delegate = self;
        
        _isCallTransToConf = NO;
        _isCallVideoOpeartionStatus = NO;
        _cameraClose = NO;
        _cameraCaptureIndex = 1;
        _callTimeOut = YES;
        _isMuteMic = NO;
        _callViewArray = [[NSMutableArray alloc] init];
        _callInfoArray = [[NSMutableArray alloc] init];
        
        _remoteView = [EAGLView getRemoteView];
        _locationView = [EAGLView getLocalView];
        
        _firstSVCView = [EAGLView getFirstSVCView];
        _secondSVCView = [EAGLView getSecondSVCView];
        _thirdSVCView = [EAGLView getThirdSVCView];
        _bfcpView = [EAGLView getTupBFCPView];
        _hasAddView = NO;
        _isJoinConfCall = NO;
        _isSetSVCWindow = NO;
        _isSetAVCWindow = NO;
        _isFirstSetWindow = YES;
        
        _needSetLocalIp = NO;
        _needSetActiveLocalIp = NO;
        _currentLocalIp = @"0.0.0.0";
        
        [ECSDKProgressHud shareInstance];
        
        if (@available(iOS 12, *)) {
            CGRect broadcastPickerViewFrame = CGRectMake(0, 0, 100.0f, 100.0f);
            self.broadcastPickerView = [[RPSystemBroadcastPickerView alloc] initWithFrame:broadcastPickerViewFrame];
            [self.callWindow.rootViewController.view addSubview:_broadcastPickerView];
            self.broadcastPickerView.hidden = YES;
        }
        
        [self addNotify];
    }
    return self;
}

-(void)addNotify
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(networkStatusChangeNotify:)
                                                 name:NETWORK_STATUS_CHAGNE_NOTIFY
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appInactiveNotify:)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appActiveNotify:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(deviceMotionOrientationChanged)
                                                 name:ESPACE_DEVICE_ORIENTATION_CHANGED
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeCallViewNotify) name:TUP_CALL_REMOVE_CALL_VIEW_NOTIFY object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(confIcomingDeal:) name:EC_COMING_CONF_NOTIFY object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startReplayKitBroadcast) name:APP_START_SYSTEM_SHARE_VIEW object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(confShareRequestAction) name:CONF_SHARE_REQUEST_ACTION object:nil];
        
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateCallStatisticInfo:) name:CALL_STATISTIC_INFO_NOTIFY object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(releaseConfResources) name:CONF_QUITE_TO_CONFLISTVIEW object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(confResumeingAction) name:LOGIN_AND_CONF_RESUMING_NOTIFY object:nil];
    
}

- (void)confResumeingAction
{
    [self showResumeNotify];
    [self.timeOutTimer fireTimer];
}

- (void) showResumeNotify
{
    if (_isJoinConfCall) {
        [[ECSDKProgressHud shareInstance] makeProgressHUD:@"Poor network quality. Attempting to join the meeting again..." duration:4.0];
    }else{
        [[ECSDKProgressHud shareInstance] makeProgressHUD:@"Poor network quality. Attempting to login again..." duration:4.0];
    }
}

-(NSTimer *)timeOutTimer
{
    if (nil == _timeOutTimer) {
        _timeOutTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 count:30 callback:^{
            [ManagerService confService].hasConfResumedFirstRewatch = NO;
//            [self confAttendeeUpdateAction];
        }];
    }
    return _timeOutTimer;
}


- (void)releaseConfResources
{
    [[CallTipView shareInstance] removeCommingCallTipView];
    self.cameraClose = NO;
    [self.callWindow setHidden:YES];
    
    _isCallTransToConf = NO;
    _isCallVideoOpeartionStatus = NO;
    _cameraClose = NO;
    _cameraCaptureIndex = 1;
    _callTimeOut = YES;
    _isMuteMic = NO;
    _callViewArray = [[NSMutableArray alloc] init];
    _callInfoArray = [[NSMutableArray alloc] init];
    
//    [EAGLView destroyFirstSVCView];
//    [EAGLView destroySecondSVCView];
//    [EAGLView destroyThirdSVCView];
    
    
    //            _hasAddView = NO;
    _isJoinConfCall = NO;
    _isSetSVCWindow = NO;
    _isSetAVCWindow = NO;
    _isFirstSetWindow = YES;
    
    _currentTupCallInfo = nil;
}

- (void)confShareRequestAction
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [AppDelegate appConfShareRequestAction];
    });
}

- (void)startReplayKitBroadcast {
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        
        DDLogInfo(@"enter startReplayKitBroadcast ");
        if (@available(iOS 12, *)) {
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            BOOL isNeedSetpreferredExtension = [userDefaults boolForKey:@"ScreenShareFlag"];
            NSString *mainBundleId = [[NSBundle mainBundle]bundleIdentifier];
            NSString *extensionId = [mainBundleId stringByAppendingString:@".ScreenShareExtension"];
            if (isNeedSetpreferredExtension) {
                weakSelf.broadcastPickerView.preferredExtension = extensionId;
            }
            weakSelf.broadcastPickerView.showsMicrophoneButton = NO;
            
            for (UIView *view in weakSelf.broadcastPickerView.subviews) {
                if ([view isKindOfClass:[UIButton class]]) {
                    if (@available(iOS 13, *)) {
                        [(UIButton *)view sendActionsForControlEvents:UIControlEventTouchUpInside];
                    } else {
                        [(UIButton *)view sendActionsForControlEvents:UIControlEventTouchDown];
                    }
                }
            }
        }
    });
}

-(void)confIcomingDeal:(NSNotification *)notify
{
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary *resultDic = notify.userInfo;
        CallInfo *callInfo = resultDic[TUP_CONF_INCOMING_KEY];
        weakSelf.currentTupCallInfo = callInfo;
        weakSelf.isJoinConfCall = YES;
        
        TUP_CALL_TYPE callType = (TUP_CALL_TYPE)weakSelf.currentTupCallInfo.stateInfo.callType;
        NSString *commingCallNumber = [NSString stringWithFormat:@"%@",callInfo.stateInfo.callNum];
        [weakSelf.callWindow makeKeyAndVisible];
        [[CallTipView shareInstance] showCommingCallTipViewInUIView:weakSelf.callWindow.rootViewController.view delegate:weakSelf];
        [CallTipView shareInstance].callId = callInfo.stateInfo.callId;
        [CallTipView shareInstance].commingView.displayCallNumberLabel.text = commingCallNumber;
        [CallTipView shareInstance].commingView.currentCallType = callType;
        
    });
}

-(void)removeCallViewNotify
{
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
        
        [weakSelf removeCallView:[weakSelf getSelfCurrentConfId]];
        [weakSelf.callWindow setHidden:YES];
        weakSelf.isJoinConfCall = YES;
        
        weakSelf.firstSVCView = [EAGLView getFirstSVCView];
        weakSelf.secondSVCView = [EAGLView getSecondSVCView];
        weakSelf.thirdSVCView = [EAGLView getThirdSVCView];
        
        weakSelf.firstSVCView.currentlabel = 0;
        weakSelf.firstSVCView.currentAttendee = nil;
        weakSelf.secondSVCView.currentlabel = 0;
        weakSelf.secondSVCView.currentAttendee = nil;
        weakSelf.thirdSVCView.currentlabel = 0;
        weakSelf.secondSVCView.currentAttendee = nil;
        
        weakSelf.isFirstSetWindow = YES;
        
        [weakSelf updateVideoWindows];
        
        if (![ManagerService confService].hasConfResumedFirstRewatch) {
            [AppDelegate goConference];
        }
        
        BOOL isSuccess = [[ManagerService callService] switchCameraIndex:weakSelf.cameraCaptureIndex callId:[weakSelf getSelfCurrentConfId]];
        if (isSuccess) {
            [weakSelf deviceMotionOrientationChanged];
        }
        
    });
}

- (void)updateVideoWindows
{
    BOOL isSvcConf = [ManagerService confService].currentJoinConfIndInfo.isSvcConf;
    BOOL iSVideoConf = [ManagerService confService].currentJoinConfIndInfo.confMediaType == TSDK_E_CONF_MEDIA_VIDEO_DATA || [ManagerService confService].currentJoinConfIndInfo.confMediaType == TSDK_E_CONF_MEDIA_VIDEO;
    if (iSVideoConf) {
        [[DeviceMotionManager sharedInstance] startDeviceMotionManager];
        if (isSvcConf) {
            [[ManagerService confService] setSvcVideoWindowWithLocal:_locationView];
            [[ManagerService confService] setSvcVideoWindowWithFirstSVCView:_firstSVCView secondSVCView:_secondSVCView thirdSVCView:_thirdSVCView remote:_remoteView];
        }else{
            [[ManagerService confService] setVideoWindowWithLocal:_locationView andRemote:_remoteView];
        }
        
    }
}

-(void)networkStatusChangeNotify:(NSNotification *)notify
{
    NetworkStatus netStatus = (NetworkStatus)[[notify object] integerValue];
    
    if (netStatus == ECSNotReachable)
    {
        if (!_isJoinConfCall) {
            [[ManagerService callService] hangupAllCall];
            [self showMessage:@"Current network is unavailable"];
        }
//        [[ManagerService loginService] logout];
    }
    
    NSString *ip = [CommonUtils getLocalIpAddressWithIsVPN:[CommonUtils checkIsVPNConnect]];
    if ([ip isEqualToString:@"0.0.0.0"]) {
        [[ECSDKProgressHud shareInstance] makeProgressHUD:@"the network is disconnected" duration:2.0];
    }
    
    if (![ip isEqualToString:_currentLocalIp]) {
        _needSetActiveLocalIp = YES;
    }
    _currentLocalIp = ip;
    
    if ([UIApplication sharedApplication].applicationState != UIApplicationStateActive) {
        return;
    }
    
    if (![LoginCenter sharedInstance].isResuming) {
        
        
        //config local ip
        TSDK_S_LOCAL_ADDRESS local_ip;
        memset(&local_ip, 0, sizeof(TSDK_S_LOCAL_ADDRESS));
        
        strcpy(local_ip.ip_address, [ip UTF8String]);
        local_ip.is_try_resume = TSDK_TRUE;
        TSDK_RESULT configResult = tsdk_set_config_param(TSDK_E_CONFIG_LOCAL_ADDRESS, &local_ip);
        DDLogInfo(@"config local address result: %d; local ip is: %@", configResult, ip);
        
    }else{
        _needSetLocalIp = YES;
    }
        
}

- (void) appInactiveNotify:(NSNotification*) notify
{
    _needSetActiveLocalIp = NO;
    if ((_currentTupCallInfo.stateInfo.callType == CALL_VIDEO
        && _currentTupCallInfo.stateInfo.callState == CallStateTaking
        && !_cameraClose) || ([self getSelfCurrentConfId] != 0 && !_cameraClose)) {
        [[DeviceMotionManager sharedInstance] stopDeviceMotionManager];
    }

    [[ManagerService callService] controlVideoWhenApplicationResignActive:NO callId:[self getSelfCurrentConfId]];
}

- (void) appActiveNotify:(NSNotification*) notify
{
    if (_needSetActiveLocalIp) {
        //config local ip
        TSDK_S_LOCAL_ADDRESS local_ip;
        memset(&local_ip, 0, sizeof(TSDK_S_LOCAL_ADDRESS));
        NSString *ip = [CommonUtils getLocalIpAddressWithIsVPN:[CommonUtils checkIsVPNConnect]];
        DDLogInfo(@"tsdk_set_config_param,IP:%@",ip);
        strcpy(local_ip.ip_address, [ip UTF8String]);
        local_ip.is_try_resume = TSDK_TRUE;
        TSDK_RESULT configResult = tsdk_set_config_param(TSDK_E_CONFIG_LOCAL_ADDRESS, &local_ip);
        DDLogInfo(@"config local address result: %d; local ip is: %@", configResult, ip);
    }else{
        BOOL needAutoLogin = [CommonUtils getUserDefaultBoolValueWithKey:NEED_AUTO_LOGIN];
        ECSLoginServiceStatus status = [ManagerService loginService].serviceStatus;
        if (needAutoLogin && ECServiceLogin != status) {
            [AppDelegate startAutoLogin];
            [AppDelegate gotoRecentChatSessionView];
        }
    }
        
    if (_cameraClose) {
        return;
    }
    [[ManagerService callService] controlVideoWhenApplicationResignActive:YES callId:[self getSelfCurrentConfId]];
    if ((_currentTupCallInfo.stateInfo.callType == CALL_VIDEO
        && _currentTupCallInfo.stateInfo.callState == CallStateTaking
        && !_cameraClose) || [self getSelfCurrentConfId] != 0) {
        [[DeviceMotionManager sharedInstance] startDeviceMotionManager];
//        [CommonUtils setToOrientation:[DeviceMotionManager sharedInstance].lastOrientation];
        [self deviceMotionOrientationChanged];
    }
}

- (void)deviceMotionOrientationChanged
{
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        NSUInteger cameraRotation = 0;
        NSUInteger displayRotation = 0;
        
        if ([DeviceMotionManager sharedInstance].lastOrientation != UIDeviceOrientationFaceDown && [DeviceMotionManager sharedInstance].lastOrientation != UIDeviceOrientationFaceUp) {
            [CommonUtils setToOrientation:[DeviceMotionManager sharedInstance].lastOrientation];
        }
        
        
        if (_cameraClose) {
            return;
        }
        BOOL needAdjust = YES;
        if (weakSelf.isJoinConfCall) {
            needAdjust = [[DeviceMotionManager sharedInstance] conferenceAdjustCamerRotation:&cameraRotation displayRotation:&displayRotation byCamerIndex:weakSelf.cameraCaptureIndex interfaceOrientation:UIInterfaceOrientationPortrait];
        }else{
            needAdjust = [[DeviceMotionManager sharedInstance] adjustCamerRotation:&cameraRotation displayRotation:&displayRotation byCamerIndex:weakSelf.cameraCaptureIndex interfaceOrientation:UIInterfaceOrientationPortrait];
        }
        
        if ([UIApplication sharedApplication].applicationState != UIApplicationStateActive)
        {
            return ;
        }
        
        if (!needAdjust) {
            return;
        }
        
        //    if (![DeviceMotionManager sharedInstance].motionManager.isDeviceMotionAvailable) {
        //        return;
        //    }
        
        NSUInteger newCameraRotation = cameraRotation;
        NSUInteger newDisplayRotation = displayRotation;
        
        [[ManagerService callService] rotationCameraCapture:newCameraRotation callId:[weakSelf getSelfCurrentConfId]];
        
        [[ManagerService callService] rotationVideoDisplay:newDisplayRotation callId:[weakSelf getSelfCurrentConfId] isLocalWnd:YES];
        
        BOOL isLandscape = NO;
        if ([DeviceMotionManager sharedInstance].lastOrientation == UIDeviceOrientationLandscapeLeft || [DeviceMotionManager sharedInstance].lastOrientation == UIDeviceOrientationLandscapeRight) {
            isLandscape = YES;
        }
        [[ManagerService callService] updateVideoRenderInfoWithVideoIndex:CameraIndexFront withRenderType:TsdkVideoWindowlacal andCallId:[weakSelf getSelfCurrentConfId] isLandscape:isLandscape];
        
        [[ManagerService callService] rotationVideoDisplay:newDisplayRotation callId:[weakSelf getSelfCurrentConfId] isLocalWnd:NO];
        [[ManagerService callService] updateVideoRenderInfoWithVideoIndex:CameraIndexFront withRenderType:TsdkVideoWindowRemote andCallId:[weakSelf getSelfCurrentConfId] isLandscape:isLandscape];
        
    });
}

- (void)showStartCallView:(unsigned int)callId
{
    [self.callWindow makeKeyAndVisible];
    [[CallEndView shareInstance] showCallEndViewInUIView:self.callWindow.rootViewController.view];
    [CallEndView shareInstance].callId = callId;
}

- (int)getSelfCurrentConfId
{
    int callId = _currentTupCallInfo.stateInfo.callId;
    if (_isJoinConfCall) {
        callId =  [ManagerService confService].currentCallId;
    }
    return callId;
}

#pragma mark - About Call Callback
-(void)callEventCallback:(TUP_CALL_EVENT_TYPE)callEvent result:(NSDictionary *)resultDictionary
{
    switch (callEvent)
    {
        case CALL_CONNECT:
        {
            [self handleCallConnectEventWithResult:resultDictionary];
            break;
        }
        case CALL_INCOMMING:
        {
            [self handleCallIncommingEventWithResult:resultDictionary];
            break;
        }
        case CALL_RINGBACK:
        {
            __weak typeof(self) weakSelf = self;
            dispatch_async(dispatch_get_main_queue(), ^{
                BOOL isPlay = [resultDictionary[TSDK_CALL_RINGBACK_KEY] boolValue];
                if (isPlay)
                {
                    NSString *wavPath = [[NSBundle mainBundle] pathForResource:@"RingTone.wav"
                                                                        ofType:nil];
                    [[ManagerService callService] mediaStartPlayWithFile:wavPath];
                }
                else {
                    [weakSelf performSelector:@selector(delayStopRing) withObject:nil afterDelay:0.5];
                }
            });
            break;
        }
        case CALL_CLOSE:
        {
            [self handleCallCloseEvent:resultDictionary];
            break;
        }
        case CALL_DESTROY:
        {
            [[DeviceMotionManager sharedInstance] stopDeviceMotionManager];
//            [[CallTipView shareInstance] removeCommingCallTipView];
//            self.cameraClose = NO;
//            [self.callWindow setHidden:YES];
//
//            _isCallTransToConf = NO;
//            _isCallVideoOpeartionStatus = NO;
//            _cameraClose = NO;
//            _cameraCaptureIndex = 1;
//            _callTimeOut = YES;
//            _isMuteMic = NO;
//            _callViewArray = [[NSMutableArray alloc] init];
//            _callInfoArray = [[NSMutableArray alloc] init];
//
////
//            [EAGLView destroyFirstSVCView];
//            [EAGLView destroySecondSVCView];
//            [EAGLView destroyThirdSVCView];
////            _hasAddView = NO;
//            _isJoinConfCall = NO;
//            _isSetSVCWindow = NO;
//            _isSetAVCWindow = NO;
//            _isFirstSetWindow = YES;
//
//            _currentTupCallInfo = nil;
            
        }
            break;
        case CALL_VIEW_REFRESH:
        {
            
//            [self updateVideoWindows];

            break;
        }
        case CALL_UPGRADE_VIDEO_PASSIVE:
        {
            [self handleCallUpgrageVideoPassiveEventWithResult:resultDictionary];
            break;
        }
        case CALL_DOWNGRADE_VIDEO_PASSIVE:
        {
            _hasAddView = NO;
            NSString *callId = resultDictionary[CALL_ID];
            __weak typeof(self) weakSelf = self;
            dispatch_async(dispatch_get_main_queue(), ^{
                CallView *callView = [weakSelf callViewWithCallId:callId.intValue];
                CallInfo *callInfo = [weakSelf callInfoWithCallId:callId.intValue];
                callInfo.stateInfo.callType = CALL_AUDIO;
                callView.currentTupCallInfo = callInfo;
                [[DeviceMotionManager sharedInstance] stopDeviceMotionManager];
                [weakSelf removeGLViewInCallView:callView];
            });
            break;
        }
        case CALL_REFUSE_OPEN_VIDEO:
        {
            __weak typeof(self) weakSelf = self;
            NSString *callId = resultDictionary[CALL_ID];
            dispatch_async(dispatch_get_main_queue(), ^{
                CallView *callView = [weakSelf callViewWithCallId:callId.intValue];
                CallInfo *callInfo = [weakSelf callInfoWithCallId:callId.intValue];
                callInfo.stateInfo.callType = CALL_VIDEO;
                callView.currentTupCallInfo = callInfo;
                [[DeviceMotionManager sharedInstance] startDeviceMotionManager];
                [weakSelf addGLViewInCallView:callView];
            });
            break;
        }
        case CALL_HOLD_RESULT:
        {
            __weak typeof(self) weakSelf = self;
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString *callId = resultDictionary[CALL_ID];
                BOOL isHoldSuccess = [resultDictionary[TSDK_CALL_HOLD_RESULT_KEY] boolValue];
                CallView *currentCallView = [weakSelf callViewWithCallId:callId.intValue];
                currentCallView.isHold = isHoldSuccess;
                if (!isHoldSuccess)
                {
                    [weakSelf showMessage:@"Hold fail!"];
                }
            });
            break;
        }
        case CALL_UNHOLD_RESULT:
        {
            __weak typeof(self) weakSelf = self;
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString *callId = resultDictionary[CALL_ID];
                BOOL isUnHoldSuccess = [resultDictionary[TSDK_CALL_UNHOLD_RESULT_KEY] boolValue];
                CallView *currentCallView = [weakSelf callViewWithCallId:callId.intValue];
                currentCallView.isHold = !isUnHoldSuccess;
                if (!isUnHoldSuccess)
                {
                    [weakSelf showMessage:@"Unhold fail!"];
                }
            });
            break;
        }
        case CALL_TRANSFER_RESULT:
        {
            __weak typeof(self) weakSelf = self;
            dispatch_async(dispatch_get_main_queue(), ^{
                BOOL isTransferSuccess = [resultDictionary[TSDK_CALL_TRANSFER_RESULT_KEY] boolValue];
                if (isTransferSuccess)
                {
                    [weakSelf showMessage:@"Transfer success"];
                    return ;
                }
                [weakSelf showMessage:@"Transfer fail"];
            });
            break;
        }
        case CALL_DIVERT_FAILED:
        {
            __weak typeof(self) weakSelf = self;
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf showMessage:@"Divert transfer failed!"];
            });
            break;
        }
        default:
            break;
    }
}

-(void)handleCallConnectEventWithResult:(NSDictionary *)resultDictionary
{
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
        
        CallInfo *callInfo = resultDictionary[TSDK_CALL_INFO_KEY];
        weakSelf.currentTupCallInfo = callInfo;
        if (weakSelf.callInfoArray.count > 0)
        {
            BOOL isExist = NO;
            for (CallInfo *tempCallInfo in weakSelf.callInfoArray)
            {
                if (tempCallInfo.stateInfo.callId == callInfo.stateInfo.callId)
                {
                    isExist = YES;
                }
            }
            if (!isExist)
            {
                [weakSelf.callInfoArray addObject:callInfo];
            }
        }
        else
        {
            [weakSelf.callInfoArray addObject:callInfo];
        }
        
//        if (!callInfo.isFocus) {
            [weakSelf.callWindow makeKeyAndVisible];
            [weakSelf addCallView];
//        }
//        else {
//            [self removeCallView:_currentTupCallInfo.stateInfo.callId];
//            [self.callWindow setHidden:YES];
//        }
        
        if (weakSelf.currentTupCallInfo.stateInfo.callType == CALL_VIDEO) {
            [weakSelf setVideoWindow];
        }
        
        if (callInfo.stateInfo.callId == [CallTipView shareInstance].callId) {
            [[CallTipView shareInstance] removeCommingCallTipView];
            [CallTipView shareInstance].callId = 0;
        }
        
        weakSelf.callTimeOut = NO;
        [weakSelf performSelector:@selector(delayStopRing) withObject:nil afterDelay:0.5];
        
        if (callInfo.stateInfo.callId == [CallEndView shareInstance].callId) {
            [[CallEndView shareInstance] removeCallEndView];
            [CallEndView shareInstance].callId = 0;
        }
    });
}

-(void)handleCallIncommingEventWithResult:(NSDictionary *)resultDictionary
{
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        CallInfo *callInfo = resultDictionary[TSDK_CALL_INFO_KEY];
        weakSelf.currentTupCallInfo = callInfo;
        weakSelf.isJoinConfCall = NO;
//        if (callInfo.isFocus) {
//            [self clickCommingTipViewButton:ANSWER_COMMING_CALL];
//            return ;
//        }
        
        TUP_CALL_TYPE callType = (TUP_CALL_TYPE)weakSelf.currentTupCallInfo.stateInfo.callType;
        NSString *commingCallNumber = [NSString stringWithFormat:@"%@",callInfo.stateInfo.callNum];
        [weakSelf.callWindow makeKeyAndVisible];
        [[CallTipView shareInstance] showCommingCallTipViewInUIView:weakSelf.callWindow.rootViewController.view delegate:weakSelf];
        [CallTipView shareInstance].callId = callInfo.stateInfo.callId;
        [CallTipView shareInstance].commingView.displayCallNumberLabel.text = commingCallNumber;
        [CallTipView shareInstance].commingView.currentCallType = callType;
        NSString *wavPath = [[NSBundle mainBundle] pathForResource:@"RingTone.wav"
                                                            ofType:nil];
        [[ManagerService callService] mediaStartPlayWithFile:wavPath];
        DDLogInfo(@"Call_log: have a new call , type is %i, number is %@, callid: %d",callInfo.stateInfo.callType,commingCallNumber,callInfo.stateInfo.callId);
    });
}

-(void)handleCallUpgrageVideoPassiveEventWithResult:(NSDictionary *)resultDictionary
{
    NSString *callId = resultDictionary[CALL_ID];
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:@"Upgrade to video call" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *refuseAction = [UIAlertAction actionWithTitle:@"Refuse" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [[ManagerService callService] replyAddVideoCallIsAccept:NO callId:callId.intValue];
        }];
        UIAlertAction *answerAction = [UIAlertAction actionWithTitle:@"Answer" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [[ManagerService callService] replyAddVideoCallIsAccept:YES callId:callId.intValue];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                CallView *callView = [weakSelf callViewWithCallId:callId.intValue];
                CallInfo *callInfo = [weakSelf callInfoWithCallId:callId.intValue];
                callInfo.stateInfo.callType = CALL_VIDEO;
                callView.currentTupCallInfo = callInfo;
                [[DeviceMotionManager sharedInstance] startDeviceMotionManager];
                [weakSelf addGLViewInCallView:callView];
            });
            
        }];
        [alertController addAction:refuseAction];
        [alertController addAction:answerAction];
        [weakSelf.callWindow.rootViewController presentViewController:alertController animated:YES completion:nil];
    });
}

-(void)handleCallCloseEvent:(NSDictionary *)resultDic
{
    CallInfo *callInfo = resultDic[TSDK_CALL_INFO_KEY];
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
        [weakSelf performSelector:@selector(delayStopRing) withObject:nil afterDelay:0.5];
        [weakSelf removeCallView:callInfo.stateInfo.callId];
        if (weakSelf.callInfoArray.count > 0)
        {
            NSMutableArray *tempMutArray = [NSMutableArray arrayWithArray:weakSelf.callInfoArray];
            for (CallInfo *tempCallInfo in tempMutArray)
            {
                DDLogInfo(@"_callInfoArray tempCallInfo : %d",tempCallInfo.stateInfo.callId);
                if (tempCallInfo.stateInfo.callId == callInfo.stateInfo.callId)
                {
                    DDLogInfo(@"_callInfoArray removeObject : %d",tempCallInfo.stateInfo.callId);
                    [weakSelf.callInfoArray removeObject:tempCallInfo];
                }
            }
        }
        
        if (callInfo.stateInfo.callId == [weakSelf getSelfCurrentConfId]) {
            if (weakSelf.callInfoArray.count > 0)
            {
                weakSelf.currentTupCallInfo = weakSelf.callInfoArray.lastObject;
                CallView *currentCallView = [weakSelf callViewWithCallId:[weakSelf getSelfCurrentConfId]];
                [[ManagerService callService] unHoldCallWithCallId:[weakSelf getSelfCurrentConfId]];
                [weakSelf.callWindow.rootViewController.view bringSubviewToFront:currentCallView];
                weakSelf.talkingCtrl.orientation = currentCallView.showOrient;
                [CommonUtils setToOrientation:(UIDeviceOrientation)currentCallView.showOrient];
            }
        }
        
        if (weakSelf.callInfoArray.count == 0) {
            weakSelf.currentTupCallInfo = nil;
            DDLogInfo(@"_callInfoArray removeAllObjects");
            weakSelf.talkingCtrl.orientation = UIInterfaceOrientationPortrait;
            if (UIDeviceOrientationPortrait != [[UIDevice currentDevice] orientation])
            {
                [[UIDevice currentDevice] setValue:[NSNumber numberWithInt:UIDeviceOrientationPortrait] forKey:@"orientation"];
            }
//            [CommonUtils setToOrientation:UIDeviceOrientationPortrait];
            [weakSelf.callWindow setHidden:YES];
        }
        
        weakSelf.isCallTransToConf = NO;
        
        if ([CallTipView shareInstance].callId == callInfo.stateInfo.callId) {
            [[CallTipView shareInstance] removeCommingCallTipView];
            [CallTipView shareInstance].callId = 0;
        }
        else {
            [weakSelf.callWindow.rootViewController.view bringSubviewToFront:[CallTipView shareInstance].commingView];
        }
        
        if ([CallEndView shareInstance].callId == callInfo.stateInfo.callId) {
            [[CallEndView shareInstance] removeCallEndView];
            [CallEndView shareInstance].callId = 0;
        }
        else {
            [weakSelf.callWindow.rootViewController.view bringSubviewToFront:[CallEndView shareInstance]];
        }
        
        [[DeviceMotionManager sharedInstance] stopDeviceMotionManager];
        weakSelf.isCallVideoOpeartionStatus = NO;
//        _cameraClose = YES;
        weakSelf.cameraCaptureIndex = 1;
        weakSelf.hasAddView = NO;
        
    });
}

-(void)removeCallView:(unsigned int)callId
{
    CallView *callView = [self callViewWithCallId:callId];
    if (callView)
    {
        [_signalBtn removeFromSuperview];
        [_signalBackView removeFromSuperview];
        _signalBackView = nil;
        [_callViewArray removeObject:callView];
        [callView removeFromSuperview];
    }
}
-(void)addCallView
{
    CallView *currentCallView = [self obtainCurrentCallView];
    if (!currentCallView)
    {
        DDLogInfo(@"addCallView");
        CallView *callView = [[CallView alloc] init];
        callView.frame = self.callWindow.bounds;
        callView.tag = [self getSelfCurrentConfId];
        callView.delegate = self;
        callView.currentTupCallInfo = _currentTupCallInfo;
        [self.callWindow.rootViewController.view addSubview:callView];
        [_callViewArray addObject:callView];
        BOOL isVideo = _currentTupCallInfo.stateInfo.callType ;
        
        if (isVideo)
        {
            _cameraClose = NO;
//            callView.showOrient = ((1 == _currentTupCallInfo.orientType) ? UIInterfaceOrientationPortrait : UIInterfaceOrientationLandscapeRight);
            [[ManagerService callService] switchCameraIndex:_cameraCaptureIndex callId:[self getSelfCurrentConfId]];
            callView.showOrient = UIInterfaceOrientationPortrait;
            [self addGLViewInCallView:callView];
            [[DeviceMotionManager sharedInstance] startDeviceMotionManager];
            _talkingCtrl.orientation = callView.showOrient;
            [self deviceMotionOrientationChanged];
            
            
        }
        
        [callView addSubview:self.signalBackView];
        [callView addSubview:self.signalBtn];
        
    }
}

-(void)addGLViewInCallView:(CallView *)callView
{
    DDLogInfo(@"addGLViewInCallView");
    // video remote view
    [_locationView removeFromSuperview];
    [_remoteView removeFromSuperview];
    
    _baseScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    _baseScrollView.pagingEnabled = YES;
    _baseScrollView.showsHorizontalScrollIndicator = NO;
    _baseScrollView.showsVerticalScrollIndicator = NO;
    
    _remoteView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    _remoteView.tag = callView.tag+1;
    _remoteView.hidden = NO;
    
    // video local view
    _locationView.tag = callView.tag +2;
    _locationView.frame = CGRectMake([UIScreen mainScreen].bounds.size.width - 100, 0, 100, 150);;
    _locationView.hidden = NO;
    
    [_remoteView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    [_locationView setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin];
    [_baseScrollView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    
    
    [callView addSubview:_baseScrollView];
    [_baseScrollView addSubview:_remoteView];
    [_baseScrollView sendSubviewToBack:_remoteView];
    [callView sendSubviewToBack:callView.tipLabel];
    
    [_baseScrollView insertSubview:_locationView aboveSubview:_remoteView];
    [callView insertSubview:callView.toolBarView aboveSubview:_baseScrollView];
    [callView insertSubview:callView.switchCameraButton aboveSubview:_baseScrollView];
    [callView insertSubview:callView.closeCameraButton aboveSubview:_baseScrollView];
}

-(void)removeGLViewInCallView:(CallView *)callView
{
    DDLogInfo(@"removeGLViewInCallView");
    UIView *subRemoteView = [callView viewWithTag:callView.tag +1];
    [subRemoteView removeFromSuperview];
    UIView *subLocalView = [callView viewWithTag:callView.tag +2];
    [subLocalView removeFromSuperview];
}

-(CallView *)obtainCurrentCallView
{
    return [self callViewWithCallId:[self getSelfCurrentConfId]];
}

- (CallInfo *)callInfoWithCallId:(unsigned int)callId
{
    __block CallInfo *info = nil;
    [_callInfoArray enumerateObjectsUsingBlock:^(CallInfo *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.stateInfo.callId == callId) {
            info = obj;
            *stop = YES;
        }
    }];
    return info;
}

- (CallView *)callViewWithCallId:(unsigned int)callId;
{
    if (_callViewArray.count > 0)
    {
        for (CallView *tempCallView in _callViewArray)
        {
            DDLogInfo(@"CallView tag: %ld",(long)tempCallView.tag);
            if (tempCallView.tag == callId)
            {
                return tempCallView;
            }
        }
        return nil;
    }
    else
    {
        return nil;
    }
}

#pragma mark - Call incomming delegate
-(void)clickCommingTipViewButton:(COMMING_VIEW_BTNACTION_TYPE)actionType
{
    switch (actionType)
    {
        case TRANSFER_CALL:
        {
            if (_callInfoArray.count >1)
            {
                [self showMessage:@"Current can't transfer call"];
                return;
            }
            [[TransferView shareInstanced] showTransferView:self.callWindow.rootViewController.view oKBlock:^(NSString *number) {
                BOOL isSuccess = [[ManagerService callService] divertCallWithNumber:number callId:[self getSelfCurrentConfId]];
                NSString *tipTitle = isSuccess ? @"Transfer success!" : @"Transfer fail";
                [self showMessage:tipTitle];
            }];
            break;
        }
        case AUDIO_ANSWER_COMMING_CALL:
        {
            if (_isJoinConfCall) {
                [[ManagerService confService] acceptConfCallIsJoinVideoConf:NO];
            }else{
                [[ManagerService callService] answerComingCallType:CALL_AUDIO callId:[self getSelfCurrentConfId]];
            }
            
            break;
        }
        case VIDEO_ANSWER_COMMING_CALL:
        {
            if (_isJoinConfCall) {
                [[ManagerService confService] acceptConfCallIsJoinVideoConf:YES];
            }else{
                [[ManagerService callService] answerComingCallType:CALL_VIDEO callId:[self getSelfCurrentConfId]];
            }
            
            if (self.currentTupCallInfo.stateInfo.callType == CALL_VIDEO) {
                _cameraClose = NO;
//                [self setVideoWindow];
            }
            
            break;
        }
        case REFUSE_COMMING_CALL:
        {
            if (_isJoinConfCall) {
                [[ManagerService confService] rejectConfCall];
            }else{
                [[ManagerService callService] closeCall:[self getSelfCurrentConfId]];
            }
            
            break;
        }
    }
    [self performSelector:@selector(delayStopRing) withObject:nil afterDelay:0.5];
}

-(void)delayStopRing
{
    [[ManagerService callService] mediaStopPlay];
}

- (void)setVideoWindow
{
    [[ManagerService callService] updateVideoWindowWithLocal:_locationView
                                                   andRemote:_remoteView
                                                     andBFCP:_bfcpView
                                                      callId:[self getSelfCurrentConfId]];
}

#pragma mark - CallView Delegate
-(void)clickCallToolBarType:(CALL_TOOLBAR_BUTTON_TYPE)type callViewTag:(NSInteger)callViewTag
{
    CallView *currentCallView = nil;
    for (CallView *tempCallView in _callViewArray)
    {
        if (tempCallView.tag == callViewTag)
        {
            currentCallView = tempCallView;
        }
    }
    
    CallInfo *callInfo = currentCallView.currentTupCallInfo;
    switch (type)
    {
        case CLOSE_CALL_BUTTON:
        {
            [[ManagerService callService] closeCall:callInfo.stateInfo.callId];
            
            break;
        }
        case CHANGE_CALL_TYPE_BUTTON:
        {
            _isCallVideoOpeartionStatus = YES;
            if (callInfo.stateInfo.callType == CALL_AUDIO)
            {
                _cameraClose = NO;
                
                [self setVideoWindow];
                
                [[ManagerService callService] upgradeAudioToVideoCallWithCallId:callInfo.stateInfo.callId];
            }
            if (self.currentTupCallInfo.stateInfo.callType == CALL_VIDEO)
            {
                [[ManagerService callService] downgradeVideoToAudioCallWithCallId:callInfo.stateInfo.callId];
            }
            break;
        }
        case SWITCH_CAMERA_BUTTON:
        {
            if (_cameraClose)
            {
                [self showMessage:@"Camera have been close"];
                return;
            }
            _cameraCaptureIndex = _cameraCaptureIndex == 1 ? 0 : 1;
            [[ManagerService callService] switchCameraIndex:_cameraCaptureIndex callId:callInfo.stateInfo.callId];
            [self deviceMotionOrientationChanged];
            break;
        }
        case  CLOSE_CAMERA_BUTTON:
        {
            _cameraClose = !_cameraClose;
            currentCallView.isCameraClose = _cameraClose;
            [[ManagerService callService] switchCameraOpen:!_cameraClose callId:callInfo.stateInfo.callId];
            [self deviceMotionOrientationChanged];
            break;
        }
        case MUTE_MIC_BUTTON:
        {
            _isMuteMic = !_isMuteMic;
            [[ManagerService callService] muteMic:_isMuteMic callId:callInfo.stateInfo.callId];
            currentCallView.isMuteMic = _isMuteMic;
            break;
        }
        case DIAL_NUMBER_BUTTON:
        {
            [[DialSecondPlate shareInstance] showViewInSuperView:[self obtainCurrentCallView] Delegate:self];
            break;
        }
        case ROUTE_BUTTON:
        {
            ROUTE_TYPE routeType = [[ManagerService callService] obtainMobileAudioRoute];
            ROUTE_TYPE configType = routeType == ROUTE_LOUDSPEAKER_TYPE ? ROUTE_DEFAULT_TYPE : ROUTE_LOUDSPEAKER_TYPE;
            [[ManagerService callService] configAudioRoute:configType];
            currentCallView.isloudSpeak = configType == ROUTE_LOUDSPEAKER_TYPE ? YES : NO;
            break;
        }
        case HOLD_BUTTON:
        {
            if (currentCallView.isHold)
            {
                [[ManagerService callService] unHoldCallWithCallId:callInfo.stateInfo.callId];
            }
            else
            {
                [[ManagerService callService] holdCallWithCallId:callInfo.stateInfo.callId];
            }
            break;
        }
        case TRANSFER_BUTTON:
        {
            [self transferButtonActionWithCallId:callInfo.stateInfo.callId];
            break;
        }
        default:
            break;
    }
}



#pragma mark - DialSecondDelegate
-(void)clickDialSecondPlate:(NSString *)string
{
    [[ManagerService callService] sendDTMFWithDialNum:string callId:[self getSelfCurrentConfId]];
}


#pragma mark - call end view delegate
-(void)transferButtonActionWithCallId:(int)callId
{
    [[TransferView shareInstanced] showTransferView:self.callWindow.rootViewController.view oKBlock:^(NSString *number) {
        BOOL isSuccess = [[ManagerService callService] blindTransferWithNumber:number callId:callId];
        if (isSuccess)
        {
            [self showMessage:@"Transfer success!"];
            return ;
        }
        [self showMessage:@"Transfer fail!"];
    }];
}

-(void)showMessage:(NSString *)msg
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:msg preferredStyle:UIAlertControllerStyleAlert];
    [self.callWindow.rootViewController presentViewController:alert animated:NO completion:nil];
    [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(creatAlert:) userInfo:alert repeats:NO];
}

- (void)creatAlert:(NSTimer *)timer
{
    UIAlertController *alert = [timer userInfo];
    [alert dismissViewControllerAnimated:YES completion:nil];
    alert = nil;
}

- (void)transferButtonAction {
    
}

- (SignalDataScrollView *)signalDataScrollView
{
    if (nil == _signalDataScrollView) {
        _signalDataScrollView = [[SignalDataScrollView alloc] initWithFrame:CGRectMake(0, 0, 365, 365)];
    }
    return _signalDataScrollView;
}

-(UIView *)signalBackView
{
    if (nil == _signalBackView) {
        
        _signalBackView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 365, 365)];
        _signalBackView.center = CGPointMake(SCREEN_WIDTH/2, SCREEN_HIGHT/2);
        //            _signalBackView.backgroundColor = [UIColor blackColor];
        //            _signalBackView.alpha = 0.5;
        _signalBackView.hidden = YES;
        [_signalBackView addSubview:self.signalDataScrollView];
        
        
    }
    return _signalBackView;
}

- (ImageViewBtn *)signalBtn
{
    if (nil == _signalBtn) {
        _signalBtn = [[ImageViewBtn alloc] initWithFrame: CGRectMake(22, 117, 30 , 30)];
        _signalBtn.contentMode = UIViewContentModeScaleAspectFill;
        [_signalBtn setImage:[UIImage imageNamed:@"signal_1"] forState:UIControlStateNormal];
        [_signalBtn addTarget:self action:@selector(signalBtnAction) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _signalBtn;
}

- (void)signalBtnAction
{
    _signalBackView.hidden = !_signalBackView.hidden;
}

- (void)updateCallStatisticInfo:(NSNotification *)notification
{
    CallStatisticInfo *callInfo = notification.userInfo[CALL_STATISTIC_INFO];
    [self updatesignalImageWithSignalStrength:callInfo.signalStrength];
    AudioStreamInfo *audioStreamInfo = callInfo.audioStreamInfo;
    
    NSMutableArray *audioInfoArray = [[NSMutableArray alloc] init];
    
    StatisticShowInfo *locallSendInfo = [[StatisticShowInfo alloc] init];
    locallSendInfo.name = @"local send";
    locallSendInfo.bandWidth = audioStreamInfo.sendBitRate;
    locallSendInfo.lossFraction = audioStreamInfo.sendLossFraction;
    locallSendInfo.delay = audioStreamInfo.sendDelay;
    locallSendInfo.jitter = audioStreamInfo.sendJitter;
    StatisticShowInfo *localRecvInfo = [[StatisticShowInfo alloc] init];
    localRecvInfo.name = @"local recv";
    localRecvInfo.bandWidth = audioStreamInfo.recvBitRate;
    localRecvInfo.lossFraction = audioStreamInfo.recvLossFraction;
    localRecvInfo.delay = audioStreamInfo.recvDelay;
    localRecvInfo.jitter = audioStreamInfo.recvJitter;
    
    [audioInfoArray addObject:locallSendInfo];
    [audioInfoArray addObject:localRecvInfo];
    self.signalDataScrollView.audioInfoArray = [NSArray arrayWithArray:audioInfoArray];
    
    NSMutableArray *videoInfoArray = [[NSMutableArray alloc] init];
    
    if (callInfo.isSvcConf) {
        NSArray *currentMutiStream = [NSArray arrayWithArray:callInfo.svcStreamInfoArray];
        int localNumber = 1;
        for (int i = 0 ; i < callInfo.svcStreamCount; i ++) {
            VideoStreamInfo *videoSingleStream = currentMutiStream[i];
            if (videoSingleStream.sendBitRate != 0) {
                StatisticShowInfo *videoLocallSendInfo = [[StatisticShowInfo alloc] init];
                videoLocallSendInfo.name = [NSString stringWithFormat:@"local send %d",localNumber];
                videoLocallSendInfo.bandWidth = videoSingleStream.sendBitRate/1000;
                videoLocallSendInfo.lossFraction = videoSingleStream.sendLossFraction;
                videoLocallSendInfo.delay = videoSingleStream.sendDelay;
                videoLocallSendInfo.jitter = videoSingleStream.sendJitter;
                videoLocallSendInfo.frameRate = videoSingleStream.sendFrameRate;
                videoLocallSendInfo.frameSize = videoSingleStream.sendFrameSize;
                
                [videoInfoArray addObject:videoLocallSendInfo];
                localNumber ++;
            }
        }
        for (int i = 0 ; i < callInfo.svcStreamCount; i ++) {
            VideoStreamInfo *videoSingleStream = currentMutiStream[i];
            if (videoSingleStream.recvBitRate != 0) {
                StatisticShowInfo *videoRecvInfo = [[StatisticShowInfo alloc] init];
                
                videoRecvInfo.bandWidth = videoSingleStream.recvBitRate/1000;
                videoRecvInfo.lossFraction = videoSingleStream.recvLossFraction;
                videoRecvInfo.delay = videoSingleStream.recvDelay;
                videoRecvInfo.jitter = videoSingleStream.recvJitter;
                videoRecvInfo.frameRate = videoSingleStream.recvFrameRate;
                videoRecvInfo.frameSize = videoSingleStream.recvFrameSize;
                
                EAGLView *firstSvcView = [EAGLView getFirstSVCView];
                EAGLView *secondSvcView = [EAGLView getSecondSVCView];
                EAGLView *thirdSvcView = [EAGLView getThirdSVCView];
                
                NSString *recvName = @"";
                if (firstSvcView.currentlabel == videoSingleStream.recvSsrcLabel) {
                    recvName = firstSvcView.currentAttendee.name;
                    if (recvName.length == 0) {
                        recvName = firstSvcView.currentAttendee.number;
                    }
                }else if (secondSvcView.currentlabel == videoSingleStream.recvSsrcLabel){
                    recvName = secondSvcView.currentAttendee.name;
                    if (recvName.length == 0) {
                        recvName = secondSvcView.currentAttendee.number;
                    }
                }else if (thirdSvcView.currentlabel == videoSingleStream.recvSsrcLabel){
                    recvName = thirdSvcView.currentAttendee.name;
                    if (recvName.length == 0) {
                        recvName = thirdSvcView.currentAttendee.number;
                    }
                }else{
                    
                }
                if (recvName.length > 0) {
                    videoRecvInfo.name = [NSString stringWithFormat:@"%@ recv",recvName];
                    [videoInfoArray addObject:videoRecvInfo];
                }
            }
        }
    }else{
        VideoStreamInfo *singleStream = callInfo.videoStreamInfo;
        StatisticShowInfo *videoLocallSendInfo = [[StatisticShowInfo alloc] init];
        videoLocallSendInfo.name = @"local send";
        videoLocallSendInfo.bandWidth = singleStream.sendBitRate/1000;
        videoLocallSendInfo.lossFraction = singleStream.sendLossFraction;
        videoLocallSendInfo.delay = singleStream.sendDelay;
        videoLocallSendInfo.jitter = singleStream.sendJitter;
        videoLocallSendInfo.frameRate = singleStream.sendFrameRate;
        videoLocallSendInfo.frameSize = singleStream.sendFrameSize;
        
        StatisticShowInfo *videoLocallRecvInfo = [[StatisticShowInfo alloc] init];
        videoLocallRecvInfo.name = @"local recv";
        videoLocallRecvInfo.bandWidth = singleStream.recvBitRate/1000;
        videoLocallRecvInfo.lossFraction = singleStream.recvLossFraction;
        videoLocallRecvInfo.delay = singleStream.recvDelay;
        videoLocallRecvInfo.jitter = singleStream.recvJitter;
        videoLocallRecvInfo.frameRate = singleStream.recvFrameRate;
        videoLocallRecvInfo.frameSize = singleStream.recvFrameSize;
        
        [videoInfoArray addObject:videoLocallSendInfo];
        [videoInfoArray addObject:videoLocallRecvInfo];
        
    }
    self.signalDataScrollView.videoInfoArray = [NSArray arrayWithArray:videoInfoArray];
    
    NSMutableArray *dataInfoArray = [[NSMutableArray alloc] init];
    if ([ManagerService confService].isStartScreenSharing) {
        VideoStreamInfo *dataStream = callInfo.dataStreamInfo;
        StatisticShowInfo *dataLocallSendInfo = [[StatisticShowInfo alloc] init];
        dataLocallSendInfo.name = @"local send";
        dataLocallSendInfo.bandWidth = dataStream.sendBitRate/1000;
        dataLocallSendInfo.lossFraction = dataStream.sendLossFraction;
        dataLocallSendInfo.delay = dataStream.sendDelay;
        dataLocallSendInfo.jitter = dataStream.sendJitter;
        dataLocallSendInfo.frameRate = dataStream.sendFrameRate;
        dataLocallSendInfo.frameSize = dataStream.sendFrameSize;
        
        StatisticShowInfo *dataLocallRecvInfo = [[StatisticShowInfo alloc] init];
        dataLocallRecvInfo.name = @"local recv";
        dataLocallRecvInfo.bandWidth = dataStream.recvBitRate/1000;
        dataLocallRecvInfo.lossFraction = dataStream.recvLossFraction;
        dataLocallRecvInfo.delay = dataStream.recvDelay;
        dataLocallRecvInfo.jitter = dataStream.recvJitter;
        dataLocallRecvInfo.frameRate = dataStream.recvFrameRate;
        dataLocallRecvInfo.frameSize = dataStream.recvFrameSize;
        
        [dataInfoArray addObject:dataLocallSendInfo];
        [dataInfoArray addObject:dataLocallRecvInfo];
        
        self.signalDataScrollView.dataInfoArray = [NSArray arrayWithArray:dataInfoArray];
    }
}

- (void)updatesignalImageWithSignalStrength:(NSInteger)signalStrength
{
    switch (signalStrength) {
        case 1:
            [_signalBtn setImage:[UIImage imageNamed:@"signal_1"] forState:UIControlStateNormal];
            break;
        case 2:
            [_signalBtn setImage:[UIImage imageNamed:@"signal_2"] forState:UIControlStateNormal];
            break;
        case 3:
            [_signalBtn setImage:[UIImage imageNamed:@"signal_3"] forState:UIControlStateNormal];
            break;
        case 4:
        case 5:
            [_signalBtn setImage:[UIImage imageNamed:@"signal_4"] forState:UIControlStateNormal];
            break;
            
        default:
            [_signalBtn setImage:[UIImage imageNamed:@"signal_1"] forState:UIControlStateNormal];
            break;
    }
    
}

@end
