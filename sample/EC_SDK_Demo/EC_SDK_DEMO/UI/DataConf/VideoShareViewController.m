//
//  VideoShareViewController.m
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

#import "ManagerService.h"
#import "EAGLView.h"
#import "ChatMsg.h"
#import "ConfAttendeeInConf.h"
#import "DeviceMotionManager.h"
#import "DataShareViewController.h"
#import "VideoShareViewController.h"
#import "ConfBaseInfo.h"
#import "ConfRunningViewController.h"
#import "ConfAttendee.h"
#import "ConfListViewController.h"

#define SCREEN_WIDTH MIN(self.view.bounds.size.width, self.view.bounds.size.height)
#define SCREEN_HIGHT MAX(self.view.bounds.size.height, self.view.bounds.size.width)

@interface VideoShareViewController ()<UITableViewDelegate, UITableViewDataSource, CallServiceDelegate, ConferenceServiceDelegate>

@property (nonatomic, strong) UIView *localViewShower;
@property (nonatomic, strong) UIImageView *backImageView;
@property (nonatomic, strong) EAGLView *remoteView;
@property (nonatomic, strong) EAGLView *localView;
@property (nonatomic, strong) UIButton *confDataShareBtn;
@property (nonatomic, strong) UIImageView *confDataShareImageView;
@property (nonatomic, strong) UIButton *attendCameraChooseBtn;
@property (nonatomic, strong) UIButton *cameraHandleBtn;
@property (nonatomic, strong) UIButton *setConfModeBtn;
@property (nonatomic, strong) UITableView *attendTableView;
@property (nonatomic, strong) UIImageView *attendTableViewBackImageView;
@property (nonatomic, strong) UIView *attendTableViewBackFullScreenView;

@property (nonatomic, strong) UITableView *confCtrlTableView;
@property (nonatomic, strong) NSMutableArray *confCtrlArray;
@property (nonatomic, strong) UIImageView *confCtrlTableViewBackImageView;
@property (nonatomic, strong) UIView *confCtrlTableViewBackFullScreenView;
@property (nonatomic,strong) UIButton* attendeeListBtn;
@property (nonatomic,strong) UIButton* moreBtn;

@property (nonatomic,strong) UIImageView* audioBackImageView;

@property (nonatomic, assign) BOOL isCameraOpen;
@property (nonatomic, strong) CallInfo *currentTupCallInfo;
@property (nonatomic, assign) NSInteger cameraCaptureIndex;
@property (nonatomic, strong) NSMutableArray *localCameraInfos;
@property (nonatomic, strong) NSMutableArray *remoteCameraInfos;

@property (nonatomic, assign) BOOL isEnterBackground;

@property (nonatomic, assign) EC_CONF_MODE currentConfMode;

@end

@implementation VideoShareViewController

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    if (![ManagerService confService].isVideoConfInvited) {
        return UIInterfaceOrientationMaskPortrait;
    }
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

-(void)callEventCallback:(TUP_CALL_EVENT_TYPE)callEvent result:(NSDictionary *)resultDictionary
{
    
}

-(void)ecConferenceEventCallback:(EC_CONF_E_TYPE)ecConfEvent result:(NSDictionary *)resultDictionary
{
    switch (ecConfEvent) {
        case CONF_E_ATTENDEE_UPDATE_INFO:
            [self confAttendeeUpdateAction];
            break;
            
        case CONF_E_END_RESULT:
        {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [self quitToListViewCtrl];
//            });
            
        }
        
        default:
            break;
    }
}

- (void)confAttendeeUpdateAction
{
    
    if ([self isNeedAddDataBtn]) {
        if (_confDataShareBtn == nil) {
            [self.barView addSubview:self.confDataShareBtn];
        }
    }
    
//    if ([self isSelfMaster]) {
//        if (_setConfModeBtn == nil) {
//            [self.bottomView addSubview:self.setConfModeBtn];
//        }
//    }
    
    [self updateConfCtrlArray];
    
    
    if(self.selfConfInfo.is_mute){
        [self.muteBtn setImage:[UIImage imageNamed:@"conf_tab_mute_selected"] forState:UIControlStateNormal];
    }else{
        [self.muteBtn setImage:[UIImage imageNamed:@"conf_tab_mute"] forState:UIControlStateNormal];
    }
    
//    [self.confCtrlArray removeAllObjects];
//    if ([ManagerService confService].isVideoConfInvited) {
//        [self.confCtrlArray addObject:@"Camera Change"];
//        [self.confCtrlArray addObject:@"Lock Conf"];
//        EC_CONF_MEDIATYPE mediaType = [ManagerService confService].currentConfBaseInfo.media_type;
//        if (mediaType == CONF_MEDIATYPE_VOICE || mediaType == CONF_MEDIATYPE_VIDEO) {
//            [self.confCtrlArray addObject:@"Update Date Meeting"];
//        }
//    }
//    if (self.selfConfInfo.role == CONF_ROLE_CHAIRMAN) {
//        [self.confCtrlArray addObject:@"Release Chair"];
//    }else{
//        [self.confCtrlArray addObject:@"Request Chair"];
//    }
    
//    [self.moreBtn setEnabled:YES];
    
//    NSInteger count = [ManagerService confService].haveJoinAttendeeArray.count;
//    if (count > 0) {
//        [self.barView addSubview:self.attendCameraChooseBtn];
//        if (![self isUseTupVideo] || ([self isVideoConf])) {
//            [self.view addSubview:self.attendTableViewBackFullScreenView];
//        }
//    }

}

- (NSMutableArray *)localCameraInfos {
    if (!_localCameraInfos) {
        _localCameraInfos = [[NSMutableArray alloc] init];
    }
    return _localCameraInfos;
}

