//
//  GroupEntity+ServiceObject.m
//  eSpaceUI
//
//  Created by yemingxing on 3/25/15.
//  Copyright (c) 2015 www.huawei.com. All rights reserved.
//

#import "GroupEntity+ServiceObject.h"
//#import "eSpaceIOSSDK.h"
#import "ESpaceImageCache.h"
//#import "TUPNetworkSDK/ECSGroupManageService.h"
#import "ESpaceContactService.h"
#import <UIKit/UIKit.h>
//#import "eSpaceIOSSDK.h"
#import "ESpaceContactService.h"
//#import "ESpaceIMessageService.h"
#import "NSManagedObjectContext+Persistent.h"
//#import "ChatSessionEntity+ServiceObject.h"
#import "eSpaceDBService.h"
#import "ECSErrorCode.h"
//#import "ESpaceGroupService.h"
#import "NSManagedObject+ECS_Utility.h"
//#import <TUPMediatorSDK/TUPMediator_IMService.h>
#import "ECSUtils.h"
//#import "TUPMAALoginService.h"
//#import "ECSLogCofig.h"
//#import <ecs/ctk/ctk.h>
#import "ECSAppConfig.h"
#import "ChatMessageEntity.h"
#import "ESpaceContactHeadImageService.h"
#import "ESpaceContactNotification.h"

#import "tsdk_im_interface.h"
#import "tsdk_error_def.h"
#import "NSManagedObjectContext+Persistent.h"
#import "tsdk_def.h"

@implementation GroupEntity (ServiceObject)

- (void) muteGroup:(void (^)(NSError* error)) completionBlock {
    [self _muteSwitch:ECSMarkGroupReceiveMute completion:completionBlock];
}

- (void) unmuteGroup:(void (^)(NSError* error)) completionBlock {
    [self _muteSwitch:ECSMarkGroupReceiveUnmute completion:completionBlock];
}


- (void) _muteSwitch:(ECSMarkGroupMuteOption)muteOpt completion:(void (^)(NSError* error)) completionBlock {
    if ([self.msgRecvOpt intValue]  == muteOpt) {
        if (completionBlock) {
            completionBlock(nil);
        }
        return;
    }
    NSManagedObjectID* oid = self.objectID;
    ESpaceLocalDataManager * localManager = LOCAL_DATA_MANAGER;
    void(^muteGroupLocal)(NSError* error) = ^(NSError* error){
        NSManagedObjectContext* bgCtx = [localManager backgroundObjectContext];
        [bgCtx performBlock:^{
            GroupEntity* shadowGroup = (GroupEntity*) [bgCtx objectWithID:oid];
            shadowGroup.msgRecvOpt = [NSNumber numberWithInteger:muteOpt];
            [bgCtx saveToPersistent];
            if (completionBlock) {
                completionBlock(nil);
            }
        }];
    };
    
//    if (NO == [[ECSAppConfig sharedInstance].currentUser isSupportFunction:EN_FUNC_SERVER_MASK_GROUP_MSG]) {
//        muteGroupLocal(nil);
//    }
//    else{
        [self _lockOrMuteGroup:ChatGroupModifyMsgPromotPolicy option:muteOpt completion:^(NSError *error) {
            if (!error) {
                muteGroupLocal(nil);
            }
            else{
                muteGroupLocal(error);
            }
        }];
//    }
}

- (void) fixGroup:(void (^)(NSError* error)) completionBlock {
    [self _fixSwitch:ECSMarkGroupFixed completion:completionBlock];
}

- (void) unfixGroup:(void (^)(NSError* error)) completionBlock {
    [self _fixSwitch:ECSMarkGroupUnfixed completion:completionBlock];
}

- (void) _fixSwitch:(ECSMarkGroupFixOption) fixOpt completion:(void (^)(NSError* error)) completionBlock {
    NSManagedObjectID* oid = self.objectID;
    if ([self.fixed integerValue] == fixOpt) {
        if (completionBlock) {
            completionBlock(nil);
        }
        return;
    }

    ESpaceLocalDataManager * localManager = LOCAL_DATA_MANAGER;
    [self _lockOrMuteGroup:ChatGroupModifyFixDiscussStauts option:fixOpt completion:^(NSError *error) {
        if (!error) {
            NSManagedObjectContext* bgCtx = [localManager backgroundObjectContext];
            [bgCtx performBlock:^{
                GroupEntity* shadowGroup = (GroupEntity*) [bgCtx objectWithID:oid];
                shadowGroup.fixed = [NSNumber numberWithInteger:fixOpt];
//                [bgCtx save:nil];
                [bgCtx saveToPersistent];
                if (completionBlock) {
                    completionBlock(nil);
                }
            }];
        } else {
            if (completionBlock) {
                completionBlock(error);
            }
        }
    }];
}

- (void) _lockOrMuteGroup:(NSInteger) opType
                  option:(NSInteger) opVal
              completion:(void (^)(NSError* error)) completionBlock{
    
    TSDK_S_CHAT_GROUP_INFO group_info;
    memset(&group_info, 0, sizeof(TSDK_S_CHAT_GROUP_INFO));
    strcpy(group_info.group_id, [self.contactId UTF8String]);
    strcpy(group_info.owner_account, [self.ownerId UTF8String]);
    strcpy(group_info.group_name, [self.name UTF8String]);
    strcpy(group_info.manifesto, [self.announce UTF8String]);
    strcpy(group_info.description, [self.intro UTF8String]);
    if (opType == TSDK_E_CHAT_GROUP_MODIFY_MSG_PROMOT_POLICY) {
        group_info.is_fix_discuss = (TSDK_BOOL)opVal;
    }else if (opType == TSDK_E_CHAT_GROUP_MODIFY_FIX_DISCUSS_STAUTS){
        group_info.msg_prompt_policy = (TSDK_E_CHAT_MSG_PROMPT_POLICY)opVal;
    }else if(opType == TSDK_E_CHAT_GROUP_MODIFY_GROUP_TYPE){
        group_info.group_type = (TSDK_E_CHAT_GROUP_TYPE)opVal;
    }else{
        
    }
    
    TSDK_E_CHAT_GROUP_MODIFY_OP_TYPE op_type = (TSDK_E_CHAT_GROUP_MODIFY_OP_TYPE)opType;
    
    TSDK_RESULT result = tsdk_modify_chat_group(&group_info, op_type);
    
    if (result == TSDK_SUCCESS) {
//        ESpaceLocalDataManager * localManager = LOCAL_DATA_MANAGER;
//        NSManagedObjectID* oid = self.objectID;
//        NSManagedObjectContext* bgCtx = [localManager backgroundObjectContext];
//        [bgCtx performBlock:^{
//
//            GroupEntity* shadowGroup = (GroupEntity*) [bgCtx objectWithID:oid];
//            if (opType == TSDK_E_CHAT_GROUP_MODIFY_MSG_PROMOT_POLICY) {
//                shadowGroup.msgRecvOpt = [NSNumber numberWithInteger:opVal];
//            }else if (opType == TSDK_E_CHAT_GROUP_MODIFY_FIX_DISCUSS_STAUTS){
//                shadowGroup.groupType = [NSNumber numberWithInteger:opVal];
//            }
//            [bgCtx save:nil];
            if (completionBlock) {
                completionBlock(nil);
            }
//        }];
    }
    
    
//    ECSMarkGroup* markGroup = [ECSMarkGroup new];
//    markGroup.ActionType = @"MarkGroup";
//    markGroup.user = [[[ECSAppConfig sharedInstance] currentUser] account];
//    markGroup.opType = opType;
//    markGroup.opValue = opVal;
//    markGroup.groupID = self.contactId;
//    markGroup.groupType = [self.groupType integerValue];
//
//    [[ESpaceGroupService shareInstance].groupManageService markGroupWithRequest:markGroup completionBlock:^(ECSMarkGroupAck *retMsg, NSError *error) {
//        if (retMsg) {
//            NSError* error1 = nil;
//            if (retMsg.retval == -1) {
//                error1 = [NSError errorWithDomain:ECSGroupErrorDomain code:retMsg.retval userInfo:@{NSLocalizedFailureReasonErrorKey: retMsg.desc}];
//            }
//            if (completionBlock) {
//                completionBlock(error1);
//            }
//        } else {
//            if (completionBlock) {
//                completionBlock(error);
//            }
//        }
//    }];
}

