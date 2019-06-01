//
//  ESpaceIMessageService.m
//  eSpaceUI
//
//  Created by yemingxing on 3/19/15.
//  Copyright (c) 2015 www.huawei.com. All rights reserved.
//

#import "ESpaceIMessageService.h"
//#import "ECSIMessagingService.h"
//#import "eSpaceIOSSDK.h"
//#import "ESpaceContactService.h"
#import "MessageEntity.h"
#import "ChatSessionEntity.h"
#import "GroupEntity.h"
//#import "ESpaceUMResource.h"
#import "ChatMessageEntity+ServiceObject.h"
//#import "EmployeeEntity+ServiceObject.h" //su TODO
#import "ChatSessionEntity+ServiceObject.h"
#import "NSString+Transform.h"
#import "MessageEntity+ServiceObject.h"
#import "DeptMessageEntity.h"
#import "NSManagedObjectContext+Persistent.h"
//#import "ESpaceVersionSwitchHelper.h"    //su TODO
//#import "CircleComment+ServiceObject.h"  //su TODO
//#import "eSpaceIOSService.h"
//#import "CircleSessionEntity+ServiceObject.h"
#import "ThirdPartSysEntity+CoreDataProperties.h"
//#import "ESpaceOperateCardMessage.h"
#import "ECSafeMutableDictionary.h"
#import "EmployeeEntity.h"
//#import "ECSOprCommandService.h"

//#import "TUPIOSSDK.h"
//#import "TUPMAALoginService.h"
#import "ECSAppConfig.h"
#import "SpecialChatSessionEntity.h"
//#import "ESpaceVersionSwitchHelper.h"
#import "eSpaceDBService.h"
//#import <TUPMediatorSDK/TUPMediator_ContactService.h>
//#import "ECSGroupManageService.h"
//#import "ECSUserSettingService.h"
#import "ECSIMessagingServiceMessage.h"
//#import "ECSNetworkService.h"
//#import "ESpaceRecentSessionService.h"

#import "ESpaceContactService.h"

typedef NS_ENUM(NSUInteger, ESpaceOperateCardType) {
    ESpaceOprTypeEmail = 0x00,
    ESpaceOprTypeConference = 0x01,//视频会议
    ESpaceOprTypeRedPaperOpr = 0x02,//红包
    ESpaceOprTypePublicNumber = 0x03,//公众号
    ESpaceOprTypeVideoCall = 0x10
};

NSString* const ESPACE_NEW_BULLETIN_NOTIFY = @"ESPACE_NEW_BULLETIN_NOTIFY";
NSString* const ESPACE_RECEIVE_SINGLE_MESSAGE_NOTIFY = @"eSpace_receive_single_message_notify";
NSString* const ESPACE_RECEIVE_GROUP_MESSAGE_NOTIFY = @"eSpace_receive_group_message_notify";
NSString* const ESPACE_RECEIVE_MESSAGE_NOTIFY_KEY = @"eSpace_receive_message_notify_key";
NSString* const ESPACE_MESSAGE_RECALLED_NOTIFY = @"eSpace_message_recalled_notify";
NSString* const ESPACE_MESSAGE_RECALLED_NOTIFY_KEY = @"eSpace_message_recalled_notify_key";
NSString* const ESPACE_MESSAGE_RECALLED_NOTIFY_MSGSTATE_KEY = @"eSpace_message_recalled_notify_msgstate_key";
NSString* const ESPACE_MESSAGE_RECALLED_MEDIA_UM_NOTIFY_KEY = @"eSpace_message_recalled_media_um_notify_key";
NSString* const ESPACE_MESSAGE_RECALLED_FILE_UM_NOTIFY_KEY = @"eSpace_message_recalled_file_um_notify_key";
NSString* const ESPACE_CLEAR_ALL_MESSAGE_NOTIFY = @"eSpace_clear_all_message_notify";

NSString* const ESPACE_RECEIVE_DEPT_MESSAGE_NOTIFY = @"eSpace_receive_dept_message_notify";

NSString *const JSAPIReceiveMessagesNotify = @"JSAPIReceiveMessagesNotify";
NSString *const JSAPIReceiveMessagesNotifyKey = @"JSAPIReceiveMessagesNotifyKey";
NSString *const JSAPIReceiveMessagesInterfaceKey = @"JSAPIReceiveMessagesInterfaceKey";// eSDK中使用
NSString *const JSAPIReceiveMessagesListKey = @"JSAPIReceiveMessagesListKey"; // eSDK中使用

@interface ESpaceIMessageService (){
    
}
@property (nonatomic, strong) NSMutableDictionary *sensitiveWordDic;
@property (nonatomic, strong) NSMutableDictionary* loadedSingleChatRoamingMsgId;
@property (nonatomic, strong) NSMutableDictionary* loadedGroupChatRoamingMsgId;
@property (nonatomic, strong) DeptSessionEntity* localDeptSessionEntity;
@property (nonatomic, strong) DeptSessionEntity* roamingDeptSessionEntity;
//@property (nonatomic, strong) ECSOprCommandService* oprCommandService;
//@property (nonatomic, strong) ECSLoginService* loginService;
@end

@implementation ESpaceIMessageService

@synthesize validSessions = _validSessions;
#pragma mark 漫游消息记录ID处理

- (NSMutableArray*)getLoadedRoamingMsgIdList:(ContactEntity*)contact {
    NSMutableArray* loadedMsgIdList = nil;
    
    if (0 == [contact.contactId length]) {
        return nil;
    }
    
    if ([contact isEmployeeEnity]) {
        loadedMsgIdList = [self.loadedSingleChatRoamingMsgId objectForKey:contact.contactId];
        if (nil == loadedMsgIdList) {
            loadedMsgIdList = [[NSMutableArray alloc] initWithCapacity:5];
            [self.loadedSingleChatRoamingMsgId setObject:loadedMsgIdList forKey:contact.contactId];
        }
    }
    else if ([contact isGroupEntity]){
        loadedMsgIdList = [self.loadedGroupChatRoamingMsgId objectForKey:contact.contactId];
        if (nil == loadedMsgIdList) {
            loadedMsgIdList = [[NSMutableArray alloc] initWithCapacity:5];
            [self.loadedGroupChatRoamingMsgId setObject:loadedMsgIdList forKey:contact.contactId];
        }
    }
    
    return loadedMsgIdList;
}

- (NSString*)previousMessageid:(ContactEntity*)contact {
    NSMutableArray* loadedMsgIdList = [self getLoadedRoamingMsgIdList:contact];
    NSString* previousMessageId = (NSString*)[loadedMsgIdList firstObject];
    
    return previousMessageId;
}

- (NSString*)latestMessageId:(ContactEntity*)contact {
    NSMutableArray* loadedMsgIdList = [self getLoadedRoamingMsgIdList:contact];
    NSString* latestMessageId = (NSString*)[loadedMsgIdList lastObject];
    
    return latestMessageId;
}

- (void)insertRoamingMessageIds:(NSArray *)msgIds andContact:(ContactEntity*)contact {
    NSMutableArray* loadedMsgIdList = [self getLoadedRoamingMsgIdList:contact];
    for (NSString *tempId in msgIds) {
        if ([tempId length] > 0 &&
            NO == [loadedMsgIdList containsObject:tempId]) {
            [loadedMsgIdList addObject:tempId];
        }
    }
    [loadedMsgIdList sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2 options:NSNumericSearch];
    }];
}


- (void)insertRoamingMessageIdBasedMsg:(NSArray*)messages andContact:(ContactEntity*)contact {
    NSMutableArray* loadedMsgIdList = [self getLoadedRoamingMsgIdList:contact];
    
    for(ChatMessageEntity* singleMsg in messages){
        if ([singleMsg.messageId length] > 0 &&
            NO == [loadedMsgIdList containsObject:singleMsg.messageId]) {
            [loadedMsgIdList addObject:singleMsg.messageId];
        }
    }
    [loadedMsgIdList sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2 options:NSNumericSearch];
    }];
}

- (void)deleteRoamingMessageIdBasedMsg:(NSArray*)messages andContact:(ContactEntity*)contact {
    NSMutableArray* loadedMsgIdList = [self getLoadedRoamingMsgIdList:contact];
    for (ChatMessageEntity* singleMsg in messages) {
        [loadedMsgIdList removeObject:singleMsg.messageId];
    }
}

- (BOOL)containedRoamingMessageIdBasedMessage:(ChatMessageEntity*)message andContact:(ContactEntity*)contact {
    NSMutableArray* loadedMsgIdList = [self getLoadedRoamingMsgIdList:contact];
    return [loadedMsgIdList containsObject:message.messageId];
}


#pragma mark -

- (ECSafeMutableDictionary *)validSessions {
    if (!_validSessions) {
        _validSessions = [[ECSafeMutableDictionary alloc] init];
    }
    return _validSessions;
}

- (instancetype)init {
    if (self = [super init]) {
//        _imessageService = [[ECSIMessagingService alloc] init];
//        _imessageService.delegate = self;
//        [[ECSNetworkService sharedInstance] registerSerivce:_imessageService];
        //[eSpaceIOSSDK sharedInstance].imessagingService.delegate = self;
//        _oprCommandService = [[ECSOprCommandService alloc] init];
//        _oprCommandService.delegate = self;
//        [[ECSNetworkService sharedInstance] registerSerivce:_oprCommandService];
        //[eSpaceIOSSDK sharedInstance].oprCommandService.delegate = self;
//        [[eSpaceIOSSDK sharedInstance].loginService addObserver:self forKeyPath:@"serviceStatus" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
//        self.loginService = [TUPMAALoginService sharedInstance].loginService;
//        [self.loginService addObserver:self forKeyPath:@"serviceStatus" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
        _loadedGroupChatRoamingMsgId = [[NSMutableDictionary alloc] init];
        _loadedSingleChatRoamingMsgId = [[NSMutableDictionary alloc] init];
        _sensitiveWordDic = [NSMutableDictionary dictionary];
    }
    return self;
}

+ (instancetype) sharedInstance {
    static dispatch_once_t onceToken;
    static ESpaceIMessageService* service;
    dispatch_once(&onceToken, ^{
        service = [[ESpaceIMessageService alloc] init];
    });
    return service;
}

+ (DeptSessionEntity*)localDeptSessionEntityWithContext:(NSManagedObjectContext*)context {
    if (!context) return nil;
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"sessionId=%@", DEPARTMENT_SESSION_LOCAL_ID];
    
    __block DeptSessionEntity* deptSession = [ESpaceLocalDataManager fetchOneObject:predicate inEnitity:@"DeptSessionEntity" inContext:context];
    if (!deptSession) {
        [context performBlockAndWait:^{
            NSEntityDescription* dsEntity = [NSEntityDescription entityForName:@"DeptSessionEntity" inManagedObjectContext:context];
            deptSession = [[DeptSessionEntity alloc] initWithEntity:dsEntity insertIntoManagedObjectContext:context];
            deptSession.sessionId = DEPARTMENT_SESSION_LOCAL_ID;
            deptSession.priority = [NSNumber numberWithInt:0];
            deptSession.parent = (NSManagedObject*)[ESpaceLocalDataManager rootChatSessionGroupInContext:context];
        }];
    }
    
    return deptSession;
}

