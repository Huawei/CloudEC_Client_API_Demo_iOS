//
//  ConfDetailViewController.h
//  TUP_Mobile_Conference_Demo
//
//  Created by lwx308413 on 17/1/14.
//  Copyright © 2017年 huawei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TUPService.h"
#import "ECConfInfo.h"
@class MeetingViewController;
@interface ConfDetailViewController : UIViewController
@property (nonatomic, strong)ECConfInfo *confInfo;
@property (nonatomic, strong)MeetingViewController *meetingVc;
@end
