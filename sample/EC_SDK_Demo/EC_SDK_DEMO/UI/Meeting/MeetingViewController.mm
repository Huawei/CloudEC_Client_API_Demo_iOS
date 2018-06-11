//
//  MeetingViewController.m
//  TUPDemo
//
//  Created by lwx308413 on 16/8/9.
//  Copyright © 2016年 huawei. All rights reserved.
//

#import "MeetingViewController.h"
#import "LoginViewController.h"
#import "AppDelegate.h"
#import "CommonUtils.h"
#import "EAGLView.h"
#import "CallTipView.h"
#import "ConferenceView.h"
#import "NetworkUtils.h"
#import "SiteView.h"
#import "SiteViewTableViewDataSouce.h"
#import "DialSecondPlate.h"
#import "TUPCallService.h"
#import "TupCallInfo.h"
#import "TUPService.h"
#import "TUPCallService.h"
#import "CallData.h"
#import "TUPLoginInfo.h"
#import "AppDelegate.h"
#import "IMView.h"
#import "ConfCameraInfo.h"
#import "CameraInfoView.h"
#import "ECCurrentConfInfo.h"
#import "ECConfInfo.h"
#import "TupCallInfo.h"
#import "ConfDetailViewController.h"
#import "AddAttendeeViewController.h"
#import "ConfAttendeeInConf.h"
#import "ConfStatus.h"
#import "ECCurrentConfInfo.h"
#import "TUPCallSessionModifyInfo.h"
//#import "TUPDataConfComponentService.h"
#import "ConferenceView.h"
#import "TUPChatMsg.h"
#import "ConfAttendee.h"

#define UISCREEN_WIDTH  [UIScreen mainScreen].bounds.size.width
#define UISCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

@interface MeetingViewController ()<UITableViewDelegate,SiteViewDelegate,UITextFieldDelegate,TUPConferenceServiceDelegate,TUPLoginServiceDelegate,ConferenceViewDelegate,IMViewDelegate,CamreaInfoViewDelegate,TUPCallServiceDelegate,UITableViewDataSource,DialSecondPlateDelegate>
{
    CGFloat _x;
    CGFloat _y;
    CGFloat _width;
    CGFloat _height;
}

@property (weak, nonatomic) IBOutlet UITextField *participantsNumberTextField;
@property (weak, nonatomic) IBOutlet UITableView *conferenceListTableView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *callingActivityIndicator;
@property (strong, nonatomic) EAGLView *remoteView;
@property (strong, nonatomic) EAGLView *locationView;
@property (assign, nonatomic) BOOL isShowSiteListe;
@property (strong, nonatomic) TupCallInfo *currentTupCallInfo;
@property (nonatomic, assign)BOOL isBeKickOut;
@property (nonatomic, strong) NSMutableArray *chatMsgArray;
@property (nonatomic, strong) NSMutableArray *remoteCameraInfoArray;
//EC 6.0
@property (nonatomic, strong)NSMutableArray *confListArray;
@property (nonatomic, copy)NSArray *attendeeInConfListArray;
@property (nonatomic, strong)ConfAttendeeInConf *mineConfInfo;
@property (nonatomic, strong)ConfStatus *currentConfStatus;
@property (nonatomic, strong)ECCurrentConfInfo *currentConfInfo;
@property (nonatomic, assign) BOOL isJoinConference;
@property (nonatomic, assign) BOOL isMuteAllConf;
@property (nonatomic, assign) BOOL isSelectedConfToJoin;
@property (nonatomic, assign) BOOL isAccessCodeWayToJoinConf;
@property (nonatomic, assign) BOOL isLeaveConf;
@property (nonatomic, assign) BOOL isCloseCamera;
@property (nonatomic, assign) BOOL isCallTransToConf;
//@property (nonatomic, strong) TUPCallSessionModifyInfo *currentCallSession;
@property (weak, nonatomic) IBOutlet UITextField *accessCodeTextField;
@property (nonatomic, strong)ConferenceView *confView;
@property (nonatomic, copy) NSString *hostNumber;
@property (nonatomic, copy) NSString *presentNumber;


@end


@implementation MeetingViewController


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self addNotify];
    _x =self.navigationController.view.bounds.origin.x;
    _y =self.navigationController.view.bounds.origin.y;
    _width =self.view.frame.size.width;
    _height =self.view.frame.size.height;
    [TUPService confService].delegate = self;
    [TUPService loginService].delegate = self;
    [TUPService callService].delegate = self;
//    [TUPService dataConfService].delegate = self;
//    [TUPDataConfComponentService shareInstanced].delegate = self;
    [[TUPService confService] obtainConferenceListWithPageIndex:1 pageSize:10];

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initAboutUI];
    _isCloseCamera = NO;
    _isBeKickOut = NO;
    _isShowSiteListe = NO;
    _isMuteAllConf = NO;
    _chatMsgArray = [[NSMutableArray alloc] init];
    _remoteCameraInfoArray = [[NSMutableArray alloc] init];
    _confListArray = [[NSMutableArray alloc] init];
    _remoteView = [EAGLView getRemoteView];
    _locationView = [EAGLView getLocalView];
//    [[TUPService dataConfService] configDataConfLocalView:_locationView remoteView:_remoteView];
}

-(void)initAboutUI
{
    _callingActivityIndicator.hidden = YES;
    TUPLoginInfo *mine = [[TUPService loginService] obtainCurrentLoginInfo];
    self.title = [NSString stringWithFormat:@"%@(%@)",mine.account,[TUPService callService].sipAccount];
    self.conferenceListTableView.dataSource = self;
    self.conferenceListTableView.delegate = self;
    self.conferenceListTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.conferenceListTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    UIBarButtonItem *rightItem1 = [[UIBarButtonItem alloc]initWithTitle:@"Refresh" style:UIBarButtonItemStylePlain target:self action:@selector(refreshConfList)];
    self.navigationItem.rightBarButtonItem = rightItem1;
}

-(void)refreshConfList
{
    [[TUPService confService] obtainConferenceListWithPageIndex:1 pageSize:10];
}


-(void)addNotify
{

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(networkStatusChangeNotify:)
                                                 name:NETWORK_STATUS_CHAGNE_NOTIFY
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appUnactiveNotify:)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appActiveNotify:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
}