+ (DeptSessionEntity*)roamingDeptSessionEntityWithContext:(NSManagedObjectContext*)context {
    if (!context) return nil;
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"sessionId=%@", DEPARTMENT_SESSION_ROAMING_ID];
    
    __block DeptSessionEntity* deptSession = [ESpaceLocalDataManager fetchOneObject:predicate inEnitity:@"DeptSessionEntity" inContext:context];
    if (!deptSession) {
        [context performBlockAndWait:^{
            NSEntityDescription* dsEntity = [NSEntityDescription entityForName:@"DeptSessionEntity" inManagedObjectContext:context];
            deptSession = [[DeptSessionEntity alloc] initWithEntity:dsEntity insertIntoManagedObjectContext:context];
            deptSession.sessionId = DEPARTMENT_SESSION_ROAMING_ID;
            deptSession.priority = [NSNumber numberWithInt:0];
        }];
    }
    
    return deptSession;
}

- (void)dealloc{
//    [self.loginService removeObserver:self forKeyPath:@"serviceStatus"];
}

- (ChatMessageEntity*) messageInSession:(SessionEntity*) session wihId:(NSString*) msgId inContext:(NSManagedObjectContext*) ctx autoCreate:(BOOL) bAutoCreate{
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"session=%@ AND messageId=%@", session, msgId];
    __block ChatMessageEntity* message = [ESpaceLocalDataManager fetchOneObject:predicate inEnitity:@"ChatMessageEntity" inContext:ctx];
    if (!message && bAutoCreate) {
        [ctx performBlockAndWait:^{
            NSEntityDescription* messageEntity = [NSEntityDescription entityForName:@"ChatMessageEntity" inManagedObjectContext:ctx];
            message = [[ChatMessageEntity alloc] initWithEntity:messageEntity insertIntoManagedObjectContext:ctx];
            message.messageId = msgId;
        }];
    }
    return message;
}

//- (ChatMessageEntity*) createMessageForSession:(SessionEntity*) session
//                                     timestamp:(NSDate*) date
//                                          flag:(NSInteger) flag
//                                        readed:(BOOL) readed {
//    if (!session) {
//        return nil;
//    }
//    NSEntityDescription* entity = [NSEntityDescription entityForName:@"ChatMessageEntity" inManagedObjectContext:session.managedObjectContext];
//    ChatMessageEntity* messageEntity = [[ChatMessageEntity alloc] initWithEntity:entity insertIntoManagedObjectContext:session.managedObjectContext];
//
//    messageEntity.receiveTimestamp = date;
//    messageEntity.flag = [NSNumber numberWithInteger:flag];
//    messageEntity.session = session;
//    messageEntity.type = @0;
//    messageEntity.readed = [NSNumber numberWithBool:readed];
//    if (ESpaceMessageFlagNormal == flag && [session.priority integerValue] < 0) {
//        session.priority = [NSNumber numberWithInteger:0];
//    }
//    NSUInteger updateDbId = [[ECSAppConfig sharedInstance].currentUser.increasedDbId unsignedIntegerValue] + 1;
//    messageEntity.dataBaseId = [NSNumber numberWithUnsignedInteger:updateDbId];
//    [ECSAppConfig sharedInstance].currentUser.increasedDbId = [NSNumber numberWithUnsignedInteger:updateDbId];
//    //此处目的是处理从老版本db数据库升级到新版coreData版本后，最后一条记录不刷新的问题
//    if ([session isKindOfClass:[SpecialChatSessionEntity class]] && NO == [ESpaceVersionSwitchHelper sharedInstance].isUpdating) {
//        [(SpecialChatSessionEntity*)session updateLastMessage:[NSSet setWithObject:messageEntity]];
//    }
//
//    return messageEntity;
//}

//- (ChatMessageEntity*) createMessageForSession:(SessionEntity*) session
//                                     timestamp:(NSDate*) date
//                                        readed:(BOOL) readed {
//    return [self createMessageForSession:session timestamp:date flag:0 readed:readed];
//}

//- (void)handleReceiveMessages:(ChatMessageEntity *)messageEntity
//               andChatMessage:(ECSChatMessage *)message
//                  withContext:(NSManagedObjectContext *)bgCtx
//                contactEntity:(ContactEntity *)contactEntity
//                         from:(ContactEntity *)from
//                           to:(EmployeeEntity *)to
//             chatMessageArray:(NSMutableArray *)chatMessageList
//{//ECSChatMessage
//    if (!messageEntity){
//        NSArray* subContentArray = [NSArray arrayWithObject:message.body];
//        if (message.contentType != ESpaceShareLinkContentType
//            && message.contentType != ESpacePublicAccountContentType) {
//            subContentArray = [message.body analysisStringWithRegularExpression:@"/:um_begin(.*?)/:um_end"];;
//        }
//        for (int i = 0 ; i < subContentArray.count ;i++) {
//            NSString* subString = [subContentArray objectAtIndex:i];
//            long long index = i;
//            NSDate* timestamp = nil;
//            if (message.milltime) {
//                timestamp = [NSDate dateWithTimeIntervalSince1970:((message.milltime + index) / 1000.0)];
//            } else {
//                timestamp = [NSDate dateWithTimeIntervalSince1970:([message.body_time integerValue])];
//            }
//            BOOL isRead = NO;
//            if (subContentArray.count > 1 && index != subContentArray.count - 1) {
//                isRead = YES;
//            }
//            if ([from isKindOfClass:[EmployeeEntity class]]) {
//                if ([TUPMediator_ContactService M_EmployeeIsMe:(EmployeeEntity *)from]) {
//                    isRead = YES;
//                }
//            }
//            messageEntity = [self createMessageForSession:contactEntity.chatSession timestamp:timestamp readed:isRead];
//            messageEntity.messageId = message.body_id;
//            messageEntity.from = from;
//            messageEntity.to = to;
//            messageEntity.readDetail = [NSNumber numberWithBool:isRead];
//            messageEntity.body = subString;
//            messageEntity.title = message.title;
//            messageEntity.total = [NSNumber numberWithInteger:subContentArray.count];
//            messageEntity.senderType = [NSNumber numberWithInteger:message.senderType];
//            messageEntity.appName = message.appName;
//            messageEntity.appID = message.appID;
//            if (subContentArray.count >= 2) {
//                messageEntity.subIndex = [NSNumber numberWithInteger:i + 1];
//            }else{
//                messageEntity.subIndex = [NSNumber numberWithInteger:i];
//            }
//            
//            messageEntity.contentType = [NSNumber numberWithInteger:[messageEntity contentTypeFromServerValue:message.contentType content:subString]] ;
//            
//            if (messageEntity.contentType.unsignedIntegerValue != ESpaceTextContentType) {
//                [messageEntity downloadThumbnails];
//            }
//            
//            [bgCtx saveToPersistent];
//        }
//        if (nil != messageEntity.objectID) {
//            [chatMessageList addObject:messageEntity.objectID];
//        }
//    }
//    
//}

//- (void)didReceiveChatMessage:(NSArray *)messages {
//    if (nil == [messages lastObject]) {
//        return;
//    }
//    if (NO == [[ECSAppConfig sharedInstance].currentUser isSupportFunction:EN_FUNC_IM]) {
//        //DDLogError(@"I have no im ability,refuse handle!");   //su TODO
//        return;
//    }
//
//    ECSChatMessage* msgObj = [messages lastObject];
//    ESpaceLocalDataManager * localManager = LOCAL_DATA_MANAGER;
//    if ([msgObj.type isEqualToString:@"chat"] || [msgObj.type isEqualToString:@"CHAT_FILE_TRANSFER_URL"]) {
//        dispatch_async(espace_coredata_management_queue, ^{
//            NSManagedObjectContext* bgCtx = [localManager backgroundObjectContext];
//            NSArray* soredMessages = [messages sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
//                ECSChatMessage* msg1 = obj1;
//                ECSChatMessage* msg2 = obj2;
//                long long t1 = msg1.milltime;
//                long long t2 = msg2.milltime;
//                return t1 < t2 ? NSOrderedAscending : ((t1 > t2) ? NSOrderedDescending : NSOrderedSame);
//            }];
//            [bgCtx performBlockAndWait:^{
//                NSMutableArray *chatMessageList = [[NSMutableArray alloc] init];
//                for (ECSChatMessage* message in soredMessages) {
//                    ContactEntity *from = nil;
//                    //EmployeeEntity* from = [[ESpaceContactService sharedInstance] userWithAccount:message.from inContext:bgCtx autoCreate:YES];
//                    EmployeeEntity* to = [TUPMediator_ContactService M_userWithAccount:message.to inContext:bgCtx autoCreate:YES];
//                    if ([from.name length] == 0) {
//                        from.name = message.name;
//                    }
//                    ChatMessageEntity* messageEntity = nil;
//                    if (ESpaceMessageFromThirdSys == message.senderType) {
//                        ThirdPartSysEntity *tPsysInfoEntity = [TUPMediator_ContactService M_systemInfoWithAppID:message.appID inContex:bgCtx autoCreat:YES];
//                        if ([message.from length] > 0) {
//                           tPsysInfoEntity.contactId = message.from;
//                        }
//                        from = tPsysInfoEntity;
//                        if (0 == [tPsysInfoEntity.appName length]) {
//                            tPsysInfoEntity.appName = message.appName;
//                        }
//                        if (0 != [message.body_id length]) {
//                            NSPredicate* predicate = [NSPredicate predicateWithFormat:@"senderType=%@ AND messageId=%@", [NSNumber numberWithInteger:2], message.body_id];
//                            messageEntity = [ESpaceLocalDataManager fetchOneObject:predicate inEnitity:@"ChatMessageEntity" inContext:bgCtx];
//                        }
//                        [self handleReceiveMessages:messageEntity
//                                     andChatMessage:message withContext:bgCtx
//                                      contactEntity:tPsysInfoEntity
//                                               from:from
//                                                 to:to
//                                   chatMessageArray:(NSMutableArray *)chatMessageList];
//
//                    }else{
//                        //ChatMessageEntity* messageEntity = nil;
//                        from = [TUPMediator_ContactService M_userWithAccount:message.from inContext:bgCtx autoCreate:YES];
//                        if (0 != [message.body_id length]) {
//                            NSPredicate* predicate = [NSPredicate predicateWithFormat:@"from=%@ AND messageId=%@", from, message.body_id];
//                            messageEntity = [ESpaceLocalDataManager fetchOneObject:predicate inEnitity:@"ChatMessageEntity" inContext:bgCtx];
//                        }
//                        ChatSessionEntity *chatSession = [TUPMediator_ContactService M_EmployeeIsMe:(EmployeeEntity *)from] == YES ? to.chatSession : from.chatSession;
//                        [self handleReceiveMessages:messageEntity
//                                     andChatMessage:message
//                                        withContext:bgCtx
//                                      contactEntity:chatSession.target
//                                               from:from
//                                                 to:to
//                                   chatMessageArray:(NSMutableArray *)chatMessageList];
//                    }
//                }
//
//                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//                    NSArray *cMsgList = messages;
//                    if (!cMsgList) {
//                        cMsgList = [[NSArray alloc] init];
//                    }
//
//                    [[NSNotificationCenter defaultCenter] postNotificationName:JSAPIReceiveMessagesNotify
//                                                                        object:nil
//                                                                      userInfo:@{JSAPIReceiveMessagesNotifyKey : chatMessageList,
//                                                                                 JSAPIReceiveMessagesInterfaceKey : [NSNumber numberWithInteger:RecMessageInterfaceChatMsgNotify],
//                                                                                 JSAPIReceiveMessagesListKey : cMsgList}];
//                });
//
//                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//                    NSDictionary* infoDic = [NSDictionary dictionaryWithObjectsAndKeys:chatMessageList.lastObject,ESPACE_RECEIVE_MESSAGE_NOTIFY_KEY, nil];
//                    [[NSNotificationCenter defaultCenter] postNotificationName:ESPACE_RECEIVE_SINGLE_MESSAGE_NOTIFY object:nil userInfo:infoDic];
//                });
//
//            }];
//        });
//    }
//    else if ([msgObj.type isEqualToString:@"system"]){
//
//        dispatch_async(espace_coredata_management_queue, ^{
//            NSManagedObjectContext* bgCtx = [localManager backgroundObjectContext];
//
//            [bgCtx performBlockAndWait:^{
//                for (ECSChatMessage* message in messages) {
//                    EmployeeEntity* from = [TUPMediator_ContactService M_userWithAccount:message.from inContext:bgCtx autoCreate:YES];
//                    EmployeeEntity* to = [TUPMediator_ContactService M_userWithAccount:message.from inContext:bgCtx autoCreate:YES];
//
//                    if ([from.name length] == 0) {
//                        from.name = message.name;
//                    }
//
//                    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"from=%@ AND messageId=%@", from, message.body_id];
//                    DeptMessageEntity* deptEntity = [ESpaceLocalDataManager fetchOneObject:predicate inEnitity:@"DeptMessageEntity" inContext:bgCtx];
//                    if (!deptEntity || 0 == [message.body_id length]) {
//                        NSEntityDescription* entity = [NSEntityDescription entityForName:@"DeptMessageEntity" inManagedObjectContext:bgCtx];
//                        deptEntity = [[DeptMessageEntity alloc] initWithEntity:entity insertIntoManagedObjectContext:bgCtx];
//                        deptEntity.session = [ESpaceIMessageService localDeptSessionEntityWithContext:bgCtx];
//                        deptEntity.messageId = message.body_id;
//                        deptEntity.from = from;
//                        deptEntity.receiveTimestamp = [NSDate dateWithTimeIntervalSince1970:([message.body_time integerValue])];
//                        deptEntity.to = to;
//                        deptEntity.body = message.body;
//                        deptEntity.title = message.title;
//                        deptEntity.readed = [NSNumber numberWithBool:NO];
//                        if ([deptEntity.session.priority integerValue] < 0) {
//                            deptEntity.session.priority = [NSNumber numberWithInteger:0];
//                        }
//                    }
//                    else{
//                        //markread
//                        if ([deptEntity.readed boolValue]) {
//                            [[ESpaceIMessageService sharedInstance] markReadRequest:MsgMarkReadForOther targetId:message.to msgId:message.body_id newMsgType:NewMsgMarkRead_SystemNotice];
//                        }
//                    }
//                }
//                [bgCtx saveToPersistent];
//                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//                    [[NSNotificationCenter defaultCenter] postNotificationName:ESPACE_RECEIVE_DEPT_MESSAGE_NOTIFY object:nil userInfo:nil];
//                });
//            }];
//        });
//    }
//    else if ([msgObj.type isEqualToString:@"notes"]){
//        //DDLogDebug(@"系统公告，改接口已废弃使用,不做处理");  //su TODO
//    }
//
//
//}

