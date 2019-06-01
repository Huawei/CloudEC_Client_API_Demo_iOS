//
//  NoDistorbViewController.m
//  TUP_Mobile_Demo
//
//  Created by tupservice on 2017/10/31.
//  Copyright © 2017年 cWX160907. All rights reserved.
//

#import "NoDisturbViewController.h"
#import "LoginCenter.h"
#import "CommonUtils.h"

#define kHeight4StatusBar               [UIApplication sharedApplication].statusBarFrame.size.height
#define UIStretchableImageA(imageName, width, height)    [UIImage stretchableImageNamed:imageName withLeftCapWidth:width topCapHeight:height]

//tableView的section数量
#define SWITCH_OFF_SECTION_NUMBERS 1
#define SWITCH_ON_SECTION_NUMBERS  2

//代表第几个section
#define TIME_SETTING_BUTTON_SECTION 0
#define SHOW_TIME_SECTION          1

//section对应的rows数量
#define ONE_ROWS 1
#define TWO_ROWS 2//ROWS_OF_SECOND_SECTION 2
#define NO_ROW 0

//时间选择section对应的两个cell
#define BEGIN_TIME_CELL 0
#define END_TIME_CELL   1

//tableViewCell的title部分坐标
#define CELL_TITLE_LABEL_START_X       9
#define CELL_TITLE_LABEL_WIDTH         200
#define CELL_TITLE_LABEL_START_Y       13
#define CELL_TITLE_LABEL_HEIGHT        25

#define CELL_CONTENT_LABEL_WIDTH       180

//显示系统Push状态的Label
#define PUSH_NOTICE_LABEL_HEIGHT        50
#define PUSH_NOTICE_LABEL_RIGHT_MARGIN  ([ESpaceUtile isOSMajorVersionHigherThanVersion:IOS_MAINVERSION_7] ? 15:30)

#define MIN_TIME_MINUTE                10
//datePicker的显示隐藏大小设定，以及仿的阴影的大小设定
#define SCREEN_SIZE                    (self.view.frame.size)
#define DATE_PICKER_VIEW_SHOW_FRAME    CGRectMake(0, (SCREEN_SIZE.height -200), SCREEN_SIZE.width, 200)
#define DATE_PICKER_VIEW_HIDDEN_FRAME  CGRectMake(0, (SCREEN_SIZE.height), SCREEN_SIZE.width, 200)
#define SHADOW_VIEW_SHOW_FRAME         CGRectMake(0, (SCREEN_SIZE.height -199), SCREEN_SIZE.width, 9)
#define SHADOW_VIEW_HIDDEN_FRAME       CGRectMake(0, (SCREEN_SIZE.height -9), SCREEN_SIZE.width, 9)

//heightForHeaderInSection中设置header
#define DEFAULT_HEADER_HEIGHT_IN_SECTION 5.0f

//当没有设置过时间的情况下显示的默认时间，且这里的时间存得时GMT的时间实际显示的时间将是加上时区差得时间
#define DEFAULT_GMT_BEGIN_TIME @"23:00"
#define DEFAULT_GMT_END_TIME   @"07:00"

#define FOOTER_LABEL_X 20//footer下label的x偏移量
#define DEFAULT_CELL_HEIGHT 44//默认的cell的高度

#define switch_width    60
#define switch_height   27

//时间字符串的长度
#define TIME_STRING_LENGTH 5

#define FONTSIZE_TBV_FOOTER_CONTENT           14     //tableview footer 内容字体大小
#define PUSH_SETTING_FOOTER_DEFAULT_WIDTH     ([UIScreen mainScreen].bounds.size.width - 20)
#define PUSH_SETTING_FOOTER_VIEW_WIDTH        ([UIScreen mainScreen].bounds.size.width)
#define PUSH_SETTING_FOOTER_SECTION_TEXT_COLOR       [UIColor colorWithRed:102.0/255.0 green:102.0/255.0 blue:102.0/255.0 alpha:1.0]

@interface NoDisturbViewController () <UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate>
{
    
}

typedef NS_ENUM(NSUInteger, SelectedPickerType) {
    SelectedBeginTimePicker      = 0,
    SelectedEndTimePicker        = 1,
    NoSelectedTimePicker         = 2
};