- (void) leaveGroup:(void (^)(NSError* error)) completionBlock {
    TSDK_RESULT result = tsdk_leave_chat_group([self.contactId UTF8String], (TSDK_E_CHAT_GROUP_TYPE)[self.groupType intValue]);
    if (result == TSDK_SUCCESS) {
        ESpaceLocalDataManager * localManager = LOCAL_DATA_MANAGER;
        NSManagedObjectContext* bgCtx = [localManager backgroundObjectContext];
        NSManagedObjectID* oid = self.objectID;
        
        [bgCtx performBlock:^{
            
            GroupEntity* shadowGroup = (GroupEntity*) [bgCtx objectWithID:oid];
//            EmployeeEntity* me = [[ESpaceContactService sharedInstance] userWithAccount:LOCAL_DATA_MANAGER.userAccount inContext:bgCtx autoCreate:YES];
            if (shadowGroup && !shadowGroup.deleted) {
                shadowGroup.state = [NSNumber numberWithInteger:ESpaceGroupStateLeaveActively];
//            ChatMessageEntity* tipMsg = [TUPMediator_IMService M_createMessageForSession:shadowGroup.chatSession timestamp:[NSDate date] flag:ESpaceMessageFlagGroupStateChanged readed:YES];
            if ([shadowGroup isFixGroup]) {
//                    tipMsg.body = [NSString stringWithFormat:ECSLocalizedString(@"leave_group",@"%@已退出"),me.uiDisplayName];
                }
                else{
//                    tipMsg.body = [NSString stringWithFormat:ECSLocalizedString(@"dizgroup_leave",@"%@已退出"),me.uiDisplayName];
                }
//                [self handleNotifcationData:shadowGroup andRetMsg:retMsg withNoti:ECSGroupRemovedNofity];
                [bgCtx saveToPersistent];
                if (completionBlock) {
                    completionBlock(nil);
                }
            }
    }];
    }
}

- (void) kickUsers:(NSArray *)userAccounts
        completion:(void (^)(NSError *))completionBlock {
    TSDK_CHAR *member_account = (TSDK_CHAR *)malloc( sizeof(TSDK_CHAR));
    memset_s(member_account, sizeof(TSDK_CHAR), 0, sizeof(TSDK_CHAR));
    strcpy(&member_account[0], [(NSString *)userAccounts[0] UTF8String]);
    TSDK_RESULT result = tsdk_del_chat_group_member([self.contactId UTF8String], (TSDK_E_CHAT_GROUP_TYPE)[self.groupType intValue], member_account);
    if (result == TSDK_SUCCESS) {
        ESpaceLocalDataManager * localManager = LOCAL_DATA_MANAGER;
        NSManagedObjectContext* bgCtx = [localManager backgroundObjectContext];
        NSManagedObjectID* oid = self.objectID;
        
        GroupEntity* shadowGroup = (GroupEntity*) [bgCtx objectWithID:oid];
        
        [bgCtx performBlock:^{
            NSPredicate *predicte = [NSPredicate predicateWithFormat:@"account in %@", userAccounts];
            NSArray *employees = [ESpaceLocalDataManager fetchObjects:predicte inEnitity:@"EmployeeEntity" inContext:bgCtx];
            NSSet *employeeSet = [NSSet setWithArray:employees];
            NSMutableString* removedUsers = [NSMutableString string];
            NSInteger count = 0;
            for (; count < employees.count; ++ count) {
                EmployeeEntity* emp = employees[count];
                if (count > 0) {
                    [removedUsers appendFormat:@",%@", emp.uiDisplayName];
                } else {
                    [removedUsers appendString:emp.uiDisplayName];
                }
            }
//            NSString* msgFormate = ECSLocalizedString(@"dizgroup_delete", @"您已将%@移除讨论组");
            
//            ChatMessageEntity* tipMsg = [TUPMediator_IMService M_createMessageForSession:shadowGroup.chatSession timestamp:[NSDate date] flag:ESpaceMessageFlagGroupMemberChanged readed:YES];
//            tipMsg.body = [NSString stringWithFormat:msgFormate, removedUsers];
            [shadowGroup removeMembers:employeeSet];
            //                        [bgCtx save:nil];
//            [self handleNotifcationData:shadowGroup andRetMsg:retMsg withNoti:ECSGroupUpdatedNotify];
            [bgCtx saveToPersistent];
            if (completionBlock) {
                completionBlock(nil);
            }
        }];
    }
    
}

- (void) _leaveOrKick:(NSArray*) userAccounts
            leaveFlag:(NSInteger) flag
           completion:(void (^)(NSError* error)) completionBlock {
//    ECSLeaveGroup* leaveGroup = [ECSLeaveGroup new];
//    leaveGroup.ActionType = @"LeaveGroup";
//    leaveGroup.groupID = self.contactId;
//    leaveGroup.groupType = [self.groupType integerValue];
//    leaveGroup.user = [[[ECSAppConfig sharedInstance] currentUser] account];
//    leaveGroup.leaveFlag = flag;
//    leaveGroup.leavedList = [userAccounts componentsJoinedByString:@";"];
//    NSManagedObjectID* oid = self.objectID;
//    ESpaceLocalDataManager * localManager = LOCAL_DATA_MANAGER;
//
//    if ([self.contactId length] && userAccounts) {
//        @synchronized([ESpaceGroupService shareInstance].deletingGroupMemberInfo) {
//            [[ESpaceGroupService shareInstance].deletingGroupMemberInfo setObject:userAccounts forKey:self.contactId];
//        }
//    }
//
//    [[ESpaceGroupService shareInstance].groupManageService leaveGroupWithRequest:leaveGroup completionBlock:^(ECSLeaveGroupAck *retMsg, NSError *error) {
//        if (!error) {
//            dispatch_async(espace_coredata_management_queue, ^{
//                NSManagedObjectContext* bgCtx = [localManager backgroundObjectContext];
//                [bgCtx performBlock:^{
//                    GroupEntity* shadowGroup = (GroupEntity*) [bgCtx objectWithID:oid];
//                    EmployeeEntity* me = [[ESpaceContactService sharedInstance] userWithAccount:leaveGroup.user inContext:bgCtx autoCreate:YES];
//                    if (flag == 0) {
//                        if (shadowGroup && !shadowGroup.deleted) {
//                            shadowGroup.state = [NSNumber numberWithInteger:ESpaceGroupStateLeaveActively];
//                            ChatMessageEntity* tipMsg = [TUPMediator_IMService M_createMessageForSession:shadowGroup.chatSession timestamp:[NSDate date] flag:ESpaceMessageFlagGroupStateChanged readed:YES];
//                            if ([shadowGroup isFixGroup]) {
//                                tipMsg.body = [NSString stringWithFormat:ECSLocalizedString(@"leave_group",@"%@已退出"),me.uiDisplayName];
//                            }
//                            else{
//                                tipMsg.body = [NSString stringWithFormat:ECSLocalizedString(@"dizgroup_leave",@"%@已退出"),me.uiDisplayName];
//                            }
////                            shadowGroup.headId = shadowGroup.headId;
//                            [self handleNotifcationData:shadowGroup andRetMsg:retMsg withNoti:ECSGroupRemovedNofity];
//                            [bgCtx saveToPersistent];
//                        }
//                    } else if (flag == 1) {
//                        NSPredicate *predicte = [NSPredicate predicateWithFormat:@"account in %@", userAccounts];
//                        NSArray *employees = [ESpaceLocalDataManager fetchObjects:predicte inEnitity:@"EmployeeEntity" inContext:bgCtx];
//                        NSSet *employeeSet = [NSSet setWithArray:employees];
//                        NSMutableString* removedUsers = [NSMutableString string];
//                        NSInteger count = 0;
//                        for (; count < employees.count; ++ count) {
//                            EmployeeEntity* emp = employees[count];
//                            if (count > 0) {
//                                [removedUsers appendFormat:@",%@", emp.uiDisplayName];
//                            } else {
//                                [removedUsers appendString:emp.uiDisplayName];
//                            }
//                        }
//                        NSString* msgFormate = ECSLocalizedString(@"dizgroup_delete", @"您已将%@移除讨论组");
//
//                        ChatMessageEntity* tipMsg = [TUPMediator_IMService M_createMessageForSession:shadowGroup.chatSession timestamp:[NSDate date] flag:ESpaceMessageFlagGroupMemberChanged readed:YES];
//                        tipMsg.body = [NSString stringWithFormat:msgFormate, removedUsers];
////                        shadowGroup.headId = shadowGroup.headId;
//                        [shadowGroup removeMembers:employeeSet];
////                        [bgCtx save:nil];
//                        [self handleNotifcationData:shadowGroup andRetMsg:retMsg withNoti:ECSGroupUpdatedNotify];
//                        [bgCtx saveToPersistent];
//                    }
//
//                    if (completionBlock) {
//                        completionBlock(error);
//                    }
//                }];
//            });
//        } else {
//            if (completionBlock) {
//                completionBlock(error);
//            }
//        }
//    }];
}

