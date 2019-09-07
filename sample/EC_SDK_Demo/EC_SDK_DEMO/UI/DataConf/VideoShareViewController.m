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
#import "CommonUtils.h"
#import "CallWindowController.h"
#import "SignalScrollView.h"

#import "ImageViewBtn.h"
#import "JoinConfIndInfo.h"
#import "ECSDKProgressHud.h"
#import "SVCConfWatchAttendeeInfo.h"
#import "CallStatisticInfo.h"
#import "SignalDataScrollView.h"

#import "StatisticShowInfo.h"

@interface VideoShareViewController ()<UITableViewDelegate, UITableViewDataSource, ConferenceServiceDelegate>

@property (nonatomic, strong) UIView *localViewShower;
@property (nonatomic, strong) UIImageView *backImageView;
@property (nonatomic, strong) EAGLView *remoteView;
@property (nonatomic, strong) EAGLView *localView;
@property (nonatomic, strong) EAGLView *localBigView;

@property (nonatomic, strong) UIView *firstSVCViewShower;
@property (nonatomic, strong) EAGLView *firstSVCView;
@property (nonatomic, strong) UIView *secondSVCViewShower;
@property (nonatomic, strong) EAGLView *secondSVCView;
@property (nonatomic, strong) UIView *thirdSVCViewShower;
@property (nonatomic, strong) EAGLView *thirdSVCView;

@property (nonatomic, strong) UILabel *bigViewNameLabel;
@property (nonatomic, strong) UILabel *localNameLabel;
@property (nonatomic, strong) UILabel *firstNameLabel;
@property (nonatomic, strong) UILabel *secondNameLabel;
@property (nonatomic, strong) UILabel *thirdNameLabel;

@property (nonatomic, strong) UIView *backSVCView;

@property (nonatomic, strong) UIButton *confDataShareBtn;
@property (nonatomic, strong) UIImageView *confDataShareImageView;
@property (nonatomic, strong) UIButton *attendCameraChooseBtn;
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

@property (nonatomic, strong) NSMutableArray *localCameraInfos;
@property (nonatomic, strong) NSMutableArray *remoteCameraInfos;

@property (nonatomic, assign) BOOL isEnterBackground;

@property (nonatomic, assign) EC_CONF_MODE currentConfMode;

@property (nonatomic, assign) NSInteger currentWatchPage;
@property (nonatomic, strong) ImageViewBtn *nextPageBtn;
@property (nonatomic, strong) ImageViewBtn *previousPageBtn;

@property (nonatomic, assign) CGFloat currentNameWith;
@property (nonatomic, assign) CGFloat currentNameHeight;

@property (nonatomic, strong) NSArray *currentAttendeeWatchArray;

@end

@implementation VideoShareViewController

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    if (![self isVideoConf]) {
        return UIInterfaceOrientationMaskPortrait;
    }
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

-(void)ecConferenceEventCallback:(EC_CONF_E_TYPE)ecConfEvent result:(NSDictionary *)resultDictionary
{
    switch (ecConfEvent) {
        case CONF_E_ATTENDEE_UPDATE_INFO:
        {
            [self confAttendeeUpdateAction];
            
        }
            break;
            
        case CONF_E_END_RESULT:
        {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [self quitToListViewCtrl];
//            });
            
        }
            break;
        case CONF_E_CONNECT:
            
            break;
        
        case CONF_E_SVC_WATCH_INFO_IND:
        {
            NSString *name = [ManagerService confService].currentBigViewAttendee.name;
            if (name.length == 0) {
                name = [ManagerService confService].currentBigViewAttendee.number;
            }
            
            CGRect rect = [name boundingRectWithSize:CGSizeMake([UIScreen mainScreen].bounds.size.width - 20, MAXFLOAT)
                                                  options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading
                                               attributes:@{NSFontAttributeName:_bigViewNameLabel.font}
                                                  context:nil];
            _currentNameWith = rect.size.width + 20;
            _currentNameHeight = rect.size.height + 20;
            
            [self updateBtnViewFrame];
            
            _bigViewNameLabel.text = name;
        }
            
            break;
            
        default:
            break;
    }
}