@property (nonatomic,retain) UITableView        *tableView;             //时间设置表格
@property (nonatomic,retain) UISwitch           *openOrCloseSwitch;     //开关
@property (nonatomic,retain) UIDatePicker       *beginTimePicker;       //开始时间选择器
@property (nonatomic,retain) UIDatePicker       *endTimePicker;         //结束时间选择器
@property (nonatomic,retain) UIView             *shadowView;            //时间选择器仿的阴影视图
@property (nonatomic,retain) NSDate             *beginTimeDate;         //开始时间
@property (nonatomic,retain) NSDate             *endTimeDate;           //结束时间
@property (nonatomic,assign) BOOL                lastEnable;
@property (nonatomic,assign) BOOL                isSwitchOn;            //表示switch的状态
@property (nonatomic,assign) NSInteger           lastSelectIndex;       //表示switch的状态

- (void) switchAction;
- (void) finishSettingAction;

//时间改变
- (void) beginTimeBeChanged:(id)sender;
- (void) endTimeBeChanged:(id)sender;

@end

@implementation NoDisturbViewController


#pragma mark -
#pragma mark UIViewControll Function
-(id)init
{
    return [self initWithPushConfig:YES noPushStart:nil noPushEnd:nil timeEnable:NO];
}

- (id)initWithPushConfig:(BOOL)enablePush noPushStart:(NSString *)beginTime noPushEnd:(NSString *)endTime timeEnable:(BOOL)timeEnable
{
    if (self = [super init])
    {
        
        _isSwitchOn = timeEnable;
        
        NSDateFormatter* dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"HH:mm"];
        [dateFormat setLocale:[NSLocale systemLocale]];
        
        NSDate *temp_beginDate = nil;
        NSDate *temp_endDate = nil;
        if (TIME_STRING_LENGTH == [beginTime length] && [beginTime caseInsensitiveCompare:endTime] != NSOrderedSame)//判断返回的时间字符串
        {
            NSTimeZone *timeZone = [[NSTimeZone alloc] initWithName:@"GMT"];
            [dateFormat setTimeZone:timeZone];
            
            temp_beginDate = [dateFormat dateFromString:beginTime];
            temp_endDate = [dateFormat dateFromString:endTime];
        }
        else
        {
            temp_beginDate = [dateFormat dateFromString:DEFAULT_GMT_BEGIN_TIME];
            temp_endDate = [dateFormat dateFromString:DEFAULT_GMT_END_TIME];
        }
        
        _lastEnable = enablePush;
        _beginTimeDate =[self getNewDate:temp_beginDate];
        _endTimeDate = [self getNewDate:temp_endDate] ;
    }
    return self;
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    CGFloat height = - 64.0;
    
    if (self.lastSelectIndex == SelectedBeginTimePicker) {
        
        //旋转屏幕 横屏时候 需要使 表示图上移
        [self contectInsetOfTableviewWithTop:height];
        
        self.beginTimePicker.frame  = DATE_PICKER_VIEW_SHOW_FRAME;
        self.shadowView.frame       = SHADOW_VIEW_SHOW_FRAME;
        self.endTimePicker.frame    = DATE_PICKER_VIEW_HIDDEN_FRAME;
        
    }else if (self.lastSelectIndex  == SelectedEndTimePicker){
        
        //旋转屏幕 横屏时候 点击 需要使 表示图上移
        [self contectInsetOfTableviewWithTop:height];
        
        self.endTimePicker.frame   = DATE_PICKER_VIEW_SHOW_FRAME;
        self.shadowView.frame      = SHADOW_VIEW_SHOW_FRAME;
        self.beginTimePicker.frame = DATE_PICKER_VIEW_HIDDEN_FRAME;
        
    }else{
        self.beginTimePicker.frame = DATE_PICKER_VIEW_HIDDEN_FRAME;
        self.endTimePicker.frame   = DATE_PICKER_VIEW_HIDDEN_FRAME;
    }
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    //title 设置
    self.title =  @"消息免打扰";
    self.lastSelectIndex = NoSelectedTimePicker;
    
    //右侧导航button设置
    UIBarButtonItem *finishbutton = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:nil action:NULL];
    finishbutton.target = self;
    finishbutton.action = @selector(finishSettingAction);
    self.navigationItem.rightBarButtonItem = finishbutton;
    
    self.tableView.delegate   = self;
    self.tableView.dataSource = self;
    
    //switch设置
    self.openOrCloseSwitch.on = _isSwitchOn;
}


