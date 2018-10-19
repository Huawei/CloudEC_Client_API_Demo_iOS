//
//  AddAttendeeViewController.m
//  TUP_Mobile_Conference_Demo
//
//  Created by lwx308413 on 17/1/12.
//  Copyright © 2017年 huawei. All rights reserved.
//

#import "AddAttendeeViewController.h"
#import "TUPLoginInfo.h"
#import "SelectedTimeView.h"
#import "ConfAttendee.h"

@interface AddAttendeeViewController ()<SelectedTimeViewDelegate,UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITextField *attendeeSipNumTextFiled;
@property (weak, nonatomic) IBOutlet UITableView *attendeeListTableView;
@property (strong, nonatomic) NSMutableArray *attendeeListArray;
@end

@implementation AddAttendeeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.attendeeListTableView.delegate = self;
    self.attendeeListTableView.dataSource = self;
    self.attendeeListTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    _attendeeListArray = [[NSMutableArray alloc] init];
    NSArray *array = [[TUPService callService].sipAccount componentsSeparatedByString:@"@"];
    NSString *shortSipNum = array[0];
    [_attendeeListArray addObject:shortSipNum];
    [self.attendeeListTableView reloadData];
    UITapGestureRecognizer *tableViewGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tableViewTouchInSide)];
    tableViewGesture.numberOfTapsRequired = 1;
    tableViewGesture.cancelsTouchesInView = NO;
    [self.attendeeListTableView addGestureRecognizer:tableViewGesture];
}

- (void)tableViewTouchInSide
{
    [self.view endEditing:YES];
}

- (IBAction)closeButtonAction:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)addButtonAction:(id)sender
{
    [self.view endEditing:YES];
    if (_attendeeSipNumTextFiled.text.length == 0)
    {
        [self showMessage:@"Attendee number can't be empty"];
        return;
    }
    NSString *sipAccount = [TUPService callService].sipAccount;
    NSArray *array = [sipAccount componentsSeparatedByString:@"@"];
    NSString *shortSipNum = array[0];
    if ([sipAccount isEqualToString:_attendeeSipNumTextFiled.text] || [shortSipNum isEqualToString:_attendeeSipNumTextFiled.text])
    {
        [self showMessage:@"You have been in the attendee list"];
        return;
    }
    
    NSMutableArray *tempArray = [[NSMutableArray alloc] initWithArray:_attendeeListArray];
    for (NSString *temp in tempArray)
    {
        if ([temp isEqualToString:_attendeeSipNumTextFiled.text])
        {
            [self showMessage:@"The attendee have been in the attendee list"];
            return;
        }
    }
    [self.attendeeListArray addObject:_attendeeSipNumTextFiled.text];
    _attendeeSipNumTextFiled.text = @"";
    [self.attendeeListTableView reloadData];
}


- (IBAction)okButtonAction:(id)sender
{
    if (!_isBookConf)
    {
        [[TUPService confService] createConferenceWithAttendee:[self obtainFinialAttendeeArray] mediaType:_confMediaType];
        [self dismissViewControllerAnimated:YES completion:nil];
        return;
    }
    [SelectedTimeView showSelectedView:self.view delegate:self];
}

-(NSArray *)obtainFinialAttendeeArray
{
    TUPLoginInfo *mine = [[TUPService loginService] obtainCurrentLoginInfo];
    NSString *sipAccount = [TUPService callService].sipAccount;
    NSArray *array = [sipAccount componentsSeparatedByString:@"@"];
    NSString *shortSipNum = array[0];
    NSMutableArray *attendeeArray = [[NSMutableArray alloc] init];
    for (NSString *tempAccount in _attendeeListArray)
    {
        ConfAttendee *attendee = [[ConfAttendee alloc] init];
        attendee.name = tempAccount;
        attendee.number = tempAccount;
        attendee.type = ATTENDEE_TYPE_NORMAL;
        if ([attendee.number isEqualToString:sipAccount] || [attendee.number isEqualToString:mine.account] || [attendee.number isEqualToString:shortSipNum])
        {
            attendee.role = CONF_ROLE_CHAIRMAN;
        }
        else
        {
            attendee.role = CONF_ROLE_ATTENDEE;
        }
        [attendeeArray addObject:attendee];
    }
    return [NSArray arrayWithArray:attendeeArray];
}

-(void)returnCurrentSelectedTime:(NSDate *)time
{
    if (!time)
    {
        [self showMessage:@"You not select time"];
        return;
    }
    NSDate *selectedTime = time;
    NSDateFormatter *dateFor = [[NSDateFormatter alloc]init];
    dateFor.dateFormat = @"yyyy-MM-dd HH:mm";
    if ([[NSDate date] isEqualToDate:selectedTime])
    {
        [self showMessage:@"Can not select current time"];
        return;
    }
    if ([selectedTime isEqualToDate: [selectedTime earlierDate:[NSDate date]]])
    {
        [self showMessage:@"Can not select earlier than current date"];
        return;
    }
    [[TUPService confService] bookConferenceWithAttendee:[self obtainFinialAttendeeArray] mediaType:_confMediaType startTime:time];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _attendeeListArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    cell.textLabel.text = _attendeeListArray[indexPath.row];
    return cell;
}


- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Attendee List :";
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.view endEditing:YES];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        if (![[TUPService callService].sipAccount isEqualToString:_attendeeListArray[indexPath.row]])
        {
            [_attendeeListArray removeObject:_attendeeListArray[indexPath.row]];
        }
        else
        {
            [self showMessage:@"You must be join the conference"];
        }
    }
    [tableView reloadData];
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
