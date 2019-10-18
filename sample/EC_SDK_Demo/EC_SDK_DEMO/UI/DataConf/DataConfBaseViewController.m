//
//  DataConfBaseViewController.m
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

#import "CommonUtils.h"
#import "DataConfBaseViewController.h"
#import "ManagerService.h"
#import "ConfListViewController.h"
#import "ConfBaseInfo.h"
#import "ConfListViewController.h"
#import "ConfRunningViewController.h"

@interface DataConfBaseViewController () {
    BOOL isHideBar;
}

//@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation DataConfBaseViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        NSArray *array = [[ManagerService callService].sipAccount componentsSeparatedByString:@"@"];
        self.selfNumber = array[0];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateSpeakerStatus:) name:NTF_AUDIOROUTE_CHANGED object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateCallStatisticInfo:) name:CALL_STATISTIC_INFO_NOTIFY object:nil];
        
    }
    
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (ConfAttendeeInConf *)selfConfInfo {
    for (ConfAttendeeInConf *tempAttendee in [ManagerService confService].haveJoinAttendeeArray)
    {
        if (tempAttendee.isSelf)
        {
            return tempAttendee;
        }
    }
    
    return nil;
}

//- (UIInterfaceOrientationMask)supportedInterfaceOrientations
//{
//    return UIInterfaceOrientationMaskAllButUpsideDown;
//}

-(BOOL)prefersStatusBarHidden {
    return YES;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIView* bottomView = self.bottomView;
    UIView* navi = self.barView;
    id<UILayoutSupport> bottom = self.bottomLayoutGuide;
    NSDictionary* views = NSDictionaryOfVariableBindings(bottomView,navi,bottom);
    NSArray* controlViewVconstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[bottomView(71)]-0-|"
                                                                               options:0
                                                                               metrics:nil
                                                                                 views:views];
    NSArray* controlViewHconstranints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[bottomView]|"
                                                                                options:0
                                                                                metrics:nil
                                                                                  views:views];
    NSArray* naviVconstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[navi(64)]"
                                                                        options:0
                                                                        metrics:nil
                                                                          views:views];
    NSArray* naviHconstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[navi]|"
                                                                        options:0
                                                                        metrics:nil
                                                                          views:views];
    NSArray *hConstraints = [controlViewHconstranints arrayByAddingObjectsFromArray:naviHconstraints];
    NSArray *vConstraints = [controlViewVconstraints arrayByAddingObjectsFromArray:naviVconstraints];
    
    
    [self.view addConstraints:hConstraints];
    [self.view addConstraints:vConstraints];
    
    self.baseTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                           action:@selector(screenTap:)];
    [self.view addGestureRecognizer:self.baseTap];
    
    [self configBasicBtns];
}

-(void)screenTap:(UITapGestureRecognizer*)tap {
    isHideBar = !isHideBar;
    self.bottomView.hidden = isHideBar;
    self.barView.hidden = isHideBar;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
//    [CommonUtils setToOrientation:UIDeviceOrientationLandscapeLeft];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
}

- (UIView *)barView {
    if (!_barView) {
        _barView = [[UIView alloc] initWithFrame:CGRectZero];
        _barView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"dataconf_navbg"]];
        _barView.translatesAutoresizingMaskIntoConstraints = NO;
        
//        UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//        UIImage *backImg = [UIImage imageNamed:@"dataconf_back"];
//        [backBtn setImage:backImg forState:UIControlStateNormal];
//        [backBtn setImage:[UIImage imageNamed:@"dataconf_back_highlight"] forState:UIControlStateHighlighted];
//        
//        backBtn.frame = CGRectMake(0, 12, 40, 40);
//        [backBtn addTarget:self action:@selector(gobackBtnAction) forControlEvents:UIControlEventTouchUpInside];
//        [_barView addSubview:backBtn];
        
//        UITapGestureRecognizer *tapBar = [[UITapGestureRecognizer alloc] initWithTarget:self action:nil];
//        [_barView addGestureRecognizer:tapBar];
        
        //[_barView addSubview:self.timeLabel];
        [_barView addSubview:self.titleLabel];
        
        [self.view addSubview:_barView];
    }
    return _barView;
}

- (UIView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[UIView alloc] initWithFrame:CGRectZero];
        _bottomView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"dataconf_navbg"]];
        _bottomView.translatesAutoresizingMaskIntoConstraints = NO;

//        UITapGestureRecognizer *tapBar = [[UITapGestureRecognizer alloc] initWithTarget:self action:nil];
//        [_bottomView addGestureRecognizer:tapBar];
        
        [self.view addSubview:_bottomView];
    }
    return _bottomView;
}

-(void)back:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