- (UISwitch *) openOrCloseSwitch
{
    if (_openOrCloseSwitch == nil) {
        _openOrCloseSwitch = [[UISwitch alloc]initWithFrame:CGRectMake(0, 0, switch_width , switch_height)];
        [_openOrCloseSwitch addTarget:self
                               action:@selector(switchAction)
                     forControlEvents:UIControlEventValueChanged];
    }
    return _openOrCloseSwitch;
}


- (UITableView *) tableView
{
    if (_tableView == nil) {
        
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero];
        _tableView.tableFooterView = [[UIView alloc] init];
        self.automaticallyAdjustsScrollViewInsets = NO;
        self.view.backgroundColor = [UIColor whiteColor];
        _tableView.translatesAutoresizingMaskIntoConstraints = NO;
        _tableView.decelerationRate = (UIScrollViewDecelerationRateFast + UIScrollViewDecelerationRateNormal) / 2.0;
//        _tableView.separatorColor = RGBACOLOR(0xe6, 0xe6, 0xe6, 1);
        [self.view addSubview:_tableView];
        
        UIView* table = _tableView;
        id<UILayoutSupport> topGuide = self.topLayoutGuide;
        id<UILayoutSupport> bottomGuide = self.bottomLayoutGuide;
        NSDictionary* views = NSDictionaryOfVariableBindings(table, topGuide, bottomGuide);
        NSArray* vconstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[topGuide]-0-[table]-0-[bottomGuide]" options:0 metrics:nil views:views];
        NSArray* hconstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[table]|" options:0 metrics:nil views:views];
        [self.view addConstraints:vconstraints];
        [self.view addConstraints:hconstraints];
        [self.view updateConstraints];
        
        UISwipeGestureRecognizer *recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                         action:@selector(handleSwipeFrom:)];
        recognizer.delegate = self;
        [recognizer setDirection:(UISwipeGestureRecognizerDirectionDown)];
        recognizer.cancelsTouchesInView = NO;
        [self.view addGestureRecognizer:recognizer];
        [self.tableView.panGestureRecognizer requireGestureRecognizerToFail:recognizer];
        
    }
    return _tableView;
}


-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if ([self.navigationController isNavigationBarHidden]) {
        [self.navigationController setNavigationBarHidden:NO animated:animated];
    }
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    self.lastSelectIndex = NoSelectedTimePicker;
}


#pragma mark - other private function
- (NSDate *) getNewDate:(NSDate *)currentDate
{
    //获取目前的GMT时间中得年月日
    NSTimeZone      *timeZone    = [[NSTimeZone alloc] initWithName:@"GMT"];
    NSDateFormatter * dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yy-MM-dd"];
    [dateFormat setTimeZone:timeZone];
    
    NSDate   *dateNow      = [NSDate date];
    NSString *yearMonthDay = [dateFormat stringFromDate:dateNow];
    
    //从传入的时间中获取小时分钟
    [dateFormat setDateFormat:@"HH:mm"];
    NSString *hourAndMinute = [dateFormat stringFromDate:currentDate];
    
    //拼接时间字符串，得到新的时间
    NSString *tmpTime = [[NSString alloc]initWithFormat:@"%@ %@",yearMonthDay,hourAndMinute];
    [dateFormat setDateFormat:@"yy-MM-dd HH:mm"];
    NSDate * newDate = [dateFormat dateFromString:tmpTime];
    
    return newDate;
}

-(void)showMessage:(NSString *)msg {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                   message:msg
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [self presentViewController:alert animated:NO completion:nil];
    [NSTimer scheduledTimerWithTimeInterval:1.5
                                     target:self
                                   selector:@selector(creatAlert:)
                                   userInfo:alert
                                    repeats:NO];
}

- (void)creatAlert:(NSTimer *)timer {
    UIAlertController *alert = [timer userInfo];
    [alert dismissViewControllerAnimated:YES completion:nil];
    alert = nil;
}