- (void) inviteUsers:(NSArray*) userAccounts
                desc:(NSString*) desc
          completion:(void (^)(NSString* faildList, NSError* error)) completionBlock {
//    [self _inviteOrJoin:userAccounts desc:desc joinFlag:0 completion:completionBlock];
    
//    TSDK_S_REQ_JOIN_CHAT_GROUP_PARAM *req_join_group_param = (TSDK_S_REQ_JOIN_CHAT_GROUP_PARAM *)malloc(userAccounts.count*sizeof(TSDK_S_REQ_JOIN_CHAT_GROUP_PARAM));
//    memset_s(req_join_group_param, userAccounts.count *sizeof(TSDK_S_REQ_JOIN_CHAT_GROUP_PARAM), 0, userAccounts.count *sizeof(TSDK_S_REQ_JOIN_CHAT_GROUP_PARAM));
//
//    for (int i = 0; i < userAccounts.count; i++) {
//
//        TSDK_S_REQ_JOIN_CHAT_GROUP_PARAM req_join_group_param[i];
//        NSString *account = userAccounts[i];
//
//        req_join_group_param[i].is_invite = TSDK_TRUE;
//        req_join_group_param[i].group_type = [self.groupType intValue];
//        strcpy(req_join_group_param[i].group_id, [self.contactId UTF8String]);
//        strcpy(req_join_group_param[i].joining_account, [account UTF8String]);
//        strcpy(req_join_group_param[i].invite_account, [LOCAL_DATA_MANAGER.userAccount UTF8String]);
//        strcpy(req_join_group_param[i].group_name, [self.name UTF8String]);
//    }
//
//    TSDK_RESULT result = tsdk_request_join_chat_group(req_join_group_param);
////    free(req_join_group_param);
//
//    if (result == TSDK_SUCCESS) {
//        ESpaceLocalDataManager * localManager = LOCAL_DATA_MANAGER;
//        NSManagedObjectID* oid = self.objectID;
//
//        dispatch_async(espace_coredata_management_queue, ^{
//            NSManagedObjectContext* bgCtx = [localManager backgroundObjectContext];
//            [bgCtx performBlock:^{
//                GroupEntity* shadowGroup = (GroupEntity*) [bgCtx objectWithID:oid];
//
//                NSPredicate *predicte = [NSPredicate predicateWithFormat:@"account in %@", userAccounts];
//                NSArray *employees = [ESpaceLocalDataManager fetchObjects:predicte inEnitity:@"EmployeeEntity" inContext:bgCtx];
//                NSSet *employeeSet = [NSSet setWithArray:employees];
//                NSMutableString* removedUsers = [NSMutableString string];
//                NSInteger count = 0;
//                for (; count < employees.count; ++ count) {
//                    EmployeeEntity* emp = employees[count];
//                    if (count > 0) {
//                        [removedUsers appendFormat:@",%@", emp.uiDisplayName];
//                    } else {
//                        [removedUsers appendString:emp.uiDisplayName];
//                    }
//                }
//                //                    NSString* msgFormate = ECSLocalizedString(@"dizgroup_invite", @"您已将%@加入群组");
//                //
//                //                    ChatMessageEntity* tipMsg = [TUPMediator_IMService M_createMessageForSession:shadowGroup.chatSession timestamp:[NSDate date] flag:ESpaceMessageFlagGroupMemberChanged readed:YES];
//                //                    tipMsg.body = [NSString stringWithFormat:msgFormate, removedUsers];
//                for (EmployeeEntity* employee in employeeSet) {
//                    if (NO == [shadowGroup containsMember:employee]) {
//                        [shadowGroup addMembersObject:employee];
//                    }
//                }
//
//                //                                [self handleNotifcationData:shadowGroup andRetMsg:retMsg withNoti:ECSGroupUpdatedNotify];
//                [bgCtx saveToPersistent];
//                if (completionBlock) {
//                    completionBlock(nil,nil);
//                }
//            }];
//        });
//    }
    
    
}

- (void) inviteUser:(NSString*) userAccount
                desc:(NSString*) desc
          completion:(void (^)(NSString* faildList, NSError* error)) completionBlock
{
    TSDK_S_REQ_JOIN_CHAT_GROUP_PARAM req_join_group_param;
    memset(&req_join_group_param, 0, sizeof(TSDK_S_REQ_JOIN_CHAT_GROUP_PARAM));
    req_join_group_param.is_invite = TSDK_TRUE;
    req_join_group_param.group_type = [self.groupType intValue];
    strcpy(req_join_group_param.group_id, [self.contactId UTF8String]);
    strcpy(req_join_group_param.joining_account, [userAccount UTF8String]);
    strcpy(req_join_group_param.invite_account, [LOCAL_DATA_MANAGER.userAccount UTF8String]);
    strcpy(req_join_group_param.group_name, [self.name UTF8String]);
    
    TSDK_RESULT result = tsdk_request_join_chat_group(&req_join_group_param);
    
    if (result == TSDK_SUCCESS) {
            ESpaceLocalDataManager * localManager = LOCAL_DATA_MANAGER;
            NSManagedObjectID* oid = self.objectID;
            
            dispatch_async(espace_coredata_management_queue, ^{
                NSManagedObjectContext* bgCtx = [localManager backgroundObjectContext];
                [bgCtx performBlock:^{
                    GroupEntity* shadowGroup = (GroupEntity*) [bgCtx objectWithID:oid];
                    NSArray *userAccounts = [NSArray arrayWithObjects:userAccount, nil];
                    
                    NSPredicate *predicte = [NSPredicate predicateWithFormat:@"account in %@", userAccounts];
                    NSArray *employees = [ESpaceLocalDataManager fetchObjects:predicte inEnitity:@"EmployeeEntity" inContext:bgCtx];
                    NSSet *employeeSet = [NSSet setWithArray:employees];
                    NSMutableString* removedUsers = [NSMutableString string];
                    NSInteger count = 0;
                    for (; count < employees.count; ++ count) {
                        EmployeeEntity* emp = employees[count];
                        if (count > 0) {
                            [removedUsers appendFormat:@",%@", emp.uiDisplayName];
                        } else {
                            [removedUsers appendString:emp.uiDisplayName];
                        }
                    }
                    //                    NSString* msgFormate = ECSLocalizedString(@"dizgroup_invite", @"您已将%@加入群组");
                    //
                    //                    ChatMessageEntity* tipMsg = [TUPMediator_IMService M_createMessageForSession:shadowGroup.chatSession timestamp:[NSDate date] flag:ESpaceMessageFlagGroupMemberChanged readed:YES];
                    //                    tipMsg.body = [NSString stringWithFormat:msgFormate, removedUsers];
                    for (EmployeeEntity* employee in employeeSet) {
                        if (NO == [shadowGroup containsMember:employee]) {
                            [shadowGroup addMembersObject:employee];
                        }
                    }
                    
                    //                                [self handleNotifcationData:shadowGroup andRetMsg:retMsg withNoti:ECSGroupUpdatedNotify];
                    [bgCtx saveToPersistent];
                    if (completionBlock) {
                        completionBlock(nil,nil);
                    }
                }];
            });
    }
}

- (void) applyToJoinWithDesc:(NSString*) desc
                  completion:(void (^)(NSError* error)) completionBlock {
    [self _inviteOrJoin:[NSArray arrayWithObject:LOCAL_DATA_MANAGER.userAccount] desc:desc joinFlag:1 completion:^(NSString *faildList, NSError *error) {
        if (completionBlock) {
            completionBlock(error);
        }
    }];
}