- (void)confAttendeeUpdateAction
{
    _currentAttendeeWatchArray = [NSArray arrayWithArray:[ManagerService confService].watchAttendeesArray];
    
    if ([self isNeedAddDataBtn]) {
        if (_confDataShareBtn == nil) {
            [self.barView addSubview:self.confDataShareBtn];
        }
    }
    
    [self updateConfCtrlArray];
    
    
    if(self.selfConfInfo.is_mute){
        [self.muteBtn setImage:[UIImage imageNamed:@"conf_tab_mute_selected"] forState:UIControlStateNormal];
    }else{
        [self.muteBtn setImage:[UIImage imageNamed:@"conf_tab_mute"] forState:UIControlStateNormal];
    }
    
    if ([ManagerService confService].currentJoinConfIndInfo.isSvcConf) {
        NSArray *watchAttendees = [ManagerService confService].watchAttendeesArray;
        
        _localNameLabel.text = @"Local";
        
        if (watchAttendees.count == 0) {
            self.localBigView.hidden = NO;
            self.remoteView.hidden = YES;
//            _backSVCView.hidden = YES;
            
            _firstSVCViewShower.hidden = YES;
            _secondSVCViewShower.hidden = YES;
            _thirdSVCViewShower.hidden = YES;
            _localViewShower.hidden = YES;
            _previousPageBtn.hidden = YES;
            _nextPageBtn.hidden = YES;
            
            _firstSVCView.currentAttendee = nil;
            _firstSVCView.currentlabel = 0;
            
            _secondSVCView.currentAttendee = nil;
            _secondSVCView.currentlabel = 0;
            
            _thirdSVCView.currentAttendee = nil;
            _thirdSVCView.currentlabel = 0;
            
        }else{
            self.localBigView.hidden = YES;
            self.remoteView.hidden = NO;
            if ( _backSVCView.hidden ==  NO) {
                _localViewShower.hidden = NO;
                _firstSVCViewShower.hidden = NO;
                _secondSVCViewShower.hidden = NO;
                _thirdSVCViewShower.hidden = NO;
                _previousPageBtn.hidden = YES;
                _nextPageBtn.hidden = YES;
            }

            NSString *firstName = _firstSVCView.currentAttendee.name;
            NSString *secondName = _secondSVCView.currentAttendee.name;
            NSString *thirdName = _thirdSVCView.currentAttendee.name;
            
            NSString *firstNumber = _firstSVCView.currentAttendee.number;
            NSString *secondNumber = _secondSVCView.currentAttendee.number;
            NSString *thirdNumber = _thirdSVCView.currentAttendee.number;
            
            if (firstName.length != 0) {
                _firstNameLabel.text = firstName;
            }else{
                _firstNameLabel.text = firstNumber;
            }
            
            if (watchAttendees.count == 1) {
                _secondSVCViewShower.hidden = YES;
                _thirdSVCViewShower.hidden = YES;
                
                BOOL isNeedUpdateWatch1 = YES;
                for (ConfAttendeeInConf* attendeeInfo in watchAttendees) {
                    if([attendeeInfo.number isEqualToString:_firstSVCView.currentAttendee.number]){
                        isNeedUpdateWatch1 = NO;
                    }
                }
                
                if (isNeedUpdateWatch1) {
                    [self updateWatchAttendeesWithPage:0 bigViewNumber:@""];
                }
                
                _secondSVCView.currentAttendee = nil;
                _secondSVCView.currentlabel = 0;
                
                _thirdSVCView.currentAttendee = nil;
                _thirdSVCView.currentlabel = 0;
                
            }else if (watchAttendees.count == 2){
                _thirdSVCViewShower.hidden = YES;
                
                BOOL isNeedUpdateWatch1 = YES;
                BOOL isNeedUpdateWatch2 = YES;
                for (ConfAttendeeInConf* attendeeInfo in watchAttendees) {
                    if([attendeeInfo.number isEqualToString:_firstSVCView.currentAttendee.number]){
                        isNeedUpdateWatch1 = NO;
                    }
                    if([attendeeInfo.number isEqualToString:_secondSVCView.currentAttendee.number]){
                        isNeedUpdateWatch2 = NO;
                    }
                }
                
                if (isNeedUpdateWatch1 || isNeedUpdateWatch2) {
                    [self updateWatchAttendeesWithPage:0 bigViewNumber:@""];
                }
                
                _thirdSVCView.currentAttendee = nil;
                _thirdSVCView.currentlabel = 0;
                
                if (secondName.length != 0) {
                    _secondNameLabel.text = secondName;
                }else{
                    _secondNameLabel.text = secondNumber;
                }
            }else{
                if (watchAttendees.count > 3) {
                    _previousPageBtn.hidden = NO;
                    _nextPageBtn.hidden = NO;
                }
                
                BOOL isNeedUpdateWatch1 = YES;
                BOOL isNeedUpdateWatch2 = YES;
                BOOL isNeedUpdateWatch3 = YES;
                for (ConfAttendeeInConf* attendeeInfo in watchAttendees) {
                    if([attendeeInfo.number isEqualToString:_firstSVCView.currentAttendee.number]){
                        isNeedUpdateWatch1 = NO;
                    }
                    if([attendeeInfo.number isEqualToString:_secondSVCView.currentAttendee.number]){
                        isNeedUpdateWatch2 = NO;
                    }
                    if([attendeeInfo.number isEqualToString:_thirdSVCView.currentAttendee.number]){
                        isNeedUpdateWatch3 = NO;
                    }
                }
                
                if (isNeedUpdateWatch1 || isNeedUpdateWatch2 || isNeedUpdateWatch3) {
                    [self updateWatchAttendeesWithPage:_currentWatchPage bigViewNumber:@""];
                }
                
                if (thirdName.length != 0) {
                    _thirdNameLabel.text = thirdName;
                }else{
                    _thirdNameLabel.text = thirdNumber;
                }
                if (secondName.length != 0) {
                    _secondNameLabel.text = secondName;
                }else{
                    _secondNameLabel.text = secondNumber;
                }
            }
        }
    }
    
    
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
        _isEnterBackground = NO;
        _currentConfMode = EC_CONF_MODE_FIXED;
        _currentWatchPage = 0;
        _currentNameWith = 0;
        _currentNameHeight = 0;
        self.confCtrlArray = [[NSMutableArray alloc] init];
        self.currentAttendeeWatchArray = [[NSArray alloc] init];
        [ECSDKProgressHud shareInstance];
        
//        [[NSNotificationCenter defaultCenter] addObserver:self
//                                                 selector:@selector(tupLocalVideoViewRefreshViewWithCallId:)
//                                                     name:TUP_CALL_REFRESH_VIEW_NOTIFY
//                                                   object:nil];
//        [[NSNotificationCenter defaultCenter] addObserver:self
//                                                 selector:@selector(tupRemoteVideoViewDecodeSuccessWithCallId:)
//                                                     name:TUP_CALL_DECODE_SUCCESS_NOTIFY
//                                                   object:nil];
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
    
    if ([self isVideoConf]) {
        [[DeviceMotionManager sharedInstance] startDeviceMotionManager];
//        [CommonUtils setToOrientation:UIDeviceOrientationLandscapeLeft];
    }else{
        [CommonUtils setToOrientation:UIDeviceOrientationPortrait];
    }
    if ([ManagerService confService].currentJoinConfIndInfo.isSvcConf) {
        [self updateWatchAttendeesWithPage:_currentWatchPage bigViewNumber:@""];
        [self confAttendeeUpdateAction];
    }
    _currentAttendeeWatchArray = [NSArray arrayWithArray:[ManagerService confService].watchAttendeesArray];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

//    [[DeviceMotionManager sharedInstance] stopDeviceMotionManager];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor clearColor];
    
    if ([self isVideoConf]) {
        [self.view insertSubview:self.backImageView belowSubview:self.bottomView];
        
        if ([ManagerService confService].currentJoinConfIndInfo.isSvcConf) {
            [self.view insertSubview:self.localBigView aboveSubview:self.backImageView];
            [self.view insertSubview:self.remoteView aboveSubview:self.localBigView];
            [self.view insertSubview:self.backSVCView aboveSubview:_remoteView];
            [self.view addSubview:self.bigViewNameLabel];
        }else{
            [self.view insertSubview:self.remoteView aboveSubview:self.backImageView];
            [self.view addSubview:self.localViewShower];
            _localViewShower.frame = CGRectMake(5, 64 + 5, 95, 126);
            _localView.frame = CGRectMake(0, 0, 95, 126);
        }
        
        [self.barView addSubview:self.attendCameraChooseBtn];
        
    }else{
        [self.view insertSubview:self.audioBackImageView belowSubview:self.bottomView];
    }
    
    if ([self isVideoConf]) {
        [self updateBtnViewFrame];
    }else{
        [self configBottomViewBtnsWithWidth:SCREEN_WIDTH];
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
    
    [self.view addSubview:self.signalBackView];
    [self.view addSubview:self.signalBtn];
    if (![self isVideoConf]) {
        self.signalBackView.frame = CGRectMake(0, 0, 365, 365);
        self.signalDataScrollView.frame = CGRectMake(0, 0, 365, 365);
        self.signalBackView.center = CGPointMake(SCREEN_WIDTH/2, SCREEN_HIGHT/2);
        self.signalBtn.frame = CGRectMake(SCREEN_WIDTH - 50, 60, 30, 30);
    }
    
    
    BOOL isSuccess = [[ManagerService callService] switchCameraIndex:[CallWindowController shareInstance].cameraCaptureIndex callId:[ManagerService confService].currentCallId];
    if (isSuccess) {
        [[CallWindowController shareInstance] deviceMotionOrientationChanged];
    }
    
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

- (BOOL)isInterfaceOrientationPortrait
{
    UIInterfaceOrientation interface = [UIApplication sharedApplication].statusBarOrientation;
    if (interface == UIInterfaceOrientationPortrait) {
        return YES;
    }
    return NO;
}

- (void)configBottomViewBtnsWithWidth:(CGFloat)width {

    self.voiceBtn.frame = CGRectMake(width/2-35, 0, 50, 70);
    [self changeBtnContent:self.voiceBtn];
    
    self.attendeeListBtn.frame = CGRectMake(width/2+35, 0, 50, 70);
    [self changeBtnContent:self.attendeeListBtn];
    
    self.muteBtn.frame = CGRectMake(width/2-105, 0, 50, 70);
    [self changeBtnContent:self.muteBtn];
    
    self.moreBtn.frame = CGRectMake(width/2+105, 0, 50, 70);
    [self changeBtnContent:self.moreBtn];
    
    self.endBtn.frame = CGRectMake(width/2-175, 0, 50, 70);
    [self changeBtnContent:self.endBtn];
    
    [self.bottomView addSubview:self.voiceBtn];
    [self.bottomView addSubview:self.muteBtn];
    [self.bottomView addSubview:self.attendeeListBtn];
    [self.bottomView addSubview:self.moreBtn];
    [self.bottomView addSubview:self.endBtn];
    
}

- (void)moreBtnPressed
{
    [self updateConfCtrlArray];
    if (_confCtrlTableViewBackFullScreenView) {
        CGFloat backViewX = SCREEN_HIGHT-5-264;
        if ([self isInterfaceOrientationPortrait]) {
            backViewX = SCREEN_WIDTH-5-264;
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
    _currentAttendeeWatchArray = [NSArray arrayWithArray:[ManagerService confService].watchAttendeesArray];
    [self.confCtrlArray removeAllObjects];
    if ([self isVideoConf]) {
        [self.confCtrlArray addObject:@"Camera Change"];
        
        if (self.selfConfInfo.role == CONF_ROLE_CHAIRMAN) {
            [self.confCtrlArray addObject:@"Set Conf Mode"];
        }
        
        if ([CallWindowController shareInstance].cameraClose) {
            [self.confCtrlArray addObject:@"Camera Open"];
        }else{
            [self.confCtrlArray addObject:@"Camera Close"];
        }
        if (_localViewShower.hidden) {
            [self.confCtrlArray addObject:@"Show LocalView"];
        }else{
            [self.confCtrlArray addObject:@"Hide LocalView"];
        }
        
        if ([ManagerService confService].currentJoinConfIndInfo.isSvcConf) {
            if (_currentAttendeeWatchArray.count > 0) {
                if (_backSVCView.hidden) {
                    [self.confCtrlArray addObject:@"Show SVCView"];
                }else{
                    [self.confCtrlArray addObject:@"Hide SVCView"];
                }
            }
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
    
    if (@available(iOS 12, *)) {
        EC_CONF_MEDIATYPE mediaType = [ManagerService confService].currentConfBaseInfo.media_type;
        if (mediaType == CONF_MEDIATYPE_VIDEO_DATA || mediaType == CONF_MEDIATYPE_DATA) {
            NSString *shareString = @"Screen Share";
            if ([ManagerService confService].mIsScreenSharing) {
                shareString = @"Stop Share";
            }
            [self.confCtrlArray addObject:shareString];
        }
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

- (UILabel *)bigViewNameLabel
{
    if (nil == _bigViewNameLabel) {
        _bigViewNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 150, 100, 150 , 30)];
        _localNameLabel.font = [UIFont systemFontOfSize:12.0];
        _bigViewNameLabel.textColor = [UIColor whiteColor];
    }
    return _bigViewNameLabel;
}

-(UILabel *)localNameLabel
{
    if (nil == _localNameLabel) {
        _localNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, (SCREEN_WIDTH - 60) / 4, 20)];
        _localNameLabel.font = [UIFont systemFontOfSize:10.0];
        _localNameLabel.textColor = [UIColor blueColor];
    }
    return _localNameLabel;
}

-(UILabel *)firstNameLabel
{
    if (nil == _firstNameLabel) {
        _firstNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, (SCREEN_WIDTH - 60) / 4, 20)];
        _firstNameLabel.font = [UIFont systemFontOfSize:10.0];
        _firstNameLabel.textColor = [UIColor whiteColor];
    }
    return _firstNameLabel;
}

-(UILabel *)secondNameLabel
{
    if (nil == _secondNameLabel) {
        _secondNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, (SCREEN_WIDTH - 60) / 4, 20)];
        _secondNameLabel.font = [UIFont systemFontOfSize:10.0];
        _secondNameLabel.textColor = [UIColor whiteColor];
    }
    return _secondNameLabel;
}

