//
//  ConfRunningViewController.m
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

#import "ConfRunningViewController.h"
#import "ManagerService.h"
#import "ConfAttendee.h"
#import "ConfAttendeeInConf.h"
#import "AttendeeListCell.h"
#import "ConfListViewController.h"
#import "VideoShareViewController.h"
#import "DataShareViewController.h"
#import "DialSecondPlate.h"
#import "ConfBaseInfo.h"

#import "ChatMsg.h"
#import "EAGLView.h"
#import "CommonUtils.h"

@interface ConfRunningViewController ()<UITableViewDelegate, UITableViewDataSource, ConferenceServiceDelegate, DialSecondPlateDelegate>

@property (nonatomic, strong)ConfAttendeeInConf *mineConfInfo;

@property (nonatomic,strong) IBOutlet UITableView *attendeeListTableView;
//@property (nonatomic, strong) NSMutableArray *currentAttendees;

@property (nonatomic,strong) UIImageView *enterDataSharedView;
@property (nonatomic,strong) UIImageView *enterVideoShareView;
@property (nonatomic,strong) UIButton *enterVideoShareBtn;
@property (nonatomic,strong) UIButton *enterDataSharedBtn;

@property (nonatomic, assign) BOOL isJoinDataConfSuccess;

@property (weak, nonatomic) IBOutlet UIView *raiseHandView;
@property (nonatomic,copy) NSString *sipAccount;
@property (weak, nonatomic) IBOutlet UIButton *muteBtn;
@property (weak, nonatomic) IBOutlet UIButton *speakerBtn;
@property (weak, nonatomic) IBOutlet UIButton *addMemberBtn;
@property (weak, nonatomic) IBOutlet UIButton *keyPadBtn;
@property (weak, nonatomic) IBOutlet UIButton *raiseHand;
@property (weak, nonatomic) IBOutlet UIButton *muteallBtn;
@property (weak, nonatomic) IBOutlet UIButton *unmuteallBtn;
@property (weak, nonatomic) IBOutlet UIButton *requestChairBtn;
@property (weak, nonatomic) IBOutlet UIButton *dataMeetingBtn;
@property (weak, nonatomic) IBOutlet UIButton *lockConfBtn;
@property (weak, nonatomic) IBOutlet UILabel *lockConfLabel;
@property (weak, nonatomic) IBOutlet UILabel *requestChairLabel;
@property (weak, nonatomic) IBOutlet UIButton *muteAttendeeLabel;

@property (nonatomic, assign) BOOL isMicMute;
@property (nonatomic, strong) NSMutableArray *currentSpeakArray;
@property (nonatomic, strong) NSArray *currentAttendeeArray;


@end

@implementation ConfRunningViewController

