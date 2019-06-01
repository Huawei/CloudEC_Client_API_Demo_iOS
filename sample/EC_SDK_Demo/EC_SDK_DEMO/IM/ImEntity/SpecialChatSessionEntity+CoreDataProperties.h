//
//  SpecialChatSessionEntity+CoreDataProperties.h
//
//  Created on 15/11/14.
//  Copyright © 2017年 Huawei Tech. Co., Ltd. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "SpecialChatSessionEntity.h"

NS_ASSUME_NONNULL_BEGIN

@interface SpecialChatSessionEntity (CoreDataProperties)
/**
 *  [en]
 *  [cn]处理批量消息时的最后一条记录显示问题
 *
 *  @param values 批量消息
 */
- (void)updateLastMessage:(NSSet *)values;
@end

NS_ASSUME_NONNULL_END