//- (void)didReceiveGroupMsgNotify:(ECSGroupMsgNotify *)notify {
//    //    NSLog(@"%@", notify.from);
//}
//
//- (void)didReceiveChatMessageNotify:(ECSChatMessageNotify *)notify {
//
//}
//
//- (void) didReceiveGroupChatResultNotify:(ECSGroupChatResultNotify *)notify {
//
//}
//
//- (void)didReceiveTempGroupMsgNotify:(ECSTempGroupMsgNotify *)notify {
//
//}
//
//
//- (ChatMessageEntity *)handleReceiveUnReadMessages:(ChatMessageEntity *)messageEntity
//                     andChatMessage:(ECSUnreadMessagesNotifyChat *)message
//                        withContext:(NSManagedObjectContext *)bgCtx
//                        chatSession:(ChatSessionEntity *)chatSession
//                               from:(ContactEntity *)from
//                                 to:(ContactEntity *)to
//{//ECSChatMessage
//    ChatMessageEntity *getEntity = nil;
//    if (!messageEntity) {
//        //        if ([chatSession.target isKindOfClass:[GroupEntity class]]) {
//        //            GroupEntity * group = nil;//(GroupEntity*)to;
//        //            NSInteger state = [group.state integerValue];
//        //            if ((state & ESpaceGroupStateMemberLoaded)!=ESpaceGroupStateMemberLoaded
//        //                && from && ![group.members containsObject:from]) {
//        //                [group addMembersObject:from];
//        //            }
//        //        }
//        //多图文消息兼容,公众号转发消息、链接分享不进行解析
//        NSArray* subContentArray = [NSArray arrayWithObject:message.body];
//        if (message.contentType != ESpaceShareLinkContentType
//            && message.contentType != ESpacePublicAccountContentType) {
//            subContentArray = [message.body analysisStringWithRegularExpression:@"/:um_begin(.*?)/:um_end"];;
//        }
//
//
//        for (int i = 0 ; i < subContentArray.count ;i++) {
//            NSString* subString = [subContentArray objectAtIndex:i];
//            long long index = i;
//            NSDate* timestamp = [NSDate date];
//            if (message.time) {
//                timestamp = [NSDate dateWithTimeIntervalSince1970:((message.time + index) / 1000.0)];
//            }
//            BOOL isRead = NO;
//            if (subContentArray.count > 1 && index != subContentArray.count - 1) {
//                isRead = YES;
//            }
//            //此处判断冗余
//            //                            isRead = notify.msgTag == 1 ? ([message.from caseInsensitiveCompare:currentUser] == NSOrderedSame ? YES : NO) : NO;
//
//            messageEntity = [self createMessageForSession:chatSession timestamp:timestamp readed:isRead];
//            messageEntity.from = from;
//            messageEntity.to  = to;
//            messageEntity.messageId = message.id;
//            messageEntity.readDetail = [NSNumber numberWithBool:NO];
//            messageEntity.body = subString;
//            messageEntity.total = [NSNumber numberWithInteger:subContentArray.count];
//            messageEntity.appID = message.appID;
//            messageEntity.appName = message.appName;
//            messageEntity.senderType = [NSNumber numberWithInteger:message.senderType];
//            if (subContentArray.count >= 2) {
//                messageEntity.subIndex = [NSNumber numberWithInteger:i +1];
//            }else{
//                messageEntity.subIndex = [NSNumber numberWithInteger:i];
//            }
//
//            messageEntity.contentType = [NSNumber numberWithInteger:[messageEntity contentTypeFromServerValue:message.contentType content:subString]] ;
//            if (messageEntity.contentType.unsignedIntegerValue != ESpaceTextContentType) {
//                [messageEntity downloadThumbnails];
//            }
//            [self insertRoamingMessageIdBasedMsg:[NSArray arrayWithObject:messageEntity] andContact:chatSession.target];
//
//            getEntity = messageEntity;
//        }
//        [bgCtx saveToPersistent];
//    }
//
//     return getEntity;
//}


//- (void)postReceiveSingleMessageNotification:(ChatMessageEntity *)message {
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        NSDictionary* infoDic = [NSDictionary dictionaryWithObjectsAndKeys:message.objectID,ESPACE_RECEIVE_MESSAGE_NOTIFY_KEY, nil];
//        [[NSNotificationCenter defaultCenter] postNotificationName:ESPACE_RECEIVE_SINGLE_MESSAGE_NOTIFY object:nil userInfo:infoDic];
//    });
//}


//- (void)postReceiveGroupMessageNotification:(ChatMessageEntity *)message {
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        NSDictionary* infoDic = [NSDictionary dictionaryWithObjectsAndKeys:message.objectID,ESPACE_RECEIVE_MESSAGE_NOTIFY_KEY, nil];
//        [[NSNotificationCenter defaultCenter] postNotificationName:ESPACE_RECEIVE_GROUP_MESSAGE_NOTIFY object:nil userInfo:infoDic];
//    });
//}