- (void) _inviteOrJoin:(NSArray*) userAccounts
                  desc:(NSString*) desc
              joinFlag:(NSInteger) flag
            completion:(void (^)(NSString* faildList, NSError* error)) completionBlock {
//    EmployeeEntity* me = [[ESpaceContactService sharedInstance] userWithAccount:LOCAL_DATA_MANAGER.userAccount
//                                                                      inContext:self.managedObjectContext
//                                                                     autoCreate:YES];
    
    
//    ECSJoinGroup* joinGroup = [ECSJoinGroup new];
//    joinGroup.ActionType = @"JoinGroup";
//    joinGroup.groupID = self.contactId;
//    joinGroup.groupType = [self.groupType integerValue];
//    joinGroup.groupName = self.name;
//    joinGroup.user = [[[ECSAppConfig sharedInstance] currentUser] account];
//    joinGroup.inviteList = [userAccounts componentsJoinedByString:@";"];
//    joinGroup.joinFlag = flag;
//    joinGroup.desc = desc;
//    joinGroup.userName = me.name;
//
//    NSManagedObjectID* oid = self.objectID;
//    ESpaceLocalDataManager * localManager = LOCAL_DATA_MANAGER;
//    if ([self.contactId length] && userAccounts) {
//        @synchronized([ESpaceGroupService shareInstance].invitingGroupMemberInfo) {
//            [[ESpaceGroupService shareInstance].invitingGroupMemberInfo setObject:userAccounts forKey:self.contactId];
//        }
//    }
//
//    [[ESpaceGroupService shareInstance].groupManageService joinGroupWithRequest:joinGroup completionBlock:^(ECSJoinGroupAck *retMsg, NSError *error) {
//        if (!error) {
//            dispatch_async(espace_coredata_management_queue, ^{
//                NSManagedObjectContext* bgCtx = [localManager backgroundObjectContext];
//                [bgCtx performBlock:^{
//                    GroupEntity* shadowGroup = (GroupEntity*) [bgCtx objectWithID:oid];
//
//                    NSPredicate *predicte = [NSPredicate predicateWithFormat:@"account in %@", userAccounts];
//                    NSArray *employees = [ESpaceLocalDataManager fetchObjects:predicte inEnitity:@"EmployeeEntity" inContext:bgCtx];
//                    NSSet *employeeSet = [NSSet setWithArray:employees];
//                    NSMutableString* removedUsers = [NSMutableString string];
//                    NSInteger count = 0;
//                    for (; count < employees.count; ++ count) {
//                        EmployeeEntity* emp = employees[count];
//                        if (count > 0) {
//                            [removedUsers appendFormat:@",%@", emp.uiDisplayName];
//                        } else {
//                            [removedUsers appendString:emp.uiDisplayName];
//                        }
//                    }
//                    NSString* msgFormate = ECSLocalizedString(@"dizgroup_invite", @"您已将%@加入群组");
//
//                    ChatMessageEntity* tipMsg = [TUPMediator_IMService M_createMessageForSession:shadowGroup.chatSession timestamp:[NSDate date] flag:ESpaceMessageFlagGroupMemberChanged readed:YES];
//                    tipMsg.body = [NSString stringWithFormat:msgFormate, removedUsers];
//                    for (EmployeeEntity* employee in employeeSet) {
//                        if (NO == [shadowGroup containsMember:employee]) {
//                            [shadowGroup addMembersObject:employee];
//                        }
//                    }
//
//                    [self handleNotifcationData:shadowGroup andRetMsg:retMsg withNoti:ECSGroupUpdatedNotify];
//                    [bgCtx saveToPersistent];
//                }];
//            });
//        }
//
//        if (completionBlock) {
//            completionBlock(retMsg.failedList, error);
//        }
//    }];
}

- (void) updateGroupWithName:(NSString*) groupName
               joinCondition:(ECSGroupJoinType) joinCondition
                    announce:(NSString*) announce
                       intro:(NSString*) intro
                  completion:(void (^)(NSError* error)) completionBlock{
    [self updateGroupWithName:groupName enName:@"" joinCondition:joinCondition announce:announce intro:intro completion:completionBlock];
}


- (void) updateGroupWithName:(NSString*) groupName
                      enName:(NSString*) enName
               joinCondition:(ECSGroupJoinType) joinCondition
                    announce:(NSString*) announce
                       intro:(NSString*) intro
                  completion:(void (^)(NSError* error)) completionBlock{
    
    TSDK_S_CHAT_GROUP_INFO group_info;
    memset(&group_info, 0, sizeof(TSDK_S_CHAT_GROUP_INFO));
    strcpy(group_info.group_name, [groupName UTF8String]);
    strcpy(group_info.manifesto, [announce UTF8String]);
    strcpy(group_info.description, [intro UTF8String]);
    strcpy(group_info.group_id, [self.contactId UTF8String]);
    strcpy(group_info.owner_account, [self.ownerId UTF8String]);
    
    TSDK_E_CHAT_GROUP_MODIFY_OP_TYPE op_type = TSDK_E_CHAT_GROUP_MODIFY_DEFAULT_PARAM;
    
    TSDK_RESULT result = tsdk_modify_chat_group(&group_info, op_type);
    
    if (result == TSDK_SUCCESS) {
        ESpaceLocalDataManager * localManager = LOCAL_DATA_MANAGER;
        NSManagedObjectID* oid = self.objectID;
        NSManagedObjectContext* bgCtx = [localManager backgroundObjectContext];
        [bgCtx performBlock:^{
            //TODO回调中不带announce和intro  此处虽然设置成功，但是不能在ack中更新群组信息，需等待同步，因有些提示业务在同步中进行
            GroupEntity* shadowGroup = (GroupEntity*) [bgCtx objectWithID:oid];
            shadowGroup.name = groupName;
            shadowGroup.announce = announce;
            shadowGroup.intro = intro;
            shadowGroup.joinFlag = [NSNumber numberWithInt:joinCondition];
            [bgCtx save:nil];
            if (completionBlock) {
                completionBlock(nil);
            }
        }];
    }
    
    
//    ECSManageGroup* mangeGroup = [ECSManageGroup new];
//    mangeGroup.ActionType = @"ManageGroup";
//    mangeGroup.user = [[[ECSAppConfig sharedInstance] currentUser] account];
//    mangeGroup.opt = ECSGroupModify;
//    mangeGroup.groupID = self.contactId;
//    mangeGroup.announce = announce;
//    mangeGroup.groupName = groupName;
//    mangeGroup.enName = enName;
//    mangeGroup.joinCondition = joinCondition;
//    mangeGroup.intro = intro;
//    mangeGroup.groupType = [self.groupType integerValue];
//    //NSManagedObjectID* oid = self.objectID;
//    ESpaceLocalDataManager * localManager = LOCAL_DATA_MANAGER;
//
//    [[ESpaceGroupService shareInstance].groupManageService manageGroupWithRequest:mangeGroup completionBlock:^(ECSManageGroupAck *retMsg, NSError *error) {
//        if (!error) {
//            NSManagedObjectContext* bgCtx = [localManager backgroundObjectContext];
//            [bgCtx performBlock:^{
//                //此处虽然设置成功，但是不能在ack中更新群组信息，需等待同步，因有些提示业务在同步中进行
////                GroupEntity* shadowGroup = (GroupEntity*) [bgCtx objectWithID:oid];
////                shadowGroup.name = groupName;
////                shadowGroup.announce = announce;
////                shadowGroup.intro = intro;
////                shadowGroup.joinFlag = [NSNumber numberWithInt:joinCondition];
//                [bgCtx save:nil];
//                if (completionBlock) {
//                    completionBlock(error);
//                }
//            }];
//        } else {
//            if (completionBlock) {
//                completionBlock(error);
//            }
//        }
//    }];
}

- (void) changeGroupTypeTo:(ECSGroupType) gt completion:(void (^)(NSError* error)) completionBlock {
    if ([self.groupType integerValue] == gt) {
        if (completionBlock) {
            completionBlock(nil);
        }
        return;
    }
    
//    NSManagedObjectID* oid = self.objectID;
    
//    ESpaceLocalDataManager * localManager = LOCAL_DATA_MANAGER;
    [self _lockOrMuteGroup:ChatGroupModifyGroupType option:gt completion:^(NSError *error) {
        if (!error) {
//            NSManagedObjectContext* bgCtx = [localManager backgroundObjectContext];
//            [bgCtx performBlock:^{
//                GroupEntity* shadowGroup = (GroupEntity*) [bgCtx objectWithID:oid];
//                shadowGroup.groupType = [NSNumber numberWithInteger:gt];
//                //                [bgCtx save:nil];
//                [bgCtx saveToPersistent];
                if (completionBlock) {
                    completionBlock(nil);
                }
//            }];
        } else {
            if (completionBlock) {
                completionBlock(error);
            }
        }
    }];
    
    
//    ECSManageGroup* mangeGroup = [ECSManageGroup new];
//    mangeGroup.ActionType = @"ManageGroup";
//    mangeGroup.user = [[[ECSAppConfig sharedInstance] currentUser] account];
//    mangeGroup.opt = ECSGroupChangeType;
//    mangeGroup.groupID = self.contactId;
//    mangeGroup.groupType = gt;
//    mangeGroup.groupAdmin = self.ownerId;
//    mangeGroup.announce = self.announce;
//    mangeGroup.intro = self.intro;
//    NSManagedObjectID* oid = self.objectID;
//    ESpaceLocalDataManager * localManager = LOCAL_DATA_MANAGER;
//
//    [[ESpaceGroupService shareInstance].groupManageService manageGroupWithRequest:mangeGroup completionBlock:^(ECSManageGroupAck *retMsg, NSError *error) {
//        if (!error) {
//            NSManagedObjectContext* bgCtx = [localManager backgroundObjectContext];
//            [bgCtx performBlock:^{
//                GroupEntity* shadowGroup = (GroupEntity*) [bgCtx objectWithID:oid];
//                shadowGroup.groupType = [NSNumber numberWithInt:gt];
////                [bgCtx save:nil];
//                [bgCtx saveToPersistent];
//                if (completionBlock) {
//                    completionBlock(error);
//                }
//            }];
//        } else {
//            if (completionBlock) {
//                completionBlock(error);
//            }
//        }
//    }];
    
}

