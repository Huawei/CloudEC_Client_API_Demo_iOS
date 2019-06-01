//
//  MsgLogSessionEntity.h
//
//  Created on 15/9/2.
//  Copyright (c) 2017年 Huawei Tech. Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "SessionEntity.h"

@class ContactEntity;

@interface MsgLogSessionEntity : SessionEntity

@property (nonatomic, retain) NSNumber * logTotalCount;
@property (nonatomic, retain) ContactEntity *target;

@end