- (NSMutableArray *)remoteCameraInfos {
    if (!_remoteCameraInfos) {
        _remoteCameraInfos = [[NSMutableArray alloc] init];
    }
    return _remoteCameraInfos;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        if ([self isUseTupVideo]) {
            _isCameraOpen = YES;
        }else {
            _isCameraOpen = NO;
        }
        _isEnterBackground = NO;
        _cameraCaptureIndex = 1;
        _currentConfMode = EC_CONF_MODE_FIXED;
        self.confCtrlArray = [[NSMutableArray alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(tupLocalVideoViewRefreshViewWithCallId:)
                                                     name:TUP_CALL_REFRESH_VIEW_NOTIFY
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(tupRemoteVideoViewDecodeSuccessWithCallId:)
                                                     name:TUP_CALL_DECODE_SUCCESS_NOTIFY
                                                   object:nil];
  
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(deviceMotionOrientationChanged)
                                                     name:ESPACE_DEVICE_ORIENTATION_CHANGED
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(receiveConfModeChanged:)
                                                     name:EC_SET_CONF_MODE_NOTIFY
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(quitToListViewCtrl) name:CONF_QUITE_TO_CONFLISTVIEW
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange) name:UIDeviceOrientationDidChangeNotification object:nil];
    }
    return self;
}

- (void)deviceOrientationDidChange
{
    [self updateBtnViewFrame];
}

