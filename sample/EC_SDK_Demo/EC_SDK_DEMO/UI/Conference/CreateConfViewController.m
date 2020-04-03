//
//  CreateConfViewController.m
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//
#import <objc/message.h>
#import "CreateConfViewController.h"
#import "CreateConfTypeChooseViewController.h"
#import "ManagerService.h"
#import "ConfAttendee.h"
#import "LoginInfo.h"
#import "MeetingDatePickViewController.h"
#import "ConfRunningViewController.h"
#import "AttendeeTableView.h"
#import "ConfBaseInfo.h"

#define CELL_TITLE_FONT     [UIFont systemFontOfSize:13]
#define CELL_CONTENT_FONT   [UIFont systemFontOfSize:16]
#define NUMBER_OF_SECTION 3
#define INDEX_OF_CONF_DURATION_CELL 2
#define SUBJECT_MAX_LENGTH  32

@interface ESpaceConfTableViewCell : UITableViewCell
{
@private
    UILabel *_textLabel;
    UILabel *_detailLabel;
    UIImageView *_accessoryView;
    UITextField *_inputTextField;
}
@end

@implementation ESpaceConfTableViewCell

#ifdef DEBUG
- (BOOL)isAccessibilityElement {
    return YES;
}

- (NSString*)accessibilityLabel {
    return @"ESpaceConfTableViewCell";
}
#endif

- (void)layoutSubviews
{
    [super layoutSubviews];
    __weak UITableViewCell *cell = self;
    
    CGSize size = [cell.textLabel.text sizeWithAttributes:[NSDictionary dictionaryWithObject:CELL_TITLE_FONT forKey:NSFontAttributeName]];
    size.width = ceilf(size.width);
    size.height = ceilf(size.height);
    
    CGFloat width = size.width==0 ? 55 : size.width;
    cell.textLabel.layer.frame = CGRectMake(11, CGRectGetMidY(cell.contentView.frame)-8, width, 16);
    cell.textLabel.font = CELL_TITLE_FONT;
    cell.textLabel.textColor = [UIColor blueColor];
    cell.textLabel.textAlignment = NSTextAlignmentLeft;
    cell.detailTextLabel.font = CELL_CONTENT_FONT;
    cell.detailTextLabel.textColor = [UIColor blackColor];
    CGFloat x = CGRectGetMinX(cell.textLabel.layer.frame) + CGRectGetWidth(cell.textLabel.layer.frame) + 22.5;
    
    cell.detailTextLabel.textAlignment = NSTextAlignmentRight;
    UIImage *image = nil;
    CGFloat maxWidth = CGRectGetMaxX([UIScreen mainScreen].bounds) - 11;
    if (nil != _accessoryView) {
        image = [UIImage imageNamed:@"contact_arrow"];
        _accessoryView.center = CGPointMake(CGRectGetWidth(self.bounds)-13-image.size.width*0.5f,
                                            CGRectGetHeight(self.bounds)*0.5f);
        maxWidth = CGRectGetMinX(_accessoryView.frame);
    }
    CGFloat contentWidth = maxWidth-x;
    if (contentWidth < 100) {
        contentWidth = 100;
    }
    cell.detailTextLabel.layer.frame = CGRectMake(x, CGRectGetMidY(cell.contentView.frame)-15, contentWidth, 30);
    _inputTextField.frame = CGRectMake(x, CGRectGetMidY(cell.contentView.frame)-15, contentWidth, 30);
}

- (UILabel *)detailTextLabel
{
    if (nil == _detailLabel) {
        _detailLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:_detailLabel];
#ifdef DEBUG
        _detailLabel.isAccessibilityElement = YES;
        _detailLabel.accessibilityLabel = @"detailLabel";
#endif
    }
    return _detailLabel;
}

- (UILabel *)textLabel
{
    if (nil == _textLabel) {
        _textLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:_textLabel];
#ifdef DEBUG
        _textLabel.isAccessibilityElement = YES;
        _textLabel.accessibilityLabel = @"textLabel";
#endif
    }
    return _textLabel;
}

