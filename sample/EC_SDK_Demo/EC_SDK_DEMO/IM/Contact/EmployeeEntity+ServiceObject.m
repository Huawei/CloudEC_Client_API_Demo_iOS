//
//  EmployeeEntity+ServiceObject.m
//  eSpaceUI
//
//  Created by yemingxing on 3/19/15.
//  Copyright (c) 2015 www.huawei.com. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "EmployeeEntity+ServiceObject.h"
//#import "eSpaceIOSSDK.h"
#import "ESpaceImageCache.h"
#import "ESpaceContactService.h"
#import "NSDate+LocalString.h"
//#import "ESpaceCircleService.h"
#import "NSManagedObjectContext+Persistent.h"
#import "ESpaceDBService.h"
#import "ECSUtils.h"
#import "ECSErrorCode.h"
#import "ECSAppConfig.h"
//#import "ECSUserMAAInfo.h"
#import "ECSUserConfig.h"
//#import "ECSContactService.h"
//#import "TUPMAALoginService.h"
#import "ContactEntity.h"
//#import <ecs/ctk/ctk.h>
#import "ESpaceContactHeadImageService.h"





@implementation EmployeeEntity (ServiceObject)

- (BOOL) headIDValid {
    if ([self.headId length] > 0
        && [self.headId caseInsensitiveCompare:@"-1"] != NSOrderedSame) {
        return YES;
    } else {
        return NO;
    }
}

// 必须是非好友才调用此方法
- (BOOL)nonFriendMarkedLoaded
{
    BOOL bMarkedLoaded = NO;
    if ([self.contactId length] > 0) {
        bMarkedLoaded = (nil != [[ESpaceContactService sharedInstance].nonFriendsRefreshTagsDic objectForKey:self.contactId]);
    }
    
    return bMarkedLoaded;
}

- (BOOL)needReload {
    if ([self.isFriend boolValue]
        || self.managedObjectContext != LOCAL_DATA_MANAGER.managedObjectContext) {
        return NO;
    } else {
        if (!self.infoUpdateTime || ABS([self.infoUpdateTime timeIntervalSinceNow]) > ONE_DAY * 3
            || self.itemLocalStatus == ItemNotLoaded || (self.itemLocalStatus == ItemLoaded && ![self nonFriendMarkedLoaded])) {
            return YES;
        } else {
            BOOL bNeedReload = [self headIDValid] == NO;
            if (!bNeedReload) {
                //bNeedReload = [[self uiDisplayName] caseInsensitiveCompare:self.account] == NSOrderedSame;
                if (0 == [self.name length]) {
                    bNeedReload = YES;
                }
            }
            return bNeedReload;
        }
    }
}

- (void)reloadDetail
{
    [self reloadDetailWith:nil];
}

- (void)reloadDetailWith:(void (^)(NSError* error))completionBlock
{
    if (self.itemLocalStatus == ItemLoading
        || (self.itemLocalStatus == ItemLoaded && [self.isFriend boolValue])
        || (self.itemLocalStatus == ItemLoaded && ![self.isFriend boolValue] && [self nonFriendMarkedLoaded])) {
        if (completionBlock) {
            completionBlock(nil);
        }
        return;
    }
    
    NSManagedObjectID* objId = self.objectID;
    self.itemLocalStatus = ItemLoading;
    ESpaceLocalDataManager * localManager = [eSpaceDBService sharedInstance].localDataManager;
    NSManagedObjectContext* bgCtx = [localManager backgroundObjectContext];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[ESpaceContactService sharedInstance] getUserInfoWithAccount:self.account andContext:bgCtx completionBlock:^(NSManagedObjectID *objectid, NSError *error) {
//                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [bgCtx performBlockAndWait:^{
                EmployeeEntity* bgEntity = (EmployeeEntity*) [bgCtx objectWithID:objId];
                if (error) {
                    bgEntity.itemLocalStatus = ItemNotLoaded;
                }else{
                    bgEntity.itemLocalStatus = ItemLoaded;
                }
                [bgCtx saveToPersistent];
                if (completionBlock) {
                    completionBlock(error);
                }
            }];
//                    });
         
        }];
    });
}

- (void)loadHDHeadImage:(void (^)(UIImage *, NSError *))completionBlock {
    if (self.headId.length == 0)
    {
        UIImage *headImage = [self defaultHeadImage];
        if (completionBlock) {
            completionBlock(headImage, nil);
        }
        return;
    }
    
    UIImage* headImage = [[ESpaceContactHeadImageService sharedInstance] defaultEmpolyeeHeadImageWithHeadId:self.headId];
    if (headImage) {
        if (completionBlock) {
            completionBlock(headImage, nil);
        }
        return;
    }
    
    NSString* hdImgPath = [ContactEntity localPathForHeadId:self.headId account:self.account prefix:@"HD"];
    
    NSData* imageData = [[NSFileManager defaultManager] contentsAtPath:hdImgPath];
    if (imageData) {
        if (completionBlock) {
            completionBlock([UIImage imageWithData:imageData], nil);
        }
    } else {
//        ECSUserConfig* config = [[ECSAppConfig sharedInstance] currentUser];
//        NSInteger width = config.maaInfo.portraitpixelw;
//        NSInteger height = config.maaInfo.portraitpixelh;
//        width = width > 1280 ? 640 : width;
//        height = height > 1280 ? 640 :height;
//        [self loadHeadImage:width height:height path:hdImgPath completionBlock:^(NSData *imageData, NSError *error) {
//            dispatch_async_main_safe(^{
//                UIImage* image = nil;
//                if (imageData) {
//                    image = [UIImage imageWithData:imageData];
//                }
//                if (completionBlock) {
//                    completionBlock(image, error);
//                }
//            });
//        }];
    }
}