-(void)networkStatusChangeNotify:(NSNotification *)notify
{
    NetworkStatus netStatus = (NetworkStatus)[[notify object] integerValue];
    if (netStatus == NotReachable)
    {
        [self showMessage:@"Current network is unavailable"];
        [[TUPService loginService] logout];
    }
}

- (void) appUnactiveNotify:(NSNotification*) notify
{
    [EAGLView hideRemoteView];
    [EAGLView hideLocalView];
//    [[TUPService dataConfService] controlDataConferenceWhenApplicationResignActive:NO];
}

- (void) appActiveNotify:(NSNotification*) notify
{
    [EAGLView showRemoteView];
    [EAGLView showLocalView];
//    [[TUPService dataConfService] controlDataConferenceWhenApplicationResignActive:YES];
}
- (IBAction)accessCodeJoinConfButtonAciton:(id)sender
{
    if (self.accessCodeTextField.text.length == 0)
    {
        [self showMessage:@"Conference access code can not be empty!"];
        return;
    }
    _isAccessCodeWayToJoinConf = YES;
    [[TUPService callService] startCallWithNumber:self.accessCodeTextField.text type:CALL_AUDIO];
}

- (IBAction)createVoiceConferenceAction:(id)sender
{
    AddAttendeeViewController *addAttendeeVc = [[AddAttendeeViewController alloc] initWithNibName:@"AddAttendeeViewController" bundle:nil];
    addAttendeeVc.isBookConf = NO;
    addAttendeeVc.confMediaType = CONF_MEDIATYPE_VOICE;
    [self presentViewController:addAttendeeVc animated:YES completion:nil];
}

- (IBAction)bookVoiceConfButtonAction:(id)sender
{
    AddAttendeeViewController *addAttendeeVc = [[AddAttendeeViewController alloc] initWithNibName:@"AddAttendeeViewController" bundle:nil];
    addAttendeeVc.isBookConf = YES;
    addAttendeeVc.confMediaType = CONF_MEDIATYPE_VOICE;
    [self presentViewController:addAttendeeVc animated:YES completion:nil];
}
- (IBAction)bookDataConfButtonAction:(id)sender
{
    AddAttendeeViewController *addAttendeeVc = [[AddAttendeeViewController alloc] initWithNibName:@"AddAttendeeViewController" bundle:nil];
    addAttendeeVc.isBookConf = YES;
    addAttendeeVc.confMediaType = CONF_MEDIATYPE_DATA;
    [self presentViewController:addAttendeeVc animated:YES completion:nil];
}
- (IBAction)createDataConfButtonAction:(id)sender
{
    AddAttendeeViewController *addAttendeeVc = [[AddAttendeeViewController alloc] initWithNibName:@"AddAttendeeViewController" bundle:nil];
    addAttendeeVc.isBookConf = NO;
    addAttendeeVc.confMediaType = CONF_MEDIATYPE_DATA;
    [self presentViewController:addAttendeeVc animated:YES completion:nil];
}

-(void)callTransToConf:(NSString *)confId
{
    [[TUPService confService] calledToJoinConf:confId];
    [self showConferenceView];
    self.navigationController.navigationBarHidden = YES;
    UILOG(@"self.navigationController.navigationBarHidden = YES");
    _isCallTransToConf = YES;
}

#pragma mark - Login callback

-(void)loginEventCallback:(TUP_LOGIN_EVENT_TYPE)loginEvent result:(NSDictionary *)resultDictionary
{
    switch (loginEvent)
    {
//        case LOGOUT_RESULT_EVENT:
//        {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
//                LoginViewController *loginViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
//                [AppDelegate sharedAppDelegate].window.rootViewController = loginViewController;
////                [TUPService confService].delegate = nil;
//            });
//            break;
//        }
//        case LOGIN_BE_KITOUT_EVENT:
//        {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                _isBeKickOut = YES;
////                if ([[TUPService confService] getCurrentConfDetailInfo] != nil)
////                {
////                    [[TUPService dataConfService] leaveDataConference];
////                }
//                [self finishConference];
//                [self beKickoutToLogout];
//            });
//            break;
//        }
//        case LOGIN_STATUS_CHANGE:
//        {
//            dispatch_async(dispatch_get_main_queue(), ^{
////                if ([[TUPService confService] getCurrentConfDetailInfo] != nil)
////                {
////                    [[TUPService dataConfService] leaveDataConference];
////                }
//                [[[UIAlertView alloc] initWithTitle:nil message:@"Your account is unavailable, please login again!" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil]show];
//                UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
//                LoginViewController *loginViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
//                [AppDelegate sharedAppDelegate].window.rootViewController = loginViewController;
////                [TUPService confService].delegate = nil;
//            });
//            break;
//        }
        default:
            break;
    }
}

-(void)beKickoutToLogout
{
    [[[UIAlertView alloc] initWithTitle:nil message:@"Your account login in other place!" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil]show];
    [[TUPService loginService] logout];
}

