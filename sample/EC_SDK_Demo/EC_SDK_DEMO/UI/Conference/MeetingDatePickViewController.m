//
//  MeetingDatePickViewController.m
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

#import "MeetingDatePickViewController.h"
//#import "AppDelegate.h"
#import "NSString+SizeWithFont.h"
#import "UIImage+Stretchable.h"

#define DEFAULT_LASTS_TIME             3600

//**************** modified by k00228462 for iOS6 **********************
#define DATE_PICKER_VIEW_SHOW_FRAME    CGRectMake(0, ([UIScreen mainScreen].bounds.size.height -280), [UIScreen mainScreen].bounds.size.width, 216)
#define DATE_PICKER_VIEW_HIDDEN_FRAME  CGRectZero// CGRectMake(0, ([UIScreen mainScreen].bounds.size.height -55), [UIScreen mainScreen].bounds.size.width, 216)
#define SHADOW_VIEW_SHOW_FRAME         CGRectMake(0, ([UIScreen mainScreen].bounds.size.height - 289), [UIScreen mainScreen].bounds.size.width, 9)
#define SHADOW_VIEW_HIDDEN_FRAME       CGRectMake(0, ([UIScreen mainScreen].bounds.size.height - 64), [UIScreen mainScreen].bounds.size.width, 9)
#define DATA_PICKERVIEW_HEIGHT  216

//**************** modified by k00228462 for iOS6 **********************

#define DEFAULT_HEIGHT_FOR_ROW_IN_TABLE     44

#define SECTION_INDEX_OF_TIMEANDDURATION_FOR_BOTH_STYLE 1
#define SECTION_INDEX_OF_TIMEANDDURATION_FOR_ONLY_STYLE 0

#define ROW_INDEX_FOR_NOWSWITHCH 0
#define ROW_INDEX_FOR_STARTTIME 0
#define ROW_INDEX_FOR_DURATION  1

#define NUM_OF_SECTIONS_FOR_ONLY_STYLE 1
#define NUM_OF_SECTIONS_FOR_BOTH_STYLE_FOR_SHEDULE 2
#define NUM_OF_SECTIONS_FOR_BOTH_STYLE_FOR_INSTANCE 1

#define DEFAULT_NUM_OF_ROWS_IN_SECTION 1
#define NUM_OF_ROWS_INTIMEANDDURATION_SECTION 2

#define DEFAULT_HEIGHT_FOR_HEADER_IN_SECTION 5.0

#define MIN_TIME_MINUTE                10
#define CELL_TITLE_LABEL_START_X       9
#define CELL_TITLE_LABEL_WIDTH         168
#define CELL_TITLE_LABEL_START_Y       13
#define CELL_TITLE_LABEL_HEIGHT        17
#define CELL_CONTENT_LABEL_WIDTH       180

#define FONTSIZE_TBV_GROUP_CONTENT 15

typedef enum {
    WEEK_DAY_SUNDAY = 1,
    WEEK_DAY_MONDAY,
    WEEK_DAY_TUESDAY,
    WEEK_DAY_WEDNESDAY,
    WEEK_DAY_THURSDAY,
    WEEK_DAY_FRIDAY,
    WEEK_DAY_SATURDAY
}WEEK_DAY_TYPE;

@interface MeetingDatePickViewController ()

@property (nonatomic,strong) UITableView        *timeChooseTableView;
@property (nonatomic,strong) UISwitch           *timeSwitch;
@property (nonatomic,strong) UIDatePicker       *beginTimePicker;
@property (nonatomic,strong) UIDatePicker       *lastsTimePicker;
@property (nonatomic,strong) UIView             *shadowView;
@property (nonatomic,strong) NSDate             *beginTimeDate;
@property (nonatomic,assign) NSTimeInterval     lastsTimeInterval;
@property (nonatomic,assign) BOOL               isNow;
@property (nonatomic,weak) id<MeetingDatePickerViewControllerDelegate> m_delegate;
//UIDatePicker隐藏显示动画
- (void) hiddenOrShowDatePicker:(BOOL)toShow picker:(UIDatePicker *)datePicker;

//更改beginTimeDatePicker选择器视图
- (void) changeBeginDatePickerView:(UIDatePicker *)Picker;

//更改lastsTimeDatePicker选择器视图
- (void) changeLastsDatePickerView:(UIDatePicker *)Picker;

//现在按钮开关响应
- (void) switchAction;

//会议开始时间更改响应
- (void) beginTimeChanged:(id)sender;

//会议时长更改响应
- (void) lastsTimeChanged:(id)sender;

//完成时间选择按钮响应
- (void) finishPicker;

