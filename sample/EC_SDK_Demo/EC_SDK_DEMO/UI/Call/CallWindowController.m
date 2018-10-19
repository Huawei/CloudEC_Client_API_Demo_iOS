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

@interface CallWindowController ()<CallServiceDelegate,CallViewDelegate,DialSecondPlateDelegate,CallEndViewDelegate>
@property (nonatomic, strong)UIWindow *callWindow;
@property (nonatomic, strong)CallTakingViewController *talkingCtrl;
@property (nonatomic)EAGLView *remoteView;
@property (nonatomic)EAGLView *locationView;
@property (nonatomic)EAGLView *bfcpView;
@property (nonatomic)UIScrollView *baseScrollView;
@property (nonatomic,assign)BOOL isCallVideoOpeartionStatus;
@property (nonatomic,assign)NSInteger cameraCaptureIndex;
@property (nonatomic,assign)BOOL cameraClose;
@property (nonatomic,assign)BOOL isMuteMic;
@property (nonatomic,strong)CallInfo *currentTupCallInfo;
@property (nonatomic,assign)BOOL callTimeOut;
@property (nonatomic, assign) BOOL isCallTransToConf;
@property (nonatomic,assign)NSInteger volume;//[0-100]
@property (nonatomic, strong)NSMutableArray *callViewArray;
@property (nonatomic, strong)NSMutableArray *callInfoArray;
@property (nonatomic,assign)BOOL hasAddView;
@property (nonatomic ,assign) BOOL isJoinConfCall;
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
        _cameraClose = YES;
        _cameraCaptureIndex = 1;
        _callTimeOut = YES;
        _isMuteMic = NO;
        _callViewArray = [[NSMutableArray alloc] init];
        _callInfoArray = [[NSMutableArray alloc] init];
        
        _remoteView = [EAGLView getRemoteView];
        _locationView = [EAGLView getLocalView];
        _bfcpView = [EAGLView getTupBFCPView];
        _hasAddView = NO;
        _isJoinConfCall = NO;
        
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
    
}

-(void)confIcomingDeal:(NSNotification *)notify
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary *resultDic = notify.userInfo;
        CallInfo *callInfo = resultDic[TUP_CONF_INCOMING_KEY];
        _currentTupCallInfo = callInfo;
        _isJoinConfCall = YES;
        
        
        TUP_CALL_TYPE callType = (TUP_CALL_TYPE)self.currentTupCallInfo.stateInfo.callType;
        NSString *commingCallNumber = [NSString stringWithFormat:@"%@",callInfo.stateInfo.callNum];
        [self.callWindow makeKeyAndVisible];
        [[CallTipView shareInstance] showCommingCallTipViewInUIView:self.callWindow.rootViewController.view delegate:self];
        [CallTipView shareInstance].callId = callInfo.stateInfo.callId;
        [CallTipView shareInstance].commingView.displayCallNumberLabel.text = commingCallNumber;
        [CallTipView shareInstance].commingView.currentCallType = callType;
        
    });
}

-(void)removeCallViewNotify
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self removeCallView:_currentTupCallInfo.stateInfo.callId];
        [self.callWindow setHidden:YES];
        
//        if ([ManagerService confService].isFirstJumpToRunningView) {
//            [ManagerService confService].isFirstJumpToRunningView = NO;
            [AppDelegate goConference];
//        }
    });
}

-(void)networkStatusChangeNotify:(NSNotification *)notify
{
    NetworkStatus netStatus = (NetworkStatus)[[notify object] integerValue];
    if (netStatus == NotReachable)
    {
        [[ManagerService callService] hangupAllCall];
        [self showMessage:@"Current network is unavailable"];
        [[ManagerService loginService] logout];
    }
}

- (void) appInactiveNotify:(NSNotification*) notify
{
    if (_currentTupCallInfo.stateInfo.callType == CALL_VIDEO
        && _currentTupCallInfo.stateInfo.callState == CallStateTaking
        && !_cameraClose) {
        [[DeviceMotionManager sharedInstance] stopDeviceMotionManager];
    }
    [[ManagerService callService] controlVideoWhenApplicationResignActive:NO callId:_currentTupCallInfo.stateInfo.callId];
}

- (void) appActiveNotify:(NSNotification*) notify
{
    [[ManagerService callService] controlVideoWhenApplicationResignActive:YES callId:_currentTupCallInfo.stateInfo.callId];
    if (_currentTupCallInfo.stateInfo.callType == CALL_VIDEO
        && _currentTupCallInfo.stateInfo.callState == CallStateTaking
        && !_cameraClose) {
        [[DeviceMotionManager sharedInstance] startDeviceMotionManager];
    }
}

