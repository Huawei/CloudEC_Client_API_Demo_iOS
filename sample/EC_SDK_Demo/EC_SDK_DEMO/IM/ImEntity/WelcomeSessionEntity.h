//
//  WelcomeSessionEntity.h
//  eSpace
//
//  Created on 15/7/20.
//  Copyright (c) 2015年 www.huawei.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "SessionEntity.h"


@interface WelcomeSessionEntity : SessionEntity

@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * detail;

@end
