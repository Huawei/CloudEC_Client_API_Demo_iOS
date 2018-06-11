//
//  ECSLogger.h
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

#import <Foundation/Foundation.h>
#import "ECSDDLogMacros.h"

@interface ECSLogger : NSObject
@property ECSDDLogLevel logLevel;

+ (instancetype)shareInstance;
/**
 *This method is used to print current thread invoke stack when service is exception or param is not correspond to suppose
 *  打印当前线程的调用栈, 用于业务异常或者参数与预期不符合时候可以用来打印调用栈, PS：只有日志级别在debug一下才会打印。
 */
+ (void)printDebugStack;

/**
 * This method is used to add UI log print
 *  添加UI日志打印文件
 */
- (void)addFileLogger;
@end