- (void)receiveConfModeChanged:(NSNotification *)notify {
    NSDictionary *resultDic = notify.userInfo;
    BOOL result = [resultDic[ECCONF_RESULT_KEY] boolValue];
    NSString *modeStr = nil;
    switch (_currentConfMode) {
        case EC_CONF_MODE_FIXED:
            modeStr = @"Boardcast Mode";
            break;
        case EC_CONF_MODE_VAS:
            modeStr = @"Voice Active Mode";
            break;
        case EC_CONF_MODE_FREE:
            modeStr = @"Free Discuss Mode";
            break;
            
        default:
            break;
    }
    if (result) {
        [self showMessage:[NSString stringWithFormat:@"Set conf mode success. Current mode: %@", modeStr]];
    }else {
        [self showMessage:@"Set conf mode failed."];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [ManagerService confService].delegate = self;
    if ([self isNeedAddDataBtn]) {
        [self.barView addSubview:self.confDataShareBtn];
    }
    [[DeviceMotionManager sharedInstance] startDeviceMotionManager];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    [[DeviceMotionManager sharedInstance] stopDeviceMotionManager];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor clearColor];
    
    if ([ManagerService confService].isVideoConfInvited) {
        [self.view insertSubview:self.backImageView belowSubview:self.bottomView];
        if ([self isUseTupVideo]) {
            [self.view insertSubview:self.remoteView aboveSubview:self.backImageView];
        }
        [self.view addSubview:self.localViewShower];
        [self.barView addSubview:self.attendCameraChooseBtn];
    }else{
        [self.view insertSubview:self.audioBackImageView belowSubview:self.bottomView];
    }
    
//    if ([self isNeedAddDataBtn]) {
//        [self.barView addSubview:self.confDataShareBtn];
//    }
//    [self.barView addSubview:self.attendCameraChooseBtn];
//    if (![self isUseTupVideo] || ([self isVideoConf])) {
//        [self.view addSubview:self.attendTableViewBackFullScreenView];
//    }
    if ([ManagerService confService].isVideoConfInvited) {
//        [self configVideoBottomViewBtnsWithWidth:SCREEN_HIGHT];
        [self updateBtnViewFrame];
    }else{
        [self configAudioBottomViewBtnsWithWidth:SCREEN_WIDTH];
    }
    
//    if ([self isSelfMaster]) {
//        [self.bottomView addSubview:self.setConfModeBtn];
//    }
    
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *backImg = [UIImage imageNamed:@"dataconf_back"];
    [backBtn setImage:backImg forState:UIControlStateNormal];
    [backBtn setImage:[UIImage imageNamed:@"dataconf_back_highlight"] forState:UIControlStateHighlighted];
    
    backBtn.frame = CGRectMake(0, 12, 40, 40);
    [backBtn addTarget:self action:@selector(gobackBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [self.barView addSubview:backBtn];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
//    self.remoteView.frame = CGRectMake(0, 0, [self selfViewWidth], [self selfViewHeight]);
//    self.localView.frame = CGRectMake(0, 0, 126, 95);
}

- (BOOL)isMediaXDataVideoConf {
    return ([[ManagerService confService] isUportalMediaXConf]
            && (CONF_MEDIATYPE_VIDEO_DATA == [ManagerService confService].currentConfBaseInfo.media_type));
}

- (BOOL)isNeedAddDataBtn {
    EC_CONF_MEDIATYPE confType = [ManagerService confService].currentConfBaseInfo.media_type;
    BOOL isVideoDataConf = (confType == CONF_MEDIATYPE_VIDEO_DATA || confType == CONF_MEDIATYPE_DATA);
    return isVideoDataConf;
}

- (void)configVideoBottomViewBtnsWithWidth:(CGFloat)width {
//    CGFloat width = [self selfViewWidth];
//    self.cameraHandleBtn.frame = CGRectMake(width/2-170, 0, 100, 71);
    self.voiceBtn.frame = CGRectMake(width/2-110, 0, 100, 71);
    self.muteBtn.frame = CGRectMake(width/2+10, 0, 100, 71);
    self.attendeeListBtn.frame = CGRectMake(width/2-220, 0, 100, 71);
    self.moreBtn.frame = CGRectMake(width/2+110, 0, 100, 71);
    
//    [self.bottomView addSubview:self.cameraHandleBtn];
    [self.bottomView addSubview:self.voiceBtn];
    [self.bottomView addSubview:self.muteBtn];
    [self.bottomView addSubview:self.attendeeListBtn];
    [self.bottomView addSubview:self.moreBtn];
    
}

- (void)configAudioBottomViewBtnsWithWidth:(CGFloat)width
{
    self.voiceBtn.frame = CGRectMake(width/2-85, 0, 85, 85);
    self.muteBtn.frame = CGRectMake(width/2, 0, 85, 85);
    self.attendeeListBtn.frame = CGRectMake(width/2-170, 0, 85, 85);
    self.moreBtn.frame = CGRectMake(width/2+85, 0, 85, 85);
    [self.bottomView addSubview:self.voiceBtn];
    [self.bottomView addSubview:self.muteBtn];
    [self.bottomView addSubview:self.attendeeListBtn];
    [self.bottomView addSubview:self.moreBtn];
}

- (void)moreBtnPressed
{
    [self updateConfCtrlArray];
    if (_confCtrlTableViewBackFullScreenView) {
        CGFloat backViewX = SCREEN_WIDTH-5-264;
        if ([ManagerService confService].isVideoConfInvited) {
            backViewX = SCREEN_HIGHT-5-264;
            UIDeviceOrientation orientation = [[DeviceMotionManager sharedInstance] lastOrientation];
            if (orientation == UIDeviceOrientationPortrait) {
                backViewX = SCREEN_WIDTH-5-264;
            }
        }
        CGFloat hight = [self heightOfConfCtrlRealTableView];
        CGRect frame = CGRectMake(backViewX, self.view.frame.size.height - 100 - hight + 2*5, 264, hight + 2*5);
        _confCtrlTableViewBackImageView.frame = frame;
        
        _confCtrlTableView.frame = CGRectMake(5, 5, 254, hight);;
        
        _confCtrlTableViewBackFullScreenView.hidden = !_confCtrlTableViewBackFullScreenView.hidden;
    }
    else{
        [self.view addSubview:self.confCtrlTableViewBackFullScreenView];
    }
    
    [self.confCtrlTableView reloadData];
    
}

- (void)updateConfCtrlArray
{
    [self.confCtrlArray removeAllObjects];
    if ([ManagerService confService].isVideoConfInvited) {
        [self.confCtrlArray addObject:@"Camera Change"];
        
        if (self.selfConfInfo.role == CONF_ROLE_CHAIRMAN) {
            [self.confCtrlArray addObject:@"Set Conf Mode"];
        }
        
        if (_isCameraOpen) {
            [self.confCtrlArray addObject:@"Camera Close"];
        }else{
            [self.confCtrlArray addObject:@"Camera Open"];
        }
        if (_localViewShower.hidden) {
            [self.confCtrlArray addObject:@"Show LocalView"];
        }else{
            [self.confCtrlArray addObject:@"Hide LocalView"];
        }
    }
    
    if (self.selfConfInfo.role == CONF_ROLE_CHAIRMAN) {
        [self.confCtrlArray addObject:@"Add Attendee"];
        
        [self.confCtrlArray addObject:@"Release Chair"];
        
        if ([ManagerService confService].currentConfBaseInfo.lock_state) {
            [self.confCtrlArray addObject:@"Unlock Conf"];
        }else{
            [self.confCtrlArray addObject:@"Lock Conf"];
        }
        
        EC_CONF_MEDIATYPE mediaType = [ManagerService confService].currentConfBaseInfo.media_type;
        if (mediaType == CONF_MEDIATYPE_VIDEO || mediaType == CONF_MEDIATYPE_VOICE) {
            [self.confCtrlArray addObject:@"UpGrade DateConf"];
        }
        
    }else{
        [self.confCtrlArray addObject:@"Request Chair"];
    }

}

- (void)attendeeListBtnPressed
{
    ConfRunningViewController *runViewCtrl = [[ConfRunningViewController alloc]init];
    [self.navigationController pushViewController:runViewCtrl animated:YES];
}

- (UIImageView *)audioBackImageView
{
    if (!_audioBackImageView) {
        _audioBackImageView = [[UIImageView alloc] init];
        _audioBackImageView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HIGHT);
        _audioBackImageView.image = [UIImage imageNamed:@"image_video_call_bg"];
        
        UIView *imageView = [[UIView alloc]init];
        imageView.frame = CGRectMake(SCREEN_WIDTH/2-80, SCREEN_HIGHT/2 -240, 160, 140);
        imageView.tag = 999;
        
        UIImageView *headView = [[UIImageView alloc]init];
//        headView.frame = CGRectMake(SCREEN_WIDTH/2-50, SCREEN_HIGHT/2 -200, 100, 100);
        headView.frame = CGRectMake(30, 0, 100, 100);
        headView.image = [UIImage imageNamed:@"default_head_image_0"];
//        [_audioBackImageView addSubview:headView];
        [imageView addSubview:headView];
        
        UILabel *nameLabel = [[UILabel alloc] init];
//        nameLabel.frame = CGRectMake(CGRectGetMinX(headView.frame)-30, CGRectGetMaxY(headView.frame)+10, 160, 30);
        nameLabel.frame = CGRectMake(0, 110, 160, 30);
        nameLabel.text = [ManagerService confService].selfJoinNumber;
        nameLabel.textAlignment = NSTextAlignmentCenter;
//        [_audioBackImageView addSubview:nameLabel];
        [imageView addSubview:nameLabel];
        
        [_audioBackImageView addSubview:imageView];
        
    }
    return _audioBackImageView;
}

- (UIImageView *)backImageView {
    if (!_backImageView) {
        _backImageView = [[UIImageView alloc] init];
        _backImageView.frame = CGRectMake(([self selfViewWidth] - 142)/2, ([self selfViewHeight] - 142)/2, 142, 142);
        _backImageView.image = [UIImage imageNamed:@"image_conf_video_back"];
    }
    return _backImageView;
}

- (UIView *)localViewShower {
    if (nil == _localViewShower) {
        _localViewShower = [[UIView alloc]initWithFrame:CGRectMake(5, 64 + 5, 126, 95)];
//        _localViewShower.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"image_conf_video_small_video_back"]];
        [_localViewShower addSubview:self.localView];
    }
    return _localViewShower;
}

-(EAGLView *)localView{
    if (nil == _localView) {
        if ([self isUseTupVideo]) {
            _localView = [EAGLView getLocalView];
        }else {
            _localView = [EAGLView getDataLocalView];
        }
    }
    return _localView;
}

-(EAGLView *)remoteView {
    if (nil == _remoteView) {
        if ([self isUseTupVideo]) {
            _remoteView = [EAGLView getRemoteView];
        }
        else {
            _remoteView = [EAGLView getDataRemoteView];
        }
    }
    return _remoteView;
}

- (void)updateBtnViewFrame
{
    if ([ManagerService confService].isVideoConfInvited) {
        CGFloat width = 0;
        CGFloat hight = 0;
//            UIDeviceOrientation orientation8 = [[UIDevice currentDevice] orientation];
        UIInterfaceOrientation interface2 = [UIApplication sharedApplication].statusBarOrientation;
//        UIDeviceOrientation orientation = [[DeviceMotionManager sharedInstance] lastOrientation];
//        if (orientation == UIDeviceOrientationPortrait) {
        if (interface2 == UIInterfaceOrientationPortrait) {
            width = SCREEN_WIDTH;
            hight = SCREEN_HIGHT;
            
            [self configAudioBottomViewBtnsWithWidth:width];
            if (nil != _remoteView) {
                _remoteView.frame = CGRectMake(0, 0, width, hight);
            }
            if (nil != _localViewShower) {
                _localViewShower = [[UIView alloc]initWithFrame:CGRectMake(5, 64 + 5, 95, 126)];
                _localView.frame = CGRectMake(0, 0, 95, 126);
            }
            
            if (nil != _confCtrlTableViewBackImageView) {
                CGFloat backViewX = SCREEN_WIDTH-5-264;

                CGFloat hight = [self heightOfConfCtrlRealTableView];
                CGRect frame = CGRectMake(backViewX, self.view.frame.size.height - 100 - hight + 2*5, 264, hight + 2*5);
                _confCtrlTableViewBackImageView.frame = frame;
            }
            
//        }else if (orientation == UIDeviceOrientationLandscapeLeft || orientation == UIDeviceOrientationLandscapeRight)
//        {
            
        }else if (interface2 == UIInterfaceOrientationLandscapeLeft || interface2 == UIInterfaceOrientationLandscapeRight)
        {
            width = SCREEN_HIGHT;
            hight = SCREEN_WIDTH;
            
            [self configVideoBottomViewBtnsWithWidth:width];
            if (nil != _remoteView) {
                _remoteView.frame = CGRectMake(0, 0, width, hight);
            }
            if (nil != _localViewShower) {
                _localViewShower = [[UIView alloc]initWithFrame:CGRectMake(5, 64 + 5, 126, 95)];
                _localView.frame = CGRectMake(0, 0, 126, 95);
            }
            
            if (nil != _confCtrlTableViewBackImageView) {
                CGFloat backViewX = SCREEN_HIGHT-5-264;

                CGFloat hight = [self heightOfConfCtrlRealTableView];
                CGRect frame = CGRectMake(backViewX, self.view.frame.size.height - 100 - hight + 2*5, 264, hight + 2*5);
                _confCtrlTableViewBackImageView.frame = frame;
            }
        }
    }
    
}

- (void)deviceMotionOrientationChanged
{
//    [self updateBtnViewFrame];
    
    NSUInteger cameraRotation = 0;
    NSUInteger displayRotation = 0;
    
    BOOL needAdjust = [[DeviceMotionManager sharedInstance] adjustCamerRotation:&cameraRotation
                                                                displayRotation:&displayRotation
                                                                   byCamerIndex:_cameraCaptureIndex
                                                           interfaceOrientation:UIInterfaceOrientationPortrait];
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
    
    [[ManagerService callService] rotationVideoDisplay:displayRotation callId:[ManagerService confService].currentConfBaseInfo.call_id];
    [[ManagerService callService] rotationCameraCapture:cameraRotation callId:[ManagerService confService].currentConfBaseInfo.call_id];
}

- (UIButton *)cameraHandleBtn {
    if (nil == _cameraHandleBtn) {
        UIImage *normalImage = [UIImage imageNamed:_isCameraOpen ? @"btn_conf_video_camera_close_normal" : @"btn_conf_video_camera_open_normal"];
        UIImage *clickImage = [UIImage imageNamed:_isCameraOpen ? @"btn_conf_video_camera_close_click" : @"btn_conf_video_camera_open_click"];
        NSString *title = _isCameraOpen ? @"Close" : @"Open";
        _cameraHandleBtn = [self createButtonByImage:normalImage
                                      highlightImage:clickImage
                                               title:title
                                              target:self
                                              action:@selector(cameraHandleBtnClicked:)];
    }
    return _cameraHandleBtn;
}

-(UIButton *)moreBtn
{
    if (nil == _moreBtn) {
        _moreBtn = [self createButtonByImage:[UIImage imageNamed:@"conf_tab_more"] highlightImage:nil title:@"More" target:self action:@selector(moreBtnPressed)];
    }
    return _moreBtn;
}

-(UIButton *)attendeeListBtn
{
    if (nil == _attendeeListBtn) {
        _attendeeListBtn = [self createButtonByImage:[UIImage imageNamed:@"attendee_list"] highlightImage:nil title:@"List" target:self action:@selector(attendeeListBtnPressed)];
    }
    return _attendeeListBtn;
}

- (void)cameraHandleBtnClicked:(id)sender {
    if ([self isVideoConf]) {
        [[ManagerService callService] switchCameraOpen:!_isCameraOpen callId:[ManagerService confService].currentConfBaseInfo.call_id];
        _isCameraOpen = !_isCameraOpen;
    }
    
}

- (void)updateCameraHandleBtn:(BOOL)isSelfCameraOpen {
    if (isSelfCameraOpen) {
        [self.cameraHandleBtn setImage:[UIImage imageNamed:@"btn_conf_video_camera_close_normal"] forState:UIControlStateNormal];
        [self.cameraHandleBtn setImage:[UIImage imageNamed:@"btn_conf_video_camera_close_click"] forState:UIControlStateHighlighted];
        [self.cameraHandleBtn setTitle:@"Close" forState:UIControlStateNormal];
    }
    else {
        [self.cameraHandleBtn setImage:[UIImage imageNamed:@"btn_conf_video_camera_open_normal"] forState:UIControlStateNormal];
        [self.cameraHandleBtn setImage:[UIImage imageNamed:@"btn_conf_video_camera_open_click"] forState:UIControlStateHighlighted];
        [self.cameraHandleBtn setTitle:@"Open" forState:UIControlStateNormal];
    }
}

- (UIButton *)setConfModeBtn {
    if (nil == _setConfModeBtn) {
        _setConfModeBtn = [self createButtonByImage:[UIImage imageNamed:@"new_login_config"]
                                      highlightImage:nil
                                               title:nil
                                              target:self
                                              action:@selector(setConfModeBtnClicked:)];
        CGFloat width = [self selfViewWidth];
        [_setConfModeBtn setFrame:CGRectMake(width-20-31, 20, 31, 31)];
    }
    return _setConfModeBtn;
}

- (void)setConfModeBtnClicked:(id)sender {
    
    void (^setModeBlock)(EC_CONF_MODE mode) = ^(EC_CONF_MODE mode) {
        if ([[ManagerService confService] isUportalMediaXConf]) {
            [[ManagerService confService] setConfMode:mode];
            _currentConfMode = mode;
        }
    };
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Select Conf Mode"
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *actionMode1 = [UIAlertAction actionWithTitle:@"Boardcast Mode"
                                                          style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction * _Nonnull action)
    {
        if (setModeBlock) {
            setModeBlock(EC_CONF_MODE_FIXED);
        }
    }];
    UIAlertAction *actionMode2 = [UIAlertAction actionWithTitle:@"Voice Active Mode"
                                                          style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction * _Nonnull action)
    {
        if (setModeBlock) {
            setModeBlock(EC_CONF_MODE_VAS);
        }
    }];
    UIAlertAction *actionMode3 = [UIAlertAction actionWithTitle:@"Free Discuss Mode"
                                                          style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction * _Nonnull action)
    {
        if (setModeBlock) {
            setModeBlock(EC_CONF_MODE_FREE);
        }
    }];
    
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleDefault
                                                         handler:nil];
    [alertController addAction:actionMode1];
    [alertController addAction:actionMode2];
    [alertController addAction:actionMode3];
    [alertController addAction:cancelAction];
    [self.navigationController presentViewController:alertController
                                            animated:YES
                                          completion:nil];
}

