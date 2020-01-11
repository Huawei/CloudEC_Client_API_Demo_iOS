//
//  ConfigIPTViewController.m
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

#import "ConfigIPTViewController.h"
#import "ManagerService.h"
#import "CommonUtils.h"
#import "LoginInfo.h"
#import "IPTConfig.h"


@interface ConfigIPTViewController ()<UIGestureRecognizerDelegate, IptConfigDelegate>
//DND
@property (weak, nonatomic) IBOutlet UITextField *dndActiveCodeTextField;
@property (weak, nonatomic) IBOutlet UITextField *dndDeactiveCodeTextField;
@property (weak, nonatomic) IBOutlet UISwitch *dndSwitch;

//CFU
@property (weak, nonatomic) IBOutlet UITextField *cfuNumberTextField;
@property (weak, nonatomic) IBOutlet UITextField *cfuActiveCodeTextField;
@property (weak, nonatomic) IBOutlet UITextField *cfuDeactiveCodeTextField;
@property (weak, nonatomic) IBOutlet UISwitch *cfuSwitch;
//CFB
@property (weak, nonatomic) IBOutlet UITextField *cfbNumberTextField;
@property (weak, nonatomic) IBOutlet UITextField *cfbActiveCodeTextField;
@property (weak, nonatomic) IBOutlet UITextField *cfbDeactiveCodeTextField;
@property (weak, nonatomic) IBOutlet UISwitch *cfbSwitch;
//CFNA
@property (weak, nonatomic) IBOutlet UITextField *cfnaNumberTextField;
@property (weak, nonatomic) IBOutlet UITextField *cfnaActiveCodeTextField;
@property (weak, nonatomic) IBOutlet UITextField *cfnaDeactiveCodeTextField;
@property (weak, nonatomic) IBOutlet UISwitch *cfnaSwitch;
//CFNR
@property (weak, nonatomic) IBOutlet UITextField *cfnrNumberTextField;
@property (weak, nonatomic) IBOutlet UITextField *cfnrActiveCodeTextField;
@property (weak, nonatomic) IBOutlet UITextField *cfnrDeactiveCodeTextField;
@property (weak, nonatomic) IBOutlet UISwitch *cfnrSwitch;
//Call wait
@property (weak, nonatomic) IBOutlet UITextField *callWaitNumberTextField;
@property (weak, nonatomic) IBOutlet UITextField *callWaitActiveCodeTextField;
@property (weak, nonatomic) IBOutlet UITextField *callWaitDeactiveCodeTextField;
@property (weak, nonatomic) IBOutlet UISwitch *callWaitSwitch;
@property (strong, nonatomic) UISwitch *currentSwitch;
@property (strong, nonatomic) UIView *waitView;
@end

@implementation ConfigIPTViewController



- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)])
    {
        self.navigationController.interactivePopGestureRecognizer.delegate = nil;
    }
}


- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    return NO;
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)])
    {
        self.navigationController.interactivePopGestureRecognizer.delegate = self;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"IPT Service";
    _currentSwitch = [[UISwitch alloc] init];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [ManagerService callService].iptDelegate = self;
    IPTConfig *iptConfig = [self getCurrentAccountIptStatus];
    
    _dndSwitch.enabled = iptConfig.hasDNDRight;
    _dndSwitch.on = iptConfig.isDNDRegister;
    _callWaitSwitch.enabled = iptConfig.hasCWRight;
    _callWaitSwitch.on = iptConfig.isCWRegister;
    
    _cfuSwitch.enabled = iptConfig.hasCFURight;
    _cfuSwitch.on = iptConfig.isCFURegister;
    _cfuNumberTextField.enabled = !iptConfig.isCFURegister;
    _cfuNumberTextField.text = iptConfig.cfuNumber;
    
    _cfbSwitch.enabled = iptConfig.hasCFBRight;
    _cfbSwitch.on = iptConfig.isCFBRegister;
    _cfbNumberTextField.enabled = !iptConfig.isCFBRegister;
    _cfbNumberTextField.text = iptConfig.cfbNumber;
    
    _cfnaSwitch.enabled = iptConfig.hasCFNARight;
    _cfnaSwitch.on = iptConfig.isCFNARegister;
    _cfnaNumberTextField.enabled = !iptConfig.isCFNARegister;
    _cfnaNumberTextField.text = iptConfig.cfnaNumber;
    
    _cfnrSwitch.enabled = iptConfig.hasCFNRRight;
    _cfnrSwitch.on = iptConfig.isCFNRRegister;
    _cfnrNumberTextField.enabled = !iptConfig.isCFNRRegister;
    _cfnrNumberTextField.text = iptConfig.cfnrNumber;
}