-(void)ecConferenceEventCallback:(EC_CONF_E_TYPE)ecConfEvent result:(NSDictionary *)resultDictionary
{
    switch (ecConfEvent)
    {
        case CONF_E_ATTENDEE_UPDATE_INFO:
        {
            dispatch_async(dispatch_get_main_queue(), ^{

                _currentAttendeeArray = [NSArray arrayWithArray:[ManagerService confService].haveJoinAttendeeArray];
                if (_currentAttendeeArray.count > 0) {
                    
                    [self.attendeeListTableView reloadData];
                }
                
                NSString *selfNumber = self.sipAccount;
                if ([ManagerService confService].selfJoinNumber) {
                    selfNumber = [ManagerService confService].selfJoinNumber;
                }
//                NSArray *attendeeArray = [NSArray arrayWithArray:[ManagerService confService].haveJoinAttendeeArray];
                for (ConfAttendeeInConf *tempAttendee in _currentAttendeeArray)
                {
                    if ([tempAttendee.number isEqualToString:selfNumber] || tempAttendee.isSelf)
                    {
                        _mineConfInfo = tempAttendee;
                        
                    }
                }
                
                [self updateBtnStatus];
//                [self updateRightBarBottonItems];
            });
        }
            break;
        case CONF_E_UPGRADE_RESULT:
        {
            BOOL result = [resultDictionary[ECCONF_RESULT_KEY] boolValue];
            if (!result)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self showMessage:@"Upgrade data conference failed!"];
                });
            }
        }
            break;
        case CONF_E_MUTE_RESULT:
        {
            BOOL result = [resultDictionary[ECCONF_RESULT_KEY] boolValue];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if(result){
                    BOOL ismute = [resultDictionary[ECCONF_MUTE_KEY] boolValue];
                    if(ismute){
                        [self showMessage:@"Mute conference success."];
                        [_muteallBtn setImage:[UIImage imageNamed:@"conf_tab_muteall_highlight"] forState:UIControlStateNormal];
                        [_unmuteallBtn setImage:[UIImage imageNamed:@"conf_tab_cancelmuteall"] forState:UIControlStateNormal];
                    }else{
                        [self showMessage:@"Unmute conference success."];
                        [_muteallBtn setImage:[UIImage imageNamed:@"conf_tab_muteall"] forState:UIControlStateNormal];
                        [_unmuteallBtn setImage:[UIImage imageNamed:@"conf_tab_cancelmuteall_highlight"] forState:UIControlStateNormal];
                    }
                }
                else{
                    [self showMessage:@"Mute conf failed."];
                }
            });
        }
            break;
        case CONF_E_LOCK_STATUS_CHANGE:
        {
            BOOL result = [resultDictionary[ECCONF_RESULT_KEY] boolValue];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (result) {
                    if(![ManagerService confService].currentConfBaseInfo.lock_state){
                        [self showMessage:@"Lock conference success."];
                        _lockConfLabel.text = @"UnlockConf";
                    }else{
                        [self showMessage:@"Unlock conference success."];
                        _lockConfLabel.text = @"LockConf";
                    }
                    
                }
                else {
                    [self showMessage:@"Lock conference failed."];
                }
            });
            break;
        }
        case CONF_E_SPEAKER_LIST:
        {
            _currentSpeakArray = [NSMutableArray arrayWithArray:resultDictionary[ECCONF_SPEAKERLIST_KEY]];
            [self.attendeeListTableView reloadData];
            break;
        }
        case CONF_E_END_RESULT:
        {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [self quitToListViewCtrl];
//            });
            
        }
            break;
        case DATA_CONF_JOIN_RESOULT: {
            BOOL isSuccess = [resultDictionary[UCCONF_RESULT_KEY] boolValue];
            DDLogInfo(@"DATA_CONF_JOIN_RESOULT: %d", isSuccess);
            dispatch_async(dispatch_get_main_queue(), ^{
                if (isSuccess) {
                    [self showMessage:@"Join data conf success."];
                    _dataMeetingBtn.enabled = NO;
                    [self stopTupBfcpCapability];
                    _isJoinDataConfSuccess = YES;
                }else {
                    [self showMessage:@"Join data conf failed."];
                    _isJoinDataConfSuccess = NO;
                }
//                [self updateRightBarBottonItems];
            });
            break;
        }
        case CONF_E_REQUEST_CHAIRMAN_RESULT:
        {
            BOOL result = [resultDictionary[ECCONF_RESULT_KEY] boolValue];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (result) {
                    [self showMessage:@"request chairman success."];
                }else {
                    [self showMessage:@"request chairman failed."];
                }
            });
            break;
        }
        case CONF_E_RELEASE_CHAIRMAN_RESULT:
        {
            BOOL result = [resultDictionary[ECCONF_RESULT_KEY] boolValue];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (result) {
                    [self showMessage:@"release chairman success."];
                }else {
                    [self showMessage:@"release chairman failed."];
                }
            });
            break;
        }
        case CONF_E_MUTE_ATTENDEE_RESULT:
        {
//            BOOL result = [resultDictionary[ECCONF_RESULT_KEY] boolValue];
//            dispatch_async(dispatch_get_main_queue(), ^{
//                if(result){
//                    [_muteBtn setImage:[UIImage imageNamed:@"conf_tab_mute_selected"] forState:UIControlStateNormal];
//                    [_muteAttendeeLabel setTitle:@"unMute" forState:UIControlStateNormal];
//                    [self showMessage:@"Mute self success"];
//                }else{
//                    [_muteBtn setImage:[UIImage imageNamed:@"conf_tab_mute"] forState:UIControlStateNormal];
//                    [_muteAttendeeLabel setTitle:@"Mute" forState:UIControlStateNormal];
//                    [self showMessage:@"Unmute self success"];
//                }
//            });
            break;
        }
        default:
            break;
    }
}