//- (void)didReceiveUnreadMessagesNotify:(ECSUnreadMessagesNotify *)notify {
//    if (NO == [[ECSAppConfig sharedInstance].currentUser isSupportFunction:EN_FUNC_IM]) {
//        //DDLogError(@"I have no im ability,refuse handle!");  //su TODO
//        return;
//    }
//
//    ESpaceLocalDataManager * localManager = LOCAL_DATA_MANAGER;
//    dispatch_async(espace_coredata_management_queue, ^{
//        NSManagedObjectContext* bgCtx = [localManager backgroundObjectContext];
//        NSString * currentUser = localManager.userAccount;
//
//        [bgCtx performBlockAndWait:^{
//            BOOL atMe = NO;
//            NSArray* messages = [notify.chatList sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
//                ECSUnreadMessagesNotifyChat* msg1 = obj1;
//                ECSUnreadMessagesNotifyChat* msg2 = obj2;
//                long long t1 = msg1.time;
//                long long t2 = msg2.time;
//                return t1 < t2 ? NSOrderedAscending : ((t1 > t2) ? NSOrderedDescending : NSOrderedSame);
//            }];
//            //first step: get ChatSession
//            ECSUnreadMessagesNotifyChat* oneMsg = [messages firstObject];
//            ContactEntity* from = nil;
//            ContactEntity* to = nil;
//            ChatSessionEntity* chatSession = nil;
//            if ([from.name length] == 0) {
//                from.name = oneMsg.from;
//            }
//            if (notify.msgTag == 1) {
//                //IM消息
//                to = [TUPMediator_ContactService M_userWithAccount:oneMsg.to inContext:bgCtx autoCreate:YES];
//                if (ESpaceMessageFromThirdSys == oneMsg.senderType) {
//                    //第三方系统消息
//                    from = [TUPMediator_ContactService M_systemInfoWithAppID:oneMsg.appID inContex:bgCtx autoCreat:YES];
//                    if ([oneMsg.from length] > 0) {
//                       from.contactId = oneMsg.from;
//                    }
//                    if (0 == [from.appName length]) {
//                        from.appName = oneMsg.appName;
//                    }
//                }
//                else{
//                    from = [TUPMediator_ContactService M_userWithAccount:oneMsg.from inContext:bgCtx autoCreate:YES];
//                }
//                chatSession = from.chatSession;
//            } else {
//                to = [TUPMediator_ContactService M_groupWithId:oneMsg.to type:0 inContext:bgCtx autoCreate:YES];
//                if (ECSFixGroup == [[(GroupEntity*)to groupType] integerValue]
//                    && NO == [[ECSAppConfig sharedInstance].currentUser isSupportFunction:EN_FUNC_FIXGROUP]) {
//                    //DDLogDebug(@"I have no fix group ability, refuse to treat message!");  //su TODO
//                    return ;
//                }
//
//                if (ECSChatGroup == [[(GroupEntity*)to groupType] integerValue]
//                    && NO == [[ECSAppConfig sharedInstance].currentUser isSupportFunction:EN_FUNC_DISCUSSION_GROUP]) {
//                    //DDLogDebug(@"I have no discussion group ability, refuse to treat message!");  //su TODO
//                    return ;
//                }
//
//                chatSession = to.chatSession;
//                chatSession.isAtMe = [NSNumber numberWithBool:notify.isAt? YES : NO];
//                atMe = notify.isAt ? YES : NO;
//                if ([to.name length] == 0) {
//                    to.name = oneMsg.to;
//                }
//            }
//            ChatMessageEntity* lastestMessage = nil;
//
//            //推送消息如果本地已存在，需进行特殊处理,目前华为UC环境与基线均支持此处理
//            //if (NO == [[ECSAppConfig sharedInstance].currentUser isHWUC]) {
//                NSArray * localUnreadMessages = [ESpaceLocalDataManager fetchObjects:[NSPredicate predicateWithFormat:@"session=%@ AND messageId=%@", chatSession, notify.maxID] inEnitity:@"ChatMessageEntity" inContext:bgCtx];
//                if ([localUnreadMessages count] > 0) {
//                    ChatMessageEntity* maxMsgEntity = (ChatMessageEntity*)[localUnreadMessages firstObject];
//                    if (maxMsgEntity.readed.boolValue) {
//                        //DDLogDebug(@"消息本地已读，需上报服务器已读，无需再处理该推送.");  //su TODO
//                        [maxMsgEntity markReadToServer];
//                        chatSession.unreadMsgNum = [NSNumber numberWithInteger:0];
//                        [bgCtx saveToPersistent];
//                        return;
//                    }
//                    else if (notify.num == [(ChatSessionEntity*)maxMsgEntity.session unreadCount].unsignedIntegerValue){
//                        //基线环境，如果未读推送的最新消息本地已存在，可以认为本地已存在；华为UC也已支持
//                        //DDLogDebug(@"推送的未读消息本地已存在，无需重复处理"); //su TODO
//                        chatSession.unreadMsgNum = [NSNumber numberWithInteger:notify.num];
//
//                        //此处需将未读消息的id进行保存
//                        for (ECSUnreadMessagesNotifyChat* message in messages) {
//                            [self insertRoamingMessageIds:[NSArray arrayWithObject:message.id] andContact:chatSession.target];
//                        }
//                        [bgCtx saveToPersistent];
//                        return;
//                    }
//                }
//            //}
//            chatSession.unreadMsgNum = [NSNumber numberWithInteger:notify.num];
//            chatSession.realUnReceiveMsgNum = [NSNumber numberWithInteger:notify.num - notify.chatList.count];
//
//            //second step:
//            //if (notify.num <= DEFAULT_IM_RECORD_NUM) {
//                //chatSession.unreadMsgNum = [NSNumber numberWithInteger:notify.num - notify.chatList.count];
//                for (ECSUnreadMessagesNotifyChat* message in messages) {
//                    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"session=%@ AND messageId=%@", chatSession, message.id];
//                    ChatMessageEntity* messageEntity = [ESpaceLocalDataManager fetchOneObject:predicate inEnitity:@"ChatMessageEntity" inContext:bgCtx];
//
//                    if (!messageEntity) {
//                        if (notify.msgTag != 1) {
//                            //群组消息, 消息中from字段可能群组中的任意成员, 需要每次遍历生成消息from
//                            if (ESpaceMessageFromThirdSys == message.senderType) {
//                                //第三方系统消息从群来，则from为该系统 to 这个群，否则from还是对应的联系人
//                                from = [TUPMediator_ContactService M_systemInfoWithAppID:message.appID inContex:bgCtx autoCreat:YES];
//                                if (0 == [from.appName length]) {
//                                    from.appName = message.appName;
//                                }
//                            }else{
//                                from = [TUPMediator_ContactService M_userWithAccount:message.from inContext:bgCtx autoCreate:YES];
//                            }
//                        }
//
//                        if ([to isKindOfClass:[GroupEntity class]]) {
//                            GroupEntity * group = (GroupEntity*) to;
//                            NSInteger state = [group.state integerValue];
//                            if ((state & ESpaceGroupStateMemberLoaded)!=ESpaceGroupStateMemberLoaded
//                                && from && [from isKindOfClass:[EmployeeEntity class]] &&![group.members containsObject:from]) {
//                                [group addMembersObject:(EmployeeEntity *)from];
//                            }
//                        }
//                        chatSession.unreadMsgNum = [NSNumber numberWithInteger:chatSession.unreadMsgNum.integerValue - 1];
//                        messageEntity = [self handleReceiveUnReadMessages:messageEntity andChatMessage:message withContext:bgCtx chatSession:chatSession from:from to:to];
//                    }
//                    else {
//                        [self insertRoamingMessageIdBasedMsg:[NSArray arrayWithObject:messageEntity] andContact:chatSession.target];
//                        messageEntity.readed = [NSNumber numberWithBool:NO];
//                    }
//                    BOOL flag = atMe;                   //静态检测告警移除
//                    if (flag) {//只对第一条消息添加at列表
//                        [messageEntity addAtObject:[TUPMediator_ContactService M_userWithAccount:currentUser inContext:bgCtx autoCreate:YES]];
//                        atMe = NO;
//                    }
//                    lastestMessage = messageEntity;
//                }
//
//            chatSession.unreadMsgNum = @(notify.num);
//            chatSession.unreadCount = chatSession.unreadMsgNum;
//
//            [bgCtx saveToPersistent];
//
//            //由于PC客户端置消息已读会延迟15秒，如果PC收到消息后查看到15秒期间移动客户端登录成功，会仍然收到PC上看过
//            //的消息作为未读推送，如果期间pc在此回话中发过消息，移动客户端若不从头漫游会丢失自己在PC端发的消息
//            [chatSession queryRoamingMessageBasedId:nil readed:YES count:10 completion:nil];
//
//            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//                [[NSNotificationCenter defaultCenter] postNotificationName:JSAPIReceiveMessagesNotify
//                                                                    object:nil
//                                                                  userInfo:@{JSAPIReceiveMessagesNotifyKey : [[NSArray alloc] init],
//                                                                             JSAPIReceiveMessagesInterfaceKey : [NSNumber numberWithInteger:RecMessageInterfaceUnreadNotify],
//                                                                             JSAPIReceiveMessagesListKey : [NSArray arrayWithObjects:notify, nil]}];
//            });
//            if (lastestMessage) {
//                //未读提醒使用
//                if (notify.msgTag == 1){
//                    [self postReceiveSingleMessageNotification:lastestMessage];
//                }
//                else{
//                    [self postReceiveGroupMessageNotification:lastestMessage];
//                }
//            }//end if
//        }];
//    });
//
//}