//进入多媒体会场按钮
- (UIButton *)confDataShareBtn {
    if (nil == _confDataShareBtn) {
        _confDataShareImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"enter_datashare"]
                                                   highlightedImage:[UIImage imageNamed:@"enter_datashare_highlight"]];
        _confDataShareImageView.animationImages = @[[UIImage imageNamed:@"enter_datashare"],[UIImage imageNamed:@"enter_datashare1"],
                                                    [UIImage imageNamed:@"enter_datashare2"],[UIImage imageNamed:@"enter_datashare3"]];
        _confDataShareImageView.animationDuration = 2;
        
        _confDataShareBtn = [[UIButton alloc]initWithFrame:_confDataShareImageView.bounds];
        
        CGFloat width = SCREEN_WIDTH -40;
        if ([ManagerService confService].isVideoConfInvited) {
            width = SCREEN_HIGHT -80;
        }
        [_confDataShareBtn setFrame:CGRectMake(width, 15, 34, 34)];
        
        [_confDataShareBtn addTarget:self action:@selector(confDataShareBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_confDataShareBtn addSubview:_confDataShareImageView];
    }
    return _confDataShareBtn;
}

- (void)confDataShareBtnClicked:(id)sender {
    NSMutableArray *ary = [NSMutableArray arrayWithArray:[self.navigationController viewControllers]];
    if ([ary containsObject:self]) {
        [ary removeObject:self];
    }
    DataShareViewController *dataConfCtrl = [[DataShareViewController alloc] init];
    dataConfCtrl.hidesBottomBarWhenPushed = YES;
    [ary addObject:dataConfCtrl];
    [self.navigationController setViewControllers:ary animated:NO];
}

