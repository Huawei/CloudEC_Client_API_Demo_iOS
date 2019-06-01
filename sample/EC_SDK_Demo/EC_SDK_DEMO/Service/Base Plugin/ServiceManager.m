//
//  ServiceManager.m
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

#import "ServiceManager.h"
#import "Initializer.h"
#import "ManagerService.h"
#import "LoginCenter.h"
#import "ESpaceContactService.h"

@implementation ServiceManager

/**
 This method is used to start tup service
 加载tup组件
 */
+ (void)startup
{
    [ManagerService loadAllService];
    [LoginCenter sharedInstance];
    [ESpaceContactService sharedInstance];
    NSString *logPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingString:@"/TUPC60log"];
    [Initializer startupWithLogPath:logPath];
}

@end
