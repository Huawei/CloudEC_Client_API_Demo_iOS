//
//  PublicAccountEntity.h
//
//  Created on 15/7/9.
//  Copyright (c) 2017年 Huawei Tech. Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "ContactEntity.h"

@class PublicAccountMenuEntity;
@class PublicAccountHistorySessionEntity;

@interface PublicAccountEntity : ContactEntity

@property (nonatomic, retain) NSNumber * isAuth;
@property (nonatomic, retain) NSNumber * isSubscription;
@property (nonatomic, retain) NSNumber * isSupportPush;
@property (nonatomic, retain) NSNumber * mode;
@property (nonatomic, retain) NSNumber * accountEntity;
@property (nonatomic, retain) NSNumber * state;
@property (nonatomic, retain) NSString * summary;
@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) NSNumber * disPosition;
@property (nonatomic, retain) NSSet *ownMenus;

@property (nonatomic, retain) PublicAccountHistorySessionEntity *paHistorySession;

@end

@interface PublicAccountEntity (CoreDataGeneratedAccessors)

- (void)addOwnMenusObject:(PublicAccountMenuEntity *)value;
- (void)removeOwnMenusObject:(PublicAccountMenuEntity *)value;
- (void)addOwnMenus:(NSSet *)values;
- (void)removeOwnMenus:(NSSet *)values;

@end