- (void) transferAdminTo:(EmployeeEntity*) other
              completion:(void (^)(NSError* error)) completionBlock {
    if ([other.contactId compare:self.owner.contactId] == NSOrderedSame) {
        if (completionBlock) {
            completionBlock(nil);
        }
        return;
    }
//    ECSManageGroup* mangeGroup = [ECSManageGroup new];
//    mangeGroup.ActionType = @"ManageGroup";
//    mangeGroup.user = [[[ECSAppConfig sharedInstance] currentUser] account];
//    mangeGroup.opt = ECSGroupTransferAdmin;
//    mangeGroup.groupID = self.contactId;
//    mangeGroup.groupType = [self.groupType integerValue];
//    mangeGroup.groupAdmin = other.contactId;
//    mangeGroup.announce = self.announce;
//    mangeGroup.intro = self.intro;
//
//    NSManagedObjectID* oid = self.objectID;
//    NSManagedObjectID* otherId = other.objectID;
//    ESpaceLocalDataManager * localManager = LOCAL_DATA_MANAGER;
//
//    [[ESpaceGroupService shareInstance].groupManageService manageGroupWithRequest:mangeGroup completionBlock:^(ECSManageGroupAck *retMsg, NSError *error) {
//        if (!error) {
//            NSManagedObjectContext* bgCtx = [localManager backgroundObjectContext];
//            [bgCtx performBlock:^{
//                GroupEntity* shadowGroup = (GroupEntity*) [bgCtx objectWithID:oid];
//                EmployeeEntity* shadowAdmin = (EmployeeEntity*)[bgCtx objectWithID:otherId];
//                shadowGroup.owner = shadowAdmin;
//                shadowGroup.ownerId = shadowAdmin.contactId;
////                [bgCtx save:nil];
//                [bgCtx saveToPersistent];
//                if (completionBlock) {
//                    completionBlock(error);
//                }
//            }];
//        } else {
//            if (completionBlock) {
//                completionBlock(error);
//            }
//        }
//    }];
}

- (void) dismiss:(void (^)(NSError* error)) completionBlock {
    
    TSDK_RESULT result = tsdk_del_chat_group([self.contactId UTF8String], [self.groupType intValue]);
    
    if (result == TSDK_SUCCESS) {
        {
            ESpaceLocalDataManager * localManager = LOCAL_DATA_MANAGER;
            NSManagedObjectID* oid = self.objectID;
            NSManagedObjectContext* bgCtx = [localManager backgroundObjectContext];
            [bgCtx performBlock:^{
                GroupEntity* shadowGroup = (GroupEntity*) [bgCtx objectWithID:oid];
                if (shadowGroup.managedObjectContext && !shadowGroup.deleted) {
                    shadowGroup.state = [NSNumber numberWithInteger:ESpaceGroupStateDismissed];
                }
//                ChatMessageEntity* tipMsg = [TUPMediator_IMService M_createMessageForSession:shadowGroup.chatSession timestamp:[NSDate date] flag:ESpaceMessageFlagGroupStateChanged readed:YES];
//                if ([shadowGroup isFixGroup]) {
//                    tipMsg.body = ECSLocalizedString(@"group_dismiss", @"该群组已被管理员解散");
//                } else {
//                    tipMsg.body = ECSLocalizedString(@"discussion_dismissed", @"讨论组已被解散");
//                }
//                //                [bgCtx save:nil];
                [bgCtx saveToPersistent];
                if (completionBlock) {
                    completionBlock(nil);
                }
            }];
        }
    }
    
    
    //    ECSManageGroup* mangeGroup = [ECSManageGroup new];
    //    mangeGroup.ActionType = @"ManageGroup";
    //    mangeGroup.user = [[[ECSAppConfig sharedInstance] currentUser] account];
    //    mangeGroup.opt = ECSGroupDelete;
    //    mangeGroup.groupID = self.contactId;
    //    mangeGroup.groupType = [self.groupType integerValue];
    //    mangeGroup.groupAdmin = self.ownerId;
    //
    //    ESpaceLocalDataManager * localManager = LOCAL_DATA_MANAGER;
    //    NSManagedObjectID* oid = self.objectID;
    //    [[ESpaceGroupService shareInstance].groupManageService manageGroupWithRequest:mangeGroup completionBlock:^(ECSManageGroupAck *retMsg, NSError *error) {
    //        if (!error) {
    //            NSManagedObjectContext* bgCtx = [localManager backgroundObjectContext];
    //            [bgCtx performBlock:^{
    //                GroupEntity* shadowGroup = (GroupEntity*) [bgCtx objectWithID:oid];
    //                if (shadowGroup.managedObjectContext && !shadowGroup.deleted) {
    //                    shadowGroup.state = [NSNumber numberWithInteger:ESpaceGroupStateDismissed];
    //                }
    //                ChatMessageEntity* tipMsg = [TUPMediator_IMService M_createMessageForSession:shadowGroup.chatSession timestamp:[NSDate date] flag:ESpaceMessageFlagGroupStateChanged readed:YES];
    //                if ([shadowGroup isFixGroup]) {
    //                    tipMsg.body = ECSLocalizedString(@"group_dismiss", @"该群组已被管理员解散");
    //                } else {
    //                    tipMsg.body = ECSLocalizedString(@"discussion_dismissed", @"讨论组已被解散");
    //                }
    ////                [bgCtx save:nil];
    //                [bgCtx saveToPersistent];
    //                if (completionBlock) {
    //                    completionBlock(error);
    //                }
    //            }];
    //        } else {
    //            if (completionBlock) {
    //                completionBlock(error);
    //            }
    //        }
    //    }];
    
}

