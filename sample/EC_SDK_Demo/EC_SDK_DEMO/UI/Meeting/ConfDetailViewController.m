//
//  ConfDetailViewController.m
//  TUP_Mobile_Conference_Demo
//
//  Created by lwx308413 on 17/1/14.
//  Copyright © 2017年 huawei. All rights reserved.
//

#import "ConfDetailViewController.h"
#import "TUPService.h"
#import "TUPLoginInfo.h"
#import "MeetingViewController.h"
#import "ECCurrentConfInfo.h"
#import "ConfAttendee.h"

@interface ConfDetailViewController ()<TUPConferenceServiceDelegate>
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

@end

@implementation ConfDetailViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [TUPService confService].delegate = self;
    BOOL result = [[TUPService confService] obtainConferenceDetailInfoWithConfId:_confInfo.conf_id Page:1 pageSize:10];
    if (!result)
    {
        self.meetingVc.selectedConfInfo = self.confInfo;
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

-(void)ecConferenceEventCallback:(EC_CONF_E_TYPE)ecConfEvent result:(NSDictionary *)resultDictionary
{
    if (ecConfEvent == CONF_E_CURRENTCONF_DETAIL)
    {
        BOOL result = [resultDictionary[ECCONF_RESULT_KEY] boolValue];
        if (!result)
        {
            [self dismissViewControllerAnimated:YES completion:nil];
            self.meetingVc.selectedConfInfo = self.confInfo;
            return;
        }
        ECCurrentConfInfo *currentConfInfo = resultDictionary[ECCONF_CURRENTCONF_DETAIL_KEY];
        _confInfo = currentConfInfo.confDetailInfo;
        _idLabel.text = _confInfo.conf_id;
        _subjectLabel.text = _confInfo.conf_subject;
        _accessNumberLabel.text = _confInfo.access_number;
        _startTimeLabel.text = [self getLocalDateFormateUTCDate:_confInfo.start_time];
        _endTimeLabel.text = [self getLocalDateFormateUTCDate:_confInfo.end_time];
        _chairmanPwdLabel.text = _confInfo.chairman_pwd;
        _generalPwdLabel.text = _confInfo.general_pwd;
        _scheduserNameLabel.text = _confInfo.scheduser_name;
        _scheduserNumberLabel.text = _confInfo.scheduser_number;
        switch (_confInfo.media_type)
        {
            case CONF_MEDIATYPE_VOICE:
                _mediaType.text = @"Voice conference";
                break;
            case CONF_MEDIATYPE_VIDEO:
                _mediaType.text = @"Video conference";
                break;
        }
        if (_confInfo.media_type == 17)
        {
            _mediaType.text = @"Data conference";
        }
        switch (_confInfo.conf_state)
        {
            case CONF_E_CONF_STATE_SCHEDULE:
                _confStatusLabel.text = @"SCHEDULE";
                break;
            case CONF_E_CONF_STATE_CREATING:
                _confStatusLabel.text = @"CREATING";
                break;
            case CONF_E_CONF_STATE_GOING:
                _confStatusLabel.text = @"ON GOING";
                break;
            case CONF_E_CONF_STATE_DESTROYED:
                _confStatusLabel.text = @"END";
                break;
            default:
                break;
        }
    }
}
-(NSString *)getLocalDateFormateUTCDate:(NSString *)utcDate
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //input
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    [dateFormatter setTimeZone:timeZone];
    NSDate *dateFormatted = [dateFormatter dateFromString:utcDate];
    //output
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSTimeZone *localTimeZone = [NSTimeZone localTimeZone];
    [dateFormatter setTimeZone:localTimeZone];
    NSString *dateString = [dateFormatter stringFromDate:dateFormatted];
    return dateString;
}

- (IBAction)closeButtonAction:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)joinConferenceButtonAction:(id)sender
{
//    if (_confInfo.media_type == 17)
//    {
//        [self showMessage:@"Can not directly joining the data conference"];
//        return;
//    }
    if (_confInfo.conf_state == CONF_E_CONF_STATE_DESTROYED)
    {
        [self showMessage:@"This conference have been end!"];
        return;
    }
    if (_confInfo.conf_state != CONF_E_CONF_STATE_GOING)
    {
        [self showMessage:@"This conference have not start going!"];
        return;
    }
    
    TUPLoginInfo *uportalLoginInfo = [[TUPService loginService] obtainCurrentLoginInfo];
    NSArray *array = [[TUPService callService].sipAccount componentsSeparatedByString:@"@"];
    NSString *shortSipNum = array[0];
    ConfAttendee *tempAttendee = [[ConfAttendee alloc] init];
    tempAttendee.name = uportalLoginInfo.account;
    tempAttendee.number = shortSipNum;
    tempAttendee.type = ATTENDEE_TYPE_NORMAL;
    UILOG(@"scheduser_number : %@",_confInfo.scheduser_number);
    if (_confInfo.chairman_pwd.length > 0)
    {
        tempAttendee.role = CONF_ROLE_CHAIRMAN;
    }
    else
    {
        tempAttendee.role = CONF_ROLE_ATTENDEE;
    }
    NSArray *attendeeArray = @[tempAttendee];
    [[TUPService confService] createConfHandle:_confInfo.conf_id];
//    [self subscribeConfWithConfId:_confInfo.conf_id];
    [[TUPService confService] confCtrlAddAttendeeToConfercene:attendeeArray];
    self.meetingVc.selectedConfInfo = self.confInfo;
    [self dismissViewControllerAnimated:YES completion:nil];
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
//    [TUPService confService].delegate = nil;
}
@end
