//
//  ChatSessionEntity+ServiceObject.m
//  eSpaceUI
//
//  Created by huawei on 15/4/21.
//  Copyright (c) 2015年 www.huawei.com. All rights reserved.
//

#import "ChatSessionEntity+ServiceObject.h"
//#import "ESpaceContactService.h"
#import "ESpaceIMessageService.h"
//#import "eSpaceIOSSDK.h"
#import "ChatMessageEntity+ServiceObject.h"
//#import "EmployeeEntity+ServiceObject.h" //sxl TODO
#import "GroupEntity.h"
#import "ECSUtils.h"
#import "ECSUtils.h"
#import "ChatMessageEntity+ServiceObject.h"
#import <AVFoundation/AVFoundation.h>
#import "MessageEntity+ServiceObject.h"
#import "NSString+Transform.h"
#import "MsgLogEntity.h"
#import "NSManagedObjectContext+Persistent.h"
//#import "eSpaceIOSService.h"
//#import "ESpaceEventRecordModel.h"
#import "ECSAppConfig.h"
#import "eSpaceDBService.h"
//#import <TUPMediatorSDK/TUPMediator_ContactService.h>
#import "ECSIMessagingServiceMessage.h"
#import "EmployeeEntity.h"
//#import "ECSUserMAAInfo.h"
//#import "ECSRecentSessionService.h"
//#import "ECSGroupManageService.h"
//#import "ESpaceRecentSessionService.h"

#import "ESpaceContactService.h"

@implementation ChatSessionEntity (ServiceObject)

- (void) sendMessage:(NSString*) messageBody
               msgEx:(NSString *)msgEx
    insertCompletion:(void (^)(NSString *messageId, NSManagedObjectID *objectID))insertCompletion
     completionBlock:(void (^)(NSError* error))completionBlock
{
    NSManagedObjectID* oid = [self objectID];
    ESpaceLocalDataManager * localManager = LOCAL_DATA_MANAGER;
    dispatch_async(espace_coredata_management_queue, ^{
        NSManagedObjectContext* bgCtx = [localManager backgroundObjectContext];
        [bgCtx performBlockAndWait:^{
            ChatSessionEntity* chatSession = (ChatSessionEntity*)[bgCtx objectWithID:oid];
            if (!chatSession.managedObjectContext || chatSession.isDeleted) {
                if (insertCompletion) {
                    insertCompletion(nil, nil);
                }
                return;
            }
            ChatMessageEntity* message = [[ESpaceContactService sharedInstance] createMessageForSession:chatSession timestamp:[NSDate date] readed:YES];
            message.from = [[ESpaceContactService sharedInstance] userWithAccount:LOCAL_DATA_MANAGER.userAccount inContext:bgCtx autoCreate:YES];
            message.to = chatSession.target;
            message.body = messageBody;
//            message.contentType = [NSNumber numberWithInteger:[message typeFromContent:message.body]];
            message.messageId = [LOCAL_DATA_MANAGER randomMessageId];
            //message.appName = @"icare";
            //message.appID = @"5";
            //message.senderType = [NSNumber numberWithInteger:ESpaceMessageFromThirdPart];//ESpaceMessageFromThirdPart;//ESpaceMessageFromEspace
//            if (!([@"eSpace" caseInsensitiveCompare:[ECSAppConfig sharedInstance].appName] == NSOrderedSame)){
//                message.appID = [ECSAppConfig sharedInstance].appID;
//                message.appName = [ECSAppConfig sharedInstance].appName;
////                message.senderType = [NSNumber numberWithInteger:ESpaceMessageFromThirdPart];
//            }
            message.msgEx = msgEx;
            
            [message checkAtPerson];
            
//                        [bgCtx save:nil];
            //保证提示语的顺序
            [bgCtx saveToPersistent];
            [message checkSensitivewWords];
            [bgCtx saveToPersistent];
            if (insertCompletion) {
                insertCompletion(message.messageId, message.objectID);
            }
            [message send:completionBlock];
        }];
    });
}

- (void) sendMessage:(NSString*) messageBody
    insertCompletion:(void (^)(NSString *messageId, NSManagedObjectID *objectID))insertCompletion
     completionBlock:(void (^)(NSError* error))completionBlock
{
    [self sendMessage:messageBody msgEx:nil insertCompletion:insertCompletion completionBlock:completionBlock];
}

- (void) sendMessage:(NSString*) messageBody completionBlock:(void (^)(NSError* error)) completionBlock
{
    [self sendMessage:messageBody insertCompletion:nil completionBlock:completionBlock];
}

