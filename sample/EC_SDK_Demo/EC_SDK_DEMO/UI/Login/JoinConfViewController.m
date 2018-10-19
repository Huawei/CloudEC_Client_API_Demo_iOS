//
//  JoinConfViewController.m
//  EC_SDK_DEMO
//
//  Created by huawei on 2018/8/7.
//  Copyright © 2018年 cWX160907. All rights reserved.
//

#import "JoinConfViewController.h"
#import "ConferenceService.h"
#import "ManagerService.h"
#import "tsdk_manager_interface.h"
#import "tsdk_manager_def.h"
#import "CommonUtils.h"
#import "LoginCenter.h"

@interface JoinConfViewController ()
@property (weak, nonatomic) IBOutlet UITextField *displayNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *confIDTextField;
@property (weak, nonatomic) IBOutlet UITextField *passWordTextField;
@property (weak, nonatomic) IBOutlet UIButton *joinConfBtn;
@property (weak, nonatomic) IBOutlet UITextField *serverAddTextField;
@property (weak, nonatomic) IBOutlet UITextField *serverPortTextField;
@property (strong, nonatomic) IBOutlet UIView *SubView;


@end

@implementation JoinConfViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getTempUserInfoFaild) name:LOGIN_GET_TEMP_USER_INFO_FAILD object:nil];
    
}

- (void)getTempUserInfoFaild
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"get user info faild" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:okAction];
    [self presentViewController:alert animated:NO completion:nil];
//    [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(creatAlert:) userInfo:alert repeats:NO];
}

//- (void)creatAlert:(NSTimer *)timer
//{
//    UIAlertController *alert = [timer userInfo];
//    [alert dismissViewControllerAnimated:YES completion:nil];
//    alert = nil;
//}

- (IBAction)joinConfAction:(id)sender {
    NSString *displayName = _displayNameTextField.text;
    NSString *confId = _confIDTextField.text;
    NSString *passWord = _passWordTextField.text;
    NSString *serverAdd = _serverAddTextField.text;
    NSString *serverport = _serverPortTextField.text;
    
    if (displayName.length == 0 || confId.length == 0 || passWord.length == 0 || serverAdd.length == 0 || serverport.length == 0)
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:@"Param is empty" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }
    
//    [[LoginCenter sharedInstance] configSipRelevantParam];
    
    [[ManagerService confService] joinConferenceWithDisPlayName:displayName ConfId:confId PassWord:passWord ServerAdd:serverAdd ServerPort:[serverport intValue]];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