- (void)deviceMotionOrientationChanged
{
    NSUInteger cameraRotation = 0;
    NSUInteger displayRotation = 0;
    
    CallView *currentView = [self obtainCurrentCallView];
    BOOL needAdjust = [[DeviceMotionManager sharedInstance] adjustCamerRotation:&cameraRotation displayRotation:&displayRotation byCamerIndex:_cameraCaptureIndex interfaceOrientation:currentView.showOrient];
    if ([UIApplication sharedApplication].applicationState != UIApplicationStateActive)
    {
        return ;
    }
    
    if (!needAdjust) {
        return;
    }
    
    [[ManagerService callService] rotationVideoDisplay:displayRotation callId:_currentTupCallInfo.stateInfo.callId];
    [[ManagerService callService] rotationCameraCapture:cameraRotation callId:_currentTupCallInfo.stateInfo.callId];
}

- (void)showStartCallView:(unsigned int)callId
{
    [self.callWindow makeKeyAndVisible];
    [[CallEndView shareInstance] showCallEndViewInUIView:self.callWindow.rootViewController.view];
    [CallEndView shareInstance].callId = callId;
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
            dispatch_async(dispatch_get_main_queue(), ^{
                BOOL isPlay = [resultDictionary[TSDK_CALL_RINGBACK_KEY] boolValue];
                if (isPlay)
                {
                    NSString *wavPath = [[NSBundle mainBundle] pathForResource:@"RingTone.wav"
                                                                        ofType:nil];
                    [[ManagerService callService] mediaStartPlayWithFile:wavPath];
                }
                else {
                    [self performSelector:@selector(delayStopRing) withObject:nil afterDelay:0.5];
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
            [[CallTipView shareInstance] removeCommingCallTipView];
            [self.callWindow setHidden:YES];
        }
            break;
        case CALL_VIEW_REFRESH:
        {
            NSString *callId = resultDictionary[CALL_ID];
                [EAGLView hideLocalView];
                [EAGLView hideRemoteView];
                [EAGLView showRemoteView];
                [EAGLView showLocalView];
                [[ManagerService callService] updateVideoWindowWithLocal:_locationView
                                                               andRemote:_remoteView
                                                                 andBFCP:_bfcpView
                                                                  callId:callId.intValue];
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
            dispatch_async(dispatch_get_main_queue(), ^{
                CallView *callView = [self callViewWithCallId:callId.integerValue];
                CallInfo *callInfo = [self callInfoWithCallId:callId.integerValue];
                callInfo.stateInfo.callType = CALL_AUDIO;
                callView.currentTupCallInfo = callInfo;
                [[DeviceMotionManager sharedInstance] stopDeviceMotionManager];
                [self removeGLViewInCallView:callView];
            });
            break;
        }
        case CALL_REFUSE_OPEN_VIDEO:
        {
            NSString *callId = resultDictionary[CALL_ID];
            dispatch_async(dispatch_get_main_queue(), ^{
                CallView *callView = [self callViewWithCallId:callId.integerValue];
                CallInfo *callInfo = [self callInfoWithCallId:callId.integerValue];
                callInfo.stateInfo.callType = CALL_VIDEO;
                callView.currentTupCallInfo = callInfo;
                [[DeviceMotionManager sharedInstance] startDeviceMotionManager];
                [self addGLViewInCallView:callView];
            });
            break;
        }
        case CALL_HOLD_RESULT:
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString *callId = resultDictionary[CALL_ID];
                BOOL isHoldSuccess = [resultDictionary[TSDK_CALL_HOLD_RESULT_KEY] boolValue];
                CallView *currentCallView = [self callViewWithCallId:callId.integerValue];
                currentCallView.isHold = isHoldSuccess;
                if (!isHoldSuccess)
                {
                    [self showMessage:@"Hold fail!"];
                }
            });
            break;
        }
        case CALL_UNHOLD_RESULT:
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString *callId = resultDictionary[CALL_ID];
                BOOL isUnHoldSuccess = [resultDictionary[TSDK_CALL_UNHOLD_RESULT_KEY] boolValue];
                CallView *currentCallView = [self callViewWithCallId:callId.integerValue];
                currentCallView.isHold = !isUnHoldSuccess;
                if (!isUnHoldSuccess)
                {
                    [self showMessage:@"Unhold fail!"];
                }
            });
            break;
        }
        case CALL_TRANSFER_RESULT:
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                BOOL isTransferSuccess = [resultDictionary[TSDK_CALL_TRANSFER_RESULT_KEY] boolValue];
                if (isTransferSuccess)
                {
                    [self showMessage:@"Transfer success"];
                    return ;
                }
                [self showMessage:@"Transfer fail"];
            });
            break;
        }
        case CALL_DIVERT_FAILED:
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self showMessage:@"Divert transfer failed!"];
            });
            break;
        }
        default:
            break;
    }
}

