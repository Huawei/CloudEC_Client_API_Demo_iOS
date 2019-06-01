//
//  ESpaceMutipleTerminalRemindSessionEntity+CoreDataProperties.m
//  eSpaceIOSSDK
//
//  Created by s00357625 on 16/8/3.
//  Copyright © 2016年 HuaWei. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//
#import "NSManagedObjectContext+Persistent.h"
#import "ESpaceLocalDataManager.h"
#import "ESpaceMutipleTerminalRemindSessionEntity+CoreDataProperties.h"
#import "eSpaceDBService.h"
#import "ECSAppConfig.h"

@implementation ESpaceMutipleTerminalRemindSessionEntity (CoreDataProperties)

- (void)chooseOrCancleStick:(void (^)(NSError* error,NSInteger priorityNum)) completionBlock{
    
    NSManagedObjectID* oid = self.objectID;
    dispatch_async(espace_coredata_management_queue, ^{
        NSManagedObjectContext* bgCtx = [LOCAL_DATA_MANAGER backgroundObjectContext];
        [bgCtx performBlockAndWait:^{
            NSInteger flag = 0;
            ESpaceMutipleTerminalRemindSessionEntity* entity = (ESpaceMutipleTerminalRemindSessionEntity*) [bgCtx objectWithID:oid];
            if ([entity.priority isEqual:@(SESSION_PRIORITY_Two)]) {
                entity.priority = @(SESSION_PRIORITY_Zero);
                flag = SESSION_PRIORITY_Zero;
                [ECSAppConfig sharedInstance].currentUser.mutilTerminalRemindStatus = 0;
                
            }else if ([entity.priority isEqual:@(SESSION_PRIORITY_Zero)]){
                entity.priority = @(SESSION_PRIORITY_Two);
                flag = SESSION_PRIORITY_Two;
                [ECSAppConfig sharedInstance].currentUser.mutilTerminalRemindStatus = 1;
                
            }
            [bgCtx saveToPersistent];
            if (completionBlock) {
                completionBlock(nil,flag);
            }
        }];
    });
}

@end