- (void)sendMessage:(NSString *)messageBody
              msgEx:(NSString *)msgExContent
    completionBlock:(void (^)(NSError *))completionBlock
{
    [self sendMessage:messageBody msgEx:msgExContent insertCompletion:nil completionBlock:completionBlock];
}

- (void)updateIsAtMe
{
    NSManagedObjectID *selfID = [self objectID];
    ESpaceLocalDataManager * localManager = LOCAL_DATA_MANAGER;
    dispatch_async(espace_coredata_management_queue, ^{
        NSManagedObjectContext* bgCtx = [localManager backgroundObjectContext];
        [bgCtx performBlockAndWait:^{
            ChatSessionEntity *newSelf = (ChatSessionEntity *)[bgCtx objectWithID:selfID];
            @try {
                if (newSelf.managedObjectContext && NO == newSelf.isDeleted) {
                    newSelf.isAtMe = [NSNumber numberWithBool:NO];
                    [bgCtx saveToPersistent];
                }
            }
            @catch (NSException *exception) {
            }
        }];
    });
}

//- (void)forwardMessage:(ChatMessageEntity *)originMessage completionBlock:(void (^)(NSError *))completionBlock {
//    NSManagedObjectID* oid = [self objectID];
//    NSManagedObjectID *originMsgObjectID = [originMessage objectID];
//    ESpaceLocalDataManager * localManager = LOCAL_DATA_MANAGER;
//    dispatch_async(espace_coredata_management_queue, ^{
//        NSManagedObjectContext* bgCtx = [localManager backgroundObjectContext];
//        [bgCtx performBlockAndWait:^{
//            ChatSessionEntity* chatSession = (ChatSessionEntity*)[bgCtx objectWithID:oid];
//            ChatMessageEntity *message = (ChatMessageEntity *)[bgCtx objectWithID:originMsgObjectID];
//            ChatMessageEntity* forwardMsg = [[ESpaceIMessageService sharedInstance] createMessageForSession:chatSession  timestamp:[NSDate date] readed:YES];
//            forwardMsg.from = [TUPMediator_ContactService M_userWithAccount:LOCAL_DATA_MANAGER.userAccount inContext:bgCtx autoCreate:YES];
//
//            forwardMsg.to = chatSession.target;
//            [forwardMsg reuseMessageBody:message];
//            forwardMsg.contentType = message.contentType;
//            forwardMsg.transferStatus = [NSNumber numberWithInteger:ESpaceMsgStatusSending];
//            forwardMsg.messageId = [LOCAL_DATA_MANAGER randomMessageId];
//
//            [forwardMsg checkAtPerson];
//            //保证提示语的顺序
//            [bgCtx saveToPersistent];
//            [forwardMsg checkSensitivewWords];
//            [bgCtx saveToPersistent];
//            [forwardMsg send:completionBlock];
//        }];
//    });
//}

//- (void) sendUMMessage:(ESpaceUMResource*)umResource completionBlock:(void (^)(NSError* error)) completionBlock {
//    NSManagedObjectID* oid = [self objectID];
//    ESpaceLocalDataManager * localManager = LOCAL_DATA_MANAGER;
//    dispatch_async(espace_coredata_management_queue, ^{
//        NSManagedObjectContext* bgCtx = [localManager backgroundObjectContext];
//        [bgCtx performBlockAndWait:^{
//            ChatSessionEntity* chatSession = (ChatSessionEntity*)[bgCtx objectWithID:oid];
//            ChatMessageEntity* message = [[ESpaceIMessageService sharedInstance] createMessageForSession:chatSession  timestamp:[NSDate date] readed:YES];
//            message.from = [TUPMediator_ContactService M_userWithAccount:LOCAL_DATA_MANAGER.userAccount inContext:bgCtx autoCreate:YES];
//            message.to = chatSession.target;
//            [message reuseUMResourceBody:umResource];
//            message.contentType = [NSNumber numberWithInteger:[message typeFromContent:message.body]];
//            message.transferStatus = [NSNumber numberWithInteger:ESpaceMsgStatusSending];
//            message.messageId = [LOCAL_DATA_MANAGER randomMessageId];
//            
//            //            [bgCtx save:nil];
//            [bgCtx saveToPersistent];
//            [message send:completionBlock];
//        }];
//    });
//}