-(UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
//    [ManagerService confService].delegate = nil;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [ManagerService confService].delegate = self;
    [CommonUtils setToOrientation:UIDeviceOrientationPortrait];
    if (self.attendeeListTableView != nil) {
        [self.attendeeListTableView reloadData];
    }
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.title = [ManagerService confService].currentConfBaseInfo.conf_subject;
    
    _currentAttendeeArray = [NSArray arrayWithArray:[ManagerService confService].haveJoinAttendeeArray];
    for (ConfAttendeeInConf *tempAttendee in _currentAttendeeArray)
    {
        if (tempAttendee.isSelf)
        {
            _mineConfInfo = tempAttendee;
            
        }
    }
    
    _isJoinDataConfSuccess = NO;
    self.view.backgroundColor = [UIColor clearColor];

    _attendeeListTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [_attendeeListTableView registerNib:[UINib nibWithNibName:@"AttendeeListCell" bundle:nil] forCellReuseIdentifier:@"ConfAttendeeCell"];
    // Do any additional setup after loading the view.
    
    UIBarButtonItem *backBtn = [[UIBarButtonItem alloc]initWithTitle:@"Quit" style:UIBarButtonItemStylePlain target:self action:@selector(gobackBtnAction)];
    self.navigationItem.leftBarButtonItem = backBtn;
    
    ROUTE_TYPE currentRoute = [[ManagerService callService] obtainMobileAudioRoute];
    _speakerBtn.selected = currentRoute == ROUTE_LOUDSPEAKER_TYPE;
    
    _isMicMute = NO;
    _currentSpeakArray = [[NSMutableArray alloc]init];;
    
    [self updateBtnStatus];
//    [self updateRightBarBottonItems];
    [self.attendeeListTableView reloadData];
    
    if ([ManagerService confService].isUportalSMCConf) {
        _raiseHandView.hidden = YES;
    }
    
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateSpeakerStatus:) name:NTF_AUDIOROUTE_CHANGED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(quitToListViewCtrl) name:CONF_QUITE_TO_CONFLISTVIEW object:nil];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)gobackBtnAction
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.navigationController popViewControllerAnimated:YES];
    });
}

-(BOOL)checkMineRoleIsChairman
{
    BOOL isChairman = NO;
    if (_mineConfInfo.role == CONF_ROLE_CHAIRMAN)
    {
        isChairman = YES;
    }
    return isChairman;
}

-(void)finishConference
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.navigationController.navigationBarHidden = NO;
    });
}

-(NSString *)sipAccount
{
    NSString *sipAccount = [ManagerService callService].sipAccount;
    NSArray *array = [sipAccount componentsSeparatedByString:@"@"];
    NSString *shortSipNum = array[0];
    
    return shortSipNum;
}


-(UIImageView *)enterVideoShareView{
    if (nil == _enterVideoShareView)
    {
        _enterVideoShareView = [self animationImageViewWithNormalImage:[UIImage imageNamed:@"enter_videoshare"]
                                                      highLightedImage:[UIImage imageNamed:@"enter_videoshare_highlight"]
                                                       animationImages:@[[UIImage imageNamed:@"enter_videoshare"],[UIImage imageNamed:@"enter_videoshare1"],
                                                                         [UIImage imageNamed:@"enter_videoshare2"],[UIImage imageNamed:@"enter_videoshare3"]]
                                                  andAnimationDuration:2];
    }
    return _enterVideoShareView;
}

-(UIImageView *)enterDataSharedView
{
    if (_enterDataSharedView == nil) {
        _enterDataSharedView = [self animationImageViewWithNormalImage:[UIImage imageNamed:@"enter_datashare"]
                                                      highLightedImage:[UIImage imageNamed:@"enter_datashare_highlight"]
                                                       animationImages:@[[UIImage imageNamed:@"enter_datashare"],[UIImage imageNamed:@"enter_datashare1"],
                                                                         [UIImage imageNamed:@"enter_datashare2"],[UIImage imageNamed:@"enter_datashare3"]]
                                                  andAnimationDuration:2];
    }
    return _enterDataSharedView;
}

-(UIButton *)enterVideoShareBtn
{
    if (_enterVideoShareBtn == nil) {
        _enterVideoShareBtn = [[UIButton alloc]initWithFrame:self.enterVideoShareView.bounds];
        [_enterVideoShareBtn addTarget:self action:@selector(enterVideoSharedController) forControlEvents:UIControlEventTouchUpInside];
        [_enterVideoShareBtn addSubview:_enterVideoShareView];
    }
    return _enterVideoShareBtn;
}

