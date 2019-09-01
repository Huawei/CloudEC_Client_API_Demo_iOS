//
//  SVCConfWatchAttendeeInfo.h
//  EC_SDK_DEMO
//
//  Created by huawei on 2019/8/26.
//  Copyright © 2019年 cWX160907. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Defines.h"

NS_ASSUME_NONNULL_BEGIN

@interface SVCConfWatchAttendeeInfo : NSObject

@property (nonatomic, copy) NSString *name;  //与会者名字
@property (nonatomic, copy) NSString *number; //与会者号码
@property (nonatomic, assign) NSInteger label; //label
@property (nonatomic, assign) CONFCTRL_CONF_ROLE role; //与会者角色

@end

NS_ASSUME_NONNULL_END