- (void) loadHeadImage:(NSInteger) width
                height:(NSInteger)height
                  path:(NSString*)path
       completionBlock:(void (^)(NSData* imageData, NSError* error)) completionBlock {
    
//    ECSViewFriendHeadImage * request = [[ECSViewFriendHeadImage alloc] init];
//    ECSViewFriendHeadImageQueryItem* queryItem = [[ECSViewFriendHeadImageQueryItem alloc] init];
//    ECSViewFriendHeadImageQuery *query = [[ECSViewFriendHeadImageQuery alloc] init];
//
//    queryItem.width = [NSString stringWithFormat:@"%ld", (long)width];
//    queryItem.height = [NSString stringWithFormat:@"%ld", (long)height];
//    queryItem.headid = self.headId;
//    queryItem.jid = self.account;
//
//    query.xmlns = @"jabber:iq:headpic";
//    query.items = [NSArray arrayWithObject:queryItem];
//
//    request.query = query;
//    request.from = [[ECSAppConfig sharedInstance] currentUser].account;
//    request.type = @"get";
//    self.headLocalStatus = ItemLoading;
//
//    [[ESpaceContactService sharedInstance].contactService viewFriendHeadImageWithRequest:request completionBlock:^(ECSViewFriendHeadImageAck *retMsg, NSError *error) {
//        NSData* data = nil;
//        if (!error) {
//            ECSViewFriendHeadImageAckHeadPicture* picture = [retMsg.headpictures lastObject];
//            if(picture.picture) {
//                data = [[NSData alloc] initWithBase64EncodedString:picture.picture options:NSDataBase64DecodingIgnoreUnknownCharacters];
//                [data writeToFile:path atomically:YES];
//            }
//        }
//        if (completionBlock) {
//            completionBlock(data, error);
//        }
//    }];
}

- (void) loadHeadImage:(void (^)(UIImage* imageData, NSError* error)) completionBlock {
    NSString* key = [self headImageKey];
    NSManagedObjectContext* mainCtx = self.managedObjectContext;
    if (!key) {
        UIImage *image = [self defaultHeadImage];
        if (completionBlock) {
            completionBlock(image, nil);
        }
        return;
    }
    NSString* imagePath = [self headImageLocalPath];
//    NSString* account = self.account;
    
//    if ([TUPMAALoginService sharedInstance].loginService.serviceStatus != ECServiceLogin) {
//        if (completionBlock) {
//            completionBlock(nil, nil);
//        }
//        return;
//    }
    
    if (self.headLocalStatus == ItemLoaded) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            UIImage* image = [[ESpaceImageCache sharedInstance] imageWithKey:key];
            if (!image) {
                NSData* imageData = [[NSFileManager defaultManager] contentsAtPath:imagePath];
                image = [UIImage imageWithData:imageData];
                [[ESpaceImageCache sharedInstance] setImage:image forKey:key cost:imageData.length];
            }
            if (completionBlock) {
                completionBlock(image, nil);
            }
        });
    } else if (self.headLocalStatus == ItemLoading) {
        if (completionBlock) {
            completionBlock(nil, nil);
        }
    } else {
        NSManagedObjectID* objId = self.objectID;
        NSInteger width = (NSInteger)(HEAD_IMG_WIDTH * [UIScreen mainScreen].scale);
        [self loadHeadImage:width height:width path:imagePath completionBlock:^(NSData *imageData, NSError *error) {
            BOOL succeeded = YES;
            UIImage* image = nil;
            if (error) {
//                SDK_INFO_LOG("Failed to load head image for user :"<<account.UTF8String<<" error number:"<<error.code<<" error:"<<error.description.UTF8String);
                if (error.code == -12) {
                    succeeded = YES;
                } else {
                    succeeded = NO;
                }
            } else {
                if(imageData) {
                    image = [UIImage imageWithData:imageData];
                    [[ESpaceImageCache sharedInstance] setImage:image forKey:key cost:imageData.length];
                    [imageData writeToFile:imagePath atomically:YES];
                }
            }
            
            dispatch_async_main_safe(^{
                EmployeeEntity* mainEntity = (EmployeeEntity*) [mainCtx objectWithID:objId];
                if (mainEntity.managedObjectContext && !mainEntity.isDeleted) {
                    mainEntity.headId = mainEntity.headId;//triger ui to update head image.
                    mainEntity.headLocalStatus = succeeded ? ItemLoaded : ItemNotLoaded;
                }
                
                if (completionBlock) {
                    completionBlock(image, succeeded ? nil : error);
                }
            });
        }];
    }
}