- (void)enterVideoSharedController {
    VideoShareViewController *videoShareVC = [[VideoShareViewController alloc] init];
    [self.navigationController pushViewController:videoShareVC animated:YES];
}

- (UIButton *)enterDataSharedBtn
{
    if (_enterDataSharedBtn == nil) {
        _enterDataSharedBtn = [[UIButton alloc] initWithFrame:self.enterDataSharedView.bounds];
        [_enterDataSharedBtn addTarget:self action:@selector(enterDataSharedController) forControlEvents:UIControlEventTouchUpInside];
        [_enterDataSharedBtn addSubview:_enterDataSharedView];
    }
    return _enterDataSharedBtn;
}

- (void)enterDataSharedController {
    DataShareViewController *dataShareVC = [[DataShareViewController alloc] init];
    [self.navigationController pushViewController:dataShareVC animated:YES];
}

//- (void)updateRightBarBottonItems {
//
//    self.title = [ManagerService confService].currentConfBaseInfo.conf_subject;
//    NSMutableArray *rightItems = [[NSMutableArray alloc] init];
//    UIBarButtonItem *enterDataShared = [[UIBarButtonItem alloc] initWithCustomView:self.enterDataSharedBtn];
//    UIBarButtonItem *enterVideoShared = [[UIBarButtonItem alloc]initWithCustomView:self.enterVideoShareBtn];
//    switch ([ManagerService confService].currentConfBaseInfo.media_type) {
//        case CONF_MEDIATYPE_VIDEO:
//            if ([ManagerService callService].isShowTupBfcp) {
//                [rightItems addObject:enterDataShared];
//            }
//
//            [rightItems addObject:enterVideoShared];
//            break;
//
//        case CONF_MEDIATYPE_DATA:
//            if (!_isJoinDataConfSuccess) {
//                return;
//            }
//            if ([[ManagerService confService] isUportalSMCConf] || [[ManagerService confService] isUportalMediaXConf]) {
//                [rightItems addObject:enterDataShared];
//            }else {
//                [rightItems addObject:enterDataShared];
//                [rightItems addObject:enterVideoShared];
//            }
//            break;
//
//        case CONF_MEDIATYPE_VIDEO_DATA:
//            if (_isJoinDataConfSuccess) {
//               [rightItems addObject:enterDataShared];
//            }
//            [rightItems addObject:enterVideoShared];
//            break;
//
//        default:
//            break;
//    }
//    dispatch_async(dispatch_get_main_queue(), ^{
//        if (rightItems.count > 0) {
//            self.navigationItem.rightBarButtonItems = rightItems;
//        }
//    });
//}

- (UIImageView *)animationImageViewWithNormalImage:(UIImage *)normalImage
                                  highLightedImage:(UIImage *)highLightedImage
                                   animationImages:(NSArray *)animationImages
                              andAnimationDuration:(NSTimeInterval)animationDuration
{
    UIImageView  *imageView = [[UIImageView alloc] initWithImage:normalImage
                                                highlightedImage:highLightedImage];
    imageView.animationImages = animationImages;
    imageView.animationDuration = animationDuration;
    return imageView;
}

- (void)updateSpeakerStatus:(NSNotification *)notification
{
    ROUTE_TYPE currentRoute = (ROUTE_TYPE)[notification.userInfo[AUDIO_ROUTE_KEY] integerValue];
    _speakerBtn.selected = currentRoute == ROUTE_LOUDSPEAKER_TYPE;
}