//- (void) sendPublicAccountMessage:(ESpacePublicAccountMessage*) msg completionBlock:(void (^)(NSError* error)) completionBlock {
//    NSManagedObjectID* oid = [self objectID];
//    ESpaceLocalDataManager * localManager = LOCAL_DATA_MANAGER;
//    dispatch_async(espace_coredata_management_queue, ^{
//        NSManagedObjectContext* bgCtx = [localManager backgroundObjectContext];
//        [bgCtx performBlockAndWait:^{
//            ChatSessionEntity* chatSession = (ChatSessionEntity*)[bgCtx objectWithID:oid];
//            ChatMessageEntity* message = [[ESpaceIMessageService sharedInstance] createMessageForSession:chatSession  timestamp:[NSDate date] readed:YES];
//            message.from = [TUPMediator_ContactService M_userWithAccount:LOCAL_DATA_MANAGER.userAccount inContext:bgCtx autoCreate:YES];
//            message.to = chatSession.target;
//            message.body = [msg description];
//            message.contentType = [NSNumber numberWithInteger:ESpacePublicAccountContentType];
//            message.transferStatus = [NSNumber numberWithInteger:ESpaceMsgStatusSending];
//            message.messageId = [LOCAL_DATA_MANAGER randomMessageId];
//
//            if (msg.umResource) {
//                [message umResourceByReuseUMResourceLocalFile:msg.umResource keepOriginal:YES encrypted:[msg.umResource remoteResource] && [msg.umResource needEncrypt]];
//            }
//
//            //            [bgCtx save:nil];
//            [bgCtx saveToPersistent];
//            [message send:completionBlock];
//        }];
//    });
//
//}
//- (void) sendSharedLinkMessage:(ESpaceSharedLinkMessage*) msg completionBlock:(void (^)(NSError* error)) completionBlock {
//    NSManagedObjectID* oid = [self objectID];
//    ESpaceLocalDataManager * localManager = LOCAL_DATA_MANAGER;
//    dispatch_async(espace_coredata_management_queue, ^{
//        NSManagedObjectContext* bgCtx = [localManager backgroundObjectContext];
//        [bgCtx performBlockAndWait:^{
//            ChatSessionEntity* chatSession = (ChatSessionEntity*)[bgCtx objectWithID:oid];
//            ChatMessageEntity* message = [[ESpaceIMessageService sharedInstance] createMessageForSession:chatSession  timestamp:[NSDate date] readed:YES];
//            message.from = [TUPMediator_ContactService M_userWithAccount:LOCAL_DATA_MANAGER.userAccount inContext:bgCtx autoCreate:YES];
//            message.to = chatSession.target;
//
//            if (msg.umResource) {
//                [message reuseShareLineMessageBody:msg];
//            }
//
//            message.contentType = [NSNumber numberWithInteger:ESpaceShareLinkContentType];
//            message.transferStatus = [NSNumber numberWithInteger:ESpaceMsgStatusSending];
//            message.messageId = [LOCAL_DATA_MANAGER randomMessageId];
//
//            //            [bgCtx save:nil];
//            [bgCtx saveToPersistent];
//            [message send:completionBlock];
//        }];
//    });
//
//}