- (BOOL)isMe {
    NSString* currentUser = LOCAL_DATA_MANAGER.userAccount;
    return ![self.contactId compare:currentUser options:NSLiteralSearch];//要区分大小写
}

- (NSArray *)allFriends:(BOOL)onlineOnly {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isFriend == %@ AND contactId!=%@", [NSNumber numberWithBool:YES],LOCAL_DATA_MANAGER.userAccount];
    NSArray *friends = [ESpaceLocalDataManager fetchObjects:predicate inEnitity:@"PersonEntity" inContext:self.managedObjectContext];
    if (friends.count > 0) {
        NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"nameIndex" ascending:YES];
        friends = [friends sortedArrayUsingDescriptors:@[sort]];
        if (onlineOnly) {
            NSMutableArray *onlineFriends = [NSMutableArray arrayWithCapacity:0];
            for (PersonEntity *person in friends) {
                if ([person isEmployeeEnity]) {
                    EmployeeEntity *employee = (EmployeeEntity *)person;
                    EspaceUserOnlineStatus* onlineStatus = [[ESpaceContactService sharedInstance] onlineStatusForUser:employee.account forceSubscribe:![employee.isFriend boolValue]];
                    if ([onlineStatus isOnline]) {
                        [onlineFriends addObject:employee];
                    }
                }
            }
            friends = onlineFriends;
        }
    }
    return friends;
}

- (NSArray *)allEmployeeFriends:(BOOL)onlineOnly {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isFriend == %@", [NSNumber numberWithBool:YES]];
    NSArray *friends = [ESpaceLocalDataManager fetchObjects:predicate inEnitity:@"EmployeeEntity" inContext:self.managedObjectContext];
    if (friends.count > 0) {
        NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"nameIndex" ascending:YES];
        friends = [friends sortedArrayUsingDescriptors:@[sort]];
        if (onlineOnly) {
            NSMutableArray *onlineFriends = [NSMutableArray arrayWithCapacity:0];
            for (EmployeeEntity *employee in friends) {
                EspaceUserOnlineStatus* onlineStatus = [[ESpaceContactService sharedInstance] onlineStatusForUser:employee.account forceSubscribe:![employee.isFriend boolValue]];
                if ([onlineStatus isOnline]) {
                    [onlineFriends addObject:employee];
                }
            }
            friends = onlineFriends;
        }
    }
    return friends;
}

- (NSArray*)callNumsViaEspace{
    return [self callNumsViaEspace:NO andShowLimit:NO];
}

- (NSArray*)callNumsViaEspaceWithShowLimit:(BOOL)isShowLimit{
    return [self callNumsViaEspace:NO andShowLimit:isShowLimit];
}