- (UIButton *)attendCameraChooseBtn {
    BOOL isVideoConf = [self isVideoConf];
    NSString *normalImageName = @"btn_conf_video_attend_camera_choose_normal";
    NSString *highlightImageName = @"btn_conf_video_attend_camera_choose_click";
    if (isVideoConf) {
        normalImageName = @"btn_conf_video_attend_camera_boardcast_normal";
        highlightImageName = @"btn_conf_video_attend_camera_boardcast_click";
    }
    if (nil == _attendCameraChooseBtn) {
        _attendCameraChooseBtn = [self createButtonByImage:[UIImage imageNamed:normalImageName]
                                            highlightImage:[UIImage imageNamed:highlightImageName]
                                                     title:nil
                                                    target:self
                                                    action:@selector(attendCameraChooseBtnClicked:)];
        CGFloat width = [self selfViewWidth];
        [_attendCameraChooseBtn setFrame:CGRectMake(width-40, 15, 34, 34)];
    }
    return _attendCameraChooseBtn;
}

- (void)attendCameraChooseBtnClicked:(id)sender {
    
    if (_attendTableViewBackFullScreenView) {
        CGFloat backViewX = SCREEN_WIDTH-5-264;
        if ([ManagerService confService].isVideoConfInvited) {
            backViewX = SCREEN_HIGHT-5-264;
        }
        CGFloat hight = [self heightOfRealTableView];
        
        _attendTableViewBackImageView.frame = CGRectMake(backViewX, 65, 264, hight+ 2*5);
        _attendTableView.frame = CGRectMake(5, 5, 254, hight);

        _attendTableViewBackFullScreenView.hidden = ! _attendTableViewBackFullScreenView.hidden;
    }
    else{
        NSInteger count = [ManagerService confService].haveJoinAttendeeArray.count;
        if (count > 0) {
            
            if (![self isUseTupVideo] || ([self isVideoConf])) {
                [self.view addSubview:self.attendTableViewBackFullScreenView];
            }
            [self.attendTableView reloadData];
        }
    }
}