//从后台返回，刷新数据
//- (void)refrashData;
- (void)showStartTimeAndDurationView;
- (void)hideStartTimeAndDurationView;
- (BOOL)styleForSheduledMeetingOnly;
@end

@implementation MeetingDatePickViewController

/*- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
 if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
 }
 return self;
 }*/
- (id)initWithDelegate:(id)delegate
             BeginTime:(NSDate *)beginTime
             lastsTime:(NSTimeInterval)lastsTime
         isImmediately:(BOOL)bNow
{
	if (self = [super init]) {
		//beginTimeDate = [[NSDate alloc]init]; 
		self.m_delegate = delegate;
		
		//如果传入的会议时长不为0，表示之前设置过，取传入的开始时间
		if ((self.isNow = bNow)) {
            self.lastsTimeInterval = DEFAULT_LASTS_TIME;
            self.beginTimeDate = [self.class startDate];
		}else {
			self.beginTimeDate = beginTime;
            self.lastsTimeInterval = lastsTime;
            //如果为空，取默认开始时间
            if (self.beginTimeDate == nil) {
                self.beginTimeDate = [self.class startDate];
            }
		}
	}
	return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
	self.title = @"conference time";
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
	_timeChooseTableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    _timeChooseTableView.backgroundView = nil;
//	_timeChooseTableView.backgroundColor = [UIColo];
	_timeChooseTableView.delegate = self;
	_timeChooseTableView.dataSource = self;
	_timeChooseTableView.sectionFooterHeight = 4;
	_timeChooseTableView.sectionHeaderHeight = 5;
	//_timeChooseTableView.scrollEnabled = NO;
    
	[self.view addSubview:_timeChooseTableView];
    _timeChooseTableView.translatesAutoresizingMaskIntoConstraints = NO;
    id <UILayoutSupport> top = self.topLayoutGuide;
    id <UILayoutSupport> bottom = self.bottomLayoutGuide;
    NSDictionary *views = NSDictionaryOfVariableBindings(_timeChooseTableView, top, bottom);
    NSArray *vconstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[top]-0-[_timeChooseTableView]-0-[bottom]" options:0 metrics:nil views:views];
    NSArray *hconstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_timeChooseTableView]|" options:0 metrics:nil views:views];
    [self.view addConstraints:vconstraints];
    [self.view addConstraints:hconstraints];
    [self.view updateConstraints];
    
	UISwitch *temp_timeSwitch= [[UISwitch alloc]initWithFrame:CGRectMake(0, 0, 60, 27)];
	self.timeSwitch = temp_timeSwitch;

	self.timeSwitch.on = self.isNow;
    
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Finish"
                                                                              style:(UIBarButtonItemStylePlain)
                                                                             target:self
                                                                             action:@selector(finishPicker)];
    // DOTO: 通话过程中不可选择即时会议
    
}

-(void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
//	if ([self.navigationController isNavigationBarHidden]) {
//		[self.navigationController setNavigationBarHidden:NO animated:animated];
//	}
}

- (void)dealloc {
	_timeChooseTableView.delegate = nil;
	_timeChooseTableView.dataSource = nil;
    self.m_delegate = nil;
}

#pragma mark -
#pragma mark 私有函数


-(void)loadBeginTimeDatePicker {
	//Datepicker创建
    if (nil == _beginTimePicker) {
        _beginTimePicker = [[UIDatePicker alloc]initWithFrame:DATE_PICKER_VIEW_HIDDEN_FRAME];
        _beginTimePicker.minimumDate = [self.class startDate];
        _beginTimePicker.minuteInterval = MIN_TIME_MINUTE;
        _beginTimePicker.datePickerMode = UIDatePickerModeDateAndTime;
        [_beginTimePicker addTarget:self action:@selector(beginTimeChanged:) forControlEvents:UIControlEventValueChanged];
        _beginTimePicker.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:_beginTimePicker];
        self.beginTimePicker.translatesAutoresizingMaskIntoConstraints = NO;
        NSDictionary *views = NSDictionaryOfVariableBindings(_beginTimePicker);
        NSString *str = [NSString stringWithFormat:@"V:[_beginTimePicker(>=%d)]|", DATA_PICKERVIEW_HEIGHT];
        NSArray *vconstraints = [NSLayoutConstraint constraintsWithVisualFormat:str options:0 metrics:nil views:views];
        NSArray *hconstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_beginTimePicker]|" options:0 metrics:nil views:views];
        
        [self.view addConstraints:vconstraints];
        [self.view addConstraints:hconstraints];
        [self.view updateConstraints];
    }
    [_beginTimePicker setDate:self.beginTimeDate animated:YES];
}

