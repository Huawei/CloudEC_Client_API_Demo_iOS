/**
 * @file TUPIOSSDKService.h
 *
 * Copyright © 2017 Huawei Tech. Co., Ltd. All rights reserved. \n
 *
 * @brief [en]Description:server start class head file.
 * [cn]描述：服务器启动类头文件。 \n
 **/

#import <Foundation/Foundation.h>

/**
 * [en] This class is about starting sdk service.
 * [cn] 启动sdk服务类
 **/
@interface TUPIOSSDKService : NSObject


/**
 * @brief [en] This method is used to start sdk service.
 *        <br>[cn] 启动sdk业务
 *
 * @attention [en] sdk service start method, it need start when application start.
 *            <br>[cn] sdk业务启动方法，程序启动后需立刻启用
 * @see NA
 **/
+ (void)start;

@end
