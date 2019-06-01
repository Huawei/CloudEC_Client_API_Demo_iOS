//
//  SpecialChatSessionEntity.m
//  eSpace
//
//  Created by wangxiangyang on 15/11/14.
//  Copyright © 2015年 www.huawei.com. All rights reserved.
//

#import "SpecialChatSessionEntity.h"

@implementation SpecialChatSessionEntity

// Insert code here to add functionality to your managed object subclass


//- (void)addMessages:(NSSet *)values{
//    [self willChangeValueForKey:@"messages" withSetMutation:NSKeyValueUnionSetMutation usingObjects:values];
//    NSMutableSet* messages =  [self primitiveValueForKey:@"messages"];
//    [messages unionSet:values];
//    [self didChangeValueForKey:@"messages" withSetMutation:NSKeyValueUnionSetMutation usingObjects:values];
//}

- (void)addMessagesObject:(MessageEntity *)value {
    [self willChangeValueForKey:@"messages" withSetMutation:NSKeyValueUnionSetMutation usingObjects:[NSSet setWithObject:value]];
    NSMutableSet* messages =  [self primitiveValueForKey:@"messages"];
    [messages unionSet:[NSSet setWithObject:value]];
    [self didChangeValueForKey:@"messages" withSetMutation:NSKeyValueUnionSetMutation usingObjects:[NSSet setWithObject:value]];
}

@end