- (NSArray*)callNumsViaEspace:(BOOL)needCombine andShowLimit:(BOOL)isShowLimit {

    NSMutableArray *results = [NSMutableArray arrayWithCapacity:1];
//    ECSUserMAAInfo *maaInfo = [[ECSAppConfig sharedInstance] currentUser].maaInfo;
//    //根据下发的状态来判断是否要显示终端号
//    BOOL isNeedShowSoftLabel = YES;
//    if ([self.bindNumber length] && [self.isBindnoShow boolValue]) {
//        CallNumberItem *item = [[CallNumberItem alloc] initWithType:ESpaceCallNumberObjectType_Softclient
//                                                                             title:ECSLocalizedString(@"user_number",@"软终端号码")
//                                                                            number:self.bindNumber
//                                                                      displayTitle:isNeedShowSoftLabel
//                                                                    hideLastNumber:NO];
//        [results addObject:item];
//        isNeedShowSoftLabel = NO;
//    }
//    //软终端号码2
//    if ([self.softClientExtPhone length]) {
//        CallNumberItem *item = [[CallNumberItem alloc] initWithType:ESpaceCallNumberObjectType_Softclient
//                                                                             title:ECSLocalizedString(@"user_number",@"软终端号码")
//                                                                            number:self.softClientExtPhone
//                                                                      displayTitle:isNeedShowSoftLabel
//                                                                    hideLastNumber:NO];
//        [results addObject:item];
//    }
//    //移动电话
//    BOOL isNeedShowMobileLabel = YES;
//    //如果需要显示限制，同时下发不支持显示，则需要隐藏
//    BOOL isNeedHiddenMobile = isShowLimit && !maaInfo.mobileShowSupport.eSpaceNumberShowSupport;
//    if ([self.mobile length] && !isNeedHiddenMobile) {
//        CallNumberItem *item = [[CallNumberItem alloc] initWithType:ESpaceCallNumberObjectType_Mobile
//                                                                             title:ECSLocalizedString(@"phone_mobile",@"移动电话")
//                                                                            number:self.mobile
//                                                                      displayTitle:isNeedShowMobileLabel
//                                                                    hideLastNumber:[[ECSAppConfig sharedInstance].currentUser hideMobileNum]];
//        [results addObject:item];
//        isNeedShowMobileLabel = NO;
//    }
//    if ([self.m2 length] && !isNeedHiddenMobile) {
//        CallNumberItem *item = [[CallNumberItem alloc] initWithType:ESpaceCallNumberObjectType_Mobile
//                                                                             title:ECSLocalizedString(@"phone_mobile",@"移动电话")
//                                                                            number:self.m2
//                                                                      displayTitle:isNeedShowMobileLabel
//                                                                    hideLastNumber:[[ECSAppConfig sharedInstance].currentUser hideMobileNum]];
//        [results addObject:item];
//        isNeedShowMobileLabel = NO;
//    }
//    if (needCombine && [self.originMobile length] && NO == [self.originMobile isEqualToString:self.mobile] &&!isNeedHiddenMobile) {
//        CallNumberItem *item = [[CallNumberItem alloc] initWithType:ESpaceCallNumberObjectType_Mobile
//                                                                             title:ECSLocalizedString(@"phone_mobile",@"移动电话")
//                                                                            number:self.originMobile
//                                                                      displayTitle:isNeedShowMobileLabel
//                                                                    hideLastNumber:[[ECSAppConfig sharedInstance].currentUser hideMobileNum]];
//        [results addObject:item];
//    }
//    //办公号码
//    BOOL isNeedShowOfficeLabel = YES;
//    //如果需要显示限制，同时下发不支持显示，则需要隐藏
//    BOOL isNeedHiddenOfficePhone = isShowLimit && !maaInfo.spShowSupport.eSpaceNumberShowSupport;
//    if ([self.shortNumber length] && !isNeedHiddenOfficePhone) {
//        CallNumberItem *item = [[CallNumberItem alloc] initWithType:ESpaceCallNumberObjectType_Office
//                                                                             title:ECSLocalizedString(@"phone_office",@"办公电话")
//                                                                            number:self.shortNumber
//                                                                      displayTitle:isNeedShowOfficeLabel
//                                                                    hideLastNumber:NO];
//        [results addObject:item];
//        isNeedShowOfficeLabel = NO;
//    }
//    //修改bmu上的固定电话会同时更改sp2字段和originOffice字段，所以这里sp2也用originoffice控制
//    //如果需要显示限制，同时下发不支持显示，则需要隐藏
//    BOOL isNeedHiddenOfficeShow = isShowLimit && !maaInfo.originOfficeShowSupport.eSpaceNumberShowSupport;
//    if ([self.sp2 length] && !isNeedHiddenOfficeShow) {
//        CallNumberItem *item = [[CallNumberItem alloc] initWithType:ESpaceCallNumberObjectType_Office
//                                                                             title:ECSLocalizedString(@"phone_office",@"办公电话")
//                                                                            number:self.sp2
//                                                                      displayTitle:isNeedShowOfficeLabel
//                                                                    hideLastNumber:NO];
//        [results addObject:item];
//        isNeedShowOfficeLabel = NO;
//    }
//    if ([self.sp3 length]) {
//        CallNumberItem *item = [[CallNumberItem alloc] initWithType:ESpaceCallNumberObjectType_Office
//                                                                             title:ECSLocalizedString(@"phone_office",@"办公电话")
//                                                                            number:self.sp3
//                                                                      displayTitle:isNeedShowOfficeLabel
//                                                                    hideLastNumber:NO];
//        [results addObject:item];
//        isNeedShowOfficeLabel = NO;
//    }
//    if ([self.sp4 length]) {
//        CallNumberItem *item = [[CallNumberItem alloc] initWithType:ESpaceCallNumberObjectType_Office
//                                                              title:ECSLocalizedString(@"phone_office",@"办公电话")
//                                                             number:self.sp4
//                                                       displayTitle:isNeedShowOfficeLabel
//                                                     hideLastNumber:NO];
//        [results addObject:item];
//        isNeedShowOfficeLabel = NO;
//    }
//    if ([self.sp5 length]) {
//        CallNumberItem *item = [[CallNumberItem alloc] initWithType:ESpaceCallNumberObjectType_Office
//                                                              title:ECSLocalizedString(@"phone_office",@"办公电话")
//                                                             number:self.sp5
//                                                       displayTitle:isNeedShowOfficeLabel
//                                                     hideLastNumber:NO];
//        [results addObject:item];
//        isNeedShowOfficeLabel = NO;
//    }
//    if ([self.sp6 length]) {
//        CallNumberItem *item = [[CallNumberItem alloc] initWithType:ESpaceCallNumberObjectType_Office
//                                                              title:ECSLocalizedString(@"phone_office",@"办公电话")
//                                                             number:self.sp6
//                                                       displayTitle:isNeedShowOfficeLabel
//                                                     hideLastNumber:NO];
//        [results addObject:item];
//        isNeedShowOfficeLabel = NO;
//    }
//    if ([self.voip length]) {
//        CallNumberItem *item = [[CallNumberItem alloc] initWithType:ESpaceCallNumberObjectType_Office
//                                                                             title:ECSLocalizedString(@"phone_office",@"办公电话")
//                                                                            number:self.voip
//                                                                      displayTitle:isNeedShowOfficeLabel
//                                                                    hideLastNumber:NO];
//        [results addObject:item];
//        isNeedShowOfficeLabel = NO;
//    }
//    if ([self.voip2 length]) {
//        CallNumberItem *item = [[CallNumberItem alloc] initWithType:ESpaceCallNumberObjectType_Office
//                                                              title:ECSLocalizedString(@"phone_office",@"办公电话")
//                                                             number:self.voip2
//                                                       displayTitle:isNeedShowOfficeLabel
//                                                     hideLastNumber:NO];
//        [results addObject:item];
//        isNeedShowOfficeLabel = NO;
//    }
//    if ([self.voip3 length]) {
//        CallNumberItem *item = [[CallNumberItem alloc] initWithType:ESpaceCallNumberObjectType_Office
//                                                              title:ECSLocalizedString(@"phone_office",@"办公电话")
//                                                             number:self.voip3
//                                                       displayTitle:isNeedShowOfficeLabel
//                                                     hideLastNumber:NO];
//        [results addObject:item];
//        isNeedShowOfficeLabel = NO;
//    }
//    if ([self.voip4 length]) {
//        CallNumberItem *item = [[CallNumberItem alloc] initWithType:ESpaceCallNumberObjectType_Office
//                                                              title:ECSLocalizedString(@"phone_office",@"办公电话")
//                                                             number:self.voip4
//                                                       displayTitle:isNeedShowOfficeLabel
//                                                     hideLastNumber:NO];
//        [results addObject:item];
//        isNeedShowOfficeLabel = NO;
//    }
//    if ([self.voip5 length]) {
//        CallNumberItem *item = [[CallNumberItem alloc] initWithType:ESpaceCallNumberObjectType_Office
//                                                              title:ECSLocalizedString(@"phone_office",@"办公电话")
//                                                             number:self.voip5
//                                                       displayTitle:isNeedShowOfficeLabel
//                                                     hideLastNumber:NO];
//        [results addObject:item];
//        isNeedShowOfficeLabel = NO;
//    }
//    if ([self.voip6 length]) {
//        CallNumberItem *item = [[CallNumberItem alloc] initWithType:ESpaceCallNumberObjectType_Office
//                                                              title:ECSLocalizedString(@"phone_office",@"办公电话")
//                                                             number:self.voip6
//                                                       displayTitle:isNeedShowOfficeLabel
//                                                     hideLastNumber:NO];
//        [results addObject:item];
//    }
//    //家庭电话
//    //如果需要显示限制，同时下发不支持显示，则需要隐藏
//    BOOL isNeedHiddenHomePhone = isShowLimit && !maaInfo.homePhoneShowSupport.eSpaceNumberShowSupport;
//    if ([self.homePhone length] && !isNeedHiddenHomePhone) {
//        CallNumberItem *item = [[CallNumberItem alloc] initWithType:ESpaceCallNumberObjectType_Home
//                                                                             title:ECSLocalizedString(@"phone_home",@"家庭电话")
//                                                                            number:self.homePhone
//                                                                      displayTitle:YES
//                                                                    hideLastNumber:NO];
//        [results addObject:item];
//    }
//    //其他电话
//    BOOL isNeedShowOtherLabel = YES;
//    //如果需要显示限制，同时下发不支持显示，则需要隐藏
//    BOOL isNeedHiddenOtherPhone = isShowLimit && !maaInfo.officePhoneShowSupport.eSpaceNumberShowSupport;
//    if ([self.officePhone length] && !isNeedHiddenOtherPhone) {
//        CallNumberItem *item = [[CallNumberItem alloc] initWithType:ESpaceCallNumberObjectType_Other
//                                                                             title:ECSLocalizedString(@"phone_other",@"其他号码")
//                                                                            number:self.officePhone
//                                                                      displayTitle:isNeedShowOtherLabel
//                                                                    hideLastNumber:NO];
//        [results addObject:item];
//        isNeedShowOtherLabel = NO;
//    }
//    if ([self.phone length] && !isNeedHiddenOtherPhone) {
//        CallNumberItem *item = [[CallNumberItem alloc] initWithType:ESpaceCallNumberObjectType_Other
//                                                                             title:ECSLocalizedString(@"phone_other",@"其他号码")
//                                                                            number:self.phone
//                                                                      displayTitle:isNeedShowOtherLabel
//                                                                    hideLastNumber:NO];
//        [results addObject:item];
//    }
    return results;
}