-(UILabel *)thirdNameLabel
{
    if (nil == _thirdNameLabel) {
        _thirdNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, (SCREEN_WIDTH - 60) / 4, 20)];
        _thirdNameLabel.font = [UIFont systemFontOfSize:10.0];
        _thirdNameLabel.textColor = [UIColor whiteColor];
    }
    return _thirdNameLabel;
}

-(ImageViewBtn *)previousPageBtn
{
    if (nil == _previousPageBtn) {
        _previousPageBtn = [[ImageViewBtn alloc] initWithFrame:CGRectMake(0, 40, 30, 35)];
        [_previousPageBtn setImage:[UIImage imageNamed:@"image_conf_video_watch_previous_page"] forState:UIControlStateNormal];
        _previousPageBtn.contentMode = UIViewContentModeScaleAspectFill;
        [_previousPageBtn addTarget:self action:@selector(previousPageAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _previousPageBtn;
}

- (void)previousPageAction
{
    if (_currentWatchPage == 0) {
        [[ECSDKProgressHud shareInstance] makeProgressHUD:@"first page" duration:1];
        return;
    }
    if (_currentWatchPage > 0) {
        _currentWatchPage --;
    }
    
    [self updateWatchAttendeesWithPage:_currentWatchPage bigViewNumber:@""];
}

-(ImageViewBtn *)nextPageBtn
{
    if (nil == _nextPageBtn) {
        _nextPageBtn = [[ImageViewBtn alloc] initWithFrame:CGRectMake(SCREEN_WIDTH -30 , 40, 30, 35)];
        [_nextPageBtn setImage:[UIImage imageNamed:@"image_conf_video_watch_next_page"] forState:UIControlStateNormal];
        _nextPageBtn.contentMode = UIViewContentModeScaleAspectFill;
        [_nextPageBtn addTarget:self action:@selector(nextPageAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _nextPageBtn;
}

- (void)nextPageAction
{
    NSInteger maxCurrentpage = [ManagerService confService].watchAttendeesArray.count / 3;
    if (maxCurrentpage < 1 || maxCurrentpage == _currentWatchPage) {
        [[ECSDKProgressHud shareInstance] makeProgressHUD:@"last page" duration:1];
        
        return;
    }
    if (_currentWatchPage < maxCurrentpage) {
        _currentWatchPage ++;
    }
    
    [self updateWatchAttendeesWithPage:_currentWatchPage bigViewNumber:@""];
}

- (UIView *)localViewShower {
    if (nil == _localViewShower) {
        _localViewShower = [[UIView alloc]initWithFrame:CGRectMake(30, 5, (SCREEN_WIDTH - 60) / 4, 105)];
        _localViewShower.backgroundColor = [UIColor blueColor];
//        _localViewShower.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"image_conf_video_small_video_back"]];
        [_localViewShower addSubview:self.localView];
        [_localViewShower addSubview:self.localNameLabel];
    }
    return _localViewShower;
}

-(EAGLView *)localView{
    if (nil == _localView) {
        _localView = [EAGLView getLocalView];
        _localView.frame = CGRectMake(0, 0, (SCREEN_WIDTH - 60) / 4, 105);
    }
    return _localView;
}

- (UIView *)backSVCView
{
    if (nil == _backSVCView) {
        _backSVCView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HIGHT - 200, SCREEN_WIDTH, 115)];
        _backSVCView.hidden = NO;
//        _backSVCView.backgroundColor = [UIColor whiteColor];
        [_backSVCView addSubview:self.localViewShower];
        [_backSVCView addSubview:self.firstSVCViewShower];
        [_backSVCView addSubview:self.secondSVCViewShower];
        [_backSVCView addSubview:self.thirdSVCViewShower];
        
        [_backSVCView addSubview:self.previousPageBtn];
        [_backSVCView addSubview:self.nextPageBtn];
    }
    return _backSVCView;
}

- (void)svcAlertActionWithNumber:(NSString *)number name:(NSString *)name
{
    NSString *tipString = name.length != 0 ? name : number;
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Tips"
                                                                             message:[NSString stringWithFormat:@"watch %@'s video?", tipString]
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"Sure"
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * _Nonnull action) {
                                                           [self updateWatchAttendeesWithPage:_currentWatchPage bigViewNumber:number];
                                                       }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleDefault
                                                         handler:nil];
    [alertController addAction:sureAction];
    [alertController addAction:cancelAction];
    [self.navigationController presentViewController:alertController animated:YES completion:nil];
}

- (void)firstSVCViewDoubleTapAction
{
    [self svcAlertActionWithNumber:_firstSVCView.currentAttendee.number name:_firstSVCView.currentAttendee.name];
}

-(UIView *)firstSVCViewShower
{
    if (nil == _firstSVCViewShower) {
        _firstSVCViewShower = [[UIView alloc]initWithFrame:CGRectMake((SCREEN_WIDTH - 60) / 4 + 30, 5, (SCREEN_WIDTH - 60) / 4, 105)];
        [_firstSVCViewShower addSubview:self.firstSVCView];
        [_firstSVCViewShower addSubview:self.firstNameLabel];
        
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(firstSVCViewDoubleTapAction)];
        doubleTap.numberOfTapsRequired = 2;
        [_firstSVCViewShower addGestureRecognizer:doubleTap];
        
//        _firstSVCViewShower.backgroundColor = [UIColor greenColor];
    }
    return _firstSVCViewShower;
}

-(EAGLView *)firstSVCView{
    if (nil == _firstSVCView) {
        _firstSVCView = [EAGLView getFirstSVCView];
        _firstSVCView.frame = CGRectMake(0, 0, (SCREEN_WIDTH - 60) / 4, 105);
    }
    return _firstSVCView;
}

- (void)secondSVCViewDoubleTapAction
{
    [self svcAlertActionWithNumber:_secondSVCView.currentAttendee.number name:_secondSVCView.currentAttendee.name];
}

-(UIView *)secondSVCViewShower
{
    if (nil == _secondSVCViewShower) {
        _secondSVCViewShower = [[UIView alloc]initWithFrame:CGRectMake((SCREEN_WIDTH - 60) / 4 * 2 + 30, 5 , (SCREEN_WIDTH - 60) / 4, 105)];
        [_secondSVCViewShower addSubview:self.secondSVCView];
        [_secondSVCViewShower addSubview:self.secondNameLabel];
        
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(secondSVCViewDoubleTapAction)];
        doubleTap.numberOfTapsRequired = 2;
        [_secondSVCViewShower addGestureRecognizer:doubleTap];
        
//        _secondSVCViewShower.backgroundColor = [UIColor yellowColor];
    }
    return _secondSVCViewShower;
}

