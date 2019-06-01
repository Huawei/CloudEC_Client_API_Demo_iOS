//
//  AssistantSessionEntity.m
//  eSpace
//
//  Created by yemingxing on 8/17/15.
//  Copyright (c) 2015 www.huawei.com. All rights reserved.
//

#import "AssistantSessionEntity.h"
#import "AssistantMessageEntity.h"
#import "NSManagedObjectContext+Persistent.h"

@implementation AssistantSessionEntity

//- (void)clearAllNotifies:(void (^)(NSError *))completionBlock {
//    NSManagedObjectID* oid = self.objectID;
//    dispatch_async(espace_coredata_management_queue, ^{
//        NSManagedObjectContext* bgCtx = [LOCAL_DATA_MANAGER backgroundObjectContext];
//        [bgCtx performBlockAndWait:^{
//            NSError* error = nil;
//            AssistantSessionEntity* session = (AssistantSessionEntity*)[bgCtx objectWithID:oid];
//            NSSet* messages = session.messages;
//            [session removeMessages:messages];
//            for (AssistantMessageEntity* message in messages) {
//                if (!message.isDeleted) {
//                    [bgCtx deleteObject:message];
//                }
//            }
//            [bgCtx saveToPersistent];
////            if ([bgCtx hasChanges]) {
////                [bgCtx save:nil];
////            }
//            if (completionBlock) {
//                completionBlock(error);
//            }
//        }];
//    });
//}

@end
