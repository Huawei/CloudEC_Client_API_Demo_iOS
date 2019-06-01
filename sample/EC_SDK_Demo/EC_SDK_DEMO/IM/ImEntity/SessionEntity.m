//
//  SessionEntity.m
//  eSpaceUI
//
//  Created by yemingxing on 3/13/15.
//  Copyright (c) 2015 www.huawei.com. All rights reserved.
//

#import "SessionEntity.h"
#import "MessageEntity.h"
#import "SessionGroupEntity.h"
#import "NSDate+LocalString.h"
#import "NSManagedObjectContext+Persistent.h"
#import "eSpaceDBService.h"

@implementation SessionEntity

@dynamic timestamp;
@dynamic messages;
@dynamic parent;
@dynamic priority;
@dynamic sessionId;
@dynamic latestMessage;
@dynamic reportUnread;

- (NSNumber *)unreadCount {
    [self willAccessValueForKey:@"unreadCount"];
    NSNumber* number = [self primitiveValueForKey:@"unreadCount"];
    [self didAccessValueForKey:@"unreadCount"];
    return number;
}

- (BOOL) canHide {
    return YES;
}

- (void)localMarkReadAll {
    [self localMarkRead:NO];
}

- (void)localMarkReadAll:(void (^)(NSError* error)) completionBlock {
    NSManagedObjectID* oid = self.objectID;
    ESpaceLocalDataManager * localManager = LOCAL_DATA_MANAGER;
    dispatch_async(espace_coredata_management_queue, ^{
        NSManagedObjectContext* bgCtx = [localManager backgroundObjectContext];
        [bgCtx performBlockAndWait:^{
            SessionEntity* shadow = (SessionEntity*)[bgCtx objectWithID:oid];
            if (shadow && !shadow.isDeleted) {
                [shadow localMarkReadAll];
                [bgCtx saveToPersistent];
            }
            if (completionBlock) {
                completionBlock(nil);
            }
        }];
    });
}

- (void) hide {
    self.priority = [NSNumber numberWithInteger:-1];
    [self localMarkReadAll:nil];
}

- (void) localMarkRead:(BOOL)hide {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"MessageEntity"];
    [request setPredicate:[NSPredicate predicateWithFormat:@"session=%@ AND readed=%@",
                           self, [NSNumber numberWithBool:NO]]];
    
    NSError* queryError = nil;
    NSArray* result = [self.managedObjectContext executeFetchRequest:request error:&queryError];
    if (queryError) {
        return;
    }
    
    for (MessageEntity* msgEntity in result) {
        if ([msgEntity.readed boolValue] == NO) {
            msgEntity.readed = [NSNumber numberWithBool:YES];
        }
    }
    self.unreadCount = [NSNumber numberWithInteger:0];
    if (hide) {
        self.priority = [NSNumber numberWithInteger:-1];
    }
}

- (BOOL) canMarkTop {
    /*
    SessionEntity* session = [self topestSession];

    return session != self;
     */
    return [self.priority integerValue] == 0 || [self.priority integerValue] == -1;
}

- (void) markTop {
    /*
    SessionEntity* session = [self topestSession];
    NSInteger priority = [session.priority unsignedIntegerValue] + 1;
    
    if (priority < 0) {
        priority = 0;
    }
    self.priority = [NSNumber numberWithInteger:priority];
    */
    self.priority = [NSNumber numberWithInteger:1];
    self.timestamp = [NSDate date];
}

- (void)cancelMarkTop {
    self.priority = [NSNumber numberWithInteger:0];
    if (self.latestMessage) {
        self.timestamp = [self.latestMessage receiveTimestamp];
    }
}