- (UITextField *)inputTextField
{
    if (nil == _inputTextField) {
        _inputTextField = [[UITextField alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:_inputTextField];
        //#ifdef DEBUG
        //        _inputTextField.isAccessibilityElement = YES;
        //        _inputTextField.accessibilityLabel = @"inputTextField";
        //#endif
    }
    return _inputTextField;
}

- (void)setAccessoryType:(UITableViewCellAccessoryType)accessoryType
{
    [super setAccessoryType:UITableViewCellAccessoryNone];
    
    if (UITableViewCellAccessoryDisclosureIndicator == accessoryType) {
        if (nil == _accessoryView) {
            UIImage *image = [UIImage imageNamed:@"contact_arrow"];
            _accessoryView = [[UIImageView alloc] initWithImage:image];
            _accessoryView.center = CGPointMake(CGRectGetWidth(self.bounds)-13-image.size.width*0.5f,
                                                CGRectGetHeight(self.bounds)*0.5f);
            [self addSubview:_accessoryView];
#ifdef DEBUG
            _accessoryView.isAccessibilityElement = YES;
            _accessoryView.accessibilityLabel = @"accessoryView";
#endif
        }
    }
    else {
        if (nil != _accessoryView) {
            [_accessoryView removeFromSuperview];
            _accessoryView = nil;
        }
    }
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    [_accessoryView removeFromSuperview];
    _accessoryView = nil;
    
    [_textLabel removeFromSuperview];
    _textLabel = nil;
    
    [_detailLabel removeFromSuperview];
    _detailLabel = nil;
    
    [_inputTextField removeFromSuperview];
    _inputTextField = nil;
}

@end

@implementation TableViewCellModel

- (instancetype)initWithKey:(NSString *)key ConfigureBlock:(SEL)configBlock action:(SEL)action;
{
    if (self = [super init]) {
        self.strKey = key;
        self.configureBlock = configBlock;
        self.selectedAction = action;
    }
    return self;
}

@end

@interface CreateConfViewController ()<UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, CreateConfTypeChooseViewControllerDelegate, ConferenceServiceDelegate, MeetingDatePickerViewControllerDelegate, CreateConfTypeChooseViewControllerDelegate>
{
    NSMutableArray *_selectedAttendeArray;
    NSMutableDictionary *_itemsDicIndexs;
    NSMutableDictionary *_itemModelsDic;
    
    
    BOOL             _isImmediately;
    EC_CONF_MEDIATYPE _confMediaType;
}
@property (nonatomic, copy) NSDate *beginDate;
@property (nonatomic, assign) NSTimeInterval lastInterval;
@property (nonatomic, strong)UITableView *attendeeView;



@end

@implementation CreateConfViewController
@synthesize itemsDicIndexs = _itemsDicIndexs;
@synthesize itemModelsDic = _itemModelsDic;
@synthesize confTypeLabel = _confTypeLabel;
@synthesize confBeginTimeLabel = _confBeginTimeLabel;
@synthesize confTimeIntervalLabel = _confTimeIntervalLabel;
@synthesize selectedNumberLabel = _selectedNumberLabel;
@synthesize confSubjectTextField = _confSubjectTextField;
//@synthesize attendeeCountLabel = _attendeeCountLabel;
//@synthesize attendeeView = _attendeeView;
@synthesize currentCallbackNumber = _currentCallbackNumber;

- (id)init {
    if (self = [super init]) {
        _isImmediately =YES;
        _confMediaType = CONF_MEDIATYPE_VOICE;
        self.selectedAttendeArray = [NSMutableArray array];
        
        [self fillSelfAttendeeInfo];
    }
    return self;
}

-(void)fillSelfAttendeeInfo
{
    LoginInfo *mine = [[ManagerService loginService] obtainCurrentLoginInfo];
    NSArray *array = [mine.account componentsSeparatedByString:@"@"];
    NSString *name = array[0];
    
    ConfAttendee *attendee = [[ConfAttendee alloc] init];
    attendee.name = name;
    attendee.number = [ManagerService callService].terminal;
    attendee.account = mine.account;
    attendee.type = ATTENDEE_TYPE_NORMAL;
    attendee.role = CONF_ROLE_CHAIRMAN;
    [self.selectedAttendeArray addObject:attendee];
}

- (NSMutableDictionary *)itemsDicIndexs
{
    if (nil == _itemsDicIndexs) {
        _itemsDicIndexs = [[NSMutableDictionary alloc] init];
    }
    return _itemsDicIndexs;
}

- (NSMutableDictionary *)itemModelsDic
{
    if (nil == _itemModelsDic) {
        _itemModelsDic = [[NSMutableDictionary alloc] init];
    }
    return _itemModelsDic;
}

- (void)dealloc {
    [self.selectedAttendeArray removeAllObjects];
    [ManagerService confService].delegate = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [_itemModelsDic removeAllObjects];
    [_itemsDicIndexs removeAllObjects];

}

//- (void)setConferenceInfo:(ECCurrentConfInfo *)conferenceInfo
//{
//    if (nil == _conferenceInfo) {
//        return;
//    }
//    _confMediaType = _conferenceInfo.confDetailInfo.media_type;
//
//    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
//    [formatter setDateFormat:@"yyyy/MM/dd  HH:mm"];
//
//    self.beginDate = _conferenceInfo.confDetailInfo.start_time  ? [formatter dateFromString:_conferenceInfo.confDetailInfo.start_time ] : [NSDate date];
//
//    NSTimeInterval timeInterval = [[formatter dateFromString:_conferenceInfo.confDetailInfo.end_time ] timeIntervalSinceDate:[formatter dateFromString:_conferenceInfo.confDetailInfo.start_time ]];
//
//    self.lastInterval = timeInterval > 60 ? timeInterval : self.lastInterval;
//}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [ManagerService confService].delegate = self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor clearColor];
    
    [self configureConfInfoItemsIndexs:(NSMutableDictionary *)self.itemsDicIndexs
                            cellModels:(NSMutableDictionary *)self.itemModelsDic];
    
    [self configureSubviews];
    
    
    
    
    UIButton *createBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 30)];
    [createBtn setTitle:@"Create Meeting" forState:UIControlStateNormal];
    [createBtn addTarget:self action:@selector(createConfEnter) forControlEvents:UIControlEventTouchUpInside];
    //        createBtn.espace_acceptEventInterval = 1.5;
    UIBarButtonItem *creatBtnItem = [[UIBarButtonItem alloc] initWithCustomView:createBtn];
    
    [self.navigationItem setRightBarButtonItems:@[creatBtnItem] animated:NO];
}