-(void)loadLastsTimeDatePicker {
    if (nil == _lastsTimePicker) {
        _lastsTimePicker = [[UIDatePicker alloc]initWithFrame:DATE_PICKER_VIEW_HIDDEN_FRAME];
        _lastsTimePicker.datePickerMode = UIDatePickerModeCountDownTimer;
        _lastsTimePicker.minuteInterval = MIN_TIME_MINUTE;
        [_lastsTimePicker addTarget:self action:@selector(lastsTimeChanged:) forControlEvents:UIControlEventValueChanged];
        _lastsTimePicker.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:_lastsTimePicker];
        self.lastsTimePicker.translatesAutoresizingMaskIntoConstraints = NO;
        NSDictionary *views = NSDictionaryOfVariableBindings(_lastsTimePicker);
        NSString *str = [NSString stringWithFormat:@"V:[_lastsTimePicker(>=%d)]|", DATA_PICKERVIEW_HEIGHT];
        NSArray *vconstraints = [NSLayoutConstraint constraintsWithVisualFormat:str options:0 metrics:nil views:views];
        NSArray *hconstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_lastsTimePicker]|" options:0 metrics:nil views:views];
        
        [self.view addConstraints:vconstraints];
        [self.view addConstraints:hconstraints];
        [self.view updateConstraints];
    }
	
    NSDate *refdate = [NSDate dateWithTimeIntervalSinceReferenceDate:0];//参考日期2001-01-01 00.00＋时区差
    NSTimeZone *zone = [NSTimeZone defaultTimeZone];
    NSInteger diff = [zone secondsFromGMTForDate:refdate];//时区差
    NSDate *dateStart = [refdate dateByAddingTimeInterval:-diff + self.lastsTimeInterval];
    [self.lastsTimePicker setDate:dateStart animated:YES];
}

-(void)loadPickerShadowPic {
	
	//_lastsTimePicker.hidden = YES;
	//pick上阴影视图
    if (nil == _shadowView) {
        _shadowView = [[UIView alloc]initWithFrame:SHADOW_VIEW_HIDDEN_FRAME];
        UIImageView *shadowImage = [[UIImageView alloc]initWithFrame:CGRectZero];
        shadowImage.image = [UIImage imageNamed:@"datepickerview_shadow.png"];
        [_shadowView addSubview:shadowImage];
//        _shadowView.backgroundColor = UIColor.redColor;
        [self.view addSubview:_shadowView];
        _shadowView.translatesAutoresizingMaskIntoConstraints = NO;
        NSDictionary *views = NSDictionaryOfVariableBindings(_shadowView);
        NSString *strV = [NSString stringWithFormat:@"V:[_shadowView(==%d)]-%d-|", (int)shadowImage.image.size.height ,DATA_PICKERVIEW_HEIGHT];
        NSArray *vconstraints = [NSLayoutConstraint constraintsWithVisualFormat:strV options:0 metrics:nil views:views];
        NSArray *hconstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_shadowView]|" options:0 metrics:nil views:views];
        [self.view addConstraints:vconstraints];
        [self.view addConstraints:hconstraints];
        [self.view updateConstraints];
    }
}