//+ (NSString*) mergeChatMessages:(NSArray*) ackMessages
//                         readed:(BOOL)readed
//                    chatSession:(ChatSessionEntity*)chatSession {
//    NSArray* logs = [ackMessages sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
//        ECSGetRoamingMsgAckMessage* msg1 = obj1;
//        ECSGetRoamingMsgAckMessage* msg2 = obj2;
//        long long t1 = [msg1.id longLongValue];
//        long long t2 = [msg2.id longLongValue];
//        return t1 < t2 ? NSOrderedAscending : ((t1 > t2) ? NSOrderedDescending : NSOrderedSame);
//    }];
//    ECSGetRoamingMsgAckMessage* firstMsg = [logs firstObject];
//    for (ECSGetRoamingMsgAckMessage* message in logs) {
//        [self createMessageWithAck:message readed:readed chatSession:chatSession];
//    }
//
//    //    if ([chatSession.managedObjectContext hasChanges]) {
//    //        [chatSession.managedObjectContext save:nil];
//    //    }
//    [chatSession.managedObjectContext saveToPersistent];
//    return firstMsg.id;
//}
//
//+ (ChatMessageEntity*) createMessageWithAck:(ECSGetRoamingMsgAckMessage*) message
//                                     readed:(BOOL)readed
//                                chatSession:(ChatSessionEntity*)chatSession {
//    NSManagedObjectContext *ctx = chatSession.managedObjectContext;
//    ContactEntity *from = nil;
//    if (message.senderType == ESpaceMessageFromThirdSys) {
//        from = [TUPMediator_ContactService M_systemInfoWithAppID:message.appID inContex:ctx autoCreat:YES];
//    }else{
//        from = [TUPMediator_ContactService M_userWithAccount:message.from inContext:ctx autoCreate:YES];
//    }
//    //EmployeeEntity* from = [[ESpaceContactService sharedInstance] userWithAccount:message.from inContext:chatSession.managedObjectContext autoCreate:YES];
//    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"session=%@ AND messageId=%@", chatSession, message.id];
//    ChatMessageEntity* messageEntity = [ESpaceLocalDataManager fetchOneObject:predicate inEnitity:@"ChatMessageEntity" inContext:chatSession.managedObjectContext];
//    NSString * userAccount = LOCAL_DATA_MANAGER.userAccount;
//    if (!messageEntity) {
//        if ([chatSession.target isKindOfClass:[GroupEntity class]]) {
//            GroupEntity* group = (GroupEntity*)chatSession.target;
//            NSInteger state = [group.state integerValue];
//            if ((ESpaceGroupStateMemberLoaded & state) != ESpaceGroupStateMemberLoaded
//                && from &&[from isKindOfClass:[EmployeeEntity class]] && ![group.members containsObject:from]) {
//                [group addMembersObject:(EmployeeEntity *)from];
//            }
//        }
//
//        NSArray* subContentArray = [NSArray arrayWithObject:message.body];
//        if (message.contentType != ESpaceShareLinkContentType
//            && message.contentType != ESpacePublicAccountContentType) {
//            subContentArray = [message.body analysisStringWithRegularExpression:@"/:um_begin(.*?)/:um_end"];;
//        }
//        for (int i = 0 ; i < subContentArray.count ;i++) {
//            NSString* subString = [subContentArray objectAtIndex:i];
//            long long index = i;
//            NSDate* timestamp = [NSDate date];
//            if (message.milltime) {
//                timestamp = [NSDate dateWithTimeIntervalSince1970:((message.milltime + index) / 1000.0)];
//            }
//            BOOL isRead = index == 0 ? readed : YES;
//            if (!isRead) {
//                if ([userAccount compare:message.from] == NSOrderedSame) {
//                    isRead = YES;
//                }
//            }
//            messageEntity = [[ESpaceIMessageService sharedInstance] createMessageForSession:chatSession timestamp:timestamp readed:isRead];
//
//
//            messageEntity.from = from;
//            messageEntity.to = chatSession.target;
//            messageEntity.messageId = message.id;
//            messageEntity.readDetail = [NSNumber numberWithBool:YES];
//            messageEntity.body = subString;
//            messageEntity.msgEx = message.msgEx;
//            messageEntity.senderType = [NSNumber numberWithInteger:message.senderType];
//            messageEntity.appID = message.appID;
//            messageEntity.appName = message.appName;
//            if (subContentArray.count >= 2) {
//                messageEntity.subIndex = [NSNumber numberWithInteger:i + 1];
//            }else{
//                messageEntity.subIndex = [NSNumber numberWithInteger:i];
//            }
//            messageEntity.contentType = [NSNumber numberWithInteger:[messageEntity contentTypeFromServerValue:message.contentType content:subString]] ;
//
//            if (messageEntity.contentType.unsignedIntegerValue != ESpaceTextContentType) {
//                [messageEntity downloadThumbnails];
//            }
//        }
//    }
//    else{//若本地消息已经存在，则其状态标记为传入的值
//        messageEntity.readed = [NSNumber numberWithBool:readed];
//    }
//    return messageEntity;
//}
//
//- (void) loadMessageBasedId:(NSString*)messageID
//                     readed:(BOOL)readed
//                      count:(NSInteger)loadeCount
//                 completion:(void (^)(NSError* error, NSInteger count)) completionBlock {
//    BOOL isGroupMessage = NO;
//    ECSGetRoamingMsg* roamingMsg = [[ECSGetRoamingMsg alloc] init];
//    roamingMsg.ActionType = @"GetRoamingMsg";
//    roamingMsg.msgID = messageID ? messageID : @"";
//    roamingMsg.recordAmount = loadeCount;
//    roamingMsg.targetID = self.target.contactId;
//    roamingMsg.user = [[ECSAppConfig sharedInstance] currentUser].account;
//    isGroupMessage = [self.target isGroupEntity];
//    roamingMsg.msgTag = isGroupMessage ? 2 : 1;
//    NSManagedObjectID* oid = [self objectID];
//    ESpaceLocalDataManager * localManager = LOCAL_DATA_MANAGER;
//
//    [[ESpaceIMessageService sharedInstance].imessageService getRoamingMsgWithRequest:roamingMsg completionBlock:^(ECSGetRoamingMsgAck *retMsg, NSError *error) {
//        dispatch_async(espace_coredata_management_queue, ^{
//            NSManagedObjectContext* bgCtx = [localManager backgroundObjectContext];
//            [bgCtx performBlockAndWait:^{
//                if (retMsg) {
//                    ChatSessionEntity* chatSession = (ChatSessionEntity*)[bgCtx objectWithID:oid];
//                    NSString* validMessageId = [ChatSessionEntity mergeChatMessages:retMsg.logList readed:readed chatSession:chatSession];
//                    [[ESpaceIMessageService sharedInstance].validSessions setObject:validMessageId forKey:chatSession.target.contactId];
//                }
//
//                if (completionBlock) {
//                    completionBlock(error, retMsg.logList.count);
//                }
//            }];
//        });
//    }];
//}
//
///**
// *  查询漫游历史消息
// *
// *  @param beginId         查询的基准ID
// *  @param readed          查询返回的记录需要标记的状态
// *  @param loadCount       查询记录的数目
// *  @param completionBlock 查询回调
// */
//- (void) queryRoamingMessageBasedId:(NSString*)beginId
//                             readed:(BOOL)readed
//                              count:(NSInteger)loadCount
//                         completion:(void (^)(NSError* error, NSInteger count, NSArray* msgLogIdList)) completionBlock {
//    BOOL isGroupMessage = NO;
//    ECSGetRoamingMsg* roamingMsg = [[ECSGetRoamingMsg alloc] init];
//    roamingMsg.ActionType = @"GetRoamingMsg";
//    roamingMsg.msgID = beginId;
//    roamingMsg.recordAmount = loadCount;
//    roamingMsg.targetID = self.target.contactId;
//    roamingMsg.user = [[ECSAppConfig sharedInstance] currentUser].account;
//    isGroupMessage = [self.target isGroupEntity];
//    roamingMsg.msgTag = isGroupMessage ? 2 : 1;
//    NSManagedObjectID* oid = [self objectID];
//    ESpaceLocalDataManager * localManager = LOCAL_DATA_MANAGER;
//
//    //群组不存在
//    if (isGroupMessage) {
//        GroupEntity* group = (GroupEntity*)self.target;
//        NSInteger groupState = [group.state integerValue];
//        if (groupState != ESpaceGroupStateExist && groupState != ESpaceGroupStateMemberLoaded) {
//            completionBlock(nil, 0, nil);
//            return;
//        }
//    }
//
//    long long startTime = ( long long)[[NSDate date] timeIntervalSince1970]*1000;
//
//    [[ESpaceIMessageService sharedInstance].imessageService getRoamingMsgWithRequest:roamingMsg completionBlock:^(ECSGetRoamingMsgAck *retMsg, NSError *error) {
//
//        //added by  wwx276172
//        if (!error ) {
//            NSTimeInterval nowTime = [[NSDate date] timeIntervalSince1970]*1000;
//            long long  offsetTime = ( long long)nowTime - startTime;
//            //su TODO
////            if ((offsetTime > 0))
////                [[ESpaceEventRecordModel shareEventRecordModel]  recordCapabilityWithId:CAPABLE_ROAMING_ONEPAGE_ID
////                                                                           withDuration:(NSInteger)offsetTime
////                                                                         withCustomInfo:[NSString stringWithFormat:@"%ld",(long)loadCount]];
//        }
//        dispatch_async(espace_coredata_management_queue, ^{
//            NSManagedObjectContext* bgCtx = [localManager backgroundObjectContext];
//            [bgCtx performBlockAndWait:^{
//                NSMutableArray* msglogIdList = [NSMutableArray array];//回传给调用者
//
//                if (retMsg) {
//                    ChatSessionEntity* chatSession = (ChatSessionEntity*)[bgCtx objectWithID:oid];
//                    BOOL isChatSessionAlreadyShow = [chatSession.priority integerValue] < 0 ? NO :YES;
//
//                    if (chatSession.managedObjectContext && !chatSession.isDeleted) {
//
//                        NSMutableArray* alreadExistMessageId = [NSMutableArray array];
//                        NSManagedObjectContext * bgCtx = chatSession.managedObjectContext;
//                        for (ECSGetRoamingMsgAckMessage* message in retMsg.logList) {
//
//                            if ([message.id length]) {
//                                [msglogIdList addObject:message.id];
//                            }
//
//                            //自己换工号场景处理
//                            NSString* oldStaffNo = [ECSAppConfig sharedInstance].currentUser.maaInfo.oldstaffNo;
//                            if ([oldStaffNo length]) {
//                                //DDLogDebug(@"触发自己工号切换流程");  //su TODO
//                                if ([message.from isEqualToString:oldStaffNo]) {
//                                    message.from = [ECSAppConfig sharedInstance].currentUser.account;
//                                }
//                                if ([message.to isEqualToString:oldStaffNo]) {
//                                    message.to = [ECSAppConfig sharedInstance].currentUser.account;
//                                }
//                            }
//                            //EmployeeEntity* from = [[ESpaceContactService sharedInstance] userWithAccount:message.from inContext:bgCtx autoCreate:YES];
//                            ContactEntity* to = nil;
//                            ContactEntity *from = nil;
//                            //判断是否是系统消息
//                            if (ESpaceMessageFromThirdSys == message.senderType) {
//                                from = [TUPMediator_ContactService M_systemInfoWithAppID:message.appID inContex:bgCtx autoCreat:YES];
//                            }else{
//                                from = [TUPMediator_ContactService M_userWithAccount:message.from inContext:bgCtx autoCreate:YES];
//                            }
//                            if (isGroupMessage) {
//                                to = chatSession.target;
//                            }
//                            else{
//                                if ([message.from length] > 0) {
//                                   from.contactId = message.from;
//                                }
//                                to = [TUPMediator_ContactService M_userWithAccount:message.to inContext:bgCtx autoCreate:YES];
//                            }
//
//                            NSPredicate* predicate = [NSPredicate predicateWithFormat:@"session=%@ AND messageId=%@", chatSession, message.id];
//
//                            if ([message.cid length]) {//判断本地是否有显示失败实际发送成功的消息，要进行去重
//                                predicate = [NSPredicate predicateWithFormat:@"session=%@ AND (messageId=%@ OR messageId=%@)", chatSession, message.id, message.cid];
//                            }
//
//                            ChatMessageEntity* messageEntity = [ESpaceLocalDataManager fetchOneObject:predicate inEnitity:@"ChatMessageEntity" inContext:chatSession.managedObjectContext];
//                            //群组中添加成员不建议在此处处理，在成员被剔除，其他成员获取漫游消息的场景下会有问题
////                            if (isGroupMessage) {
////                                GroupEntity* group = (GroupEntity*)chatSession.target;
////                                NSInteger groupState = [group.state integerValue];
////                                if ((groupState & ESpaceGroupStateMemberLoaded) != ESpaceGroupStateMemberLoaded
////                                    ) {
////                                    if (from && [from isKindOfClass:[EmployeeEntity class]] && ![group.members containsObject:from]) {
////                                        [group addMembersObject:(EmployeeEntity *)from];
////                                    }
////                                }
////                            }
//                            if (!messageEntity) {
//
//                                //多图文消息兼容,公众号转发消息、链接分享不进行解析
//                                NSArray* subContentArray = [NSArray arrayWithObject:@""];
//                                if (message.body) {
//                                    subContentArray = [NSArray arrayWithObject:message.body];
//                                }
//                                if (message.contentType != 0) {
//                                    //                                    NSLog(@"message:%@ type:%d", message.body, message.contentType);
//                                }
//                                if (message.contentType != ESpaceShareLinkContentType
//                                    && message.contentType != ESpacePublicAccountContentType) {
//                                    subContentArray = [message.body analysisStringWithRegularExpression:@"/:um_begin(.*?)/:um_end"];;
//                                }
//
//                                for (int i = 0 ; i < subContentArray.count ;i++) {
//                                    NSString* subString = [subContentArray objectAtIndex:i];
//                                    long long index = i;
//                                    NSDate* timestamp = [NSDate date];
//                                    if (message.milltime) {
//                                        timestamp = [NSDate dateWithTimeIntervalSince1970:((message.milltime + index) / 1000.0)];
//                                    }
//                                    BOOL isReaded;//= index == 0 ? ([from isMe] ? YES : readed) : YES;
//                                    if ([from isKindOfClass:[EmployeeEntity class]]) {
//                                        isReaded = index == 0 ? ([TUPMediator_ContactService M_EmployeeIsMe:(EmployeeEntity *)from] ? YES : readed) : YES;
//                                    }else{
//                                        isReaded = YES;
//                                    }
//                                    messageEntity = [[ESpaceIMessageService sharedInstance] createMessageForSession:chatSession timestamp:timestamp readed:isReaded];
//                                    messageEntity.from = from;
//                                    messageEntity.to = to;
//                                    messageEntity.messageId = message.id;
//                                    messageEntity.readDetail = [NSNumber numberWithBool:YES];
//                                    messageEntity.body = subString;
//                                    messageEntity.total = [NSNumber numberWithInteger:subContentArray.count];
//                                    messageEntity.msgEx = message.msgEx;
//                                    messageEntity.senderType = [NSNumber numberWithInteger:message.senderType];
//                                    messageEntity.appID = message.appID;
//                                    messageEntity.appName = message.appName;
//                                    if (subContentArray.count >= 2) {
//                                        messageEntity.subIndex = [NSNumber numberWithInteger:i + 1];
//                                    }else{
//                                        messageEntity.subIndex = [NSNumber numberWithInteger:i];
//                                    }
//
//                                    messageEntity.contentType = [NSNumber numberWithInteger:[messageEntity contentTypeFromServerValue:message.contentType content:subString]] ;
//
//                                    if (messageEntity.contentType.unsignedIntegerValue != ESpaceTextContentType) {
//                                        [messageEntity downloadThumbnails];
//                                    }
//                                }
//
//                            }
//                            else{
//                                //若找到重复的消息，要将本地消息的状态更改为已发送，同时不会新插入消息
//                                if (ESpaceMsgStatusSended != messageEntity.transferStatus.unsignedIntegerValue) {
//                                    //DDLogInfo(@"handle send failed message %@", message.id);  //su TODO
//                                    messageEntity.transferStatus = @(ESpaceMsgStatusSended);
//                                    messageEntity.messageId = message.id;
//                                    messageEntity.receiveTimestamp = [ECSUtils dateFromMillisecondUTCValue:message.milltime];
//                                }
//
//                                //判断消息的from和to是否一致,可能本地已存在自己老工号发送的消息
//                                if ([oldStaffNo length]) {
//                                    if (NO == [messageEntity.from.contactId isEqualToString:from.contactId]) {
//                                        messageEntity.from = from;
//                                    }
//                                    if (!isGroupMessage) {
//                                        if (NO == [messageEntity.from.contactId isEqualToString:to.contactId]) {
//                                            messageEntity.to = to;
//                                        }
//                                    }
//                                }
//                            }
//                            if (message.id) {
//                                [alreadExistMessageId addObject:message.id];
//                            }
//
//                            if (messageEntity) {
//                                [[ESpaceIMessageService sharedInstance] insertRoamingMessageIdBasedMsg:[NSArray arrayWithObject:messageEntity] andContact:chatSession.target];
//                            }
//                        }
//
//                        NSString* beginMsgId = retMsg.endMsgID;
//                        NSString* endMsgId = [roamingMsg.msgID length] == 0 ? retMsg.startMsgID : roamingMsg.msgID;
//                        [chatSession deleteChatRecordBetweenStartMsgId:beginMsgId andEndMsgId:endMsgId withAlreadyExistMsgId:alreadExistMessageId forChatSession:chatSession inContext:bgCtx];
//
//
//                        //如果查询漫游前priority为-1，则查询后仍然保持-1
//                        if (NO == isChatSessionAlreadyShow) {
//                            chatSession.priority = [NSNumber numberWithInteger:-1];
//                        }
//
//                        [bgCtx saveToPersistent];
//                    }
//                }
//                if (completionBlock) {
//                    completionBlock(error, [retMsg.logList count], msglogIdList);
//                }
//            }];
//        });
//    }];
//}