//- (UILabel *)timeLabel {
//    if (!_timeLabel) {
//        _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 32, 300, 24)];
//        _timeLabel.textAlignment = NSTextAlignmentLeft;
//        _timeLabel.text = @"00:00:00";
//        _timeLabel.textColor = [UIColor whiteColor];
//        _timeLabel.font = [UIFont systemFontOfSize:17];
//    }
//    return _timeLabel;
//}

- (UILabel *)titleLabel {
    if (nil == _titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 0, 300, 64)];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.text = [ManagerService confService].currentConfBaseInfo.conf_subject;
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.font = [UIFont systemFontOfSize:17];
    }
    return _titleLabel;
}

#pragma mark - Interface
-(void)configBasicBtns {
    self.voiceBtn = [self createButtonByImage:[UIImage imageNamed:@"dataconf_tab_voice"]
                               highlightImage:nil
                                        title:@"Speak"
                                       target:self
                                       action:@selector(voiceBtnPressed:)];
//    [self.voiceBtn setImage:[UIImage imageNamed:@"conf_tab_voice_selected"] forState:UIControlStateSelected];
    
    self.endBtn   = [self createButtonByImage:[UIImage imageNamed:@"dataconf_tab_quit"]
                               highlightImage:nil
                                        title:@"Quit"
                                       target:self
                                       action:@selector(endBtnPressed:)];
    
    self.muteBtn = [self createButtonByImage:[UIImage imageNamed:@"conf_tab_mute"] highlightImage:nil title:@"Mute" target:self action:@selector(mutebtnPressed:)];
    
}

- (void)mutebtnPressed:(id)sender{
    if([[ManagerService confService] confCtrlMuteAttendee:self.selfConfInfo.number isMute:!self.selfConfInfo.is_mute]){
    }
}

- (void)voiceBtnPressed:(id)sender {
    ROUTE_TYPE routeType = [[ManagerService callService] obtainMobileAudioRoute];
    ROUTE_TYPE configType = routeType == ROUTE_LOUDSPEAKER_TYPE ? ROUTE_DEFAULT_TYPE : ROUTE_LOUDSPEAKER_TYPE;
    if (configType == ROUTE_LOUDSPEAKER_TYPE) {
        [self.voiceBtn setImage:[UIImage imageNamed:@"conf_tab_voice_selected"] forState:UIControlStateSelected];
    }else{
        [self.voiceBtn setImage:[UIImage imageNamed:@"dataconf_tab_voice"] forState:UIControlStateSelected];
    }
    [[ManagerService callService] configAudioRoute:configType];
}

- (void)updateSpeakerStatus:(NSNotification *)notification
{
    ROUTE_TYPE currentRoute = (ROUTE_TYPE)[notification.userInfo[AUDIO_ROUTE_KEY] integerValue];
    _voiceBtn.selected = currentRoute == ROUTE_LOUDSPEAKER_TYPE;
}

-(void)endBtnPressed:(id)sender
{
    BOOL isMaster = [self isSelfMaster];
    if (isMaster) {
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Tip"
                                                                                 message:nil
                                                                          preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *quitAction = [UIAlertAction actionWithTitle:@"Quit"
                                                             style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction *action){
                                                               [self quitConf];
                                                           }];
        [alertController addAction:quitAction];
        
        UIAlertAction *endAction = [UIAlertAction actionWithTitle:@"End"
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction *action){
                                                              [self endConf];
                                                          }];
        [alertController addAction:endAction];
        
        UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                               style:UIAlertActionStyleCancel
                                                             handler:nil];
        [alertController addAction:cancelAction];
        
        [self presentViewController:alertController animated:YES completion:nil];
        
        
        
    }else{
        [self quitConf];
    }
    
}

-(void)endConf{
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Tip"
                                                                             message:@"End the meeting?"
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    __weak typeof(self) weakSelf = self;
    UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"Sure"
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction *action)
    {
        
        if ([ManagerService confService].currentConfBaseInfo.media_type == CONF_MEDIATYPE_DATA || [ManagerService confService].currentConfBaseInfo.media_type == CONF_MEDIATYPE_VIDEO_DATA)
        {
//            BOOL isEndDataConf = [[ManagerService dataConfService] closeDataConference];
//            if (!isEndDataConf) {
//                DDLogInfo(@"End conference(data) failed.");
//            }
//            [[ManagerService dataConfService].remoteCameraInfos removeAllObjects];
//            [[ManagerService dataConfService].localCameraInfos removeAllObjects];
        }
        
        BOOL isEndVoiceConf = [[ManagerService confService] confCtrlEndConference];
        [[ManagerService confService] restoreConfParamsInitialValue];
        
        if (!isEndVoiceConf) {
            DDLogInfo(@"End conference(voice) failed.");
        }
        
        [self performSelector:@selector(goToConfListViewController) withObject:nil afterDelay:0.5];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
    [alertController addAction:sureAction];
    [alertController addAction:cancelAction];
    
    [self.navigationController presentViewController:alertController
                                            animated:YES
                                          completion:nil];
    
}