- (void) queryGroupMember:(void (^)(NSError* errorm)) completionBlock {
    if (self.itemLocalStatus == ItemLoading) {
        return;
    }
    self.itemLocalStatus = ItemLoading;
    NSManagedObjectID* objId = self.objectID;
    ESpaceLocalDataManager * localManager = LOCAL_DATA_MANAGER;
    
//    TSDK_S_CHAT_GROUP_INFO group_info;
//    memset(&group_info, 0, sizeof(TSDK_S_CHAT_GROUP_INFO));
//
////    TSDK_CHAR *group_id = NULL;
////    strcpy(group_id, [self.contactId UTF8String]);
//
//    TSDK_RESULT result = tsdk_get_chat_group_detail([self.contactId UTF8String], &group_info);
    
    TSDK_S_CHAT_GROUP_MEMBER_GET_RESULT member_get_result;
    memset(&member_get_result, 0, sizeof(TSDK_S_CHAT_GROUP_MEMBER_GET_RESULT));
    
    TSDK_S_CHAT_GROUP_MEMBER_GET_PARAM member_get_param;
    memset(&member_get_param, 0, sizeof(TSDK_S_CHAT_GROUP_MEMBER_GET_PARAM));
    member_get_param.is_sync_all = TSDK_TRUE;
    strcpy(member_get_param.group_id, [self.contactId UTF8String]);
    
    TSDK_RESULT result = tsdk_get_chat_group_members(&member_get_param, &member_get_result);
    
    
    if (result == TSDK_SUCCESS) {
        dispatch_async(espace_coredata_management_queue, ^{
            NSManagedObjectContext* bgCtx = [localManager backgroundObjectContext];
            [bgCtx performBlockAndWait:^{
                GroupEntity* bgGroup = (GroupEntity*) [bgCtx objectWithID:objId];
                //                if (!error && retMsg) {
                
                NSMutableSet *originalMembers = [bgGroup.members mutableCopy];
                NSMutableSet *existMembers = [NSMutableSet setWithCapacity:0];
                
                TSDK_S_IM_USER_INFO *memberList = member_get_result.member_list;
                // 1. Add new member or update existing member.
                for (int i = 0; i < member_get_result.member_count; i++) {
                    TSDK_S_IM_USER_INFO member = memberList[i];
                    //                        // Type: 0: Added; 1: Invited but not confirmed; 2: Request but not confirmed;
                    //                        if (member.type != 0) {
                    //                            continue;
                    //                        }
                    EmployeeEntity* user = [[ESpaceContactService sharedInstance] userWithAccount:[NSString stringWithUTF8String:member.staff_account] inContext:bgCtx autoCreate:YES];
                    user.account = [NSString stringWithUTF8String:member.staff_account];
                    user.contactId = [NSString stringWithFormat:@"%lld",member.staff_id];
                    user.staffNo = [NSString stringWithUTF8String:member.staff_no];
                    user.name = [NSString stringWithUTF8String:member.name];
                    user.nativeName = [NSString stringWithUTF8String:member.native_name];
                    user.pinyinName = [NSString stringWithUTF8String:member.full_spelling];
                    if (member.gender == TSDK_E_GENDER_MALE) {
                        user.sex = @"male";
                    }
                    else if (member.gender == TSDK_E_GENDER_FEMALE){
                        user.sex = @"femail";
                    }
                    user.deptName = [NSString stringWithUTF8String:member.department_name_cn];
                    user.mobile = [NSString stringWithUTF8String:member.mobile];
                    user.homePhone = [NSString stringWithUTF8String:member.home_phone];
                    user.officePhone = [NSString stringWithUTF8String:member.office_phone];
                    user.shortNumber = [NSString stringWithUTF8String:member.short_phone];
                    user.voip = [NSString stringWithUTF8String:member.voip];
                    user.fax = [NSString stringWithUTF8String:member.fax];
                    user.email = [NSString stringWithUTF8String:member.email];
                    user.signature = [NSString stringWithUTF8String:member.signature];
                    user.address = [NSString stringWithUTF8String:member.address];
                    user.headId = [NSString stringWithUTF8String:member.image_id];
                    
                    if (![bgGroup.members containsObject:user]) {
                        [bgGroup addMembersObject:user];
                    }
                    
                    [existMembers addObject:user];
                }
                
                NSInteger state = [bgGroup.state integerValue];
                bgGroup.state = [NSNumber numberWithInteger:(ESpaceGroupStateMemberLoaded | state)];
                
                // 2. Remove expired memeber;
                [originalMembers minusSet:existMembers];
                [bgGroup removeMembers:originalMembers];
                
                
                //notification
                NSMutableArray *updateGroups = [NSMutableArray new];
                NSMutableDictionary *tempDir = [NSMutableDictionary new];
                GroupInfo *groupInfo = [[GroupInfo alloc] init];
                [bgGroup fillGroupInfo:groupInfo needGroupMember:YES];
                [groupInfo addValueForDir:tempDir];
                [updateGroups addObject:tempDir];
                if (updateGroups.count > 0) {
                    [self postNotification:ECSGroupUpdatedNotify with:updateGroups];
                }
                
                
                [bgCtx saveToPersistent];
                bgGroup.itemLocalStatus = ItemLoaded;
                if (completionBlock) {
                    completionBlock(nil);
                }

            }];
        });
        
    }else{
        
    }
    
    
//    ECSQueryGroupMembers * query = [ECSQueryGroupMembers new];
//    query.from = [[ECSAppConfig sharedInstance].currentUser account];
//    query.to = self.contactId;
//    query.type = @"get";
//    query.owner = self.owner.contactId;
//    query.groupType = [self.groupType integerValue];
//    query.query_xmlns = @"http://jabber.org/protocol/disco#items";
//    ESpaceLocalDataManager * localManager = LOCAL_DATA_MANAGER;
//
//    [[ESpaceGroupService shareInstance].groupManageService queryGroupMembersWithRequest:query completionBlock:^(ECSQueryGroupMembersAck *retMsg, NSError *error) {
//        dispatch_async(espace_coredata_management_queue, ^{
//            NSManagedObjectContext* bgCtx = [localManager backgroundObjectContext];
//            [bgCtx performBlockAndWait:^{
//                GroupEntity* bgGroup = (GroupEntity*) [bgCtx objectWithID:objId];
//                if (!error && retMsg) {
////                    if ([bgGroup.groupType integerValue] != retMsg.groupType) {
////                        bgGroup.groupType = [NSNumber numberWithInteger:retMsg.groupType];
////                    }
//
//                    NSMutableSet *originalMembers = [bgGroup.members mutableCopy];
//                    NSMutableSet *existMembers = [NSMutableSet setWithCapacity:0];
//                    // 1. Add new member or update existing member.
//                    for (ECSQueryGroupMembersAckQueryItem* member in retMsg.query.items) {
//                        // Type: 0: Added; 1: Invited but not confirmed; 2: Request but not confirmed;
//                        if (member.type != 0) {
//                            continue;
//                        }
//                        EmployeeEntity* user = [[ESpaceContactService sharedInstance] userWithAccount:member.jid inContext:bgCtx autoCreate:YES];
//                        user.account = member.jid;
//                        if (![user.name isEqualToString:member.name]) {
//                            user.name = member.name;
//                        }
//                        if (![user.nativeName isEqualToString:member.nativeName]) {
//                            user.nativeName = member.nativeName;
//                        }
//                        if ([member.headid length] > 0 && ![user.headId isEqualToString:member.headid]) {
//                            user.headId = member.headid;
//                        }
//                        user.bindNumber = member.bd;
//                        user.domain = member.domain;
//                        user.phone = member.phone;
//                        user.voip = member.voip;
//                        user.voip2 = member.voip2;
//                        user.mobile = member.mobile;
//                        user.shortNumber = member.shortnumber;
//                        user.officePhone = member.officephone;
//                        user.originMobile = member.originMobile;
//                        user.originOffice = member.originOffice;
//                        user.spDomain = member.spDomain;
//                        user.sp2 = member.sp2;
//                        user.sp2Domain = member.sp2Domain;
//                        user.m2 = member.m2;
//                        user.homePhone = member.homePhone;
//                        user.voipDomain = member.voipDomain;
//                        user.voip2Domain = member.voip2Domain;
//                        user.softClientExtPhone = member.softClientExtPhone;
//                        user.softClientExtPhoneDomain = member.softClientExtPhoneDomain;
//                        user.sp3 = member.sp3;
//                        user.sp3Domain = member.sp3Domain;
//                        user.sp4 = member.sp4;
//                        user.sp4Domain = member.sp4Domain;
//                        user.sp5 = member.sp5;
//                        user.sp5Domain = member.sp5Domain;
//                        user.sp6 = member.sp6;
//                        user.sp6Domain = member.sp6Domain;
//                        user.voip3 = member.voip3;
//                        user.voip4 = member.voip4;
//                        user.voip5 = member.voip5;
//                        user.voip6 = member.voip6;
//
//                        if (![bgGroup.members containsObject:user]) {
//                            [bgGroup addMembersObject:user];
//                        }
//
//                        [existMembers addObject:user];
//                    }
//
//                    NSInteger state = [bgGroup.state integerValue];
//                    bgGroup.state = [NSNumber numberWithInteger:(ESpaceGroupStateMemberLoaded | state)];
//
//                    // 2. Remove expired memeber;
//                    [originalMembers minusSet:existMembers];
//                    [bgGroup removeMembers:originalMembers];
//
//
//                    //notification
//                    NSMutableArray *updateGroups = [NSMutableArray new];
//                    NSMutableDictionary *tempDir = [NSMutableDictionary new];
//                    GroupInfo *groupInfo = [[GroupInfo alloc] init];
//                    [bgGroup fillGroupInfo:groupInfo needGroupMember:YES];
//                    [groupInfo addValueForDir:tempDir];
//                    [updateGroups addObject:tempDir];
//                    if (updateGroups.count > 0 && retMsg != nil) {
//                        [self postNotification:ECSGroupUpdatedNotify with:updateGroups];
//                    }
//
//
//                    [bgCtx saveToPersistent];
//                    bgGroup.itemLocalStatus = ItemLoaded;
//                    if (completionBlock) {
//                        completionBlock(error);
//                    }
//                } else if (completionBlock) {
//                    bgGroup.itemLocalStatus = ItemNotLoaded;
//                    completionBlock(error);
//                }
//            }];
//        });
//    }];
}