//- (void) didReceiveGroupMessage:(NSArray *)messages {
//
//    if (NO == [[ECSAppConfig sharedInstance].currentUser isSupportFunction:EN_FUNC_IM]) {
//        //DDLogError(@"I have no im ability,refuse handle!");  //su TODO
//        return;
//    }
//
//    //屏蔽不支持讨论组功能时的消息
//    ECSSendGroupMsg* firstMsg = [messages firstObject];
//    if (firstMsg && ECSChatGroup == firstMsg.groupType && NO == [[ECSAppConfig sharedInstance].currentUser isSupportFunction:EN_FUNC_DISCUSSION_GROUP]) {
//        //DDLogDebug(@"暂不支持讨论组功能，无法处理该消息！");  //su TODO
//        return;
//    }
//
//
//
//    ESpaceLocalDataManager * localManager = LOCAL_DATA_MANAGER;
//    dispatch_async(espace_coredata_management_queue, ^{
//        NSManagedObjectContext* bgCtx = [localManager backgroundObjectContext];
//        [bgCtx performBlockAndWait:^{
//            NSArray* sortedMessages = [messages sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
//                ECSSendGroupMsg* msg1 = obj1;
//                ECSSendGroupMsg* msg2 = obj2;
//                long long t1 = msg1.milltime;
//                long long t2 = msg2.milltime;
//                return t1 < t2 ? NSOrderedAscending : ((t1 > t2) ? NSOrderedDescending : NSOrderedSame);
//            }];
//
//            NSMutableArray *groupMessageList = [[NSMutableArray alloc] init];
//            for (ECSSendGroupMsg* message in sortedMessages) {
//                ContactEntity *from = nil;
//                ThirdPartSysEntity *tPsysInfoEntity;
//                if (ESpaceMessageFromThirdSys == message.senderType) {
//                    //群里面来系统消息，from是这个系统，to这个群
//                    tPsysInfoEntity = [TUPMediator_ContactService M_systemInfoWithAppID:message.appID inContex:bgCtx autoCreat:YES];
//                    if (0 == [tPsysInfoEntity.appName length]) {
//                        tPsysInfoEntity.appName = message.appName;
//                    }
//                    if (0 == [tPsysInfoEntity.name length]) {
//                        tPsysInfoEntity.name = message.appName;
//                    }
//                    from = tPsysInfoEntity;
//                }else{
//                    from = [TUPMediator_ContactService M_userWithAccount:message.jid inContext:bgCtx autoCreate:YES];
//                }
//                //EmployeeEntity* from = [[ESpaceContactService sharedInstance] userWithAccount:message.jid inContext:bgCtx autoCreate:YES];
//                GroupEntity* group = [TUPMediator_ContactService M_groupWithId:message.from type:message.groupType inContext:bgCtx autoCreate:YES];
//                //GroupEntity* group = [[ESpaceContactService sharedInstance] groupWithMessage:message type:message.groupType inContext:bgCtx autoCreate:YES];
//                if (group.name.length == 0) {
//                    group.name = message.from;
//                }
//                if (from.name.length == 0) {
//                    from.name = message.name;
//                }
//
//                ChatMessageEntity* messageEntity = nil;
//                if (0 != [message.id length]) {
//                    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"to=%@ AND messageId=%@", group, message.id];
//                    messageEntity = [ESpaceLocalDataManager fetchOneObject:predicate inEnitity:@"ChatMessageEntity" inContext:bgCtx];
//                }
//
//                NSInteger groupState = [group.state integerValue];
//                if ((groupState & ESpaceGroupStateMemberLoaded) != ESpaceGroupStateMemberLoaded
//                    && from && ![group.members containsObject:from] && [from isKindOfClass:[EmployeeEntity class]]) {
//                    [group addMembersObject:(EmployeeEntity *)from];
//                }
//                if (!messageEntity) {
//                    //多图文消息兼容,公众号转发消息、链接分享不进行解析
//                    NSArray* subContentArray = [NSArray arrayWithObject:message.body];
//                    if (message.contentType != ESpaceShareLinkContentType
//                        && message.contentType != ESpacePublicAccountContentType) {
//                        subContentArray = [message.body analysisStringWithRegularExpression:@"/:um_begin(.*?)/:um_end"];;
//                    }
//                    for (int i = 0 ; i < subContentArray.count ;i++) {
//                        NSString* subString = [subContentArray objectAtIndex:i];
//                        long long index = i;
//                        NSDate* timestamp = nil;
//
//                        if (message.milltime) {
//                            timestamp = [NSDate dateWithTimeIntervalSince1970:((message.milltime + index) / 1000.0)];
//                        }
//                        else{
//                            timestamp = [NSDate dateWithTimeIntervalSince1970:(message.time + index)];
//                        }
//                        BOOL isRead = NO;
//                        if (subContentArray.count > 1 && index != subContentArray.count - 1) {
//                            isRead = YES;
//                        }
//                        if ([from isKindOfClass:[EmployeeEntity class]]) {
////                            if ([(EmployeeEntity *)from isMe]) {
////                                isRead = YES;
////                            }
//                            if ([TUPMediator_ContactService M_EmployeeIsMe:(EmployeeEntity *)from]) {
//                                isRead = YES;
//                            }
//                        }
//                        messageEntity = [self createMessageForSession:group.chatSession timestamp:timestamp readed:isRead];
//                        //添加@列表
//                        NSString* atUsers = message.atUserList;
//                        NSArray* userList = [NSJSONSerialization JSONObjectWithData:[atUsers dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:nil];
//                        if ([userList isKindOfClass:[NSArray class]]) {
//                            NSMutableSet* userEntitys = [NSMutableSet set];
//                            for (NSDictionary* dic in userList) {
//                                if ([dic isKindOfClass:[NSDictionary class]]) {
//                                    NSString* account = [dic objectForKey:@"account"];
//                                    if (account) {
//                                        [userEntitys addObject:[TUPMediator_ContactService M_userWithAccount:account inContext:bgCtx autoCreate:YES]];
//                                        if ([account compare:LOCAL_DATA_MANAGER.userAccount] == NSOrderedSame) {
//                                            group.chatSession.isAtMe = [NSNumber numberWithBool:YES];
//                                        }
//                                    }
//                                }
//                            }
//                            if (userEntitys.count > 0) {
//                                messageEntity.at = userEntitys;
//                            }
//                        }
//                        messageEntity.from = from;
//                        messageEntity.to = group;
//                        messageEntity.messageId = message.id;
//                        messageEntity.readDetail = [NSNumber numberWithBool:NO];
//                        messageEntity.body = subString;
//                        messageEntity.total = [NSNumber numberWithInteger:subContentArray.count];
//                        messageEntity.senderType = [NSNumber numberWithInteger:message.senderType];
//                        messageEntity.appName = message.appName;
//                        messageEntity.appID = message.appID;
//                        if (subContentArray.count >= 2) {
//                            messageEntity.subIndex = [NSNumber numberWithInteger:i + 1];
//                        }else{
//                            messageEntity.subIndex = [NSNumber numberWithInteger:i];
//                        }
//
//                        messageEntity.contentType = [NSNumber numberWithInteger:[messageEntity contentTypeFromServerValue:message.contentType content:subString]] ;
//
//                        if (messageEntity.contentType.unsignedIntegerValue != ESpaceTextContentType) {
//                            [messageEntity downloadThumbnails];
//                        }
//
//                        [bgCtx saveToPersistent];
//                    }
//
//                    if (nil != messageEntity.objectID) {
//                        [groupMessageList addObject:messageEntity.objectID];
//                    }
//
//                }
//            }
//
//            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//                NSArray *gMsgList = sortedMessages;
//                if (!gMsgList) {
//                    gMsgList = [[NSArray alloc] init];
//                }
//                [[NSNotificationCenter defaultCenter] postNotificationName:JSAPIReceiveMessagesNotify
//                                                                    object:nil
//                                                                  userInfo:@{JSAPIReceiveMessagesNotifyKey : groupMessageList,
//                                                                             JSAPIReceiveMessagesInterfaceKey : [NSNumber numberWithInteger:RecMessageInterfaceGroupMsgNotify],
//                                                                             JSAPIReceiveMessagesListKey : gMsgList}];
//            });
//
//            dispatch_async(dispatch_get_main_queue(), ^{
//                NSDictionary* infoDic = [NSDictionary dictionaryWithObjectsAndKeys:groupMessageList.lastObject,ESPACE_RECEIVE_MESSAGE_NOTIFY_KEY, nil];
//                [[NSNotificationCenter defaultCenter] postNotificationName:ESPACE_RECEIVE_GROUP_MESSAGE_NOTIFY object:nil userInfo:infoDic];
//            });
//        }];
//    });
//
//}

//- (void) markRead:(SessionEntity*) session {
//    if (!session
//        || session.unreadCount.integerValue == 0
//        || ![session isKindOfClass:[ChatSessionEntity class]]
//        || nil == session.latestMessage) {
//        return;
//    }
//    ChatSessionEntity* chatSession = (ChatSessionEntity*) session;
//    ECSMarkRead* markRead = [[ECSMarkRead alloc] init];
//    markRead.ActionType = @"MarkRead";
//    markRead.to = chatSession.target.contactId;
//    markRead.from = [[[ECSAppConfig sharedInstance] currentUser] account];
//    if ([chatSession.target isGroupEntity]) {
//        markRead.markType = MsgMarkReadForGroup;
//        markRead.msgTag = NewMsgMarkRead_Group;
//    } else if ([chatSession.target isEmployeeEnity]) {
//        markRead.markType = MsgMarkReadForIM;
//        markRead.msgTag = NewMsgMarkRead_IM;
//    } else {
//        markRead.markType = MsgMarkReadForOther;
//        markRead.to = markRead.from;
//    }
//    markRead.id = session.latestMessage.messageId;
//
//    NSManagedObjectID* oid = session.objectID;
//    ESpaceLocalDataManager * localManager = LOCAL_DATA_MANAGER;
//
//    dispatch_async(espace_coredata_management_queue, ^{
//        NSManagedObjectContext* ctx = [localManager backgroundObjectContext];
//        [ctx performBlockAndWait:^{
//            SessionEntity* session = (SessionEntity*)[ctx objectWithID:oid];
//            if (session.managedObjectContext && !session.isDeleted) {
//                for (MessageEntity* message in session.messages) {
//                    if (message.readed.boolValue == NO) {
//                        message.readed = [NSNumber numberWithBool:YES];
//                    }
//                }
//                [ctx saveToPersistent];
//                //                [ctx performBlockAndWait:^{
//                //                    if ([ctx hasChanges]) {
//                //                        [ctx save:nil];
//                //                    }
//                //                }];
//            }
//        }];
//    });
//
//
//
//    [self.imessageService markReadWithRequest:markRead completionBlock:^(ECSMarkReadAck *retMsg, NSError *error) {
//        NSLog(@"%@", error);
//    }];
//}

//- (void) markReadLocal:(SessionEntity *)session {
//    if (nil == session) {
//        return;
//    }
//
//    ESpaceLocalDataManager * localManager = LOCAL_DATA_MANAGER;
//    NSManagedObjectID* oid = session.objectID;
//    dispatch_sync(espace_coredata_management_queue, ^{
//        NSManagedObjectContext* bgCtx = [localManager backgroundObjectContext];
//        [bgCtx performBlockAndWait:^{
//            ChatSessionEntity* sessionEntity = (ChatSessionEntity*)[bgCtx objectWithID:oid];
//
//            NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"MessageEntity"];
//            [request setPredicate:[NSPredicate predicateWithFormat:@"session=%@ AND readed=%@", sessionEntity, [NSNumber numberWithBool:NO]]];
//            NSError* queryError = nil;
//
//            NSArray* result = [bgCtx executeFetchRequest:request error:&queryError];
//            if (queryError) {
//                //DDLogError(@"error:(%@)",queryError.localizedDescription); //su TODO
//                return ;
//            }
//
//            for (MessageEntity* msgEntity in result) {
//                msgEntity.readed = [NSNumber numberWithBool:YES];
//            }
//
//            if ([sessionEntity.isAtMe boolValue]) {
//                sessionEntity.isAtMe = [NSNumber numberWithBool:NO];
//            }
//
//            if ([bgCtx hasChanges]) {
//                //DDLogDebug(@"mark [%lu] local message to read", (unsigned long)[result count]); //su TODO
//                //                [bgCtx save:nil];
//                [bgCtx saveToPersistent];
//            }
//        }];
//
//    });
//}
//- (void)MarkReadP2PMessageForTHirdPartyRequest:(ChatSessionEntity*)session message:(ChatMessageEntity*)chatMsg{
//        [self markReadRequest:MsgMarkReadForIM targetId:session.target.contactId msgId:chatMsg.messageId newMsgType:NewMsgMarkRead_IM];
//}

- (void)MarkReadMessageRequest:(ChatSessionEntity*)session  message:(ChatMessageEntity*)chatMsg{
    if ([session.target isEmployeeEnity]) {
        NSMutableArray *chatArray = [[NSMutableArray alloc] init];
        TsdkSetChatMsgReadInfo *readInfo = [[TsdkSetChatMsgReadInfo alloc] init];
        readInfo.msgid = [chatMsg.messageId longLongValue];
        readInfo.historyMsgType = TSDK_E_HISTORY_CHAT_MSG_TYPE_SINGLE_CHAT;
        readInfo.account = ((EmployeeEntity *)session.target).account;
        [chatArray addObject:readInfo];
        
        [[ESpaceContactService sharedInstance] setMessageIsReadedWithReadinfoArray:chatArray];
        
    }
    else if ([session.target isGroupEntity]){
        NSMutableArray *chatArray = [[NSMutableArray alloc] init];
        TsdkSetChatMsgReadInfo *readInfo = [[TsdkSetChatMsgReadInfo alloc] init];
        readInfo.msgid = [chatMsg.messageId longLongValue];
        readInfo.historyMsgType = TSDK_E_HISTORY_CHAT_MSG_TYPE_GROUP_CHAT;
        readInfo.account = ((GroupEntity *)session.target).contactId;
        [chatArray addObject:readInfo];
        
        [[ESpaceContactService sharedInstance] setMessageIsReadedWithReadinfoArray:chatArray];
    }
//    else if ([session.target isKindOfClass:[ThirdPartSysEntity class]]){
//        [self markReadRequest:MsgMarkReadForGroup targetId:session.target.contactId msgId:chatMsg.messageId newMsgType:NewMsgMarkRead_Group];
//    }
}

//- (void)markReadRequestWithTargetId:(NSString *)targetId
//                              msgId:(NSString *)msgId
//                            msgType:(NewMsgMarkReadType)type {
//    [self markReadRequest:MsgMarkReadForIM targetId:targetId msgId:msgId newMsgType:type];
//}