- (IBAction)dndSwitchAction:(id)sender
{
    UISwitch *swtich = sender;
    _currentSwitch = swtich;
    
    BOOL result ;
    if (swtich.on)
    {
        result = [[ManagerService callService] setIPTService:CALL_SERVICE_TYPE_DND andCapable:true andNumber:@""];
    }
    else
    {
        result = [[ManagerService callService] setIPTService:CALL_SERVICE_TYPE_DND andCapable:false andNumber:@""];
    }
    if (!result)
    {
        [self showMessage:@"fail"];
        return;
    }
    [self showWaitView];
}

- (IBAction)cfuSwitchAction:(id)sender
{
    UISwitch *swtich = sender;
    _currentSwitch = swtich;
    BOOL isNumberNotEmpty = [self checkNumberIsNotEmpty:_cfuNumberTextField.text];
    if (isNumberNotEmpty)
    {
        BOOL result ;
        if (swtich.on)
        {
            result = [[ManagerService callService] setIPTService:CALL_SERVICE_TYPE_CFU andCapable:true andNumber:_cfuNumberTextField.text];
        }
        else
        {
            result = [[ManagerService callService] setIPTService:CALL_SERVICE_TYPE_CFU andCapable:false andNumber:_cfuNumberTextField.text ];
        }
        if (!result)
        {
            [self showMessage:@"fail"];
            return;
        }
        [self showWaitView];
        return;
    }
    swtich.on = NO;
}
- (IBAction)cfbSwitchAction:(id)sender
{
    UISwitch *swtich = sender;
    _currentSwitch = swtich;
    BOOL isNumberNotEmpty = [self checkNumberIsNotEmpty:_cfbNumberTextField.text];
    if (isNumberNotEmpty)
    {
        BOOL result ;
        if (swtich.on)
        {
            result = [[ManagerService callService] setIPTService:CALL_SERVICE_TYPE_CFB andCapable:true andNumber:_cfbNumberTextField.text ];
        }
        else
        {
            result = [[ManagerService callService] setIPTService:CALL_SERVICE_TYPE_CFB andCapable:false andNumber:_cfbNumberTextField.text ];
        }
        if (!result)
        {
            [self showMessage:@"fail"];
            return;
        }
        [self showWaitView];
        return;
    }
    swtich.on = NO;
}
- (IBAction)cfnaSwitchAction:(id)sender
{
    UISwitch *swtich = sender;
    _currentSwitch = swtich;
    BOOL isNumberNotEmpty = [self checkNumberIsNotEmpty:_cfnaNumberTextField.text];
    if (isNumberNotEmpty)
    {
        BOOL result ;
        if (swtich.on)
        {
            result = [[ManagerService callService] setIPTService:CALL_SERVICE_TYPE_CFN andCapable:true andNumber:_cfnaNumberTextField.text];
        }
        else
        {
            result = [[ManagerService callService] setIPTService:CALL_SERVICE_TYPE_CFN andCapable:false andNumber:_cfnaNumberTextField.text];
        }
        if (!result)
        {
            [self showMessage:@"fail"];
            return;
        }
        [self showWaitView];
        return;
    }
    swtich.on = NO;
}