//更改lastTimeDatePicker选择器视图,（更改pickerView的frame大小和背景颜色）
- (void) changeLastsDatePickerView:(UIDatePicker *)Picker
{
	UIView *pickerSubView = [[Picker subviews]objectAtIndex:0];
	//NSLog(@"%@",pickerSubView.subviews);
	int i = 1,j = 1,k = 1,l=1,m = 1;
	for(UIView *v in [pickerSubView subviews])
	{
		if ([[v description] hasPrefix:@"<_UIPickerViewSelectionBar"]) {
			
			CGRect vframe1 = CGRectMake(11, 86, 148, 44);
			CGRect vframe2 = CGRectMake(161, 86, 148, 44);
			if (i == 1) {
				v.frame = vframe1;
				i++;
			}
			else {
				v.frame = vframe2;
				i = 1;
			}
			
			UILabel *lb = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, v.frame.size.width, v.frame.size.height)];
			lb.backgroundColor = [UIColor colorWithRed:0 green:184.0f/255.0f blue:1.0f alpha:0.3];
			v.backgroundColor = [UIColor clearColor];
			[v addSubview:lb];
		}
		else if([[v description] hasPrefix:@"<_UIPickerWheelView"])
		{
			CGRect vframe1 = CGRectMake(11, 0, 148, 216);
			CGRect vframe2 = CGRectMake(161, 0, 148, 216);
			if (j == 1) {
				v.frame = vframe1;
				j++;
			}
			else {
				v.frame = vframe2;
				j = 1;
			}
			
		}
		/*else if([[v description] hasPrefix:@"<UILabel"])
         {
         //v.backgroundColor = [UIColor redColor];
         //CGRect tt1 = CGRectMake(11, 96, 148, 26);(91 96; 43 26)
         //			CGRect tt2 = CGRectMake(161, 96, 148, 26);(217 96; 43 26)
         //			if (l%2) {
         //				v.frame = tt1;
         //				l++;
         //			}
         //			else {
         //				v.frame = tt2;
         //				l=1;
         //			}
         
         }*/
		else if([[v description] hasPrefix:@"<_UIPickerViewTopFrame"])
		{
			v.alpha = 0.0;
			CGRect vFrame = CGRectMake(8, 0, _lastsTimePicker.frame.size.width - 16, _lastsTimePicker.frame.size.height);
			UIImageView *pickerBackImage = [[UIImageView alloc]initWithFrame:vFrame];
			pickerBackImage.image = UIStretchableImageA(@"datepickerview_bg.png", 0, 30);
			pickerBackImage.alpha = 1.0;
			UIImageView *pickerAddFrontBackImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 8,
																								_lastsTimePicker.frame.size.height)];
			pickerAddFrontBackImage.image = UIStretchableImageA(@"datepickerview_addbg.png", 0, 30);
            pickerAddFrontBackImage.alpha = 1.0;
			UIImageView *pickerAddEndBackImage = [[UIImageView alloc]initWithFrame:CGRectMake(_lastsTimePicker.frame.size.width - 8,
																							  0, 8, _lastsTimePicker.frame.size.height)];
            pickerAddEndBackImage.image = UIStretchableImageA(@"datepickerview_addbg.png", 0, 30);
            pickerAddEndBackImage.alpha = 1.0;
			[pickerSubView addSubview:pickerAddFrontBackImage];
			[pickerSubView addSubview:pickerAddEndBackImage];
			[pickerSubView addSubview:pickerBackImage];
		}
		else if([[v description] hasPrefix:@"<_UIPickerWheelView"])
		{
			CGRect vframe1 = CGRectMake(11, 0, 148, 216);
			CGRect vframe2 = CGRectMake(160, 0, 148, 216);
			if (k == 1) {
				v.frame = vframe1;
				k++;
			}
			else {
				v.frame = vframe2;
				k = 1;
			}
			
		}
		else if([[v description] hasPrefix:@"<_UIPickerTable"])
		{
			CGRect vframe1 = CGRectMake(11, 0, 148, 216);
			CGRect vframe2 = CGRectMake(161, 0, 148, 216);
			if (l == 1) {
				v.frame = vframe1;
				l++;
			}
			else {
				v.frame = vframe2;
				l = 1;
			}
			
		}
		else if([[v description] hasPrefix:@"<_UIOnePartImageView"])
		{
			
			CGRect vframe1 = CGRectMake(10, 86, 1, 48);
			CGRect vframe2 = CGRectMake(11, 0, 148, 216);
			CGRect vframe3 = CGRectMake(11, 86, 148, 62);
			CGRect vframe4 = CGRectMake(159, 86, 2, 48);
			CGRect vframe5 = CGRectMake(161, 0, 148, 216);
			CGRect vframe6 = CGRectMake(161, 86, 148, 62);
			CGRect vframe7 = CGRectMake(309, 86, 1, 48);
			if (m == 1) {
				v.frame = vframe1;
				m++;
			}
			else if (m == 2) {
				v.frame = vframe2;
				m++;
			}
			else if (m == 3) {
				v.frame = vframe3;
				m++;
			}else if (m == 4) {
				v.frame = vframe4;
				m++;
			}
			else if (m == 5) {
				v.frame = vframe5;
				m++;
			}
			else if (m == 6) {
				v.frame = vframe6;
				m++;
			}else if (m == 7) {
				v.frame = vframe7;
				m = 1;
			}
		}
	}
}

