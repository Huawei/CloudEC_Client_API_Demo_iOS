//
//  UmEntity.h
//
//  Created on 3/16/15.
//  Copyright (c) 2017 Huawei Tech. Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CircleSessionEntity;

@interface UmEntity : NSManagedObject

@property (nonatomic, retain) NSString * bodyRef;
@property (nonatomic, retain) NSString * remark;
@property (nonatomic, retain) NSDate * timestamp;
@property (nonatomic, retain) CircleSessionEntity *partOf;
@property (nonatomic, retain) NSNumber* status;

@end