-(EAGLView *)secondSVCView
{
    if (nil == _secondSVCView) {
        _secondSVCView = [EAGLView getSecondSVCView];
        _secondSVCView.frame = CGRectMake(0, 0, (SCREEN_WIDTH - 60) / 4, 105);
    }
    return _secondSVCView;
}

- (void)thirdSVCViewDoubleTapAction
{
    [self svcAlertActionWithNumber:_thirdSVCView.currentAttendee.number name:_thirdSVCView.currentAttendee.name];
}

-(UIView *)thirdSVCViewShower
{
    if (nil == _thirdSVCViewShower) {
        _thirdSVCViewShower = [[UIView alloc]initWithFrame:CGRectMake((SCREEN_WIDTH - 60) / 4 * 3 + 30, 5 , (SCREEN_WIDTH - 60) / 4, 105)];
        [_thirdSVCViewShower addSubview:self.thirdSVCView];
        [_thirdSVCViewShower addSubview:self.thirdNameLabel];
        
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(thirdSVCViewDoubleTapAction)];
        doubleTap.numberOfTapsRequired = 2;
        [_thirdSVCViewShower addGestureRecognizer:doubleTap];
        
//        _thirdSVCViewShower.backgroundColor = [UIColor grayColor];
    }
    return _thirdSVCViewShower;
}

