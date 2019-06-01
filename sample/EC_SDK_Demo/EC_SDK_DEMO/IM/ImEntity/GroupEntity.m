//
//  GroupEntity.m
//  eSpaceUI
//
//  Created by yemingxing on 3/16/15.
//  Copyright (c) 2015 www.huawei.com. All rights reserved.
//

#import "GroupEntity.h"
#import "EmployeeEntity.h"
//#import "ECSGroupManageService.h"
#import "ECSUtils.h"
#import "GroupFileEntity.h"
#import "ECSAppConfig.h"
#import "eSpaceDBService.h"


@implementation GroupEntity

@dynamic capacity;
@dynamic fixed;
@dynamic groupType;
@dynamic joinFlag;
@dynamic ownerId;
@dynamic msgRecvOpt;
@dynamic members;
@dynamic owner;
@dynamic state;
@dynamic rootFolder;
@dynamic baseFileId;
@dynamic isFavourited;
@dynamic enName;
@dynamic groupSpaceInfo;

//ECSEntryptCoreDataStringProp(announce, Announce)
//ECSEntryptCoreDataStringProp(intro, Intro)

- (NSString *)uiDisplayName {
    NSString *tempStr;
    if ([ECSAppConfig sharedInstance].isChineseLaguage) {
        tempStr = [self.name length] != 0 ? self.name : self.contactId;
    }else{
        if (self.enName.length > 0) {
            tempStr = self.enName;
        }else if(self.name.length > 0){
            tempStr = self.name;
        }else{
            tempStr = self.contactId;
        }
    }
    if (0 != [self.appName length] && [ECSUtils chargeIsThirdpartyInfo:self.appID]) {
        tempStr = [NSString stringWithFormat:@"%@ [%@]",tempStr,self.appName];
    }
    return tempStr;
}

+ (NSString*) directoryForGoupFilesWithId:(NSString*) groupId {
    if (!groupId) {
        return nil;
    }
    NSURL* url = [[[LOCAL_DATA_MANAGER userDataHome] URLByAppendingPathComponent:@"groupfile"] URLByAppendingPathComponent:groupId];
    NSFileManager * fileManager = [NSFileManager defaultManager];
    BOOL bDir = NO;
    if (![fileManager fileExistsAtPath:url.path isDirectory:&bDir]
        || !bDir) {
        [fileManager createDirectoryAtURL:url withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return url.path;
}

- (NSString*) directoryForGoupFiles {
    return [GroupEntity directoryForGoupFilesWithId:self.contactId];
}

- (NSString*) directoryForGroupFileThumbnails {
    NSString* path = [self directoryForGoupFiles];
    if (path) {
        NSString *thumbDir = [path stringByAppendingPathComponent:@"thumb"];
        NSFileManager * fileManager = [NSFileManager defaultManager];
        BOOL bDir = NO;
        if (thumbDir && (![fileManager fileExistsAtPath:thumbDir isDirectory:&bDir]
            || !bDir)) {
            [fileManager createDirectoryAtPath:thumbDir withIntermediateDirectories:YES attributes:nil error:nil];
        }
        return thumbDir;
    }
    return nil;
}


- (UIImage *)defaultHeadImage {
    return [[ESpaceContactHeadImageService sharedInstance] defaultGroupHeadImage];
}

- (NSString *)headImageLocalPath {
    return [ContactEntity localPathForHeadId:self.contactId account:self.contactId prefix: @"GroupEntity"];
}

- (NSString*) headIdFromMembers:(NSSet*) members {
    NSMutableDictionary* dic = [NSMutableDictionary dictionary];
    for (NSObject* employee in members) {
        NSString* contactId = [employee valueForKey:@"contactId"];
        NSString* headId = [employee valueForKey:@"headId"];
        if (!headId || [headId isEqualToString:INVALID_HEAD_ID]) {
            headId = @"0";
        }
        [dic setObject:headId forKey:contactId];
    }
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:dic options:0 error:nil];
    if (!jsonData) {
        return @"{}";
    }
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

- (BOOL) shouldChangeHeadIdWithMemberChanged:(NSString*) memberId headId:(NSString*) _headId {
    if (!memberId) {
        return NO;
    }
    if (!self.headId) {
        return YES;
    } else {
        NSData* jsonData = [self.headId dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary* dic = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
        if (dic) {
            NSString* headId = [dic objectForKey:memberId];
            if (headId) {
                if ([headId isEqualToString:_headId]) {
                    return NO;
                } else {
                    return YES;
                }
            } else {
                return NO;
            }
        } else {
            return YES;
        }
    }
}

- (BOOL) shouldChangeHeadIdWithMemberChanged:(EmployeeEntity*) employee {
    return [self shouldChangeHeadIdWithMemberChanged:employee.contactId headId:employee.headId];
}

- (BOOL)isFixGroup {
    return [self.groupType integerValue] == 0;
}

- (BOOL)isChatGroup {
    return [self.groupType integerValue] == 1 && [[ECSAppConfig sharedInstance].currentUser isSupportFunction:EN_FUNC_DISCUSSION_GROUP];
}

- (BOOL)checkPermission {
    EmployeeEntity *currentUser = [LOCAL_DATA_MANAGER currentUser];
    return ![self.owner.account compare:currentUser.account];
}

- (BOOL)containsMember:(EmployeeEntity *)employee {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"account ==[c] %@", employee.account];
    NSSet *set = [self.members filteredSetUsingPredicate:predicate];
    return set.count;
}

- (NSArray *)sortedMembers {
    NSMutableArray * result;
    if (self.members.count > 0) {
        NSMutableArray *source = [NSMutableArray arrayWithArray:self.members.allObjects];
        if (self.owner) {
            [source removeObject:self.owner];
        }
        
        // 1. Sort by name.
        NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
        result = [[source sortedArrayUsingDescriptors:@[sort]] mutableCopy];
        
        // 2. Owner in the first.
        if (self.owner) {
            [result insertObject:self.owner atIndex:0];
        }
    }
    
    return result;
}

- (void)localDeleteSelf {
    [self.rootFolder localDeleteSelf];
    [self removeMembers:self.members];
    [super localDeleteSelf];
}
@end


@implementation GroupInfo
- (void)addValueForDir:(NSMutableDictionary *)dir{
    if (nil != dir) {
        [dir setValue:self.groupId forKey:@"room_id"];
        [dir setValue:self.groupName forKey:@"room_name"];
        [dir setValue:self.groupHeadImg forKey:@"room_icon"];
        [dir setValue:self.groupMemberNum forKey:@"room_member_count"];
        [dir setValue:self.groupMemberlist forKey:@"room_member"];
    }
}
@end