//- (void)markReadRequest:(MsgMarkReadType)type
//               targetId:(NSString *)targetId
//                  msgId:(NSString *)msgId
//             newMsgType:(NewMsgMarkReadType)newType {
//    ECSMarkRead* mr = [[ECSMarkRead alloc] init];
//    mr.ActionType =@"MarkRead";
//    mr.markType = type;
//    mr.from = [[[ECSAppConfig sharedInstance] currentUser] account];
//    mr.to = targetId;
//    mr.id = msgId;
//    mr.msgTag = newType;
//
//    [self.imessageService markReadWithRequest:mr completionBlock:^(ECSMarkReadAck *retMsg, NSError *error) {
//        if (error) {
//            //DDLogError(@"mark read message [%@] failed", msgId); //su TODO
//        }
//    }];
//}

//typedef NS_ENUM(NSInteger, markReadMsgType){
//    markReadMsgP2P = 0,
//    markReadMsgGroup = 1,
//    markReadMsgSMS = 2,
//    markReadMsgSystem = 3,
//    markReadMsgOther = 4
//};

//- (void) didReceiveMessageReadNotify:(ECSMessageReadNotify*) notify {
//
//    if (NSOrderedSame != [notify.to compare:[LOCAL_DATA_MANAGER userAccount]]) {
//        return;
//    }
//    ESpaceLocalDataManager * localManager = LOCAL_DATA_MANAGER;
//    dispatch_async(espace_coredata_management_queue, ^{
//        NSManagedObjectContext* bgCtx = [localManager backgroundObjectContext];
//        [bgCtx performBlockAndWait:^{
//            ChatSessionEntity* chatSession = nil;
//            switch (notify.msgTag) {
//                case markReadMsgP2P:{
//                    EmployeeEntity* from = [TUPMediator_ContactService M_userWithAccount:notify.from inContext:bgCtx autoCreate:YES];
//                    chatSession = from.chatSession;
//                    break;
//                }
//                case markReadMsgGroup:{
//                    GroupEntity* from = [TUPMediator_ContactService M_groupWithId:notify.from type:0 inContext:bgCtx autoCreate:YES];
//                    chatSession = from.chatSession;
//                    break;
//                }
//                case markReadMsgSMS:
//                    break;
//                case markReadMsgSystem:
//                    break;
//                case markReadMsgOther:
//                    break;
//                default:
//                    break;
//            }
//
//            if (chatSession) {
//                NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:@"ChatMessageEntity"];
//                [request setPredicate:[NSPredicate predicateWithFormat:@"session=%@ AND messageId <= %@", chatSession, notify.id]];
//
//                NSError* reqError = nil;
//                NSArray* result = [bgCtx executeFetchRequest:request error:&reqError];
//
//                if (!reqError || [result count] > 0) {
//                    for (MessageEntity* msgEntity in result) {
//                        msgEntity.readed = [NSNumber numberWithBool:YES];
//                    }
//                }
//
//                //                if ([bgCtx hasChanges]) {
//                //                    [bgCtx save:nil];
//                //                }
//                [bgCtx saveToPersistent];
//            }
//        }];
//    });
//}

//- (void)getSensitiveWord:(void (^)(NSError* error)) completionBlock{
//    ECSGetSensitive* getSensitiveWord = [[ECSGetSensitive alloc] init];
//    getSensitiveWord.ActionType = @"GetSensitive";
//    getSensitiveWord.user = [[[ECSAppConfig sharedInstance] currentUser] account];
//    //su TODO
////    [[eSpaceIOSSDK sharedInstance].userSettingService getSensitiveWithRequest:getSensitiveWord completionBlock:^(ECSGetSensitiveAck *retMsg, NSError *error) {
////        if (!error) {
////            [_sensitiveWordDic removeAllObjects];
////
////            NSString* seperateString = @"|";
////            NSString* relpaceWord = @"*";
////            NSString* supportPCSeperateWord = @",";
////
////            NSArray* sensitiveWords = nil;
////            if ([retMsg.w containsString:seperateString]) {
////                sensitiveWords = [retMsg.w componentsSeparatedByString:seperateString];
////            }
////            else{
////                sensitiveWords = [retMsg.w componentsSeparatedByString:supportPCSeperateWord];
////            }
////
////            for (NSString * word in sensitiveWords) {
////
////                NSString * replaceWord = nil;
////
////                //制造一个由'*'组成的字符串,该字符串的长度和敏感词长度一样
////                replaceWord = [@"" stringByPaddingToLength:[word length] withString:relpaceWord startingAtIndex:0];
////
////                [_sensitiveWordDic setObject:replaceWord forKey:word];
////            }
////        }
////        else{
////            DDLogError(@"GetSensitive failed !");
////        }
////        if (completionBlock) {
////            completionBlock(error);
////        }
////    }];
//}

//- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
//    if ([@"serviceStatus" isEqualToString:keyPath]) {
//
//        dispatch_async_main_safe(^{
//            NSNumber* newStatus = [change objectForKey:NSKeyValueChangeNewKey];
//            if (ECServiceLogin == [newStatus integerValue]) {
//                [_validSessions removeAllObjects];
//                if ([[[ECSAppConfig sharedInstance] currentUser] isSupportFunction:EN_FUNC_SENSITIVE_WORDS]) {
//                    [[ESpaceIMessageService sharedInstance] getSensitiveWord:^(NSError *error) {
//
//                    }];
//                }
//                [[ESpaceRecentSessionService sharedInstance] queryRecentSessions:^(NSError *error) {
//
//                }];
//
//                [self queryMuteState:[ECSAppConfig sharedInstance].currentUser.account completion:nil];
//            }
//            else{
//                //DDLogDebug(@"eSpace does not login, it will clear all roaming message id!"); //su TODO
//                [self.loadedSingleChatRoamingMsgId removeAllObjects];
//                [self.loadedGroupChatRoamingMsgId removeAllObjects];
//                //chatstate全置0，保证断网状态进入聊天详情界面会继续漫游
//                [self updateChatState];
//            }
//        });
//    }
//}

//- (void)updateChatState {
//    NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:@"ChatSessionEntity"];
//    NSError* reqError = nil;
//    NSArray* result = [[LOCAL_DATA_MANAGER managedObjectContext] executeFetchRequest:request error:&reqError];
//    if (!reqError || [result count] > 0) {
//        for (ChatSessionEntity* entity in result) {
//            if ([entity.chatState isEqualToNumber:[NSNumber numberWithInt:ECSChatStateLoaded]]) {
//                entity.chatState = [NSNumber numberWithInteger:ECSChatStateNotLoad];
//            }
//        }
//    }
//}

- (NSString*)filterSensitiveWords:(NSString *)inputString
{
    if (_sensitiveWordDic == nil) {
        //DDLogDebug(@"sensitve word is not ready!!!!");  //su TODO
        return inputString;
    }
    
    NSString *outputString = [inputString copy];
    
    NSArray *words = [_sensitiveWordDic allKeys];
    NSRange msgRang = [outputString rangeOfString:outputString];
    
    for (int i = 0;i < [words count]; i++) {
        
        NSString *sensitiveWord = [words objectAtIndex:i];
        
        if ([sensitiveWord length] > [outputString length]) {
            continue;
        }
        
        outputString = [outputString stringByReplacingOccurrencesOfString:sensitiveWord withString:[_sensitiveWordDic objectForKey:sensitiveWord] options:NSCaseInsensitiveSearch range:msgRang];
        
    }
    
    return outputString;
}


//- (void) deleteMessages:(NSArray*) messages
//                session:(SessionEntity*) session
//                 target:(ContactEntity*)target
//        completionBlock:(void (^)(NSError* error)) completionBlock{
//    if (messages.count == 0 && nil == session) {
//        if (completionBlock) {
//            completionBlock(nil);
//        }
//        return;
//    }
//
//    NSMutableArray* remoteOids = [NSMutableArray array];
//    NSMutableArray* remoteMessageIds = [NSMutableArray array];
//    NSMutableArray* allOids = [NSMutableArray array];
//    NSManagedObjectID* sessionOid = session.objectID;
//    [messages enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//        MessageEntity* message = obj;
//        if (message.messageId && [message.transferStatus unsignedIntegerValue] == ESpaceMsgStatusSended) {
//            [remoteOids addObject:message.objectID];
//            [remoteMessageIds addObject:message.messageId];
//        }
//
//        //多图文消息处理
//        if (message.type.integerValue == ESpaceIMMSGType && 0 != [message.messageId length]) {
//            NSFetchRequest* fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"ChatMessageEntity"];
//            [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"session=%@ AND messageId=%@", message.session, message.messageId]];
//            NSArray* resluts = [[LOCAL_DATA_MANAGER managedObjectContext] executeFetchRequest:fetchRequest error:nil];
//            for (ChatMessageEntity* msg in resluts) {
//                [allOids addObject:msg.objectID];
//            }
//        }
//        else{
//            [allOids addObject:message.objectID];
//        }
//    }];
//
//    ESpaceLocalDataManager * localManager = LOCAL_DATA_MANAGER;
//    //删除数据库数据
//    dispatch_async(espace_coredata_management_queue, ^{
//        NSManagedObjectContext* bgCtx = [localManager backgroundObjectContext];
//        [bgCtx performBlockAndWait:^{
//            SessionEntity* session = (SessionEntity*)[bgCtx objectWithID:sessionOid];
//            if (allOids.count > 0) {
//                NSMutableSet* messages = [NSMutableSet set];
//                for (NSManagedObjectID* oid in allOids) {
//                    MessageEntity* obj = (MessageEntity*)[bgCtx objectWithID:oid];
//                    if (obj.managedObjectContext && !obj.isDeleted) {
//                        [messages addObject:obj];
//                    }
//                }
//                [session localDeleteMessages:messages];
//
//            } else {
//                [session localDeleteAllMessages];
//            }
//            //            [session updateLatestMessage];
//
//            //            if ([bgCtx hasChanges]) {
//            //                [bgCtx save:nil];
//            //            }
//            [bgCtx processPendingChanges];
//            [bgCtx saveToPersistent];
//            if (completionBlock) {
//                completionBlock(nil);
//            }
//        }];
//    });
//
//    if ([session isKindOfClass:[ChatSessionEntity class]]) {
//        if ([[[ECSAppConfig sharedInstance] currentUser] isSupportFunction:EN_FUNC_ROAMING_MESSAGE]) {
//            [self deleteIMessageWithIds:remoteMessageIds contact:target completionBlock:nil];
//        }
//    }
//
//}