- (NSArray*)callNumsViaPhone{
    return [self callNumsViaPhoneWithShowLimit:NO];
}

- (NSArray*)callNumsViaPhoneWithShowLimit:(BOOL)isShowLimit {
    if (NO == [[ECSAppConfig sharedInstance].currentUser isSupportDisplayPhoneCall]) {
        return nil;
    }
    NSMutableArray* results = [[NSMutableArray alloc] initWithCapacity:10];
//    ECSUserMAAInfo *maaInfo = [[ECSAppConfig sharedInstance] currentUser].maaInfo;
//    //移动电话
//    //华为UC环境和IPT环境下不显示mobile，mobile2字段，只显示originMobile字段，其他环境不受影响
//    BOOL is_HWUC_Server = [[ECSAppConfig sharedInstance].currentUser isHWUC] || [[ECSAppConfig sharedInstance].currentUser isIPTSolution];
//    BOOL isShowMobileLabel = YES;
//    //如果需要显示限制，同时下发不支持显示，则需要隐藏
//    BOOL isNeedHiddenMobile = isShowLimit && !maaInfo.mobileShowSupport.phoneNumberShowSupport;
//    if ([self.mobile length] && NO == is_HWUC_Server && !isNeedHiddenMobile) {
//        CallNumberItem* item = [[CallNumberItem alloc] initWithType:ESpaceCallNumberObjectType_Mobile
//                                                              title:ECSLocalizedString(@"phone_mobile",@"移动电话")
//                                                             number:self.mobile
//                                                       displayTitle:isShowMobileLabel
//                                                     hideLastNumber:[[ECSAppConfig sharedInstance].currentUser hideMobileNum]];
//        [results addObject:item];
//        isShowMobileLabel = NO;
//    }
//
//    if ([self.m2 length] && NO == is_HWUC_Server && !isNeedHiddenMobile) {
//        CallNumberItem* item = [[CallNumberItem alloc] initWithType:ESpaceCallNumberObjectType_Mobile
//                                                              title:ECSLocalizedString(@"phone_mobile",@"移动电话")
//                                                             number:self.m2
//                                                       displayTitle:isShowMobileLabel
//                                                     hideLastNumber:[[ECSAppConfig sharedInstance].currentUser hideMobileNum]];
//        [results addObject:item];
//        isShowMobileLabel = NO;
//    }
//
//    if ([self.originMobile length] && !isNeedHiddenMobile) {
//        if (is_HWUC_Server || NO == [self.originMobile isEqualToString:self.mobile]) {
//            CallNumberItem* item = [[CallNumberItem alloc] initWithType:ESpaceCallNumberObjectType_Mobile
//                                                                  title:ECSLocalizedString(@"phone_mobile",@"移动电话")
//                                                                 number:self.originMobile
//                                                           displayTitle:isShowMobileLabel
//                                                         hideLastNumber:[[ECSAppConfig sharedInstance].currentUser hideMobileNum]];
//            [results addObject:item];
//        }
//    }
//    //办公号码
//    //如果需要显示限制，同时下发不支持显示，则需要隐藏
//    BOOL isNeedHiddenOfficePhone = isShowLimit && !maaInfo.originOfficeShowSupport.phoneNumberShowSupport;
//    if ([self.originOffice length] && !isNeedHiddenOfficePhone) {
//        CallNumberItem* item = [[CallNumberItem alloc] initWithType:ESpaceCallNumberObjectType_Office
//                                                              title:ECSLocalizedString(@"phone_office",@"办公电话")
//                                                             number:self.originOffice
//                                                       displayTitle:YES
//                                                     hideLastNumber:NO];
//        [results addObject:item];
//    }
//    //家庭电话
//    //如果需要显示限制，同时下发不支持显示，则需要隐藏
//    BOOL isNeedHiddenHomePhone = isShowLimit && !maaInfo.homePhoneShowSupport.phoneNumberShowSupport;
//    if ([self.homePhone length] && !isNeedHiddenHomePhone) {
//        CallNumberItem* item = [[CallNumberItem alloc] initWithType:ESpaceCallNumberObjectType_Home
//                                                              title:ECSLocalizedString(@"phone_home",@"家庭电话")
//                                                             number:self.homePhone
//                                                       displayTitle:YES
//                                                     hideLastNumber:NO];
//        [results addObject:item];
//    }
//    //其他电话
//    BOOL isShowOtherLabel = YES;
//    //如果需要显示限制，同时下发不支持显示，则需要隐藏
//    BOOL isNeedHiddenOtherPhone = isShowLimit && !maaInfo.officePhoneShowSupport.phoneNumberShowSupport;
//    if ([self.officePhone length] && !isNeedHiddenOtherPhone) {
//        CallNumberItem* item = [[CallNumberItem alloc] initWithType:ESpaceCallNumberObjectType_Other
//                                                              title:ECSLocalizedString(@"phone_other",@"其他号码")
//                                                             number:self.officePhone
//                                                       displayTitle:isShowOtherLabel
//                                                     hideLastNumber:NO];
//        [results addObject:item];
//        isShowOtherLabel = NO;
//    }
//    if ([self.phone length] && !isNeedHiddenOtherPhone) {
//        CallNumberItem* item = [[CallNumberItem alloc] initWithType:ESpaceCallNumberObjectType_Other
//                                                              title:ECSLocalizedString(@"phone_other",@"其他号码")
//                                                             number:self.phone
//                                                       displayTitle:isShowOtherLabel
//                                                     hideLastNumber:NO];
//        [results addObject:item];
//    }
    
    return results;
}