- (void)configureSubviews
{
    if (nil == _itemsTable) {
        _itemsTable = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _itemsTable.delegate = self;
        _itemsTable.dataSource = self;
        [_itemsTable registerClass:[ESpaceConfTableViewCell class] forCellReuseIdentifier:@"ESpaceConfTableViewCell"];
    }
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    _itemsTable.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_itemsTable];
    
    id<UILayoutSupport> topGuide = self.topLayoutGuide;
    id<UILayoutSupport> bottomGuide = self.bottomLayoutGuide;
    NSDictionary* views = NSDictionaryOfVariableBindings(_itemsTable, topGuide, bottomGuide);
    NSArray* vconstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[topGuide]-0-[_itemsTable]-0-[bottomGuide]" options:0 metrics:nil views:views];
    NSArray* hconstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_itemsTable]|" options:0 metrics:nil views:views];
    [self.view addConstraints:vconstraints];
    [self.view addConstraints:hconstraints];
    [self.view updateConstraints];
}

- (void)configureConfInfoItemsIndexs:(NSMutableDictionary *)itemsDic
                          cellModels:(NSMutableDictionary *)cellModelsDic;
{
    if (nil == itemsDic
        || ![itemsDic isKindOfClass:[NSMutableDictionary class]]) {
        return;
    }
    
    if (nil == itemsDic
        || ![itemsDic isKindOfClass:[NSMutableDictionary class]]) {
        return;
    }
    
    [self makeItemCellsIndexs:itemsDic];
    [self makeItemCellModelsDic:cellModelsDic];
    
}

/**
 *  建立单元格的cellModel的索引
 *
 *  @param itemsDic 索引字典
 */
- (void)makeItemCellsIndexs:(NSMutableDictionary *)itemsDic
{
    NSUInteger index = 0;
    // SECTION 1
    NSMutableArray *section0 = [NSMutableArray arrayWithObjects:@"ConfSubject", @"ConfTime", @"ConfMediaType", nil];
    if ([self shouldShowConfTimeInterval]) {
        [self insertConfDurationCell:section0];
    }
    [itemsDic setObject:section0 forKey:[NSNumber numberWithUnsignedInteger:index]];
    index++;
    
    // SECTION 2
    if ([self needShowCallBackNumber]) {
        NSMutableArray *section1 = [NSMutableArray arrayWithObjects:@"ConfCallbackNumber", nil];
        [itemsDic setObject:section1 forKey:[NSNumber numberWithUnsignedInteger:index]];
        index++;
    }
    
    // SECTION 3
    if ([self needShowAttendees]) {
        NSMutableArray *section2 = [NSMutableArray arrayWithObjects:@"ConfAttendees", nil];
        [itemsDic setObject:section2 forKey:[NSNumber numberWithUnsignedInteger:index]];
        index++;
    }
    
}

- (BOOL)shouldShowConfTimeInterval
{
    return NO;
}
-(BOOL)needShowAttendees{
    return YES; //创会界面一定显示与会人cell
}

-(BOOL)needShowCallBackNumber{
    return YES; //创会界面一定显示号码选择
}

- (void)insertConfDurationCell:(NSMutableArray *)sectionArray
{
    NSString *strKey = @"ConfDuration";
    if (sectionArray.count > INDEX_OF_CONF_DURATION_CELL) {
        if ([strKey isEqualToString:sectionArray[INDEX_OF_CONF_DURATION_CELL]]) {
            DDLogInfo(@"%@ tableViewCell is already existed!", strKey);
            return;
        }
    }
    [sectionArray insertObject:@"ConfDuration" atIndex:INDEX_OF_CONF_DURATION_CELL];
}

- (void)makeItemCellModelsDic:(NSMutableDictionary *)itemsDic
{
    TableViewCellModel *cellModel0 = [[TableViewCellModel alloc] initWithKey:@"ConfSubject"
                                                                          ConfigureBlock:@selector(configureConfSubjectCell:forKey:)
                                                                                  action:nil];
    [itemsDic setObject:cellModel0 forKey:cellModel0.strKey];
    
    
    TableViewCellModel *cellModel1 = [[TableViewCellModel alloc] initWithKey:@"ConfTime"
                                                                          ConfigureBlock:@selector(configureConfTimeCell:forKey:)
                                                                                  action:@selector(showConfTimeSelectionView)];
    [itemsDic setObject:cellModel1 forKey:cellModel1.strKey];
    
    
    TableViewCellModel *cellModel2 = [[TableViewCellModel alloc] initWithKey:@"ConfMediaType"
                                                                          ConfigureBlock:@selector(configureConfMediaTypeCell:forKey:)
                                                                                  action:@selector(showConfTypeChoosingView)];
    [itemsDic setObject:cellModel2 forKey:cellModel2.strKey];
    
    
    TableViewCellModel *cellModel3 = [[TableViewCellModel alloc] initWithKey:@"ConfDuration"
                                                                          ConfigureBlock:@selector(configureConfDurationCell:forKey:)
                                                                                  action:@selector(showConfTimeSelectionView)];
    [itemsDic setObject:cellModel3 forKey:cellModel3.strKey];
    
    
    TableViewCellModel *cellModel4 = [[TableViewCellModel alloc] initWithKey:@"ConfCallbackNumber"
                                                                          ConfigureBlock:@selector(configureConfCallbackNumberCell:forKey:)
                                                                                  action:nil];
    [itemsDic setObject:cellModel4 forKey:cellModel4.strKey];
    
    TableViewCellModel *cellModel5 = [[TableViewCellModel alloc] initWithKey:@"ConfAttendees"
                                                                          ConfigureBlock:@selector(configureConfAttendeesCell:forKey:)
                                                                                  action:@selector(showConfMembersList)];
    [itemsDic setObject:cellModel5 forKey:cellModel5.strKey];
    
}