- (MessageEntity*) updateLatestMessage {
    MessageEntity* oldLatestMsg = self.latestMessage;
    MessageEntity* lastestMsg = [self lastMessageByTimeStamp:NO];
    if (oldLatestMsg == lastestMsg//nil == nil
        || [oldLatestMsg isEqual:lastestMsg]) {
        if ([lastestMsg.receiveTimestamp isEqualToDate:self.timestamp]) {
            return oldLatestMsg;
        }
    }
    
    self.latestMessage = lastestMsg;
    self.timestamp = lastestMsg.receiveTimestamp;
    if (!self.latestMessage && 1 != [self.priority integerValue]) {
        self.priority = [NSNumber numberWithInteger:-1];
    }
    SessionGroupEntity* parent = (SessionGroupEntity*)self.parent;
    if (parent && !parent.isDeleted) {//父节点存在
        if ([self isKindOfClass:[SessionGroupEntity class]]) {
            SessionGroupEntity* group = (SessionGroupEntity*) self;
            if ([group.reportUnread boolValue]) {
                [parent setLatestMessage:lastestMsg withSession:lastestMsg.session];
            }
        } else {
            [parent setLatestMessage:lastestMsg withSession:self];
        }
    }
    return lastestMsg;
}

- (SessionEntity*) topestSession {
    NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:@"SessionEntity"];
    [request setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"priority" ascending:NO]]];
    [request setFetchLimit:1];
    NSError * error = nil;
    
    NSArray* results = [self.managedObjectContext executeFetchRequest:request error:&error];
    if (error) {
        return nil;
    }
    return [results lastObject];
    
}

- (void) setUnreadCount:(NSNumber *)unreadCount {
    [self willAccessValueForKey:@"unreadCount"];
    NSNumber* unread = [self primitiveValueForKey:@"unreadCount"];
    if (![unread boolValue] || unread.integerValue != unreadCount.integerValue) {
        [self willChangeValueForKey:@"unreadCount"];
        [self setPrimitiveValue:unreadCount forKey:@"unreadCount"];
        NSInteger changeCount = unreadCount.integerValue - unread.integerValue;
        SessionGroupEntity* parent = (SessionGroupEntity*)self.parent;
        if ([self.reportUnread boolValue] && parent) {
            NSInteger unreaded = [parent.unreadCount integerValue];
            unreaded += changeCount;
            if (unreaded > 0) {
                parent.unreadCount = [NSNumber numberWithInteger:unreaded];
            } else {
                parent.unreadCount = [NSNumber numberWithInteger:0];
            }
        }
        [self didChangeValueForKey:@"unreadCount"];
    }
    [self didAccessValueForKey:@"unreadCount"];
}

- (MessageEntity *)messageWithId:(NSString *)msgId {
    NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:@"MessageEntity"];
    request.predicate = [NSPredicate predicateWithFormat:@"session=%@ AND messageId=%@", self, msgId];
    [request setFetchLimit:1];
    NSError * error = nil;
    
    NSArray* results = [self.managedObjectContext executeFetchRequest:request error:&error];
    if (error) {
        return nil;
    }
    return [results lastObject];
    
}

- (MessageEntity*) lastMessageByTimeStamp:(BOOL) ascending {
    NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:@"MessageEntity"];
    
    request.predicate = [NSPredicate predicateWithFormat:@"session=%@", self];
    
    [request setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"receiveTimestamp" ascending:ascending]]];
    [request setFetchLimit:1];
    NSError * error = nil;
    
    NSArray* results = [self.managedObjectContext executeFetchRequest:request error:&error];
    if (error) {
        return nil;
    }
    return [results lastObject];
}

