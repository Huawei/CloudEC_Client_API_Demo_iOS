/**
 * @file eSpaceDBService.h
 *
 * Copyright © 2017年 Huawei Tech. Co., Ltd. All rights reserved. \n
 *
 * @brief [en]Description:local database manage head file.
 * [cn]描述：本地数据库管理头文件。 \n
 **/


#import <UIKit/UIKit.h>
#import "ESpaceLocalDataManager.h"

#define LOCAL_DATA_MANAGER [eSpaceDBService sharedInstance].localDataManager

/**
 * [en] This class is about local database manager.
 * [cn] 本地数据库管理
 **/
@interface eSpaceDBService : NSObject

@property (nonatomic, strong) ESpaceLocalDataManager *localDataManager;

/**
 * @brief [en] This method is used to get instance object.
 *        <br>[cn] 获取单例对象
 *
 * @retval instancetype                           <b>:</b><br>[en] Return an instance object.
 *                                                        <br>[cn] 返回一个单例对象
 * @attention [en] NA.
 *            <br>[cn] NA
 * @see NA
 **/
+ (instancetype)sharedInstance;
@end
