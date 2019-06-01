//
//  SessionGroupEntity.m
//  eSpaceUI
//
//  Created by yemingxing on 3/16/15.
//  Copyright (c) 2015 www.huawei.com. All rights reserved.
//

#import "SessionGroupEntity.h"
#import "SessionEntity.h"
#import "MessageEntity.h"
#import "NSManagedObjectContext+Persistent.h"

@implementation SessionGroupEntity

@dynamic desc;
@dynamic headId;
@dynamic name;
@dynamic child;

- (MessageEntity*)lastMessageByTimeStamp:(BOOL) ascending
{
    MessageEntity *lastMessage = nil;
    for (SessionEntity *childSession in self.child)
    {
        if (!childSession.latestMessage || childSession.latestMessage.isDeleted || childSession.isDeleted) {
            continue;
        }
        
        if (!lastMessage)
        {
            lastMessage = childSession.latestMessage;
        }
        else if ([childSession.latestMessage.receiveTimestamp compare:lastMessage.receiveTimestamp]
                 == NSOrderedDescending)
        {
            lastMessage = childSession.latestMessage;
        }
    }
    
    return lastMessage;
}

- (void)localDeleteAllMessages
{
    //后序遍历删除所有子节点Messages保证最新消息准确
    NSMutableArray * stack = [NSMutableArray arrayWithObject:self];
    while ([stack count] > 0) {
        SessionEntity* session = [stack lastObject];
        if ([session isKindOfClass:[SessionGroupEntity class]]) {
            SessionGroupEntity* group = (SessionGroupEntity*)session;
            NSSet* children = group.child;
            [stack removeLastObject];
            if ([children count] > 0) {
                [stack addObjectsFromArray:[children allObjects]];
            }
        } else {
            [session localDeleteAllMessages];
            [stack removeLastObject];
        }
    }
}

- (void)localMarkReadAll {
    //后序遍历删除所有子节点Messages保证最新消息准确
    NSMutableArray * stack = [NSMutableArray arrayWithObject:self];
    while ([stack count] > 0) {
        SessionEntity* session = [stack lastObject];
        if ([session isKindOfClass:[SessionGroupEntity class]]) {
            SessionGroupEntity* group = (SessionGroupEntity*)session;
            NSSet* children = group.child;
            [stack removeLastObject];
            if ([children count] > 0) {
                [stack addObjectsFromArray:[children allObjects]];
            }
        } else {
            [session localMarkReadAll];
            [stack removeLastObject];
        }
    }
}

- (void)setLatestMessage:(MessageEntity *)latestMessage withSession:(SessionEntity*) session {
    if (!session) {
        self.latestMessage = nil;
        self.timestamp = nil;
        self.priority = [NSNumber numberWithInteger:-1];
        return;
    }
    MessageEntity* oldMessage = self.latestMessage;
    SessionGroupEntity* parent = (SessionGroupEntity*)self.parent;
    
//    if (oldMessage.fault == YES) {
//        return;
//    }
    
    if (!oldMessage || oldMessage.deleted || oldMessage.session.deleted ) {
        self.latestMessage = latestMessage;
        self.timestamp = latestMessage.receiveTimestamp;
        if (latestMessage) {
            if ([self.priority integerValue] < 0) {
                self.priority = [NSNumber numberWithInteger:0];
            }
        } else {
            if ([self.priority integerValue] >= 0) {
                self.priority = [NSNumber numberWithInteger:-1];
            }
        }
        if (parent && !parent.isDeleted && [self.reportUnread boolValue]) {
            [parent setLatestMessage:latestMessage withSession:session];
        }
    } else {
        BOOL addOrDelete = YES;//add default
        if (latestMessage) {
            NSTimeInterval interval = [latestMessage.receiveTimestamp timeIntervalSinceDate:oldMessage.receiveTimestamp];
            if (interval < 0) {//新消息没有旧消息新,删除操作
                addOrDelete = NO;
            }
        } else {//新消息不存在,删除操作
            addOrDelete = NO;
        }
        if (addOrDelete) {//新消息比旧消息新,新增操作
            self.latestMessage = latestMessage;
            self.timestamp = latestMessage.receiveTimestamp;
            if ([self.priority integerValue] < 0) {
                self.priority = [NSNumber numberWithInteger:0];
            }
            if (parent && !parent.isDeleted && [self.reportUnread boolValue]) {
                [parent setLatestMessage:latestMessage withSession:session];
            }
        } else {//新消息没有旧消息新,删除操作
            if (oldMessage.session == nil//旧消息被从session中移除
                || latestMessage == nil//新消息为空
                || [session isEqual:oldMessage.session]) {
                MessageEntity* newLatestMsg = [self lastMessageByTimeStamp:NO];
                self.latestMessage = newLatestMsg;
                self.timestamp = newLatestMsg.receiveTimestamp;
                if (newLatestMsg) {
                    if ([self.priority integerValue] < 0) {
                        self.priority = [NSNumber numberWithInteger:0];
                    }
                } else {
                    if ([self.priority integerValue] >= 0) {
                        self.priority = [NSNumber numberWithInteger:-1];
                    }
                }
                if (parent && !parent.isDeleted && [self.reportUnread boolValue]) {
                    [parent setLatestMessage:newLatestMsg withSession:session];
                }
            } else {//父节点的消息session不是当前session而当前session又删除消息,父节点最新消息一定不会落在当前session的消息中
//                self.latestMessage = latestMessage;
            }
        }
    }
}

//- (void)setLatestMessage:(MessageEntity *)latestMessage {
//    if (self.latestMessage
//        && !self.latestMessage.isDeleted//原来的latestmessage已存在并未删除
//        && !self.latestMessage.session.isDeleted
//        && latestMessage//latestmessage比原消息老
//        && [latestMessage.receiveTimestamp timeIntervalSinceDate:self.latestMessage.receiveTimestamp] <= 0) {
//        return;
//    }
//    [self willChangeValueForKey:@"latestMessage"];
//    [self setPrimitiveValue:latestMessage forKey:@"latestMessage"];
//    SessionGroupEntity* parent = (SessionGroupEntity*)self.parent;
//    if (parent && [self.reportUnread boolValue]) {
//        parent.latestMessage = latestMessage;
//    }
//    [self didChangeValueForKey:@"latestMessage"];
//    self.timestamp = latestMessage.receiveTimestamp;
//    if (latestMessage == nil) {
//        self.priority = [NSNumber numberWithInteger:-1];
//    } else {
//        if ([self.priority integerValue] < 0) {
//            self.priority = [NSNumber numberWithInteger:0];
//        }
//    }
//}

- (void)setUnreadCount:(NSNumber *)unreadCount {
    [self willAccessValueForKey:@"unreadCount"];
    NSNumber* unread = [self primitiveValueForKey:@"unreadCount"];
    if (![unread boolValue] || unread.integerValue != unreadCount.integerValue) {
        [self willChangeValueForKey:@"unreadCount"];
        [self setPrimitiveValue:unreadCount forKey:@"unreadCount"];
        NSInteger changeCount = unreadCount.integerValue - unread.integerValue;
        SessionGroupEntity* parent = (SessionGroupEntity*)self.parent;
        if (parent && [self.reportUnread boolValue]) {
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

@end
