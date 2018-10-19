//
//  NoDistorbViewController.h
//  TUP_Mobile_Demo
//
//  Created by tupservice on 2017/10/31.
//  Copyright © 2017年 cWX160907. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NoDisturbViewController : UIViewController

- (id)initWithPushConfig:(BOOL)enablePush noPushStart:(NSString *)beginTime noPushEnd:(NSString *)endTime timeEnable:(BOOL)timeEnable;

@end
