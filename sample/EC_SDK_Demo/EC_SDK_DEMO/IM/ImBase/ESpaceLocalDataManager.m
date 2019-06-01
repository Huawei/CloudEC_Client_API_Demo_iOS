 //
//  ESpaceLocalDataManager.m
//  eSpaceUI
//
//  Created by yemingxing on 3/12/15.
//  Copyright (c) 2015 www.huawei.com. All rights reserved.
//

#import "ESpaceLocalDataManager.h"
#import "NSDate+LocalString.h"
#import "SessionGroupEntity.h"
#import "AssistantSessionEntity.h"
#import "NSManagedObjectContext+Persistent.h"
#import "ECSSandboxHelper.h"
#import "NSString+ESpaceMD5.h"
#import "ECSAppConfig.h"
//#import "TUPMediator_ContactService.h"
#import "EmployeeEntity.h"
//#import "ECSLogCofig.h"
//#import <ctk.h>

#import "ESpaceContactService.h"
#import "EmployeeEntity+ServiceObject.h"


@interface ESpaceLocalDataManager ()
@property(strong, nonatomic) NSManagedObjectModel* managedObjectModel;
@property(strong, nonatomic) NSPersistentStoreCoordinator* persistentStoreCoordinator;
@property(strong, nonatomic) NSManagedObjectContext* managedObjectContext;
@property(strong, nonatomic) NSManagedObjectContext * persistentManagedObjectContext;

@end

dispatch_queue_t espace_coredata_management_queue = 0;

@implementation ESpaceLocalDataManager

@synthesize rootChatSessionGroup = _rootChatSessionGroup;
@synthesize rootCircleSessionGroup = _rootCircleSessionGroup;
@synthesize rootPublicAccountSessionGroup = _rootPublicAccountSessionGroup;
@synthesize userDataHome = _userDataHome;
@synthesize currentUser = _currentUser;

- (id)initWithUserAccount:(NSString*)userAccount {
    if (nil == userAccount
        || 0 == userAccount.length) {
        return nil;
    }
    if (self = [self init]) {
        _userAccount = [userAccount copy];
        [self rootChatSessionGroup];
    }
    return self;
}

- (instancetype)init {
    if (self = [super init]) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            espace_coredata_management_queue = dispatch_queue_create(COREDATA_MANAGEMENT_QUEUE_NAME, 0);
        });
    }
    return self;
}

- (EmployeeEntity*) currentUser {
    if (!_currentUser) {
        
        
         _currentUser = [[ESpaceContactService sharedInstance] userWithAccount:self.userAccount inContext:[self managedObjectContext] autoCreate:YES];
        if (!_currentUser.name) {
            if ([_currentUser isKindOfClass:[EmployeeEntity class]]) {
//                EmployeeEntity* employee = (EmployeeEntity*)_currentUser;
                [(EmployeeEntity*)_currentUser reloadDetail];
            }
        }
        
//        _currentUser = [TUPMediator_ContactService M_userWithAccount:self.userAccount inContext:[self managedObjectContext] autoCreate:YES];
//        if (!_currentUser.name) {
//            [TUPMediator_ContactService M_employeeEntityReloadDetail:_currentUser];
//        }
    }
    
    return _currentUser;
}

//- (NSManagedObjectContext *)persistentManagedObjectContext {
//    if (_persistentManagedObjectContext != nil) {
//        return _persistentManagedObjectContext;
//    }
//    
//    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
//    if (coordinator != nil) {
//        _persistentManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
//        [_persistentManagedObjectContext setPersistentStoreCoordinator:coordinator];
//    }
//    return _persistentManagedObjectContext;
//
//}

- (NSManagedObjectContext*) managedObjectContext {
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }

    return _managedObjectContext;
}

- (NSManagedObjectContext*) memoryObjectContext {
    NSPersistentStoreCoordinator *coordinator = [self memoryPersistentStoreCoordinator];
    if (coordinator != nil) {
        NSManagedObjectContext* context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [context setPersistentStoreCoordinator:coordinator];
        return context;
    }
    return nil;
}

