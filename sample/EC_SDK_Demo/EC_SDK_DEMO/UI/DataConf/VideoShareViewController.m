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

@interface VideoShareViewController ()<UITableViewDelegate, UITableViewDataSource, CallServiceDelegate, ConferenceServiceDelegate>

@property (nonatomic, strong) UIView *localViewShower;
@property (nonatomic, strong) UIImageView *backImageView;
@property (nonatomic, strong) EAGLView *remoteView;
@property (nonatomic, strong) EAGLView *localView;
@property (nonatomic, strong) UIButton *confDataShareBtn;
@property (nonatomic, strong) UIImageView *confDataShareImageView;
@property (nonatomic, strong) UIButton *attendCameraChooseBtn;
@property (nonatomic, strong) UIButton *cameraHandleBtn;
@property (nonatomic, strong) UIButton *cameraChangeBtn;
@property (nonatomic, strong) UIButton *setConfModeBtn;
@property (nonatomic, strong) UITableView *attendTableView;
@property (nonatomic, strong) UIImageView *attendTableViewBackImageView;
@property (nonatomic, strong) UIView *attendTableViewBackFullScreenView;

@property (nonatomic, assign) BOOL isCameraOpen;
@property (nonatomic, strong) CallInfo *currentTupCallInfo;
@property (nonatomic, assign) NSInteger cameraCaptureIndex;
@property (nonatomic, strong) NSMutableArray *localCameraInfos;
@property (nonatomic, strong) NSMutableArray *remoteCameraInfos;

@property (nonatomic, assign) BOOL isEnterBackground;

@property (nonatomic, assign) EC_CONF_MODE currentConfMode;

@end

@implementation VideoShareViewController

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

- (instancetype)initWithConfInfo:(ConfStatus *)confInfo {
    self = [super initWithConfInfo:confInfo];
    if (self) {
        if ([self isUseTupVideo]) {
            _isCameraOpen = YES;
        }else {
            _isCameraOpen = NO;
        }
        _isEnterBackground = NO;
        _cameraCaptureIndex = 1;
        _currentConfMode = EC_CONF_MODE_FIXED;
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
    }
    return self;
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

    [[DeviceMotionManager sharedInstance] startDeviceMotionManager];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    [[DeviceMotionManager sharedInstance] stopDeviceMotionManager];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view insertSubview:self.backImageView belowSubview:self.bottomView];
    if ([self isUseTupVideo]) {
        [self.view insertSubview:self.remoteView aboveSubview:self.backImageView];
    }
    [self.bottomView addSubview:self.cameraChangeBtn];
    [self.view addSubview:self.localViewShower];
    if ([self isNeedAddDataBtn]) {
        [self.barView addSubview:self.confDataShareBtn];
    }
    [self.barView addSubview:self.attendCameraChooseBtn];
    if (![self isUseTupVideo] || ([self isVideoConf] && [self isSelfMaster])) {
        [self.view addSubview:self.attendTableViewBackFullScreenView];
    }
    [self configBottomViewBtns];
    if ([self isSelfMaster]) {
        [self.bottomView addSubview:self.setConfModeBtn];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.remoteView.frame = CGRectMake(0, 0, [self selfViewWidth], [self selfViewHeight]);
}

- (BOOL)isMediaXDataVideoConf {
    return ([[ManagerService confService] isUportalMediaXConf]
            && (CONF_MEDIATYPE_VIDEO_DATA == self.confStatus.media_type));
}

- (BOOL)isNeedAddDataBtn {
    EC_CONF_MEDIATYPE confType = self.confStatus.media_type;
    BOOL isVideoDataConf = (confType == CONF_MEDIATYPE_VIDEO_DATA);
    return isVideoDataConf;
}

- (void)configBottomViewBtns {
    CGFloat width = [self selfViewWidth];
    self.cameraHandleBtn.frame = CGRectMake(width/2-170, 0, 100, 71);
    self.voiceBtn.frame = CGRectMake(width/2-50, 0, 100, 71);
    self.endBtn.frame = CGRectMake(width/2+70, 0, 100, 71);
    [self.bottomView addSubview:self.cameraHandleBtn];
    [self.bottomView addSubview:self.voiceBtn];
    [self.bottomView addSubview:self.endBtn];
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
        _localViewShower.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"image_conf_video_small_video_back"]];
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
        _localView.frame = CGRectMake(0, 0, 126, 95);
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

