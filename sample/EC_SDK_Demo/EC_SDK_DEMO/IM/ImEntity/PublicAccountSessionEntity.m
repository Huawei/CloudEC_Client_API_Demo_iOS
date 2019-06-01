//
//  PublicAccountSessionEntity.m
//  eSpace
//
//  Created by ZengyiWang on 15/7/30.
//  Copyright (c) 2015年 www.huawei.com. All rights reserved.
//

#import "PublicAccountSessionEntity.h"
#import "SessionGroupEntity.h"
#import "ESpaceLocalDataManager.h"
#import "ContactEntity.h"

@implementation PublicAccountSessionEntity

- (BOOL)canMarkTop
{
    return NO;
}

- (void)setParent:(NSManagedObject *)parent
{
    SessionGroupEntity *group = (SessionGroupEntity *)parent;
    
    [self willAccessValueForKey:@"parent"];
    
    SessionGroupEntity* oldGroup = [self primitiveValueForKey:@"parent"];
    
    if (![oldGroup isEqual:group]){
        
        NSInteger unreadEntity   = [self.unreadCount integerValue];
        NSInteger unreadGroup    = [group.unreadCount integerValue];
        NSInteger unreadGroupOld = [oldGroup.unreadCount integerValue];
        
        NSInteger newUnreadGroup    = unreadGroup + unreadEntity;
        NSInteger newUnreadGroupOld = unreadGroupOld - unreadEntity;
        
        if (newUnreadGroup < 0) {
            newUnreadGroup = 0;
        }
        
        if (newUnreadGroupOld < 0) {
            newUnreadGroupOld = 0;
        }
        
        group.unreadCount    = [NSNumber numberWithInteger:newUnreadGroup];
        oldGroup.unreadCount = [NSNumber numberWithInteger:newUnreadGroupOld];
        
//        NSLog(@"debug info setParent contactid = %@, unreadGroup = %d, unreadGroupeOld = %d, unreadEntity = %d, \n %@", [self.target contactId], unreadGroup, unreadGroupOld, unreadEntity, [NSThread callStackSymbols]);

        
        [self willChangeValueForKey:@"parent"];
        [self setPrimitiveValue:parent forKey:@"parent"];
        [self didChangeValueForKey:@"parent"];
        
        [oldGroup removeChildObject:self];
        [oldGroup setLatestMessage:nil withSession:self];
        [group setLatestMessage:self.latestMessage withSession:self];
    }
    
    [self didAccessValueForKey:@"parent"];
}

@end