//更改beginTimeDatePicker选择器视图
- (void) changeBeginDatePickerView:(UIDatePicker *)Picker
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
		/*else if([[v description] hasPrefix:@"<_UIPickerViewTopFrame"])
         {
         v.alpha = 0.0;
         CGRect tt = CGRectMake(0, 0, _lastsTimePicker.frame.size.width, _lastsTimePicker.frame.size.height);
         UIImageView *pickerBackImage = [[UIImageView alloc]initWithFrame:tt];
         pickerBackImage.image = [UIImage imageNamed:@"pickerview_bg.png"];
         pickerBackImage.alpha = 1.0;
         [pickerSubView addSubview:pickerBackImage];
         }*/
		else if([[v description] hasPrefix:@"<_UIOnePartImageView"])
		{
			if(i == 0)
			{
				startX = v.frame.origin.x;
			}
			/*else if(i == 12)
             {
             endX = v.frame.origin.x + v.frame.size.width;
             }*/
            
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
			pickerBackImage.image = UIStretchableImageA(@"datepickerview_bg.png", 0, 30);
			pickerBackImage.alpha = 1.0;
			UIImageView *pickerAddFrontBackImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, startX - 2,
																								DATE_PICKER_VIEW_HIDDEN_FRAME.size.height)];
			pickerAddFrontBackImage.image = UIStretchableImageA(@"datepickerview_addbg.png", 0, 30);
			pickerAddFrontBackImage.alpha = 1.0;
			UIImageView *pickerAddEndBackImage = [[UIImageView alloc]initWithFrame:CGRectMake(DATE_PICKER_VIEW_HIDDEN_FRAME.size.width - (startX - 2),
																							  0, startX - 2, DATE_PICKER_VIEW_HIDDEN_FRAME.size.height)];
			pickerAddEndBackImage.image = UIStretchableImageA(@"datepickerview_addbg.png", 0, 30);
			pickerAddEndBackImage.alpha = 1.0;
			[pickerSubView addSubview:pickerAddFrontBackImage];
			[pickerSubView addSubview:pickerAddEndBackImage];
			[pickerSubView addSubview:pickerBackImage];
		}
	}
}

- (BOOL)isPickerHidden:(UIDatePicker *)picker {
    return picker.frame.origin.y > (self.view.bounds.size.height - picker.bounds.size.height);
}
- (void)showPicker:(UIDatePicker *)pickerToshow completion:(void (^)(BOOL finished))completion{
//    [UIView animateWithDuration:0.3
//                     animations:^{
//                         pickerToshow.frame = DATE_PICKER_VIEW_SHOW_FRAME;
//                         selkf.shadowView.frame = SHADOW_VIEW_SHOW_FRAME;
//                     }
//                     completion:completion];
    pickerToshow.hidden = NO;
    if (completion) {
        completion(YES);
    }
}

- (void)hidePicker:(UIDatePicker *)pickerTohide completion:(void (^)(BOOL finished))completion{
    pickerTohide.hidden = YES;
    
//    [UIView animateWithDuration:0.3
//                     animations:^{
//                         pickerTohide.frame = DATE_PICKER_VIEW_HIDDEN_FRAME;
//                         selkf.shadowView.frame = SHADOW_VIEW_HIDDEN_FRAME;
//                     }
//                     completion:completion];
    if (completion) {
        completion(YES);
    }
}

- (void)showPicker:(UIDatePicker *)pickerToshow alsoHidePicker:(UIDatePicker *)pickerToHide {
    if (pickerToshow == nil) {
        return;
    }
    if (pickerToHide == nil || [self isPickerHidden:pickerToHide]) {
        [self showPicker:pickerToshow completion:nil];
    }else {
        [self hidePicker:pickerToHide
              completion:^(BOOL finished){
                  if (finished) {
                      [self showPicker:pickerToshow completion:nil];
                  }
              }];
    }
}

- (NSString *)weekStringtTrans:(NSInteger)weeks {
	NSString *weekString = @"";
	switch (weeks) {
		case WEEK_DAY_SUNDAY:
			weekString = @"Sunday";
			break;
		case WEEK_DAY_MONDAY:
			weekString = @"Monday";
			break;
		case WEEK_DAY_TUESDAY:
			weekString =  @"Tuesday";
			break;
		case WEEK_DAY_WEDNESDAY:
			weekString = @"Wednesday";
			break;
		case WEEK_DAY_THURSDAY:
			weekString = @"Thursday";
			break;
		case WEEK_DAY_FRIDAY:
			weekString = @"Friday";
			break;
		case WEEK_DAY_SATURDAY:
			weekString = @"Saturday";
			break;
		default:
			break;
	}
	return weekString;
}


- (NSString *)beginTimeStringFormat:(NSDate *)beginTime
{
	NSDateFormatter *formatter =[[NSDateFormatter alloc] init];
	[formatter setTimeStyle:NSDateFormatterMediumStyle];
	NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
	NSInteger unitFlags = 	NSCalendarUnitYear |
	NSCalendarUnitMonth |
	NSCalendarUnitDay |
	NSCalendarUnitWeekday |
	NSCalendarUnitHour |
	NSCalendarUnitMinute;
	NSDateComponents *comps = [calendar components:unitFlags fromDate:beginTime];
	//comps = [calendar components:unitFlags fromDate:beginTime];
	
	NSInteger week = [comps weekday];
	NSInteger year =[comps year];
	NSInteger month = [comps month];
	NSInteger day = [comps day];
	NSInteger hour = [comps hour];
	NSInteger min = [comps minute];
	
	NSString *beginTimeDateString = [NSString stringWithFormat:@"%04ld/%02ld/%02ld %@ %02ld:%02ld",(long)year,(long)month,(long)day,[self weekStringtTrans:week],(long)hour,(long)min];
	return beginTimeDateString;
}