- (NSString*)defaultCallNum {
    NSString *num = nil;
//    EspaceUserOnlineStatus* userOnlineStatus = [[ESpaceContactService sharedInstance] onlineStatusForUser:self.account forceSubscribe:NO];
//    if (userOnlineStatus.clientType == ESpaceClientType_PC && userOnlineStatus.userStatus == ESpaceUserStatusAvailable) {
//        num = self.bindNumber;
//    } else {
//        if ([self.mobile length]>0) {
//            num = self.mobile;
//        }else if([self.shortNumber length]>0){
//            num = self.shortNumber;
//        }else if([self.sp2 length]>0){
//            num = self.sp2;
//        }else if([self.sp3 length]>0){
//            num = self.sp3;
//        }else if([self.sp4 length]>0){
//            num = self.sp4;
//        }else if([self.sp5 length]>0){
//            num = self.sp5;
//        }else if([self.sp6 length]>0){
//            num = self.sp6;
//        }else if([self.voip length]>0){
//            num = self.voip;
//        }else if([self.voip2 length]>0){
//            num = self.voip2;
//        }else if([self.voip3 length]>0){
//            num = self.voip3;
//        }else if([self.voip4 length]>0){
//            num = self.voip4;
//        }else if([self.voip5 length]>0){
//            num = self.voip5;
//        }else if([self.voip6 length]>0){
//            num = self.voip6;
//        }else{
//            num = self.bindNumber;
//        }
//    }
//
    return num;
}