//- (void) deleteIMessageWithIds:(NSArray*) ids contact:(ContactEntity*) target completionBlock:(void (^)(NSError* error)) completionBlock {
//    if (!target) {
//        if (completionBlock) {
//            completionBlock(nil);
//        }
//        return;
//    }
//
//    ECSDelRoamingMsg* delMsg = [[ECSDelRoamingMsg alloc] init];
//    delMsg.ActionType = @"DelRoamingMsg";
//    if ([target isGroupEntity]) {
//        delMsg.msgTag = 2;
//    } else {
//        delMsg.msgTag = 1;
//    }
//    delMsg.targetid = target.contactId;
//    delMsg.type = [ids count] == 0 ? 1 : 0;
//    delMsg.msgList = ids;
//    delMsg.user = [[[ECSAppConfig sharedInstance] currentUser] account];
//    [self.imessageService delRoamingMsgWithRequest:delMsg completionBlock:^(ECSDelRoamingMsgAck *retMsg, NSError *error) {
//        if (completionBlock) {
//            completionBlock(error);
//        }
//    }];
//}
//su TODO
//- (void) deleteCallMessageWithIds:(NSArray*) ids contact:(ContactEntity*) target completionBlock:(void (^)(NSError* error)) completionBlock {
//    ECSDelCallLog* delCall = [[ECSDelCallLog alloc] init];
//    delCall.ActionType = @"DelCallLog";
//    delCall.user = [[ECSAppConfig sharedInstance] currentUser].account;
//    short type = 0;
//    if (target.contactId) {
//        type = 2;
//        delCall.delUser = target.contactId;
//    } else if ([ids count] > 0) {
//        type = 0;
//        NSString* logids = [ids componentsJoinedByString:@","];
//        delCall.logID = logids;
//    } else {
//        type = 1;
//    }
//    delCall.delUser = target.contactId;
//    delCall.type = type;
//    [[eSpaceIOSSDK sharedInstance].callService delCallLogWithRequest:delCall completionBlock:^(ECSDelCallLogAck *retMsg, NSError *error) {
//        if (completionBlock) {
//            completionBlock(error);
//        }
//    }];
//}

/**
 *  将发送中的消息置为失败,包括IM、topic、comment、publicAccount message
 */
- (void) markSendingMessageToFailed {
    NSManagedObjectContext* bgCtx = [LOCAL_DATA_MANAGER backgroundObjectContext];
    [bgCtx performBlock:^{
        //DDLogInfo(@"Begin to mark sending message failed...");  //su TODO
        //IM and publicAccount message
        NSPredicate* failedSendChatFilter = [NSPredicate predicateWithFormat:@"transferStatus = %@ AND flag=%@", [NSNumber numberWithInteger:ESpaceMsgStatusSending], [NSNumber numberWithInteger:ESpaceMessageFlagNormal]];
        NSArray* failedChatMsgs = [ESpaceLocalDataManager fetchObjects:failedSendChatFilter inEnitity:@"ChatMessageEntity" inContext:bgCtx];
        if ([failedChatMsgs count] > 0) {
            //DDLogInfo(@"Have sending chat messages, count:%lu", (unsigned long)failedChatMsgs.count);  //su TODO
        }
        for (ChatMessageEntity* chatMsg in failedChatMsgs) {
            chatMsg.transferStatus = [NSNumber numberWithInteger:ESpaceMsgStatusSendFailed];
        }
        //topic TODO wxy
//        NSPredicate* failedTopicFilter = [NSPredicate predicateWithFormat:@"transferStatus = %@", [NSNumber numberWithInteger:CircleSessionSending]];
//        NSArray* failedTopics = [ESpaceLocalDataManager fetchObjects:failedTopicFilter inEnitity:@"CircleSessionEntity" inContext:bgCtx];
//        if ([failedTopics count] > 0) {
//            //DDLogInfo(@"Have sending topics, count:%lu", (unsigned long)failedTopics.count);//su TODO
//        }
//        for (CircleSessionEntity* topic in failedTopics) {
//            topic.transferStatus = [NSNumber numberWithInteger:CircleSessionSendFailed];
//        }
        //comment,评论不在此处处理
        /*
         NSPredicate* failedCommentFilter = [NSPredicate predicateWithFormat:@"transferStatus=%@", [NSNumber numberWithInteger:ESpaceMsgStatusSending]];
         NSArray* failedComment = [ESpaceLocalDataManager fetchObjects:failedCommentFilter inEnitity:@"CircleComment" inContext:bgCtx];
         if ([failedComment count] > 0) {
         DDLogInfo(@"Have sending comments, count:%lu", (unsigned long)failedComment.count);
         }
         for (CircleComment* comment in failedComment) {
         [comment publicComment:nil];
         }
         */
        
        [bgCtx save:nil];
    }];
}

#pragma mark - 收到新的系统公告

//- (void)didReceiveNewBulletinNotify:(ECSNewsMessage *)notify{
//    //DDLogDebug(@"收到新的系统公告");  //su TODO
//
//    [[ESpaceIMessageService sharedInstance] markReadRequest:MsgMarkReadForOther
//                                                   targetId:[LOCAL_DATA_MANAGER userAccount]
//                                                      msgId:notify.id
//                                                 newMsgType:NewMsgMarkRead_SystemNotice];
//
//    dispatch_async_main_safe(^{
//        if ([[ECSAppConfig sharedInstance].currentUser isSupportFunction:EN_FUNC_NEWS]) {
//            [[NSNotificationCenter defaultCenter] postNotificationName:ESPACE_NEW_BULLETIN_NOTIFY object:nil];
//        }
//    });
//}

#pragma mark - 消息撤回
//- (void) didReceiveOprMsgNotify:(ECSOprMsgNotify*) notify{
//    //删除本地已经有的chatmessage
//    //构建一个xxx撤回的message
//    __weak typeof(self) weakSelf = self;
//    ESpaceLocalDataManager * localManager = LOCAL_DATA_MANAGER;
//    dispatch_async(espace_coredata_management_queue, ^{
//        NSManagedObjectContext* bgCtx = [localManager backgroundObjectContext];
//        [bgCtx performBlockAndWait:^{
//            for (NSString *msgId in notify.msgIDList) {
//                NSPredicate* predicate = [NSPredicate predicateWithFormat:@"messageId=%@",msgId];
//                //ChatMessageEntity* message = [ESpaceLocalDataManager fetchOneObject:predicate inEnitity:@"ChatMessageEntity" inContext:bgCtx];
//                NSArray *arr = [ESpaceLocalDataManager fetchObjects:predicate inEnitity:@"ChatMessageEntity" inContext:bgCtx];
//                BOOL isMsgRead = YES;
//                if (arr && [arr count] > 0) {
//                    ChatMessageEntity *message = (ChatMessageEntity *)[arr objectAtIndex:0];
//                    isMsgRead = message.readed.boolValue;
//                    if (message) {
//                        ContactEntity *to = message.to;
//                        EmployeeEntity *employer = (EmployeeEntity *)message.from;
//                        BOOL fromIsMe = [TUPMediator_ContactService M_EmployeeIsMe:employer];
//                        ChatSessionEntity *session = nil;
//
//                        if ([to isKindOfClass:[GroupEntity class]] || fromIsMe) {
//                            session = message.to.chatSession;
//                        }else{
//                            session = message.from.chatSession;
//                        }
//                        session.isAtMe = [NSNumber numberWithBool:NO];
//                        ChatMessageEntity* msgEntity = [[ESpaceIMessageService sharedInstance] createMessageForSession:session timestamp:message.receiveTimestamp flag:ESpaceMessageFlagRecalled readed:YES];
//                        msgEntity.messageId = message.messageId;
//                        //msgEntity.dataBaseId = message.dataBaseId;
//                        msgEntity.from = message.from;
//                        msgEntity.to = message.to;
//                        msgEntity.receiveTimestamp = message.receiveTimestamp;
//                        msgEntity.flag = [NSNumber numberWithInteger:ESpaceMessageFlagRecalled];
//                        msgEntity.body = [NSString stringWithFormat:ECSLocalizedString(@"opr_msg_withdraw_hint",nil),(fromIsMe ? ECSLocalizedString(@"opr_msg_withdraw_you",nil): [NSString stringWithFormat:@"\"%@\"",message.from.uiDisplayName])];
//
//                        for (ChatMessageEntity *entity in arr) {
//                            ESpaceUMResource *resource = [entity.umResources lastObject];
//                            if (resource) {
//                                switch (resource.umType) {
//                                    case ESpaceUMTypeAudio:
//                                        if ([resource isKindOfClass:[ESpaceUMAudioResource class]]) {
//                                            ESpaceUMAudioResource *audio = (ESpaceUMAudioResource *)resource;
//                                            dispatch_async(dispatch_get_main_queue(), ^{
//                                                [audio stop];
//                                            });
//                                        }
//                                        break;
//                                    case ESpaceUMTypeFile:
//                                    {
//                                        dispatch_async(dispatch_get_main_queue(), ^{
//                                            [[NSNotificationCenter defaultCenter] postNotificationName:ESPACE_MESSAGE_RECALLED_FILE_UM_NOTIFY_KEY object:message.messageId];
//                                        });
//                                        break;
//                                    }
//                                    case ESpaceUMTypeImage:
//                                    case ESpaceUMTypeVideo:
//                                    {
//                                        dispatch_async(dispatch_get_main_queue(), ^{
//                                            [[NSNotificationCenter defaultCenter] postNotificationName:ESPACE_MESSAGE_RECALLED_MEDIA_UM_NOTIFY_KEY object:message.messageId];
//                                        });
//                                        break;
//                                    }
//                                    default:
//                                        break;
//                                }
//                            }
//                        }
//
//                        NSSet *revokset = [NSSet setWithArray:arr];
//                        [session localDeleteMessages:revokset];
//                        if ([bgCtx hasChanges]) {
//                            [bgCtx save:nil];
//                        }
//                        [bgCtx saveToPersistent];
//                        dispatch_async(dispatch_get_main_queue(), ^{
//                            NSDictionary* infoDic = [NSDictionary dictionaryWithObjectsAndKeys:msgId,ESPACE_MESSAGE_RECALLED_NOTIFY_KEY, [NSNumber numberWithBool:isMsgRead], ESPACE_MESSAGE_RECALLED_NOTIFY_MSGSTATE_KEY, nil];
//                            [[NSNotificationCenter defaultCenter] postNotificationName:ESPACE_MESSAGE_RECALLED_NOTIFY object:nil userInfo:infoDic];
//                        });
//                    }
//
//                }
//                //已经有的消息才进行xxx撤回了一条消息提示
//                /*
//                else{
//                    ChatSessionEntity *session = nil;
//                    NSArray *rangArr = [NSArray array];
//                    if (1 == notify.messageType) {
//                        //点对点
//                        rangArr = [weakSelf.unReceiveMsgRangDic objectForKey:notify.oprUser];
//                        ContactEntity *people = [[ESpaceContactService sharedInstance] userWithAccount:notify.oprUser inContext:bgCtx autoCreate:YES];
//                        session = people.chatSession;
//                    }else if (2 == notify.messageType){
//                        //群组
//                        rangArr = [weakSelf.unReceiveMsgRangDic objectForKey:notify.targetId];
//                        GroupEntity *group = [[ESpaceContactService sharedInstance] groupWithId:notify.targetId inContext:bgCtx];
//                        session = group.chatSession;
//                    }
//
//                    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"session=%@ AND readed=%@ AND flag=%@", session, [NSNumber numberWithBool:YES],[NSNumber numberWithInteger:ESpaceMessageFlagNormal]];
//                    ChatMessageEntity* messageEntity = [ESpaceLocalDataManager fetchOneObject:predicate inEnitity:@"ChatMessageEntity" inContext:bgCtx];
//
//                    if (nil != rangArr && [rangArr count] == 2 && [messageEntity.messageId compare:msgId] == NSOrderedAscending) {
//                        NSString *min = [rangArr firstObject];
//                        NSString *max = [rangArr lastObject];
//                        if ( NSOrderedDescending == [msgId compare:min] && NSOrderedAscending == [msgId compare:max]
//                            || (NSOrderedSame == [min compare:msgId] || NSOrderedSame == [max compare:msgId])) {
//                            if (session.unreadCount.integerValue > 0) {
//                                session.unreadCount = [NSNumber numberWithInteger:session.unreadCount.integerValue - 1];
//                            }
//                            if (session.unreadMsgNum.integerValue > 0) {
//                                session.unreadMsgNum = [NSNumber numberWithInteger:session.unreadMsgNum.integerValue - 1];
//                            }
//                            if (session.realUnReceiveMsgNum.integerValue > 0) {
//                                session.realUnReceiveMsgNum = [NSNumber numberWithInteger:session.realUnReceiveMsgNum.integerValue - 1];
//                            }
//                        }else if(NSOrderedDescending == [msgId compare:min] && NSOrderedAscending == [msgId compare:max]){
//                            if (session.realUnReceiveMsgNum.integerValue > 0) {
//                                session.realUnReceiveMsgNum = [NSNumber numberWithInteger:session.realUnReceiveMsgNum.integerValue - 1];
//                            }
//                        }
//                    }
//                    if ([bgCtx hasChanges]) {
//                        [bgCtx save:nil];
//                    }
//                    //[bgCtx saveToPersistent];
//                }
//                 */
//
//            }
//        }];
//
//    });
//}

