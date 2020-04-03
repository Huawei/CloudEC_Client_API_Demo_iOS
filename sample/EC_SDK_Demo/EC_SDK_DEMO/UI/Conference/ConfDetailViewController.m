//
//  ConfDetailViewController.m
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

#import "ConfDetailViewController.h"
#import "ManagerService.h"
#import "LoginInfo.h"
#import "CommonUtils.h"
#import "ConfRunningViewController.h"
#import "AppDelegate.h"
#import "ConfBaseInfo.h"

@interface ConfDetailViewController ()<ConferenceServiceDelegate>
@property (weak, nonatomic) IBOutlet UILabel *idLabel;
@property (weak, nonatomic) IBOutlet UILabel *subjectLabel;
@property (weak, nonatomic) IBOutlet UILabel *accessNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *startTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *endTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *mediaType;
@property (weak, nonatomic) IBOutlet UILabel *chairmanPwdLabel;
@property (weak, nonatomic) IBOutlet UILabel *generalPwdLabel;
@property (weak, nonatomic) IBOutlet UILabel *scheduserNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *scheduserNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *confStatusLabel;
@property (weak, nonatomic) IBOutlet UILabel *joinNumberLabel;
@property (weak, nonatomic) IBOutlet UITextField *joinNumberTextField;

@end

@implementation ConfDetailViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [ManagerService confService].delegate = self;
    BOOL result = [[ManagerService confService] obtainConferenceDetailInfoWithConfId:_confId Page:1 pageSize:10];
    if (!result)
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    NSString *shortSipNum = [ManagerService callService].terminal;
    self.joinNumberTextField.text = shortSipNum;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

-(void)ecConferenceEventCallback:(EC_CONF_E_TYPE)ecConfEvent result:(NSDictionary *)resultDictionary
{
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (ecConfEvent == CONF_E_CURRENTCONF_DETAIL)
        {
            BOOL result = [resultDictionary[ECCONF_RESULT_KEY] boolValue];
            if (!result)
            {
                [weakSelf dismissViewControllerAnimated:YES completion:nil];
                return;
            }
            
            ConfBaseInfo *baseInfo = [ManagerService confService].currentConfBaseInfo;
            weakSelf.idLabel.text = baseInfo.conf_id;
            weakSelf.subjectLabel.text = baseInfo.conf_subject;
            weakSelf.accessNumberLabel.text = baseInfo.access_number;
            weakSelf.startTimeLabel.text = baseInfo.start_time;
            weakSelf.endTimeLabel.text = baseInfo.end_time;
            weakSelf.chairmanPwdLabel.text = baseInfo.chairman_pwd;
            weakSelf.generalPwdLabel.text = baseInfo.general_pwd;
            weakSelf.scheduserNameLabel.text = baseInfo.scheduser_name;
            weakSelf.scheduserNumberLabel.text = baseInfo.scheduser_number;
            
            switch (baseInfo.media_type)
            {
                case CONF_MEDIATYPE_VOICE:
                    weakSelf.mediaType.text = @"Voice conference";
                    break;
                case CONF_MEDIATYPE_VIDEO:
                    weakSelf.mediaType.text = @"Video conference";
                    break;
                case CONF_MEDIATYPE_DATA:
                    weakSelf.mediaType.text = @"Data conference";
                    break;
                case CONF_MEDIATYPE_VIDEO_DATA:
                    weakSelf.mediaType.text = @"Data + Video conference";
                    break;
                default:
                    break;
            }
            switch (baseInfo.conf_state)
            {
                case CONF_E_STATE_SCHEDULE:
                    weakSelf.confStatusLabel.text = @"SCHEDULE";
                    break;
                case CONF_E_STATE_CREATING:
                    weakSelf.confStatusLabel.text = @"CREATING";
                    break;
                case CONF_E_STATE_GOING:
                    weakSelf.confStatusLabel.text = @"ON GOING";
                    break;
                case CONF_E_STATE_DESTROYED:
                    weakSelf.confStatusLabel.text = @"END";
                    break;
                default:
                    break;
            }
        }
        if (ecConfEvent == CONF_E_ATTENDEE_UPDATE_INFO) {
            DDLogInfo(@"ConfDetailViewController,CONF_E_ATTENDEE_UPDATE_INFO");
        }
    });
    
}

- (IBAction)joinConferenceButtonAction:(id)sender
{
    if ([ManagerService confService].currentConfBaseInfo.conf_state == CONF_E_STATE_DESTROYED)
    {
        [self showMessage:@"This conference have been end!"];
        return;
    }
    if ([ManagerService confService].currentConfBaseInfo.conf_state != CONF_E_STATE_GOING)
    {
        [self showMessage:@"This conference have not start going!"];
        return;
    }
    
    NSString *joinNumber = self.joinNumberTextField.text;
    
    NSString *pwd = [ManagerService confService].currentConfBaseInfo.chairman_pwd.length > 0 ? [ManagerService confService].currentConfBaseInfo.chairman_pwd :[ManagerService confService].currentConfBaseInfo.general_pwd;
    BOOL isVideoJoin = NO;
    if ([ManagerService confService].currentConfBaseInfo.media_type == CONF_MEDIATYPE_VIDEO || [ManagerService confService].currentConfBaseInfo.media_type == CONF_MEDIATYPE_VIDEO_DATA) {
        isVideoJoin = YES;
    }
    [[ManagerService confService] joinConferenceWithConfId:[ManagerService confService].currentConfBaseInfo.conf_id AccessNumber:[ManagerService confService].currentConfBaseInfo.access_number confPassWord:pwd joinNumber:joinNumber isVideoJoin:isVideoJoin];

}
- (IBAction)TextFiledReturnEditing:(id)sender {
    [sender resignFirstResponder];
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
-(void)dealloc
{
    [ManagerService confService].delegate = nil;
}
@end