- (BOOL)stopTupBfcpCapability
{
//    CallInfo *callInfo = [[ManagerService callService] callInfoWithConfId:_currentStatus.conf_id];
//
//    [[ManagerService callService] stopTupBfcpCapabilityWithCallId:callInfo.stateInfo.callId];
    return YES;
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

#pragma mark -
#pragma mark Button Action

- (void)updateBtnStatus
{
    if (_mineConfInfo.hand_state) {
        [_raiseHand setImage:[UIImage imageNamed:@"conf_tab_cancel_handup_normal"] forState:UIControlStateNormal];
    }
    else {
        [_raiseHand setImage:[UIImage imageNamed:@"conf_tab_handup_normal"] forState:UIControlStateNormal];
    }
    
    if (_mineConfInfo.role == CONF_ROLE_CHAIRMAN) {
        [_requestChairBtn setImage:[UIImage imageNamed:@"conf_tab_release_chairman_normal"] forState:UIControlStateNormal];
        _requestChairLabel.text = @"releaseChair";
        [_lockConfBtn setEnabled:YES];
        [_addMemberBtn setEnabled:YES];
        [_muteallBtn setEnabled:YES];
        [_unmuteallBtn setEnabled:YES];
        if ([ManagerService confService].currentConfBaseInfo.media_type == CONF_MEDIATYPE_DATA
            || [ManagerService confService].currentConfBaseInfo.media_type == CONF_MEDIATYPE_VIDEO_DATA) {
            [_dataMeetingBtn setEnabled:NO];
        }
        else {
            [_dataMeetingBtn setEnabled:YES];
        }
        [_lockConfBtn setEnabled:YES];
    }
    else {
        [_requestChairBtn setImage:[UIImage imageNamed:@"conf_tab_request_chairman_normal"] forState:UIControlStateNormal];
        _requestChairLabel.text = @"requestChair";
        [_lockConfBtn setEnabled:NO];
        [_addMemberBtn setEnabled:NO];
        [_muteallBtn setEnabled:NO];
        [_unmuteallBtn setEnabled:NO];
        [_dataMeetingBtn setEnabled:NO];
        [_lockConfBtn setEnabled:NO];
    }
    
    if (_mineConfInfo.is_mute && _mineConfInfo.role == CONF_ROLE_CHAIRMAN) {
        _muteBtn.selected = YES;
    }
    // toso jl
//    [_raiseHand setEnabled:([ManagerService confService].uPortalConfType == CONF_TOPOLOGY_MEDIAX)];
    [_raiseHand setEnabled:YES];
    
    
    if([ManagerService confService].currentConfBaseInfo.lock_state){
        _lockConfLabel.text = @"UnlockConf";
    }else{
        _lockConfLabel.text = @"LockConf";
    }

    
    
}

- (IBAction)addMember:(id)sender
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
        if (cAttendee.number !=  nil && cAttendee.number.length > 0) {
            [[ManagerService confService] confCtrlAddAttendeeToConfercene:addAttendeeArray];
        }
    }];
    [alertCon addAction:okAction];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:nil];
    [alertCon addAction:cancelAction];
    [self presentViewController:alertCon animated:YES completion:nil];
}

- (IBAction)raiseHand:(id)sender
{
    [[ManagerService confService] confCtrlRaiseHand:!_mineConfInfo.hand_state attendeeNumber:_mineConfInfo.number];
}

- (IBAction)requestOrReleaseChair:(id)sender {
    if (_mineConfInfo.role == CONF_ROLE_CHAIRMAN) {
        [[ManagerService confService] confCtrlReleaseChairman:_mineConfInfo.number];
    }
    else {
        if ([ManagerService confService].uPortalConfType == CONF_TOPOLOGY_SMC) {
            [[ManagerService confService] confCtrlRequestChairman:@"" number:_mineConfInfo.number];
        }
        else {  // mediaX conf
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
                
                [[ManagerService confService] confCtrlRequestChairman:password number:_mineConfInfo.number];
            }];
            
            [alert addAction:cancel];
            [alert addAction:ok];
            
            [self presentViewController:alert animated:YES completion:nil];

        }
    }
}

- (IBAction)muteAll:(id)sender {
    [[ManagerService confService] confCtrlMuteConference:YES];
}

- (IBAction)unmuteAll:(id)sender {
    [[ManagerService confService] confCtrlMuteConference:NO];
}

- (IBAction)muteSelf:(id)sender { 
    if([[ManagerService confService] confCtrlMuteAttendee:_mineConfInfo.number isMute:!_mineConfInfo.is_mute]){
//        dispatch_async(dispatch_get_main_queue(), ^{
//            if(_mineConfInfo.is_mute){
//                [self showMessage:@"Unmute self success"];
//            }else{
//                [self showMessage:@"Mute self success"];
//            }
//        });
        
        if(_mineConfInfo.is_mute){
            [_muteBtn setImage:[UIImage imageNamed:@"conf_tab_mute"] forState:UIControlStateNormal];
            [_muteAttendeeLabel setTitle:@"Mute" forState:UIControlStateNormal];
            [self showMessage:@"Unmute self success"];
        }else{
            [_muteBtn setImage:[UIImage imageNamed:@"conf_tab_mute_selected"] forState:UIControlStateNormal];
            [_muteAttendeeLabel setTitle:@"unMute" forState:UIControlStateNormal];
            [self showMessage:@"Mute self success"];
        }
    }
}