- (IBAction)cfnrSwitchAction:(id)sender
{
    UISwitch *swtich = sender;
    _currentSwitch = swtich;
    BOOL isNumberNotEmpty = [self checkNumberIsNotEmpty:_cfnrNumberTextField.text];
    if (isNumberNotEmpty)
    {
        BOOL result ;
        if (swtich.on)
        {
            result = [[ManagerService callService] setIPTService:CALL_SERVICE_TYPE_CFO andCapable:true andNumber:_cfnrNumberTextField.text ];
        }
        else
        {
            result = [[ManagerService callService] setIPTService:CALL_SERVICE_TYPE_CFO andCapable:false andNumber:_cfnrNumberTextField.text ];
        }
        if (!result)
        {
            [self showMessage:@"Config failed!"];
            return;
        }
        [self showWaitView];
        return;
    }
    swtich.on = NO;
    
}


- (IBAction)callWaitSwitchAction:(id)sender
{
    UISwitch *swtich = sender;
    _currentSwitch = swtich;
    
    BOOL result ;
    if (swtich.on)
    {
        result = [[ManagerService callService] setIPTService:CALL_SERVICE_TYPE_CALL_WAIT andCapable:true andNumber:@""];
    }
    else
    {
        result = [[ManagerService callService] setIPTService:CALL_SERVICE_TYPE_CALL_WAIT andCapable:false andNumber:@""];
    }
    if (!result)
    {
        [self showMessage:@"Config failed!"];
        return;
    }
    [self showWaitView];
}

#pragma mark - Call Event call back
-(void)callEventCallback:(TUP_CALL_EVENT_TYPE)callEvent result:(NSDictionary *)resultDictionary
{
    switch (callEvent)
    {
        case CALL_SET_IPT_RESULT:
        {
            // TODO: CHENZHIQIAN
            //            dispatch_async(dispatch_get_main_queue(), ^{
            //                [self hideWaitView];
            //                BOOL result = [resultDictionary[TUP_CALL_SET_IPT_RESULT_KEY] boolValue];
            //                CALL_E_SERVICE_CALL_TYPE serviceCallType = (CALL_E_SERVICE_CALL_TYPE)[resultDictionary[TUP_CALL_IPT_ENUN_KEY] intValue];
            //                if (result)
            //                {
            //                    [self handleConfigIPTSuccess:serviceCallType];
            //                    return ;
            //                }
            //                _currentSwitch.on = !_currentSwitch.on;
            //                [self showMessage:[NSString stringWithFormat:@"Config IPT fail (IPT type: %d)",serviceCallType]];
            //            });
            //            break;
        }
        default:
            break;
    }
}