- (void)finishSettingAction
{
    NSTimeZone      *timeZone      = [[NSTimeZone alloc] initWithName:@"GMT"];//零时区
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm"];//大写表示24小时制
    [dateFormatter setTimeZone:timeZone];
    
    NSDate *newBeginTime = [self getNewDate:_beginTimeDate];
    NSDate  *newEndTime  = [self getNewDate:_endTimeDate];
    NSString *begin_gmt_time = nil;
    NSString *end_gmt_time = nil;
    
    //发送配置消息
    NSString *value = nil;
    if (_isSwitchOn == YES) {
        value = @"YES" ;
    }else{
        value = @"NO" ;
    }
    
    if ([newBeginTime isEqualToDate:newEndTime])
    {
        [self showMessage:@"开始时间与结束时间不能相同"];
    }
    else
    {
        begin_gmt_time = [dateFormatter stringFromDate:newBeginTime];
        end_gmt_time   = [dateFormatter stringFromDate:newEndTime];
        
        if (TIME_STRING_LENGTH  != [begin_gmt_time length])
        {
            begin_gmt_time = [begin_gmt_time substringToIndex:TIME_STRING_LENGTH];
            end_gmt_time   = [end_gmt_time substringToIndex:TIME_STRING_LENGTH];
        }
        
        //        NSMutableDictionary *parmDic = [[NSMutableDictionary alloc] init];
        //        [parmDic setValue:begin_gmt_time forKey:@"noPushStart"];
        //        [parmDic setValue:end_gmt_time forKey:@"noPushEnd"];
        //        [parmDic setValue:value forKey:@"timeEnable"];
        
        [CommonUtils userDefaultSaveValue:@[value,begin_gmt_time, end_gmt_time] forKey:PushTimeEnableRecoud];
        
    }
    
    
    
//    [[LoginCenter sharedInstance] configUportalAPNSEnable:YES noPushStartTime:begin_gmt_time noPushEndTime:end_gmt_time enableNoPushByTime:_isSwitchOn];
    
    [self.navigationController popViewControllerAnimated:YES];
    
    
}


- (BOOL)isTwelveHours
{
    NSString *formatStringForHours = [NSDateFormatter dateFormatFromTemplate:@"j" options:0 locale:[NSLocale currentLocale]];
    NSRange containsA = [formatStringForHours rangeOfString:@"a"];
    return (containsA.location != NSNotFound ? YES : NO);
}

- (void)handleUIApplicationWillEnterForegroundNotification
{
    [self.tableView reloadData];
}


- (void) contectInsetOfTableviewWithTop:(CGFloat)top
{
    if (self.view.frame.size.width > self.view.frame.size.height) {
        [UIView animateWithDuration:0.3 animations:^{
            self.tableView.contentInset = UIEdgeInsetsMake(top, 0, 0, 0);
        }];
    }
}


#pragma mark -
#pragma mark UISwipeGestureRecognizer
-(void)handleSwipeFrom:(UISwipeGestureRecognizer *)recognizer
{
    [self hiddenOrShowDatePicker:NO picker:self.beginTimePicker];
    [self hiddenOrShowDatePicker:NO picker:self.endTimePicker];
    
    //竖屏
    CGFloat height = 0;
    [UIView animateWithDuration:0.3 animations:^{
        self.tableView.contentInset = UIEdgeInsetsMake(height, 0, 0, 0);
    }];
    
    self.lastSelectIndex = NoSelectedTimePicker;
}

