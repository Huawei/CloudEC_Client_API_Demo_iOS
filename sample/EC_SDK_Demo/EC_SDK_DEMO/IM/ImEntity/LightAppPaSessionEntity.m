//
//  LightAppPaSessionEntity.m
//  
//
//  Created by ZengyiWang on 15/9/8.
//
//

#import "LightAppPaSessionEntity.h"
#import "SessionGroupEntity.h"


@implementation LightAppPaSessionEntity

- (void)setParent:(NSManagedObject *)parent {
    
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
        
        [self willChangeValueForKey:@"parent"];
        [self setPrimitiveValue:parent forKey:@"parent"];
        [self didChangeValueForKey:@"parent"];
        
        [oldGroup removeChildObject:self];// ??
        [oldGroup setLatestMessage:nil withSession:self];
        [group setLatestMessage:self.latestMessage withSession:self];
    }
    
    [self didAccessValueForKey:@"parent"];
}
@end