- (UIView *)attendTableViewBackFullScreenView {
    if(nil == _attendTableViewBackFullScreenView) {
        _attendTableViewBackFullScreenView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [self selfViewWidth], [self selfViewHeight])];
        _attendTableViewBackFullScreenView.backgroundColor = [UIColor clearColor];
        [_attendTableViewBackFullScreenView addSubview:self.attendTableViewBackImageView];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(attendTableViewFullScreenViewTap:)];
        [_attendTableViewBackFullScreenView addGestureRecognizer:tap];
        [tap setCancelsTouchesInView:NO];
    }
    return _attendTableViewBackFullScreenView;
}

- (void)attendTableViewFullScreenViewTap:(UITapGestureRecognizer* )tap {
        _attendTableViewBackFullScreenView.hidden = YES;
}

- (UIView *)attendTableViewBackImageView {
    if (nil == _attendTableViewBackImageView) {
        CGFloat backViewX = [self selfViewWidth]-5-264;
        CGRect frame = CGRectMake(backViewX, 65, 264, [self heightOfRealTableView] + 2*5);
        _attendTableViewBackImageView = [[UIImageView alloc]initWithFrame:frame];
        _attendTableViewBackImageView.userInteractionEnabled = YES;
        UIImage *backImage = [UIImage imageNamed:@"image_conf_video_camera_choose_tableview_back_normal"];
        UIEdgeInsets inset = UIEdgeInsetsMake(10, 10, 10, 10);
        _attendTableViewBackImageView.image = [backImage resizableImageWithCapInsets:inset resizingMode:UIImageResizingModeStretch];
        [_attendTableViewBackImageView addSubview:self.attendTableView];
        
    }
    return _attendTableViewBackImageView;
}

- (CGFloat)heightOfRealTableView {
    NSInteger rowNumber = [ManagerService confService].haveJoinAttendeeArray.count;
    if (rowNumber <= 4) {
        return rowNumber*44+30;
    }
    return 4*44+30;
}

- (CGFloat)heightOfConfCtrlRealTableView {
    NSInteger rowNumber = self.confCtrlArray.count;
    if (rowNumber <= 5) {
        return rowNumber*44;
    }
    return 5*44;
}

- (UITableView *)attendTableView {
    if (nil == _attendTableView) {
        CGRect frame = CGRectMake(5, 5, 254, [self heightOfRealTableView]);
        _attendTableView = [[UITableView alloc]initWithFrame:frame];
        _attendTableView.backgroundColor = [UIColor clearColor];
        _attendTableView.delegate = self;
        _attendTableView.dataSource = self;
        _attendTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        _attendTableView.layer.masksToBounds = YES;
        _attendTableView.layer.cornerRadius = 5;
        _attendTableView.tableFooterView = [[UIView alloc] init];
    }
    
    return _attendTableView;
}

- (void)updateViewInTupVideoConf {
    
}

- (void)updateRemoteViewInTupVideoConf:(BOOL)isAddView {
    if (![self isUseTupVideo]) {
        DDLogInfo(@"not use tup video, ignore!");
        return;
    }
    //如果为使用tup视频能力的会议，使用的是视频呼叫的视频view，需要根据通知做add和remove处理
    if (isAddView) {
        [self.view insertSubview:self.remoteView aboveSubview:self.backImageView];
    }else {
        [self.remoteView removeFromSuperview];
    }
}

- (void)updateLocalViewInTupVideoConf:(BOOL)isAddView {
    if (![self isUseTupVideo]) {
        DDLogInfo(@"not tup video conf, ignore!");
        return;
    }
    if (isAddView) {
        [self.localViewShower addSubview:self.localView];
    }else {
        [self.localView removeFromSuperview];
    }
}

- (void)tupLocalVideoViewRefreshViewWithCallId:(NSNotification *)notify {
    if (![ManagerService confService].isVideoConfInvited) {
        DDLogInfo(@"not tup video conf,ignore!");
        return;
    }
    NSNumber *callidNumber = notify.object;
    unsigned int callid = [callidNumber unsignedIntValue];
    if (self.currentTupCallInfo.stateInfo.callId != callid) {
        DDLogInfo(@"call id is not equal to mcu conf callid, ignore!");
        return;
    }
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf updateLocalViewInTupVideoConf:YES];
    });
}