#pragma mark -
#pragma mark UITableView
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * IdentifierOfCell = @"IdentifierOfCell";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:IdentifierOfCell];
    
    if (nil == cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:IdentifierOfCell];
    }
    
    for (UIView * temp_View in [cell.contentView subviews])
    {
        [temp_View removeFromSuperview];
    }
    cell.exclusiveTouch = YES;
    UILabel *temp_cellTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(CELL_TITLE_LABEL_START_X,
                                                                            (DEFAULT_CELL_HEIGHT - CELL_TITLE_LABEL_HEIGHT)/2,
                                                                            [UIScreen mainScreen].bounds.size.width - 90,
                                                                            CELL_TITLE_LABEL_HEIGHT)];
    temp_cellTitleLabel.backgroundColor = [UIColor clearColor];
    temp_cellTitleLabel.font = [UIFont systemFontOfSize:15.0];
    temp_cellTitleLabel.adjustsFontSizeToFitWidth = YES;
    temp_cellTitleLabel.minimumScaleFactor = 0.9;
    cell.accessoryView = nil;
    
    if (indexPath.section == TIME_SETTING_BUTTON_SECTION)
    {
        
        temp_cellTitleLabel.text = @"消息免打扰";
        [cell.contentView addSubview:temp_cellTitleLabel];
        cell.accessoryView = self.openOrCloseSwitch;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    else if (indexPath.section == SHOW_TIME_SECTION)
    {
        
        CGFloat width = self.view.frame.size.width - 100;
        temp_cellTitleLabel.frame = CGRectMake(CELL_TITLE_LABEL_START_X, CELL_TITLE_LABEL_START_Y, width, CELL_TITLE_LABEL_HEIGHT);
        
        UILabel *temp_cellContentLabel = [[UILabel alloc]initWithFrame:CGRectMake(0,
                                                                                  0,
                                                                                  100,
                                                                                  CELL_TITLE_LABEL_HEIGHT)];
        temp_cellContentLabel.backgroundColor = [UIColor clearColor];
        temp_cellContentLabel.font = [UIFont systemFontOfSize:15.0];
        
        temp_cellContentLabel.textAlignment = NSTextAlignmentRight;
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        
        NSDateFormatter* dateFormat = [[NSDateFormatter alloc] init];//默认的时区是本地的时区
        if ([self isTwelveHours])
        {
            [dateFormat setDateFormat:@"hh:mm a"];
        }
        else
        {
            [dateFormat setDateFormat:@"HH:mm"];//设定时间格式,只取"小时:分钟"
        }
        
        NSDate *disDate = nil;
        if (indexPath.row == BEGIN_TIME_CELL)
        {
            temp_cellTitleLabel.text = @"开始时间";
            disDate = _beginTimeDate;
            temp_cellContentLabel.text = [dateFormat stringFromDate:disDate];
        }
        else if (indexPath.row == END_TIME_CELL)
        {
            temp_cellTitleLabel.text = @"结束时间";
            disDate = _endTimeDate;
            temp_cellContentLabel.text = [dateFormat stringFromDate:disDate];
        }
        
        [cell.contentView addSubview:temp_cellTitleLabel];
        cell.accessoryView = temp_cellContentLabel;
    }
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == SHOW_TIME_SECTION)
    {
        //横屏时候 点击 需要使 表示图上移
        CGFloat height = -64.0;
        
        [self contectInsetOfTableviewWithTop:height];
        
        if(indexPath.row == BEGIN_TIME_CELL)
        {
            self.lastSelectIndex = SelectedBeginTimePicker;
            if (!self.beginTimePicker)
            {
                [self loadBeginTimeDatePicker];
            }
            [self hiddenOrShowDatePicker:YES picker:self.beginTimePicker];
        }
        else if (indexPath.row == END_TIME_CELL)
        {
            
            self.lastSelectIndex = SelectedEndTimePicker;
            if (!self.endTimePicker)
            {
                [self loadEndTimeDatePicker];
            }
            [self hiddenOrShowDatePicker:YES picker:self.endTimePicker];
        }
        
    }else{
        
        self.lastSelectIndex = NoSelectedTimePicker;
    }
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (_isSwitchOn)
    {
        return SWITCH_ON_SECTION_NUMBERS;
    }
    else
    {
        return SWITCH_OFF_SECTION_NUMBERS;
    }
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (TIME_SETTING_BUTTON_SECTION == section)
    {
        return ONE_ROWS;
    }
    else if (section == SHOW_TIME_SECTION)
    {
        return TWO_ROWS;
    }
    return NO_ROW;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return DEFAULT_CELL_HEIGHT;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return DEFAULT_HEADER_HEIGHT_IN_SECTION*2;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return nil;
}

#pragma mark -
#pragma mark UISwitch Action
- (void) switchAction
{
    _isSwitchOn = _openOrCloseSwitch.on;
    if (_isSwitchOn)
    {
        [self showStartTimeAndDurationView];
        
    }
    else if (!_isSwitchOn)
    {
        [self hiddenOrShowDatePicker:NO picker:self.beginTimePicker];
        [self hiddenOrShowDatePicker:NO picker:self.endTimePicker];
        [self hideStartTimeAndDurationView];
    }
}
#pragma mark -
#pragma mark UILabel Show and Hide Animation
- (void)showStartTimeAndDurationView
{
    NSInteger currentSections = [self.tableView numberOfSections];
    if (currentSections == SWITCH_OFF_SECTION_NUMBERS)
    {
        _isSwitchOn = _openOrCloseSwitch.on;
        
        [self.tableView beginUpdates];
        [self.tableView insertSections:[NSIndexSet indexSetWithIndex:SHOW_TIME_SECTION] withRowAnimation:UITableViewRowAnimationTop];
        [self.tableView endUpdates];
    }
}