#pragma mark - Call callback
-(void)callEventCallback:(TUP_CALL_EVENT_TYPE)callEvent result:(NSDictionary *)resultDictionary
{
    dispatch_async(dispatch_get_main_queue(), ^{
        switch (callEvent)
        {
            case CALL_CLOSE:
            {
//                [self showMessage:@"Conference End"];
                [self finishConference];
                if (_isBeKickOut)
                {
                    [self beKickoutToLogout];
                }
            }
                break;
            case CALL_INCOMMING:
            {
                NSLog(@"meeting CALL_INCOMMING");
                TupCallInfo *tupCallInfo = resultDictionary[TUP_CALL_INFO_KEY];
                _currentTupCallInfo = [[TupCallInfo alloc] init];
                _currentTupCallInfo = tupCallInfo;
                [MeetingViewController cancelPreviousPerformRequestsWithTarget:self selector:@selector(handleUnreviceCallIncommingEvent) object:nil];
                if (_isSelectedConfToJoin == YES)
                {
                    return;
                }
                if (_currentTupCallInfo.serverConfId.length == 0)
                {
                    return;
                }
                BOOL autoAnswer = [self handleConfAutoAnswer];
                if (autoAnswer)
                {
                    UILOG(@"show audio view");
                    [self showConferenceView];
                    [[CallTipView shareInstance] removeCommingCallTipView];
                    self.navigationController.navigationBarHidden = YES;
                    return ;
                }
                [[CallTipView shareInstance] showCommingCallTipViewInUIView:self.view delegate:self];
                [CallTipView shareInstance].commingView.currentConfType = AudioConfType;
                [CallTipView shareInstance].commingView.displayCallNumberLabel.text = @"INCOMMING";
            }
                break;
            case CALL_CONNECT:
            {
                UILOG(@"CALL_CONNECT show audio view");
                TupCallInfo *tupCallInfo = resultDictionary[TUP_CALL_INFO_KEY];
                self.currentTupCallInfo = tupCallInfo;
                [self showConferenceView];
                [[CallTipView shareInstance] removeCommingCallTipView];
                self.navigationController.navigationBarHidden = YES;
                if (_isAccessCodeWayToJoinConf)
                {
                    return;
                }
                ECCurrentConfInfo *ecConfInfo = [[TUPService confService] getCurrentConfDetailInfo];
                if (ecConfInfo.confDetailInfo.conf_id.length == 0)
                {
                    [[TUPService confService] calledToJoinConf:_currentTupCallInfo.serverConfId];
                }
                
            }
                break;
            case CALL_SESSION_MODIFIED:
            {
                TUPCallSessionModifyInfo *callSession = resultDictionary[TUP_CALL_SESSION_MODIFIED_KEY];
                //                self.currentCallSession = callSession;
                if (callSession.serverConfID.length == 0)
                {
//                    [self showMessage:@"The method can not used to join the data conference"];
                    return;
                }
                [[TUPService confService] calledToJoinConf:callSession.serverConfID];
                _isAccessCodeWayToJoinConf = NO;
            }
                break;
            case CALL_DATACONF_PARAM:
            {
                if (_isAccessCodeWayToJoinConf)
                {
                    NSString *confId = resultDictionary[TUP_CALL_DATACONF_ID_KEY];
                    UILOG(@"confId: %@",confId);
                    [[TUPService confService] calledToJoinConf:confId];
                    _isAccessCodeWayToJoinConf = NO;
                }
            }
                break;
            default:
                break;
        }
    });
    
}

-(void)showConferenceView
{
    if (!_confView)
    {
        ConferenceView *confView = [[ConferenceView alloc] init];
        confView.frame = self.view.bounds;
        confView.delegate = self;
        confView.isEnterConf = NO;
        _confView = confView;
        [self.view addSubview:confView];
    }
}

-(void)addGLViewInConfView:(ConferenceView *)confView
{
    UILOG(@"addGLViewInConfView");
    // video remote view
    _remoteView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    [confView addSubview:_remoteView];
    [confView sendSubviewToBack:_remoteView];
    [confView sendSubviewToBack:confView.tipLabel];
    // video local view
    _locationView.frame = CGRectMake([UIScreen mainScreen].bounds.size.width - 200, 0, 200, 150);
    [confView insertSubview:_locationView aboveSubview:_remoteView];
}


-(void)handleUnreviceCallIncommingEvent
{
    _isSelectedConfToJoin = YES;
    _selectedConfInfo = nil;
}

-(BOOL)handleConfAutoAnswer
{
    BOOL autoAnswer = NO;
    UILOG(@"_currentTupCallInfo.serverConfId : %@",_currentTupCallInfo.serverConfId);
    if (_currentTupCallInfo.serverConfId.length > 0)
    {
        //select conf list and than join the conference
        if (_selectedConfInfo)
        {
            UILOG(@"currentCallInfo.serverConfId : %@, _selectedConfInfo conf_id:%@",_currentTupCallInfo.serverConfId,_selectedConfInfo.conf_id);
            if ([_currentTupCallInfo.serverConfId isEqualToString:_selectedConfInfo.conf_id])
            {
                [[TUPService callService] answerComingCallType:CALL_AUDIO callId:_currentTupCallInfo.stateInfo.callId];
                _selectedConfInfo = nil;
                autoAnswer = YES;
            }
        }
        else
        {
            //immediately create conference
            ECCurrentConfInfo *ecConfInfo = [[TUPService confService] getCurrentConfDetailInfo];
            if (ecConfInfo.confDetailInfo.conf_id.length == 0)
            {
                UILOG(@"current confinfo is nil");
            }
            if ([ecConfInfo.confDetailInfo.conf_id isEqualToString:_currentTupCallInfo.serverConfId])
            {
                UILOG(@"Current is auto answer conference incomming");
                TUP_CALL_TYPE calltype = CALL_AUDIO;
                [[TUPService callService] answerComingCallType:calltype callId:_currentTupCallInfo.stateInfo.callId];
                autoAnswer = YES;
            }
        }
    }
    else
    {
        UILOG(@"_currentTupCallInfo is nil, autoAnswer is %d",autoAnswer);
    }
    UILOG(@"autoAnswer is %d",autoAnswer);
    return autoAnswer;
}


