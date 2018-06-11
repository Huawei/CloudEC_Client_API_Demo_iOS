//
//  ServiceManager.h
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

#import <Foundation/Foundation.h>
#import "ManagerService.h"

@interface ServiceManager : NSObject

/**
 This method is used to start tup service
 加载tup组件
 */
+ (void)startup;

@end
