//
//  SelectedTime.h
//  TUP_Mobile_Conference_Demo
//
//  Created by lwx308413 on 17/1/12.
//  Copyright © 2017年 huawei. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SelectedTimeViewDelegate <NSObject>

-(void)returnCurrentSelectedTime:(NSDate *)time;

@end

@interface SelectedTimeView : UIView
//+(instancetype)sharedInstance;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (assign, nonatomic)id<SelectedTimeViewDelegate> delegate;
+(void)showSelectedView:(UIView *)supView delegate:(id)delegate;
@end