//格式转换
/*-(NSString *)transformDuration:(NSTimeInterval)iduration{
 
 NSInteger totalMin = (NSInteger)(iduration)/60;
 NSInteger hour = totalMin/60;
 NSInteger minute = totalMin%60;
 
 NSString *time=nil;
 if (0 == hour) {
 time = [NSString stringWithFormat:@"%d%@",minute,MINUTE];
 } 
 else if(0 == minute) {
 time = [NSString stringWithFormat:@"%d%@",hour,HOUR];
 }
 else {
 time = [NSString stringWithFormat:@"%d%@%d%@",hour,HOUR,minute,MINUTE];
 }
 return time;
 }*/

#pragma mark -
//现在按钮开关响应
- (void) switchAction {
    self.isNow = self.timeSwitch.on;
	if (self.isNow) {
        [self hiddenOrShowDatePicker:NO picker:_beginTimePicker];
		[self hiddenOrShowDatePicker:NO picker:_lastsTimePicker];
        [self hideStartTimeAndDurationView];
	}else {
        [self showStartTimeAndDurationView];
	}
}

//会议开始时间更改响应
- (void) beginTimeChanged:(id)sender {
	UIDatePicker *control = (UIDatePicker *)sender;
	self.beginTimeDate = control.date;
	[self.timeChooseTableView reloadData];
}

//会议时长更改响应
- (void) lastsTimeChanged:(id)sender {
	self.lastsTimeInterval = [self.lastsTimePicker countDownDuration];
	if (MIN_TIME_MINUTE*60 > self.lastsTimeInterval) {
		NSDate *refdate = [NSDate dateWithTimeIntervalSinceReferenceDate:0];//参考日期2001-01-01 00.00＋时区差
		NSTimeZone *zone = [NSTimeZone defaultTimeZone];
		NSInteger diff = [zone secondsFromGMTForDate:refdate];//时区差
		NSDate *dateMin = [refdate dateByAddingTimeInterval:-diff + MIN_TIME_MINUTE*60];//取得的参考日期需要减去时区差
		_lastsTimePicker.minimumDate = dateMin;
		[self.lastsTimePicker setDate:dateMin animated:YES];
		self.lastsTimeInterval = MIN_TIME_MINUTE*60;
	}
	[self.timeChooseTableView reloadData];
}

//完成时间选取
- (void)finishPicker
{
	if (self.isNow) {
		self.lastsTimeInterval = 0;
	}
    if ([self.m_delegate respondsToSelector:@selector(datePickerViewController:didSelectBeginTime:lastsTime:immediately:)]) {
        [self.m_delegate datePickerViewController:self didSelectBeginTime:self.beginTimeDate lastsTime:self.lastsTimeInterval immediately:self.isNow];
    }
}

#pragma mark -
//取根据已有时间取新的时间（整数）
//开始时间为当前时间的个位时间数四舍五入，再推后10分钟得到
+ (NSDate *)startDate {
	NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
	[formatter setDateFormat:@"mm"];
	NSString *from_minute = [formatter stringFromDate:[NSDate date]];

	
	NSInteger minute = [from_minute integerValue];
	NSInteger secs = 60*minute;
	NSTimeInterval interval = 0;
	if (minute%10/5 > 0) {
		interval = (minute/10 + 2)*10*60 - secs;
	}else {
		interval = (minute/10 + 1)*10*60 - secs;
	}
    
	NSDate *temp_Date = [[NSDate alloc]initWithTimeInterval:interval sinceDate:[NSDate date]];
    return temp_Date;
}

//UIDatePicker隐藏显示动画
- (void)hiddenOrShowDatePicker:(BOOL)toShow picker:(UIDatePicker *)datePicker {
	
	if (toShow) {
        if (datePicker == _beginTimePicker){
			[self showPicker:_beginTimePicker alsoHidePicker:_lastsTimePicker];
		}else{
            [self showPicker:_lastsTimePicker alsoHidePicker:_beginTimePicker];
		}
	}else {
		[self hidePicker:datePicker completion:nil];
	}
}
- (void)showStartTimeAndDurationView {
    NSInteger currentSections = [self.timeChooseTableView numberOfSections];
    if (!(self.isNow = self.timeSwitch.on) && currentSections == NUM_OF_SECTIONS_FOR_BOTH_STYLE_FOR_INSTANCE) {
        [self.timeChooseTableView beginUpdates];
        [self.timeChooseTableView insertSections:[NSIndexSet indexSetWithIndex:SECTION_INDEX_OF_TIMEANDDURATION_FOR_BOTH_STYLE] withRowAnimation:UITableViewRowAnimationFade];
        [self.timeChooseTableView endUpdates];
    }
}

