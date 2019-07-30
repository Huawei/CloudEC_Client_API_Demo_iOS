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
@property (weak, nonatomic) IBOutlet UISwitch *useAppSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *udpSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *tlsSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *tcpSwitch;
@property (weak, nonatomic) IBOutlet UITextField *udpPortField;
@property (weak, nonatomic) IBOutlet UITextField *tlsPortField;
@property (weak, nonatomic) IBOutlet UISwitch *srtpDisableSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *srtpOptionSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *srtpForceSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *portConfigSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *tunnelDefaultSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *tunnelDisableSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *useIDOConCtrl;
@property (strong, nonatomic) UISwitch *currentSwitch;

@property (nonatomic, assign)SRTP_MODE srtpMode;
@property (nonatomic, assign)TRANSPORT_MODE transportMode;
@property (nonatomic, assign)CONFIG_PRIORITY_TYPE priorityType;
@property (nonatomic, assign)TUNNEL_MODE tunnelMode;
@property (nonatomic, assign)BOOL sipPortPriority;

@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSArray *array = [CommonUtils getUserDefaultValueWithKey:SERVER_CONFIG];
    NSString *serverAddress = array[0];
    NSString *serverPort = array[1];
    if (serverAddress.length == 0 || serverPort.length == 0) {
        serverAddress = @"bmeeting.huaweicloud.com";
        serverPort = @"8443";
        [CommonUtils userDefaultSaveValue:@[@"bmeeting.huaweicloud.com", @"8443"] forKey:SERVER_CONFIG];
        
    }
    _serverAddressField.text = serverAddress;
    _serverPortField.text = serverPort;
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSString *useIDOConfCtrl = [CommonUtils getUserDefaultValueWithKey:USE_IDO_CONFCTRL];
    _useIDOConCtrl.on = [useIDOConfCtrl boolValue];
    
    NSArray *array = [CommonUtils getUserDefaultValueWithKey:SRTP_TRANSPORT_MODE];
    _srtpMode = [array[0] intValue];
    _transportMode = [array[1] intValue];
    
    NSString *priorityTypeString = array[2];
    _priorityType = [priorityTypeString intValue];
    if(_priorityType == CONFIG_PRIORITY_TYPE_APP){
        _udpSwitch.enabled = YES;
        _tlsSwitch.enabled = YES;
        _tcpSwitch.enabled = YES;
        _srtpDisableSwitch.enabled = YES;
        _srtpOptionSwitch.enabled = YES;
        _srtpForceSwitch.enabled = YES;
        _tunnelDisableSwitch.enabled = YES;
        _tunnelDefaultSwitch.enabled = YES;
        _priorityType = CONFIG_PRIORITY_TYPE_APP;
    }else{
        _udpSwitch.enabled = NO;
        _tlsSwitch.enabled = NO;
        _tcpSwitch.enabled = NO;
        _srtpDisableSwitch.enabled = NO;
        _srtpOptionSwitch.enabled = NO;
        _srtpForceSwitch.enabled = NO;
        _tunnelDisableSwitch.enabled = NO;
        _tunnelDefaultSwitch.enabled = NO;
        _priorityType = CONFIG_PRIORITY_TYPE_SYSTEM;
    }
    _udpPortField.text = array[3];
    _tlsPortField.text = array[4];
    _tunnelMode = [array[6] intValue];
    
    NSString *sipPortPriorityString = array[5];
    _sipPortPriority = [sipPortPriorityString boolValue];
    
    if (_sipPortPriority) {
        _udpPortField.enabled = YES;
        _tlsPortField.enabled = YES;
        _portConfigSwitch.on = YES;
        _sipPortPriority = YES;
    }else{
        _udpPortField.enabled = NO;
        _tlsPortField.enabled = NO;
        _portConfigSwitch.on = NO;
        _sipPortPriority = NO;
    }
    
    _srtpDisableSwitch.on = (_srtpMode == SRTP_MODE_DISABLE);
    _srtpForceSwitch.on = (_srtpMode == SRTP_MODE_FORCE);
    _srtpOptionSwitch.on = (_srtpMode == SRTP_MODE_OPTION);
    _udpSwitch.on = (_transportMode == TRANSPORT_MODE_UDP);
    _tlsSwitch.on = (_transportMode == TRANSPORT_MODE_TLS);
    _tcpSwitch.on = (_transportMode == TRANSPORT_MODE_TCP);
    _useAppSwitch.on = (_priorityType == CONFIG_PRIORITY_TYPE_APP);
    _tunnelDisableSwitch.on = (_tunnelMode == TUNNEL_MODE_DISABLE);
    _tunnelDefaultSwitch.on = (_tunnelMode == TUNNEL_MODE_DEFAULT);
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)saveBtnClicked:(id)sender
{
    [CommonUtils userDefaultSaveValue:@[_serverAddressField.text, _serverPortField.text] forKey:SERVER_CONFIG];
    NSString *srtp = [NSString stringWithFormat:@"%d",_srtpMode];
    NSString *transport = [NSString stringWithFormat:@"%d",_transportMode];
    NSString *config = [NSString stringWithFormat:@"%d",_priorityType];
    NSString *portPriority = [NSString stringWithFormat:@"%d",_sipPortPriority];
    NSString *tunnel = [NSString stringWithFormat:@"%d", _tunnelMode];
    NSString *udpPort = _udpPortField.text;
    if (udpPort.length == 0) {
        udpPort = @"5060";
    }
    NSString *tlsport = _tlsPortField.text;
    if (tlsport.length == 0) {
        tlsport = @"5061";
    }
    [CommonUtils userDefaultSaveValue:@[srtp, transport, config, udpPort, tlsport, portPriority, tunnel] forKey:SRTP_TRANSPORT_MODE];
    
    [CommonUtils userDefaultSaveValue:[NSString stringWithFormat:@"%d",_useIDOConCtrl.on] forKey:USE_IDO_CONFCTRL];
    
    [[LoginCenter sharedInstance] configSipRelevantParam];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)useAppConfig:(id)sender {
    UISwitch *swtich = sender;
    _currentSwitch = swtich;
    if(swtich.on){
        _udpSwitch.enabled = YES;
        _tlsSwitch.enabled = YES;
        _tcpSwitch.enabled = YES;
        _srtpDisableSwitch.enabled = YES;
        _srtpOptionSwitch.enabled = YES;
        _srtpForceSwitch.enabled = YES;
        _tunnelDisableSwitch.enabled = YES;
        _tunnelDefaultSwitch.enabled = YES;
        _priorityType = CONFIG_PRIORITY_TYPE_APP;
    }else{
        _udpSwitch.enabled = NO;
        _tlsSwitch.enabled = NO;
        _tcpSwitch.enabled = NO;
        _srtpDisableSwitch.enabled = NO;
        _srtpOptionSwitch.enabled = NO;
        _srtpForceSwitch.enabled = NO;
        _tunnelDisableSwitch.enabled = NO;
        _tunnelDefaultSwitch.enabled = NO;
        _priorityType = CONFIG_PRIORITY_TYPE_SYSTEM;
    }
}