@end

@implementation EmployeeEntity (MatchEmployee)

-(BOOL)targetString:(NSString *)strNumber matchPhoneNumber:(NSString *)number {
    if (0 == [strNumber length] || 0 == [number length]) {
        return NO;
    }
    
    //号码不大于7位，作全匹配
    if([strNumber length] <= 7 || [number length] <= 7){
        return [strNumber isEqualToString:number];
    }
    else {
        //大于7位号码，去除首位‘+’
        if('+' == [number characterAtIndex:0]){
            number = [number substringFromIndex:1];
        }
        
        if('+' == [strNumber characterAtIndex:0]){
            strNumber = [strNumber substringFromIndex:1];
        }
        
        return [strNumber hasSuffix:number] || [number hasSuffix:strNumber];//右匹配
        
    }
    return NO;
}

- (BOOL)isTargetNumber:(NSString *)targerNumber equalToOneOfPhoneNumbers:(NSArray *)phoneNumbers {
    if ([targerNumber length] == 0) {
        return NO;
    }
    if (nil == phoneNumbers) {
        return NO;
    }
    for (NSString * phoneNumber in phoneNumbers)
    {
        if ([targerNumber isEqualToString:phoneNumber]) {
            return YES;
        }
    }
    return NO;
}

// 号码字符串格式: “号码,描述;号码,描述;号码,描述;”
- (NSArray*)getNumbersFromNumberStr:(NSString*)numberList
{
    if ([numberList length] == 0) {
        return nil;
    }
    NSArray * comps = [numberList componentsSeparatedByString:@";"];
    if (nil != comps) {
        NSMutableArray * phoneNumberAry = [[NSMutableArray alloc] initWithCapacity:[comps count]];
        for (NSString * formatStr in comps) {
            if ([formatStr length] > 0) {
                NSArray * comps = [formatStr componentsSeparatedByString:@","];
                if (nil != comps) {
                    NSString* number = ([comps count] >= 1) ? [comps objectAtIndex:0] : nil;
                    //NSString* desc = ([comps count] >= 2) ? [comps objectAtIndex:1] : nil;
                    if (number) {
                        [phoneNumberAry addObject:number];
                    }
                }
            }
        }
    }
    return nil;
}