/******************************cell configuration begin***********************************/
- (void)configureConfSubjectCell:(UITableViewCell *)cell forKey:(NSString *)str
{
    cell.textLabel.text = str;
    cell.textLabel.font = CELL_TITLE_FONT;
    cell.textLabel.textColor = [UIColor blackColor];
    cell.textLabel.frame = CGRectMake(9, CGRectGetMinY(cell.textLabel.frame), 55, CGRectGetHeight(cell.textLabel.frame));
    cell.textLabel.textAlignment = 0;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    BOOL bNeedSetConfSubject = YES; // 是否需要自动填充会议主题
    ESpaceConfTableViewCell *confCell = (ESpaceConfTableViewCell *)cell;
    // 这里看不懂就去写安卓吧。
    // 成员变量|_confSubjectTextField|为nil的情况下，说明是首次加载table，所以需要自动填充会议主题
    // 如果此变量为非nil，则说明是非首次加载table，因此不需要再次自动填充会议主题。
    if (nil != _confSubjectTextField) {
        bNeedSetConfSubject = NO;
        confCell.inputTextField.text = _confSubjectTextField.text;
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:_confSubjectTextField];
    }
    _confSubjectTextField = confCell.inputTextField;
    _confSubjectTextField.delegate = self;
    
    _confSubjectTextField.backgroundColor = [UIColor clearColor];
    _confSubjectTextField.font = CELL_CONTENT_FONT;
    _confSubjectTextField.textColor = [UIColor blackColor];;
    _confSubjectTextField.placeholder = NSLocalizedString(@"tap_input_theme", @"点击输入会议主题");
    _confSubjectTextField.textAlignment = NSTextAlignmentRight;
    _confSubjectTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateCreateConfButtonStatus) name:UITextFieldTextDidChangeNotification object:_confSubjectTextField];
    [self updateTableViewCellStyle:cell enabled:NO];
    cell.userInteractionEnabled = YES;
    
    if (!bNeedSetConfSubject) {
        return;
    }
    
    _confSubjectTextField.text = [self confDefaultName];
    
}

- (void)updateCreateConfButtonStatus
{
    NSString *strConfSubject = _confSubjectTextField.text;
    if (strConfSubject.length > SUBJECT_MAX_LENGTH) {
        _confSubjectTextField.text = [strConfSubject substringToIndex:SUBJECT_MAX_LENGTH];
    }
    
    self.navigationItem.rightBarButtonItem.enabled = (0 != strConfSubject.length);
}


- (NSString*)confDefaultName
{
    //todo  jinliang
//    NSString *dispName = self.selfInfo.uiDisplayName;
    LoginInfo *mine = [[ManagerService loginService] obtainCurrentLoginInfo];
    NSString *dispName = mine.account;
    NSString *strConfSubject = [NSString stringWithFormat:@"%@'conference",dispName];
    if (strConfSubject.length > SUBJECT_MAX_LENGTH) {
        strConfSubject = [strConfSubject substringToIndex:SUBJECT_MAX_LENGTH];
    }
    return strConfSubject;
}

- (void)updateTableViewCellStyle:(UITableViewCell *)cell enabled:(BOOL)bEnabled
{
    cell.selectionStyle = bEnabled ? UITableViewCellSelectionStyleDefault : UITableViewCellSelectionStyleNone;
    cell.accessoryType = bEnabled ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
    cell.userInteractionEnabled = bEnabled;
}


- (void)configureConfTimeCell:(UITableViewCell *)cell forKey:(NSString *)str
{
//    BOOL bSupportBookConf = [[[ECSAppConfig sharedInstance] currentUser] isSupportFunction:EN_FUNC_CREATE_SCHEDULE_MEETING];
//    BOOL bSupportCTC = [[ECSAppConfig sharedInstance].currentUser isSupportFunction:EN_FUNC_CTC];
//    是否支持预约会议
    BOOL bSupportBookConf = YES;
//    是否支持即时会议
    BOOL bSupportCTC = YES;
    // 如果当前没有即时会议的权限，则现实为预约会议
    if (_isImmediately && !bSupportCTC) {
        _isImmediately = NO;
    }
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy/MM/dd  HH:mm"];
    
    NSString *strConfTime = _isImmediately ? @"Now" : [formatter stringFromDate:self.beginDate];
    cell.detailTextLabel.text = strConfTime;
    _confBeginTimeLabel = cell.detailTextLabel;
    cell.textLabel.text = str;
    [self updateTableViewCellStyle:cell enabled:bSupportBookConf];
}

