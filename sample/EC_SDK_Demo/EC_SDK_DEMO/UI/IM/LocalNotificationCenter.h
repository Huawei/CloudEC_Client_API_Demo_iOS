//
//  LocalNotificationCenter.h
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

#import <Foundation/Foundation.h>

@interface LocalNotificationCenter : NSObject

+ (instancetype)sharedInstance;

- (void)start;

@end