- (void)iptConfigCallBack:(IPTConfigType)type result:(BOOL)isSuccess;
{
    __weak typeof(self) weakSelf = self;
    switch (type) {
        case IPT_REG_DND:
        {
            if(!isSuccess){
                dispatch_async(dispatch_get_main_queue(), ^{
                    _dndSwitch.on = NO;
                    [weakSelf hideWaitView];
                    [weakSelf showMessage:@"Failed!"];
                });
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf hideWaitView];
                    [weakSelf showMessage:@"Success!"];
                });
            }
        }
            break;
        case IPT_UNREG_DND:
        {
            if(!isSuccess){
                dispatch_async(dispatch_get_main_queue(), ^{
                    _dndSwitch.on = YES;
                    [weakSelf hideWaitView];
                    [weakSelf showMessage:@"Failed!"];
                });
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf hideWaitView];
                    [weakSelf showMessage:@"Success!"];
                });
            }
        }
            break;
        case IPT_FORWARD_UNCONDITION_Active:
        {
            if(isSuccess){
                dispatch_async(dispatch_get_main_queue(), ^{
                    _cfuNumberTextField.enabled = NO;
                    [weakSelf hideWaitView];
                    [weakSelf showMessage:@"Success!"];
                });
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    _cfuSwitch.on = NO;
                    [weakSelf hideWaitView];
                    [weakSelf showMessage:@"Failed!"];
                });
            }
        }
            break;
        case IPT_FORWARD_UNCONDITION_Deactive:
        {
            if(isSuccess){
                dispatch_async(dispatch_get_main_queue(), ^{
                    weakSelf.cfuNumberTextField.enabled = YES;
                    [weakSelf hideWaitView];
                    [weakSelf showMessage:@"Success!"];
                });
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    weakSelf.cfuSwitch.on = YES;
                    [weakSelf hideWaitView];
                    [weakSelf showMessage:@"Failed!"];
                });
            }
        }
            break;
        case IPT_FORWARD_ONBUSY_Active:
        {
            if(isSuccess){
                dispatch_async(dispatch_get_main_queue(), ^{
                    _cfbNumberTextField.enabled = NO;
                    [weakSelf hideWaitView];
                    [weakSelf showMessage:@"Success!"];
                });
            }else{
                dispatch_sync(dispatch_get_main_queue(), ^{
                    weakSelf.cfbSwitch.on = NO;
                    [weakSelf hideWaitView];
                    [weakSelf showMessage:@"Failed!"];
                });
            }
        }
            break;
        case IPT_FORWARD_ONBUSY_Deactive:
        {
            if(isSuccess){
                dispatch_async(dispatch_get_main_queue(), ^{
                    weakSelf.cfbNumberTextField.enabled = YES;
                    [weakSelf hideWaitView];
                    [weakSelf showMessage:@"Success!"];
                });
            }else{
                dispatch_sync(dispatch_get_main_queue(), ^{
                    weakSelf.cfbSwitch.on = YES;
                    [weakSelf hideWaitView];
                    [weakSelf showMessage:@"Failed!"];
                });
            }
        }
            break;
        case IPT_FORWARD_OFFLINE_Active:
        {
            if(isSuccess){
                dispatch_async(dispatch_get_main_queue(), ^{
                    weakSelf.cfnrNumberTextField.enabled = NO;
                    [weakSelf hideWaitView];
                    [weakSelf showMessage:@"Success!"];
                });
            }else{
                dispatch_sync(dispatch_get_main_queue(), ^{
                    weakSelf.cfnrSwitch.on = NO;
                    [weakSelf hideWaitView];
                    [weakSelf showMessage:@"Failed!"];
                });
            }
        }
            break;
        case IPT_FORWARD_OFFLINE_Deactive:
        {
            if(isSuccess){
                dispatch_async(dispatch_get_main_queue(), ^{
                    weakSelf.cfnrNumberTextField.enabled = YES;
                    [weakSelf hideWaitView];
                    [weakSelf showMessage:@"Success!"];
                });
            }else{
                dispatch_sync(dispatch_get_main_queue(), ^{
                    weakSelf.cfnrSwitch.on = YES;
                    [weakSelf hideWaitView];
                    [weakSelf showMessage:@"Failed!"];
                });
            }
        }
            break;
        case IPT_FORWARD_NOREPLY_Active:
        {
            if(isSuccess){
                dispatch_async(dispatch_get_main_queue(), ^{
                    weakSelf.cfnaNumberTextField.enabled = NO;
                    [weakSelf hideWaitView];
                    [weakSelf showMessage:@"Success!"];
                });
            }else{
                dispatch_sync(dispatch_get_main_queue(), ^{
                    weakSelf.cfnaSwitch.on = NO;
                    [weakSelf hideWaitView];
                    [weakSelf showMessage:@"Failed!"];
                });
            }
        }
            break;
        case IPT_FORWARD_NOREPLY_Deactive:
        {
            if(isSuccess){
                dispatch_async(dispatch_get_main_queue(), ^{
                    weakSelf.cfnaNumberTextField.enabled = YES;
                    [weakSelf hideWaitView];
                    [weakSelf showMessage:@"Success!"];
                });
            }else{
                dispatch_sync(dispatch_get_main_queue(), ^{
                    weakSelf.cfnaSwitch.on = YES;
                    [weakSelf hideWaitView];
                    [weakSelf showMessage:@"Failed!"];
                });
            }
        }
            break;
        case IPT_CALL_WAIT_ACTIVE:
        {
            if(!isSuccess){
                dispatch_async(dispatch_get_main_queue(), ^{
                    weakSelf.callWaitSwitch.on = NO;
                    [weakSelf hideWaitView];
                    [weakSelf showMessage:@"Failed!"];
                });
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf hideWaitView];
                    [weakSelf showMessage:@"Success!"];
                });
            }
        }
            break;
        case IPT_CALL_WAIT_DEACTIVE:
        {
            if(!isSuccess){
                dispatch_async(dispatch_get_main_queue(), ^{
                    weakSelf.callWaitSwitch.on = YES;
                    [weakSelf hideWaitView];
                    [weakSelf showMessage:@"Failed!"];
                });
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf hideWaitView];
                    [weakSelf showMessage:@"Success!"];
                });
            }
        }
            break;
        default:
            break;
    }
}