- (NSString *)beginTimeStringFormat:(NSDate *)beginTime
{
    if (nil == beginTime) {
        DDLogInfo(@"beginTimeStringFormat: nil beginTime");
        return nil;
    }
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
    
    //    int week = [comps weekday];
    NSInteger year =[comps year];
    NSInteger month = [comps month];
    NSInteger day = [comps day];
    NSInteger hour = [comps hour];
    NSInteger min = [comps minute];
    
    NSString *beginTimeDateString = [NSString stringWithFormat:@"%04ld/%02ld/%02ld %02ld:%02ld", (long)year, (long)month,(long)day, (long)hour,(long)min];
    return beginTimeDateString;
}

- (void)showConfTimeSelectionView
{
//    todo jinliang time pickView
    
    MeetingDatePickViewController *ctrl = [[MeetingDatePickViewController alloc] initWithDelegate:self
                                                                                        BeginTime:self.beginDate
                                                                                        lastsTime:self.lastInterval
                                                                                    isImmediately:_isImmediately];
    [self.navigationController pushViewController:ctrl animated:YES];
}

- (void)configureConfMediaTypeCell:(UITableViewCell *)cell forKey:(NSString *)str
{
//    BOOL bSupportMultimediaConf = [[ESpaceService sharedInstance].confService canCreateMultiConf];
    BOOL bSupportMultimediaConf = YES;
    if (!bSupportMultimediaConf) {
        _confMediaType = CONF_MEDIATYPE_VOICE;
    }
    
    cell.detailTextLabel.text = [self mediaTypeDescriptionByConfMediaType:_confMediaType];
    _confTypeLabel = cell.detailTextLabel;
    cell.textLabel.text = str;
    [self updateTableViewCellStyle:cell enabled:bSupportMultimediaConf];
}

- (NSString *)mediaTypeDescriptionByConfMediaType:(EC_CONF_MEDIATYPE)mediaType
{
    NSString *description = @"";
    switch (mediaType) {
        case CONF_MEDIATYPE_VOICE:
            description = @"Voice conference";
            break;
        case CONF_MEDIATYPE_DATA:
            description = @"Data conference";
            break;
        case CONF_MEDIATYPE_VIDEO:
            description = @"Video conference";
            break;
        case CONF_MEDIATYPE_VIDEO_DATA:
            description =@"Video+data conference";
        default:
            break;
    }
    return description;
}


- (void)configureConfDurationCell:(UITableViewCell *)cell forKey:(NSString *)str
{
    cell.detailTextLabel.text = [self stringOfConfTimerInterval:self.lastInterval];
    _confTimeIntervalLabel = cell.detailTextLabel;
    cell.textLabel.text = str;
    [self updateTableViewCellStyle:cell enabled:YES];
}

- (NSString *)stringOfConfTimerInterval:(NSTimeInterval)timeInterval
{
    NSUInteger hours = timeInterval / 3600;
    NSUInteger minutes = ((NSUInteger)timeInterval % 3600) / 60;
    NSString *str = [NSString stringWithFormat:@"%lu%@ %lu%@", (unsigned long)hours, @"hour(s)", (unsigned long)minutes, @"min(s)"];
    return str;
}

- (void)updateJoinConfNumber
{
    NSString *strConfSubject = _selectedNumberLabel.text;
    if (strConfSubject.length > SUBJECT_MAX_LENGTH) {
        _selectedNumberLabel.text = [strConfSubject substringToIndex:SUBJECT_MAX_LENGTH];
    }
    ((ConfAttendee *)_selectedAttendeArray[0]).number = _selectedNumberLabel.text;
    [_attendeeView reloadData];
    self.navigationItem.rightBarButtonItem.enabled = (0 != strConfSubject.length);
}

- (void)configureConfCallbackNumberCell:(UITableViewCell *)cell forKey:(NSString *)str
{
    cell.textLabel.text = str;
    cell.textLabel.font = CELL_TITLE_FONT;
    cell.textLabel.textColor = [UIColor blackColor];
    cell.textLabel.frame = CGRectMake(9, CGRectGetMinY(cell.textLabel.frame), 55, CGRectGetHeight(cell.textLabel.frame));
    cell.textLabel.textAlignment = 0;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    BOOL bNeedSetConfSubject = YES;
    ESpaceConfTableViewCell *confCell = (ESpaceConfTableViewCell *)cell;
    if (nil != _selectedNumberLabel) {
        bNeedSetConfSubject = NO;
        confCell.inputTextField.text = _selectedNumberLabel.text;
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:_selectedNumberLabel];
    }
    _selectedNumberLabel = confCell.inputTextField;
    _selectedNumberLabel.delegate = self;
    
    _selectedNumberLabel.backgroundColor = [UIColor clearColor];
    _selectedNumberLabel.font = CELL_CONTENT_FONT;
    _selectedNumberLabel.textColor = [UIColor blackColor];;
    _selectedNumberLabel.placeholder = @"tap_input_number";
    _selectedNumberLabel.textAlignment = NSTextAlignmentRight;
    _selectedNumberLabel.clearButtonMode = UITextFieldViewModeWhileEditing;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateJoinConfNumber) name:UITextFieldTextDidChangeNotification object:_selectedNumberLabel];
    [self updateTableViewCellStyle:cell enabled:NO];
    cell.userInteractionEnabled = YES;
    
    if (!bNeedSetConfSubject) {
        return;
    }
    
    NSString *shortSipNum = [ManagerService callService].terminal;
    _selectedNumberLabel.text = shortSipNum;
}


