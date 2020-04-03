//
//  MeViewController.m
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

#import "MeViewController.h"
#import "ManagerService.h"
#import "CommonUtils.h"


#import "NoDisturbViewController.h"
#import "LoginCenter.h"



@interface MeViewController ()
@property(weak, nonatomic)IBOutlet UILabel *sipAccountLabel;
@property(weak, nonatomic)IBOutlet UILabel *callBackNumber;


@end

@implementation MeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *accountId = [CommonUtils getUserDefaultValueWithKey:@"USER_ACCOUNT"];
    _sipAccountLabel.text = accountId;

    [self updateCallBackNumber];

    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
    if (_callBackNumber.text.length == 0) {
        [self updateCallBackNumber];
    }
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateCallBackNumber
{
    NSString *callBackNumberText = [CommonUtils getUserDefaultValueWithKey:@"CallbackNumber"];
    if (callBackNumberText.length == 0) {
        NSString *sipNumber = [ManagerService callService].terminal;
        _callBackNumber.text = sipNumber;
    }
    else {
        _callBackNumber.text = callBackNumberText;
    }
}

- (IBAction)logout:(id)sender
{
    [[ManagerService loginService] logout];
    [self goToLoginViewController];
    [CommonUtils userDefaultSaveBoolValue:NO forKey:NEED_AUTO_LOGIN];
}

- (void)goToLoginViewController {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    UINavigationController *loginNavigationViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"LoginNavigationController"];
    [UIApplication sharedApplication].delegate.window.rootViewController = loginNavigationViewController;
}

- (IBAction)modifyCallBackNumber:(id)sender
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Modify" message:@"Please input new callback number." preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        [textField setFont:[UIFont systemFontOfSize:15]];
        textField.text = @"";
    }];
    
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UITextField * input = alert.textFields[0];
        [CommonUtils userDefaultSaveValue:input.text forKey:@"CallbackNumber"];
        [self updateCallBackNumber];
    }];
    [alert addAction:action];
    
    action = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:action];
    
    [self presentViewController:alert animated:YES completion:nil];
}

// 消息免打扰接口SDK中未暴露出来，暂时修改成跳转到系统设置界面设置关闭通知来实现
- (IBAction)SystemSettingAction:(id)sender {
    NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url];
    }
}
- (IBAction)pushConfig:(id)sender {
    
    NSArray *pushTime = [CommonUtils getUserDefaultValueWithKey:PushTimeEnableRecoud];
    BOOL timeEnable = NO;
    NSString *noPushStart = nil;
    NSString *noPushEnd = nil;
    if (pushTime != nil) {
        timeEnable = [pushTime[0] boolValue];
        noPushStart = pushTime[1];
        noPushEnd = pushTime[2];
    }

    NoDisturbViewController *noDisturbView = [[NoDisturbViewController alloc] initWithPushConfig:YES noPushStart:noPushStart noPushEnd:noPushEnd timeEnable:timeEnable];
    [self.navigationController pushViewController:noDisturbView animated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark
#pragma mark --- AlertShow ---
-(void)showMessage:(NSString *)msg {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                   message:msg
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [self presentViewController:alert animated:NO completion:nil];
    [NSTimer scheduledTimerWithTimeInterval:0.5
                                     target:self
                                   selector:@selector(creatAlert:)
                                   userInfo:alert
                                    repeats:NO];
}

- (void)creatAlert:(NSTimer *)timer {
    UIAlertController *alert = [timer userInfo];
    [alert dismissViewControllerAnimated:YES completion:nil];
    alert = nil;
}

@end