- (void)tupRemoteVideoViewDecodeSuccessWithCallId:(NSNotification *)notify {
    if (![self isUseTupVideo]) {
        DDLogInfo(@"not tup video conf,ignore!");
        return;
    }
    NSNumber *callidNumber = notify.object;
    unsigned int callid = [callidNumber unsignedIntValue];
    if (self.currentTupCallInfo.stateInfo.callId != callid) {
        DDLogInfo(@"call id is not equal to mcu conf callid, ignore!");
        return;
    }
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf updateRemoteViewInTupVideoConf:YES];
    });
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSInteger count = 0;
    
    if (tableView == _attendTableView) {
        count = [ManagerService confService].haveJoinAttendeeArray.count;
    }
    if (tableView == _confCtrlTableView) {
        count = self.confCtrlArray.count;
    }
    
    return count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (tableView == _attendTableView) {
        return @"Please select attendee.";
    }
    if (tableView == _confCtrlTableView) {
        return nil;
    }
    return @"Please select attendee.";
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UITableViewCell class])];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:NSStringFromClass([UITableViewCell class])];
    }
    if (tableView == _attendTableView) {
        ConfAttendeeInConf *attendee = [ManagerService confService].haveJoinAttendeeArray[indexPath.row];
        if ([attendee.number isEqualToString:self.selfNumber]) {
            cell.textLabel.text = [NSString stringWithFormat:@"%@(me)", attendee.number];
        }else {
            cell.textLabel.text = [NSString stringWithFormat:@"%@", attendee.number];
        }
        cell.textLabel.textColor = [UIColor blackColor];
    }
    
    if (tableView == _confCtrlTableView) {
        NSString *confCtrlAction = self.confCtrlArray[indexPath.row];
        cell.textLabel.text = confCtrlAction;
        cell.textLabel.textColor = [UIColor blackColor];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (tableView == _attendTableView) {
        ConfAttendeeInConf *attendee = [ManagerService confService].haveJoinAttendeeArray[indexPath.row];
        if ([self isVideoConf]) {
            if ([self isSelfMaster]) {
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Tips"
                                                                                         message:[NSString stringWithFormat:@"Broadcast %@'s video?", attendee.number]
                                                                                  preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"Sure"
                                                                     style:UIAlertActionStyleDefault
                                                                   handler:^(UIAlertAction * _Nonnull action) {
                                                                       [[ManagerService confService] boardcastAttendee:attendee.number isBoardcast:YES];
                                                                   }];
                UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                                       style:UIAlertActionStyleDefault
                                                                     handler:nil];
                [alertController addAction:sureAction];
                [alertController addAction:cancelAction];
                [self.navigationController presentViewController:alertController animated:YES completion:nil];
            }
            else
            {
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Tips"
                                                                                         message:[NSString stringWithFormat:@"watch %@'s video?", attendee.number]
                                                                                  preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"Sure"
                                                                     style:UIAlertActionStyleDefault
                                                                   handler:^(UIAlertAction * _Nonnull action) {
                                                                       //watch attendee todo jl
                                                                       [[ManagerService confService] watchAttendeeNumber:attendee.number];
                                                                   }];
                UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                                       style:UIAlertActionStyleDefault
                                                                     handler:nil];
                [alertController addAction:sureAction];
                [alertController addAction:cancelAction];
                [self.navigationController presentViewController:alertController animated:YES completion:nil];
            }
        }
    }
    if (tableView == _confCtrlTableView) {
        NSString *confCtrlAction = self.confCtrlArray[indexPath.row];
        if ([confCtrlAction isEqualToString:@"Camera Change"]) {
            if (_isCameraOpen) {
                if ([self isUseTupVideo]) {
                    _cameraCaptureIndex = _cameraCaptureIndex == 1 ? 0 : 1;
                    BOOL isSuccess = [[ManagerService callService] switchCameraIndex:_cameraCaptureIndex callId:[ManagerService confService].currentConfBaseInfo.call_id];
                    if (isSuccess) {
                        [self deviceMotionOrientationChanged];
                    }
                }
            }
        }
        if ([confCtrlAction isEqualToString:@"Release Chair"]) {
            [[ManagerService confService] confCtrlReleaseChairman:self.selfConfInfo.number];
        }
        if ([confCtrlAction isEqualToString:@"Lock Conf"]) {
            [[ManagerService confService] confCtrlLockConference:YES];
        }
        if ([confCtrlAction isEqualToString:@"Unlock Conf"]) {
            [[ManagerService confService] confCtrlLockConference:NO];
        }
        if ([confCtrlAction isEqualToString:@"UpGrade DateConf"]) {
            [[ManagerService confService] confCtrlVoiceUpgradeToDataConference:YES];
        }
        if ([confCtrlAction isEqualToString:@"Request Chair"]) {
            if ([ManagerService confService].uPortalConfType == CONF_TOPOLOGY_SMC) {
                [[ManagerService confService] confCtrlRequestChairman:@"" number:self.selfConfInfo.number];
            }
            else {  // mediaX conf
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self requestConfChairman];
                });
            }
        }
        if ([confCtrlAction isEqualToString:@"Hide LocalView"] || [confCtrlAction isEqualToString:@"Show LocalView"]) {
            _localViewShower.hidden = !_localViewShower.hidden;
        }
        if ([confCtrlAction isEqualToString:@"Add Attendee"]) {
            [self addAttendeeAction];
        }
        if ([confCtrlAction isEqualToString:@"Camera Open"] || [confCtrlAction isEqualToString:@"Camera Close"]) {
            if ([self isVideoConf]) {
                [[ManagerService callService] switchCameraOpen:!_isCameraOpen callId:[ManagerService confService].currentConfBaseInfo.call_id];
                _isCameraOpen = !_isCameraOpen;
            }
        }
        if ([confCtrlAction isEqualToString:@"Set Conf Mode"]) {
            [self setConfModeBtnClicked:nil];
        }
        
    }
}