- (IBAction)transportUDP:(id)sender {
    UISwitch *swtich = sender;
    _currentSwitch = swtich;
    if(swtich.on){
        _tcpSwitch.on = NO;
        _tlsSwitch.on = NO;
        _transportMode = TRANSPORT_MODE_UDP;
    }
}

- (IBAction)transportTLS:(id)sender {
    UISwitch *swtich = sender;
    _currentSwitch = swtich;
    if(swtich.on){
        _udpSwitch.on = NO;
        _tcpSwitch.on = NO;
        _transportMode = TRANSPORT_MODE_TLS;
    }
}

- (IBAction)transportTCP:(id)sender {
    UISwitch *swtich = sender;
    _currentSwitch = swtich;
    if(swtich.on){
        _udpSwitch.on = NO;
        _tlsSwitch.on = NO;
        _transportMode = TRANSPORT_MODE_TCP;
    }
}

- (IBAction)srtpDisable:(id)sender {
    UISwitch *swtich = sender;
    _currentSwitch = swtich;
    if(swtich.on){
        _srtpForceSwitch.on = NO;
        _srtpOptionSwitch.on = NO;
        _srtpMode = SRTP_MODE_DISABLE;
    }
}

- (IBAction)srtpOption:(id)sender {
    UISwitch *swtich = sender;
    _currentSwitch = swtich;
    if(swtich.on){
        _srtpDisableSwitch.on = NO;
        _srtpForceSwitch.on = NO;
        _srtpMode = SRTP_MODE_OPTION;
    }
}

- (IBAction)srtpForce:(id)sender {
    UISwitch *swtich = sender;
    _currentSwitch = swtich;
    if(swtich.on){
        _srtpDisableSwitch.on = NO;
        _srtpOptionSwitch.on = NO;
        _srtpMode = SRTP_MODE_FORCE;
    }
}

- (IBAction)sipPortPriority:(id)sender {
    UISwitch *swtich = sender;
    _currentSwitch = swtich;

    if(swtich.on){
        _sipPortPriority = YES;
        _udpPortField.enabled = YES;
        _tlsPortField.enabled = YES;
    }else{
        _sipPortPriority = NO;
        _udpPortField.enabled = NO;
        _tlsPortField.enabled = NO;
    }
}

- (IBAction)tunnelDefault:(id)sender {
    UISwitch *swtich = sender;
    _currentSwitch = swtich;
    if(swtich.on){
        _tunnelDisableSwitch.on = NO;
        _tunnelMode = TUNNEL_MODE_DEFAULT;
    }
}

- (IBAction)tunnelDisable:(id)sender {
    UISwitch *swtich = sender;
    _currentSwitch = swtich;
    if(swtich.on){
        _tunnelDefaultSwitch.on = NO;
        _tunnelMode = TUNNEL_MODE_DISABLE;
    }
}

- (IBAction)ipCallSkipLogin:(id)sender {
    [[ManagerService callService] ipCallConfig];
}

- (IBAction)useIDOConfCtrlAction:(id)sender {

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
