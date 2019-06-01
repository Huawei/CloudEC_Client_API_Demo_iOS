//
//  TUPIOSSDKService.m
//  TUPIOSSDK
//
//  Created on 3/25/17.
//  Copyright © 2017 Huawei Tech. Co., Ltd. All rights reserved.
//

#import "TUPIOSSDKService.h"

//#import "ECSNetworkService.h"
//#import "TUPMediatorSDK.h"
//#import "tup_service_interface.h"
//#import "ECSTUPServiceSDKCommonDefine.h"
#import "ECSSandboxHelper.h"
//#import "call_interface.h"
//#import "call_advanced_interface.h"
#import "ECSAppConfig.h"

@implementation TUPIOSSDKService

+ (void)start
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
//        TUP_RESULT result = tup_service_startup(NULL);
//        DUMP_TUP_API_EXECUTED_RESULT(tup_service_startup, result);
//        [[ECSNetworkService sharedInstance] start];
//        [[TUPMediator sharedInstance] startBusinessService];
        
        [TUPIOSSDKService setTupLog:[ECSAppConfig sharedInstance].isLogEnabled];
    });
}

+ (void)setTupLog:(BOOL) isLoggerOn{
//    NSString *tupCallLogPath = [[ECSSandboxHelper shareInstance].logFilePath stringByAppendingPathComponent:@"tuplog/call"];
//    TUP_INT32 loglevel = 0;
//    TUP_INT32 hmeLogSize = 10;
//    // level : 0 error,1 warning, 2 info , 3 debug
//    //hme日志建议开的时候使用50MB大小，关的时候使用10MB大小
//    if (isLoggerOn)
//    {
//        loglevel = 3;
//        hmeLogSize = 50;
//    }
//    //打开日志默认使用3，即debug级别，5MB的大小，日志文件
//    tup_call_log_start(loglevel, 5*1024, 2, (TUP_CHAR*)[tupCallLogPath UTF8String]);
//    tup_call_hme_log_info(loglevel, hmeLogSize, loglevel, hmeLogSize);
//    //SDK_INFO_LOG("TUP Param Config tup_call_log_start, level is"<<loglevel);
//    //SDK_INFO_LOG("TUP Param Config tup_call_hme_log_info, level is"<<loglevel);
}

@end