- (BOOL)containTheNumber:(NSString *)number {
    if (0 == [number length]) {
        return NO;
    }
    
    // 绑定号,voiplist,内部号码全匹配; 其余号码右匹配(大于八位,小于八位全匹配);
    if ([number isEqualToString:self.bindNumber] || [number isEqualToString:self.domain]) {
        return YES;
    }
    
    if ([self targetString:number matchPhoneNumber:self.phone]
        || [self targetString:number matchPhoneNumber:self.mobile]
        || [self targetString:number matchPhoneNumber:self.officePhone]
        || [self targetString:number matchPhoneNumber:self.shortNumber]
        || [self targetString:number matchPhoneNumber:self.originMobile]
        || [self targetString:number matchPhoneNumber:self.originOffice]
        || [number isEqualToString:self.voip]
        || [number isEqualToString:self.voip2]
        || [self targetString:number matchPhoneNumber:self.homePhone]
        || [self targetString:number matchPhoneNumber:self.m2]
        || [self targetString:number matchPhoneNumber:self.sp2]
        || [self targetString:number matchPhoneNumber:self.spDomain]
        || [self targetString:number matchPhoneNumber:self.sp2Domain]
        || [self targetString:number matchPhoneNumber:self.voipDomain]
        || [self targetString:number matchPhoneNumber:self.voip2Domain]
        || [self targetString:number matchPhoneNumber:self.softClientExtPhone]
        || [self targetString:number matchPhoneNumber:self.softClientExtPhoneDomain]
        || [self targetString:number matchPhoneNumber:self.sp3]
        || [self targetString:number matchPhoneNumber:self.sp3Domain]
        || [self targetString:number matchPhoneNumber:self.sp4]
        || [self targetString:number matchPhoneNumber:self.sp4Domain]
        || [self targetString:number matchPhoneNumber:self.sp5]
        || [self targetString:number matchPhoneNumber:self.sp5Domain]
        || [self targetString:number matchPhoneNumber:self.sp6]
        || [self targetString:number matchPhoneNumber:self.sp6Domain]
        || [self targetString:number matchPhoneNumber:self.voip3]
        || [self targetString:number matchPhoneNumber:self.voip4]
        || [self targetString:number matchPhoneNumber:self.voip5]
        || [self targetString:number matchPhoneNumber:self.voip6]) {
        return YES;
    }
    
    if ([self isTargetNumber:number equalToOneOfPhoneNumbers:[self getNumbersFromNumberStr:self.voipList]]) {
        return YES;
    }
    
    if ([self isTargetNumber:number equalToOneOfPhoneNumbers:[self getNumbersFromNumberStr:self.interPhoneList]]) {
        return YES;
    }
    
    if ([self isTargetNumber:number equalToOneOfPhoneNumbers:[self getNumbersFromNumberStr:self.phoneList]]) {
        return YES;
    }
    
    if ([self isTargetNumber:number equalToOneOfPhoneNumbers:[self getNumbersFromNumberStr:self.mobileList]]) {
        return YES;
    }
    
    if ([self isTargetNumber:number equalToOneOfPhoneNumbers:[self getNumbersFromNumberStr:self.faxList]]) {
        return YES;
    }
    
    /*
     if ([number isEqualToString:self.fullnumber] || [number isEqualToString:self.fullnumberAtDomain]) {
     return YES;
     }*/
    
    return NO;
}

+ (NSArray*)matchEmployeeWithCallNumber:(NSString*)callNumber inContext:(NSManagedObjectContext *)context
{
    if (callNumber.length == 0) {
        return nil;
    }
    
    // TODO: 性能优化
    
    NSMutableArray* matchContacts = [NSMutableArray array];
    NSArray* allContacts = [ESpaceLocalDataManager fetchObjects:nil inEnitity:@"EmployeeEntity" inContext:context];
    for (EmployeeEntity* employee in allContacts) {
        if ([employee containTheNumber:callNumber]) {
            [matchContacts addObject:employee];
        }
    }
    
    return matchContacts;
}

// TODO: chenzhiqian
//- (void)acceptCircleInvite:(void (^)(NSError * error))completionBlock {
//    ECSSetCircleRelationRecord* record = [[ECSSetCircleRelationRecord alloc] init];
//    record.targetId = self.contactId;
//    record.optType = CircleFriendRelationOptAcceptInvite;
//    [[ESpaceCircleService sharedInstance] setCircleRelationFirstUse:NO contactList:[NSArray arrayWithObject:record] completion:completionBlock];
//}
//
//- (void)refuseCircleInvite:(void (^)(NSError * error))completionBlock {
//    ECSSetCircleRelationRecord* record = [[ECSSetCircleRelationRecord alloc] init];
//    record.targetId = self.contactId;
//    record.optType = CircleFriendRelationOptRefuseInvite;
//    [[ESpaceCircleService sharedInstance] setCircleRelationFirstUse:NO contactList:[NSArray arrayWithObject:record] completion:completionBlock];
//}
//
//- (void)removeCircleFriend:(void (^)(NSError * error))completionBlock {
//    ECSSetCircleRelationRecord* record = [[ECSSetCircleRelationRecord alloc] init];
//    record.targetId = self.contactId;
//    record.optType = CircleFriendRelationOptDismiss;
//    [[ESpaceCircleService sharedInstance] setCircleRelationFirstUse:NO contactList:[NSArray arrayWithObject:record] completion:completionBlock];
//}
//
//- (void)inviteCircleFriend:(void (^)(NSError * error))completionBlock {
//    ECSSetCircleRelationRecord* record = [[ECSSetCircleRelationRecord alloc] init];
//    record.targetId = self.contactId;
//    record.optType = CircleFriendRelationOptInvite;
//    [[ESpaceCircleService sharedInstance] setCircleRelationFirstUse:NO contactList:[NSArray arrayWithObject:record] completion:completionBlock];
//}
//
//- (void) hideCircleStatus:(BOOL)bHide completion:(void (^)(NSError * error))completionBlock {
//    [[ESpaceCircleService sharedInstance] hideCircleStatus:[NSArray arrayWithObject:self.account] hide:bHide completion:completionBlock];
//}

@end
