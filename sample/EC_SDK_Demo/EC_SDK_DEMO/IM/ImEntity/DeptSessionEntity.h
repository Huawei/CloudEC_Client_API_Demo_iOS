//
//  DeptSessionEntity.h
//
//  Created on 15/9/7.
//  Copyright (c) 2017年 Huawei Tech. Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "SessionEntity.h"


@interface DeptSessionEntity : SessionEntity

@property (nonatomic, retain) NSString * name;

@property (nonatomic, assign) NSNumber* deptLogTotalCount;

@end
