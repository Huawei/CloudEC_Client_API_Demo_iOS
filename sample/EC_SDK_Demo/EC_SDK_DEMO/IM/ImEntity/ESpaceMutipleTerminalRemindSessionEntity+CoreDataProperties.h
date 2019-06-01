//
//  ESpaceMutipleTerminalRemindSessionEntity+CoreDataProperties.h
//
//  Created on 16/8/3.
//  Copyright © 2017年 Huawei Tech. Co., Ltd. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "ESpaceMutipleTerminalRemindSessionEntity.h"

NS_ASSUME_NONNULL_BEGIN

@interface ESpaceMutipleTerminalRemindSessionEntity (CoreDataProperties)

- (void)chooseOrCancleStick:(void (^)(NSError* error,NSInteger priorityNum)) completionBlock;

@end

NS_ASSUME_NONNULL_END