- (void)configureConfAttendeesCell:(UITableViewCell *)cell forKey:(NSString *)str
{
    UILabel *attendeeLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, 12, 150, 20)];
    attendeeLabel.font = CELL_TITLE_FONT;
    attendeeLabel.textColor = [UIColor blueColor];
    attendeeLabel.textAlignment = 0;
    attendeeLabel.text = str;
    
    _attendeeCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.bounds.size.width-100-12, 12, 100, 20)];
    _attendeeCountLabel.font = CELL_CONTENT_FONT;
    _attendeeCountLabel.textColor = [UIColor blackColor];
    _attendeeCountLabel.textAlignment = NSTextAlignmentRight;
    _attendeeCountLabel.text = [NSString stringWithFormat:@"%lu person(s)", (unsigned long)self.selectedAttendeArray.count];
    
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(self.view.bounds.size.width-60-12, 40, 60, 30)];
    [button addTarget:self action:@selector(addAttendeeNumber) forControlEvents:UIControlEventTouchUpInside];
//    [button setTitle:@"sure" forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:@"attendee_add_normal"] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//    button.backgroundColor = [UIColor yellowColor];
    
    [cell addSubview:attendeeLabel];
    [cell addSubview:_attendeeCountLabel];
    [cell addSubview:self.attendeeView];
    //[cell addSubview:self.inputNumTextField];
    [cell addSubview:button];
    

    cell.userInteractionEnabled = YES;
}

- (void)addAttendeeNumber
{
    UIAlertController *allertCtrl = [UIAlertController alertControllerWithTitle:@"attendee" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [allertCtrl addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Number";
        textField.secureTextEntry = NO;
    }];
    [allertCtrl addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Name";
        textField.secureTextEntry = NO;
    }];
    [allertCtrl addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Account";
        textField.secureTextEntry = NO;
    }];
    
    UIAlertAction *AlertAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UITextField *numberFiled = allertCtrl.textFields.firstObject;
        UITextField *nameFiled = allertCtrl.textFields[1];
        UITextField *accountField = allertCtrl.textFields[2];
        
        NSString *number = numberFiled.text;
        NSString *name = nameFiled.text;
        NSString *account = accountField.text;
        
        ConfAttendee *attendee = [[ConfAttendee alloc]init];
        attendee.number = number;
        attendee.name = name ? name : number;
        attendee.account = account;
        attendee.type = ATTENDEE_TYPE_NORMAL;
        attendee.role = CONF_ROLE_ATTENDEE;
        if (attendee.number != nil && attendee.number.length > 0) {
            [_selectedAttendeArray addObject:attendee];
            _attendeeCountLabel.text = [NSString stringWithFormat:@"%lu person(s)", (unsigned long)self.selectedAttendeArray.count];
            [_attendeeView reloadData];
        }
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:nil];
    
    [allertCtrl addAction:AlertAction];
    [allertCtrl addAction:cancelAction];
    [self presentViewController:allertCtrl animated:YES completion:nil];
    
//    NSString *attendeeNum = self.inputNumTextField.text;
//    if (attendeeNum.length != 0) {
//        self.inputNumTextField.text = nil;
//        [self.inputNumTextField reloadInputViews];
//        ConfAttendee *attendee = [[ConfAttendee alloc]init];
//        attendee.number = attendeeNum;
//        attendee.name = attendeeNum;
//        attendee.type = ATTENDEE_TYPE_NORMAL;
//        attendee.role = CONF_ROLE_ATTENDEE;
//        [_selectedAttendeArray addObject:attendee];
//        _attendeeCountLabel.text = [NSString stringWithFormat:@"%lu person(s)", (unsigned long)self.selectedAttendeArray.count];
//        [_attendeeView reloadData];
//        [self hideKeyboard];
//    }
}
    

-(UITextField *)inputNumTextField
{
    if (_inputNumTextField == nil) {
        _inputNumTextField = [[UITextField alloc]initWithFrame:CGRectMake(12, 40, self.view.bounds.size.width - 100 , 30)];
        _inputNumTextField.delegate = self;
        _inputNumTextField.backgroundColor = [UIColor clearColor];
        _inputNumTextField.font = CELL_CONTENT_FONT;
        _inputNumTextField.textColor = [UIColor blackColor];;
        _inputNumTextField.placeholder = NSLocalizedString(@"tap_input_number", @"添加与会者号码");
        _inputNumTextField.textAlignment = NSTextAlignmentLeft;
        _inputNumTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _inputNumTextField.layer.borderWidth = 1.0;
        _inputNumTextField.layer.borderColor = [[UIColor grayColor] CGColor];
        
    }
    return _inputNumTextField;
}

