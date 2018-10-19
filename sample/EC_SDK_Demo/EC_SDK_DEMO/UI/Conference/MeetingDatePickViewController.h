//
//  MeetingDatePickViewController.h
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

#import <UIKit/UIKit.h>
//#import "ViewController.h"
@class MeetingDatePickViewController;
@protocol MeetingDatePickerViewControllerDelegate<NSObject>

- (void) datePickerViewController:(MeetingDatePickViewController*)ctrl
               didSelectBeginTime:(NSDate *)date
                        lastsTime:(NSTimeInterval)lastsTime
                      immediately:(BOOL)boolValue;

@end


@interface MeetingDatePickViewController : UIViewController <UITableViewDelegate,
                                                             UITableViewDataSource>

+ (NSDate *)startDate;

//初始化方法，beginTime为会议开始时间参数，lastsTime为会议持续时间参数

- (id)initWithDelegate:(id)delegate
             BeginTime:(NSDate *)beginTime
             lastsTime:(NSTimeInterval)lastsTime
         isImmediately:(BOOL)bNow;


@end