- (void)hideStartTimeAndDurationView {
    NSInteger currentSections = [self.tableView numberOfSections];
    if (currentSections == SWITCH_ON_SECTION_NUMBERS)
    {
        _isSwitchOn = _openOrCloseSwitch.on;
        
        [self.tableView beginUpdates];
        [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:SHOW_TIME_SECTION] withRowAnimation:UITableViewRowAnimationBottom];
        [self.tableView endUpdates];
    }
}
#pragma mark -
#pragma mark UIDatePicker
-(void)loadBeginTimeDatePicker
{
    //创建UIDatePicker
    UIDatePicker *temp_beginTimePicker = [[UIDatePicker alloc]initWithFrame:DATE_PICKER_VIEW_HIDDEN_FRAME];
    self.beginTimePicker = temp_beginTimePicker;
    _beginTimePicker.datePickerMode = UIDatePickerModeTime;
    _beginTimePicker.minuteInterval = MIN_TIME_MINUTE;
    
    [self.beginTimePicker addTarget:self action:@selector(beginTimeBeChanged:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:_beginTimePicker];
    [_beginTimePicker setDate:_beginTimeDate animated:YES];
    [self changeDatePickerView:_beginTimePicker];
}

-(void)loadEndTimeDatePicker
{
    UIDatePicker *temp_endTimePicker = [[UIDatePicker alloc]initWithFrame:DATE_PICKER_VIEW_HIDDEN_FRAME];
    self.endTimePicker = temp_endTimePicker;
    _endTimePicker.datePickerMode = UIDatePickerModeTime;
    _endTimePicker.minuteInterval = MIN_TIME_MINUTE;
    
    [self.endTimePicker addTarget:self action:@selector(endTimeBeChanged:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:_endTimePicker];
    [_endTimePicker setDate:_endTimeDate animated:YES];
    [self changeDatePickerView:_endTimePicker];
}

- (void) changeDatePickerView:(UIDatePicker *)Picker
{
    UIView *pickerSubView = [[Picker subviews]objectAtIndex:0];
    int i = 0;
    CGFloat startX = 0.0f;//,endX = 0.0f;
    for(UIView *v in [pickerSubView subviews])
    {
        if ([[v description] hasPrefix:@"<_UIPickerViewSelectionBar"]) {
            UILabel *lb = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, v.frame.size.width, v.frame.size.height)];
            lb.backgroundColor = [UIColor colorWithRed:0 green:184.0f/255.0f blue:1.0f alpha:0.3];
            v.backgroundColor = [UIColor clearColor];
            [v addSubview:lb];
        }
        else if([[v description] hasPrefix:@"<_UIOnePartImageView"])
        {
            if(i == 0)
            {
                startX = v.frame.origin.x;
            }
            i++;
        }
    }
    
    for(UIView *v in [pickerSubView subviews])
    {
        if([[v description] hasPrefix:@"<_UIPickerViewTopFrame"])
        {
            v.alpha = 0.0;
            CGRect vFrame = CGRectMake(startX - 2, 0, DATE_PICKER_VIEW_HIDDEN_FRAME.size.width - (startX+startX - 4), DATE_PICKER_VIEW_HIDDEN_FRAME.size.height);
            UIImageView *pickerBackImage = [[UIImageView alloc]initWithFrame:vFrame];
//            pickerBackImage.image = UIStretchableImageA(@"datepickerview_bg.png", 0, 30);
            pickerBackImage.alpha = 1.0;
            UIImageView *pickerAddFrontBackImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, startX - 2,
                                                                                                DATE_PICKER_VIEW_HIDDEN_FRAME.size.height)];
//            pickerAddFrontBackImage.image = UIStretchableImageA(@"datepickerview_addbg.png", 0, 30);
            pickerAddFrontBackImage.alpha = 1.0;
            UIImageView *pickerAddEndBackImage = [[UIImageView alloc]initWithFrame:CGRectMake(DATE_PICKER_VIEW_HIDDEN_FRAME.size.width - (startX - 2),
                                                                                              0, startX - 2, DATE_PICKER_VIEW_HIDDEN_FRAME.size.height)];
//            pickerAddEndBackImage.image = UIStretchableImageA(@"datepickerview_addbg.png", 0, 30);
            pickerAddEndBackImage.alpha = 1.0;
            [pickerSubView addSubview:pickerAddFrontBackImage];
            [pickerSubView addSubview:pickerAddEndBackImage];
            [pickerSubView addSubview:pickerBackImage];
        }
    }
}


