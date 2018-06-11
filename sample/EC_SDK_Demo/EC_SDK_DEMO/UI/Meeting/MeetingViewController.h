//
//  MeetingViewController.h
//  TUPDemo
//
//  Created by lwx308413 on 16/8/9.
//  Copyright © 2016年 huawei. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ECConfInfo;
@interface MeetingViewController : UIViewController

@property (nonatomic, strong)ECConfInfo *selectedConfInfo;
-(void)callTransToConf:(NSString *)confId;
@end
