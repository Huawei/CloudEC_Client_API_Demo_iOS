//
//  CallViewController.m
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

#import "CallViewController.h"

#import "CommonUtils.h"
#import "AppDelegate.h"
#import "NetworkUtils.h"
#import "ManagerService.h"
#import "LoginInfo.h"
#import "DeviceMotionManager.h"
#import "CallWindowController.h"
#import "CallHistoryViewController.h"
#import "EAGLView.h"

#define CALL_TYPE_CONFIG    @"CALL_TYPE_CONFIG"

typedef enum
{
    CALL_TYPE_VOIP,
    CALL_TYPE_CTD
}CURRENT_CALL_TYPE;

@interface CallViewController ()

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *callingActivityIndicator;
@property (weak, nonatomic) IBOutlet UITextField *callNumberTextFiled;
@property (nonatomic, strong)UIBarButtonItem *callTypeBtn;
@end

@implementation CallViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    _callingActivityIndicator.hidden = YES;
    self.navigationController.navigationBarHidden = NO;
    self.tabBarController.tabBar.hidden = NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.callTypeBtn = [[UIBarButtonItem alloc]initWithTitle:@"Config" style:UIBarButtonItemStylePlain target:self action:@selector(configBtnAction)];
    self.navigationItem.rightBarButtonItems = @[_callTypeBtn];
    
    UIBarButtonItem *callHistory = [[UIBarButtonItem alloc]initWithTitle:@"CallHistory" style:UIBarButtonItemStylePlain target:self action:@selector(goCallHistoryView)];
    self.navigationItem.leftBarButtonItem = callHistory;
    
    [self updateCurrentCallType];
}

- (void)updateCurrentCallType
{
    NSNumber *callType = [CommonUtils getUserDefaultValueWithKey:CALL_TYPE_CONFIG];
    switch (callType.integerValue) {
        case CALL_TYPE_VOIP:
            _callTypeBtn.title = @"Setting(VoIP)";
            break;
        case CALL_TYPE_CTD:
            _callTypeBtn.title = @"Setting(CTD)";
            break;
        default:
            break;
    }
}

- (IBAction)videoCallBtnClick:(id)sender
{
    [self.view endEditing:YES];
    [self startCallWithType:CALL_VIDEO isCTD:NO];
}

- (IBAction)callBtnClick:(id)sender
{
    [self.view endEditing:YES];

    NSNumber *callType = [CommonUtils getUserDefaultValueWithKey:CALL_TYPE_CONFIG];
    switch (callType.integerValue) {
        case CALL_TYPE_VOIP:
            [self startCallWithType:CALL_AUDIO isCTD:NO];
            break;
        case CALL_TYPE_CTD:
            [self startCallWithType:CALL_AUDIO isCTD:YES];
            break;
        default:
            break;
    }
}

- (IBAction)delteBtnClick:(id)sender
{
    if (_callNumberTextFiled.text.length == 0) {
        return;
    }
    _callNumberTextFiled.text = [_callNumberTextFiled.text substringToIndex:_callNumberTextFiled.text.length-1];
}

- (IBAction)diaBtnClick:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    _callNumberTextFiled.text = [_callNumberTextFiled.text stringByAppendingString:btn.titleLabel.text];
}

- (IBAction)num0LongPressed:(UIGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateBegan) {
        _callNumberTextFiled.text = [_callNumberTextFiled.text stringByAppendingString:@"+"];
    }
}

-(void)startCallWithType:(TUP_CALL_TYPE)callType isCTD:(BOOL)isCTD
{
    [self.view endEditing:YES];
    if ([[NetworkUtils shareInstance] getCurrentNetworkStatus] == ECSNotReachable)
    {
        [self showMessage:@"Current network is unavailable"];
        return;
    }
    if (![CommonUtils checkIsNotEmptyString:self.callNumberTextFiled.text])
    {
        [self showMessage:@"Account Number can not be empty!"];
        return;
    }
    
    LoginInfo *uportalLoginInfo = [[ManagerService loginService] obtainCurrentLoginInfo];
    NSString *shortSipNum = [ManagerService callService].terminal;
    if ([self.callNumberTextFiled.text isEqualToString:shortSipNum] || [self.callNumberTextFiled.text isEqualToString:uportalLoginInfo.account])
    {
        [self showMessage:@"Can not call yourself!"];
        return;
    }
    if (isCTD)
    {
        // if do not config callback number , call back to sip number.
        NSString *callBackNumber = [CommonUtils getUserDefaultValueWithKey:@"CallbackNumber"];
        if (callBackNumber.length == 0) {
            NSString *sipNumber = [ManagerService callService].terminal;
            callBackNumber = sipNumber;
        }
        
        BOOL result = [[ManagerService callService] startCTDCallWithCallbackNumber:callBackNumber calleeNumber:_callNumberTextFiled.text];
        if (!result)
        {
            [self showMessage:@"CTD call failed!"];
        }
        return;
    }
    else
    {
//        EAGLView *remoteView = [EAGLView getRemoteView];
//        EAGLView *locationView = [EAGLView getLocalView];
//        EAGLView *bfcpView = [EAGLView getTupBFCPView];
//        [[ManagerService callService] updateVideoWindowWithLocal:locationView
//                                                       andRemote:remoteView
//                                                         andBFCP:bfcpView
//                                                          callId:0];
        unsigned int callId = [[ManagerService callService] startCallWithNumber:self.callNumberTextFiled.text type:callType];
        if (callId != 0)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[CallWindowController shareInstance] showStartCallView:callId];
            });
        }
    }
}

- (void)goCallHistoryView
{
    CallHistoryViewController *ctrl = [[CallHistoryViewController alloc]init];
    ctrl.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:ctrl animated:YES];
}

-(void)configBtnAction
{
    UIAlertController *alertCtrl = [UIAlertController alertControllerWithTitle:@"Select Call Type" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"VoIP" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [CommonUtils userDefaultSaveValue:@(0) forKey:CALL_TYPE_CONFIG];
        [self updateCurrentCallType];
    }];
    [alertCtrl addAction:action];
    
    action = [UIAlertAction actionWithTitle:@"CTD" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [CommonUtils userDefaultSaveValue:@(1) forKey:CALL_TYPE_CONFIG];
        [self updateCurrentCallType];
    }];
    [alertCtrl addAction:action];
    
    [self presentViewController:alertCtrl animated:YES completion:nil];
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