- (void)beginTimeBeChanged:(id)sender
{
    UIDatePicker *control = (UIDatePicker *)sender;
    NSDate * tmpDate = control.date;
    if ([tmpDate isEqualToDate:_endTimeDate])
    {
        NSTimeInterval timeInterval = -10*60;
        self.beginTimeDate = [_endTimeDate dateByAddingTimeInterval:timeInterval];
        [_beginTimePicker setDate:_beginTimeDate animated:YES];
    }
    else
    {
        self.beginTimeDate =tmpDate;
    }
    
    [self.tableView reloadData];
}

- (void)endTimeBeChanged:(id)sender
{
    UIDatePicker *control = (UIDatePicker *)sender;
    if ([control.date isEqualToDate:_beginTimeDate])
    {
        NSTimeInterval timeInterval = 10*60;
        self.endTimeDate = [_beginTimeDate dateByAddingTimeInterval:timeInterval];
        [_endTimePicker setDate:_endTimeDate];
    }
    else
    {
        self.endTimeDate =control.date;
    }
    
    
    [self.tableView reloadData];
}

#pragma mark -
#pragma mark UIDatePicker Show and Hide Animation
- (void)hiddenOrShowDatePicker:(BOOL)toShow picker:(UIDatePicker *)datePicker
{
    if (toShow)
    {
        if (datePicker == _beginTimePicker)
        {
            [self showPicker:_beginTimePicker alsoHidePicker:_endTimePicker];
        }else
        {
            [self showPicker:_endTimePicker alsoHidePicker:_beginTimePicker];
        }
        
    }
    else
    {
        [self hidePicker:datePicker completion:nil];
    }
}

- (BOOL)isPickerHidden:(UIDatePicker *)picker
{
    return picker.frame.origin.y > (self.view.bounds.size.height - picker.bounds.size.height);
}

- (void)showPicker:(UIDatePicker *)pickerToshow completion:(void (^)(BOOL finished))completion
{
    [UIView animateWithDuration:0.3
                     animations:^
     {
         pickerToshow.frame = DATE_PICKER_VIEW_SHOW_FRAME;
         self.shadowView.frame = SHADOW_VIEW_SHOW_FRAME;
     }
                     completion:completion];
}

- (void)hidePicker:(UIDatePicker *)pickerTohide completion:(void (^)(BOOL finished))completion
{
    [UIView animateWithDuration:0.3
                     animations:^
     {
         pickerTohide.frame = DATE_PICKER_VIEW_HIDDEN_FRAME;
         self.shadowView.frame = SHADOW_VIEW_HIDDEN_FRAME;
     }
                     completion:completion];
}

- (void)showPicker:(UIDatePicker *)pickerToshow alsoHidePicker:(UIDatePicker *)pickerToHide
{
    if (pickerToshow == nil)
    {
        return;
    }
    __weak typeof(self) weakSelf = self;
    self.tableView.userInteractionEnabled = NO;
    if (pickerToHide == nil || [self isPickerHidden:pickerToHide])
    {
        [self showPicker:pickerToshow completion:^(BOOL finished){
            weakSelf.tableView.userInteractionEnabled = YES;
        }];
    }else
    {
        [self hidePicker:pickerToHide completion:^(BOOL finished)
         {
             if (finished) {
                 [self showPicker:pickerToshow completion:^(BOOL finished){
                     weakSelf.tableView.userInteractionEnabled = YES;
                 }];
             }else{
                 weakSelf.tableView.userInteractionEnabled = YES;
             }
         }];
    }
}


@end