- (void) queryMemberInfoForGroupPic:(void (^)(NSError* error, NSArray *info)) completionBlock {
//    ECSGetGroupPic* request = [[ECSGetGroupPic alloc] init];
//    request.user = [[[ECSAppConfig sharedInstance] currentUser] account];
//    request.ActionType = @"GetGroupPic";
//    request.count = 4;
//    request.groupId = self.contactId;
//
//    [[ESpaceGroupService shareInstance].groupManageService getGroupPicWithRequest:request completionBlock:^(ECSGetGroupPicAck *retMsg, NSError *error) {
//        if (error) {
//            if (completionBlock) {
//                completionBlock(error, nil);
//            }
//        }
//        else{
//            NSMutableArray* accounts = [NSMutableArray array];
//            for (ECSGetGroupPicAckItem *item in retMsg.idList) {
//                if ([item.user length]) {
//                    [accounts addObject:item.user];
//                }
//            }
//            if (completionBlock) {
//                completionBlock(nil, accounts);
//            }
//        }
//    }];
}

- (void) loadHeadImage:(BOOL)needForceLoad completion:(void (^)(UIImage* imageData, NSError* error)) completionBlock {
    NSString* key = [self headImageKey];
    
    if (!key) {
        UIImage *image = [self defaultHeadImage];
        if (completionBlock) {
            completionBlock(image, nil);
        }
        return;
    }
    
    if (self.headLocalStatus == ItemLoaded && NO == needForceLoad) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            UIImage* image = [[ESpaceImageCache sharedInstance] imageWithKey:key];
            if (!image) {
                NSData* imageData = [[NSFileManager defaultManager] contentsAtPath:[self headImageLocalPath]];
                image = [UIImage imageWithData:imageData];
                [[ESpaceImageCache sharedInstance] setImage:image forKey:key cost:imageData.length];
            }
            if (completionBlock) {
                completionBlock(image, nil);
            }
        });
        
        return;
    }
    else if (self.headLocalStatus == ItemLoading){
        if (completionBlock) {
            completionBlock(nil, nil);
        }
        
        return;
    }
    
    //开启制作群组头像
    self.headLocalStatus = ItemLoading;
//    ECSGetGroupPic* request = [[ECSGetGroupPic alloc] init];
//    request.groupId = self.contactId;
//    NSInteger width = (NSInteger)(HEAD_IMG_WIDTH * [UIScreen mainScreen].scale);
//    NSInteger height = (NSInteger)(HEAD_IMG_HEIGHT * [UIScreen mainScreen].scale);
//    request.user = [[[ECSAppConfig sharedInstance] currentUser] account];
//    request.ActionType = @"GetGroupPic";
//    request.count = 4;
//    NSString * groupName = self.name;
//    NSManagedObjectID* objId = self.objectID;
//    NSString* localPath = [self headImageLocalPath];
//    UIImage* defGroupImage = [self defaultHeadImage];
//    ESpaceLocalDataManager * localManager = LOCAL_DATA_MANAGER;
//
//    void (^notifyUI)(BOOL, NSData*) = ^(BOOL succeed, NSData*image) {
//        dispatch_async_main_safe(^{
//            NSManagedObjectContext* mainCtx = localManager.managedObjectContext;
//            [mainCtx performBlockAndWait:^{
//                GroupEntity* mainEntity = (GroupEntity*) [mainCtx objectWithID:objId];
//                if ([mainEntity canFillFault]) {
//                    if (succeed) {
//                        [[ESpaceContactService sharedInstance].validGroupHeadImages addObject:key];
//                        mainEntity.headId = mainEntity.headId;//triger ui to update head image.
//                        mainEntity.headLocalStatus = ItemLoaded;
//                    } else {
//                        mainEntity.headLocalStatus = ItemNotLoaded;
//                    }
//                }
//
//                if (completionBlock) {
//                    completionBlock([UIImage imageWithData:image], nil);
//                }
//            }];
//        });
//    };
//
//    if ([TUPMAALoginService sharedInstance].loginService.serviceStatus != ECServiceLogin) {
//        notifyUI(NO, nil);
//        return;
//    }
//
//    [[ESpaceGroupService shareInstance].groupManageService getGroupPicWithRequest:request completionBlock:^(ECSGetGroupPicAck *retMsg, NSError *error) {
//        if (!retMsg) {
//            notifyUI(NO, nil);
//            return;
//        }
//        if (retMsg.idList.count == 1) {
//            NSData* groupData =  UIImagePNGRepresentation(defGroupImage);
//            [[ESpaceImageCache sharedInstance] setImage:defGroupImage forKey:key cost:groupData.length];
//            if (groupData) {
//                [groupData writeToFile:localPath atomically:YES];
//            }
//            notifyUI(YES, groupData);
//            return;
//        }
//        dispatch_async(espace_coredata_management_queue, ^{
//            NSManagedObjectContext* bgCtx = [localManager backgroundObjectContext];
//            ECSViewFriendHeadImage * request = [[ECSViewFriendHeadImage alloc] init];
//            ECSViewFriendHeadImageQuery *query = [[ECSViewFriendHeadImageQuery alloc] init];
//            query.xmlns = @"jabber:iq:headpic";
//
//            request.query = query;
//            request.from = [[[ECSAppConfig sharedInstance] currentUser] account];
//            request.type = @"get";
//
//            NSMutableArray* imageData = [NSMutableArray arrayWithCapacity:4];
//            NSMutableArray* queryItems = [NSMutableArray arrayWithCapacity:retMsg.idList.count];
//            NSMutableSet* members = [NSMutableSet set];
//            NSInteger defaultHeadCount = 0;
//            for (ECSGetGroupPicAckItem* item in retMsg.idList) {
//                ECSViewFriendHeadImageQueryItem* queryItem = [[ECSViewFriendHeadImageQueryItem alloc] init];
//                queryItem.width = [NSString stringWithFormat:@"%ld", (long)width];
//                queryItem.height = [NSString stringWithFormat:@"%ld", (long)height];
//                queryItem.headid = item.headid;
//                queryItem.jid = item.user;
//                EmployeeEntity* employeeEntity = [[ESpaceContactService sharedInstance] userWithAccount:item.user inContext:bgCtx autoCreate:YES];
//                if (employeeEntity.headId != item.headid) {
//                    if ([item.headid isEqualToString:INVALID_HEAD_ID]) {
//                        employeeEntity.headId = @"0";
//                        defaultHeadCount ++;
//                    } else {
//                        employeeEntity.headId = item.headid;
//                    }
//                }
//                NSDictionary* member = [[NSDictionary alloc] initWithObjectsAndKeys:employeeEntity.headId, @"headId",employeeEntity.contactId, @"contactId", nil];
//                [members addObject:member];
//                UIImage* image = [ContactEntity defaultHeadImageWithId:employeeEntity.headId];
//                BOOL bDir;
//
//                NSString* localPath = [employeeEntity headImageLocalPath];
//                if (image) {
//                    NSData* data = UIImagePNGRepresentation(image);
//                    if (data) {
//                        [imageData addObject:data];
//                    }
//                } else if ([[NSFileManager defaultManager] fileExistsAtPath:localPath isDirectory:&bDir] && !bDir) {
//                    NSData* data = [NSData dataWithContentsOfFile:localPath];
//                    if (data) {
//                        [imageData addObject:data];
//                    }
//                } else {
//                    [queryItems addObject:queryItem];
//                }
//            }
//            query.items = queryItems;
//            //            [bgCtx performBlockAndWait:^{
//            //                [bgCtx save:nil];
//            //            }];
//            [bgCtx saveToPersistentAndWait];
//
//            if (query.items.count == 0) {//数据已ready
//                //                if (defaultHeadCount == 4) {
//                //                    notifyUI(YES);
//                //                    return;
//                //                }
//                UIImage* groupImage = [GroupEntity drawGroupHeadImage:imageData width:width height:height];
//                if (groupImage) {
//                    NSData* groupData =  UIImagePNGRepresentation(groupImage);
//                    [[ESpaceImageCache sharedInstance] setImage:groupImage forKey:key cost:groupData.length];
//                    if (groupData) {
//                        [groupData writeToFile:localPath atomically:YES];
//                        notifyUI(YES, groupData);
//                        return;
//                    }
//
//                }
//
//                notifyUI(NO, nil);
//            } else {//需要从网络补充数据
//                [[ESpaceContactService sharedInstance].contactService viewFriendHeadImageWithRequest:request completionBlock:^(ECSViewFriendHeadImageAck *retMsg, NSError *error) {
//                    if (!retMsg || error) {
//                        notifyUI(NO, nil);
//                        return;
//                    }
//                    for (ECSViewFriendHeadImageAckHeadPicture* headPic in retMsg.headpictures) {
//                        NSData* data = nil;
//                        data = [[NSData alloc] initWithBase64EncodedString:headPic.picture options:NSDataBase64DecodingIgnoreUnknownCharacters];
//                        if (data) {
//                            //                            for (ECSViewFriendHeadImageQueryItem* queryItem in queryItems) {
//                            //                                if ([queryItem.jid caseInsensitiveCompare:headPic.from] == NSOrderedSame) {
//                            ////                                    [data writeToFile: localPath atomically:YES];
//                            //                                    break;
//                            //                                }
//                            //                            }
//
//                            [imageData addObject:data];
//                        }
//                    }
//                    UIImage* groupImage = [GroupEntity drawGroupHeadImage:imageData width:width height:height];
//                    if (groupImage) {
//
//                        NSData* groupData =  UIImagePNGRepresentation(groupImage);
//                        [[ESpaceImageCache sharedInstance] setImage:groupImage forKey:key cost:groupData.length];
//                        if (groupData) {
//                            [groupData writeToFile:localPath atomically:YES];
//                            notifyUI(YES, groupData);
//                            return;
//                        }
//                    }
//
//                    notifyUI(NO, nil);
//                }];
//            }
//        });
//
//    }];
}