-(EAGLView *)thirdSVCView
{
    if (nil == _thirdSVCView) {
        _thirdSVCView = [EAGLView getThirdSVCView];
        _thirdSVCView.frame = CGRectMake(0, 0, (SCREEN_WIDTH - 60) / 4, 105);
    }
    return _thirdSVCView;
}

-(EAGLView *)remoteView {
    if (nil == _remoteView) {
        _remoteView = [EAGLView getRemoteView];
    }
    return _remoteView;
}

- (EAGLView *)localBigView
{
    if (nil == _localBigView) {
        _localBigView = [EAGLView getLocalBigView];
    }
    return _localBigView;
}

- (void)updateBtnViewFrame
{
    if ([self isVideoConf]) {
        CGFloat width = 0;
        CGFloat hight = 0;

        UIInterfaceOrientation interface2 = [UIApplication sharedApplication].statusBarOrientation;

        if (interface2 == UIInterfaceOrientationPortrait) {
            width = SCREEN_WIDTH;
            hight = SCREEN_HIGHT;

            self.signalBackView.frame = CGRectMake(0, 0, 365, 365);
            self.signalDataScrollView.frame = CGRectMake(0, 0, 365, 365);
            self.signalBackView.center = CGPointMake(width/2, hight/2);
            self.signalBtn.frame = CGRectMake(width - 50, 60, 30, 30);
            
            [self configBottomViewBtnsWithWidth:width];
            if (nil != _remoteView) {
                _remoteView.frame = CGRectMake(0, 0, width, hight);
            }

            if ([ManagerService confService].currentJoinConfIndInfo.isSvcConf) {
                
                if (nil != _localBigView) {
                    _localBigView.frame = CGRectMake(0, 0, width, hight);
                }
                
                _backSVCView.frame = CGRectMake(0, hight - 200, width, 115);
                _localViewShower.frame = CGRectMake(30, 5, (width - 60) / 4, 105);
                _localView.frame = CGRectMake(0, 0, (width - 60) / 4, 105);
                _firstSVCViewShower.frame = CGRectMake((width - 60) / 4 + 30, 5, (width - 60) / 4, 105);
                _firstSVCView.frame = CGRectMake(0, 0, (width - 60) / 4, 105);
                _secondSVCViewShower.frame = CGRectMake((width - 60) / 4 * 2 + 30, 5 , (width - 60) / 4, 105);
                _secondSVCView.frame = CGRectMake(0, 0, (width - 60) / 4, 105);
                _thirdSVCViewShower.frame = CGRectMake((width - 60) / 4 * 3 + 30, 5 , (width - 60) / 4, 105);
                _thirdSVCView.frame = CGRectMake(0, 0, (width - 60) / 4, 105);
                
                _previousPageBtn.frame = CGRectMake(0, 40, 30, 35);
                _nextPageBtn.frame = CGRectMake(width - 30 , 40, 30, 35);
                [_previousPageBtn setImage:[UIImage imageNamed:@"image_conf_video_watch_previous_page"] forState:UIControlStateNormal];
                [_nextPageBtn setImage:[UIImage imageNamed:@"image_conf_video_watch_next_page"] forState:UIControlStateNormal];
                
                _bigViewNameLabel.frame = CGRectMake(width - _currentNameWith, 100, _currentNameWith , _currentNameHeight);
                
            }else{
                if (nil != _localViewShower) {
                    _localViewShower.frame = CGRectMake(5, 64 + 5, 95, 126);
                    _localView.frame = CGRectMake(0, 0, 95, 126);
                }
            }
            
        }else if (interface2 == UIInterfaceOrientationLandscapeLeft || interface2 == UIInterfaceOrientationLandscapeRight)
        {
            width = SCREEN_HIGHT;
            hight = SCREEN_WIDTH;
            
            self.signalBackView.frame = CGRectMake(0, 0, 365+200, 365);
            self.signalDataScrollView.frame = CGRectMake(0, 0, 365+200, 365);
            self.signalBackView.center = CGPointMake(width/2, hight/2);
            
            self.signalBtn.frame = CGRectMake(width - 50, 60, 30, 30);
            
            [self configBottomViewBtnsWithWidth:width];
            if (nil != _remoteView) {
                _remoteView.frame = CGRectMake(0, 0, width, hight);
            }
            
            if ([ManagerService confService].currentJoinConfIndInfo.isSvcConf) {
                
                if (nil != _localBigView) {
                    _localBigView.frame = CGRectMake(0, 0, width, hight);
                }
                
                _backSVCView.frame = CGRectMake(44, 0, 115, hight);
                _localViewShower.frame = CGRectMake(5, 30, 105, (hight - 60) / 4);
                _localView.frame = CGRectMake(0, 0, 105, (hight - 60) / 4);
                _firstSVCViewShower.frame = CGRectMake(5, (hight - 60) / 4 + 30, 105, (hight - 60) / 4);
                _firstSVCView.frame = CGRectMake(0, 0, 105, (hight - 60) / 4);
                _secondSVCViewShower.frame = CGRectMake(5 , (hight - 60) / 4 * 2 + 30, 105, (hight - 60) / 4);
                _secondSVCView.frame = CGRectMake(0, 0, 105, (hight - 60) / 4);
                _thirdSVCViewShower.frame = CGRectMake(5 , (hight - 60) / 4 * 3 + 30, 105, (hight - 60) / 4);
                _thirdSVCView.frame = CGRectMake(0, 0, 105, (hight - 60) / 4);
                
                _previousPageBtn.frame = CGRectMake(40, 0, 30, 35);
                _nextPageBtn.frame = CGRectMake(40, hight -30, 30, 35);
                [_previousPageBtn setImage:[UIImage imageNamed:@"image_conf_video_watch_previous_page_up"] forState:UIControlStateNormal];
                [_nextPageBtn setImage:[UIImage imageNamed:@"image_conf_video_watch_next_page_down"] forState:UIControlStateNormal];
                
                _bigViewNameLabel.frame = CGRectMake(width - _currentNameWith, 100, _currentNameWith , _currentNameHeight);
                
            }else{
                if (nil != _localViewShower) {
                    _localViewShower.frame = CGRectMake(5, 64 + 5, 126, 95);
                    _localView.frame = CGRectMake(0, 0, 126, 95);
                }
            }
        }
        
        if (nil != _attendTableViewBackImageView) {
            CGFloat backViewX = width-5-264;
            CGFloat hight1 = [self heightOfRealTableView];
            _attendTableViewBackFullScreenView.frame = CGRectMake(0, 0, width, hight);
            _attendTableViewBackImageView.frame = CGRectMake(backViewX, 65, 264, hight1 + 2*5);
            
        }
        
        if (nil != _confCtrlTableViewBackImageView) {
            CGFloat backViewX = width-5-264;
            
            CGFloat hight2 = [self heightOfConfCtrlRealTableView];
            CGRect frame = CGRectMake(backViewX, self.view.frame.size.height - 100 - hight2 + 2*5, 264, hight2 + 2*5);
            _confCtrlTableViewBackImageView.frame = frame;
            _confCtrlTableViewBackFullScreenView.frame = CGRectMake(0, 0, width, hight);
        }
        
        if (_attendCameraChooseBtn != nil) {
            [_attendCameraChooseBtn setFrame:CGRectMake(width-40, 15, 34, 34)];
        }
        
        if (_confDataShareBtn != nil) {
            CGFloat DateShareBtnwidth = width - 40;
            if ([self isVideoConf]) {
                DateShareBtnwidth = width - 80;
                
            }
            [_confDataShareBtn setFrame:CGRectMake(DateShareBtnwidth, 15, 34, 34)];
        }
        
    }
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
        _attendeeListBtn = [self createButtonByImage:[UIImage imageNamed:@"participant_list"] highlightImage:nil title:@"List" target:self action:@selector(attendeeListBtnPressed)];
    }
    return _attendeeListBtn;
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
        
        CGFloat width = SCREEN_WIDTH - 40;
        if ([self isVideoConf]) {
            width = SCREEN_HIGHT - 80;
            if ([self isInterfaceOrientationPortrait]) {
                width = SCREEN_WIDTH - 80;
            }
        }
        [_confDataShareBtn setFrame:CGRectMake(width, 15, 34, 34)];
        
        [_confDataShareBtn addTarget:self action:@selector(confDataShareBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_confDataShareBtn addSubview:_confDataShareImageView];
        _confDataShareImageView.center = CGPointMake(17, 17);
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
        CGFloat backViewX = SCREEN_HIGHT - 5 -264;
        if ([self isInterfaceOrientationPortrait]) {
            backViewX = SCREEN_WIDTH-5-264;
        }
        [_attendCameraChooseBtn setFrame:CGRectMake(backViewX-40, 15, 34, 34)];
    }
    return _attendCameraChooseBtn;
}