-(UITableView *)attendeeView
{
    if (_attendeeView == nil) {
        _attendeeView = [[UITableView alloc]initWithFrame:CGRectMake(12, 75, self.view.bounds.size.width - 12*2, 100)];
        _attendeeView.backgroundColor = [UIColor clearColor];
        [_attendeeView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
        _attendeeView.delegate = self;
        _attendeeView.dataSource = self;
        _attendeeView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _attendeeView;
}

- (void)showConfTypeChoosingView
{
//    //EC6.0的MediaX组网下才支持视频会议的创建
//    BOOL isSupportVideoConf = ([[ManagerService confService] isUportalSMCConf] ||
//                               [[ManagerService confService] isUportalMediaXConf]);
    
    BOOL isSupportVideoConf = YES;

    CreateConfTypeChooseViewController *confTypeChooseCtrl = [[CreateConfTypeChooseViewController alloc]initWithConfMediaType:_confMediaType
        andIsSupportVideoConf:isSupportVideoConf];
    confTypeChooseCtrl.delegate = self;
    [self.navigationController pushViewController:confTypeChooseCtrl animated:YES];
}

- (void)showConfMembersList {
//    [self.attendeeView hasTouched:nil];
}


#pragma mark - UITableView DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView == _itemsTable) {
        return self.itemsDicIndexs.count;
    }else{
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == _itemsTable) {
        NSNumber *index = [NSNumber numberWithInteger:section];
        return ((NSArray *)self.itemsDicIndexs[index]).count;
    }else{
        return _selectedAttendeArray.count;
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //[self configureItemCell:cell atIndexPath:indexPath];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    if (tableView == _itemsTable) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"ESpaceConfTableViewCell"];
        [self configureItemCell:cell atIndexPath:indexPath];
    }else{
        cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
        ConfAttendee * attendee = _selectedAttendeArray[indexPath.row];
        NSString *cellString = [NSString stringWithFormat:@"Name:%@ Number:%@ Account:%@",attendee.name, attendee.number, attendee.account];
        cell.textLabel.text = cellString;
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.font = [UIFont systemFontOfSize:12.0];
//        cell.textLabel.text = ((ConfAttendee *)_selectedAttendeArray[indexPath.row]).number;
    }
    return cell;
}

#pragma mark - UITableView Delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == _itemsTable) {
        NSString *str = (NSString *)[self itemKeyAtIndexPath:indexPath];
        if ([str isEqualToString:@"ConfAttendees"]) {
            return 180;
        }
        return 44;
    }else{
        return 30;
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == _itemsTable) {
        [self hideKeyboard];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        TableViewCellModel *cellModel = [self itemModelAtIndexPath:indexPath];
        if (nil == cellModel) {
            return;
        }
        
        if (nil == cellModel.selectedAction) {
            return;
        }
        if ([self respondsToSelector:cellModel.selectedAction]) {
            [self performSelectorOnMainThread:cellModel.selectedAction withObject:nil waitUntilDone:NO];
        }
    }else{
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
    
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == _attendeeView) {
        if (indexPath.row == 0) {
            return NO;
        }
        return YES;
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        [_selectedAttendeArray removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        _attendeeCountLabel.text = [NSString stringWithFormat:@"%lu person(s)", (unsigned long)self.selectedAttendeArray.count];
    }
}

#pragma mark - inner functions
- (TableViewCellModel *)itemModelAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *strKey = (NSString *)[self itemKeyAtIndexPath:indexPath];
    if (nil == strKey) {
        DDLogInfo(@"can not find the Model key for %@", indexPath);
        return nil;
    }
    return [self.itemModelsDic objectForKey:strKey];
}

- (NSString *)itemKeyAtIndexPath:(NSIndexPath *)indexPath
{
    id str = nil;
    NSArray *array = [self.itemsDicIndexs objectForKey:[NSNumber numberWithUnsignedInteger:indexPath.section]];
    if (indexPath.row >= array.count) {
        DDLogInfo(@"index %ld beyond array range!", (long)indexPath.row);
    }
    
    str = [array objectAtIndex:indexPath.row];
    return str;
}

#pragma mark - UIScrollerViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self hideKeyboard];
}

- (void)hideKeyboard
{
    if ([self.confSubjectTextField isFirstResponder]) {
        [self.confSubjectTextField resignFirstResponder];
    }
    if ([self.selectedNumberLabel isFirstResponder]) {
        [self.selectedNumberLabel resignFirstResponder];
    }
    if ([self.inputNumTextField isFirstResponder]) {
        [self.inputNumTextField resignFirstResponder];
    }
}

#pragma mark
- (void)configureItemCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    TableViewCellModel *cellModel = [self itemModelAtIndexPath:indexPath];
    if (nil == cellModel) {
        return;
    }
    
    if ([self respondsToSelector:cellModel.configureBlock]) {
        NSString *strLocalizedKey = self.cellLabelTextDic[cellModel.strKey];
        assert(strLocalizedKey);
        NSString *strLocalized = NSLocalizedString(strLocalizedKey, @"");
        void (*ConfigureCellFunc)(id target, SEL cmd, UITableViewCell *cell, NSString *strKey) = (void*)objc_msgSend;
        ConfigureCellFunc(self, cellModel.configureBlock, cell, strLocalized);
    }
}