- (IBAction)switchSpeaker:(id)sender {
    ROUTE_TYPE routeType = [[ManagerService callService] obtainMobileAudioRoute];
    ROUTE_TYPE configType = routeType == ROUTE_LOUDSPEAKER_TYPE ? ROUTE_DEFAULT_TYPE : ROUTE_LOUDSPEAKER_TYPE;
    [[ManagerService callService] configAudioRoute:configType];
}

- (IBAction)upgradeButtonAction:(id)sender {
    if (![self checkMineRoleIsChairman])
    {
        [self showMessage:@"You are not chairman!"];
        return;
    }
    [[ManagerService confService] confCtrlVoiceUpgradeToDataConference:([ManagerService confService].currentConfBaseInfo.media_type==CONF_MEDIATYPE_VIDEO)];
}
- (IBAction)keypadButtonAction:(id)sender {
    if ([DialSecondPlate shareInstance].isShow) {
        [[DialSecondPlate shareInstance] hideView];
    }else{
        [[DialSecondPlate shareInstance] showViewInSuperView:self.view Delegate:self];
    }
}

- (IBAction)lockConference:(id)sender {
    [[ManagerService confService] confCtrlLockConference:![ManagerService confService].currentConfBaseInfo.lock_state];
    
}

#pragma mark - DialSecondDelegate
-(void)clickDialSecondPlate:(NSString *)string
{
    CallInfo *callInfo = [[ManagerService callService] callInfoWithConfId:[ManagerService confService].currentConfBaseInfo.conf_id];
     [[ManagerService callService] sendDTMFWithDialNum:string callId:callInfo.stateInfo.callId];
}