-(IPTConfig *)getCurrentAccountIptStatus
{
    NSString *accountId = [CommonUtils getUserDefaultValueWithKey:@"USER_ACCOUNT"];
    IPTConfig *iptConfig;
    if (![[CommonUtils getUserDefaultValueWithKey:@"iptConfig"] isKindOfClass:[NSArray class]])
    {
        return nil;
    }
    NSArray *orginalArray = [CommonUtils getUserDefaultValueWithKey:@"iptConfig"];
    for (NSDictionary *tempDic in orginalArray)
    {
        NSString *account = tempDic[@"ACCOUNT"];
        DDLogInfo(@"account num is :%@",account);
        if ([account isEqualToString:accountId])
        {
            iptConfig = [NSKeyedUnarchiver unarchiveObjectWithData:tempDic[@"IPT"]];
        }
    }
    if (!iptConfig)
    {
        return nil;
    }
    return iptConfig;
}



//YES: not empty NO: empty
-(BOOL)checkActiveAndDeactiveCodeIsNotEmpty:(NSString *)activeCode deactiveCode:(NSString *)deactiveCode
{
    [self.view endEditing:YES];
    BOOL isNotEmpty = YES;
    if (activeCode.length == 0 || deactiveCode.length == 0)
    {
        [self showMessage:@"Please enter active access code or deactive access code!"];
        isNotEmpty = NO;
    }
    return isNotEmpty;
}

//YES: not empty NO: empty
-(BOOL)checkNumberIsNotEmpty:(NSString *)numberText
{
    BOOL isNotEmpty = YES;
    if (numberText.length == 0)
    {
        [self showMessage:@"Please enter the number!"];
        isNotEmpty = NO;
    }
    return isNotEmpty;
}

-(void)showMessage:(NSString *)msg
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:msg preferredStyle:UIAlertControllerStyleAlert];
    [self presentViewController:alert animated:NO completion:nil];
    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(creatAlert:) userInfo:alert repeats:NO];
}

- (void)creatAlert:(NSTimer *)timer
{
    UIAlertController *alert = [timer userInfo];
    [alert dismissViewControllerAnimated:YES completion:nil];
    alert = nil;
}

-(void)showWaitView
{
    self.navigationController.navigationBarHidden = YES;
    [_waitView removeFromSuperview];
    _waitView = [[UIView alloc] initWithFrame:self.view.bounds];
    _waitView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] init];
    activityView.center = CGPointMake([UIScreen mainScreen].bounds.size.width/2, [UIScreen mainScreen].bounds.size.height/2);
    [activityView startAnimating];
    [_waitView addSubview:activityView];
    [self.view addSubview:_waitView];
}

-(void)hideWaitView
{
    self.navigationController.navigationBarHidden = NO;
    [_waitView removeFromSuperview];
    _waitView = nil;
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

-(void)dealloc
{
    _currentSwitch = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
