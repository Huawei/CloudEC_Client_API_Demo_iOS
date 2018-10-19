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

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}

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
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(screenTap:)];
    [self.view addGestureRecognizer:tap];
    
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
    [CommonUtils setToOrientation:UIDeviceOrientationLandscapeLeft];
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
        
        UITapGestureRecognizer *tapBar = [[UITapGestureRecognizer alloc] initWithTarget:self action:nil];
        [_barView addGestureRecognizer:tapBar];
        
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

        UITapGestureRecognizer *tapBar = [[UITapGestureRecognizer alloc] initWithTarget:self action:nil];
        [_bottomView addGestureRecognizer:tapBar];
        
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







/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
