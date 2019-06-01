//
//  CallSessionEntity.h
//
//  Created on 7/31/15.
//  Copyright (c) 2017 Huawei Tech. Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "SessionEntity.h"

@class ContactEntity;

@interface CallSessionEntity : SessionEntity
@property (nonatomic, retain) ContactEntity * callTarget;
@end