- (void)hideStartTimeAndDurationView {
    NSInteger currentSections = [self.timeChooseTableView numberOfSections];
    if ((self.isNow = self.timeSwitch.on) && currentSections == NUM_OF_SECTIONS_FOR_BOTH_STYLE_FOR_SHEDULE) {
        [self.timeChooseTableView beginUpdates];
        [self.timeChooseTableView deleteSections:[NSIndexSet indexSetWithIndex:SECTION_INDEX_OF_TIMEANDDURATION_FOR_BOTH_STYLE] withRowAnimation:UITableViewRowAnimationFade];
        [self.timeChooseTableView endUpdates];
    }
}
- (BOOL)styleForSheduledMeetingOnly {
//    BOOL value = [[[ECSAppConfig sharedInstance] currentUser] isSupportFunction:EN_FUNC_CTC];
//    return !value;
    //todo jinliang
    return NO;
}
#pragma mark -
#pragma mark UITableView

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if ((indexPath.section == SECTION_INDEX_OF_TIMEANDDURATION_FOR_BOTH_STYLE) && (indexPath.row == ROW_INDEX_FOR_STARTTIME))
	{
		return DEFAULT_HEIGHT_FOR_ROW_IN_TABLE;
	}
	return DEFAULT_HEIGHT_FOR_ROW_IN_TABLE + 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([self styleForSheduledMeetingOnly]) {
        return NUM_OF_ROWS_INTIMEANDDURATION_SECTION;
    }else if (self.isNow) {
        return DEFAULT_NUM_OF_ROWS_IN_SECTION;
    }else {
        if (section == SECTION_INDEX_OF_TIMEANDDURATION_FOR_BOTH_STYLE) {
			return NUM_OF_ROWS_INTIMEANDDURATION_SECTION;
		}else{
            return DEFAULT_NUM_OF_ROWS_IN_SECTION;
        }
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if ([self styleForSheduledMeetingOnly]) {
        return NUM_OF_SECTIONS_FOR_ONLY_STYLE;
    }else if(self.isNow) {
		return NUM_OF_SECTIONS_FOR_BOTH_STYLE_FOR_INSTANCE;
	}else {
        return NUM_OF_SECTIONS_FOR_BOTH_STYLE_FOR_SHEDULE;
    }
} 

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CellIdentifier = @"numChoosecell";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
	}
	for (UIView* temp_View in [cell.contentView subviews]) {
		[temp_View removeFromSuperview];
	}
    
	if (![self styleForSheduledMeetingOnly] && indexPath.section == ROW_INDEX_FOR_NOWSWITHCH) {//开关SECTION
		UILabel *temp_cellTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(CELL_TITLE_LABEL_START_X,
																				CELL_TITLE_LABEL_START_Y, 
																				CELL_TITLE_LABEL_WIDTH, 
																				CELL_TITLE_LABEL_HEIGHT)];
		temp_cellTitleLabel.backgroundColor = [UIColor clearColor];
		temp_cellTitleLabel.text =  @"Now";
		temp_cellTitleLabel.font = [UIFont systemFontOfSize:FONTSIZE_TBV_GROUP_CONTENT];
		temp_cellTitleLabel.textColor = [UIColor blackColor];
        temp_cellTitleLabel.highlightedTextColor = [UIColor blackColor];
		[self.timeSwitch addTarget:self action:@selector(switchAction) forControlEvents:UIControlEventValueChanged];
		[cell.contentView addSubview:temp_cellTitleLabel];
		cell.accessoryView = self.timeSwitch;
        //[cell.contentView addSubview:timeSwitch];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}else{//开始时间和会议时长SECTION
		UILabel *temp_cellTitleLabel = [[UILabel alloc]initWithFrame:CGRectZero];
		temp_cellTitleLabel.backgroundColor = [UIColor clearColor];
		temp_cellTitleLabel.font = [UIFont systemFontOfSize:FONTSIZE_TBV_GROUP_CONTENT];
		temp_cellTitleLabel.textColor = [UIColor grayColor];
		temp_cellTitleLabel.highlightedTextColor = [UIColor grayColor];
		temp_cellTitleLabel.textAlignment = NSTextAlignmentLeft;
        CGSize titleSize1 = [@"ConfTime" sizeWithMyFont:[UIFont systemFontOfSize:FONTSIZE_TBV_GROUP_CONTENT]
                                                                 constrainedToSize:CGSizeMake(300, 44)
                                                                     lineBreakMode:NSLineBreakByWordWrapping];
        
        CGSize titleSize2 = [@"ConfDuration" sizeWithMyFont:[UIFont systemFontOfSize:FONTSIZE_TBV_GROUP_CONTENT]
                                                                             constrainedToSize:CGSizeMake(300, 44)
                                                                                 lineBreakMode:NSLineBreakByWordWrapping];
		CGFloat width = MAX(titleSize1.width, titleSize2.width);
		temp_cellTitleLabel.frame = CGRectMake(CELL_TITLE_LABEL_START_X, CELL_TITLE_LABEL_START_Y, width, CELL_TITLE_LABEL_HEIGHT);
        CGFloat contentLabelX = CGRectGetMaxX(temp_cellTitleLabel.frame) + 10;
		UILabel *temp_cellContentLabel = [[UILabel alloc]initWithFrame:CGRectMake(contentLabelX,
																				  CELL_TITLE_LABEL_START_Y, 
																				  CGRectGetWidth(tableView.bounds) - contentLabelX - 10,
																				  CELL_TITLE_LABEL_HEIGHT)];
		temp_cellContentLabel.backgroundColor = [UIColor clearColor];
		temp_cellContentLabel.font = [UIFont systemFontOfSize:FONTSIZE_TBV_GROUP_CONTENT];
        temp_cellContentLabel.textColor = [UIColor blackColor];
		temp_cellContentLabel.highlightedTextColor = [UIColor blackColor];
        temp_cellContentLabel.textAlignment = NSTextAlignmentRight;
		cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        
		if (indexPath.row == ROW_INDEX_FOR_STARTTIME) {
			temp_cellTitleLabel.text = @"ConfTime";
			
			NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
			
			[dateFormatter setDateFormat:@"yyyy/MM/dd EEE HH:mm"];

			temp_cellContentLabel.text = [self beginTimeStringFormat:self.beginTimeDate];
			
			[cell.contentView addSubview:temp_cellTitleLabel];
			[cell.contentView addSubview:temp_cellContentLabel];
		}
		else if (indexPath.row == ROW_INDEX_FOR_DURATION) {
			temp_cellTitleLabel.text = @"ConfDuration";
			
			NSString *temp_timeString = @"", *temp_timeHourString= @"", *temp_timeMinuteString = @"";
			if ((NSInteger)self.lastsTimeInterval >= 3600)
			{
				temp_timeHourString = [NSString stringWithFormat:@"%ld hour(s)",(long)self.lastsTimeInterval/3600];
			}
			
			if ((NSInteger)self.lastsTimeInterval%3600/60 > 0)
			{
				temp_timeMinuteString = [NSString stringWithFormat:@"%ld min(s)",(long)self.lastsTimeInterval%3600/60];
			}
			
			temp_timeString = [temp_timeHourString stringByAppendingString:temp_timeMinuteString];
			
			temp_cellContentLabel.text = temp_timeString;
			[cell.contentView addSubview:temp_cellTitleLabel];
			[cell.contentView addSubview:temp_cellContentLabel];
		}
	}