- (void)addMessages:(NSSet *)values {
    [self willChangeValueForKey:@"messages" withSetMutation:NSKeyValueUnionSetMutation usingObjects:values];
    NSMutableSet* messages =  [self primitiveValueForKey:@"messages"];
    [messages unionSet:values];
    [self didChangeValueForKey:@"messages" withSetMutation:NSKeyValueUnionSetMutation usingObjects:values];
    MessageEntity* message = [self lastMessageByTimeStamp:NO];
    for (MessageEntity* msg in values) {
        if (![msg canBeLatestMessage]) {
            continue;
        }
        if (!message) {
            message = msg;
        } else {
            if ([msg.receiveTimestamp timeIntervalSinceDate:message.receiveTimestamp] > 0) {
                message = msg;
            }
        }
    }
    //为提高新增消息的性能不在addMessages时调用updateLatestMessage更新parent的latestmessage而是比较新增消息是否比原消息新
    if (message && ![self.latestMessage isEqual:message]) {
        SessionGroupEntity* parent = (SessionGroupEntity*)self.parent;
        self.latestMessage = message;
        self.timestamp = message.receiveTimestamp;
        //此处不应该做如下处理，不能因为添加消息而强制将priority设为0
//        if ([self.priority integerValue] < 0) {
//            self.priority = [NSNumber numberWithInteger:0];
//        }
        if ([self.reportUnread boolValue]
            && parent
            && (parent.latestMessage
                || parent.latestMessage.isDeleted
                || [parent.timestamp timeIntervalSinceDate:message.receiveTimestamp] < 0
                || nil == parent.timestamp/*the judge is supply for timeIntervalSinceDate: method*/))
        {
            [parent setLatestMessage:message withSession:self];
        }
    }
}

- (void) addMessagesObject:(MessageEntity *)value {
    if (nil == value) {
        return;
    }
    [self addMessages:[NSSet setWithObjects:&value count:1]];
}

//Core Data技术限制，无法在remove对象时修改many-to-one的属性,故不能在removeMessages时重设latestMessage
- (void)removeMessages:(NSSet *)values {
    for (MessageEntity* message in values) {
        message.readed = [NSNumber numberWithBool:YES];
    }
    //只有删除的message中包含直接父节点的latestMessage才需要(递归)计算父节点的latestmessage
//    SessionGroupEntity* parent = (SessionGroupEntity*)self.parent;
//    BOOL needUpdateParent = NO;
//    if (parent && [values containsObject:parent.latestMessage]) {
//        needUpdateParent = YES;
//    }
    [self willChangeValueForKey:@"messages" withSetMutation:NSKeyValueMinusSetMutation usingObjects:values];
    NSMutableSet* messages =  [self primitiveValueForKey:@"messages"];
    [messages minusSet:values];
    [self didChangeValueForKey:@"messages" withSetMutation:NSKeyValueMinusSetMutation usingObjects:values];
    if (messages.count == 0 && 1 != [self.priority integerValue]) {
        self.priority = [NSNumber numberWithInteger:-1];
    }
}

- (void)removeMessagesObject:(MessageEntity *)value {
    [self removeMessages:[NSSet setWithObjects:&value count:1]];
}

- (void)localDeleteSelf{
    if (self.isDeleted) {
        return;
    }
    self.unreadCount = [NSNumber numberWithInteger:0];
    SessionGroupEntity* group = (SessionGroupEntity*)self.parent;
    [group removeChildObject:self];
    [group setLatestMessage:nil withSession:self];
    [self.managedObjectContext deleteObject:self];
}

- (void)localDeleteSelf:(void (^)(NSError* error)) completionBlock {
    NSManagedObjectID* oid = self.objectID;
    ESpaceLocalDataManager * localManager = LOCAL_DATA_MANAGER;
    dispatch_async(espace_coredata_management_queue, ^{
        NSManagedObjectContext* bgCtx = [localManager backgroundObjectContext];
        [bgCtx performBlockAndWait:^{
            SessionEntity* shadow = (SessionEntity*)[bgCtx objectWithID:oid];
            if (shadow && !shadow.isDeleted) {
                [shadow localDeleteSelf];
            }
            [bgCtx processPendingChanges];
            [bgCtx saveToPersistent];
            if (completionBlock) {
                completionBlock(nil);
            }
        }];
    });
}

- (NSNumber *)reportUnread {
    [self willAccessValueForKey:@"reportUnread"];
    NSNumber * reportUnread = [self primitiveValueForKey:@"reportUnread"];
    [self didAccessValueForKey:@"reportUnread"];
    return reportUnread;
}

