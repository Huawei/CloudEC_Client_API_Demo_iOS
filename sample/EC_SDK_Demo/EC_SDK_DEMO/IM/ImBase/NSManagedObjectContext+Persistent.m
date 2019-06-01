//
//  NSManagedObjectContext+Persistent.m
//  eSpace
//
//  Created by yemingxing on 9/22/15.
//  Copyright (c) 2015 www.huawei.com. All rights reserved.
//

#import "NSManagedObjectContext+Persistent.h"
//#import "ECSLogCofig.h"
//#import <ctk.h>

@implementation NSManagedObjectContext (Persistent)

- (void) saveToPersistent {
    if ([self hasChanges]) {
        NSError* error = nil;
        [self save:&error];
        
        if (error && [error.localizedDescription length]) {
            DDLogInfo(@"saveToPersistent,error: %@", error.localizedDescription);
        }
        
        NSManagedObjectContext* parent = self.parentContext;
        [parent _psaveToPersistent];
    }
}

- (void) _psaveToPersistent {
    [self performBlock:^{
        if ([self hasChanges]) {
            NSError* error = nil;
            [self save:&error];
            
            if (error && [error.localizedDescription length]) {
//                //SDK_INFO_LOG("CoreData save error:"<<[error.localizedDescription UTF8String]);
            }
            
            NSManagedObjectContext* parent = self.parentContext;
            if (parent) {
                [parent _psaveToPersistent];
            }
        }
    }];
    
}

- (void) saveToPersistentAndWait {
    if ([self hasChanges]) {
        NSError* error = nil;
        [self save:&error];
        
        if (error && [error.localizedDescription length]) {
//            //SDK_INFO_LOG("CoreData save error:"<<[error.localizedDescription UTF8String]);
        }
        
        NSManagedObjectContext* parent = self.parentContext;
        [parent _psaveToPersistentAndWait];
    }
}

- (void) _psaveToPersistentAndWait {
    [self performBlockAndWait:^{
        if ([self hasChanges]) {
            NSError* error = nil;
            [self save:&error];
            
            if (error && [error.localizedDescription length]) {
//                //SDK_INFO_LOG("CoreData save error:"<<[error.localizedDescription UTF8String]);
            }
            
            NSManagedObjectContext* parent = self.parentContext;
            if (parent) {
                [parent _psaveToPersistentAndWait];
            }
        }
    }];
}

@end