- (void)attendCameraChooseBtnClicked:(id)sender {
    _currentAttendeeWatchArray = [NSArray arrayWithArray:[ManagerService confService].watchAttendeesArray];
    if (_attendTableViewBackFullScreenView) {
        CGFloat backViewX = SCREEN_HIGHT-5-264;
        if ([self isInterfaceOrientationPortrait]) {
            backViewX = SCREEN_WIDTH-5-264;
        }
        CGFloat hight = [self heightOfRealTableView];
        
        _attendTableViewBackImageView.frame = CGRectMake(backViewX, 65, 264, hight+ 2*5);
        _attendTableView.frame = CGRectMake(5, 5, 254, hight);

        _attendTableViewBackFullScreenView.hidden = ! _attendTableViewBackFullScreenView.hidden;
    }
    else{
        NSInteger count = _currentAttendeeWatchArray.count;
        if (count > 0) {
            if ([self isVideoConf]) {
                [self.view addSubview:self.attendTableViewBackFullScreenView];
            }
        }
    }
    [self.attendTableView reloadData];
}

- (UIView *)attendTableViewBackFullScreenView {
    if(nil == _attendTableViewBackFullScreenView) {
        if ([self isInterfaceOrientationPortrait]) {
            _attendTableViewBackFullScreenView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HIGHT)];
        }else{
            _attendTableViewBackFullScreenView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_HIGHT, SCREEN_WIDTH)];
        }
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
        CGFloat backViewX = SCREEN_HIGHT-5-264;
        if ([self isInterfaceOrientationPortrait]) {
            backViewX = SCREEN_WIDTH-5-264;
        }
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
    _currentAttendeeWatchArray = [NSArray arrayWithArray:[ManagerService confService].watchAttendeesArray];
    NSInteger rowNumber = _currentAttendeeWatchArray.count + 1;
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
    if (![self isVideoConf]) {
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
    if (![self isVideoConf]) {
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
    if (![self isVideoConf]) {
        DDLogInfo(@"not tup video conf,ignore!");
        return;
    }
    NSNumber *callidNumber = notify.object;
    unsigned int callid = [callidNumber unsignedIntValue];
    if ([ManagerService confService].currentCallId != callid) {
        DDLogInfo(@"call id is not equal to mcu conf callid, ignore!");
        return;
    }
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf updateLocalViewInTupVideoConf:YES];
    });
}

