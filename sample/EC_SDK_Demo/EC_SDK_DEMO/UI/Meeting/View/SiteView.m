//
//  SiteView.m
//  TUP_Mobile_Conference_Demo
//
//  Created by lwx308413 on 16/8/12.
//  Copyright © 2016年 huawei. All rights reserved.
//

#import "SiteView.h"
#import "SiteViewTableViewDataSouce.h"
#include <sys/sysctl.h>
#import "ConfData.h"
#import "IMView.h"
#import "TUPService.h"

@interface SiteView()<UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UIButton *postponeConfButton;
@property (weak, nonatomic) IBOutlet UIButton *addAttendeeButton;
@property (weak, nonatomic) IBOutlet UIButton *requestChairmanButton;
@property (weak, nonatomic) IBOutlet UITableView *siteTableView;
@property (weak, nonatomic) IBOutlet UIButton *watchButton;
@property (nonatomic)SiteViewTableViewDataSouce *siteViewTableViewdataSource;
@property (weak, nonatomic) IBOutlet UIButton *closeCameraButton;
@end

@implementation SiteView

+(instancetype)shareInstance
{
    static SiteView *_siteView = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _siteView = [[SiteView alloc] init];
    });
    return _siteView;
}

-(instancetype)init
{
    self = [super init];
    if (!self)
    {
        return nil;
    }
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"SiteView" owner:self options:nil];
    self = [nib objectAtIndex:0];
    self.siteViewTableViewdataSource = [[SiteViewTableViewDataSouce alloc] init];
    self.siteTableView.delegate = self;
    self.siteTableView.dataSource = self.siteViewTableViewdataSource;
    self.siteTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    NSLog(@"_hostNumber--- :%@ _presentNumber--- :%@",_hostNumber,_presentNumber);
    self.siteViewTableViewdataSource.hostNumber = _hostNumber;
    self.siteViewTableViewdataSource.presentNumber = _presentNumber;
    [self.siteTableView reloadData];
    return self;
}
-(void)setHostNumber:(NSString *)hostNumber
{
    _hostNumber = hostNumber;
    self.siteViewTableViewdataSource.hostNumber = hostNumber;
    [self.siteTableView reloadData];
}

-(void)setPresentNumber:(NSString *)presentNumber
{
    UILOG(@"_presentNumber : %@",_presentNumber);
    _presentNumber = presentNumber;
    self.siteViewTableViewdataSource.presentNumber = presentNumber;
    [self.siteTableView reloadData];
}
-(void)showSiteViewInSuperView:(UIView *)superView Delegate:(id)delegate
{
    self.delegate = delegate;
//    self.center = CGPointMake([UIScreen mainScreen].bounds.size.width/2, [UIScreen mainScreen].bounds.size.height/2);
    self.frame = CGRectMake(8, 20, superView.bounds.size.width - 16,superView.bounds.size.height - 40);
    [superView addSubview:self];
}

-(void)hideSiteView
{
    [self removeFromSuperview];
}

- (IBAction)postponeConfButtonAction:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(clickSiteViewTopButtonAction:)])
    {
        [self.delegate clickSiteViewTopButtonAction:MUTE_ALLCONFERENCE_ACTION];
    }
}

-(void)setIsAllConferenceMute:(BOOL)isAllConferenceMute
{
    _isAllConferenceMute = isAllConferenceMute;
    if (_isAllConferenceMute)
    {
        [_postponeConfButton setTitle:@"UnMute All" forState:UIControlStateNormal];
    }
    else
    {
        [_postponeConfButton setTitle:@"Mute All" forState:UIControlStateNormal];
    }
    
}
- (IBAction)requestChairmanButtonAction:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(clickSiteViewTopButtonAction:)])
    {
        [self.delegate clickSiteViewTopButtonAction:LOCK_CONFERENCE_ACTION];
    }
}

-(void)setIsLockConference:(BOOL)isLockConference
{
    _isLockConference = isLockConference;
    if (_isLockConference)
    {
        [_requestChairmanButton setTitle:@"UnLock All" forState:UIControlStateNormal];
        [_addAttendeeButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        _addAttendeeButton.enabled = NO;
    }
    else
    {
        [_requestChairmanButton setTitle:@"Lock All" forState:UIControlStateNormal];
        [_addAttendeeButton setTitleColor:[UIColor colorWithRed:0/255.0 green:122/255.0 blue:255/255.0 alpha:1] forState:UIControlStateNormal];
        _addAttendeeButton.enabled = YES;
    }
}

- (IBAction)addAttendeeButtonAction:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(clickSiteViewTopButtonAction:)])
    {
        [self.delegate clickSiteViewTopButtonAction:ADD_ATTENDEE_ACTION];
    }
}


- (IBAction)closeSiteViewButtonAction:(id)sender
{
    [self hideSiteView];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ConfAttendeeInConf *member = self.attendeeArray[indexPath.row];
    if ([self.delegate respondsToSelector:@selector(selectECConferenceMemberInTableView:)])
    {
        [self.delegate selectECConferenceMemberInTableView:member];
    }
}

-(void)setAttendeeArray:(NSArray *)attendeeArray
{
    _attendeeArray = attendeeArray;
    _siteViewTableViewdataSource.siteListMutArray = _attendeeArray;
    [self.siteTableView reloadData];
}

-(void)setSelfSite:(TupSite *)selfSite
{
    _selfSite = selfSite;
}

- (IBAction)sendMessageButtonAction:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(clickSiteViewTopButtonAction:)])
    {
        [self.delegate clickSiteViewTopButtonAction:SEND_MSG_ACTION];
    }
}
- (IBAction)watchButtonAction:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(clickSiteViewTopButtonAction:)])
    {
        [self.delegate clickSiteViewTopButtonAction:WATCH_ACTION];
    }
}
- (IBAction)closeCameraButtonAction:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(clickSiteViewTopButtonAction:)])
    {
        [self.delegate clickSiteViewTopButtonAction:CLOSE_CAMERA_ACTION];
    }
}
-(void)setIsCloseCamera:(BOOL)isCloseCamera
{
    _isCloseCamera = isCloseCamera;
    if (isCloseCamera)
    {
        [_closeCameraButton setTitle:@"OpenCamera" forState:UIControlStateNormal];
    }
    else
    {
        [_closeCameraButton setTitle:@"CloseCamera" forState:UIControlStateNormal];
    }
}
- (void)peformDelegateMethodOnMainWithSelector:(SEL)aSelector withObject:(id)object
{
    if ([_delegate respondsToSelector:aSelector])
    {
        [(id)self.delegate performSelectorOnMainThread:aSelector withObject:object waitUntilDone:NO];
    }
}

@end
