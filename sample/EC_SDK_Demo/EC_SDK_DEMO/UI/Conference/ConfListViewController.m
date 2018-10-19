//
//  ConfListViewController.m
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

#import "ConfListViewController.h"
#import "ConfListCell.h"
#import "CreateConfViewController.h"
#import "ManagerService.h"
#import "EmptyDataView.h"
#import "ConfDetailViewController.h"
#import "CommonUtils.h"
#import "ConfBaseInfo.h"

typedef NS_ENUM(NSInteger, ESpaceConfListSection){
    ESpaceConfListSection_Running   = 0,         //正在进行的会议section
    ESpaceConfListSection_Unopen    = 1,         //尚未开始的会议section
    ESpaceConfListSection_Close     = 2          //已结束会议section
};

#define CONFLIST_ROW_H 60  //行高
#define CONFLIST_SECTIONHEADER_H  25
#define APP_THEAM_COLOR RGBACOLOR(0x2c, 0x6e, 0xe8, 1)
#define RGBACOLOR(r,g,b,a) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:(a)]

//#define CACHE_NAME @"ConfListViewController"

@interface ConfListViewController ()<UITableViewDelegate, UITableViewDataSource, ConferenceServiceDelegate ,EmptyDataViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *confListTableView;
@property (nonatomic,strong) NSMutableArray *runningConfAry;
@property (nonatomic,strong) NSMutableArray *closeConfAry;
@property (nonatomic,strong) NSMutableArray *unopenConfAry;
@property (nonatomic,strong) UIRefreshControl *refreshControl;
@property (nonatomic,strong) NSMutableArray *confListAll;
@property (nonatomic, strong)EmptyDataView *emptyDataView;

@end

@implementation ConfListViewController

#pragma mark - life circle

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    if (UIDeviceOrientationPortrait != [[UIDevice currentDevice] orientation])
    {
        [[UIDevice currentDevice] setValue:[NSNumber numberWithInt:UIDeviceOrientationPortrait] forKey:@"orientation"];
    }
//    [CommonUtils setToOrientation:UIDeviceOrientationPortrait];
    
    [ManagerService confService].delegate = self;
    
    [self refreshConfList:nil];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.refreshControl endRefreshing];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"Conferecne";
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor whiteColor];
    [self configSubViews];
    
    [self refreshConfList:nil];
}

-(void)dealloc{
    [ManagerService confService].delegate = nil;
    _emptyDataView.delegate = nil;
    _confListTableView.delegate = nil;
    _confListTableView.dataSource = nil;
}

- (void)configSubViews
{
    _confListTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    _refreshControl = [[UIRefreshControl alloc] init];
    [_refreshControl addTarget:self
                        action:@selector(refreshConfList:)
              forControlEvents:UIControlEventValueChanged];
    [_confListTableView addSubview:_refreshControl];
    
    _runningConfAry = [[NSMutableArray alloc] init];
    _closeConfAry = [[NSMutableArray alloc] init];
    _unopenConfAry = [[NSMutableArray alloc] init];
}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    //调整界面，避免横屏情况下退到该界面时界面显示异常问题
    if (self.view.frame.size.width > [UIScreen mainScreen].bounds.size.width) {
        self.view.frame = CGRectMake(self.view.frame.origin.x,
                                     self.view.frame.origin.y,
                                     [UIScreen mainScreen].bounds.size.width,
                                     [UIScreen mainScreen].bounds.size.height-self.view.frame.origin.y);

    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Voice conference ballback
-(void)ecConferenceEventCallback:(EC_CONF_E_TYPE)ecConfEvent result:(NSDictionary *)resultDictionary
{
    if (ecConfEvent == CONF_E_GET_CONFLIST) {
        _confListAll = resultDictionary[ECCONF_LIST_KEY];
        [self reloadDataWithConfList:_confListAll];
    }
    if (ecConfEvent == CONF_E_ATTENDEE_UPDATE_INFO) {
        DDLogInfo(@"ConfListViewController,CONF_E_ATTENDEE_UPDATE_INFO");
    }
}

- (IBAction)createConf:(id)sender {
    CreateConfViewController *ctrl = [[CreateConfViewController alloc] init];
    ctrl.hidesBottomBarWhenPushed = YES;
    ctrl.title = @"Create Meeting";
    [self.navigationController pushViewController:ctrl animated:YES];
}

- (IBAction)accessConfByCode:(id)sender {
    UIAlertController *alertCon = [UIAlertController alertControllerWithTitle:nil message:@"Access conference" preferredStyle:UIAlertControllerStyleAlert];
    [alertCon addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"conference id";
        textField.secureTextEntry = NO;
    }];
    [alertCon addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"account";
        textField.secureTextEntry = NO;
    }];
    [alertCon addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"conf password";
        textField.secureTextEntry = NO;
    }];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Access" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UITextField *accountTxf0 = alertCon.textFields.firstObject;
        UITextField *accountTxf1 = alertCon.textFields[1];
        UITextField *accountTxf2 = alertCon.textFields[2];
        NSString *confId = accountTxf0.text;
        NSString *account = accountTxf1.text;
        NSString *password = accountTxf2.text;
        if (confId.length > 0 && account.length > 0 && password.length > 0) {
            [[ManagerService confService] joinConferenceWithConfId:confId AccessNumber:account confPassWord:password joinNumber:nil isVideoJoin:YES];
        }
        
    }];
    [alertCon addAction:okAction];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:nil];
    [alertCon addAction:cancelAction];
    [self presentViewController:alertCon animated:YES completion:nil];
}