- (void)deleteChatRecordBetweenStartMsgId:(NSString*)beginMessageId//小
                              andEndMsgId:(NSString*)endMessageId//大
                    withAlreadyExistMsgId:(NSArray*)existIds
                           forChatSession:(ChatSessionEntity*)chatSession
                                inContext:(NSManagedObjectContext*)context{
    NSPredicate* predicate = nil;
    if (0 != [beginMessageId length]) {
        if (0 == [endMessageId length]) {
            //su TODO
            //DDLogInfo(@"first load, need delete all bigger than beginId message.");
            predicate = [NSPredicate predicateWithFormat:@"session=%@ AND transferStatus=%@ AND messageId >=%@ AND !(messageId IN %@)", chatSession, [NSNumber numberWithInteger:ESpaceMsgStatusReceived], beginMessageId, existIds];
        }
        else{
            //su TODO
            //DDLogInfo(@"need delete message between beginId and endId");
            predicate = [NSPredicate predicateWithFormat:@"session=%@ AND transferStatus=%@ AND messageId >=%@ AND messageId <%@ AND !(messageId IN %@)", chatSession, [NSNumber numberWithInteger:ESpaceMsgStatusReceived], beginMessageId, endMessageId, existIds];
        }
    }
    else{
        if (0 == [endMessageId length]) {
            //su TODO
            //DDLogInfo(@"need delete all message.");
            //此处需要特殊处理，目的是为了防止收到新建群组的消息时，如果服务器还没有入库，用户查询时返回0条记录，导致消息被删除
            //体验效果极差，但是这个预防也仅仅是能够降低这个事件发生的概率，不能从根本上面杜绝
            if (fabs([chatSession.latestMessage.receiveTimestamp timeIntervalSinceNow]) > 60*10) {
                predicate = [NSPredicate predicateWithFormat:@"session=%@ AND transferStatus=%@ AND !(messageId IN %@)", chatSession, [NSNumber numberWithInteger:ESpaceMsgStatusReceived], existIds];
            }
            else{
                return;
            }
        }
        else{
            //su TODO
            //DDLogInfo(@"last load, need delete all smaller than endid message");
            predicate = [NSPredicate predicateWithFormat:@"session=%@ AND transferStatus=%@ AND messageId <%@ AND !(messageId IN %@)", chatSession, [NSNumber numberWithInteger:ESpaceMsgStatusReceived], endMessageId, existIds];
        }
    }
    
    NSFetchRequest* fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"ChatMessageEntity"];
    [fetchRequest setPredicate:predicate];
    NSError* error = nil;
    NSArray* result = [context executeFetchRequest:fetchRequest error:&error];
    for (ChatMessageEntity* message in result) {
        [message localDeleteSelf];
    }
    
    [context save:nil];
}


