//
//  SettingViewController.m
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

#import "SettingViewController.h"
#import "CommonUtils.h"
#import "ManagerService.h"
#import "LoginCenter.h"

@interface SettingViewController ()
@property (nonatomic, weak)IBOutlet UITextField *serverAddressField;
@property (nonatomic, weak)IBOutlet UITextField *serverPortField;

@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSArray *array = [CommonUtils getUserDefaultValueWithKey:SERVER_CONFIG];
    NSString *serverAddress = array[0];
    NSString *serverPort = array[1];
    if (serverAddress.length == 0 || serverPort.length == 0) {
        serverAddress = @"bmeeting.huaweicloud.com";
        serverPort = @"443";
        [CommonUtils userDefaultSaveValue:@[@"bmeeting.huaweicloud.com", @"443"] forKey:SERVER_CONFIG];
        
    }
    _serverAddressField.text = serverAddress;
    _serverPortField.text = serverPort;
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)saveBtnClicked:(id)sender
{
    [CommonUtils userDefaultSaveValue:@[_serverAddressField.text, _serverPortField.text] forKey:SERVER_CONFIG];
    
    [[LoginCenter sharedInstance] configSipRelevantParam];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)ipCallSkipLogin:(id)sender {
    [[ManagerService callService] ipCallConfig];
}


@end