#pragma mark - 指令性消息
//指令性消息接收通知
//- (void) didReceiveOprCommandNotify:(ECSOprCommandNotify*) notify{
//    dispatch_async(espace_coredata_management_queue, ^{
//        NSManagedObjectContext* bgCtx = [LOCAL_DATA_MANAGER backgroundObjectContext];
//        [bgCtx performBlockAndWait:^{
////
////            ChatMessageEntity* message = nil;
////            NSDate* timestamp = [ECSUtils dateFromMillisecondUTCValue:notify.deliverTime];;
////            //发送方为IP，按照第三方显示
////            if ([notify.groupId isEqualToString:@"-1"]) {
////                if (notify.senderType == ESpaceMessageFromThirdSys) {
////                    ThirdPartSysEntity *tPsysInfoEntity = [[ESpaceContactService sharedInstance] systemInfoWithAppID:notify.originAppID
////                                                                                                            inContex:bgCtx autoCreat:YES];
////                    message = [[ESpaceIMessageService sharedInstance] createMessageForSession:tPsysInfoEntity.chatSession timestamp:timestamp readed:NO];
////                    EmployeeEntity* to = [[ESpaceContactService sharedInstance] userWithAccount:notify.target inContext:bgCtx autoCreate:YES];
////                    message.to = to;
////                    message.from = tPsysInfoEntity;
////                }else{
////                    EmployeeEntity *fromUser = [[ESpaceContactService sharedInstance] userWithAccount:notify.origin inContext:bgCtx autoCreate:YES];
////                    message = [[ESpaceIMessageService sharedInstance] createMessageForSession:fromUser.chatSession timestamp:timestamp readed:YES];
////                    EmployeeEntity* to = [[ESpaceContactService sharedInstance] userWithAccount:notify.target inContext:bgCtx autoCreate:YES];
////                    message.to = to;
////                    message.from = fromUser;
////                }
////            }else{
////                GroupEntity* group = [[ESpaceContactService sharedInstance] groupWithId:notify.groupId type:0 inContext:bgCtx autoCreate:YES];
////                message = [[ESpaceIMessageService sharedInstance] createMessageForSession:group.chatSession timestamp:timestamp readed:NO];
////                message.to = group;
////                if (notify.senderType == ESpaceMessageFromThirdSys) {
////                    ThirdPartSysEntity *tPsysInfoEntity = [[ESpaceContactService sharedInstance] systemInfoWithAppID:notify.originAppID
////                                                                                                            inContex:bgCtx autoCreat:YES];
////                    message.from = tPsysInfoEntity;
////                }else{
////                    EmployeeEntity *fromUser = [[ESpaceContactService sharedInstance] userWithAccount:notify.origin inContext:bgCtx autoCreate:YES];
////                    message.from = fromUser;
////                }
////
////            }
////            message.appID = notify.originAppID;
////            message.appName = notify.originAppName;
////            message.senderType = [NSNumber numberWithInteger:notify.senderType];
////            message.body = notify.commandBody;
////            message.contentType = [NSNumber numberWithInteger:ESpaceCardMsgOrderType];
////            message.messageId = notify.id;
////            [bgCtx saveToPersistent];
//
//
//            NSString *oprTypeKey = @"oprType";
//            NSString *oprContextKey = @"oprContext";
//            NSMutableDictionary* infoDic = [NSMutableDictionary dictionary];
//            if (notify.commandBody) {
//                infoDic = [NSJSONSerialization JSONObjectWithData:[notify.commandBody dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:nil];
//            }
//
//            if (0 == [infoDic count]) {
//                //DDLogInfo(@"opr message info is null.");  //su TODO
//                return;
//            }
//
//            switch ([[infoDic valueForKey:oprTypeKey] integerValue]) {
//                case ESpaceOprTypeConference:{
//                    //DDLogInfo(@"receive video conference command."); //su TODO
//                    dispatch_async(dispatch_get_main_queue(), ^{
//
//                        NSDictionary* oprContextDic = [infoDic valueForKey:oprContextKey];
//                        NSString* ipn = [infoDic valueForKey:@"ipn"];
//
//                        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"im", @"bussiness", [NSNumber numberWithLongLong:notify.deliverTime], @"deliverTime", nil];
//
//                        if (oprContextDic) {
//                            [dic setObject:oprContextDic forKey:@"data"];
//                        }
//
//                        if ([ipn length]) {
//                            [dic setObject:ipn forKey:@"ipn"];
//                        }
//
//                        NSString * notifyName = @"com.huawei.it.W3MCore.im.command.message";
//                        [[NSNotificationCenter defaultCenter] postNotificationName:notifyName object:nil userInfo:dic];
//                        //DDLogInfo(@"post com.huawei.it.W3MCore.im.command.message notify"); //su TODO
//                    });
//                    break;
//                }
//                case ESpaceOprTypePublicNumber:{
//                    //DDLogInfo(@"receive PublicNO. message command.");  su TODO
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
//
//                        if (infoDic) {
//                            [dic setObject:infoDic forKey:@"data"];
//                        }
//
//                        NSString * notifyName = @"com.huawei.it.W3MCore.im.command.publicNo";
//                        [[NSNotificationCenter defaultCenter] postNotificationName:notifyName object:nil userInfo:dic];
//                        //DDLogInfo(@"post com.huawei.it.W3MCore.im.command.publicNo notify");  //su TODO
//                    });
//                    break;
//                }
//                default:
//                    break;
//            }
//
//        }];
//    });
//}

//- (void)sendOprCommandMessageToUsers:(NSArray *)userArray withMsg:(NSString *)msgBody completionBlock:(void (^)(NSError* error, ECSOprCommandAck* result)) completionBlock{
//    //命令消息，上行接口
//    ECSOprCommand *opt = [[ECSOprCommand alloc] init];
//    opt.ActionType = @"OprCommand";
//    opt.originAppID = [ECSAppConfig sharedInstance].appID;
//    opt.originAppName = [ECSAppConfig sharedInstance].appName;
//    opt.senderType = 0;
//    opt.origin = [ECSAppConfig sharedInstance].currentUser.account;
//    opt.userList = userArray;
//    opt.commandBody = msgBody;
//    opt.receiverType = 0;
//
//    [self.oprCommandService oprCommandWithRequest:opt completionBlock:^(ECSOprCommandAck *retMsg, NSError *error) {
//        if (!error) {
//            NSLog(@"command message send to people success");
//        }else{
//            NSLog(@"command send to people error");
//        }
//    }];
//}

//- (void)sendOprCommandMessageToGroup:(NSString *)groupId withMsg:(NSString *)msgBody completionBlock:(void (^)(NSError* error, ECSOprCommandAck* result)) completionBlock{
//    ECSOprCommand *opt = [[ECSOprCommand alloc] init];
//    opt.ActionType = @"OprCommand";
//    opt.originAppID = [ECSAppConfig sharedInstance].appID;
//    opt.originAppName = [ECSAppConfig sharedInstance].appName;
//    opt.senderType = 0;
//    opt.origin = [ECSAppConfig sharedInstance].currentUser.account;
//    opt.groupID = groupId;
//    opt.commandBody = msgBody;
//    opt.receiverType = 1;
//
//    [self.oprCommandService oprCommandWithRequest:opt completionBlock:^(ECSOprCommandAck *retMsg, NSError *error) {
//        if (!error) {
//            NSLog(@"command message send to group success");
//        }else{
//            NSLog(@"command send to group error");
//        }
//    }];
//}

//- (void)setSelfMuteForMobile:(NSString *)account withMuteFlag:(BOOL)muteFlag completion:(void(^)(NSError* error))completionBlock{
//    ECSSetMuteForMobile *opt = [[ECSSetMuteForMobile alloc] init];
//    opt.ActionType = @"SetMuteForMobile";
//    opt.user = account;
//    opt.muteFlagForMobile = [NSString stringWithFormat:@"%d",muteFlag];
//    [_oprCommandService setMuteForMobileWithRequest:opt completionBlock:^(ECSSetMuteForMobileAck *retMsg, NSError *error) {
//        if (error) {
//            if (completionBlock) {
//                completionBlock(error);
//            }
//        }
//        else{
//            [[ECSAppConfig sharedInstance] currentUser].isMute = ![[ECSAppConfig sharedInstance] currentUser].isMute;
//            if (completionBlock) {
//                completionBlock(nil);
//            }
//        }
//    }];
//}

//- (void)queryMuteState:(NSString *)account completion:(void(^)(NSError* error))completionBlock{
//
//    if (NO == [[ECSAppConfig sharedInstance].currentUser isSupportMuteSelf]) {
//        return;
//    }
//
//    ECSGetMuteForMobile *opt = [[ECSGetMuteForMobile alloc] init];
//    opt.ActionType = @"GetMuteForMobile";
//    opt.user = account;
//    [_oprCommandService getMuteForMobileWithRequest:opt completionBlock:^(ECSGetMuteForMobileAck *retMsg, NSError *error) {
//        if (error) {
//            if (completionBlock) {
//                completionBlock(error);
//            }
//        }else{
//            NSString *flagStr = retMsg.muteFlagForMobile;
//            [[ECSAppConfig sharedInstance] currentUser].isMute = [flagStr boolValue];
//            if (completionBlock) {
//                completionBlock(nil);
//            }
//        }
//    }];
//}

@end
