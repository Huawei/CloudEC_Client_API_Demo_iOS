//
//  SelectedTime.m
//  TUP_Mobile_Conference_Demo
//
//  Created by lwx308413 on 17/1/12.
//  Copyright © 2017年 huawei. All rights reserved.
//

#import "SelectedTimeView.h"

@interface SelectedTimeView()
@property (nonatomic, strong)NSDate *selectedTime;
@end

@implementation SelectedTimeView

//+(instancetype)sharedInstance
//{
//    static
//}

-(instancetype)init
{
    self = [super init];
    if (self)
    {
        NSArray *xibArray = [[NSBundle mainBundle] loadNibNamed:@"SelectedTimeView" owner:self options:nil];
        self = [xibArray firstObject];
        return self;
    }
    return nil;
}

+(void)showSelectedView:(UIView *)supView delegate:(id)delegate
{
    SelectedTimeView *timeView = [[SelectedTimeView alloc] init];
    timeView.delegate = delegate;
    timeView.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 216, [UIScreen mainScreen].bounds.size.width, 216);
    timeView.datePicker.minimumDate = [NSDate date];
    [supView addSubview:timeView];
}

- (IBAction)closeButtonAction:(id)sender
{
    [self removeFromSuperview];
}

- (IBAction)okButtonAction:(id)sender
{
    [self removeFromSuperview];
    if ([self.delegate respondsToSelector:@selector(returnCurrentSelectedTime:)])
    {
        [self.delegate returnCurrentSelectedTime:_selectedTime];
    }
}

- (IBAction)datePickerValueChangedAction:(id)sender
{
    UIDatePicker *datePicker = sender;
    NSDate *date = datePicker.date;
    _selectedTime = date;
//    NSDateFormatter *dateFor = [[NSDateFormatter alloc]init];
//    dateFor.dateFormat = @"yyyy/MM/dd HH:mm";
//    NSString *dateStr = [dateFor stringFromDate:_selectedTime];
//    NSLog(@"%@",dateStr);
}

@end