//	[cell setCellCornerInTableView:tableView ForRowAtIndexPath:indexPath];
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.timeChooseTableView deselectRowAtIndexPath:indexPath animated:YES];
    if ([self styleForSheduledMeetingOnly]
        || ([self styleForSheduledMeetingOnly]==NO && indexPath.section==SECTION_INDEX_OF_TIMEANDDURATION_FOR_BOTH_STYLE)) {
        
        if (!self.shadowView) {
			[self loadPickerShadowPic];
		}
		if(indexPath.row == ROW_INDEX_FOR_STARTTIME) {
			if (!self.beginTimePicker) {
				[self loadBeginTimeDatePicker];
			}
			[self hiddenOrShowDatePicker:YES picker:_beginTimePicker];
		}
		else if (indexPath.row == ROW_INDEX_FOR_DURATION) {
			if (!self.lastsTimePicker) {
				[self loadLastsTimeDatePicker];
			}
			[self hiddenOrShowDatePicker:YES picker:_lastsTimePicker];
		}
    }
}

//**************** modified by k00228462 for iOS6 **********************
//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//	
//	if(section == 0)
//	{
//		tableView.sectionHeaderHeight = 10;
//		UIView *firstHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 10)];
//		firstHeaderView.backgroundColor = [UIColor clearColor];
//		return [firstHeaderView autorelease];
//	}
//	tableView.sectionHeaderHeight = 5;
//	return nil;
//}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	if(section == 0) {
        return DEFAULT_HEIGHT_FOR_HEADER_IN_SECTION*2;
	}else {
        return DEFAULT_HEIGHT_FOR_HEADER_IN_SECTION;
    }
}
//**************** modified by k00228462 for iOS6 **********************
@end