- (void)setReportUnread:(NSNumber *)reportUnread {
    NSNumber * oldReport = [self reportUnread];
    if ([oldReport boolValue] != [reportUnread boolValue]) {
        [self willChangeValueForKey:@"reportUnread"];
        [self setPrimitiveValue:reportUnread forKey:@"reportUnread"];
        
        SessionGroupEntity* parent = (SessionGroupEntity*)self.parent;
        if (parent) {
            NSInteger unreadCount = [self.unreadCount integerValue];
            NSInteger changeCount = [reportUnread boolValue] ? unreadCount : -1 * unreadCount;
            NSInteger unreaded = [parent.unreadCount integerValue];
            unreaded += changeCount;
            //更新未读数
            if (unreaded > 0) {
                parent.unreadCount = [NSNumber numberWithInteger:unreaded];
            } else {
                parent.unreadCount = [NSNumber numberWithInteger:0];
            }
            //更新最新消息
            [parent setLatestMessage:([reportUnread boolValue] ? self.latestMessage : nil) withSession:self];
        }
        [self didChangeValueForKey:@"reportUnread"];
    }
}

- (void)localDeleteAllMessages:(void (^)(NSError* error)) completionBlock {
    NSManagedObjectID* oid = self.objectID;
    ESpaceLocalDataManager * localManager = LOCAL_DATA_MANAGER;
    dispatch_async(espace_coredata_management_queue, ^{
        NSManagedObjectContext* bgCtx = [localManager backgroundObjectContext];
        [bgCtx performBlockAndWait:^{
            SessionEntity* shadow = (SessionEntity*)[bgCtx objectWithID:oid];
            if (shadow && !shadow.isDeleted) {
                [shadow localDeleteAllMessages];
            }
            [bgCtx saveToPersistent];
            if (completionBlock) {
                completionBlock(nil);
            }
        }];
    });
}

- (void)localDeleteMessages:(NSSet*) msg {
    if (self.isDeleted) {
        return;
    }
    [self removeMessages:msg];
    [self updateLatestMessage];
    for (MessageEntity* message in msg) {
        [self.managedObjectContext deleteObject:message];
    }
}

- (void)localDeleteMessages:(NSSet*) msgs completion:(void (^)(NSError* error)) completionBlock {
    NSManagedObjectID* oid = self.objectID;
    NSMutableArray* array = [NSMutableArray array];
    for (MessageEntity* message in msgs) {
        [array addObject:message.objectID];
    }
    ESpaceLocalDataManager * localManager = LOCAL_DATA_MANAGER;
    
    dispatch_async(espace_coredata_management_queue, ^{
        NSManagedObjectContext* bgCtx = [localManager backgroundObjectContext];
        [bgCtx performBlockAndWait:^{
            SessionEntity* shadow = (SessionEntity*)[bgCtx objectWithID:oid];
            if (shadow && !shadow.isDeleted) {
                NSMutableSet * set = [NSMutableSet set];
                for (NSManagedObjectID* oid in array) {
                    MessageEntity* msg = (MessageEntity*)[bgCtx objectWithID:oid];
                    if (msg && !msg.deleted) {
                        [set addObject:msg];
                    }
                }
                [shadow localDeleteMessages:set];
            }
            [bgCtx saveToPersistent];
            if (completionBlock) {
                completionBlock(nil);
            }
        }];
    });
}

- (void)localDeleteAllMessages {
    if (self.isDeleted) {
        return;
    }
    self.unreadCount = [NSNumber numberWithInteger:0];
    self.latestMessage = nil;
    self.timestamp = nil;
    if (1 != [self.priority integerValue]) {
        self.priority = [NSNumber numberWithInteger:-1];
    }
    NSSet* messages = [NSSet setWithSet:self.messages];
    [self removeMessages:messages];
    SessionGroupEntity* group = (SessionGroupEntity*)self.parent;
    [group setLatestMessage:nil withSession:self];
    for (MessageEntity* message in messages) {
        [self.managedObjectContext deleteObject:message];
    }
}
@end