#pragma mark - Voice conference ballback
-(void)ecConferenceEventCallback:(EC_CONF_E_TYPE)ecConfEvent result:(NSDictionary *)resultDictionary
{
    dispatch_async(dispatch_get_main_queue(), ^{
        switch (ecConfEvent)
        {
            case CONF_E_ADD_ATTENDEE_RESULT:
            {
                BOOL result = [resultDictionary[ECCONF_RESULT_KEY] boolValue];
                UILOG(@"result is :%d",result);
                if (!result)
                {
                    if (_currentConfStatus.media_type == CONF_MEDIATYPE_DATA)
                    {
                        [self handleJoinDataConferenceFail];
                    }
                    [self showMessage:@"add attendee failed"];
                    return ;
                }
            }
                break;
            case CONF_E_CREATE_RESULT:
            {
                BOOL result = [resultDictionary[ECCONF_RESULT_KEY] boolValue];
                if (!result)
                {
                    [self showMessage:@"Create conference failed"];
                    [self finishConference];
                    return ;
                }
                [self showMessage:@"Create conference success"];
                [self performSelector:@selector(refreshConfList) withObject:nil afterDelay:3];
            }
                break;
            case CONF_E_GET_CONFLIST:
            {
                NSMutableArray *tempArray = resultDictionary[ECCONF_LIST_KEY];
                [self.confListArray removeAllObjects];
                self.confListArray = tempArray;
                [self.conferenceListTableView reloadData];
            }
                break;
            case CONF_E_CURRENTCONF_DETAIL:
            {
                _currentConfInfo = resultDictionary[ECCONF_CURRENTCONF_DETAIL_KEY];
                
            }
                break;
            case CONF_E_ATTENDEE_UPDATE_INFO:
            {
                _currentConfStatus = resultDictionary[ECCONF_ATTENDEE_UPDATE_KEY];
                _confView.isEnterConf = YES;
                _confView.isDataConf = NO;
                UILOG(@"CONF_E_ATTENDEE_UPDATE_INFO media_type: %d CONF_MEDIATYPE_DATA---:%d",_currentConfStatus.media_type,CONF_MEDIATYPE_DATA);
                if (_currentConfStatus.media_type == CONF_MEDIATYPE_DATA)
                {
                    _confView.isDataConf = YES;
                }
                
                NSArray *resultArray = _currentConfStatus.participants;
                if (resultArray.count == 0)
                {
                    return;
                }
                _attendeeInConfListArray = resultArray;
                NSString *sipAccount = [TUPService callService].sipAccount;
                NSArray *array = [sipAccount componentsSeparatedByString:@"@"];
                NSString *shortSipNum = array[0];
                for (ConfAttendeeInConf *tempAttendee in _attendeeInConfListArray)
                {
                    if ([tempAttendee.number isEqualToString:sipAccount] || [tempAttendee.number isEqualToString:shortSipNum])
                    {
                        _mineConfInfo = tempAttendee;
                    }
                }
                [SiteView shareInstance].attendeeArray = _attendeeInConfListArray;
            }
                break;
            case CONF_E_END_RESULT:
            {
                [self performSelector:@selector(refreshConfList) withObject:nil afterDelay:3];
            }
                break;
            case CONF_E_MUTE_RESULT:
            {
                BOOL muteResult = [resultDictionary[ECCONF_RESULT_KEY] boolValue];
                [self showMessage:[NSString stringWithFormat:@"Modify conference mute status %@",muteResult ? @"Success" :@"Failed"]];
                if (muteResult)
                {
                    BOOL isMute = [resultDictionary[ECCONF_MUTE_KEY] boolValue];
                    _isMuteAllConf = isMute;
                    [SiteView shareInstance].isAllConferenceMute = _isMuteAllConf;
                }
            }
                break;
            case CONF_E_UPGRADE_RESULT:
            {
                BOOL result = [resultDictionary[ECCONF_RESULT_KEY] boolValue];
                if (!result)
                {
                    [self showMessage:@"Upgrade to data conference failed!"];
                }
            }
                break;
            case CONF_E_HANDUP_ATTENDEE_RESULT:
            {
                BOOL result = [resultDictionary[ECCONF_RESULT_KEY] boolValue];
                if (!result)
                {
                    [self showMessage:@"Handup attendee failure"];
                }
            }
                break;
                
            case CONF_E_SPEAKER_LIST:
            {
                NSArray *array = resultDictionary[ECCONF_SPEAKERLIST_KEY];
                NSString *sperkerStr = [[NSString alloc] init];
                if (array.count == 0)
                {
                    sperkerStr = @"No one";
                }
                if (array.count == 1)
                {
                    ConfCtrlSpeaker *speaker = array[0];
                    sperkerStr = [sperkerStr stringByAppendingString:[NSString stringWithFormat:@"%@",speaker.number]];
                }
                if (array.count > 1)
                {
                    NSSortDescriptor *sortDes = [[NSSortDescriptor alloc] initWithKey:@"speaking_volume" ascending:NO];
                    NSArray *result = [array sortedArrayUsingDescriptors:@[sortDes]];
                    
                    for (ConfCtrlSpeaker *speaker  in result)
                    {
                        sperkerStr = [sperkerStr stringByAppendingString:[NSString stringWithFormat:@"%@ ",speaker.number]];
                    }
                }
                _confView.speakerLabel.text = [NSString stringWithFormat:@"Current spokesman : %@",sperkerStr];
                [MeetingViewController cancelPreviousPerformRequestsWithTarget:self selector:@selector(setNobodySpeak) object:nil];
                [self performSelector:@selector(setNobodySpeak) withObject:nil afterDelay:5];
            }
                break;

            default:
                break;
        }
    });
}

-(void)setNobodySpeak
{
    _confView.speakerLabel.text = @"Current spokesman : no one";
}


#pragma mark - Data conference callback