#pragma mark - UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if ([ManagerService confService].currentConfBaseInfo.lock_state) {
        return 20;
    }
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(tableView.frame), 20)];
    [view setBackgroundColor:[UIColor lightGrayColor]];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(tableView.frame), 20)];
    label.text = @"Conference locked.";
    [label setTextColor:[UIColor whiteColor]];
    [label setTextAlignment:NSTextAlignmentCenter];
    [label setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    [view addSubview:label];
    return view;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([self.attendeeListTableView isEqual:tableView]){
        return _currentAttendeeArray.count;
    }
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AttendeeListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ConfAttendeeCell"];
//    NSArray *attendeeArray = [ManagerService confService].haveJoinAttendeeArray;
    DDLogInfo(@"jinliang2222222,%d",_currentAttendeeArray.count);
    ConfAttendeeInConf *attendee = _currentAttendeeArray[indexPath.row];
    DDLogInfo(@"jinliang3333333,%d",_currentAttendeeArray.count);
    cell.attendee = attendee;
    cell.isSpeaking = NO;
    for (ConfCtrlSpeaker *speaker in _currentSpeakArray) {
        DDLogInfo(@"ConfCtrlSpeaker,speaker.number:%@,speaker.is_speaking:%d",speaker.number,speaker.is_speaking);
        if ([speaker.number isEqualToString:attendee.number] && speaker.is_speaking) {
            cell.isSpeaking = YES;
        }
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (_mineConfInfo.role == CONF_ROLE_CHAIRMAN || _mineConfInfo.isPresent) {
//        NSArray *attendeeArray = [ManagerService confService].haveJoinAttendeeArray;
        ConfAttendeeInConf *attendee = _currentAttendeeArray[indexPath.row];
//        unsigned int userId = [attendee.userID intValue];
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:attendee.name
                                                                                 message:@""
                                                                          preferredStyle:UIAlertControllerStyleActionSheet];
        if (attendee.state == ATTENDEE_STATUS_IN_CONF || attendee.state == ATTENDEE_STATUS_JOINING ||  attendee.state == ATTENDEE_STATUS_CALLING) {
            
            if (attendee.state != ATTENDEE_STATUS_JOINING &&  attendee.state != ATTENDEE_STATUS_CALLING) {
                if (attendee.isJoinDataconf) {
                    if (!attendee.isPresent) {
                        UIAlertAction *presentAction = [UIAlertAction actionWithTitle:@"Set Presenter"
                                                                                style:UIAlertActionStyleDefault
                                                                              handler:^(UIAlertAction *action)
                                                        {
                                                            BOOL result = [[ManagerService confService] setPresenterNumber:attendee.number];
                                                            if (result) {
                                                                [self showMessage:@"set presenter success."];
                                                            }else {
                                                                [self showMessage:@"set presenter failed."];
                                                            }
                                                        }];
                        [alertController addAction:presentAction];
                    }
                    
                    if (!attendee.isSelf) {
                        if (attendee.isShareOwner) {
                            UIAlertAction *cancelShareAction = [UIAlertAction actionWithTitle:@"Cancen Share"
                                                                                        style:UIAlertActionStyleDefault
                                                                                      handler:^(UIAlertAction *action)
                                                                {
                                                                    [[ManagerService confService] cancelDataShareWithNumber:attendee.number];

                                                                }];
                            [alertController addAction:cancelShareAction];
                        }else{
                            UIAlertAction *setShareAction = [UIAlertAction actionWithTitle:@"Set Share"
                                                                                     style:UIAlertActionStyleDefault
                                                                                   handler:^(UIAlertAction *action)
                                                             {
                                                                 [[ManagerService confService] inviteDataShareWithNumber:attendee.number];

                                                             }];
                            [alertController addAction:setShareAction];
                        }
                    }
                    
                    
                }
                
                if (_mineConfInfo.role == CONF_ROLE_CHAIRMAN) {
                    NSString *title = attendee.is_mute ? @"Grant Talk Right" : @"Revoke Talk Right";
                    
                    UIAlertAction * action = [UIAlertAction actionWithTitle:title style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        [[ManagerService confService] confCtrlMuteAttendee:attendee.number isMute:!attendee.is_mute];
                    }];
                    [alertController addAction:action];
                    
                    if ([ManagerService confService].isVideoConfInvited) {
                        NSString *broastcast = @"Broatcast attendee";
                        BOOL BroatcastAttendee = YES;
                        if (attendee.isBroadcast) {
                            broastcast = @"UnBroatcast attendee";
                            BroatcastAttendee = NO;
                        }
                        UIAlertAction * borastAction = [UIAlertAction actionWithTitle:broastcast style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                            [[ManagerService confService] broadcastAttendee:attendee.number isBoardcast:BroatcastAttendee];
                        }];
                        [alertController addAction:borastAction];
                    }
                    
                }
                
            }
            
            
            //            UIAlertAction* action = [UIAlertAction actionWithTitle:@"HangUp Participant" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            //                [[ManagerService confService] confCtrlHangUpAttendee:attendee.number];
            //                if (attendee.dataState == DataConfAttendeeMediaStateIn || attendee.dataState == DataConfAttendeeMediaStatePresent) {
            //                    [[ManagerService dataConfService] kickoutUser:[attendee.userID intValue]];
            //                }
            //            }];
            //            [alertController addAction:action];
            
        }
        else if (attendee.state == ATTENDEE_STATUS_LEAVED
                 || attendee.state == ATTENDEE_STATUS_NO_EXIST
                 || attendee.state == ATTENDEE_STATUS_BUSY
                 || attendee.state == ATTENDEE_STATUS_NO_ANSWER
                 || attendee.state == ATTENDEE_STATUS_REJECT
                 || attendee.state == ATTENDEE_STATUS_CALL_FAILED){
            UIAlertAction * action = [UIAlertAction actionWithTitle:@"Redial" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                ConfAttendee *cAttendee = [[ConfAttendee alloc] init];
                cAttendee.name = attendee.name;
                cAttendee.number = attendee.number;
                NSArray *addAttendeeArray = @[cAttendee];
                [[ManagerService confService] confCtrlAddAttendeeToConfercene:addAttendeeArray];
            }];
            [alertController addAction:action];
        }
        
        if (_mineConfInfo.role == CONF_ROLE_CHAIRMAN) {
            UIAlertAction* action = [UIAlertAction actionWithTitle:@"Remove Participant" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [[ManagerService confService] confCtrlRemoveAttendee:attendee.number];
            }];
            [alertController addAction:action];
        }
        
        UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"cancel" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:cancelAction];
        
        [self presentViewController:alertController animated:YES completion:nil];
    }
    
    
}

-(void)showMessage:(NSString *)msg
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:msg preferredStyle:UIAlertControllerStyleAlert];
    [self presentViewController:alert animated:NO completion:nil];
    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(creatAlert:) userInfo:alert repeats:NO];
}

- (void)creatAlert:(NSTimer *)timer
{
    UIAlertController *alert = [timer userInfo];
    [alert dismissViewControllerAnimated:YES completion:nil];
    alert = nil;
}


@end
