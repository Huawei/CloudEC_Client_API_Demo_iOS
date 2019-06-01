//
//  ContractEntity.m
//  eSpaceUI
//
//  Created by yemingxing on 3/16/15.
//  Copyright (c) 2015 www.huawei.com. All rights reserved.
//

#import "ContactEntity.h"
#import "ChatSessionEntity.h"
#import "MessageEntity.h"
#import "AttendeeEntity.h"
#import "NSString+Transform.h"
#import "ECSUtils.h"
#import "CallSessionEntity.h"
#import "NSManagedObjectContext+Persistent.h"
#import "eSpaceDBService.h"
#import "ECSSandboxHelper.h"
#import "EmployeeEntity.h"
#import "ESpaceContactHeadImageService.h"

@implementation ContactEntity

@dynamic contactId;
@dynamic name;
@dynamic chatSession;
@dynamic recivMessages;
@dynamic sentMessages;
@dynamic classType;
@dynamic weight;
@dynamic infoUpdateTime;
@dynamic nameIndex;
@dynamic matchedAttendee;
@dynamic callSession;
@dynamic msgLogSession;
@dynamic searchIndex;
@dynamic appID;
@dynamic translateSwitchState;
@dynamic translateSwitchOpenedTime;
@dynamic translateLanguage;

@synthesize headId = _headId;
@synthesize itemLocalStatus = _itemLocalStatus;
@synthesize headLocalStatus = _headLocalStatus;
@synthesize uiDisplayName = _uiDisplayName;
@synthesize appName = _appName;
@synthesize remarkName;

+ (NSSet *)keyPathsForValuesAffectingUiDisplayName {
    return [NSSet setWithObject:@"name"];
}

- (void)setHeadId:(NSString *)headId {
    if (_headId && ![_headId isEqualToString:headId]) {
        [self resetHeadLocalStatus];
    }
    [self willChangeValueForKey:@"headId"];
    [self setPrimitiveValue:headId forKey:@"headId"];
    [self didChangeValueForKey:@"headId"];
}

- (void)resetHeadLocalStatus {
    
    NSManagedObjectID *oldObjectID = self.objectID;
    dispatch_async(dispatch_get_main_queue(), ^{
        NSManagedObjectContext *mainContext = [LOCAL_DATA_MANAGER managedObjectContext];
        [mainContext performBlockAndWait:^{
            NSError *error;
            ContactEntity *mainShadow = [mainContext existingObjectWithID:oldObjectID error:&error];
            if (error) {
                //
            } else {
                mainShadow.headLocalStatus = ItemNotLoaded;
            }
        }];
    });
}

- (NSString *)headId {
    [self willAccessValueForKey:@"headId"];
    NSString *headID = [self primitiveValueForKey:@"headId"];
    [self didAccessValueForKey:@"headId"];
    return headID;
}

- (NSString *)name {
    [self willAccessValueForKey:@"name"];
    NSString* nameVal = [self primitiveValueForKey:@"name"];
    [self didAccessValueForKey:@"name"];
//    return [ECSUtils databaseDataDecrypt:nameVal];
    return nameVal;
}

-(void)setName:(NSString *)name{
    [self willChangeValueForKey:@"name"];
//    NSString* nameVal = [ECSUtils databaseDataEncrypt:name];
    NSString* nameVal = name;
    [self setPrimitiveValue:nameVal forKey:@"name"];
    [self didChangeValueForKey:@"name"];

    if (0 == [name length]) {
        self.nameIndex = @"[";
    }
    else{
        self.nameIndex = [name nameIndex];
    }
}


- (void)setAppName:(NSString *)appName{
    [self willChangeValueForKey:@"appName"];
//    NSString *appNameVal = [ECSUtils databaseDataEncrypt:appName];
    NSString *appNameVal = appName;
    [self setPrimitiveValue:appNameVal forKey:@"appName"];
    [self didChangeValueForKey:@"appName"];
}

- (NSString *)appName{
    [self willAccessValueForKey:@"appName"];
    NSString *appNameVal = [self primitiveValueForKey:@"appName"];
    [self didAccessValueForKey:@"appName"];
//    return [ECSUtils databaseDataDecrypt:appNameVal];
    return appNameVal;
}

- (NSString *)uiDisplayName {
    [self willAccessValueForKey:@"uiDisplayName"];
    _uiDisplayName = [self.name length] != 0 ? self.name : self.contactId;
    [self didAccessValueForKey:@"uiDisplayName"];
    
    return _uiDisplayName;
}

- (void)setUiDisplayName:(NSString *)uiDisplayName {
    [self willChangeValueForKey:@"uiDisplayName"];
    _uiDisplayName = uiDisplayName;
    [self didChangeValueForKey:@"uiDisplayName"];
}