- (void)tupRemoteVideoViewDecodeSuccessWithCallId:(NSNotification *)notify {
    if (![self isVideoConf]) {
        DDLogInfo(@"not tup video conf,ignore!");
        return;
    }
    NSNumber *callidNumber = notify.object;
    unsigned int callid = [callidNumber unsignedIntValue];
    if ([ManagerService confService].currentCallId != callid) {
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
        count = _currentAttendeeWatchArray.count + 1;
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
        if (indexPath.row == 0) {
            cell.textLabel.text = @"Main Conf Hall";
        }else{
            ConfAttendeeInConf *attendee = _currentAttendeeWatchArray[indexPath.row - 1];
            NSString *name = attendee.name;
            if (name.length == 0) {
                name = attendee.number;
            }
            if (attendee.isSelf) {
                cell.textLabel.text = [NSString stringWithFormat:@"%@(me)", name];
            }else {
                cell.textLabel.text = [NSString stringWithFormat:@"%@", name];
            }
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
        if (indexPath.row == 0) {
            if ([ManagerService confService].currentJoinConfIndInfo.isSvcConf) {
                [self updateWatchAttendeesWithPage:_currentWatchPage bigViewNumber:@""];
            }else{
                [[ManagerService confService] watchAttendeeNumber:@""];
            }
            
        }
        else
        {
            ConfAttendeeInConf *attendee = _currentAttendeeWatchArray[indexPath.row - 1];
            if ([self isVideoConf]) {
                //            if ([self isSelfMaster]) {
                //                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Tips"
                //                                                                                         message:[NSString stringWithFormat:@"Broadcast %@'s video?", attendee.number]
                //                                                                                  preferredStyle:UIAlertControllerStyleAlert];
                //                UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"Sure"
                //                                                                     style:UIAlertActionStyleDefault
                //                                                                   handler:^(UIAlertAction * _Nonnull action) {
                //                                                                       [[ManagerService confService] broadcastAttendee:attendee.number isBoardcast:YES];
                //                                                                   }];
                //                UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                //                                                                       style:UIAlertActionStyleDefault
                //                                                                     handler:nil];
                //                [alertController addAction:sureAction];
                //                [alertController addAction:cancelAction];
                //                [self.navigationController presentViewController:alertController animated:YES completion:nil];
                //            }
                //            else
                //            {
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Tips"
                                                                                         message:[NSString stringWithFormat:@"watch %@'s video?", attendee.number]
                                                                                  preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"Sure"
                                                                     style:UIAlertActionStyleDefault
                                                                   handler:^(UIAlertAction * _Nonnull action) {
                                                                       if ([ManagerService confService].currentJoinConfIndInfo.isSvcConf) {
                                                                           
                                                                           [self updateWatchAttendeesWithPage:_currentWatchPage bigViewNumber:attendee.number];
                                                                       }else{
                                                                           //watch attendee todo jl
                                                                           [[ManagerService confService] watchAttendeeNumber:attendee.number];
                                                                       }
                                                                       
                                                                   }];
                UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                                       style:UIAlertActionStyleDefault
                                                                     handler:nil];
                [alertController addAction:sureAction];
                [alertController addAction:cancelAction];
                [self.navigationController presentViewController:alertController animated:YES completion:nil];
                //            }
            }
        }
        
    }
    if (tableView == _confCtrlTableView) {
        NSString *confCtrlAction = self.confCtrlArray[indexPath.row];
        if ([confCtrlAction isEqualToString:@"Camera Change"]) {
            if (![CallWindowController shareInstance].cameraClose) {
                if ([self isVideoConf]) {
                    NSInteger cameraCaptureIndex = [CallWindowController shareInstance].cameraCaptureIndex;
                    cameraCaptureIndex = cameraCaptureIndex == 1 ? 0 : 1;
                    BOOL isSuccess = [[ManagerService callService] switchCameraIndex:cameraCaptureIndex callId:[ManagerService confService].currentCallId];
                    if (isSuccess) {
                        [CallWindowController shareInstance].cameraCaptureIndex = cameraCaptureIndex;
//                        [[CallWindowController shareInstance] deviceMotionOrientationChanged];
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
                BOOL isCameraClose = [CallWindowController shareInstance].cameraClose;
                [[ManagerService callService] switchCameraOpen:isCameraClose callId:[ManagerService confService].currentCallId];
                [CallWindowController shareInstance].cameraClose = !isCameraClose;
            }
        }
        if ([confCtrlAction isEqualToString:@"Set Conf Mode"]) {
            [self setConfModeBtnClicked:nil];
        }
        
        if ([confCtrlAction isEqualToString:@"Screen Share"]) {
            [self startSharingScreen];
        }
        
        if ([confCtrlAction isEqualToString:@"Stop Share"]) {
            [self stopSharingScreen];
        }
        
        if ([confCtrlAction isEqualToString:@"Show SVCView"]) {
            self.backSVCView.hidden = NO;
            [self updateWatchAttendeesWithPage:_currentWatchPage bigViewNumber:@""];
        }
        if ([confCtrlAction isEqualToString:@"Hide SVCView"]) {
            self.backSVCView.hidden = YES;
        }
    }
}

- (void)addAttendeeAction
{
    UIAlertController *alertCon = [UIAlertController alertControllerWithTitle:nil message:@"Please enter participant number" preferredStyle:UIAlertControllerStyleAlert];
    [alertCon addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Number";
        textField.secureTextEntry = NO;
    }];
    [alertCon addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Name";
        textField.secureTextEntry = NO;
    }];
    [alertCon addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Account";
        textField.secureTextEntry = NO;
    }];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UITextField *numberFiled = alertCon.textFields.firstObject;
        UITextField *nameFiled = alertCon.textFields[1];
        UITextField *accountField = alertCon.textFields[2];
        
        NSString *number = numberFiled.text;
        NSString *name = nameFiled.text;
        NSString *account = accountField.text;
        
        ConfAttendee *cAttendee = [[ConfAttendee alloc]init];
        cAttendee.number = number;
        cAttendee.name = name ? name : number;
        cAttendee.account = account;
        NSArray *addAttendeeArray = @[cAttendee];
        if (cAttendee.number != nil && cAttendee.number.length > 0) {
            [[ManagerService confService] confCtrlAddAttendeeToConfercene:addAttendeeArray];
        }
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
    return [ManagerService confService].isVideoConfInvited;
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
        
        CGFloat backViewX = SCREEN_HIGHT-5-264;
        if ([self isInterfaceOrientationPortrait]) {
            backViewX = SCREEN_WIDTH-5-264;
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
        if ([self isInterfaceOrientationPortrait]) {
            _confCtrlTableViewBackFullScreenView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HIGHT)];
        }else{
            _confCtrlTableViewBackFullScreenView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_HIGHT, SCREEN_WIDTH)];
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