- (NSDictionary *)cellLabelTextDic
{
    NSDictionary *dic = @{
                          @"ConfSubject":@"ConfSubject",
                          @"ConfTime":@"ConfTime",
                          @"ConfDuration":@"ConfDuration",
                          @"ConfMediaType":@"ConfMediaType",
                          @"ConfCallbackNumber":@"ConfCallbackNumber",
                          @"ConfAttendees":@"ConfAttendees"
                          };
    
    return dic;
}

- (void)createConfEnter{
    BOOL isCreateConfSuccessed = [[ManagerService confService] createConferenceWithAttendee:_selectedAttendeArray mediaType:_confMediaType subject:self.confSubjectTextField.text startTime:_isImmediately ? nil : self.beginDate confLen:_isImmediately ? 0 : self.lastInterval/60];
    
    if (isCreateConfSuccessed) {
        if (!_isImmediately){
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

-(void)ecConferenceEventCallback:(EC_CONF_E_TYPE)ecConfEvent result:(NSDictionary *)resultDictionary
{
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        switch (ecConfEvent)
        {
            case CONF_E_CREATE_RESULT:
            {
                BOOL result = [resultDictionary[ECCONF_RESULT_KEY] boolValue];
//                ECCurrentConfInfo *currentConfInfo = resultDictionary[ECCONF_BOOK_CONF_INFO_KEY];
                if (!result)
                {
                    [weakSelf showMessage:@"Create conference failed"];
                    return ;
                }
                else {
                    [weakSelf showMessage:@"Create conference success"];
                }
                break;
            }
                
            case CONF_E_ATTENDEE_UPDATE_INFO:
            {
                DDLogInfo(@"CreateConfViewController,CONF_E_ATTENDEE_UPDATE_INFO");
                break;
            }
            case CONF_E_CURRENTCONF_DETAIL:
            {
                BOOL result = [resultDictionary[ECCONF_RESULT_KEY] boolValue];
                if (!result)
                {
                    [weakSelf dismissViewControllerAnimated:YES completion:nil];
                    return;
                }
                break;
            }
                
            default:
                break;
        
        }
    });
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

- (void) datePickerViewController:(MeetingDatePickViewController*)ctrl
               didSelectBeginTime:(NSDate *)date
                        lastsTime:(NSTimeInterval)lastsTime
                      immediately:(BOOL)boolValue
{
    //    [self dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popToViewController:self animated:YES];
    
    self.beginDate = date;
    self.lastInterval = lastsTime;
    
    BOOL bHaveConfTimeIntervalCell = !_isImmediately;
    BOOL bNeedConfTimeIntervalCell = !boolValue;
    _isImmediately = boolValue;
    
    [_itemsTable beginUpdates];
    UITableViewCell *cell1 = (UITableViewCell *)_confBeginTimeLabel.superview.superview;
    NSIndexPath *indexPath1 = [_itemsTable indexPathForCell:cell1];
    NSMutableArray *indexpaths = [NSMutableArray array];
    if (nil != indexPath1) {
        [indexpaths addObject:indexPath1];
    }
    // 插入“会议时长”单元格
    if (!bHaveConfTimeIntervalCell && bNeedConfTimeIntervalCell) {
        NSMutableArray *sectin0 = (NSMutableArray *)self.itemsDicIndexs[@0];
        if (sectin0.count >= 3) {
            [self insertConfDurationCell:sectin0];
            NSIndexPath *path = [NSIndexPath indexPathForRow:INDEX_OF_CONF_DURATION_CELL inSection:0];
            if (nil != path) {
                [_itemsTable insertRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationFade];
            }
        }
    }
    // 删除“会议时长”单元格
    else if (bHaveConfTimeIntervalCell && !bNeedConfTimeIntervalCell) {
        NSMutableArray *sectin0 = (NSMutableArray *)self.itemsDicIndexs[@0];
        if (sectin0.count >= 3) {
            [sectin0 removeObjectAtIndex:INDEX_OF_CONF_DURATION_CELL];
            NSIndexPath *path = [NSIndexPath indexPathForRow:INDEX_OF_CONF_DURATION_CELL inSection:0];
            if (nil != path) {
                [_itemsTable deleteRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationFade];
            }
        }
    }
    else {
        UITableViewCell *cell2 = (UITableViewCell *)_confTimeIntervalLabel.superview.superview;
        NSIndexPath *indexPath2 = [_itemsTable indexPathForCell:cell2];
        if (nil != indexPath2) {
            [indexpaths addObject:indexPath2];
        }
    }
    [_itemsTable reloadRowsAtIndexPaths:indexpaths withRowAnimation:UITableViewRowAnimationFade];
    [_itemsTable endUpdates];
}

#pragma mark - CreateConfTypeChooseViewControllerDelegate

- (void)confMediaTypeSelectedWithConfMediaType:(EC_CONF_MEDIATYPE)selectedMediaType
{
    _confMediaType = selectedMediaType;
    _confTypeLabel.text = [self mediaTypeDescriptionByConfMediaType:selectedMediaType];
}

@end