- (void)setItemLocalStatus:(ItemLocalStatus)itemLocalStatus {
    [self willChangeValueForKey:@"itemLocalStatus"];
    _itemLocalStatus = itemLocalStatus;
    [self didChangeValueForKey:@"itemLocalStatus"];
    
    if (self.managedObjectContext != [LOCAL_DATA_MANAGER managedObjectContext]) {
        __strong NSManagedObjectID *objId = self.objectID;
        dispatch_async_main_safe(^{
            if (objId) {
                NSManagedObjectContext *mainContext = [LOCAL_DATA_MANAGER managedObjectContext];
                ContactEntity * mainContact = [mainContext objectWithID:objId];
                mainContact.itemLocalStatus = itemLocalStatus;
            }
        });
    }
}

- (ItemLocalStatus)itemLocalStatus {
    [self willAccessValueForKey:@"itemLocalStatus"];
    ItemLocalStatus status = _itemLocalStatus;
    [self didAccessValueForKey:@"itemLocalStatus"];
    return status;
}

- (ItemLocalStatus)headLocalStatus {
    [self willAccessValueForKey:@"headLocalStatus"];
    ItemLocalStatus status = _headLocalStatus;
    [self didAccessValueForKey:@"headLocalStatus"];
    return status;
}

- (void)setHeadLocalStatus:(ItemLocalStatus)headLocalStatus {
    [self willChangeValueForKey:@"headLocalStatus"];
    _headLocalStatus = headLocalStatus;
    [self didChangeValueForKey:@"headLocalStatus"];
}

- (NSString *)remarkName {
    [self willAccessValueForKey:@"remarkName"];
    NSString *name = remarkName;
    [self didAccessValueForKey:@"remarkName"];
    return name;
}

- (void)setRemarkName:(NSString *)name {
    [self willChangeValueForKey:@"remarkName"];
    remarkName = name;
    [self didChangeValueForKey:@"remarkName"];
}

- (UIImage *)defaultHeadImage {
    return [[ESpaceContactHeadImageService sharedInstance] defaultGroupHeadImage];
}

+ (UIImage*) defaultHeadImageWithId:(NSString*) headId{
    
    return [[ESpaceContactHeadImageService sharedInstance] defaultEmpolyeeHeadImageWithHeadId:headId];
}

+ (NSString*) localPathForHeadId:(NSString*) headId account:(NSString*) userAccount prefix:(NSString *)prefix {
    NSString* currentUser = LOCAL_DATA_MANAGER.userAccount;
    NSString* cachePath = [ECSSandboxHelper shareInstance].cachesPath;
    NSString* headDirectory = [[cachePath stringByAppendingPathComponent:currentUser] stringByAppendingPathComponent:@"headimgs"];
    BOOL bDir = NO;
    if (![[NSFileManager defaultManager] fileExistsAtPath:headDirectory isDirectory:&bDir]
        || !bDir)
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:headDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    }
    if ([prefix length] > 0) {
        NSString* path = [[[cachePath stringByAppendingPathComponent:currentUser] stringByAppendingPathComponent:@"headimgs"] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_%@_%@.png",prefix, userAccount, headId]];
        return path;
    } else {
        return [[[cachePath stringByAppendingPathComponent:currentUser] stringByAppendingPathComponent:@"headimgs"] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_%@.png",userAccount, headId]];
    }

}

- (NSString*) headImageLocalPath {
    return [ContactEntity localPathForHeadId:self.headId account:self.contactId prefix:NSStringFromClass([self class])];
}

- (NSString*) headImageKey {
    if ([self.headId length] == 0) {
        return nil;
    }
    return [NSString stringWithFormat:@"%@_%@.png", self.contactId, self.headId];
}

- (BOOL)isEmployeeEnity {
    return [NSStringFromClass([EmployeeEntity class]) isEqualToString:NSStringFromClass([self class])];
}

- (BOOL)isGroupEntity {
    return [self isKindOfClass:[GroupEntity class]];
}


- (BOOL)isEqualToContact:(ContactEntity *)c
{
    if (self.contactId.length != 0
        && [self.contactId compare:c.contactId] == NSOrderedSame) {
        return YES;
    }
    return NO;
}

- (void)localDeleteSelf {
    SessionEntity* chatSession = self.chatSession;
    SessionEntity* callSession = self.callSession;
    [chatSession localDeleteSelf];
    [callSession localDeleteSelf];
    [self.managedObjectContext deleteObject:self];
}

- (void)localDeleteSelf:(void (^)(NSError* error)) completionBlock {
    
    NSManagedObjectID* oid = self.objectID;
    ESpaceLocalDataManager * localManager = LOCAL_DATA_MANAGER;
    dispatch_async(espace_coredata_management_queue, ^{
        NSManagedObjectContext* bgCtx = [localManager backgroundObjectContext];
        [bgCtx performBlockAndWait:^{
            ContactEntity* shadow = (ContactEntity*)[bgCtx objectWithID:oid];
            if (shadow && !shadow.isDeleted) {
                [shadow localDeleteSelf];
                [bgCtx saveToPersistent];
            }
            if (completionBlock) {
                completionBlock(nil);
            }
        }];
    });
}
@end