//-(void)dataConferenceEventCallback:(TUP_DATA_CONFERENCE_EVENT_TYPE)conferenceEvent result:(NSDictionary *)resultDictionary
//{
//    
//    NSDictionary *resultInfo = resultDictionary[TUP_DATACONF_CALLBACK_RESULT_KEY];
//    switch (conferenceEvent)
//    {
//        case DATA_CONFERENCE_END:
//        {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                //[[TUPService confService] restoreConfParamsInitialValue];
//                [self finishConference];
//            });
//            break;
//        }
//        case DATA_CONFERENCE_LEAVE:
//        {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [[TUPService confService] confCtrlLeaveConference];
//                [self finishConference];
//            });
//            break;
//        }
//        case DATA_CONFERENCE_JOIN_RESULT:
//        {
//            UILOG(@"DATA_CONFERENCE_JOIN_RESULT");
//            dispatch_async(dispatch_get_main_queue(), ^{
//                BOOL isSuccess = [resultInfo[UCCONF_RESULT_KEY] boolValue];
//                if (isSuccess)
//                {
//                    [self addGLViewInConfView:_confView];
//                    _confView.upgradeButton.enabled = NO;
//                    self.navigationController.navigationBarHidden = YES;
//                    return ;
//                }
//                [self handleJoinDataConferenceFail];
//            });
//            break;
//        }
//        case DATACONF_RECEIVE_SHARE_DATA:
//        {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                UILOG(@"UILOG: DATACONF_RECEIVE_SHARE_DATA");
//                [self showShareView:resultInfo];
//            });
//            break;
//        }
//        case DATACONF_SHARE_STOP:
//        {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                UILOG(@"UILOG: DATACONF_SHARE_STOP");
//                [self removeShareView];
//            });
//            break;
//        }
//        case DATACONF_VEDIO_ON_SWITCH:
//        {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                UILOG(@"UILOG: DATACONF_VEDIO_ON_SWITCH");
//                BOOL videoOpen = [resultInfo[DATACONF_VIDEO_ON_SWITCH_KEY] boolValue];
////                [EAGLView hideRemoteView];
////                if (videoOpen)
////                {
////                    [EAGLView showRemoteView];
////                }
//                if (!videoOpen)
//                {
//                    int otherUserId = [resultInfo[DATACONF_VIDEO_ON_SWITCH_USERID_KEY] intValue];
//                    if (otherUserId != 0)
//                    {
//                        if ([self checkMineRoleIsChairman])
//                        {
//                            [[TUPService dataConfService] confVideoNotifyOpenVideo:YES userId:otherUserId];
//                        }
//                    }
//                }
//            });
//            break;
//        }
//        case DATACONF_USER_LEAVE:
//        {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                NSString *leaveUserName = resultInfo[DATACONF_USER_LEAVE_KEY];
//                UILOG(@"user %@ leave",leaveUserName);
//                //                NSMutableArray *tempMutArray = [[NSMutableArray alloc] init];
//                //                tempMutArray = [[TUPService confService] getCurrentConfDetailInfo].memberList;
//                //                for (NSString *name in [[TUPService confService] getCurrentConfDetailInfo].memberList)
//                //                {
//                //                    if ([name isEqualToString:leaveUserName])
//                //                    {
//                //                        [tempMutArray removeObject:name];
//                //                    }
//                //                }
//                //                [SiteView shareInstance].attendeeArray = tempMutArray;
//            });
//            break;
//        }
//        case DATACONF_CHAT_MSG:
//        {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                TUPChatMsg *chatMsg = resultInfo[DATACONF_CHAT_MSG_KEY];
//                [self.chatMsgArray addObject:chatMsg];
//                [[IMView shareInstance] configDataWithArray:self.chatMsgArray];
//            });
//            break;
//        }
//        case DATACONF_REMOTE_CAMETAINFO:
//        {
//            UILOG(@"DATACONF_REMOTE_CAMETAINFO");
//            [_remoteCameraInfoArray removeAllObjects];
//            NSArray *tempCameraArray = resultInfo[DATACONF_REMOTE_CAMERA_KEY];
//            _remoteCameraInfoArray = [NSMutableArray arrayWithArray:tempCameraArray];
//            NSLog(@"_remoteCameraInfoArray--- :%@",_remoteCameraInfoArray);
//            break;
//        }
//        case DATACONF_VEDIO_ON_NOTIFY:
//        {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                BOOL isOpen = [resultInfo[DATACONF_VIDEO_ON_NOTIFY_KEY] boolValue];
//                UILOG(@"DATACONF_VEDIO_ON_NOTIFY isOpen: %d",isOpen);
//                if (isOpen)
//                {
//                    UIAlertController *alertCon = [UIAlertController alertControllerWithTitle:nil message:@"Chairman invite you to reopen camera" preferredStyle:UIAlertControllerStyleAlert];
//                    UIAlertAction *openAction = [UIAlertAction actionWithTitle:@"Open" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
////                        BOOL result = [[TUPDataConfComponentService shareInstanced] openLocalCamera];
//                        if (result)
//                        {
//                            _isCloseCamera = !_isCloseCamera;
//                            [SiteView shareInstance].isCloseCamera = _isCloseCamera;
//                        }
//                    }];
//                    [alertCon addAction:openAction];
//                    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:nil];
//                    [alertCon addAction:cancelAction];
//                    [self presentViewController:alertCon animated:YES completion:nil];
//                }
//            });
//            break;
//        }
//        case DATACONF_GET_HOST:
//        {
//            UILOG(@"DATACONF_GET_HOST");
//            NSArray *array = [[TUPService callService].sipAccount componentsSeparatedByString:@"@"];
//            NSString *shortSipNum = array[0];
//            _hostNumber = shortSipNum;
//            [SiteView shareInstance].hostNumber = _hostNumber;
//            break;
//        }
//        case DATACONF_GET_PERSENT:
//        {
//            UILOG(@"DATACONF_GET_PERSENT");
//            NSArray *array = [[TUPService callService].sipAccount componentsSeparatedByString:@"@"];
//            NSString *shortSipNum = array[0];
//            _presentNumber = shortSipNum;
//            [SiteView shareInstance].presentNumber = _presentNumber;
//            break;
//        }
//        case DATACONF_SET_HOST_RESULT:
//        {
//            UILOG(@"DATACONF_SET_HOST_RESULT");
//            BOOL result = [resultInfo[UCCONF_SET_HOST_RESULT_KEY] boolValue];
//            if (!result)
//            {
//                [self showMessage:@"Fali to set host role!"];
//            }
//            break;
//        }
//        case DATACONF_SET_PERSENTER_RESULT:
//        {
//            UILOG(@"DATACONF_SET_PERSENTER_RESULT");
//            BOOL result = [resultInfo[UCCONF_SET_PERSENTER_RESULT_KEY] boolValue];
//            if (!result)
//            {
//                [self showMessage:@"Fali to set persenter role!"];
//            }
//            break;
//        }
//        case DATACONF_HOST_CHANGE:
//        {
//            int newHostNumber = [resultInfo[UCCONF_NEWHOST_KEY] intValue];
//            _hostNumber = [NSString stringWithFormat:@"%d",newHostNumber];
//            UILOG(@"DATACONF_HOST_CHANGE,_hostNumber : %@",_hostNumber);
//            [SiteView shareInstance].hostNumber = _hostNumber;
//            break;
//        }
//        case DATACONF_PERSENTER_CHANGE:
//        {
//            int newPersenterNumber = [resultInfo[UCCONF_NEWPERSENTER_KEY] intValue];
//            _presentNumber = [NSString stringWithFormat:@"%d",newPersenterNumber];
//            UILOG(@"DATACONF_PERSENTER_CHANGE, _presentNumber: %@",_presentNumber);
//            [SiteView shareInstance].presentNumber = _presentNumber;
//            break;
//        }
//        default:
//            break;
//    }
//
//}