- (void)addAttendeeAction
{
    UIAlertController *alertCon = [UIAlertController alertControllerWithTitle:nil message:@"Please enter participant number" preferredStyle:UIAlertControllerStyleAlert];
    [alertCon addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Please enter participant number...";
        textField.secureTextEntry = NO;
    }];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UITextField *accountTxf = alertCon.textFields.firstObject;
        ConfAttendee *cAttendee = [[ConfAttendee alloc] init];
        cAttendee.name = accountTxf.text;
        cAttendee.number = accountTxf.text;
        NSArray *addAttendeeArray = @[cAttendee];
        [[ManagerService confService] confCtrlAddAttendeeToConfercene:addAttendeeArray];
    }];
    [alertCon addAction:okAction];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:nil];
    [alertCon addAction:cancelAction];
    [self presentViewController:alertCon animated:YES completion:nil];
}

- (void)requestConfChairman
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Info"
                                                                   message:@"Obtain the passwords from the chair if the passwords are needed."
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.secureTextEntry = YES;
    }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
    }];
    __weak typeof(self) weakSelf = self;
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        UITextField *textField = [alert.textFields firstObject];
        NSString *password = textField.text;
        
        [[ManagerService confService] confCtrlRequestChairman:password number:weakSelf.selfConfInfo.number];
    }];
    
    [alert addAction:cancel];
    [alert addAction:ok];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (BOOL)isVideoConf {
//    BOOL isVideoConf = NO;
//    if (CONF_MEDIATYPE_VIDEO == [ManagerService confService].currentConfBaseInfo.media_type || CONF_MEDIATYPE_VIDEO_DATA == [ManagerService confService].currentConfBaseInfo.media_type) {
//        isVideoConf = YES;
//    }
//    return isVideoConf;
    return [ManagerService confService].isVideoConfInvited;
}

- (BOOL)isUseTupVideo {
    return [self isVideoConf];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (UITableView *)confCtrlTableView {
    if (nil == _confCtrlTableView) {
        CGFloat hight = [self heightOfConfCtrlRealTableView];
        CGRect frame = CGRectMake(5, 5, 254, hight);
        _confCtrlTableView = [[UITableView alloc]initWithFrame:frame];
        _confCtrlTableView.backgroundColor = [UIColor clearColor];
        _confCtrlTableView.delegate = self;
        _confCtrlTableView.dataSource = self;
        _confCtrlTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        _confCtrlTableView.layer.masksToBounds = YES;
        _confCtrlTableView.layer.cornerRadius = 5;
        _confCtrlTableView.tableFooterView = [[UIView alloc] init];
    }
    
    return _confCtrlTableView;
}

- (UIView *)confCtrlTableViewBackImageView {
    if (nil == _confCtrlTableViewBackImageView) {
        
        CGFloat backViewX = SCREEN_WIDTH-5-264;
        if ([ManagerService confService].isVideoConfInvited) {
            backViewX = SCREEN_HIGHT-5-264;
            if ([DeviceMotionManager sharedInstance].lastOrientation == UIDeviceOrientationPortrait) {
                backViewX = SCREEN_WIDTH-5-264;
            }
        }
        CGFloat hight = [self heightOfConfCtrlRealTableView];
        CGRect frame = CGRectMake(backViewX, self.view.frame.size.height - 100 - hight + 2*5, 264, hight + 2*5);
        _confCtrlTableViewBackImageView = [[UIImageView alloc]initWithFrame:frame];
        _confCtrlTableViewBackImageView.userInteractionEnabled = YES;
        [_confCtrlTableViewBackImageView addSubview:self.confCtrlTableView];
    }
    return _confCtrlTableViewBackImageView;
}

- (UIView *)confCtrlTableViewBackFullScreenView {
    if(nil == _confCtrlTableViewBackFullScreenView) {
        if ([ManagerService confService].isVideoConfInvited) {
            _confCtrlTableViewBackFullScreenView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_HIGHT, SCREEN_WIDTH)];
        }else{
            _confCtrlTableViewBackFullScreenView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HIGHT)];
        }
        
        _confCtrlTableViewBackFullScreenView.backgroundColor = [UIColor clearColor];
        
        [_confCtrlTableViewBackFullScreenView addSubview:self.confCtrlTableViewBackImageView];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(confCtrlTableViewFullScreenViewTap:)];
        [_confCtrlTableViewBackFullScreenView addGestureRecognizer:tap];
        [tap setCancelsTouchesInView:NO];
    }
    return _confCtrlTableViewBackFullScreenView;
}

- (void)confCtrlTableViewFullScreenViewTap:(UITapGestureRecognizer *)tap
{
    _confCtrlTableViewBackFullScreenView.hidden = YES;
    
}



- (void)gobackBtnAction
{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Info" message:@"Exit the meeting?" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *closeMeetingAction = [UIAlertAction actionWithTitle:@"End" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            [[ManagerService confService] confCtrlEndConference];
            [[ManagerService confService] restoreConfParamsInitialValue];
            [self finishConference];
            [self quitToListViewCtrl];
        }];
        
        UIAlertAction *leaveMeetingAction = [UIAlertAction actionWithTitle:@"Leave" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            [[ManagerService confService] confCtrlLeaveConference];
            [[ManagerService confService] restoreConfParamsInitialValue];
            [self finishConference];
            [self quitToListViewCtrl];
            
        }];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
        if (self.selfConfInfo.role == CONF_ROLE_CHAIRMAN)
        {
            [alertController addAction:closeMeetingAction];
        }
        [alertController addAction:leaveMeetingAction];
        [alertController addAction:cancelAction];
        [self presentViewController:alertController animated:YES completion:nil];
    });
}

-(void)finishConference
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.navigationController.navigationBarHidden = NO;
    });
}

- (void)quitToListViewCtrl
{
    UIViewController *list = nil;
    for (UIViewController *vc in self.navigationController.viewControllers) {
        if ([vc isKindOfClass:[ConfListViewController class]]) {
            list = vc;
            break;
        }
    }
    
    if (list) {
        [self.navigationController popToViewController:list animated:YES];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