- (void) saveDraft:(NSString*)draftContent completion:(void (^)(NSError* error)) completionBlock {
    NSManagedObjectID* oldId = self.objectID;
    NSManagedObjectContext* bgCtx = [LOCAL_DATA_MANAGER backgroundObjectContext];
    [bgCtx performBlock:^{
        ChatSessionEntity* session = (ChatSessionEntity*)[bgCtx objectWithID:oldId];
        if ([draftContent length]) {
            if (NO == [draftContent isEqualToString:session.draft]) {
                session.timestamp = [NSDate date];//更新session的时间
                session.draft = draftContent;
            }
        }
        else if ([session.draft length]){//当无草稿变更时，无需做此操作，否则会影响置顶排序功能
            session.draft = @"";
            if (session.latestMessage) {
                session.timestamp = session.latestMessage.receiveTimestamp;
            }
        }
        if ([bgCtx hasChanges]) {
            [bgCtx save:nil];
        }
        if (completionBlock) {
            completionBlock(nil);
        }
    }];
}

//- (void)deleteselfFromServer:(void (^)(NSError* error)) completionBlock {
//    ECSDelRecentSessions* drs = [[ECSDelRecentSessions alloc] init];
//    drs.ActionType = @"DelRecentSessions";
//    drs.user = [[[ECSAppConfig sharedInstance] currentUser] account];
//    drs.attributes = self.target.contactId;
//
//    if ([self.target isGroupEntity]) {
//        if ([[(GroupEntity*)self.target groupType] integerValue] == ECSFixGroup) {
//            drs.type = RecentSessionFixedGroup;
//        }
//        else{
//            drs.type = RecentSessionDiscussGroup;
//        }
//    }
//    else{
//        drs.type = RecentSessionP2P;
//    }
//    drs.opt = 1;
//
//    [[ESpaceRecentSessionService sharedInstance].recentSessionService delRecentSessionsWithRequest:drs completionBlock:^(ECSDelRecentSessionsAck *retMsg, NSError *error) {
//        if (completionBlock) {
//            completionBlock(error);
//        }
//    }];
//}