-(void)handleJoinDataConferenceFail
{
//    [[TUPService dataConfService] leaveDataConference];
    [[TUPService confService] confCtrlLeaveConference];
    [self finishConference];
    
    dispatch_async(dispatch_get_main_queue(), ^{
    UIAlertController *alertCon = [UIAlertController alertControllerWithTitle:nil message:@"Upgrade to Data conference fail,maybe MS server address error" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alertCon addAction:okAction];
    [self presentViewController:alertCon animated:YES completion:nil];
    });
}

-(void)showShareView:(NSDictionary *)resultDictionary
{
//    [self isChangeUIOrientationToLandspaceRight:YES];
    UIImage *catchShareImage = resultDictionary[DATACONF_SHARE_DATA_KEY];
    [_confView showDesktopShareView:catchShareImage];
}

-(void)removeShareView
{
//    [self isChangeUIOrientationToLandspaceRight:NO];
    [_confView hideDesktopShareView];
}


-(void)finishConference
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.navigationController.navigationBarHidden = NO;
        _callingActivityIndicator.hidden = YES;
        [_callingActivityIndicator stopAnimating];
        _isShowSiteListe = NO;
        [self isChangeUIOrientationToLandspaceRight:NO];
        [SiteView shareInstance].isLockConference = NO;
        [SiteView shareInstance].isAllConferenceMute = NO;
        [SiteView shareInstance].isCloseCamera = NO;
        [EAGLView destroyLocalView];
        [EAGLView destroyRemoteView];
        [[SiteView shareInstance] hideSiteView];
        [[CallTipView shareInstance] removeCommingCallTipView];
        [[DialSecondPlate shareInstance] hideView];
        [[IMView shareInstance] hideIMView];
        _currentTupCallInfo = nil;
        [_confView hideDesktopShareView];
        [_confView removeFromSuperview];
        _confView = nil;
        _isBeKickOut = NO;
        _isMuteAllConf = NO;
        _isJoinConference = NO;
        _isSelectedConfToJoin = NO;
        _isAccessCodeWayToJoinConf = NO;
        _isCloseCamera = NO;
        [_remoteCameraInfoArray removeAllObjects];
        [_chatMsgArray removeAllObjects];
        _chatMsgArray = nil;
        _hostNumber = @"";
        if (_isCallTransToConf)
        {
            [self.navigationController popViewControllerAnimated:YES];
        }
    });
}


#pragma mark - CommingTipViewDelegate
-(void)clickCommingTipViewButton:(COMMING_VIEW_BTNACTION_TYPE)actionType
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (actionType == ANSWER_COMMING_CALL)
        {
            BOOL result = [[TUPService callService] answerComingCallType:CALL_AUDIO callId:_currentTupCallInfo.stateInfo.callId];
            if (result)
            {
//                [self showConferenceView];
//                self.navigationController.navigationBarHidden = YES;
                [[CallTipView shareInstance] removeCommingCallTipView];
                [self performSelector:@selector(refreshConfList) withObject:nil afterDelay:3];
            }
        }
        else
        {
            [[TUPService callService] closeCall:_currentTupCallInfo.stateInfo.callId];
        }
        [[CallTipView shareInstance] removeCommingCallTipView];
    });
}



#pragma mark - CallToolBarDelegate

-(void)clickConferenceToolBarType:(CONF_TOOLBAR_BUTTON_TYPE)type
{
    dispatch_async(dispatch_get_main_queue(), ^{
        switch (type)
        {
            case CONF_END_BUTTON:
            {
                [self closeButtonAction];
                break;
            }
            case CONF_SITE_LIST_BUTTON:
            {
                if (_attendeeInConfListArray.count == 0)
                {
                    [self showMessage:@"Please wait..."];
                    BOOL result = [[TUPService confService] obtainConferenceDetailInfoWithConfId:_currentTupCallInfo.serverConfId Page:1 pageSize:10];
                    if (!result)
                    {
                        [self showMessage:@"Get attendee list failed"];
                    }
                    return ;
                }
                [[SiteView shareInstance] showSiteViewInSuperView:self.view Delegate:self];
                [SiteView shareInstance].attendeeArray = _attendeeInConfListArray;
                break;
            }
            case CONF_UPGRADE_BUTTON:
            {
                if (![self checkMineRoleIsChairman])
                {
                    [self showMessage:@"You are not chairman!"];
                    return;
                }
                [[TUPService confService] confCtrlVoiceUpgradeToDataConference];
                break;
            }
            case CONF_DIAL_NUMBER_BUTTON:
            {
                if ([DialSecondPlate shareInstance].isShow)
                {
                    [[DialSecondPlate shareInstance] hideView];
                    return;
                }
                [[DialSecondPlate shareInstance] showViewInSuperView:self.view Delegate:self];
            }
                break;
            default:
                break;
        }

        
    });
}

-(void)clickDialSecondPlate:(NSString *)string
{
    [[TUPService callService] sendDTMFWithDialNum:string callId:_currentTupCallInfo.stateInfo.callId];
}


-(void)closeButtonAction
{
    if (_isAccessCodeWayToJoinConf)
    {
        BOOL result = [[TUPService callService] closeCall:self.currentTupCallInfo.stateInfo.callId];
        if (result)
        {
            _isAccessCodeWayToJoinConf = NO;
        }
        return ;
    }
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *closeMeetingAction = [UIAlertAction actionWithTitle:@"End" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        BOOL result = YES;
        if (_currentConfStatus.media_type == CONF_MEDIATYPE_DATA || _currentConfStatus.media_type == 16)
        {
//            result = [[TUPService dataConfService] closeDataConference];
        }
        if (!result)
        {
            [self showMessage:@"Fail to end conference!"];
            return ;
        }
        [[TUPService confService] confCtrlEndConference];
        [self finishConference];
    }];
    
    UIAlertAction *leaveMeetingAction = [UIAlertAction actionWithTitle:@"Leave" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSArray *array = [[TUPService callService].sipAccount componentsSeparatedByString:@"@"];
        NSString *shortSipNum = array[0];
        if (_currentConfStatus.media_type == CONF_MEDIATYPE_DATA)
        {
//            [[TUPService dataConfService] leaveDataConference];
        }
        [[TUPService confService] confCtrlHangUpAttendee:shortSipNum];
        BOOL result = [[TUPService confService] confCtrlLeaveConference];
        if (result)
        {
            [self showMessage:@"You have been leave"];
            [self finishConference];
            return ;
        }
        [self showMessage:@"Fail to leave conference!"];
        
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    if ([self checkMineRoleIsChairman])
    {
        [alertController addAction:closeMeetingAction];
    }
    [alertController addAction:leaveMeetingAction];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];

}