- (NSManagedObjectContext*) backgroundObjectContext {
    NSManagedObjectContext* _backgroundCtx = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    _backgroundCtx.parentContext = [self managedObjectContext];
    return _backgroundCtx;
}

- (NSManagedObjectModel *)managedObjectModel {
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    
    NSBundle *bundle = [NSBundle bundleWithIdentifier:TUP_IOS_FRAMEWORK_BUNDLE_ID];
    NSURL *modelURL = [bundle URLForResource:@"EC_SDK_MODEL" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];

    return _managedObjectModel;
}

+ (NSURL*) homeDirecotryForUser:(NSString*) userAccount {
    if ([userAccount length] == 0) {
        return nil;
    }
    NSFileManager* fileManager = [NSFileManager defaultManager];
    NSError* error;
    NSURL* retUrl = nil;
    
//    NSURL* docUrl = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    NSURL* docUrl = [[NSURL alloc] initFileURLWithPath:[ECSSandboxHelper shareInstance].documentPath isDirectory:YES];
    
    if ([ECSAppConfig sharedInstance].isUpdatedAccountCaseSensitive) {
        retUrl = [docUrl URLByAppendingPathComponent:[userAccount combinedWithMD5]];
    }
    else{
        retUrl = [docUrl URLByAppendingPathComponent:[userAccount lowercaseString]];
    }
    
    if (![fileManager fileExistsAtPath:retUrl.path]) {
        if (![fileManager createDirectoryAtURL:retUrl withIntermediateDirectories:NO attributes:nil error:&error]) {
            return nil;
        }
    }
    return retUrl;
}

+ (void) cleanDataForUser:(NSString*) userAccount {
    NSURL* url = [self homeDirecotryForUser:userAccount];
    if (url) {
        [[NSFileManager defaultManager] removeItemAtURL:url error:nil];
        BOOL bDeleted = [[ECSAppConfig sharedInstance] removeUserConfig:userAccount];
        if (bDeleted) {
            [[ECSAppConfig sharedInstance] save];
        }
    }
}

+ (void)cleanDataForAll
{
    NSArray *accounts = [[ECSAppConfig sharedInstance] allUserAccounts];
    for (NSString *userAccount in accounts)
    {
        [self cleanDataForUser:userAccount];
    }
    
    [ECSAppConfig sharedInstance].latestAccount = @"";
    
    [self cleanUserInfoFolder];
}

+ (void)cleanUserInfoFolder {
    //clean document folder
    NSString* documentPath = [ECSSandboxHelper shareInstance].documentPath;
    
    NSArray * items = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentPath error:nil];
    for (NSString* subItem in items) {
        if ([subItem isEqualToString:@"AppConfig.plist"] || [subItem isEqualToString:@"tls_certs"]) {
            continue;
        }
        NSString* subDocPath = [documentPath stringByAppendingPathComponent:subItem];
        //SDK_DEBUG_LOG("sub document path is:"<<subDocPath.UTF8String);
        [[NSFileManager defaultManager] removeItemAtPath:subDocPath error:nil];
    }
    
    //clean cache folder
    NSString* cachePath = [ECSSandboxHelper shareInstance].cachesPath;
    [[NSFileManager defaultManager] removeItemAtPath:cachePath error:nil];
    for (NSString* subItem in [[NSFileManager defaultManager] contentsOfDirectoryAtPath:cachePath error:nil]) {
        NSString* subCachePath = [cachePath stringByAppendingPathComponent:subItem];
        //SDK_DEBUG_LOG("sub cache path is:"<<subCachePath.UTF8String);
        [[NSFileManager defaultManager] removeItemAtPath:subCachePath error:nil];
    }
}

+ (void)deleteUnDirectoryItem:(NSString *)path {
    if (0 == [path length] || NO == [[NSFileManager defaultManager] fileExistsAtPath:path]) {
        return;
    }
    
    NSArray* subPaths = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil];
    for (NSString* tempStr in subPaths) {
        if ([tempStr isEqualToString:@"thumb"]) {
            continue;
        }
        NSString* tempPath = [path stringByAppendingPathComponent:tempStr];
        BOOL isDirectory;
        if ([[NSFileManager defaultManager] fileExistsAtPath:tempPath isDirectory:&isDirectory]) {
            if (isDirectory) {
                [self deleteUnDirectoryItem:tempPath];
            }
            else{
                [[NSFileManager defaultManager] removeItemAtPath:tempPath error:nil];
            }
        }
    }
}