-(void)handleCallConnectEventWithResult:(NSDictionary *)resultDictionary
{
    dispatch_async(dispatch_get_main_queue(), ^{
        CallInfo *callInfo = resultDictionary[TSDK_CALL_INFO_KEY];
        self.currentTupCallInfo = callInfo;
        if (_callInfoArray.count > 0)
        {
            BOOL isExist = NO;
            for (CallInfo *tempCallInfo in _callInfoArray)
            {
                if (tempCallInfo.stateInfo.callId == callInfo.stateInfo.callId)
                {
                    isExist = YES;
                }
            }
            if (!isExist)
            {
                [_callInfoArray addObject:callInfo];
            }
        }
        else
        {
            [_callInfoArray addObject:callInfo];
        }
        
        if (!callInfo.isFocus) {
            [self.callWindow makeKeyAndVisible];
            [self addCallView];
        }
        else {
            [self removeCallView:_currentTupCallInfo.stateInfo.callId];
            [self.callWindow setHidden:YES];
        }
        
        
        if (callInfo.stateInfo.callId == [CallTipView shareInstance].callId) {
            [[CallTipView shareInstance] removeCommingCallTipView];
            [CallTipView shareInstance].callId = 0;
        }
        
        _callTimeOut = NO;
        [self performSelector:@selector(delayStopRing) withObject:nil afterDelay:0.5];
        
        if (callInfo.stateInfo.callId == [CallEndView shareInstance].callId) {
            [[CallEndView shareInstance] removeCallEndView];
            [CallEndView shareInstance].callId = 0;
        }
    });
}

-(void)handleCallIncommingEventWithResult:(NSDictionary *)resultDictionary
{
    dispatch_async(dispatch_get_main_queue(), ^{
        CallInfo *callInfo = resultDictionary[TSDK_CALL_INFO_KEY];
        _currentTupCallInfo = callInfo;
        _isJoinConfCall = NO;
//        if (callInfo.isFocus) {
//            [self clickCommingTipViewButton:ANSWER_COMMING_CALL];
//            return ;
//        }
        
        TUP_CALL_TYPE callType = (TUP_CALL_TYPE)self.currentTupCallInfo.stateInfo.callType;
        NSString *commingCallNumber = [NSString stringWithFormat:@"%@",callInfo.stateInfo.callNum];
        [self.callWindow makeKeyAndVisible];
        [[CallTipView shareInstance] showCommingCallTipViewInUIView:self.callWindow.rootViewController.view delegate:self];
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
    dispatch_async(dispatch_get_main_queue(), ^{
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:@"Upgrade to video call" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *refuseAction = [UIAlertAction actionWithTitle:@"Refuse" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [[ManagerService callService] replyAddVideoCallIsAccept:NO callId:callId.integerValue];
        }];
        UIAlertAction *answerAction = [UIAlertAction actionWithTitle:@"Answer" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [[ManagerService callService] replyAddVideoCallIsAccept:YES callId:callId.integerValue];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                CallView *callView = [self callViewWithCallId:callId.integerValue];
                CallInfo *callInfo = [self callInfoWithCallId:callId.integerValue];
                callInfo.stateInfo.callType = CALL_VIDEO;
                callView.currentTupCallInfo = callInfo;
                [[DeviceMotionManager sharedInstance] startDeviceMotionManager];
                [self addGLViewInCallView:callView];
            });
            
        }];
        [alertController addAction:refuseAction];
        [alertController addAction:answerAction];
        [self.callWindow.rootViewController presentViewController:alertController animated:YES completion:nil];
    });
}

