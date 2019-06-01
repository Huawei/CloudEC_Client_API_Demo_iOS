//
//  CallContactEntity.h
//
//  Created on 7/31/15.
//  Copyright (c) 2017 Huawei Tech. Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "ContactEntity.h"


@interface CallContactEntity : ContactEntity

@property (nonatomic, retain) NSString * phoneNumber;
- (BOOL)isEqualToContact:(CallContactEntity *)c;
@end