static unsigned long long umFilesSize = 0;

+ (unsigned long long)calculateFileSize:(NSString *)path {
    if (0 == [path length] || NO == [[NSFileManager defaultManager] fileExistsAtPath:path]) {
        return 0;
    }
    
    NSArray* subPaths = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil];
    for (NSString* tempStr in subPaths) {
        if ([tempStr isEqualToString:@"thumb"]) {
            continue;
        }
        NSString* tempPath = [path stringByAppendingPathComponent:tempStr];
        BOOL isDirectory;
        if ([[NSFileManager defaultManager] fileExistsAtPath:tempPath isDirectory:&isDirectory]) {
            if (isDirectory) {
                [self calculateFileSize:tempPath];
            }
            else{
                umFilesSize += [[NSFileManager defaultManager] attributesOfItemAtPath:tempPath error:nil].fileSize;
            }
        }
    }
    
    return umFilesSize;
}

+ (void)removeUmResourceForUser:(NSString *)userAccount {
    if (0 == [userAccount length]) {
        return;
    }
    
    NSString* doucument = [ECSSandboxHelper shareInstance].documentPath;
    NSString* umDirectoryPath = [doucument stringByAppendingPathComponent:userAccount];
    
    //first step:delete image or video of im /library/account/chat/...
    NSString* chatDirectoryPath = [umDirectoryPath stringByAppendingPathComponent:@"chat"];
    [self deleteUnDirectoryItem:chatDirectoryPath];
    
    //second step:delete image or video of cicle /library/account/circle/...
    NSString* circleDirectoryPath = [umDirectoryPath stringByAppendingPathComponent:@"circle"];
    [self deleteUnDirectoryItem:circleDirectoryPath];
}

+ (unsigned long long)umFilesSizeForUser:(NSString *)userAccount {
    if (0 == [userAccount length]) {
        return 0;
    }
    
    umFilesSize = 0;
    
    NSString* doucument = [ECSSandboxHelper shareInstance].documentPath;
    NSString* umDirectoryPath = [doucument stringByAppendingPathComponent:[userAccount combinedWithMD5]];
    
    NSString* chatDirectoryPath = [umDirectoryPath stringByAppendingPathComponent:@"chat"];
    unsigned long long size = [self calculateFileSize:chatDirectoryPath];
    
//    NSString* circleDirectoryPath = [umDirectoryPath stringByAppendingPathComponent:@"circle"];
    size += [self calculateFileSize:chatDirectoryPath];
    
    return size;
}

+ (BOOL)isUserAccountExist
{
    NSArray *accounts = [[ECSAppConfig sharedInstance] allUserAccounts];
    
    if (accounts.count > 0) {
        return YES;
    }
    
    return NO;
}

- (NSURL*) userDataHome {
    if (!_userDataHome) {
        _userDataHome = [ESpaceLocalDataManager homeDirecotryForUser:self.userAccount];
    }
    return _userDataHome;
}

- (NSPersistentStoreCoordinator *) memoryPersistentStoreCoordinator {
    if (nil == self.userAccount) {
        return nil;
    }
    NSPersistentStoreCoordinator* persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    [persistentStoreCoordinator addPersistentStoreWithType:NSInMemoryStoreType configuration:nil URL:nil options:nil error:nil];
    return persistentStoreCoordinator;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (nil == self.userAccount) {
        return nil;
    }
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    NSError* error;
    NSFileManager* fileManager = [NSFileManager defaultManager];
    NSURL *storeURL = [self.userDataHome URLByAppendingPathComponent:@"eSpaceData.db"];
        [fileManager removeItemAtURL:storeURL error:nil];
    
    //SDK_DEBUG_LOG("eSpaceData data path"<<[[storeURL absoluteString] UTF8String]<<",esist is"<<[fileManager fileExistsAtPath:storeURL.path]);
    if (nil == storeURL) {
        //SDK_ERROR_LOG("NULL storeURL!");
        return nil;
    }
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    
    // handle db upgrade
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                             [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption,
                              NSSQLitePragmasOption, @{@"journal_mode":@"DELETE"}, nil];
    
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
        //SDK_ERROR_LOG("can not load data base. Terminate eSpace now...");
        return nil;
    }
    return _persistentStoreCoordinator;
}