#pragma mark - private methods

-(void)reloadDataWithConfList:(NSArray *)listArray{
    [self handleConfRecordWithConfList:(NSArray *)listArray];
    [_confListTableView reloadData];
    [self updateEmptyDataView];
    if (self.refreshControl.refreshing) {
        [self.refreshControl endRefreshing];
    }
}

-(void)handleConfRecordWithConfList:(NSArray *)listArray{
    [_runningConfAry removeAllObjects];
    [_closeConfAry removeAllObjects];
    [_unopenConfAry removeAllObjects];
    for (ConfBaseInfo *conf in listArray) {
        switch (conf.conf_state) {
            case CONF_E_STATE_GOING:
                [_runningConfAry addObject:conf];
                break;
            case CONF_E_STATE_SCHEDULE:
                [_unopenConfAry addObject:conf];
                break;
            case CONF_E_STATE_DESTROYED:
                [_closeConfAry addObject:conf];
                break;
            default:
                break;
        }
    }
}


-(ConfBaseInfo*)confAtIndexPath:(NSIndexPath*)indexPath{
    ConfBaseInfo *conf = nil;
    switch (indexPath.section) {
        case ESpaceConfListSection_Running:
            if ([_runningConfAry count] > indexPath.row) {
                conf = [_runningConfAry objectAtIndex:indexPath.row];
            }
            break;
        case ESpaceConfListSection_Unopen:
            if ([_unopenConfAry count] > indexPath.row) {
                conf = [_unopenConfAry objectAtIndex:indexPath.row];
            }
            break;
        case ESpaceConfListSection_Close:
            if ([_closeConfAry count] > indexPath.row) {
                conf = [_closeConfAry objectAtIndex:indexPath.row];
            }
            break;
        default:
            DDLogInfo(@"wrong section(%ld)",(long)indexPath.section);
            break;
    }
    return conf;
}

-(void)refreshConfList:(id)sender{
    [[ManagerService confService] obtainConferenceListWithPageIndex:1 pageSize:10];
}