- (void)startSharingScreen {
    DDLogInfo(@"MainViewController startSharingScreen ");
    // 开始replaykit
    
    [[ManagerService confService]inviteDataShareWithNumber:[ManagerService confService].selfJoinNumber];
}

- (void)stopSharingScreen {
    DDLogInfo(@"MainViewController stopSharingScreen ");
    
    [[ManagerService confService] confStopReplayKitBroadcast];
    
}


- (void)updateWatchAttendeesWithPage:(NSInteger)page bigViewNumber:(NSString *)number
{
    NSArray *attendeeArray = [ManagerService confService].watchAttendeesArray;
    NSArray *labelArray1 = [ManagerService confService].currentJoinConfIndInfo.svcLable;
    
    NSInteger startIndex = page * 3;
    if (startIndex + 3 > attendeeArray.count) {
        startIndex = attendeeArray.count - 3;
    }
    
    if (attendeeArray.count == 1) {
        _firstSVCView.currentAttendee = (ConfAttendeeInConf *)attendeeArray[0];
        _firstSVCView.currentlabel = [labelArray1[1] integerValue];;
        
        NSMutableArray *numberArray = [[NSMutableArray alloc] init];
        [numberArray addObject:number];
        [numberArray addObject:((ConfAttendeeInConf *)attendeeArray[0]).number];
        
        NSMutableArray *labelArray = [[NSMutableArray alloc] init];
        [labelArray addObject:labelArray1[0]];
        [labelArray addObject:labelArray1[1]];
        
        [[ManagerService confService] watchAttendeeNumberArray:numberArray labelArray:labelArray];
    }
    if (attendeeArray.count == 2) {
        _firstSVCView.currentAttendee = (ConfAttendeeInConf *)attendeeArray[0];
        _firstSVCView.currentlabel = [labelArray1[1] integerValue];
        _secondSVCView.currentAttendee = (ConfAttendeeInConf *)attendeeArray[1];
        _secondSVCView.currentlabel = [labelArray1[2] integerValue];
        
        
        NSMutableArray *numberArray = [[NSMutableArray alloc] init];
        [numberArray addObject:number];
        [numberArray addObject:((ConfAttendeeInConf *)attendeeArray[0]).number];
        [numberArray addObject:((ConfAttendeeInConf *)attendeeArray[1]).number];
        
        NSMutableArray *labelArray = [[NSMutableArray alloc] init];
        [labelArray addObject:labelArray1[0]];
        [labelArray addObject:labelArray1[1]];
        [labelArray addObject:labelArray1[2]];
        
        [[ManagerService confService] watchAttendeeNumberArray:numberArray labelArray:labelArray];
        
    }
    if (attendeeArray.count >= 3) {
        _firstSVCView.currentAttendee = (ConfAttendeeInConf *)attendeeArray[startIndex];
        _firstSVCView.currentlabel = [labelArray1[1] integerValue];
        _secondSVCView.currentAttendee = (ConfAttendeeInConf *)attendeeArray[startIndex + 1];
        _secondSVCView.currentlabel = [labelArray1[2] integerValue];
        _thirdSVCView.currentAttendee = (ConfAttendeeInConf *)attendeeArray[startIndex + 2];
        _thirdSVCView.currentlabel = [labelArray1[3] integerValue];
        
        
        NSMutableArray *numberArray = [[NSMutableArray alloc] init];
        [numberArray addObject:number];
        [numberArray addObject:((ConfAttendeeInConf *)attendeeArray[startIndex]).number];
        [numberArray addObject:((ConfAttendeeInConf *)attendeeArray[startIndex + 1]).number];
        [numberArray addObject:((ConfAttendeeInConf *)attendeeArray[startIndex + 2]).number];
        
        NSMutableArray *labelArray = [[NSMutableArray alloc] init];
        [labelArray addObject:labelArray1[0]];
        [labelArray addObject:labelArray1[1]];
        [labelArray addObject:labelArray1[2]];
        [labelArray addObject:labelArray1[3]];
        
        [[ManagerService confService] watchAttendeeNumberArray:numberArray labelArray:labelArray];

    }
    
}

@end