+ (id) fetchOneObject:(NSPredicate*) predicate inEnitity:(NSString*) entityName inContext:(NSManagedObjectContext*) context {
    NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:entityName];
    [request setPredicate:predicate];
    [request setFetchLimit:1];
    
    __block NSArray* results = nil;
    [context performBlockAndWait:^{
        NSError * error = nil;
        results = [context executeFetchRequest:request error:&error];
    }];
    return [results lastObject];
}

+ (NSArray *) fetchObjects:(NSPredicate*) predicate inEnitity:(NSString*) entityName inContext:(NSManagedObjectContext*) context {
    NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:entityName];
    [request setPredicate:predicate];
    __block NSArray* results = nil;
    [context performBlockAndWait:^{
        NSError * error = nil;
        results = [context executeFetchRequest:request error:&error];
    }];
    return results;
}

- (SessionGroupEntity *)rootChatSessionGroup {
    if (!_rootChatSessionGroup) {
        _rootChatSessionGroup = [ESpaceLocalDataManager fetchOneObject:
                                     [NSPredicate predicateWithFormat:@"sessionId=%@", ROOT_CHAT_SESSION_GROUP]
                                     inEnitity:@"SessionGroupEntity"
                                     inContext:[self managedObjectContext]];
        if (!_rootChatSessionGroup) {
            _rootChatSessionGroup = [NSEntityDescription insertNewObjectForEntityForName:@"SessionGroupEntity" inManagedObjectContext:[self managedObjectContext]];
            _rootChatSessionGroup.sessionId = ROOT_CHAT_SESSION_GROUP;
//            [self.managedObjectContext save:nil];
            [self.managedObjectContext saveToPersistent];
        }
    }
    //eSpace欢迎提示语不需要再提示
    //[[ESpaceRecentSessionService sharedInstance] creatWelcomeEntity:_rootChatSessionGroup];

    return _rootChatSessionGroup;
}

- (SessionGroupEntity*) rootCircleSessionGroup {
    if (!_rootCircleSessionGroup) {
        _rootCircleSessionGroup = [ESpaceLocalDataManager rootCircleSessionGroupInContext:[self managedObjectContext]];
//        [self.managedObjectContext save:nil];
    }
    return _rootCircleSessionGroup;
}

- (SessionGroupEntity *)rootPublicAccountSessionGroup
{
    if (!_rootPublicAccountSessionGroup)
    {
        _rootPublicAccountSessionGroup = [ESpaceLocalDataManager
                                          rootPublicAccountSessionInContext:[self managedObjectContext]];
    }
    return _rootPublicAccountSessionGroup;
}

+ (SessionGroupEntity*) rootCircleSessionGroupInContext:(NSManagedObjectContext *)context {
    __block SessionGroupEntity* sessionGroup = [ESpaceLocalDataManager fetchOneObject:
                                                [NSPredicate predicateWithFormat:@"sessionId=%@", ROOT_CIRCLE_SESSION_GROUP]
                                                                            inEnitity:@"SessionGroupEntity"
                                                                            inContext:context];
    if (!sessionGroup) {
        [context performBlockAndWait:^{
            sessionGroup = [NSEntityDescription insertNewObjectForEntityForName:@"SessionGroupEntity" inManagedObjectContext:context];
            sessionGroup.sessionId = ROOT_CIRCLE_SESSION_GROUP;
            [context saveToPersistent];
        }];
        //SDK_DEBUG_LOG("Create Circle Root Entity");
    }
    return sessionGroup;
}