-(void)handleForceCloseMeeting:(BOOL)isEndMeeting
{
    NSString *tipMsg = isEndMeeting ? @"Fail to end conference!" : @"Fail to leave conference!";
    [self showMessage:tipMsg];
    NSString *titleMsg = isEndMeeting ? @"Force end meeting" : @"Force leave meeting";
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *closeMeetingAction = [UIAlertAction actionWithTitle:@"Force close meeting" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (isEndMeeting)
        {
//            [[TUPService dataConfService] closeDataConference];
            [[TUPService confService] confCtrlEndConference];
        }
        else
        {
            NSArray *array = [[TUPService callService].sipAccount componentsSeparatedByString:@"@"];
            NSString *shortSipNum = array[0];
//            [[TUPService dataConfService] leaveDataConference];
            [[TUPService confService] confCtrlHangUpAttendee:shortSipNum];
            [[TUPService confService] confCtrlLeaveConference];
        }
        [self finishConference];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:closeMeetingAction];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - SiteViewDelegate
-(void)clickSiteViewTopButtonAction:(SITEVIEW_TOP_ACTION_TYPE)type
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        switch (type)
        {
            case LOCK_CONFERENCE_ACTION:
            {
                if (![self checkMineRoleIsChairman])
                {
                    [self showMessage:@"You are not the chairman!"];
                    return;
                }
                BOOL isLock = _currentConfStatus.lock_state ? NO : YES;
                BOOL isSuccess = [[TUPService confService] confCtrlLockConference:isLock];
                if (isSuccess)
                {
                    [SiteView shareInstance].isLockConference = ![SiteView shareInstance].isLockConference;
                }
                break;
            }
            case MUTE_ALLCONFERENCE_ACTION:
            {
                if (![self checkMineRoleIsChairman])
                {
                    [self showMessage:@"You are not the chairman!"];
                    return;
                }
                BOOL isSuccess = [[TUPService confService] confCtrlMuteConference:!_isMuteAllConf];
                if (!isSuccess)
                {
                    [self showMessage:@"Mute conference failed"];
                }
                break;
            }
            case ADD_ATTENDEE_ACTION:
            {
                [self handleAddAttendeeEvent];
                break;
            }
            case SEND_MSG_ACTION:
            {
                ECCurrentConfInfo *confData = [[TUPService confService] getCurrentConfDetailInfo];
                if (_currentConfStatus.media_type != CONF_MEDIATYPE_DATA)
                {
                    [self showMessage:@"Please upgrade to data conference!"];
                    return;
                }
                [[IMView shareInstance] showIMViewWithFrame:CGRectMake(10, 10, [UIScreen mainScreen].bounds.size.width - 20, [UIScreen mainScreen].bounds.size.height /2) inSuperView:self.view delegate:self];
                [[SiteView shareInstance] hideSiteView];
                break;
            }
            case WATCH_ACTION:
            {
                NSLog(@"WATCH_ACTION _remoteCameraInfoArray:%@",_remoteCameraInfoArray);
                ECCurrentConfInfo *confData = [[TUPService confService] getCurrentConfDetailInfo];
                if (_currentConfStatus.media_type != CONF_MEDIATYPE_DATA)
                {
                    [self showMessage:@"Please upgrade to data conference!"];
                    return;
                }
                if (_remoteCameraInfoArray.count == 0)
                {
                    [self showMessage:@"Please wait for remote camera open!"];
                    return;
                }
                [CameraInfoView sharedInstance].cameraInfoArray = _remoteCameraInfoArray;
                [[CameraInfoView sharedInstance] showCameraInfoViewIn:self.view delegate:self];
                
                break;
            }
            case CLOSE_CAMERA_ACTION:
            {
                UILOG(@"CLOSE_CAMERA_ACTION");
                if (_currentConfStatus.media_type != CONF_MEDIATYPE_DATA)
                {
                    [self showMessage:@"Please upgrade to data conference!"];
                    return;
                }
                if (_isCloseCamera)
                {
//                    [[TUPDataConfComponentService shareInstanced] openLocalCamera];
                }
                else
                {
//                    [[TUPDataConfComponentService shareInstanced] closeLocalCamera];
                }
                _isCloseCamera = !_isCloseCamera;
                [SiteView shareInstance].isCloseCamera = _isCloseCamera;
                [[SiteView shareInstance] hideSiteView];
            }
                break;
            default:
                break;
        }

    });
}

-(void)didSelectedCameraInfo:(ConfCameraInfo *)cameraInfo
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"cameraInfo---- :%@",cameraInfo);
//        [[TUPService dataConfService] selectedCameraInfoToWatch:cameraInfo];
        [[CameraInfoView sharedInstance] removeFromSuperview];
        [[SiteView shareInstance] hideSiteView];
    });
}

//IMView Delegate
-(void)sendButtonAction:(NSString *)message
{
//    if ([[TUPService dataConfService] sendIMMessageToAll:message])
//    {
//        [[IMView shareInstance] cleanTextFileContent];
//        return;
//    }
    UILOG(@"send message error");
}

