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
#import "HeadImageView.h"

#import <TUPIOSSDK/eSpaceDBService.h>
#import <TUPContactSDK/TupContactService.h>
#import <TUPIOSSDK/TUPUserSettingService.h>
#import <TUPIOSSDK/TUPIOSSDK.h>

#import <TUPIOSSDK/eSpaceDBService.h>
#import "PersonDetailViewController.h"

#define NEEDREGISTERMAALOGOUT 1 // 是否需要MAA注销
@interface MeViewController ()
@property(weak, nonatomic)IBOutlet UILabel *sipAccountLabel;
@property(weak, nonatomic)IBOutlet UILabel *callBackNumber;
@property (weak, nonatomic) IBOutlet UILabel *userStatusLabel;
@property (weak, nonatomic) IBOutlet HeadImageView *headImg;

@end

@implementation MeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _sipAccountLabel.text = [ManagerService callService].sipAccount;
    NSString *account = [[eSpaceDBService sharedInstance].localDataManager userAccount];
    EspaceUserOnlineStatus* status = [[TupContactService sharedInstance] onlineStatusForUser:account];
    [self reloadUserStatus:status.userStatus];
    [self updateCallBackNumber];
    [self.headImg setContactEntity:LOCAL_DATA_MANAGER.currentUser];
    // Do any additional setup after loading the view.
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.headImg.layer.cornerRadius = 50.0f;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateCallBackNumber
{
    NSString *callBackNumberText = [CommonUtils getUserDefaultValueWithKey:@"CallbackNumber"];
    if (callBackNumberText.length == 0) {
        NSString *sipNumber = [ManagerService callService].sipAccount;
        NSRange range = [sipNumber rangeOfString:@"@"];
        sipNumber = range.location == NSNotFound ? sipNumber : [sipNumber substringToIndex:range.location];
        _callBackNumber.text = sipNumber;
    }
    else {
        _callBackNumber.text = callBackNumberText;
    }
}

- (IBAction)logout:(id)sender
{
#if NEEDREGISTERMAALOGOUT
    [[TUPMAALoginService sharedInstance] logout:^(NSError *error) {
         dispatch_async(dispatch_get_main_queue(), ^{
             if (error) {
                 [self showMessage:@"MAA Logout failed!"];
             }
         });
     }];
    [[ECSAppConfig sharedInstance] save];
    [[LOCAL_DATA_MANAGER managedObjectContext] saveToPersistent];
#endif
    [[ManagerService loginService] logout];
}

- (IBAction)showSelfDetail:(id)sender {
    EmployeeEntity *selfEntity = LOCAL_DATA_MANAGER.currentUser;
    PersonDetailViewController *detailVC = [[PersonDetailViewController alloc] initWithPerson:selfEntity];
    detailVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:detailVC animated:YES];
}

- (IBAction)setUserStatus:(UITapGestureRecognizer *)sender {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Select The Status"
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *online = [UIAlertAction actionWithTitle:@"Online"
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction *action) {
                                                       [self setSelfUserStatus:ESpaceUserStatusAvailable];
                                                   }];
    UIAlertAction *busy = [UIAlertAction actionWithTitle:@"Busy"
                                                   style:UIAlertActionStyleDefault
                                                 handler:^(UIAlertAction *action) {
                                                     [self setSelfUserStatus:ESpaceUserStatusBusy];
                                                 }];
    UIAlertAction *away = [UIAlertAction actionWithTitle:@"Away"
                                                   style:UIAlertActionStyleDefault
                                                 handler:^(UIAlertAction *action) {
                                                     [self setSelfUserStatus:ESpaceUserStatusAway];
                                                 }];
    UIAlertAction *uninterrupt = [UIAlertAction actionWithTitle:@"UnInterruptable"
                                                          style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction *action) {
                                                            [self setSelfUserStatus:ESpaceUserStatusUninteruptable];
                                                        }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel"
                                                     style:UIAlertActionStyleCancel
                                                   handler:nil];
    [alertController addAction:online];
    [alertController addAction:busy];
    [alertController addAction:away];
    [alertController addAction:uninterrupt];
    [alertController addAction:cancel];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)setSelfUserStatus:(ESpaceUserStatus)status
{
    NSString *account = [[eSpaceDBService sharedInstance].localDataManager userAccount];
    [[TupContactService sharedInstance] onlineStatusForUser:account forceSubscribe:YES];
    [[TUPUserSettingService sharedInstance] setSelfStatus:status completion:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!error) {
                [self reloadUserStatus:status];
            }else {
                [self showMessage:@"Set user status failed."];
            }
        });
    }];
}

- (void)reloadUserStatus:(ESpaceUserStatus)status {
    NSString *stateStr;
    switch (status) {
        case ESpaceUserStatusAvailable:
            stateStr = @"Online";
            break;
        case ESpaceUserStatusBusy:
            stateStr = @"Busy";
            break;
        case ESpaceUserStatusAway:
            stateStr = @"Away";
            break;
        case ESpaceUserStatusUninteruptable:
            stateStr = @"UnInterruptable";
            break;
        default:
            stateStr = @"Offline";
            break;
    }
    self.userStatusLabel.text = stateStr;
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