+ (AssistantSessionEntity *)assistantSessionEntityInContext:(NSManagedObjectContext *)ctx {
    AssistantSessionEntity* assistantSession = [ESpaceLocalDataManager fetchOneObject:[NSPredicate predicateWithFormat:@"sessionId=%@", ASSISTANT_SESSION_ENTITY] inEnitity:@"AssistantSessionEntity" inContext:ctx];
    if (!assistantSession) {
        assistantSession = [NSEntityDescription insertNewObjectForEntityForName:@"AssistantSessionEntity" inManagedObjectContext:ctx];
        assistantSession.parent = [ESpaceLocalDataManager rootChatSessionGroupInContext:ctx];
        assistantSession.sessionId = ASSISTANT_SESSION_ENTITY;
//        [ctx save:nil];
        [ctx saveToPersistent];
    }
    return assistantSession;
}

+ (SessionGroupEntity*) rootChatSessionGroupInContext:(NSManagedObjectContext*) context {
    __block SessionGroupEntity* sessionGroup = [ESpaceLocalDataManager fetchOneObject:
                                        [NSPredicate predicateWithFormat:@"sessionId=%@", ROOT_CHAT_SESSION_GROUP]
                                                                    inEnitity:@"SessionGroupEntity"
                                                                    inContext:context];
    if (!sessionGroup) {
        [context performBlockAndWait:^{
            sessionGroup = [NSEntityDescription insertNewObjectForEntityForName:@"SessionGroupEntity" inManagedObjectContext:context];
            sessionGroup.sessionId = ROOT_CHAT_SESSION_GROUP;
//            [context save:nil];
            [context saveToPersistent];
        }];
        //SDK_DEBUG_LOG("Create Chat Root Entity");
    }
    return sessionGroup;
}

+ (SessionGroupEntity*) rootCallSessionGroupInContext:(NSManagedObjectContext*) context {
    __block SessionGroupEntity* sessionGroup = [ESpaceLocalDataManager fetchOneObject:
                                                [NSPredicate predicateWithFormat:@"sessionId=%@", ROOT_CALL_SESSION_GROUP]
                                                                            inEnitity:@"SessionGroupEntity"
                                                                            inContext:context];
    if (!sessionGroup) {
        [context performBlockAndWait:^{
            sessionGroup = [NSEntityDescription insertNewObjectForEntityForName:@"SessionGroupEntity" inManagedObjectContext:context];
            sessionGroup.sessionId = ROOT_CALL_SESSION_GROUP;
//            [context save:nil];
            [context saveToPersistent];
        }];
        //SDK_DEBUG_LOG("Create Call Root Entity");
    }
    return sessionGroup;
}

+ (SessionGroupEntity *)rootPublicAccountSessionInContext:(NSManagedObjectContext *)context
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"sessionId=%@", ROOT_PUBLIC_ACCOUNT_SESSION_GROUP];
    __block SessionGroupEntity *sessionGroup = [ESpaceLocalDataManager fetchOneObject:predicate
                                                                            inEnitity:@"SessionGroupEntity"
                                                                            inContext:context];
    if (!sessionGroup)
    {
        [context performBlockAndWait:^{
            sessionGroup = [NSEntityDescription insertNewObjectForEntityForName:@"SessionGroupEntity"
                                                         inManagedObjectContext:context];
            sessionGroup.sessionId = ROOT_PUBLIC_ACCOUNT_SESSION_GROUP;
            sessionGroup.parent = [self rootChatSessionGroupInContext:context];
            sessionGroup.priority = [NSNumber numberWithInt:-1];
            sessionGroup.name = ECSLocalizedString(@"public_account", "公众号");
            sessionGroup.reportUnread = [NSNumber numberWithBool:NO];
//            [context save:nil];
            [context saveToPersistent];
        }];
    }
    return sessionGroup;
}

- (NSString*) randomMessageId {
    NSDate* now = [NSDate date];
    NSString* messageId = [NSString stringWithFormat:@"%@%@%.6d", self.userAccount, [now toNumberString], arc4random() % 1000000];
    return messageId;
}
@end
