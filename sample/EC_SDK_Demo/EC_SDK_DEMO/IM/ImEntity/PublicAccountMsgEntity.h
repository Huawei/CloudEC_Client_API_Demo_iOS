//
//  PublicAccountMsgEntity.h
//
//  Created on 15/7/27.
//  Copyright (c) 2017年 Huawei Tech. Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "MessageEntity.h"
#import "ChatMessageEntity.h"
@class PublicAccountEntity, PublicAccountMsgItemEntity;

@interface PublicAccountMsgEntity : ChatMessageEntity

@property (nonatomic, retain) NSString * chatID;
@property (nonatomic, retain) NSNumber * publicAccountMsgType;
@property (nonatomic, retain) NSDate * createTime;
@property (nonatomic, retain) NSNumber * publicSource;
@property (nonatomic, retain) NSSet *ownMsgItem;
@end

@interface PublicAccountMsgEntity (CoreDataGeneratedAccessors)

- (void)addOwnMsgItemObject:(PublicAccountMsgItemEntity *)value;
- (void)removeOwnMsgItemObject:(PublicAccountMsgItemEntity *)value;
- (void)addOwnMsgItem:(NSSet *)values;
- (void)removeOwnMsgItem:(NSSet *)values;

@end