- (void)updateEmptyDataView {
    if (_confListAll.count == 0) {
        [self showEmptyDataViewWithOption:ESpaceEDONoConference hiddenActionBtn:NO];
    } else {
        [self hideEmptyDataView];
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if ([self.confListTableView isEqual:tableView]){
        return 3;
    }
    return 0;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.confListTableView) {
        NSInteger count = 0;
        switch (section) {
            case ESpaceConfListSection_Running:
                count = [_runningConfAry count];
                break;
            case ESpaceConfListSection_Unopen:
                count = [_unopenConfAry count];
                break;
            case ESpaceConfListSection_Close:
                count = [_closeConfAry count];
                break;
            default:
                break;
        }
        return count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.confListTableView) {
        ConfListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"confListCell"];
        if (cell == nil) {
            cell = [[ConfListCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                             reuseIdentifier:@"confListCell"];
        }
        ConfBaseInfo  *conf = [self confAtIndexPath:indexPath];
        cell.conf = conf;
        return cell;
    }
    return [[UITableViewCell alloc] init];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    ConfBaseInfo  *conf = [self confAtIndexPath:indexPath];
    if (conf.conf_state == CONF_E_STATE_DESTROYED) {
        return YES;
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        if (indexPath.section != ESpaceConfListSection_Close) {
            return;
        }
        if ([self.closeConfAry count] > indexPath.row) {
            ConfBaseInfo* conf = [self.closeConfAry objectAtIndex:indexPath.row];
            if ([_confListAll containsObject:conf]) {
                [_confListAll removeObject:conf];
            }
            [self handleConfRecordWithConfList:_confListAll];
        }
        
        
    }
    
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (tableView == self.confListTableView){
        ConfBaseInfo* confInfo = [self confAtIndexPath:indexPath];
        [self performSegueWithIdentifier:@"confDetail" sender:confInfo];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return CONFLIST_ROW_H;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    CGFloat sectionHeaderHeight = 0;
    switch (section) {
        case ESpaceConfListSection_Running:
            sectionHeaderHeight = [_runningConfAry count] == 0 ? 0 : CONFLIST_SECTIONHEADER_H;
            break;
        case ESpaceConfListSection_Unopen:
            sectionHeaderHeight = [_unopenConfAry count] == 0 ? 0 : CONFLIST_SECTIONHEADER_H;
            break;
        case ESpaceConfListSection_Close:
            sectionHeaderHeight = [_closeConfAry count] == 0 ? 0 : CONFLIST_SECTIONHEADER_H;
            break;
        default:
            DDLogInfo(@"wrong section(%ld)",(long)section);
            break;
    }
    return sectionHeaderHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    NSString *sectionTitle = nil;;
    switch (section) {
        case ESpaceConfListSection_Running:
            sectionTitle = [_runningConfAry count] == 0 ? nil : @"Ongoing";
            break;
        case ESpaceConfListSection_Unopen:
            sectionTitle = [_unopenConfAry count] == 0 ? nil : @"Scheduled";
            break;
        case ESpaceConfListSection_Close:
            sectionTitle = [_closeConfAry count] == 0 ? nil : @"Ended";
            break;
        default:
            DDLogInfo(@"wrong section(%ld)",(long)section);
            break;
    }
    
    UIView *headerView = nil;
    if ([sectionTitle length] > 0) {
        headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0,tableView.frame.size.width, CONFLIST_SECTIONHEADER_H)];
        [headerView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:headerView.bounds];
        [titleLabel setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
        titleLabel.backgroundColor = [UIColor whiteColor];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.font = [UIFont systemFontOfSize:11];
        titleLabel.textColor = RGBACOLOR(0x66, 0x66, 0x66, 1);
        titleLabel.text = sectionTitle;
        [headerView addSubview:titleLabel];
        CGFloat lineH = 0.5;
        UIView *bottomLine = [[UIView alloc] initWithFrame:CGRectMake(0, titleLabel.frame.size.height - lineH,
                                                                      titleLabel.frame.size.width, lineH)];
        
        bottomLine.backgroundColor = RGBACOLOR(0xe6, 0xe6, 0xe6, 1);
        [headerView addSubview:bottomLine];
    }
    
    return headerView;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    ConfDetailViewController *confDetailCtrl = segue.destinationViewController;
    confDetailCtrl.confId =((ConfBaseInfo *)sender).conf_id;
}

- (void)showEmptyDataViewWithOption:(EmptyDataOption)option hiddenActionBtn:(BOOL)yesOrNo{
    if (!_emptyDataView) {
        _emptyDataView = [[EmptyDataView alloc] initWithOption:option];
        _emptyDataView.delegate = self;
        [_confListTableView addSubview:_emptyDataView];
    }
    
    _emptyDataView.center = CGPointMake(CGRectGetWidth(_confListTableView.bounds) / 2.0, CGRectGetHeight(_confListTableView.bounds) / 2.0);
    
    [_emptyDataView actionBtnHide:yesOrNo];
    [_emptyDataView setHidden:NO];
    [_emptyDataView updateWithOption:option];
}

- (void)hideEmptyDataView {
    _emptyDataView.hidden = YES;
}

- (void)eSpaceEmptyDataViewOnActionButtonPress:(EmptyDataView *)emptyDataView{
    [self createConf:nil];
}

@end
