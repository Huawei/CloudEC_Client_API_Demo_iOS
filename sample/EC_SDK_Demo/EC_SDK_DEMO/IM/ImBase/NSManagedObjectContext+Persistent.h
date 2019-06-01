/**
 * @file NSManagedObjectContext+Persistent.h
 *
 * Copyright © 2017 Huawei Tech. Co., Ltd. All rights reserved. \n
 *
 * @brief [en]Description:manage object class head file.
 * [cn]描述：管理对象类头文件。 \n
 **/

#import <CoreData/CoreData.h>

/**
 * [en] This class is about managed object.
 * [cn] 管理对象类
 **/
@interface NSManagedObjectContext (Persistent)

/**
 * @brief [en] This method is used to coreData async saved.
 *        <br>[cn] coreData异步保存
 *
 * @attention [en] NA.
 *            <br>[cn] NA
 * @see NA
 **/
- (void) saveToPersistent;

/**
 * @brief [en] This method is used to coreData sync saved.
 *        <br>[cn] coreData同步保存
 *
 * @attention [en] NA.
 *            <br>[cn] NA
 * @see NA
 **/
- (void) saveToPersistentAndWait;

@end