- (void) reloadHeadImage:(BOOL)needForceLoad {
    
    [self loadHeadImage:needForceLoad completion:nil];
}

+ (UIImage*) drawGroupHeadImage:(NSArray*) imageData width:(CGFloat) width height:(CGFloat) height {
    if (imageData.count == 0) {
        return nil;
    }
    
    width = width * 2;//增加群组拼接头像大小
    height = height * 2;
    
    static CGImageRef maskRef;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(width, height), NO, 0);
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(ctx, [UIColor whiteColor].CGColor);
        CGContextFillRect(ctx, CGRectMake(0, 0, width, height));
        CGContextSetFillColorWithColor(ctx, [UIColor blackColor].CGColor);
        CGContextFillEllipseInRect(ctx, CGRectMake(0, 0, width, height));
        maskRef = CGBitmapContextCreateImage(ctx);
        UIGraphicsEndImageContext();
    });
    
//    UIImage* maskImage = [UIImage imageNamed:@"headround_mask"];
//    CGImageRef maskRef = maskImage.CGImage;
    CGImageRef mask = CGImageMaskCreate(CGImageGetWidth(maskRef), CGImageGetHeight(maskRef), CGImageGetBitsPerComponent(maskRef), CGImageGetBitsPerPixel(maskRef), CGImageGetBytesPerRow(maskRef), CGImageGetDataProvider(maskRef), NULL, false);
    UIGraphicsBeginImageContext(CGSizeMake(width, height));
    CGContextRef contextRef =  UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(contextRef, 0, height);
    CGContextScaleCTM(contextRef, 1.0, -1.0);
    for (NSUInteger index = 0; index < imageData.count; ++index) {
        CGRect imageRect = CGRectZero;
        if (imageData.count == 2) {
            imageRect = CGRectMake(index % 2 * width / 2.0, height / 4.0, width / 2.0, height / 2.0);
        }else if (imageData.count == 3){
            if (index == 2) {
                imageRect = CGRectMake(width / 4.0, height / 2.0, width / 2.0, height / 2.0);
            }else{
                imageRect = CGRectMake(index % 2 * width / 2.0 , (index / 2) * height / 2.0 , width / 2.0, height / 2.0);
            }
        }else{
            imageRect = CGRectMake(index % 2 * width / 2.0 , (index / 2) * height / 2.0 , width / 2.0, height / 2.0);
        }
        UIImage* image = [UIImage imageWithData:imageData[index]];
        CGImageRef maskedImage = CGImageCreateWithMask(image.CGImage, mask);
        CGContextDrawImage(contextRef, imageRect, maskedImage);
        CGImageRelease(maskedImage);
    }
    UIImage* groupImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    CGImageRelease(mask);
    return groupImage;
}

//- (void)favouriteGroup:(BOOL)favourited  completion:(void (^)(NSError* error)) completionBlock {
//    NSManagedObjectID* oid = self.objectID;
//    if ([self.isFavourited boolValue] == favourited) {
//        if (completionBlock) {
//            completionBlock(nil);
//        }
//        return;
//    }
//
//    ESpaceLocalDataManager * localManager = LOCAL_DATA_MANAGER;
//    NSInteger value = favourited ? 1 : 0;
//    [self _lockOrMuteGroup:ECSMarkGroupTypeFavourite option:value completion:^(NSError *error) {
//        if (!error) {
//            NSManagedObjectContext* bgCtx = [localManager backgroundObjectContext];
//            [bgCtx performBlock:^{
//                GroupEntity* shadowGroup = (GroupEntity*) [bgCtx objectWithID:oid];
//                shadowGroup.isFavourited = [NSNumber numberWithInteger:favourited];
//                [bgCtx saveToPersistent];
//
//                if (completionBlock) {
//                    completionBlock(error);
//                }
//            }];
//        } else {
//            if (completionBlock) {
//                completionBlock(error);
//            }
//        }
//    }];
//}

- (void) fillGroupInfo:(GroupInfo *)info needGroupMember:(BOOL)flag{
    info.groupId = self.contactId;
    info.groupName = self.name;
    info.groupHeadImg = @"";
    info.groupMemberNum = @"";
    info.groupMemberlist = [NSMutableArray new];
    
    if (flag) {
        //NSLog(@"----ddd-->>%d",[self.members.allObjects count]);
        for (EmployeeEntity *entity in self.members.allObjects) {
            EmployeeInfo *item = [[EmployeeInfo alloc] initWithEmployeeEntity:entity];
            NSMutableDictionary *dic = [item dirForEmployeeInfo];
            [info.groupMemberlist addObject:dic];
        }
        NSInteger count = [info.groupMemberlist count];
        info.groupMemberNum = [NSString stringWithFormat:@"%ld",(long)count];
        
    }
}

- (void)handleNotifcationData:(GroupEntity *)group andRetMsg:(id)retMsg withNoti:(NSString *)notif{
    NSMutableArray *updateGroups = [NSMutableArray new];
    NSMutableDictionary *tempDir = [NSMutableDictionary new];
    GroupInfo *groupInfo = [[GroupInfo alloc] init];
    [group fillGroupInfo:groupInfo needGroupMember:YES];
    [groupInfo addValueForDir:tempDir];
    [updateGroups addObject:tempDir];
    if (updateGroups.count > 0 && retMsg != nil) {
        [self postNotification:notif with:updateGroups];
    }
}

- (void)postNotification:(NSString *)key with:(NSMutableArray *)array{
    NSData *registerData;
    if ([NSJSONSerialization isValidJSONObject:array]) {
        NSError *error;
        registerData = [NSJSONSerialization dataWithJSONObject:array options:NSJSONWritingPrettyPrinted error:&error];
        //NSLog(@"Register JSON1111:%@",[[NSString alloc] initWithData:registerData encoding:NSUTF8StringEncoding]);
    }
    dispatch_async_main_safe(^{
        [[NSNotificationCenter defaultCenter] postNotificationName:key object:registerData];
    })
}


- (void)openGroupSpaceInfo:(void (^)(NSError* error)) completionBlock {
//    ECSManageGroup* mangeGroup = [[ECSManageGroup alloc] init];
//    mangeGroup.ActionType = @"ManageGroup";
//    mangeGroup.user = [[[ECSAppConfig sharedInstance] currentUser] account];
//    mangeGroup.opt = ECSGroupModifyGroupSpace;
//    mangeGroup.groupID = self.contactId;
//    mangeGroup.groupName = self.name;
//    mangeGroup.enName = self.enName;
//    mangeGroup.groupType = self.groupType.integerValue;
//    mangeGroup.groupAdmin = self.ownerId;
//    mangeGroup.announce = self.announce;
//    mangeGroup.intro = self.intro;
//
//    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:-1], @"groupSpaceId", nil];
//    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:0 error:nil];
//    mangeGroup.groupSpaceInfo = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
//
////    NSManagedObjectID* oid = self.objectID;
////    ESpaceLocalDataManager * localManager = LOCAL_DATA_MANAGER;
//
//    [[ESpaceGroupService shareInstance].groupManageService manageGroupWithRequest:mangeGroup completionBlock:^(ECSManageGroupAck *retMsg, NSError *error) {
//        if (completionBlock) {
//            completionBlock(error);
//        }
//    }];
}

@end
