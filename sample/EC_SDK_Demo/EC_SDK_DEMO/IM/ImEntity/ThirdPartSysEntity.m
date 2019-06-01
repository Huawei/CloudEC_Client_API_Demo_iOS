//
//  ThirdPartSysEntity.m
//  eSpaceIOSSDK
//
//  Created by s00357625 on 16/4/29.
//  Copyright © 2016年 HuaWei. All rights reserved.
//

#import "ThirdPartSysEntity.h"
#import "ECSUtils.h"
//#import "TUPMediator_ContactService.h"
//#import "ECSLogCofig.h"
//#import <ctk.h>

#import "ESpaceContactService.h"

@implementation ThirdPartSysEntity

// Insert code here to add functionality to your managed object subclass

+ (ThirdPartSysEntity *)thirdPartySysEntityWith:(NSString *)appID
                                      inContext:(NSManagedObjectContext *)ctx
{
    if ([appID length] == 0 || nil == ctx)
    {
        //SDK_INFO_LOG("param error");
//        return nil;
    }
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"appID = %@", appID];
    __block ThirdPartSysEntity *thirdPartyEntity = [ESpaceLocalDataManager fetchOneObject:predicate
                                                                                inEnitity:@"ThirdPartSysEntity"
                                                                                inContext:ctx];
    if (!thirdPartyEntity)
    {
        [ctx performBlockAndWait:^{
            NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"ThirdPartSysEntity"
                                                          inManagedObjectContext:ctx];
            thirdPartyEntity = [[ThirdPartSysEntity alloc] initWithEntity:entityDesc insertIntoManagedObjectContext:ctx];
            thirdPartyEntity.contactId = appID;
            thirdPartyEntity.appID = appID;
            [[ESpaceContactService sharedInstance] createChatSessionForContact:thirdPartyEntity];
//            [TUPMediator_ContactService M_createChatSessionForContact:thirdPartyEntity];
        }];
    }
    return thirdPartyEntity;
}

+ (ThirdPartSysEntity *)fetchThirdPartySysEntityWith:(NSString *)appID
                                           inContext:(NSManagedObjectContext *)ctx
{
    if ([appID length] == 0 || nil == ctx) {
        //SDK_INFO_LOG("param error");
//        return nil;
    }
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"appID = %@", appID];
    ThirdPartSysEntity *thirdPartyEntity = [ESpaceLocalDataManager fetchOneObject:predicate
                                                                        inEnitity:@"ThirdPartSysEntity"
                                                                        inContext:ctx];
    return thirdPartyEntity;
}

- (void)setAppName:(NSString *)appName{
    [self willChangeValueForKey:@"appName"];
//    NSString *appNameVal = [ECSUtils databaseDataEncrypt:appName];
    NSString *appNameVal = appName;
    [self setPrimitiveValue:appNameVal forKey:@"appName"];
    [self didChangeValueForKey:@"appName"];
    if (0 == [self.name length]) {
        self.name = appNameVal;
    }
}

- (NSString *)uiDisplayName{
    if ([self.appName length] > 0) {
        return self.appName;
    }else{
        return self.name;
    }
}
@end
