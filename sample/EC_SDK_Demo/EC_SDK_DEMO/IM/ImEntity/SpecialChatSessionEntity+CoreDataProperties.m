//
//  SpecialChatSessionEntity+CoreDataProperties.m
//  eSpace
//
//  Created by wangxiangyang on 15/11/14.
//  Copyright © 2015年 www.huawei.com. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "SpecialChatSessionEntity+CoreDataProperties.h"
#import "SpecialChatSessionEntity.h"
#import "ChatMessageEntity.h"
#import "SessionGroupEntity.h"

@implementation SpecialChatSessionEntity (CoreDataProperties)


- (void)updateLastMessage:(NSSet *)values{
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
        if ([self.priority integerValue] < 0) {
            self.priority = [NSNumber numberWithInteger:0];
        }
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

@end