-(void)handleAddAttendeeEvent
{
    if (![self checkMineRoleIsChairman])
    {
        [self showMessage:@"You are not the chairman!"];
        return;
    }
    UIAlertController *alertCon = [UIAlertController alertControllerWithTitle:nil message:@"Please enter participant number..." preferredStyle:UIAlertControllerStyleAlert];
    [alertCon addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Please enter participant number...";
        textField.secureTextEntry = NO;
        textField.keyboardType = UIKeyboardTypeNumberPad;
    }];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UITextField *accountTxf = alertCon.textFields.firstObject;
        ConfAttendee *cAttendee = [[ConfAttendee alloc] init];
        cAttendee.name = accountTxf.text;
        cAttendee.number = accountTxf.text;
        NSArray *addAttendeeArray = @[cAttendee];
        [[TUPService confService] confCtrlAddAttendeeToConfercene:addAttendeeArray];
    }];
    [alertCon addAction:okAction];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:nil];
    [alertCon addAction:cancelAction];
    [self presentViewController:alertCon animated:YES completion:nil];
}

#pragma mark - Choice Member
-(void)selectECConferenceMemberInTableView:(ConfAttendeeInConf *)member
{
    UILOG(@"selectECConferenceMembe : %@",member.number);
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Menu" message:nil preferredStyle:UIAlertControllerStyleAlert];

    NSString *speakTitle = member.is_mute ? @"UnMute" : @"Mute";
    UIAlertAction *muteAction = [UIAlertAction actionWithTitle:speakTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[TUPService confService] confCtrlMuteAttendee:member.number isMute:member.is_mute ? NO : YES];
    }];

    UIAlertAction *deleteAttendeeAction = [UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (_currentConfStatus.media_type == CONF_MEDIATYPE_DATA)
        {
//            [[TUPService dataConfService] kickoutUser:[member.number intValue]];
        }
        [[TUPService confService] confCtrlHangUpAttendee:member.number];
    }];
    UIAlertAction *setHostRoleAction = [UIAlertAction actionWithTitle:@"Host" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//        BOOL result = [[TUPService dataConfService] setRoleToUser:[member.number intValue] role:DATACONF_USER_ROLE_HOST];
//        if (!result)
//        {
//            [self showMessage:@"The participants did not join the data conference"];
//        }
    }];
    UIAlertAction *setPresenterRoleAction = [UIAlertAction actionWithTitle:@"Presenter" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//        BOOL result = [[TUPService dataConfService] setRoleToUser:[member.number intValue] role:DATACONF_USER_ROLE_PRESENTER];
//        if (!result)
//        {
//            [self showMessage:@"The participants did not join the data conference"];
//        }
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:cancelAction];
    if (_mineConfInfo.state != ATTENDEE_STATUS_IN_CONF)
    {
        return;
    }
    if ([self checkMineRoleIsChairman])
    {
        if ([member.number isEqualToString:_mineConfInfo.number])
        {
            [alertController addAction:muteAction];
        }
        else
        {
            if (member.state == ATTENDEE_STATUS_IN_CONF)
            {
                [alertController addAction:muteAction];
                [alertController addAction:deleteAttendeeAction];
                [alertController addAction:setHostRoleAction];
                if (![_presentNumber isEqualToString:member.number])
                {
                    [alertController addAction:setPresenterRoleAction];
                }
            }
        }
    }
    else
    {
        if ([member.number isEqualToString:_mineConfInfo.number])
        {
            [alertController addAction:muteAction];
        }
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:alertController animated:YES completion:nil];
    });
}

-(BOOL)checkMineRoleIsChairman
{
    BOOL isChairman = NO;
    if (_hostNumber.length > 0)
    {
        if ([_hostNumber isEqualToString:_mineConfInfo.number])
        {
            isChairman = YES;
        }
    }
    else
    {
        if (_mineConfInfo.role == CONF_ROLE_CHAIRMAN)
        {
            isChairman = YES;
        }
    }
    UILOG(@"isChairman : %d, hostNumber : %@",isChairman,_hostNumber);
    return isChairman;
}

-(BOOL)checkIsExitSelfAccount:(NSString *)account InArray:(NSArray *)array
{
    BOOL isExit = NO;
    for (NSString *name in array)
    {
        if ([name isEqualToString:account])
        {
            isExit = YES;
        }
    }
    return isExit;
}

-(void)deletePaticipantsNotify:(NSNotification *)notify
{
    [self showMessage:@"You must be join the Conference!"];
}



#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _confListArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    ECConfInfo *confInfo = _confListArray[indexPath.row];
    cell.textLabel.text = confInfo.conf_subject;
    cell.detailTextLabel.text = confInfo.start_time;
    return cell;
}


- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Conference List :";
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.view endEditing:YES];
    ECConfInfo *confInfo = _confListArray[indexPath.row];
    ConfDetailViewController *detailVc = [[ConfDetailViewController alloc] initWithNibName:@"ConfDetailViewController" bundle:nil];
    detailVc.confInfo = confInfo;
    detailVc.meetingVc = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:detailVc animated:YES completion:nil];
    });
}

-(void)showMessage:(NSString *)msg
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:msg preferredStyle:UIAlertControllerStyleAlert];
    [self presentViewController:alert animated:NO completion:nil];
    [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(creatAlert:) userInfo:alert repeats:NO];
}

- (void)creatAlert:(NSTimer *)timer
{
    UIAlertController *alert = [timer userInfo];
    [alert dismissViewControllerAnimated:YES completion:nil];
    alert = nil;
}


-(void)isChangeUIOrientationToLandspaceRight:(BOOL)landscapeRight
{
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        if (landscapeRight)
        {
            CGFloat duration = [UIApplication sharedApplication].statusBarOrientationAnimationDuration;
            [UIView animateWithDuration:duration animations:^{
                [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeRight animated:NO];
                self.navigationController.view.transform =CGAffineTransformMakeRotation(M_PI_2);
                self.navigationController.view.bounds = CGRectMake(self.navigationController.view.bounds.origin.x,self.navigationController.view.bounds.origin.y,self.view.frame.size.height,self.view.frame.size.width);
                self.view.frame =CGRectMake(0,0,self.view.frame.size.height,self.view.frame.size.width);
            }];
        }
        else
        {
            CGFloat duration = [UIApplication sharedApplication].statusBarOrientationAnimationDuration;
            [UIView animateWithDuration:duration animations:^{
                [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait animated:NO];
                self.navigationController.view.transform=CGAffineTransformIdentity;
                self.navigationController.view.frame = CGRectMake(_x,_y, _width,_height);
                self.view.frame =CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height);
            }];
        }
    }
}


-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
//    [TUPService confService].delegate = nil;
}
@end
