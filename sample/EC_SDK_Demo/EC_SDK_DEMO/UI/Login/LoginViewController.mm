//
//  LoginViewController.m
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

#import "LoginViewController.h"
#import "ViewController.h"
#import "CommonUtils.h"
#import "NetworkUtils.h"
#import "AppDelegate.h"
#import "ManagerService.h"
#import "LoginInfo.h"
#import "SettingViewController.h"

NSString *const IPTBUSINESS_KEY = @"IPTBUSINESS";

@interface LoginViewController ()
{
    BOOL _hasTimeOut;
}
@property (weak, nonatomic) IBOutlet UITextField *accountTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loginingActivityIndicator;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;

@end

@implementation LoginViewController


- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [NetworkUtils shareInstance];
    _hasTimeOut = NO;
    _loginingActivityIndicator.hidden = YES;
    _loginButton.hidden = NO;
    _accountTextField.text = [CommonUtils getUserDefaultValueWithKey:USER_ACCOUNT];
    _passwordTextField.text = [CommonUtils getUserDefaultValueWithKey:USER_PASSWORD];
    
    _versionLabel.text = [NSString stringWithFormat:@"Version: %@", [NSBundle mainBundle].infoDictionary[@"CFBundleVersion"]];
    [self.navigationController.navigationBar setHidden:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginSipUnregistered) name:LOGIN_UNREGISTERED_RESULT object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginAuthFailed) name:LOGIN_AUTH_FAILED object:nil];
}

- (void)loginSipUnregistered
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self showMessage:@"lgoin faild! sip unregistered!"];
        [self hiddenActivityIndicator:YES];
    });
    
}

- (void)loginAuthFailed
{
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf showMessage:@"lgoin faild! auth failed!"];
        [weakSelf hiddenActivityIndicator:YES];
    });
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController.navigationBar setHidden:NO];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (IBAction)loginAction:(id)sender
{
    [self.view endEditing:YES];
    _hasTimeOut = NO;
    NSArray *serverConfig = [CommonUtils getUserDefaultValueWithKey:SERVER_CONFIG];
    NSString *serverAddress = serverConfig[0];
    NSString *serverPort = serverConfig[1];
    if ([[NetworkUtils shareInstance] getCurrentNetworkStatus] == ECSNotReachable)
    {
        [self showMessage:@"Current network is unavailable"];
        return;
    }
    NSArray *array = @[self.accountTextField.text,self.passwordTextField.text];
    for (NSString *tempString in array)
    {
        if (![CommonUtils checkIsNotEmptyString:tempString])
        {
            [self showMessage:@"Parameter can't be empty!"];
            return;
        }
    }
    
    if (serverAddress.length == 0 || serverPort.length == 0) {
//        [self showMessage:@"server config can't be empty!"];
//        return;
        serverAddress = @"bmeeting.huaweicloud.com";
        serverPort = @"443";
        [CommonUtils userDefaultSaveValue:@[@"bmeeting.huaweicloud.com", @"443"] forKey:SERVER_CONFIG];
        
    }

    [self hiddenActivityIndicator:NO];
    LoginInfo *user = [[LoginInfo alloc] init];
    user.regServerAddress = serverAddress;
    user.regServerPort = serverPort;
    user.account = self.accountTextField.text;
    user.password = self.passwordTextField.text;
    [CommonUtils userDefaultSaveValue:self.accountTextField.text forKey:USER_ACCOUNT];
    [CommonUtils userDefaultSaveValue:self.passwordTextField.text forKey:USER_PASSWORD];
    __weak typeof(self) weakSelf = self;
    [[ManagerService loginService] authorizeLoginWithLoginInfo:user completionBlock:^(BOOL isSuccess, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf hiddenActivityIndicator:YES];
            if (!isSuccess) {
                [weakSelf showMessage:[NSString stringWithFormat:@"Login Fail!code:%ld",(long)error.code]];
                return ;
            }else{
                UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
                ViewController *baseViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"ViewController"];
                [UIApplication sharedApplication].delegate.window.rootViewController = baseViewController;
            }
        });
    }];
}


-(void)hiddenActivityIndicator:(BOOL)isHidden
{
    if (isHidden)
    {
        self.loginingActivityIndicator.hidden = YES;
        [self.loginingActivityIndicator stopAnimating];
        self.loginButton.hidden = NO;
    }
    else
    {
        self.loginingActivityIndicator.hidden = NO;
        [self.loginingActivityIndicator startAnimating];
        self.loginButton.hidden = YES;
    }
}

-(void)showMessage:(NSString *)msg
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:msg preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

-(void)dealloc
{
    [LoginViewController cancelPreviousPerformRequestsWithTarget:self selector:@selector(loginTimeOut) object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}




@end