- (UIButton *)cameraChangeBtn {
    if (nil == _cameraChangeBtn)
    {
        _cameraChangeBtn = [self createButtonByImage:[UIImage imageNamed:@"btn_conf_video_camera_change_normal"]
                                      highlightImage:nil
                                               title:nil
                                              target:self
                                              action:@selector(cameraChangeBtnClicked:)];
        [_cameraChangeBtn setFrame:CGRectMake(20, 20, 31, 31)];
    }
    return _cameraChangeBtn;
}

- (void)cameraChangeBtnClicked:(id)sender {
    if (_isCameraOpen) {
        if ([self isUseTupVideo]) {
            _cameraCaptureIndex = _cameraCaptureIndex == 1 ? 0 : 1;
            BOOL isSuccess = [[ManagerService callService] switchCameraIndex:_cameraCaptureIndex callId:self.confStatus.call_id];
            if (isSuccess) {
                [self deviceMotionOrientationChanged];
            }
        }
    }
    
}

- (void)deviceMotionOrientationChanged
{
    NSUInteger cameraRotation = 0;
    NSUInteger displayRotation = 0;
    
    BOOL needAdjust = [[DeviceMotionManager sharedInstance] adjustCamerRotation:&cameraRotation
                                                                displayRotation:&displayRotation
                                                                   byCamerIndex:_cameraCaptureIndex
                                                           interfaceOrientation:UIInterfaceOrientationLandscapeRight];
    if ([UIApplication sharedApplication].applicationState != UIApplicationStateActive)
    {
        return ;
    }
    
    if (!needAdjust) {
        return;
    }
    
    [[ManagerService callService] rotationVideoDisplay:displayRotation callId:self.confStatus.call_id];
    [[ManagerService callService] rotationCameraCapture:cameraRotation callId:self.confStatus.call_id];
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

- (void)cameraHandleBtnClicked:(id)sender {
    if ([self isVideoConf]) {
        [[ManagerService callService] switchCameraOpen:!_isCameraOpen callId:self.confStatus.call_id];
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
        
        CGFloat width = [self selfViewWidth];
        [_confDataShareBtn setFrame:CGRectMake(width-80, 15, 34, 34)];
        
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
    DataShareViewController *dataConfCtrl = [[DataShareViewController alloc] initWithConfInfo:self.confStatus];
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
    [self.attendTableViewBackFullScreenView setHidden:(!self.attendTableViewBackFullScreenView.hidden)];
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
    NSInteger rowNumber = self.confStatus.participants.count;
    if (rowNumber <= 4) {
        return rowNumber*44+30;
    }
    return 4*44+30;
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
    return self.confStatus.participants.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
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
    ConfAttendeeInConf *attendee = self.confStatus.participants[indexPath.row];
    if ([attendee.number isEqualToString:self.selfNumber]) {
        cell.textLabel.text = [NSString stringWithFormat:@"%@(me)", attendee.number];
    }else {
        cell.textLabel.text = [NSString stringWithFormat:@"%@", attendee.number];
    }
    cell.textLabel.textColor = [UIColor blackColor];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    ConfAttendeeInConf *attendee = self.confStatus.participants[indexPath.row];
    if ([self isVideoConf]) {
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Tips"
                                                                                 message:[NSString stringWithFormat:@"Broadcast %@'s video?", attendee.number]
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"Sure"
                                                             style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction * _Nonnull action) {
            //watch attendee todo jl
//            [[ManagerService confService] watchAttendeeNumber:attendee.number];
            [[ManagerService confService] boardcastAttendee:attendee.number isBoardcast:YES];
        }];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                               style:UIAlertActionStyleDefault
                                                             handler:nil];
        [alertController addAction:sureAction];
        [alertController addAction:cancelAction];
        [self.navigationController presentViewController:alertController animated:YES completion:nil];
    }
}

- (BOOL)isVideoConf {
    BOOL isVideoConf = NO;
    if (CONF_MEDIATYPE_VIDEO == self.confStatus.media_type || CONF_MEDIATYPE_VIDEO_DATA == self.confStatus.media_type) {
        isVideoConf = YES;
    }
    return isVideoConf;
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
