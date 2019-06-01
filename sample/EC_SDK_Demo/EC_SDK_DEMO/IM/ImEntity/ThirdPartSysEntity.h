//
//  ThirdPartSysEntity.h
//
//  Created on 16/4/29.
//  Copyright © 2017年 Huawei Tech. Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ContactEntity.h"

NS_ASSUME_NONNULL_BEGIN

@interface ThirdPartSysEntity : ContactEntity

// Insert code here to declare functionality of your managed object subclass
/**
 *  [en]
 *  [cn]查找指定appID的对象，没有则进行创建
 *
 *  @param appID appID
 *  @param ctx   coredata数据上下文
 *
 *  @return 查询或者创建的对象
 */
+ (ThirdPartSysEntity *)thirdPartySysEntityWith:(NSString *)appID
                                      inContext:(NSManagedObjectContext *)ctx;

/**
 *  [en]
 *  [cn]查找指定的appID对象，没有则返回nil
 *
 *  @param appID appID
 *  @param ctx   coredata数据上下文
 *
 *  @return 查询到的对象
 */
+ (ThirdPartSysEntity *)fetchThirdPartySysEntityWith:(NSString *)appID
                                           inContext:(NSManagedObjectContext *)ctx;
@end

NS_ASSUME_NONNULL_END

#import "ThirdPartSysEntity+CoreDataProperties.h"