- (void)goToConfListViewController {
    
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

-(void)quitConf{
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Tip"
                                                                             message:@"Quit"
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    __weak typeof(self) weakSelf = self;
    UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"Sure"
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction *action)
    {
        if ([ManagerService confService].currentConfBaseInfo.media_type == CONF_MEDIATYPE_DATA || [ManagerService confService].currentConfBaseInfo.media_type == CONF_MEDIATYPE_VIDEO_DATA)
        {
//            if (![[ManagerService dataConfService] leaveDataConference]) {
//                DDLogInfo(@"Quit conference(data) failed.");
//            }
//            [[ManagerService dataConfService].remoteCameraInfos removeAllObjects];
//            [[ManagerService dataConfService].localCameraInfos removeAllObjects];
        }
        // 挂断通话
        CallInfo *callInfo = [[ManagerService callService] callInfoWithConfId:[ManagerService confService].currentConfBaseInfo.conf_id];
        [[ManagerService callService] closeCall:callInfo.stateInfo.callId];
        if (![[ManagerService confService] confCtrlLeaveConference]) {
            DDLogInfo(@"Quit conference(voice) failed.");
        }
        
        [[ManagerService confService] restoreConfParamsInitialValue];
        
        [weakSelf performSelector:@selector(goToConfListViewController) withObject:nil afterDelay:0.5];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
    [alertController addAction:sureAction];
    [alertController addAction:cancelAction];
    
    [self.navigationController presentViewController:alertController
                                            animated:YES
                                          completion:nil];
}

- (UIButton *)createButtonByImage:(UIImage *)btnImage
                   highlightImage:(UIImage *)highlightImage
                            title:(NSString *)title
                           target:(id)target
                           action:(SEL)action
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    if (nil != btnImage) {
        [button setImage:btnImage forState:UIControlStateNormal];
    }
    if (nil != highlightImage) {
        [button setImage:highlightImage forState:UIControlStateHighlighted];
    }
    [button setTitle:title forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:12];
    button.titleLabel.minimumScaleFactor = 0.8;
    button.titleLabel.adjustsFontSizeToFitWidth = YES;
    if (nil != action) {
        [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    }
    return button;
}

- (void)changeBtnContent:(UIButton *)btn
{
    btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    [btn setTitleEdgeInsets:UIEdgeInsetsMake(btn.imageView.frame.size.height, -btn.imageView.frame.size.width, 0.0, 0.0)];
    [btn setImageEdgeInsets:UIEdgeInsetsMake(-btn.titleLabel.bounds.size.height, 0.0, 0.0, -btn.titleLabel.bounds.size.width)];
}
//返回当前的view的宽度，由于为横屏，所以返回的高宽中更大值的为宽度（由于转屏的影响，需要实时获取宽度）
- (CGFloat)selfViewWidth
{
    return MAX(self.view.bounds.size.width, self.view.bounds.size.height);
}

//返回当前的view的宽度，由于为横屏，所以返回的高宽中更小值的为宽度（由于转屏的影响，需要实时获取长度）
- (CGFloat)selfViewHeight
{
    return MIN(self.view.bounds.size.height, self.view.bounds.size.width);
}

- (BOOL)isSelfMaster {
    
    ConfAttendeeInConf *selfAttendee = nil;
    
    for (ConfAttendeeInConf *tempAttendee in [ManagerService confService].haveJoinAttendeeArray)
    {
        if (tempAttendee.isSelf)
        {
            selfAttendee = tempAttendee;
        }
    }
    
    if (nil == selfAttendee) {
        return NO;
    }
    
    return (CONF_ROLE_CHAIRMAN == selfAttendee.role);
}

-(void)showMessage:(NSString *)msg
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:msg preferredStyle:UIAlertControllerStyleAlert];
    [self presentViewController:alert animated:NO completion:nil];
    [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(creatAlert:) userInfo:alert repeats:NO];
}

- (void)creatAlert:(NSTimer *)timer
{
    UIAlertController *alert = [timer userInfo];
    [alert dismissViewControllerAnimated:YES completion:nil];
    alert = nil;
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
        _signalBackView.center = CGPointMake(SCREEN_HIGHT/2, SCREEN_WIDTH/2);
        //            _signalBackView.backgroundColor = [UIColor blackColor];
        //            _signalBackView.alpha = 0.5;
        _signalBackView.hidden = YES;
        //        [_signalBackView addSubview:self.signalScrollView];
        [_signalBackView addSubview:self.signalDataScrollView];
        
        
    }
    return _signalBackView;
}

- (ImageViewBtn *)signalBtn
{
    if (nil == _signalBtn) {
        _signalBtn = [[ImageViewBtn alloc] initWithFrame: CGRectMake(SCREEN_HIGHT - 50, 60, 30 , 30)];
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
                
                NSString *recvName = @"";
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