-(void)handleCallCloseEvent:(NSDictionary *)resultDic
{
    CallInfo *callInfo = resultDic[TSDK_CALL_INFO_KEY];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self performSelector:@selector(delayStopRing) withObject:nil afterDelay:0.5];
        [self removeCallView:callInfo.stateInfo.callId];
        if (_callInfoArray.count > 0)
        {
            NSMutableArray *tempMutArray = [NSMutableArray arrayWithArray:_callInfoArray];
            for (CallInfo *tempCallInfo in tempMutArray)
            {
                DDLogInfo(@"_callInfoArray tempCallInfo : %d",tempCallInfo.stateInfo.callId);
                if (tempCallInfo.stateInfo.callId == callInfo.stateInfo.callId)
                {
                    DDLogInfo(@"_callInfoArray removeObject : %d",tempCallInfo.stateInfo.callId);
                    [_callInfoArray removeObject:tempCallInfo];
                }
            }
        }
        
        if (callInfo.stateInfo.callId == _currentTupCallInfo.stateInfo.callId) {
            if (_callInfoArray.count > 0)
            {
                _currentTupCallInfo = _callInfoArray.lastObject;
                CallView *currentCallView = [self callViewWithCallId:_currentTupCallInfo.stateInfo.callId];
                [[ManagerService callService] unHoldCallWithCallId:_currentTupCallInfo.stateInfo.callId];
                [self.callWindow.rootViewController.view bringSubviewToFront:currentCallView];
                _talkingCtrl.orientation = currentCallView.showOrient;
                [CommonUtils setToOrientation:(UIDeviceOrientation)currentCallView.showOrient];
            }
        }
        
        if (_callInfoArray.count == 0) {
            _currentTupCallInfo = nil;
            DDLogInfo(@"_callInfoArray removeAllObjects");
            _talkingCtrl.orientation = UIInterfaceOrientationPortrait;
            [CommonUtils setToOrientation:UIDeviceOrientationPortrait];
            [self.callWindow setHidden:YES];
        }
        
        _isCallTransToConf = NO;
        
        if ([CallTipView shareInstance].callId == callInfo.stateInfo.callId) {
            [[CallTipView shareInstance] removeCommingCallTipView];
            [CallTipView shareInstance].callId = 0;
        }
        else {
            [self.callWindow.rootViewController.view bringSubviewToFront:[CallTipView shareInstance].commingView];
        }
        
        if ([CallEndView shareInstance].callId == callInfo.stateInfo.callId) {
            [[CallEndView shareInstance] removeCallEndView];
            [CallEndView shareInstance].callId = 0;
        }
        else {
            [self.callWindow.rootViewController.view bringSubviewToFront:[CallEndView shareInstance]];
        }
        
        [[DeviceMotionManager sharedInstance] stopDeviceMotionManager];
        _isCallVideoOpeartionStatus = NO;
        _cameraClose = YES;
        _cameraCaptureIndex = 1;
        _hasAddView = NO;
        
    });
}

-(void)removeCallView:(unsigned int)callId
{
    CallView *callView = [self callViewWithCallId:callId];
    if (callView)
    {
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
        callView.tag = _currentTupCallInfo.stateInfo.callId;
        callView.delegate = self;
        callView.currentTupCallInfo = _currentTupCallInfo;
        [self.callWindow.rootViewController.view addSubview:callView];
        [_callViewArray addObject:callView];
        BOOL isVideo = _currentTupCallInfo.stateInfo.callType ;
        
        
        if (isVideo)
        {
//            callView.showOrient = ((1 == _currentTupCallInfo.orientType) ? UIInterfaceOrientationPortrait : UIInterfaceOrientationLandscapeRight);
            callView.showOrient = UIInterfaceOrientationPortrait;
            [self addGLViewInCallView:callView];
            [[DeviceMotionManager sharedInstance] startDeviceMotionManager];
            _talkingCtrl.orientation = callView.showOrient;
            [CommonUtils setToOrientation:(UIDeviceOrientation)callView.showOrient];
        }
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
    
    // video local view
    _locationView.tag = callView.tag +2;
    _locationView.frame = CGRectMake([UIScreen mainScreen].bounds.size.width - 100, 0, 100, 150);;
    
    
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
    return [self callViewWithCallId:_currentTupCallInfo.stateInfo.callId];
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
            DDLogInfo(@"CallView tag: %d",tempCallView.tag);
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
                BOOL isSuccess = [[ManagerService callService] divertCallWithNumber:number callId:_currentTupCallInfo.stateInfo.callId];
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
                [[ManagerService callService] answerComingCallType:CALL_AUDIO callId:_currentTupCallInfo.stateInfo.callId];
            }
            
            break;
        }
        case VIDEO_ANSWER_COMMING_CALL:
        {
            if (_isJoinConfCall) {
                [[ManagerService confService] acceptConfCallIsJoinVideoConf:YES];
            }else{
                [[ManagerService callService] answerComingCallType:CALL_VIDEO callId:_currentTupCallInfo.stateInfo.callId];
            }
            
            _cameraClose = NO;
            
            [[ManagerService callService] updateVideoWindowWithLocal:_locationView
                                                           andRemote:_remoteView
                                                             andBFCP:_bfcpView
                                                              callId:_currentTupCallInfo.stateInfo.callId];
            break;
        }
        case REFUSE_COMMING_CALL:
        {
            if (_isJoinConfCall) {
                [[ManagerService confService] rejectConfCall];
            }else{
                [[ManagerService callService] closeCall:self.currentTupCallInfo.stateInfo.callId];
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
                
                [[ManagerService callService] updateVideoWindowWithLocal:_locationView
                                                               andRemote:_remoteView
                                                                 andBFCP:_bfcpView
                                                                  callId:callInfo.stateInfo.callId];
                
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
    [[ManagerService callService] sendDTMFWithDialNum:string callId:_currentTupCallInfo.stateInfo.callId];
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

@end