//- (void) deleteSelf{
//    //    NSManagedObjectID * oid = self.objectID;
//    //step1:mark read messages from local
//    [self hide];
//    //step2:mark read messages from server
//    [[ESpaceIMessageService sharedInstance] markRead:self];
//    
//    
//    //step4:delete chatSession from server
//    if (NO == [[ECSAppConfig sharedInstance].currentUser isSupportFunction:EN_FUNC_RECENT_SESSIONS_ROAMING]) {
//        return;
//    }
//    [self deleteselfFromServer:^(NSError *error) {
//        if (error) {
//            //DDLogDebug(@"delete session [%@] failed !", self.target.contactId);  //su TODO
//        }/* else {//不要删除session
//          dispatch_async(espace_coredata_management_queue, ^{
//          NSManagedObjectContext* bgCtx = [LOCAL_DATA_MANAGER backgroundObjectContext];
//          [bgCtx performBlockAndWait:^{
//          ChatSessionEntity* chatSession = (ChatSessionEntity*)[bgCtx objectWithID:oid];
//          [chatSession localDeleteSelf];
//          [bgCtx saveToPersistent];
//          }];
//          });
//          }*/
//    }];
//}

- (void) cleanHistory:(void (^)(NSError* error)) completionBlock {
    [[ESpaceIMessageService sharedInstance] deleteMessages:nil session:self target:self.target completionBlock:completionBlock];
}



@end
