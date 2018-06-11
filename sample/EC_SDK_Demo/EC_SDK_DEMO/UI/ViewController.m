//
//  ViewController.m
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

#import "ViewController.h"
#import "AppDelegate.h"
#import "LoginViewController.h"
#import <TUPIOSSDK/TUPIOSSDK.h>
#import "ManagerService.h"
#import "UIViewController+CurrentViewController.h"
#import "DataConfBaseViewController.h"

@interface ViewController ()<LoginServiceDelegate>
@property (nonatomic,assign)BOOL isBeKickOut;

@end

@implementation ViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [ManagerService loginService].delegate = self;
    [TUPMAALoginService sharedInstance].authType = 4;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _isBeKickOut = NO;
    self.title = @"Main";
    [[TUPMAALoginService sharedInstance].loginService addObserver:self forKeyPath:@"serviceStatus" options:NSKeyValueObservingOptionNew context:NULL];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                       context:(void *)context {
    
    if ([keyPath isEqualToString:@"serviceStatus"]) {
        __weak typeof(self) weakSelf = self;
        ECSLoginServiceStatus sStatus = [[change objectForKey:NSKeyValueChangeNewKey] unsignedIntegerValue];
        dispatch_async(dispatch_get_main_queue(), ^{
            switch (sStatus) {
                case ECServiceOffline:
                case ECServiceKickOff:
                {
                    [[TUPMAALoginService sharedInstance] logout:^(NSError *error) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (error) {
                                [weakSelf showMessage:@"Logout failed!"];
                                return ;
                            }else {
                                [[ECSAppConfig sharedInstance] save];
                                [[LOCAL_DATA_MANAGER managedObjectContext] saveToPersistent];
                                [[ManagerService loginService] logout];
                            }
                        });
                    }];
                }
                    break;
                case ECServiceReconnecting:
                    break;
                case ECServiceSigning:
                    break;
                case ECServiceLogin:
                    break;
                case ECServiceInvalidAccountOrPassword:
                    break;
                    
                default:
                    break;
            }
        });
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)loginEventCallback:(TUP_LOGIN_EVENT_TYPE)loginEvent result:(NSDictionary *)resultDictionary
{
    switch (loginEvent)
    {
        case LOGINOUT_EVENT:
        {
            if (ECServiceLogin == [TUPMAALoginService sharedInstance].loginService.serviceStatus) {
                [[TUPMAALoginService sharedInstance] logout:^(NSError *error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (error) {
                            [self showMessage:@"Logout failed!"];
                        }else {
                            [[ECSAppConfig sharedInstance] save];
                            [[LOCAL_DATA_MANAGER managedObjectContext] saveToPersistent];
                            [self goToLoginViewController];
                        }
                    });
                }];
            }else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self goToLoginViewController];
                });
            }
            break;
        }
        default:
            break;
    }
}

- (void)goToLoginViewController {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    UINavigationController *loginNavigationViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"LoginNavigationController"];
    [UIApplication sharedApplication].delegate.window.rootViewController = loginNavigationViewController;
}

-(void)dealloc
{
    [ManagerService loginService].delegate = nil;
    [[TUPMAALoginService sharedInstance].loginService removeObserver:self forKeyPath:@"serviceStatus" context:NULL];
}

-(void)showMessage:(NSString *)msg
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:msg preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    UIViewController *currentCtrl = [UIViewController currentViewController];
    
    if ([currentCtrl isKindOfClass:[DataConfBaseViewController class]]) {
        return [currentCtrl supportedInterfaceOrientations];
    }
    return UIInterfaceOrientationMaskPortrait;

}

@end
