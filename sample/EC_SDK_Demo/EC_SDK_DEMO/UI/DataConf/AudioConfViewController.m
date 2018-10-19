//
//  AudioConfViewController.m
//  EC_SDK_DEMO
//
//  Created by huawei on 2018/9/17.
//  Copyright © 2018年 cWX160907. All rights reserved.
//

#import "AudioConfViewController.h"
#import "ManagerService.h"
#import "ConfBaseInfo.h"
#import "CommonUtils.h"

@interface AudioConfViewController ()<UITableViewDelegate, UITableViewDataSource, CallServiceDelegate, ConferenceServiceDelegate>
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
//@property (strong, nonatomic) UIButton *moreBtn;
@property (nonatomic, strong) UIView *attendTableViewBackFullScreenView;

@end

@implementation AudioConfViewController

-(void)callEventCallback:(TUP_CALL_EVENT_TYPE)callEvent result:(NSDictionary *)resultDictionary
{
    
}

-(void)ecConferenceEventCallback:(EC_CONF_E_TYPE)ecConfEvent result:(NSDictionary *)resultDictionary
{
    switch (ecConfEvent) {
        case CONF_E_ATTENDEE_UPDATE_INFO:
            [self confAttendeeUpdateAction];
            break;
            
        default:
            break;
    }
}

- (void)confAttendeeUpdateAction
{
    //    [self.confCtrlArray removeAllObjects];
    //    if ([ManagerService confService].isVideoConfInvited) {
    //        [self.confCtrlArray addObject:@"Camera Change"];
    //        [self.confCtrlArray addObject:@"Lock Conf"];
    //        EC_CONF_MEDIATYPE mediaType = [ManagerService confService].currentConfBaseInfo.media_type;
    //        if (mediaType == CONF_MEDIATYPE_VOICE || mediaType == CONF_MEDIATYPE_VIDEO) {
    //            [self.confCtrlArray addObject:@"Update Date Meeting"];
    //        }
    //    }
    //    if (self.selfConfInfo.role == CONF_ROLE_CHAIRMAN) {
    //        [self.confCtrlArray addObject:@"Release Chair"];
    //    }else{
    //        [self.confCtrlArray addObject:@"Request Chair"];
    //    }
    
    [self.moreBtn setEnabled:YES];
    
    
    
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    [CommonUtils setToOrientation:UIDeviceOrientationLandscapeLeft];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    UIImage *backgroundImage = [UIImage imageNamed:@"tp_call_background"];
//    UIImageView *voiceCallOutBackgroundImageView = [[UIImageView alloc]initWithImage:backgroundImage];
//    [voiceCallOutBackgroundImageView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
//    [voiceCallOutBackgroundImageView setFrame:self.view.frame];
    
    
//    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"image_video_call_bg"]];
//    self.view.backgroundColor = [UIColor whiteColor];
    
    [_nameLabel setText:[ManagerService confService].selfJoinNumber];
    
    [self configBottomViewBtns];
}

- (void)configBottomViewBtns {
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
//    CGFloat width1 = self.view.bounds.size.width;
    self.voiceBtn.frame = CGRectMake(width/2-85, 0, 85, 85);
    self.muteBtn.frame = CGRectMake(width/2, 0, 85, 85);
    self.attendeeListBtn.frame = CGRectMake(width/2-170, 0, 85, 85);
//    self.moreBtn = [self createButtonByImage:[UIImage imageNamed:@"conf_tab_more"] highlightImage:nil title:@"More" target:self action:@selector(moreBtnPressed)];
    self.moreBtn.frame = CGRectMake(width/2+85, 0, 85, 85);
    [self.bottomView addSubview:self.voiceBtn];
    [self.bottomView addSubview:self.muteBtn];
    [self.bottomView addSubview:self.attendeeListBtn];
    [self.bottomView addSubview:self.moreBtn];
}

//- (void)moreBtnPressed
//{
//    [self.confCtrlArray removeAllObjects];
//
//    if (self.selfConfInfo.role == CONF_ROLE_CHAIRMAN) {
//        [self.confCtrlArray addObject:@"Release Chair"];
//
//        [self.confCtrlArray addObject:@"Lock Conf"];
//        EC_CONF_MEDIATYPE mediaType = [ManagerService confService].currentConfBaseInfo.media_type;
//        if (mediaType == CONF_MEDIATYPE_VOICE) {
//            [self.confCtrlArray addObject:@"UpGrade DateConf"];
//        }
//
//    }else{
//        [self.confCtrlArray addObject:@"Request Chair"];
//    }
//
//    [self.view addSubview:self.attendTableViewBackFullScreenView];
//    [_attendTableViewBackFullScreenView addSubview:self.confCtrlTableViewBackImageView];
//    self.confCtrlTableView.delegate = self;
//    self.confCtrlTableView.dataSource = self;
//}

- (UIView *)attendTableViewBackFullScreenView {
    if(nil == _attendTableViewBackFullScreenView) {
        CGFloat width = MIN(self.view.bounds.size.height, self.view.bounds.size.width);
        CGFloat hight = MAX(self.view.bounds.size.width, self.view.bounds.size.height);
        _attendTableViewBackFullScreenView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, width, hight)];
        _attendTableViewBackFullScreenView.backgroundColor = [UIColor clearColor];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(attendTableViewFullScreenViewTap:)];
        [_attendTableViewBackFullScreenView addGestureRecognizer:tap];
        [tap setCancelsTouchesInView:NO];
    }
    return _attendTableViewBackFullScreenView;
}

- (void)attendTableViewFullScreenViewTap:(UITapGestureRecognizer* )tap {
    //    _attendTableViewBackFullScreenView.hidden = YES;
    [_attendTableViewBackFullScreenView removeFromSuperview];
    [self.confCtrlTableView removeFromSuperview];
    [self.confCtrlTableViewBackImageView removeFromSuperview];
    _attendTableViewBackFullScreenView = nil;
    self.confCtrlTableView = nil;
    self.confCtrlTableViewBackImageView = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSInteger count = 0;
    
    count = self.confCtrlArray.count;
    
    return count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {

    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UITableViewCell class])];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:NSStringFromClass([UITableViewCell class])];
    }
    NSString *confCtrlAction = self.confCtrlArray[indexPath.row];
    cell.textLabel.text = confCtrlAction;
    cell.textLabel.textColor = [UIColor blackColor];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
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
