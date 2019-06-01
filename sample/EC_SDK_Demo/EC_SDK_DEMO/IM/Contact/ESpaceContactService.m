//
//  ESpaceContactService.m
//  eSpaceUI
//
//  Created by yemingxing on 3/19/15.
//  Copyright (c) 2015 www.huawei.com. All rights reserved.
//

#import "ESpaceContactService.h"
#import "ECSUtils.h"
#import "EmployeeEntity.h"
#import "LocalContactEntity.h"
#import "ChatSessionEntity.h"
#import "ESpaceLocalDataManager.h"
//#import "ECSContactService.h"
#import "GroupEntity.h"
#import "GroupFileEntity.h"
#import "EmployeeCategoryEntity.h"
#import "ChatMessageEntity.h"
#import "ECSAppConfig.h"
#import "NSDate+LocalString.h"
//#import "EmployeeEntity+ServiceObject.h"
#import "PersonEntity.h"
#import "CustomContactEntity.h"
#import "ECSafeMutableDictionary.h"
#import "CallSessionEntity.h"
#import "AssistantSessionEntity.h"
//#import "MsgLogSessionEntity+ServiceObject.h"
#import "NSManagedObjectContext+Persistent.h"
//#import "GroupEntity+ServiceObject.h"
//#import "ESpaceLPPairItem.h"
#import "NSString+FileType.h"
#import "ECSErrorCode.h"
//#import "PhoneticContacts.h"
#import "ThirdPartSysEntity.h"
#import "ESpaceContactNotification.h"
//#import "TUPMAALoginService.h"
//#import "ECSNetworkService.h"
#import "eSpaceDBService.h"
//#import "TUPMediator_UserSettingService.h"
//#import <ecs/ctk/ctk.h>
//#import "ECSLogCofig.h"
//#import "TUPMediator_IMService.h"
//#import "ECSUserMAAInfo.h"
//#import "ESpaceGroupService.h"
//#import "ESpaceLocalContactService.h"

#import "ManagerService.h"
#import "tsdk_error_def.h"
#import "tsdk_im_interface.h"
#import "NSManagedObjectContext+Persistent.h"
#import "GroupEntity+ServiceObject.h"
#import "Initializer.h"
#import "GroupEntity.h"
#import "NSString+Transform.h"
#import "ChatMessageEntity+ServiceObject.h"
#import "MessageEntity+ServiceObject.h"


@interface ECSImChatMsgXmlInfo : NSObject<NSXMLParserDelegate>
{
    NSXMLParser *xmlParser;
    NSMutableString *currentStringValue;
}
@property (nonatomic, copy) NSString *content;

/**
 使用userInfo的Xml字符串进行初始化
 
 @param xmlString userInfo的xml字符串
 
 @return 实例对象
 */
- (instancetype)initWithXmlUserInfo:(NSString *)xmlString;
@end



@implementation ECSImChatMsgXmlInfo

- (instancetype)initWithXmlUserInfo:(NSString *)xmlString
{
    if (self = [super init]){
        if (xmlString.length > 0)
        {
            currentStringValue = [[NSMutableString alloc]initWithCapacity:0];
            xmlParser = [[NSXMLParser alloc]initWithData:[xmlString dataUsingEncoding:NSUTF8StringEncoding]];
            xmlParser.delegate = self;
            [xmlParser parse];
        }
    }
    return self;
}

#pragma mark NSXMLParserDelegate

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    [currentStringValue setString:@""];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    
    if ([elementName isEqualToString:@"content"]) {
        NSString *str = [currentStringValue stringByTrimmingCharactersInSet:
                         [NSCharacterSet whitespaceAndNewlineCharacterSet]];
        self.content = str;
    }
    
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    [currentStringValue appendString:string];
}


@end

#define MAX_GROUP_NAME_LENGTH 85

static NSString* const contactsSyncFieldsForSimpleMode = @"id,name,en,p,voip,voip2,nativeName,m,sp,op,bd,nk,si,tid,fr,originMobile,originOffice,headid,domain";

NSString* ESPACE_USER_STATUS_CHANGED            = @"com.huawei.espace.userstatus";
NSString* ESPACE_USER_STATUS_CHANGED_BY_ACCOUNT = @"ESPACE_USER_STATUS_CHANGED_BY_ACCOUNT";
NSString* ESPACE_CONTACT_FULL_SYNC_FINISHED     = @"com.huawei.espace.contact.fullsync";
#define ESPACE_CALLCONTACT_IDPREFIX             @"ESPACE_CALLCONTACT_IDPREFIX"

NSString* ESpaceAddFriendNotify                 = @"ESpaceAddFriendNotify";
NSString* ESpaceAddFriendNotify_TitleKey        = @"ESpaceAddFriendNotify_TitleKey";

NSString* TUP_USER_STATUS_CHANGED            = @"com.huawei.espace.userstatus";


typedef NS_ENUM(NSInteger, ESpaceSyncType) {
    ESpaceFullSync = 0,     //全量同步
    ESpacePartailSync = 1   //增量同步
};

@interface ESpaceContactService () <ImContactNotification>//<ECSContactServiceDelegate>
@property (nonatomic, strong) ECSafeMutableDictionary* subscribedUsers;
//@property (nonatomic, strong) ECSContactService *contactService;
@property (nonatomic, strong) NSMutableArray* bForceSubscribedUsers;    // value: account 向服务器强制订阅过状态的好友列表

@property (nonatomic, strong)void (^sendMsgBackAction)(TsdkSendChatMsgResult*, NSError*);
@end

@implementation ESpaceContactService
@synthesize loginStatus = _loginStatus;
- (instancetype)init {
    if (self = [super init]) {
        [((id)[ManagerService loginService]) addObserver:self forKeyPath:@"serviceStatus" options:NSKeyValueObservingOptionNew context:NULL];
        [self setLoginStatus:[ManagerService loginService].serviceStatus];
        
//        self.contactService = [[ECSContactService alloc] init];
//        self.contactService.delegate = self;
//        [[ECSNetworkService sharedInstance] registerSerivce:self.contactService];
        _subscribedUsers = [ECSafeMutableDictionary dictionary];
        _validGroupHeadImages = [[NSMutableSet alloc] init];
        _nonFriendsRefreshTagsDic = [[ECSafeMutableDictionary alloc] init];
        _bForceSubscribedUsers = [[NSMutableArray alloc] init];
        
        // 设置联系人回调的delegate
        [Initializer registerImContactCallBack:self];
        _currentContactGroupId = nil;
    }
    return self;
}

/**
 * This method is used to deel contact event callback from service
 * 分发联系人业务相关回调
 *@param module TUP_MODULE
 *@param notification Notification
 */
- (void)imContactModule:(TUP_MODULE)module notification:(Notification *)notification {
    if (module == IM_CONTACT_MODULE) {
        switch (notification.msgId) {
            case TSDK_E_IM_EVT_USER_STATUS_UPDATE:
            {
                DDLogInfo(@"TSDK_E_IM_EVT_USER_STATUS_UPDATE");
                NSInteger count = notification.param2;
                TSDK_S_IM_USER_STATUS_UPDATE_INFO * userStatusInfo = notification.data;
                
                dispatch_async(espace_coredata_management_queue, ^{
                    ESpaceLocalDataManager * localManager = LOCAL_DATA_MANAGER;
                    NSManagedObjectContext* bgCtx = [localManager backgroundObjectContext];
                    for (int i = 0; i < count; i++) {
                        TSDK_S_IM_USER_STATUS_UPDATE_INFO statusInfo = userStatusInfo[i];
                        EmployeeEntity* userEntity = [self userWithAccount:[NSString stringWithUTF8String:statusInfo.origin] inContext:bgCtx autoCreate:YES];
                        userEntity.userStatus = [NSNumber numberWithInteger:statusInfo.status];
                    }
                    [bgCtx saveToPersistentAndWait];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[NSNotificationCenter defaultCenter] postNotificationName:TUP_USER_STATUS_CHANGED object:nil];
                    });
                });
                
                
            }
                break;
            case TSDK_E_IM_EVT_USER_INFO_UPDATE:
            {
                 DDLogInfo(@"TSDK_E_IM_EVT_USER_INFO_UPDATE");
            }
                break;
                
            case TSDK_E_IM_EVT_CHAT_GROUP_INFO_UPDATE:
            {
                DDLogInfo(@"TSDK_E_IM_EVT_CHAT_GROUP_INFO_UPDATE");
                TSDK_E_CHAT_GROUP_INFO_UPDATE_TYPE updateType = notification.param2;
                TSDK_S_CHAT_GROUP_UPDATE_INFO* group_update_info = notification.data;
                
                
                dispatch_async(espace_coredata_management_queue, ^{
                    ESpaceLocalDataManager * localManager = LOCAL_DATA_MANAGER;
                    NSManagedObjectContext* bgCtx = [localManager backgroundObjectContext];
                    
                    if (updateType == TSDK_E_CHAT_GROUP_DEFAULT_INFO_UPDATE) {
                        GroupEntity* groupEntity = [self groupWithId:[NSString stringWithUTF8String:group_update_info->group_id] type:group_update_info->group_type inContext:bgCtx autoCreate:YES];
                        groupEntity.groupType = [NSNumber numberWithInteger:group_update_info->group_type];
                        groupEntity.contactId = [NSString stringWithUTF8String:group_update_info->group_id];
                        groupEntity.name = [NSString stringWithUTF8String:group_update_info->group_name];
                        groupEntity.enName = [NSString stringWithUTF8String:group_update_info->group_name_en];
                        groupEntity.ownerId = [NSString stringWithUTF8String:group_update_info->owner_account];
                    }
                    [bgCtx saveToPersistentAndWait];
                });
            }
                break;
            case TSDK_E_IM_EVT_JOIN_CHAT_GROUP_IND:
            {
                DDLogInfo(@"TSDK_E_IM_EVT_JOIN_CHAT_GROUP_IND");
            }
                break;
            case TSDK_E_IM_EVT_CHAT_MSG:
            {
                DDLogInfo(@"TSDK_E_IM_EVT_CHAT_MSG");
                TSDK_S_CHAT_MSG_INFO* chat_msg = notification.data;

                TsdkChatMessageInfo* msgObj = [self msgInfoToChatMessage:chat_msg];
                [self didReceiveChatMessage:msgObj];
            }
                break;
            case TSDK_E_IM_EVT_BATCH_CHAT_MSG:
            {
                TSDK_S_BATCH_CHAT_MSG_INFO* batch_chat_msg = notification.data;
                TsdkBatchChatMessageInfo *batchMsgInfo = [self batchMsgInfoToBatchChatMessage:batch_chat_msg];
                [self didReceiveBatchChatMessage:batchMsgInfo];
                DDLogInfo(@"TSDK_E_IM_EVT_BATCH_CHAT_MSG");
            }
                break;
            case TSDK_E_IM_EVT_MSG_READ_IND:
            {
//                TSDK_S_MSG_READ_IND_INFO* read_ind_info = notification.data;
                DDLogInfo(@"TSDK_E_IM_EVT_MSG_READ_IND");
            }
                break;
            case TSDK_E_IM_EVT_UNDELIVER_IND:
            {
//                TSDK_S_CHAT_MSG_UNDELIVER_INFO* undeliver_info = notification.data;
                DDLogInfo(@"TSDK_E_IM_EVT_UNDELIVER_IND");
            }
                break;
            case TSDK_E_IM_EVT_MSG_SEND_RESULT:
            {
                DDLogInfo(@"TSDK_E_IM_EVT_MSG_SEND_RESULT");
                TSDK_S_SEND_CHAT_MSG_RESULT* send_msg_result = notification.data;
                TsdkSendChatMsgResult *msgResult = [self sendChatMsgResultToChatsendChatMsgResult:send_msg_result];
                if (msgResult.result == TSDK_SUCCESS) {
                    if (self.sendMsgBackAction) {
                        self.sendMsgBackAction(msgResult, nil);
                    }
                }
            }
                break;
            case TSDK_E_IM_EVT_MSG_WITHDRAW_RESULT:
            {
                DDLogInfo(@"TSDK_E_IM_EVT_MSG_WITHDRAW_RESULT");
                TSDK_S_CHAT_MSG_WITHDRAW_RESULT* withdraw_msg_result = notification.data;
                TsdkMsgWithDrawResult *msgResult = [self withDrawResultToWithDrawResult:withdraw_msg_result];
                [self withDrawResultActionWithResult:msgResult];
            }
                break;
            case TSDK_E_IM_EVT_MSG_WITHDRAW_IND:
            {
                DDLogInfo(@"TSDK_E_IM_EVT_MSG_WITHDRAW_IND");
                TSDK_S_CHAT_MSG_WITHDRAW_INFO* withdraw_info = notification.data;
                TsdkMsgWithDrawInfo *msgInfo = [self withDrawInfoToWithDrawInfo:withdraw_info];
                [self withDrawinfoActionWithinfo:msgInfo];
            }
            default:
                break;
        }
    }
}

- (void)withDrawinfoActionWithinfo:(TsdkMsgWithDrawInfo *)info
{
        ESpaceLocalDataManager * localManager = LOCAL_DATA_MANAGER;
        NSManagedObjectContext* bgCtx = [localManager backgroundObjectContext];
    dispatch_async(espace_coredata_management_queue, ^{
        [bgCtx performBlockAndWait:^{
        for (int i = 0; i < info.withdrawMsgCount; i++) {
            TsdkMsgBaseInfo *baseInfo = info.msgList[i];
            
            ChatMessageEntity* messageEntity = nil;
            NSPredicate* predicate = [NSPredicate predicateWithFormat:@"messageId=%lld", baseInfo.msgId];
//            messageEntity = [ESpaceLocalDataManager fetchOneObject:predicate inEnitity:@"ChatMessageEntity" inContext:bgCtx];
//
//            if (messageEntity != nil) {
//                ChatSessionEntity *session = messageEntity.to.chatSession;
//                if (session == nil) {
//                    session = messageEntity.from.chatSession;
//                }
//
//                NSSet *messages = [NSSet setWithObject:messageEntity];
//
//                [session localDeleteMessages:messages];
//            }
            
            NSArray *arr = [ESpaceLocalDataManager fetchObjects:predicate inEnitity:@"ChatMessageEntity" inContext:bgCtx];
            
            if (arr.count > 0) {
                ChatSessionEntity *session = ((ChatMessageEntity *)arr[0]).to.chatSession;
                //                        NSArray *msgArray = [NSArray arrayWithObject:messageEntity];
                
                NSSet *messages = [NSSet setWithArray:arr];
                
                [session localDeleteMessages:messages];
//                                            [session localDeleteMessages:messages completion:nil];
                
            }
            
        }
            [bgCtx processPendingChanges];
//        if ([bgCtx hasChanges]) {
//            [bgCtx save:nil];
//        }
        [bgCtx saveToPersistent];
        }];
    });
}

- (TsdkMsgWithDrawInfo *)withDrawInfoToWithDrawInfo:(TSDK_S_CHAT_MSG_WITHDRAW_INFO *)info
{
    TsdkMsgWithDrawInfo *msgInfo = [[TsdkMsgWithDrawResult alloc] init];
    msgInfo.origin = [NSString stringWithUTF8String:info->origin];
    msgInfo.target = [NSString stringWithUTF8String:info->target];
    msgInfo.withdrawMsgType = info->withdraw_msg_type;
    msgInfo.withdrawMsgCount = info->withdraw_msg_count;
//    msgInfo.unreadMsgId = info->unread_msg_id;
//    long long msgId = info->unread_msg_id;
    
    TSDK_S_MSG_BASE_INFO *msgList = info->withdraw_msg_list;
    NSMutableArray *msgListArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < info->withdraw_msg_count; i++) {
        long long msgId =  msgList[i].msg_id;
        TsdkMsgBaseInfo *msgInfo = [[TsdkMsgBaseInfo alloc] init];
        msgInfo.msgId = msgId;
        [msgListArray addObject:msgInfo];
    }
    msgInfo.msgList = [NSArray arrayWithArray:msgListArray];
    
    return msgInfo;
}

- (void)withDrawResultActionWithResult:(TsdkMsgWithDrawResult *)result
{
    if (result.result == TSDK_SUCCESS) {
        ESpaceLocalDataManager * localManager = LOCAL_DATA_MANAGER;
        NSManagedObjectContext* bgCtx = [localManager backgroundObjectContext];
        dispatch_async(espace_coredata_management_queue, ^{
            [bgCtx performBlockAndWait:^{
        for (int i = 0; i < result.withdrawMsgCount; i++) {
            TsdkMsgBaseInfo *baseInfo = result.msgList[i];
            
            ChatMessageEntity* messageEntity = nil;
            NSPredicate* predicate = [NSPredicate predicateWithFormat:@"messageId=%lld", baseInfo.msgId];
//            messageEntity = [ESpaceLocalDataManager fetchOneObject:predicate inEnitity:@"ChatMessageEntity" inContext:bgCtx];
//
//            if (messageEntity != nil) {
//                ChatSessionEntity *session = messageEntity.to.chatSession;
//
//                NSSet *messages = [NSSet setWithObject:messageEntity];
//
//                [session localDeleteMessages:messages];
//            }
            NSArray *arr = [ESpaceLocalDataManager fetchObjects:predicate inEnitity:@"ChatMessageEntity" inContext:bgCtx];
            
            if (arr.count > 0) {
                ChatSessionEntity *session = ((ChatMessageEntity *)arr[0]).to.chatSession;
                //                        NSArray *msgArray = [NSArray arrayWithObject:messageEntity];
                
                NSSet *messages = [NSSet setWithArray:arr];
                
                [session localDeleteMessages:messages];
//                                            [session localDeleteMessages:messages completion:nil];
                
            }
            
        }
                [bgCtx processPendingChanges];
//        if ([bgCtx hasChanges]) {
//            [bgCtx save:nil];
//        }
        [bgCtx saveToPersistent];
             }];
        });
    }
}

- (TsdkMsgWithDrawResult *)withDrawResultToWithDrawResult:(TSDK_S_CHAT_MSG_WITHDRAW_RESULT *)result
{
    TsdkMsgWithDrawResult *msgResult = [[TsdkMsgWithDrawResult alloc] init];
    msgResult.origin = [NSString stringWithUTF8String:result->origin];
    msgResult.target = [NSString stringWithUTF8String:result->target];
    msgResult.withdrawMsgType = result->withdraw_msg_type;
    msgResult.withdrawMsgCount = result->withdraw_msg_count;
    msgResult.timeout = result->timeout;
    msgResult.result = result->result;
    
    TSDK_S_MSG_BASE_INFO *msgList = result->withdraw_msg_list;
    NSMutableArray *msgListArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < result->withdraw_msg_count; i++) {
        long long msgId =  msgList[i].msg_id;
        TsdkMsgBaseInfo *msgInfo = [[TsdkMsgBaseInfo alloc] init];
        msgInfo.msgId = msgId;
        [msgListArray addObject:msgInfo];
    }
    msgResult.msgList = [NSArray arrayWithArray:msgListArray];
    
    return msgResult;
}

- (TsdkSendChatMsgResult *)sendChatMsgResultToChatsendChatMsgResult:(TSDK_S_SEND_CHAT_MSG_RESULT *)result
{
    TsdkSendChatMsgResult *MsgResult = [[TsdkSendChatMsgResult alloc] init];
    MsgResult.target = [NSString stringWithUTF8String:result->target];
    MsgResult.utcStamp = result->utc_stamp;
    MsgResult.clientMsgId = result->client_msg_id;
    MsgResult.serverMsgId = result->server_msg_id;
//    MsgResult.description = [NSString stringWithUTF8String:result->description];
    MsgResult.result = result->result;
    
    return MsgResult;
}

- (TsdkBatchChatMessageInfo *)batchMsgInfoToBatchChatMessage:(TSDK_S_BATCH_CHAT_MSG_INFO *)msgInfo
{
    TsdkBatchChatMessageInfo *batchMsgInfo = [[TsdkBatchChatMessageInfo alloc] init];
    batchMsgInfo.count = msgInfo->count;
    batchMsgInfo.unReadCount = msgInfo->unread_msg_count;
    batchMsgInfo.minMsgId = msgInfo->min_msg_id;
    batchMsgInfo.maxMsgId = msgInfo->max_msg_id;
    
    TSDK_S_CHAT_MSG_INFO *msgList = msgInfo->chat_msg_list;
    NSMutableArray *msgListArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < batchMsgInfo.count; i++) {
        TSDK_S_CHAT_MSG_INFO batchMsgInfo = msgList[i];
        TsdkChatMessageInfo *msgInfo = [self msgInfoToChatMessage:&batchMsgInfo];
        [msgListArray addObject:msgInfo];
    }
    
    batchMsgInfo.messageList = [NSArray arrayWithArray:msgListArray];
    
    return batchMsgInfo;
}

- (void)didReceiveBatchChatMessage:(TsdkBatchChatMessageInfo *)batchMsg
{
    DDLogInfo(@"didReceiveBatchChatMessage");
    for (int i = 0; i < batchMsg.count; i++) {
        TsdkChatMessageInfo *msgInfo = batchMsg.messageList[i];
        [self didReceiveChatMessage:msgInfo];
    }
}

- (void)didReceiveChatMessage:(TsdkChatMessageInfo *)message {
    if (message.chatType == TSDK_E_CHAT_MSG_TYPE_SINGLE_CHAT) {
        [self didReceiveSingleChatMessage:message];
    }else if (message.chatType == TSDK_E_CHAT_MSG_TYPE_FIXED_GROUP || message.chatType == TSDK_E_CHAT_MSG_TYPE_TEMP_GROUP){
        [self didReceiveGroupChatMessage:message];
    }
}

- (void)didReceiveGroupChatMessage:(TsdkChatMessageInfo *)message {
    ESpaceLocalDataManager * localManager = LOCAL_DATA_MANAGER;
    dispatch_async(espace_coredata_management_queue, ^{
        NSManagedObjectContext* bgCtx = [localManager backgroundObjectContext];
        [bgCtx performBlockAndWait:^{
            
            ContactEntity *from = nil;
            
            from = [self userWithAccount:message.account inContext:bgCtx autoCreate:YES];
            ECSGroupType groupType = ECSFixGroup;
            if (message.chatType == TSDK_E_CHAT_MSG_TYPE_TEMP_GROUP) {
                groupType = ECSChatGroup;
            }
            GroupEntity* group = [self groupWithId:message.groupId type:groupType inContext:bgCtx autoCreate:YES];
            if (group.name.length == 0) {
                group.name = message.groupName;
            }
            if (from.name.length == 0) {
                from.name = message.account;
            }
            
            ChatMessageEntity* messageEntity = nil;
            
            NSPredicate* predicate = [NSPredicate predicateWithFormat:@"messageId=%lld", message.serverMsgId];
            messageEntity = [ESpaceLocalDataManager fetchOneObject:predicate inEnitity:@"ChatMessageEntity" inContext:bgCtx];
            
            
            NSInteger groupState = [group.state integerValue];
            if ((groupState & ESpaceGroupStateMemberLoaded) != ESpaceGroupStateMemberLoaded
                && from && ![group.members containsObject:from] && [from isKindOfClass:[EmployeeEntity class]]) {
                [group addMembersObject:(EmployeeEntity *)from];
            }
            if (!messageEntity) {
                //多图文消息兼容,公众号转发消息、链接分享不进行解析
                NSArray* subContentArray = [NSArray arrayWithObject:message.content];
                //                    if (message.contentType != ESpaceShareLinkContentType
                //                        && message.contentType != ESpacePublicAccountContentType) {
                //                        subContentArray = [message.body analysisStringWithRegularExpression:@"/:um_begin(.*?)/:um_end"];;
                //                    }
                for (int i = 0 ; i < subContentArray.count ;i++) {
                    NSString* subString = [subContentArray objectAtIndex:i];
                    long long index = i;
                    NSDate* timestamp = [NSDate date];
                    if (message.utcStamp) {
                        timestamp = [NSDate dateWithTimeIntervalSince1970:((message.utcStamp + index) / 1000.0)];
                    }
                    BOOL isRead = NO;
                    if (subContentArray.count > 1 && index != subContentArray.count - 1) {
                        isRead = YES;
                    }
                    //                        if ([from isKindOfClass:[EmployeeEntity class]]) {
                    //                            //                            if ([(EmployeeEntity *)from isMe]) {
                    //                            //                                isRead = YES;
                    //                            //                            }
                    //                            if ([TUPMediator_ContactService M_EmployeeIsMe:(EmployeeEntity *)from]) {
                    //                                isRead = YES;
                    //                            }
                    //                        }
                    messageEntity = [self createMessageForSession:group.chatSession timestamp:timestamp readed:isRead];
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
                    
                    messageEntity.from = from;
                    messageEntity.messageId = [NSString stringWithFormat:@"%lld",message.serverMsgId];
                    messageEntity.readDetail = [NSNumber numberWithBool:YES];
                    subString = [subString stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"];
                    subString = [subString stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"];
                    ECSImChatMsgXmlInfo *xmlInfo = [[ECSImChatMsgXmlInfo alloc] initWithXmlUserInfo:subString];
                    if (xmlInfo.content!= nil) {
                        messageEntity.body = xmlInfo.content;
                    }else{
                        messageEntity.body = subString;
                    }
                    messageEntity.total = [NSNumber numberWithInteger:subContentArray.count];
                    [bgCtx saveToPersistent];
                }
                
            }
        }];
    });
}

- (TsdkChatMessageInfo *)msgInfoToChatMessage:(TSDK_S_CHAT_MSG_INFO *)msgInfo
{
    TsdkChatMessageInfo *message = [[TsdkChatMessageInfo alloc] init];
    message.chatType = msgInfo->chat_type;
    message.chatMediaType = msgInfo->chat_media_type;
    message.sourceType = msgInfo->source_type;
    message.account = [NSString stringWithUTF8String:msgInfo->origin];
    message.name = [NSString stringWithUTF8String:msgInfo->origin_name];
    message.target = [NSString stringWithUTF8String:msgInfo->target];
    message.groupId = [NSString stringWithUTF8String:msgInfo->group_id];
    message.content = [NSString stringWithUTF8String:msgInfo->content];
    message.clientMsgId = msgInfo->client_msg_id;
    message.serverMsgId = msgInfo->server_msg_id;
    message.groupName = [NSString stringWithUTF8String:msgInfo->group_name];
    message.groupNameEn = [NSString stringWithUTF8String:msgInfo->group_name_en];
    message.utcStamp = msgInfo->utc_stamp;
    message.serverDeliverTime = msgInfo->server_deliver_time;
    
    return message;
}

- (void)didReceiveSingleChatMessage:(TsdkChatMessageInfo *)message {
    ESpaceLocalDataManager * localManager = LOCAL_DATA_MANAGER;
    dispatch_async(espace_coredata_management_queue, ^{
        NSManagedObjectContext* bgCtx = [localManager backgroundObjectContext];
        
        [bgCtx performBlockAndWait:^{
            NSMutableArray *chatMessageList = [[NSMutableArray alloc] init];
            ContactEntity *from = nil;
            EmployeeEntity* to = [self userWithAccount:message.target inContext:bgCtx autoCreate:YES];
            if ([from.name length] == 0) {
                from.name = message.name;
            }
            ChatMessageEntity* messageEntity = nil;
            from = [self userWithAccount:message.account inContext:bgCtx autoCreate:YES];
            if (nil != message.serverMsgId) {
                NSPredicate* predicate = [NSPredicate predicateWithFormat:@"from=%@ AND messageId=%lld", from, message.serverMsgId];
                messageEntity = [ESpaceLocalDataManager fetchOneObject:predicate inEnitity:@"ChatMessageEntity" inContext:bgCtx];
            }
            BOOL isMe = NO;
            if ([(EmployeeEntity *)from isKindOfClass:[EmployeeEntity class]]) {
                EmployeeEntity* tmpEmployee = (EmployeeEntity*)from;
                isMe = ![tmpEmployee.contactId compare:LOCAL_DATA_MANAGER.userAccount options:NSLiteralSearch];;
            }
            
            ChatSessionEntity *chatSession = isMe == YES ? to.chatSession : from.chatSession;
            [self handleReceiveMessages:messageEntity
                         andChatMessage:message
                            withContext:bgCtx
                          contactEntity:chatSession.target
                                   from:from
                                     to:to
                       chatMessageArray:(NSMutableArray *)chatMessageList];
            
        }];
    });
}

- (void)handleReceiveMessages:(ChatMessageEntity *)messageEntity
               andChatMessage:(TsdkChatMessageInfo *)message
                  withContext:(NSManagedObjectContext *)bgCtx
                contactEntity:(ContactEntity *)contactEntity
                         from:(ContactEntity *)from
                           to:(EmployeeEntity *)to
             chatMessageArray:(NSMutableArray *)chatMessageList
{//TsdkChatMessage
    if (!messageEntity){
        NSArray* subContentArray = [NSArray arrayWithObject:message.content];
//        if (message.contentType != ESpaceShareLinkContentType
//            && message.contentType != ESpacePublicAccountContentType) {
//            subContentArray = [message.content analysisStringWithRegularExpression:@"/:um_begin(.*?)/:um_end"];;
//        }
        for (int i = 0 ; i < subContentArray.count ;i++) {
            NSString* subString = [subContentArray objectAtIndex:i];
            long long index = i;
            NSDate* timestamp = nil;
            if (message.serverDeliverTime) {
//                timestamp = [NSDate dateWithTimeIntervalSince1970:((message->server_deliver_time + index) / 1000.0)];
//            } else {
                timestamp = [NSDate dateWithTimeIntervalSince1970:message.serverDeliverTime/1000.0];
//                NSTimeZone *tZone = [NSTimeZone defaultTimeZone];
//                NSInteger seconds = [tZone secondsFromGMTForDate:timestamp];
//                timestamp = [NSDate dateWithTimeInterval:seconds sinceDate:timestamp];
            }

            BOOL isRead = NO;
            if (subContentArray.count > 1 && index != subContentArray.count - 1) {
                isRead = YES;
            }
            if ([from isKindOfClass:[EmployeeEntity class]]) {
                isRead = ![from.contactId compare:LOCAL_DATA_MANAGER.userAccount options:NSLiteralSearch];;
            }
            messageEntity = [self createMessageForSession:contactEntity.chatSession timestamp:timestamp readed:isRead];
            messageEntity.messageId = [NSString stringWithFormat:@"%lld",message.serverMsgId];
            messageEntity.from = from;
            messageEntity.to = to;
            messageEntity.readDetail = [NSNumber numberWithBool:isRead];
            
            subString = [subString stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"];
            subString = [subString stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"];
            ECSImChatMsgXmlInfo *xmlInfo = [[ECSImChatMsgXmlInfo alloc] initWithXmlUserInfo:subString];
            if (xmlInfo.content!= nil) {
                messageEntity.body = xmlInfo.content;
            }else{
                messageEntity.body = subString;
            }
            
//            messageEntity.title = message.title;
            messageEntity.total = [NSNumber numberWithInteger:subContentArray.count];
//            messageEntity.senderType = [NSNumber numberWithInteger:message.senderType];
//            messageEntity.appName = message.appName;
//            messageEntity.appID = message.appID;
            if (subContentArray.count >= 2) {
                messageEntity.subIndex = [NSNumber numberWithInteger:i + 1];
            }else{
                messageEntity.subIndex = [NSNumber numberWithInteger:i];
            }

//            messageEntity.contentType = [NSNumber numberWithInteger:message.contentType];

            if (messageEntity.contentType.unsignedIntegerValue != ESpaceTextContentType) {
//                [messageEntity downloadThumbnails];
            }

            
        }
        [bgCtx saveToPersistent];
//        if (nil != messageEntity.objectID) {
//            [chatMessageList addObject:messageEntity.objectID];
//        }
    }
    
}

- (ChatMessageEntity*) createMessageForSession:(SessionEntity*) session
                                     timestamp:(NSDate*) date
                                          flag:(NSInteger) flag
                                        readed:(BOOL) readed {
    if (!session) {
        return nil;
    }
    NSEntityDescription* entity = [NSEntityDescription entityForName:@"ChatMessageEntity" inManagedObjectContext:session.managedObjectContext];
    ChatMessageEntity* messageEntity = [[ChatMessageEntity alloc] initWithEntity:entity insertIntoManagedObjectContext:session.managedObjectContext];
    
    messageEntity.receiveTimestamp = date;
    messageEntity.flag = [NSNumber numberWithInteger:flag];
    messageEntity.session = session;
    messageEntity.type = @0;
    messageEntity.readed = [NSNumber numberWithBool:readed];
    if (ESpaceMessageFlagNormal == flag && [session.priority integerValue] < 0) {
        session.priority = [NSNumber numberWithInteger:0];
    }
    NSUInteger updateDbId = [[ECSAppConfig sharedInstance].currentUser.increasedDbId unsignedIntegerValue] + 1;
    messageEntity.dataBaseId = [NSNumber numberWithUnsignedInteger:updateDbId];
    [ECSAppConfig sharedInstance].currentUser.increasedDbId = [NSNumber numberWithUnsignedInteger:updateDbId];
//    //此处目的是处理从老版本db数据库升级到新版coreData版本后，最后一条记录不刷新的问题
//    if ([session isKindOfClass:[SpecialChatSessionEntity class]] && NO == [ESpaceVersionSwitchHelper sharedInstance].isUpdating) {
//        [(SpecialChatSessionEntity*)session updateLastMessage:[NSSet setWithObject:messageEntity]];
//    }
    
    return messageEntity;
}

- (ChatMessageEntity*) createMessageForSession:(SessionEntity*) session
                                     timestamp:(NSDate*) date
                                        readed:(BOOL) readed {
    return [self createMessageForSession:session timestamp:date flag:0 readed:readed];
}

- (EspaceUserOnlineStatus*) onlineStatusForUser:(NSString*) account forceSubscribe:(BOOL) bForce {
    if (account) {
        EspaceUserOnlineStatus* onlineStatus = [_subscribedUsers objectForKey:account];
        
//        BOOL isNeedForceSubscribe = NO;
//        if (bForce) {
//            //如果需要强制订阅则判断当前_bForceSubscribedUsers是否包含该用户的账号(好友和自己则不需要订阅)
//            isNeedForceSubscribe = [self isNeedForceSubscribeStatusForUser:account];
//        }
        
//        if (!onlineStatus || isNeedForceSubscribe) {
//            onlineStatus = [[EspaceUserOnlineStatus alloc] init];
//            if (self.loginStatus == ECServiceLogin && bForce) {
//                ECSAddNonFriendMember* member = [ECSAddNonFriendMember new];
//                ECSAddNonFriendMemberQuery* query = [ECSAddNonFriendMemberQuery new];
//                ECSAddNonFriendMemberQueryItem* queryItem = [ECSAddNonFriendMemberQueryItem new];
//                queryItem.jid = account;
//                queryItem.subscription = @"add";
//                query.xmlns = @"jabber:iq:presence";
//                query.list = @[queryItem];
//                member.from = [[[ECSAppConfig sharedInstance] currentUser] account];
//                member.type = @"get";
//                member.query = query;
//                [_subscribedUsers setObject:onlineStatus forKey:account];
//                [_bForceSubscribedUsers addUniqueObject:account];
//                if ([[ECSAppConfig sharedInstance].currentUser isSupportFunction:EN_FUNC_SUBSCRIBE_NON_FRIEND]) {
//                    [[ESpaceContactService sharedInstance].contactService addNonFriendMemberWithRequest:member completionBlock:^(ECSAddNonFriendMemberAck *retMsg, NSError *error) {
//                        if (error) {
//                            //订阅失败也没必要清空其状态 UC2.0 UC2.2不支持非好友状态订阅
//                            //[_subscribedUsers removeObjectForKey:account];
//                            @synchronized (_bForceSubscribedUsers) {
//                                [_bForceSubscribedUsers removeObject:account];
//                            }
//                        }
//                    }];
//                }
//            }
//        }
        return onlineStatus;
    }
    return nil;
}

/**
 是否需要向服务器发起某用户的状态订阅
 不需要订阅的情况：
 1.自己
 2.已经订阅过的账号
 3.朋友
 @param account 被订阅状态的用户
 @return 是否需要发起订阅
 */
- (BOOL)isNeedForceSubscribeStatusForUser:(NSString *)account {
    
    if (0 == account.length) {
        return NO;
    }
    
    NSString *myAccount = [ECSAppConfig sharedInstance].currentUser.account;
    if ([myAccount isEqualToString:account]) {
        return NO;
    }
    
    if ([_bForceSubscribedUsers containsObject:account]) {
        return NO;
    }
    
    NSManagedObjectContext *bgContext = LOCAL_DATA_MANAGER.backgroundObjectContext;
    EmployeeEntity *employee = [self userWithAccount:account
                                           inContext:bgContext
                                          autoCreate:NO];
    if ([employee.isFriend boolValue]) {
        return NO;
    }
    
    return YES;
}


- (EspaceUserOnlineStatus*) onlineStatusForUser:(NSString*) account {
    if (0 == [account length]) {
        return nil;
    }
    
    EspaceUserOnlineStatus* onlineStatus = [_subscribedUsers objectForKey:account];
    return onlineStatus;
}

- (void)setLoginStatus:(ECSLoginServiceStatus)loginStatus {
    if (loginStatus != _loginStatus) {
        _loginStatus = loginStatus;
        if (_loginStatus == ECServiceLogout) {
//            [[ESpaceUserSettingService sharedInstance] setUserOnlineStatusWhenLogin:ESpaceUserStatusAvailable];
        }
        if (_loginStatus == ECServiceOffline || _loginStatus == ECServiceKickOff || _loginStatus == ECServiceSigning) {
            @synchronized(_subscribedUsers) {
                [_subscribedUsers removeAllObjects];
                [_validGroupHeadImages removeAllObjects];
            }
            @synchronized (_bForceSubscribedUsers) {
                [_bForceSubscribedUsers removeAllObjects];
            }
            dispatch_async_main_safe(^{
                [[NSNotificationCenter defaultCenter] postNotificationName:ESPACE_USER_STATUS_CHANGED object:_subscribedUsers];
            });
        } else if (_loginStatus == ECServiceLogin) {
            //如果 userOnlineStatus 有值设置 无值时 直接付给 ESpaceUserStatusAvailable 保证切换网络时候 个人在线状态的保存使用
            NSString* account = LOCAL_DATA_MANAGER.userAccount;
            EspaceUserOnlineStatus* onlineStatus = [_subscribedUsers objectForKey:account];
            if (!onlineStatus) {
                onlineStatus = [[EspaceUserOnlineStatus alloc] init];
                onlineStatus.account = account;
                [_subscribedUsers setObject:onlineStatus forKey:account];
            }
            ESpaceUserStatus userStatus = ESpaceUserStatusAvailable;
            onlineStatus.userStatus = userStatus;
            [[ESpaceContactService sharedInstance] setSelfStatus:userStatus completion:^(NSError *error) {
            
            }];
            dispatch_async_main_safe(^{
                [[NSNotificationCenter defaultCenter] postNotificationName:ESPACE_USER_STATUS_CHANGED object:_subscribedUsers];
            });
        }
    }
}

- (void) hideAssistentSession {
    ESpaceLocalDataManager * localManager = LOCAL_DATA_MANAGER;
    dispatch_async(espace_coredata_management_queue, ^{
        NSManagedObjectContext* bgCtx = [localManager backgroundObjectContext];
        [bgCtx performBlockAndWait:^{
            NSArray* assientMsgs = [ESpaceLocalDataManager fetchObjects:[NSPredicate predicateWithFormat:@"readed=%@", @NO] inEnitity:@"AssistantMessageEntity" inContext:bgCtx];
            for (AssistantMessageEntity* msg in assientMsgs) {
                msg.readed = [NSNumber numberWithBool:YES];
            }
            AssistantSessionEntity* sessionEntity = [ESpaceLocalDataManager assistantSessionEntityInContext:bgCtx];
            sessionEntity.priority = [NSNumber numberWithInteger:-1];
            [bgCtx saveToPersistent];
        }];
    });
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"serviceStatus"]) {
        NSNumber* newStatus = [change objectForKey:NSKeyValueChangeNewKey];

        [self setLoginStatus:[ManagerService loginService].serviceStatus];

        if (ECServiceLogin == [newStatus integerValue]) {
            if ([[LOCAL_DATA_MANAGER userAccount] length] > 0) {
                
                [self syncContacts:^(NSError *error) {
                    if (error) {
//                        SDK_ERROR_LOG("syncContacts complete: error:"<<error.description.UTF8String);
                    }
                }];
            }
        }
    }
}




//- (AssistantMessageEntity*) createAssistantMessageWithId:(NSString*) msgId timestamp:(NSDate*)timestamp readed:(BOOL)readed inContext:(NSManagedObjectContext*) ctx {
//    AssistantSessionEntity* assistantSession = [ESpaceLocalDataManager assistantSessionEntityInContext:ctx];
//    NSEntityDescription* assistantDesc = [NSEntityDescription entityForName:@"AssistantMessageEntity" inManagedObjectContext:ctx];
//    AssistantMessageEntity* message = [[AssistantMessageEntity alloc] initWithEntity:assistantDesc insertIntoManagedObjectContext:ctx];
//    message.receiveTimestamp = timestamp;
//    message.session = assistantSession;
//    message.readed = [NSNumber numberWithBool:readed];
//    message.messageId = msgId;
//    return message;
//}

- (ChatSessionEntity *)createChatSessionForContact:(ContactEntity *)contact {
    ChatSessionEntity* chatSession = contact.chatSession;
    if (contact && (!chatSession || chatSession.isDeleted)) {
        NSEntityDescription* chatSessionEntity = [NSEntityDescription entityForName:@"ChatSessionEntity" inManagedObjectContext:contact.managedObjectContext];
        chatSession = [[ChatSessionEntity alloc] initWithEntity:chatSessionEntity insertIntoManagedObjectContext:contact.managedObjectContext];
        chatSession.parent = (NSManagedObject*)[ESpaceLocalDataManager rootChatSessionGroupInContext:contact.managedObjectContext];
        chatSession.priority = [NSNumber numberWithInt:-1];
        contact.chatSession = chatSession;
    }
    return chatSession;
}

- (MsgLogSessionEntity *)creatMsgLogSessionForContact:(ContactEntity *)contact {
    NSManagedObjectID *contactObjectID = [contact objectID];
    NSManagedObjectContext *mainCtx = [LOCAL_DATA_MANAGER managedObjectContext];

    [mainCtx performBlockAndWait:^{
        ContactEntity *newContact = [mainCtx objectWithID:contactObjectID];
        MsgLogSessionEntity *msgLogSession = newContact.msgLogSession;
        if (msgLogSession) {
            msgLogSession.target = nil;
            [msgLogSession localDeleteSelf];
        }

        NSEntityDescription* LogEntity = [NSEntityDescription entityForName:@"MsgLogSessionEntity"
                                                     inManagedObjectContext:mainCtx];
        MsgLogSessionEntity *logSession = [[MsgLogSessionEntity alloc] initWithEntity:LogEntity
                                                       insertIntoManagedObjectContext:mainCtx];
        newContact.msgLogSession = logSession;
    }];

    return contact.msgLogSession;
}

- (CallSessionEntity*)createCallSessionForContact:(ContactEntity*) contact {
    CallSessionEntity* callSession = contact.callSession;
    if (contact && !callSession) {
        NSEntityDescription* callSessionEntity = [NSEntityDescription entityForName:@"CallSessionEntity" inManagedObjectContext:contact.managedObjectContext];
        callSession = [[CallSessionEntity alloc] initWithEntity:callSessionEntity insertIntoManagedObjectContext:contact.managedObjectContext];
        callSession.parent = (NSManagedObject*)[ESpaceLocalDataManager rootCallSessionGroupInContext:contact.managedObjectContext];
        callSession.priority = [NSNumber numberWithInt:-1];
        contact.callSession = callSession;
    }
    return callSession;
}

- (GroupEntity*) groupWithId:(NSString*) _id
                        type:(NSInteger) type
                   inContext:(NSManagedObjectContext*)context
                  autoCreate:(BOOL) bAutoCreate {
    if (!_id || !context){
//        SDK_DEBUG_LOG("id or context is nil.");
        return nil;
    }

    __block GroupEntity* group = nil;

    group = [self groupWithId:_id inContext:context];
    if (!group && bAutoCreate) {
        [context performBlockAndWait:^{
            NSEntityDescription* groupEntity = [NSEntityDescription entityForName:@"GroupEntity" inManagedObjectContext:context];
            NSEntityDescription* folderEntity = [NSEntityDescription entityForName:@"GroupFileEntity" inManagedObjectContext:context];
            GroupFileEntity * rootFolder = [[GroupFileEntity alloc] initWithEntity:folderEntity insertIntoManagedObjectContext:context];
            rootFolder.type = [NSNumber numberWithUnsignedInteger:ESpaceGPFolderType];
            rootFolder.id = @"0";
            rootFolder.createAt = [NSDate date];
            group = [[GroupEntity alloc] initWithEntity:groupEntity insertIntoManagedObjectContext:context];
            group.contactId = _id;
            group.groupType = [NSNumber numberWithInteger:type];
            group.classType = [NSNumber numberWithInteger:ContactGroupType];
//            group.msgRecvOpt = [NSNumber numberWithInteger:ECSMarkGroupReceiveUnmute];
            group.rootFolder = rootFolder;
            NSPredicate* groupAssistentPredicate = [NSPredicate predicateWithFormat:@"type=%@ AND body CONTAINS %@", [NSNumber numberWithInteger:ESpaceAssistantGroupInvite], _id];
            AssistantMessageEntity * groupAssistentMsg = [ESpaceLocalDataManager fetchOneObject:groupAssistentPredicate inEnitity:@"AssistantMessageEntity" inContext:context];
            if (groupAssistentMsg.managedObjectContext && !groupAssistentMsg.deleted) {
                groupAssistentMsg.action = [NSNumber numberWithInteger:ESpaceAssistantAccept];
            }
            [self createChatSessionForContact:group];
        }];
    }
    return group;
}

//- (CustomContactEntity*) createCustomContactEntityInContext:(NSManagedObjectContext*)context {
//    if (!context) {
//        SDK_DEBUG_LOG("context is nil.");
//        return nil;
//    }
//    NSEntityDescription* userEntity = [NSEntityDescription entityForName:@"CustomContactEntity" inManagedObjectContext:context];
//    CustomContactEntity* user = [[CustomContactEntity alloc] initWithEntity:userEntity insertIntoManagedObjectContext:context];
//    user.classType = [NSNumber numberWithInteger:ContactUserType];
//    return user;
//}

- (EmployeeEntity*) userWithAccount:(NSString*) userAccount
                          inContext:(NSManagedObjectContext*)context
                         autoCreate:(BOOL) bAutoCreate {
    if (!userAccount || !context){
//        SDK_DEBUG_LOG("user account length is zero, or context is nil.");
        return nil;
    }
    
    __block EmployeeEntity* user = [self userWithAccount:userAccount inContext:context];
    if (!user && bAutoCreate) {
        [context performBlockAndWait:^{
            NSEntityDescription* userEntity = [NSEntityDescription entityForName:@"EmployeeEntity" inManagedObjectContext:context];
            user = [[EmployeeEntity alloc] initWithEntity:userEntity insertIntoManagedObjectContext:context];
            user.account = userAccount;
            user.contactId = userAccount;
            user.classType = [NSNumber numberWithInteger:ContactUserType];
            [self createChatSessionForContact:user];
            [self createCallSessionForContact:user];
        }];
    }
    return user;
}

- (CustomContactEntity*) customUserWithId:(NSString*)userId
                                inContext:(NSManagedObjectContext*)context
                                autoCreat:(BOOL)bAutoCreate {
    if (0 == [userId length] || nil == context) {
//        SDK_DEBUG_LOG("userId length is zero, or context is nil.");
        return nil;
    }
    
    __block CustomContactEntity* customUser = [self customUserWithId:userId inContext:context];
    if (nil == customUser && bAutoCreate) {
        [context performBlockAndWait:^{
            NSEntityDescription* userEntity = [NSEntityDescription entityForName:@"CustomContactEntity" inManagedObjectContext:context];
            customUser = [[CustomContactEntity alloc] initWithEntity:userEntity insertIntoManagedObjectContext:context];
            customUser.contactId = userId;
        }];
    }
    
    return customUser;
}

- (CallContactEntity*) callContactWithPhoneNumber:(NSString*)phoneNumber
                                        inContext:(NSManagedObjectContext*)context
                                       autoCreate:(BOOL) bAutoCreate {
    if (!phoneNumber || !context){
//        SDK_DEBUG_LOG("phoneNumber length is zero, or context is nil.");
        return nil;
    }
    
    __block CallContactEntity* callEntity = [self callContactWithPhoneNumber:phoneNumber inContext:context];
    if (!callEntity && bAutoCreate) {
        [context performBlockAndWait:^{
            NSEntityDescription* callEntityDesc = [NSEntityDescription entityForName:@"CallContactEntity" inManagedObjectContext:context];
            callEntity = [[CallContactEntity alloc] initWithEntity:callEntityDesc insertIntoManagedObjectContext:context];
            callEntity.phoneNumber = phoneNumber;
            callEntity.contactId =  [NSString stringWithFormat:@"%@%@",ESPACE_CALLCONTACT_IDPREFIX,phoneNumber];
        }];
    }
    return callEntity;
}

- (ThirdPartSysEntity*) systemInfoWithAppID:(NSString *)appID
                                   inContex:(NSManagedObjectContext *)context
                                  autoCreat:(BOOL)bAutoCreate{
    if (!appID || !context) {
//        SDK_DEBUG_LOG("appName is nil or context is nil");
        return nil;
    }
    __block ThirdPartSysEntity *sysInfoEntity = [self systemInfoWithAppID:appID inContext:context];
    if (!sysInfoEntity && bAutoCreate) {
        [context performBlockAndWait:^{
            NSEntityDescription *sysInfoEntityDesc = [NSEntityDescription entityForName:@"ThirdPartSysEntity" inManagedObjectContext:context];
            sysInfoEntity = [[ThirdPartSysEntity alloc] initWithEntity:sysInfoEntityDesc insertIntoManagedObjectContext:context];
            sysInfoEntity.appID = appID;
            [self createChatSessionForContact:sysInfoEntity];
        }];
    }
    return sysInfoEntity;
}

- (GroupEntity*) groupWithId:(NSString*) _id inContext:(NSManagedObjectContext *)context {
    if (!_id || !context){
//        SDK_DEBUG_LOG("group id length is zero, or context is nil.");
        return nil;
    }
    
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"contactId=[cd]%@", _id];
    return [ESpaceLocalDataManager fetchOneObject:predicate inEnitity:@"GroupEntity" inContext:context];
}

- (EmployeeEntity*) userWithAccount:(NSString*) userAccount inContext:(NSManagedObjectContext*) context {
    if (!userAccount || ! context){
//        SDK_DEBUG_LOG("user account length is zero, or context is nil.");
        return nil;
    }
    
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"account=%@", userAccount];
    return [ESpaceLocalDataManager fetchOneObject:predicate inEnitity:@"EmployeeEntity" inContext:context];
}

- (EmployeeEntity*) userWithContactId:(NSString*) userId inContext:(NSManagedObjectContext*) context {
    if (!userId || ! context){
//        SDK_DEBUG_LOG("userId length is zero, or context is nil.");
        return nil;
    }
    
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"personId=%@", userId];
    return [ESpaceLocalDataManager fetchOneObject:predicate inEnitity:@"EmployeeEntity" inContext:context];
}

- (CustomContactEntity*)customUserWithId:(NSString*)userId inContext:(NSManagedObjectContext*) context {
    if (0 == [userId length] || nil == context) {
//        SDK_DEBUG_LOG("userId length is zero, or context is nil.");
        return nil;
    }
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"personId=%@", userId];
    CustomContactEntity* test = [ESpaceLocalDataManager fetchOneObject:predicate inEnitity:@"CustomContactEntity" inContext:context];
    return test;
}

- (CallContactEntity*) callContactWithPhoneNumber:(NSString*) phoneNumber inContext:(NSManagedObjectContext*) context {
    if (!phoneNumber || !context){
//        SDK_DEBUG_LOG("phone number length is zero, or context is nil.");
        return nil;
    }
    
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"phoneNumber=%@", [ECSUtils databaseDataEncrypt:phoneNumber]];
    return [ESpaceLocalDataManager fetchOneObject:predicate inEnitity:@"CallContactEntity" inContext:context];
}

- (ThirdPartSysEntity *)systemInfoWithAppID:(NSString *)appID inContext:(NSManagedObjectContext *)context{
    if (!appID || !context) {
//        SDK_DEBUG_LOG("appName is nil or context is nil");
        return nil;
    }
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"appID=%@", appID];
    ThirdPartSysEntity *entity = [ESpaceLocalDataManager fetchOneObject:predicate inEnitity:@"ThirdPartSysEntity" inContext:context];
    return entity;
}
#pragma mark- 联系人同步
//- (void)handleGroupAnnounceChange:(NSString *)newAnnounce
//                      oldAnnounce:(NSString *)oldAnnounce
//                            group:(GroupEntity *)groupEntity {
//    if (nil == groupEntity || 0 == [newAnnounce length] || [newAnnounce isEqualToString:oldAnnounce]) {
//        return;
//    }
//
//    //增加提示语
//    ChatMessageEntity* tipMsg = [TUPMediator_IMService M_createMessageForSession:groupEntity.chatSession timestamp:[NSDate date] flag:ESpaceMessageFlagGroupAnnounceChanged readed:YES];
//    tipMsg.from = [[ESpaceContactService sharedInstance] userWithAccount:[LOCAL_DATA_MANAGER userAccount] inContext:groupEntity.managedObjectContext autoCreate:YES];
//    tipMsg.to = groupEntity;
//    tipMsg.body = newAnnounce;
//}
//

//- (void)partialSyncContacts:(TSDK_S_CONTACT_AND_CHAT_GROUPS_INFO)contactInfo
//{
//    NSDate* now = [NSDate date];
//    ESpaceLocalDataManager * localManager = LOCAL_DATA_MANAGER;
//    dispatch_async(espace_coredata_management_queue, ^{
//        NSManagedObjectContext* bgCtx = [localManager backgroundObjectContext];
//        [bgCtx performBlockAndWait:^{
//            EmployeeEntity *bgUser = [self userWithAccount:localManager.userAccount inContext:bgCtx];
//            //分组
//            for (ECSPartialSyncAckGroup* category in retMsg.groups) {
//                if (category.opt == OPT_DELETE) {
//                    EmployeeCategoryEntity* employeeCategory = [self employeeCategoryWithId:category.id inContext:bgCtx autoCreate:NO];
//                    if (employeeCategory && !employeeCategory.deleted) {
//                        [bgCtx deleteObject:employeeCategory];
//                    }
//                } else {
//                    EmployeeCategoryEntity* employeeCategory = [self employeeCategoryWithId:category.id inContext:bgCtx autoCreate:YES];
//                    employeeCategory.idx = [NSNumber numberWithInteger:category.idx];
//                    employeeCategory.name = category.name;
//                    employeeCategory.lastUpdateTime = now;
//                }
//            }
//
//            //联系人变更,新增联系人时，groupId为空
//            for (ECSPartialSyncAckUser* user in retMsg.users) {
//                if (user.opt == OPT_DELETE) {
//                    //删除时信息可能只有id，其他字段均为空
//                    PersonEntity* person = [self userWithContactId:user.id inContext:bgCtx];
//                    if (nil == person) {
//                        person = [self customUserWithId:user.id inContext:bgCtx];
//                    }
//                    if (person && !person.deleted) {
//                        person.isFriend = @NO;
//                    }
//                } else {
//                    if ([user.account length] == 0) {
//                        if (user.opt == OPT_INSERT) {
//                            CustomContactEntity* customContact = [self customUserWithId:user.id inContext:bgCtx autoCreat:YES];
//                            [self fillPersonInfo:customContact withAck:user];
//                            customContact.infoUpdateTime = now;
//                        }
//                    } else {
//                        EmployeeEntity* userEntity = [self userWithAccount:user.account inContext:bgCtx autoCreate:YES];
//                        NSPredicate* assitentPredicate = [NSPredicate predicateWithFormat:@"type=%@ AND from = %@", [NSNumber numberWithInteger:ESpaceAssistantAddedFriend], userEntity];
//                        AssistantMessageEntity* assistentMsg = [ESpaceLocalDataManager fetchOneObject:assitentPredicate inEnitity:@"AssistantMessageEntity" inContext:bgCtx];
//                        if (assistentMsg.managedObjectContext && !assistentMsg.deleted) {
//                            assistentMsg.action = [NSNumber numberWithInteger:ESpaceAssistantAccept];
//                        }
//                        [self fillEmployeeInfo:userEntity withAck:user];
//                        userEntity.infoUpdateTime = now;
//                    }
//                }
//            }
//
//            //分组成员变更
//            for (ECSPartialSyncAckRelation* relation in retMsg.relations) {
//                EmployeeCategoryEntity* category = [self employeeCategoryWithId:relation.tid inContext:bgCtx autoCreate:NO];
//                PersonEntity* person = [self userWithContactId:relation.mid inContext:bgCtx];
//                if (nil == person) {
//                    person = [self customUserWithId:relation.mid inContext:bgCtx];
//                }
//                if (nil == person || nil == category) {
//                    continue;
//                }
//                switch (relation.opt) {
//                    case OPT_INSERT:{
//                        [person addCategoryObject:category];
//                        break;
//                    }
//                    case OPT_UPDATE:
//                        break;
//                    case OPT_DELETE:
//                        [person removeCategoryObject:category];
//                        break;
//                    default:
//                        break;
//                }
//            }
//
//            NSMutableArray *removedGroups = [NSMutableArray new];
//            NSMutableArray *addGroups = [NSMutableArray new];
//            NSMutableArray *updateGroups = [NSMutableArray new];
//
//            for (ECSPartialSyncAckTeam* group in retMsg.grplist) {
//                if (group.opt == OPT_DELETE) {
//                    GroupEntity* groupEntity = [self groupWithId:group.id type:group.groupType inContext:bgCtx autoCreate:NO];
//                    if (groupEntity && !groupEntity.deleted) {
//                        NSMutableDictionary *tempDir = [NSMutableDictionary new];
//                        GroupInfo *groupInfo = [[GroupInfo alloc] init];
//                        [groupEntity fillGroupInfo:groupInfo needGroupMember:NO];
//                        [groupInfo addValueForDir:tempDir];
//                        [removedGroups addObject:tempDir];
//                    }
//                    if (groupEntity
//                        && !groupEntity.deleted
//                        && ([groupEntity.state integerValue] == ESpaceGroupStateExist
//                            || [groupEntity.state integerValue] == ESpaceGroupStateMemberLoaded)) {
//                            if ([groupEntity.chatSession.priority integerValue] >= 0) {
//                                groupEntity.state = [NSNumber numberWithInteger:ESpaceGroupStateDismissed];
//                                //增加提示语
//                                ChatMessageEntity* tipMsg = [TUPMediator_IMService M_createMessageForSession:groupEntity.chatSession timestamp:[NSDate date] flag:ESpaceMessageFlagGroupMemberChanged readed:YES];
//                                tipMsg.from = [[ESpaceContactService sharedInstance] userWithAccount:[LOCAL_DATA_MANAGER userAccount] inContext:bgCtx autoCreate:YES];
//                                tipMsg.to = groupEntity;
//                                tipMsg.receiveTimestamp = [NSDate date];
//                                tipMsg.body = ECSLocalizedString(@"group_dismiss_unknown", @"您已离开该群组或该群组已被解散。");
//                            } else {
//                                [groupEntity localDeleteSelf];
//                            }
//                        }
//                } else {
//                    GroupEntity* groupEntity = [self groupWithId:group.id type:group.groupType inContext:bgCtx autoCreate:YES];
//                    NSString* oldAnnounce = groupEntity.announce;
//                    [self fillGroupInfo:groupEntity withAck:group];
//                    groupEntity.infoUpdateTime = now;
//                    groupEntity.itemLocalStatus = ItemNotLoaded;
//                    //                            [groupEntity reloadHeadImage:YES];
//                    if (![bgUser.memberOf containsObject:groupEntity]) {
//                        [bgUser addMemberOfObject:groupEntity];
//                    }
//                    if (OPT_INSERT == group.opt) {
//                        NSMutableDictionary *tempDir = [NSMutableDictionary new];
//                        GroupInfo *groupInfo = [[GroupInfo alloc] init];
//                        [groupEntity fillGroupInfo:groupInfo needGroupMember:NO];
//                        [groupInfo addValueForDir:tempDir];
//                        [addGroups addObject:tempDir];
//                    }else if (OPT_UPDATE == group.opt){
//                        NSMutableDictionary *tempDir = [NSMutableDictionary new];
//                        GroupInfo *groupInfo = [[GroupInfo alloc] init];
//
//                        if ([ECSAppConfig sharedInstance].functionConfig.supportGroupAnnounceChangedNotify) {
//                            [self handleGroupAnnounceChange:group.announce oldAnnounce:oldAnnounce group:groupEntity];
//                        }
//
//                        [groupEntity fillGroupInfo:groupInfo needGroupMember:NO];
//                        [groupInfo addValueForDir:tempDir];
//                        [updateGroups addObject:tempDir];
//                    }
//
//                    //在收到固定群邀请后，点击同意，增加在最近对话界面的消息入口，提升用户体验
//                    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"messageId=%@ AND type=%@ AND action=%@", groupEntity.contactId,[NSNumber numberWithInteger:ESpaceAssistantGroupInvite], @(ESpaceAssistantUndetermined)];
//                    AssistantMessageEntity* assistantMsg = [ESpaceLocalDataManager fetchOneObject:predicate inEnitity:@"AssistantMessageEntity" inContext:bgCtx];
//                    if (assistantMsg) {
//                        [groupEntity.chatSession setPriority:[NSNumber numberWithInteger:0]];
//                        groupEntity.chatSession.timestamp = [NSDate date];
//                        assistantMsg.action = [NSNumber numberWithInteger:ESpaceAssistantAccept];
//                        if (NO == [assistantMsg.readed boolValue]) {
//                            assistantMsg.readed = [NSNumber numberWithBool:YES];
//                        }
//                    }
//                }
//            }
//
//            //removed notify
//            if (removedGroups.count > 0) {
//                [self postNotification:ECSGroupRemovedNofity with:removedGroups];
//            }
//            //added notify
//            if (addGroups.count > 0) {
//                [self postNotification:ECSGroupAddedNotify with:addGroups];
//            }
//            //updated notify
//            if (updateGroups.count > 0) {
//                [self postNotification:ECSGroupUpdatedNotify with:updateGroups];
//            }
//
//            [bgCtx saveToPersistent];
//            ECSUserConfig* userConfig = [[ECSAppConfig sharedInstance] currentUser];
//            userConfig.lastConfigSyncTimestamp = now;
//            userConfig.serverSyncContactTimestamp = retMsg.timestamp;
//
//
//            if (completionBlock) {
//                completionBlock(error);
//            }
//        }];
//    });
//
//}

- (void)DealSyncContact:(TSDK_S_CONTACT_AND_CHAT_GROUPS_INFO)contactInfo
{
    NSDate* now = [NSDate date];
    ESpaceLocalDataManager * localManager = LOCAL_DATA_MANAGER;
    dispatch_async(espace_coredata_management_queue, ^{
        NSManagedObjectContext* bgCtx = [localManager backgroundObjectContext];
        [bgCtx performBlockAndWait:^{
//            TSDK_S_IM_USER_STATUS_DETECT_PARAM detect_param;
//            memset(&detect_param, 0, sizeof(TSDK_S_IM_USER_STATUS_DETECT_PARAM));
//            detect_param.account_count = 1;
//            TSDK_S_IM_USER_BASE_INFO account_list;
//            memset(&account_list, 0, sizeof(TSDK_S_IM_USER_BASE_INFO));
//            strcpy(((&account_list)[0]).staff_account, [@"ios180" UTF8String]);
//
//            detect_param.account_list = &account_list;
//
//            tsdk_detect_user_status(&detect_param);
            
            EmployeeEntity *bgUser = [self userWithAccount:localManager.userAccount inContext:bgCtx];
            NSMutableArray *userArray = [[NSMutableArray alloc] init];
            NSMutableArray *selfDefContactArray = [[NSMutableArray alloc] init];
            
            
            //第二步：处理联系人.联系人不能直接删除，否则会删除聊天记录，此处只需先将eSpace联系人置为非好友即可
            if (contactInfo.friend_count > 0 || contactInfo.self_def_contact_count > 0) {
                NSArray* allContact = [ESpaceLocalDataManager fetchObjects:nil inEnitity:@"PersonEntity" inContext:bgCtx];
                for (PersonEntity* contact in allContact) {
                    contact.isFriend = @NO;
                    contact.category = nil;
                }
                
                TSDK_S_IM_USER_INFO *friendList = contactInfo.friend_list;
                for (int i = 0; i < contactInfo.friend_count; i++) {
                    TSDK_S_IM_USER_INFO userInfo = friendList[i];
                    EmployeeEntity* userEntity = [self userWithAccount:[NSString stringWithUTF8String:userInfo.staff_account] inContext:bgCtx autoCreate:YES];
                    [self fillEmployeeInfo:userEntity withAck:userInfo];
                    userEntity.isFriend = [NSNumber numberWithBool:YES];
                    userEntity.infoUpdateTime = now;
                    [userArray addObject:userEntity];
                }
                
                TSDK_S_SELF_DEF_CONTACT_INFO *selfDefContactList = contactInfo.self_def_contact_list;
                for (int i = 0; i < contactInfo.self_def_contact_count; i++) {
                    TSDK_S_SELF_DEF_CONTACT_INFO contactInfo = selfDefContactList[i];
                    CustomContactEntity* customContact = [self customUserWithId:[NSString stringWithFormat:@"%lld",contactInfo.contact_id] inContext:bgCtx autoCreat:YES];
                    [self fillPersonInfo:customContact withSelfDefContactInfo:contactInfo];
                    customContact.isFriend = [NSNumber numberWithBool:YES];
                    [selfDefContactArray addObject:customContact];
                }
            }
            
            //此处需分三步走：1分组；2联系人（包括eSpace联系人和自定义联系人）；3群组
            //第一步:处理分组
            if (contactInfo.contact_group_count > 0) {
                NSArray* clearCategorys = [ESpaceLocalDataManager fetchObjects:nil inEnitity:@"EmployeeCategoryEntity" inContext:bgCtx];
                for (EmployeeCategoryEntity* category in clearCategorys) {
                    [bgCtx deleteObject:category];
                }
                TSDK_S_CONTACT_GROUP_BASE_INFO *groupList = contactInfo.contact_group_base_info_list;
                TSDK_S_CONTACT_GROUP_DETAIL_INFO *contact_group_detail_info_list = contactInfo.contact_group_detail_info_list;
                
                for (int i = 0; i < contactInfo.contact_group_count; i++) {
                    TSDK_S_CONTACT_GROUP_BASE_INFO baseInfo = groupList[i];
                    TSDK_S_CONTACT_GROUP_DETAIL_INFO detailInfo = contact_group_detail_info_list[i];
                    
                    EmployeeCategoryEntity* employeeCategory = [self employeeCategoryWithId:[NSString stringWithFormat:@"%lld",baseInfo.group_id] inContext:bgCtx autoCreate:YES];
                    employeeCategory.idx = [NSNumber numberWithInteger:baseInfo.index];
                    employeeCategory.name = [NSString stringWithUTF8String:baseInfo.group_name];
                    employeeCategory.num = [NSNumber numberWithInteger:detailInfo.friend_count + detailInfo.self_def_contact_count];
                    employeeCategory.lastUpdateTime = now;
                    employeeCategory.id = [NSString stringWithFormat:@"%lld",baseInfo.group_id];
                    
                    
                    TSDK_S_IM_USER_INFO *friend_list = detailInfo.friend_list;
                    for (int i = 0; i < detailInfo.friend_count; i++) {
                        TSDK_S_IM_USER_INFO userInfo = friend_list[i];
                        //                        EmployeeEntity* userEntity = [self userWithAccount:[NSString stringWithUTF8String:userInfo.staff_account] inContext:bgCtx autoCreate:YES];
                        //                        userEntity.groupId = [NSString stringWithFormat:@"%lld",baseInfo.group_id];
                        
                        for (EmployeeEntity *entity in userArray) {
                            if ([entity.account isEqualToString:[NSString stringWithUTF8String:userInfo.staff_account]]) {
                                [employeeCategory addMembersObject:entity];
                            }
                        }
                        
                        
                    }
                    TSDK_S_SELF_DEF_CONTACT_INFO *self_def_contact_list = detailInfo.self_def_contact_list;
                    for (int i = 0; i < detailInfo.self_def_contact_count; i++) {
                        TSDK_S_SELF_DEF_CONTACT_INFO contactInfo = self_def_contact_list[i];
                        //                        CustomContactEntity* customContact = [self customUserWithId:[NSString stringWithFormat:@"%lld",contactInfo.contact_id] inContext:bgCtx autoCreat:YES];
                        //                        customContact.groupId = [NSString stringWithFormat:@"%lld",baseInfo.group_id];
                        for (CustomContactEntity *entity in selfDefContactArray) {
                            if ([entity.contactId isEqualToString:[NSString stringWithFormat:@"%lld",contactInfo.contact_id]]) {
                                [employeeCategory addMembersObject:entity];
                            }
                        }
                    }
                }
            }
            
            //第三步：处理群组
            if(contactInfo.chat_group_count > 0)
            {
                NSMutableArray *addGroups = [NSMutableArray new];
                NSArray* localGroups = [ESpaceLocalDataManager fetchObjects:nil inEnitity:@"GroupEntity" inContext:bgCtx];
                for (GroupEntity* group in localGroups) {
                    group.state = [NSNumber numberWithInteger:ESpaceGroupStateDisappearedUnKnow];
                }
                
                TSDK_S_CHAT_GROUP_INFO *chatGroupBaseInfoList = contactInfo.chat_group_info_list;
                int count = 0;     //用于分片通知的计数
                for (int i = 0; i < contactInfo.chat_group_count; i++) {
                    TSDK_S_CHAT_GROUP_INFO chatGroupBaseInfo = chatGroupBaseInfoList[i];
                    GroupEntity* groupEntity = [self groupWithId:[NSString stringWithUTF8String:chatGroupBaseInfo.group_id] type:chatGroupBaseInfo.group_type inContext:bgCtx autoCreate:YES];
                    [self fillGroupInfo:groupEntity withAck:chatGroupBaseInfo];
                    groupEntity.state = [NSNumber numberWithInteger:ESpaceGroupStateExist];
                    groupEntity.itemLocalStatus = ItemNotLoaded;
                    groupEntity.infoUpdateTime = now;
                    if (![bgUser.memberOf containsObject:groupEntity]) {
                        [bgUser addMemberOfObject:groupEntity];
                    }
                    if (count == 30) {
                        [self postNotification:ECSGroupAddedNotify with:addGroups];
                        count = 0;
                        [addGroups removeAllObjects];
                    }else{
                        count ++;
                        NSMutableDictionary *tempDir = [NSMutableDictionary new];
                        GroupInfo *groupInfo = [[GroupInfo alloc] init];
                        [groupEntity fillGroupInfo:groupInfo needGroupMember:NO];
                        [groupInfo addValueForDir:tempDir];
                        [addGroups addObject:tempDir];
                    }
                }
                
                if (addGroups.count > 0) {
                    [self postNotification:ECSGroupAddedNotify with:addGroups];
                }
            }
            
            
            [bgCtx saveToPersistentAndWait];
            
            
            
            ECSUserConfig* userConfig = [[ECSAppConfig sharedInstance] currentUser];
            userConfig.lastConfigSyncTimestamp = now;
            userConfig.serverSyncContactTimestamp = [NSString stringWithUTF8String:contactInfo.timestamp];
            [[ECSAppConfig sharedInstance] save];
            
        }];
    });
}

- (void) needFullSyncContacts:(BOOL)needFull completionBkock:(void (^)(NSError* error)) completionBlock {
    TSDK_S_CONTACT_AND_CHAT_GROUPS_INFO contactInfo;
    memset(&contactInfo, 0, sizeof(TSDK_S_CONTACT_AND_CHAT_GROUPS_INFO));
    
    TSDK_S_GET_CONTACT_AND_CHAT_GROUPS_REQ_PARAM contactReqParam;
    memset(&contactReqParam, 0, sizeof(TSDK_S_GET_CONTACT_AND_CHAT_GROUPS_REQ_PARAM));
    if (needFull) {
        contactReqParam.is_sync_all = TSDK_TRUE;
    }else{
        contactReqParam.is_sync_all = TSDK_FALSE;
        NSDate * lastConfigSyncTime = [[ECSAppConfig sharedInstance] currentUser].lastConfigSyncTimestamp;
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];//19000000000000
        NSString *strDate = [dateFormatter stringFromDate:lastConfigSyncTime];
        strcpy(contactReqParam.timestamp, [strDate UTF8String]);
    }
    
    
    TSDK_RESULT resutl = tsdk_get_contact_and_chat_groups(&contactReqParam, &contactInfo);
    
    if (resutl == TSDK_SUCCESS || needFull) {
        [self DealSyncContact:contactInfo];
    }
}

- (BOOL) needFullSyncContacts {
    NSDate * lastConfigSyncTime = [[ECSAppConfig sharedInstance] currentUser].lastConfigSyncTimestamp;
    if (!lastConfigSyncTime) {
        lastConfigSyncTime = [NSDate dateWithTimeIntervalSince1970:0];
    }
    if (ABS([lastConfigSyncTime timeIntervalSinceNow]) >  ONE_DAY * 30) {
        return YES;
    }
    return NO;
}

- (void) syncContacts:(void (^)(NSError* error)) completionBlock {
//    if ([self needFullSyncContacts]) {
        [self needFullSyncContacts:YES completionBkock:completionBlock];
//    }else{
//        [self needFullSyncContacts:NO completionBkock:completionBlock];
//    }

    
//    else if ([[ECSAppConfig sharedInstance] currentUser].maaInfo.isupdate == ECS_CONTACT_SYNC_PART) {
//        [self partialSyncContacts:completionBlock];
//    } else {
//        if (completionBlock) {
//            completionBlock(nil);
//        }
//    }
}

#pragma mark-联系人同步end
//- (void) createGroupWithName:(NSString*) groupName
//                   groupType:(ECSGroupType) groupType
//               joinCondition:(ECSGroupJoinType) joinCondition
//                   initUsers:(NSArray *) users
//                    announce:(NSString*) announce
//                       intro:(NSString*) intro
//                  completion:(void (^)(NSString* groupId, NSString* failedList, NSError* error)) completionBlock{
//    [self createGroupWithName:groupName enName:@"" groupType:groupType joinCondition:joinCondition initUsers:users announce:announce intro:intro completion:completionBlock];
//}
//
//
//- (void) createGroupWithName:(NSString*) groupName
//                   groupType:(ECSGroupType) groupType
//               joinCondition:(ECSGroupJoinType) joinCondition
//             userAccountList:(NSArray *) userAccounts
//                    announce:(NSString*) announce
//                       intro:(NSString*) intro
//                  completion:(void (^)(NSString* groupId, NSString* failedList, NSError* error)) completionBlock{
//    [self createGroupWithName:groupName enName:@"" groupType:groupType joinCondition:joinCondition userAccountList:userAccounts announce:announce intro:intro completion:completionBlock];
//}
//
//- (void) createGroupWithName:(NSString*) groupName
//                      enName:(NSString*) enName
//                   groupType:(ECSGroupType) groupType
//               joinCondition:(ECSGroupJoinType) joinCondition
//                   initUsers:(NSArray *) users
//                    announce:(NSString*) announce
//                       intro:(NSString*) intro
//                  completion:(void (^)(NSString* groupId, NSString* failedList, NSError* error)) completionBlock {
//    
//    NSMutableArray* userAccounts = [NSMutableArray array];
//    [users enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//        EmployeeEntity* user = obj;
//        [userAccounts addObject:user.account];
//    }];
//    
//    [self createGroupWithName:groupName
//                       enName:enName
//                    groupType:groupType
//                joinCondition:joinCondition
//              userAccountList:userAccounts
//                     announce:announce
//                        intro:intro completion:completionBlock];
//}
//
- (void) createGroupWithName:(NSString*) groupName
                      enName:(NSString*) enName
                   groupType:(ECSGroupType) groupType
             userAccountList:(NSArray *) userAccounts
                ownerAccount:(NSString *) ownerAccount
                    announce:(NSString*) announce
                       intro:(NSString*) intro
                  completion:(void (^)(NSString* groupId, NSString* failedList, NSError* error)) completionBlock{
    if ([groupName length] > MAX_GROUP_NAME_LENGTH || [groupName length] == 0) {
        if (completionBlock) {
            completionBlock(nil, nil, [[NSError alloc] initWithDomain:ECSGroupErrorDomain
                                                                 code:ECSGroupGroupNameError
                                                             userInfo:nil]);
        }
        return;
    }
    
    if (0 == [userAccounts count]) {
        return;
    }
    
    TSDK_S_CHAT_GROUP_INFO group_info;
    memset(&group_info, 0, sizeof(TSDK_S_CHAT_GROUP_INFO));
    strcpy(group_info.group_name, [groupName UTF8String]);
    strcpy(group_info.owner_account, [ownerAccount UTF8String]);
    group_info.group_type = groupType;
    TSDK_CHAR *group_id = (TSDK_CHAR *)malloc(16);
    memset_s(group_id, 16, 0, 16);
    
    TSDK_RESULT result = tsdk_add_chat_group(&group_info, group_id);
    
    
    if (result == TSDK_SUCCESS) {
        NSString *groupId = [NSString stringWithUTF8String:group_id];
//        free(group_id);
        ESpaceLocalDataManager * localManager = LOCAL_DATA_MANAGER;
        dispatch_async(espace_coredata_management_queue, ^{
            NSManagedObjectContext* bgCtx = [localManager backgroundObjectContext];
            [bgCtx performBlockAndWait:^{
                GroupEntity* group = [[ESpaceContactService sharedInstance] groupWithId:[NSString stringWithUTF8String:group_id] type:groupType inContext:bgCtx autoCreate:YES];
                group.owner = [[ESpaceContactService sharedInstance] userWithAccount:LOCAL_DATA_MANAGER.userAccount inContext:bgCtx autoCreate:YES];
                group.name = groupName;
                NSMutableSet* initUsers = [NSMutableSet new];
                [initUsers addObject:group.owner];
                [group addMembers:initUsers];
                group.announce = announce;
                group.groupType = [NSNumber numberWithInteger:groupType];
                group.intro = intro;
                group.ownerId = ownerAccount;

                [bgCtx saveToPersistent];

                if (completionBlock) {
                    completionBlock(groupId, nil, nil);
                }
                
                for (NSString *account in userAccounts) {
                    [group inviteUser:account desc:@"" completion:^(NSString *faildList, NSError *error) {
                        
                    }];
                }
                
                

            }];
        });
        
        

    }
    
//    ECSManageGroup* mangeGroup = [ECSManageGroup new];
//    mangeGroup.ActionType = @"ManageGroup";
//    mangeGroup.user = [[[ECSAppConfig sharedInstance] currentUser] account];
//    mangeGroup.opt = ECSGroupCreate;
//    mangeGroup.joinCondition = joinCondition;
//    mangeGroup.groupName = groupName;
//    mangeGroup.enName = enName;
//    mangeGroup.groupType = groupType;
//    mangeGroup.announce = announce;
//    mangeGroup.intro = intro;
//    mangeGroup.groupAdmin = [[[ECSAppConfig sharedInstance] currentUser] account];
//
//    mangeGroup.inviteList = [userAccounts componentsJoinedByString:@";"];
//    ESpaceLocalDataManager * localManager = LOCAL_DATA_MANAGER;
//
//    [[ESpaceGroupService shareInstance].groupManageService manageGroupWithRequest:mangeGroup completionBlock:^(ECSManageGroupAck *retMsg, NSError *error) {
//        if (!error) {
//            dispatch_async(espace_coredata_management_queue, ^{
//                NSManagedObjectContext* bgCtx = [localManager backgroundObjectContext];
//                NSArray* failedList = [retMsg.failedList componentsSeparatedByString:@";"];
//
//                [bgCtx performBlockAndWait:^{
//                    GroupEntity* group = [[ESpaceContactService sharedInstance] groupWithId:retMsg.groupID type:groupType inContext:bgCtx autoCreate:YES];
//                    group.owner = [[ESpaceContactService sharedInstance] userWithAccount:LOCAL_DATA_MANAGER.userAccount inContext:bgCtx autoCreate:YES];
//                    group.name = groupName;
//                    group.joinFlag = [NSNumber numberWithInteger:joinCondition];
//                    NSMutableSet* initUsers = [NSMutableSet new];
//                    [initUsers addObject:group.owner];
//                    if (joinCondition == ECSGroupJoinAuto && [userAccounts count] > 0) {
//                        NSSet* failedSet = nil;
//                        if ([failedList count]) {
//                            failedSet = [NSSet setWithArray:failedList];
//                        }
//                        for (NSString* userAccount in userAccounts) {
//                            if (![failedSet containsObject:userAccount]) {
//                                [initUsers addObject:[[ESpaceContactService sharedInstance] userWithAccount:userAccount inContext:bgCtx autoCreate:YES]];
//                            }
//                        }
//                    }
//                    [group addMembers:initUsers];
//                    group.announce = announce;
//                    group.groupType = [NSNumber numberWithInteger:groupType];
//                    group.intro = intro;
//
//                    //构建一条创建讨论组成功的消息
//                    NSString* tipMsg = @"";
//                    NSInteger memberCount = 0;
//                    for(EmployeeEntity*member in initUsers) {
//                        if ([member isMe]) {
//                            SDK_DEBUG_LOG("不要提示自己");
//                            continue;
//                        }
//                        if (memberCount != 0) {
//                            tipMsg = [tipMsg stringByAppendingString:@","];
//
//                        }
//                        NSString* tempName = [member uiDisplayName];
//                        tipMsg = [tipMsg stringByAppendingFormat:@"%@",tempName];
//                        memberCount++;
//                    }
//                    ChatMessageEntity* groupCreatedTip = [TUPMediator_IMService M_createMessageForSession:group.chatSession timestamp:[NSDate date] flag:ESpaceMessageFlagGroupStateChanged readed:YES];
//                    groupCreatedTip.body = [NSString stringWithFormat:ECSLocalizedString(@"dizgroup_invite", @"您已将%@加入讨论组"),tipMsg];
//                    groupCreatedTip.from = [[ESpaceContactService sharedInstance] userWithAccount:[LOCAL_DATA_MANAGER userAccount] inContext:bgCtx];
//                    groupCreatedTip.to = group;
//                    group.chatSession.timestamp = [NSDate date];
//                    if ([group.chatSession.priority integerValue] < 0) {
//                        group.chatSession.priority = [NSNumber numberWithInteger:0];
//                    }
//                    [bgCtx saveToPersistent];
//
//                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//                        if (completionBlock) {
//                            completionBlock(retMsg.groupID, retMsg.failedList, error);
//                        }
//                    });
//                }];
//            });
//
//        } else {
//            if (completionBlock) {
//                completionBlock(nil, nil, error);
//            }
//        }
//    }];
}

- (void) queryCorpAdressBook:(NSString*) keyword
                   pageIndex:(NSInteger) pageIndex
                    pageSize:(NSInteger) pageSize
                       field:(NSString*) field
                  showStatus:(BOOL) bShow
                  searchFlag:(ESpaceSearchFlag) searchFlag
                   inContext:(NSManagedObjectContext*) ctx
                  completion:(void (^)(NSError* error, NSInteger count)) completionBlock
{
    [self queryCorpAdressBook:keyword
                    pageIndex:pageIndex
                     pageSize:pageSize
                        field:field
                   showStatus:bShow
                   searchFlag:searchFlag
                    inContext:ctx
                    maxWeight:-1
                   completion:completionBlock];
}

//- (void) queryCorpAdressBook:(NSString*) keyword
//                   pageIndex:(NSInteger) pageIndex
//                    pageSize:(NSInteger) pageSize
//                       field:(NSString*) field
//                  showStatus:(BOOL) bShow
//                  searchFlag:(ESpaceSearchFlag) searchFlag
//                   inContext:(NSManagedObjectContext*) ctx
//                   maxWeight:(NSInteger)lastMaxWeight
//                  completion:(void (^)(NSError* error, NSInteger count)) completionBlock
//{
//    NSString* user = [[[ECSAppConfig sharedInstance] currentUser] account];
//    ECSQueryCorpContacts* query = [ECSQueryCorpContacts new];
//    query.ActionType = @"GetEPersonList";
//    query.user = user;
//    query.show = bShow ? @"true" : @"false";
//    query.queryCustom = NO;
//    query.condition = keyword;
//    query.pagecount = pageSize;
//    query.pagenum = pageIndex;
//    query.queryField = field;
//    query.searchFlag = searchFlag;
//
//    long long startTime = ( long long)[[NSDate date] timeIntervalSince1970]*1000;
//
//    [self.contactService queryCorpContactsWithRequest:query completionBlock:^(ECSQueryCorpContactsAck *retMsgs, NSError *error) {
//
//        if (!error ) {
//            NSTimeInterval nowTime = [[NSDate date] timeIntervalSince1970]*1000;
//            long long  offsetTime = ( long long)nowTime - startTime;
//
//            if ((offsetTime > 0)) {
//                // TODO: chenzhiqian
////                [[ESpaceEventRecordModel shareEventRecordModel]  recordCapabilityWithId:CAPABLE_SEARCH_CONTACTS_ID withDuration:(NSInteger)offsetTime ];
//            }
//        }
//
//        if (retMsgs) {
//            NSManagedObjectContext* bgCtx = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
//            bgCtx.parentContext = ctx;
//            [bgCtx performBlock:^{
//                NSFetchRequest* request = [[NSFetchRequest alloc] init];
//                request.entity = [NSEntityDescription entityForName:@"EmployeeEntity" inManagedObjectContext:bgCtx];
//                request.fetchLimit = 1;
//                request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"weight" ascending:NO]];
//                NSInteger topWeight = lastMaxWeight;
//                if (topWeight < 0) {
//                    EmployeeEntity* topWeightEntity = [[bgCtx executeFetchRequest:request error:nil] firstObject];
//                    topWeight = [topWeightEntity.weight integerValue];
//                }
//                for (ECSCorpUserContact* retMsg in retMsgs.entAddrRecord) {
//                    EmployeeEntity* bgEntity = [self userWithAccount:retMsg.eSpaceNumber inContext:bgCtx autoCreate:YES];
//                    bgEntity.address = retMsg.address;
//                    bgEntity.assistantList = retMsg.assistantList;
//                    bgEntity.bdHideFlag = [NSNumber numberWithInteger:retMsg.bindnoHideFlag];
//                    bgEntity.isBindnoShow = [NSNumber numberWithBool:retMsg.bindnoHideFlag == 0];
//                    bgEntity.bindNumber = retMsg.bindno;
//                    bgEntity.contact = retMsg.contact;
//                    bgEntity.deptDesc = retMsg.deptDesc;
//                    bgEntity.deptDescEnglish = retMsg.deptDescEnglish;
//                    bgEntity.deptName = retMsg.deptname;
//                    bgEntity.displayName = retMsg.displayName;
//                    bgEntity.domain = retMsg.domain;
//                    bgEntity.email = retMsg.email;
//                    bgEntity.fax = retMsg.fax;
//                    bgEntity.faxList = retMsg.faxList;
//                    bgEntity.foreignName = retMsg.foreignName;
//                    bgEntity.homePage = retMsg.homepage;
//                    bgEntity.homePhone = retMsg.homePhone;
//                    bgEntity.interPhoneList = retMsg.interPhoneList;
//                    bgEntity.m2 = retMsg.m2;
//                    bgEntity.mobile = retMsg.mobile;
//                    bgEntity.mobileList = retMsg.mobileList;
//                    bgEntity.nativeName = retMsg.nativeName;
//                    bgEntity.notesMail = retMsg.notesMail;
//                    bgEntity.officePhone = retMsg.officephone;
//                    bgEntity.originMobile = retMsg.originMobile;
//                    bgEntity.originOffice = retMsg.originOffice;
//                    bgEntity.otherInfo = retMsg.otherInfo;
//                    bgEntity.phone = retMsg.phone;
//                    bgEntity.phoneList = retMsg.phoneList;
//                    bgEntity.pinyinName = retMsg.pinyinName;
//                    bgEntity.position = retMsg.position;
//                    bgEntity.postalCode = retMsg.postalcode;
//                    bgEntity.room = retMsg.room;
//                    bgEntity.sex = retMsg.sex;
//                    bgEntity.shortNumber = retMsg.shortphone;
//                    bgEntity.signature = retMsg.signature;
//                    bgEntity.simplifiedPinyin = retMsg.simplifiedPinyin;
//                    bgEntity.softClientExtPhone = retMsg.softClientExtPhone;
//                    bgEntity.softClientExtPhoneDomain = retMsg.softClientExtPhoneDomain;
//                    bgEntity.sp2 = retMsg.sp2;
//                    bgEntity.sp2Domain = retMsg.sp2Domain;
//                    bgEntity.sp3 = retMsg.sp3;
//                    bgEntity.sp3Domain = retMsg.sp3Domain;
//                    bgEntity.sp4 = retMsg.sp4;
//                    bgEntity.sp4Domain = retMsg.sp4Domain;
//                    bgEntity.sp5 = retMsg.sp5;
//                    bgEntity.sp5Domain = retMsg.sp5Domain;
//                    bgEntity.sp6 = retMsg.sp6;
//                    bgEntity.sp6Domain = retMsg.sp6Domain;
//                    bgEntity.staffNo = retMsg.staffNo;
//                    bgEntity.timezone = retMsg.timezone;
//                    bgEntity.timezoneValue = retMsg.timezoneValue;
//                    bgEntity.spDomain = retMsg.spDomain;
//                    bgEntity.voip = retMsg.voip;
//                    bgEntity.voip2 = retMsg.voip2;
//                    bgEntity.voip2Domain = retMsg.voip2Domain;
//                    bgEntity.voip3 = retMsg.voip3;
//                    bgEntity.voip4 = retMsg.voip4;
//                    bgEntity.voip5 = retMsg.voip5;
//                    bgEntity.voip6 = retMsg.voip6;
//                    bgEntity.voipDomain = retMsg.voipDomain;
//                    bgEntity.voipList = retMsg.voipList;
//                    bgEntity.headId = retMsg.headid;
//                    bgEntity.contactId = retMsg.eSpaceNumber;
//                    bgEntity.weight = [NSNumber numberWithInteger:(++ topWeight)];
//                    if ([bgEntity.headId length] == 0) {
//                        bgEntity.headId = @"0";
//                    }
//                    bgEntity.name = retMsg.name;
//                }
//                [bgCtx save:nil];
//
//                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//                    if (completionBlock) {
//                        completionBlock(error, retMsgs.entAddrRecord.count);
//                    }
//                });
//
//            }];
//        } else {
//            if (completionBlock) {
//                completionBlock(error, 0);
//            }
//        }
//    }];
//}

- (EmployeeCategoryEntity*) employeeCategoryWithId:(NSString*) categoryId inContext:(NSManagedObjectContext*) context autoCreate:(BOOL)bAutoCreate{
    if (!categoryId || !context){
//        SDK_DEBUG_LOG("categoryId length is zero, or context is nil.");
        return nil;
    }
    
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"id=%@", categoryId];
    EmployeeCategoryEntity* entity = [ESpaceLocalDataManager fetchOneObject:predicate inEnitity:@"EmployeeCategoryEntity" inContext:context];
    if (!entity && bAutoCreate) {
        NSEntityDescription* description = [NSEntityDescription entityForName:@"EmployeeCategoryEntity" inManagedObjectContext:context];
        entity = [[EmployeeCategoryEntity alloc] initWithEntity:description insertIntoManagedObjectContext:context];
        entity.id = categoryId;
    }
    return entity;
}

- (void) fillGroupInfo:(GroupEntity*) bgEntity withAck:(TSDK_S_CHAT_GROUP_INFO) retMsg {
    bgEntity.contactId = [NSString stringWithUTF8String:retMsg.group_id];
    bgEntity.name = [NSString stringWithUTF8String:retMsg.group_name];
    bgEntity.capacity = [NSNumber numberWithInteger:retMsg.capacity];
    bgEntity.intro = [NSString stringWithUTF8String:retMsg.description];
    bgEntity.joinFlag = [NSNumber numberWithInteger:retMsg.join_auth_mode];
    bgEntity.announce = [NSString stringWithUTF8String:retMsg.manifesto];
    bgEntity.msgRecvOpt = [NSNumber numberWithInteger:retMsg.msg_prompt_policy];
    bgEntity.state = [NSNumber numberWithInteger:ESpaceGroupStateExist];
    bgEntity.groupType = [NSNumber numberWithInteger:retMsg.group_type];
    bgEntity.ownerId = [NSString stringWithUTF8String:retMsg.owner_account];
    
//    bgEntity.fixed = [NSNumber numberWithBool:retMsg.fixed];
//    bgEntity.ownerId = retMsg.owner;
//    if ([[ECSAppConfig sharedInstance].currentUser isSupportFunction:EN_FUNC_SERVER_MASK_GROUP_MSG]) {
//        bgEntity.msgRecvOpt = [NSNumber numberWithInteger:retMsg.recvmsg];
//    }
//    bgEntity.headId = retMsg.id;
//
//    bgEntity.owner = [self userWithAccount:retMsg.owner inContext:bgEntity.managedObjectContext autoCreate:YES];
//    bgEntity.appName = retMsg.appName;
//    bgEntity.appID = retMsg.appID;
//    bgEntity.isFavourited = @(retMsg.servicePolicy ? YES : NO);
//    bgEntity.groupSpaceInfo = retMsg.groupSpaceInfo;
}

- (void) fillPersonInfo:(CustomContactEntity*) bgEntity withSelfDefContactInfo:(TSDK_S_SELF_DEF_CONTACT_INFO) retMsg {
    bgEntity.contactId = [NSString stringWithFormat:@"%lld",retMsg.contact_id];
//    bgEntity.staffNo = [NSString stringWithUTF8String:retMsg.staff_no];
    bgEntity.name = [NSString stringWithUTF8String:retMsg.name];
    bgEntity.nickname = [NSString stringWithUTF8String:retMsg.nick_name];
    bgEntity.foreignName = [NSString stringWithUTF8String:retMsg.foreign_name];
//    bgEntity.nativeName = [NSString stringWithUTF8String:retMsg.native_name];
//    bgEntity.pinyinName = [NSString stringWithUTF8String:retMsg.full_spelling];
    if (retMsg.gender == TSDK_E_GENDER_MALE) {
        bgEntity.sex = @"male";
    }
    else if (retMsg.gender == TSDK_E_GENDER_FEMALE){
        bgEntity.sex = @"femail";
    }
    bgEntity.deptName = [NSString stringWithUTF8String:retMsg.department_name];
    bgEntity.mobile = [NSString stringWithUTF8String:retMsg.mobile];
    bgEntity.homePhone = [NSString stringWithUTF8String:retMsg.home_phone];
    bgEntity.officePhone = [NSString stringWithUTF8String:retMsg.office_phone];
//    bgEntity.shortNumber = [NSString stringWithUTF8String:retMsg.short_phone];
//    bgEntity.voip = [NSString stringWithUTF8String:retMsg.voip];
    bgEntity.fax = [NSString stringWithUTF8String:retMsg.fax];
    bgEntity.email = [NSString stringWithUTF8String:retMsg.email];
//    bgEntity.signature = [NSString stringWithUTF8String:retMsg.signature];
    bgEntity.address = [NSString stringWithUTF8String:retMsg.address];
//    bgEntity.headId = [NSString stringWithUTF8String:retMsg.image_id];
    
    
    // jl todo isfriend
    //    NSString *account = [NSString stringWithUTF8String:retMsg->staff_account];
    // For CustomContactEntity, isFriend Property in local is always YES.
    //    if ([account length] != 0) {
    //        if (NSOrderedSame != [account compare:[ECSAppConfig sharedInstance].currentUser.account]) {
    //            //同步信息中如果包含自己，则不处理isFriend字段
    //            bgEntity.isFriend = [NSNumber numberWithBool:retMsg.isFriend];
    //        }
    //    } else {
//    bgEntity.isFriend = [NSNumber numberWithBool:YES];
    //    }
    
    
    
}

- (void) fillPersonInfo:(PersonEntity*) bgEntity withAck:(TSDK_S_IM_USER_INFO) retMsg {
    bgEntity.contactId = [NSString stringWithFormat:@"%lld",retMsg.contact_id];
    bgEntity.staffNo = [NSString stringWithUTF8String:retMsg.staff_no];
    bgEntity.name = [NSString stringWithUTF8String:retMsg.name];
    bgEntity.nativeName = [NSString stringWithUTF8String:retMsg.native_name];
    bgEntity.pinyinName = [NSString stringWithUTF8String:retMsg.full_spelling];
    if (retMsg.gender == TSDK_E_GENDER_MALE) {
        bgEntity.sex = @"male";
    }
    else if (retMsg.gender == TSDK_E_GENDER_FEMALE){
        bgEntity.sex = @"femail";
    }
    bgEntity.deptName = [NSString stringWithUTF8String:retMsg.department_name_cn];
    bgEntity.mobile = [NSString stringWithUTF8String:retMsg.mobile];
    bgEntity.homePhone = [NSString stringWithUTF8String:retMsg.home_phone];
    bgEntity.officePhone = [NSString stringWithUTF8String:retMsg.office_phone];
    bgEntity.shortNumber = [NSString stringWithUTF8String:retMsg.short_phone];
    bgEntity.voip = [NSString stringWithUTF8String:retMsg.voip];
    bgEntity.fax = [NSString stringWithUTF8String:retMsg.fax];
    bgEntity.email = [NSString stringWithUTF8String:retMsg.email];
    bgEntity.signature = [NSString stringWithUTF8String:retMsg.signature];
    bgEntity.address = [NSString stringWithUTF8String:retMsg.address];
    bgEntity.headId = [NSString stringWithUTF8String:retMsg.image_id];

    
    // jl todo isfriend
//    NSString *account = [NSString stringWithUTF8String:retMsg->staff_account];
    // For CustomContactEntity, isFriend Property in local is always YES.
//    if ([account length] != 0) {
//        if (NSOrderedSame != [account compare:[ECSAppConfig sharedInstance].currentUser.account]) {
//            //同步信息中如果包含自己，则不处理isFriend字段
//            bgEntity.isFriend = [NSNumber numberWithBool:retMsg.isFriend];
//        }
//    } else {
//        bgEntity.isFriend = [NSNumber numberWithBool:YES];
//    }

    
//    //此处需考虑多分组情况
//    if ([retMsg.groupid length]) {
//        EmployeeCategoryEntity* category = [self employeeCategoryWithId:retMsg.groupid inContext:bgEntity.managedObjectContext autoCreate:YES];
//        if (category && NO == [bgEntity.category containsObject:category]) {
//            [bgEntity addCategoryObject:category];
//        }
//    }


//    NSString *fulSpelling = [NSString stringWithUTF8String:retMsg->full_spelling];
//    // 当服务器没有下发拼音和简拼时终端需要根据已有字段进行解析并拼装
//    if ([fulSpelling length] == 0)
//    {
//        NSArray *array  = [PhoneticContacts pinyinAndSimplifiedPinyin:[self getCompareName:retMsg]];
//        if ([bgEntity.pinyinName length] == 0)
//        {
//            bgEntity.pinyinName = [array objectAtIndex:0];
//        }
//
//        if ([bgEntity.simplifiedPinyin length] == 0)
//        {
//            bgEntity.simplifiedPinyin = [array objectAtIndex:1];
//        }
//    }
}

- (void) fillEmployeeInfo:(EmployeeEntity*) bgEntity withAck:(TSDK_S_IM_USER_INFO) retMsg {
    [self fillPersonInfo:bgEntity withAck:retMsg];
    bgEntity.account = [NSString stringWithUTF8String:retMsg.staff_account];
//    bgEntity.circleRelation = [NSNumber numberWithInteger:retMsg.circleRelation];
//    bgEntity.circleWatched = [NSNumber numberWithInteger:retMsg.sendCircleMsg]; //watched为是否允许他看我
//    bgEntity.circleWatch = [NSNumber numberWithInteger:retMsg.recvCircleMsg];  //wathced为我是否要看他
//    bgEntity.isBindnoShow =  [NSNumber numberWithBool:retMsg.bdHideFlag == 0 ? YES : NO];
}

+ (instancetype) sharedInstance {
    static dispatch_once_t onceToken;
    static ESpaceContactService* service;
    dispatch_once(&onceToken, ^{
        service = [[ESpaceContactService alloc] init];
    });
    return service;
}

/**
 *  判断是否有能力显示im和状态
 *
 *  @param person 联系人
 *
 *  @return 是否具有权限
 */
+ (BOOL)isableToShowImAndPresenceForPerson:(EmployeeEntity*)person {
    BOOL isExist = YES;
    
//    //非UC2.0组网下不判断绑定号是否为空
//    if (SERVERTYPE_UC_V2 != [ECSAppConfig sharedInstance].serverAbility.serverType) {
//        return isExist;
//    }
    
    if (0 == [[LOCAL_DATA_MANAGER currentUser].bindNumber length]) {
        isExist = NO;
    }
    if (0 == [person.bindNumber length]) {
        isExist = NO;
    }
    return isExist;
}

+ (BOOL)imAbilityOfPerson:(EmployeeEntity*)employ {
    
    if (NO == [[ECSAppConfig sharedInstance].currentUser isSupportFunction:EN_FUNC_IM]) {
        return NO;
    }
    EspaceUserOnlineStatus* onlineStatus = [[ESpaceContactService sharedInstance] onlineStatusForUser:employ.contactId forceSubscribe:NO];
    if (onlineStatus && [onlineStatus isImAllowed] == NO) {
        return NO;
    }
    if (NO == [self isableToShowImAndPresenceForPerson:employ]) {
        return NO;
    }
    
    return YES;
}

+ (BOOL)presenceAbilityOfPerson:(EmployeeEntity*)employ {
    
    if (NO == [[ECSAppConfig sharedInstance].currentUser isSupportFunction:EN_FUNC_PRESENCE]) {
        return NO;
    }
    EspaceUserOnlineStatus* onlineStatus = [[ESpaceContactService sharedInstance] onlineStatusForUser:employ.contactId forceSubscribe:NO];
    if (NO == [onlineStatus isPresenceAllowed]) {
        return NO;
    }
    
    return YES;
}

- (void)dealloc {
    [((id)[ManagerService loginService]) removeObserver:self forKeyPath:@"serviceStatus" context:NULL];
}

- (void)addFriend:(EmployeeEntity*)person toExistedTeam:(EmployeeCategoryEntity*)team notify:(BOOL)needNotify completion:(void (^)(NSError* error)) completionBlock {
    
    TSDK_S_ADD_FRIEND_REQ_PARAM req_param;
    memset(&req_param, 0, sizeof(TSDK_S_ADD_FRIEND_REQ_PARAM));
    strcpy(req_param.staff_account, [person.account UTF8String]);
    req_param.group_id = [team.id intValue];
    
    TSDK_INT64 *contact_id = (TSDK_INT64 *)malloc(16);
    memset_s(contact_id, 16, 0, 16);
    
    TSDK_RESULT result = tsdk_add_friend(&req_param, contact_id);
    
    if (result == TSDK_SUCCESS) {
        dispatch_async(espace_coredata_management_queue, ^{
            ESpaceLocalDataManager * localManager = LOCAL_DATA_MANAGER;
            NSManagedObjectContext* bgCtx = [localManager backgroundObjectContext];
            NSManagedObjectID* oldPersonId = person.objectID;
            NSManagedObjectID* oldTeamId = team.objectID;
            [bgCtx performBlockAndWait:^{
                
                EmployeeEntity* newFriend = (EmployeeEntity*)[bgCtx objectWithID:oldPersonId];
                EmployeeCategoryEntity* tempTeam = (EmployeeCategoryEntity*)[bgCtx objectWithID:oldTeamId];
                if (![newFriend.isFriend boolValue]) {
                    newFriend.isFriend = [NSNumber numberWithBool:YES];
                }
                if (tempTeam.idx != nil) {
                    [newFriend addCategoryObject:tempTeam];
                }
                
                [bgCtx saveToPersistent];
                
                if (completionBlock) {
                    completionBlock(nil);
                }
            }];
        });
    }
}

- (NSInteger)getMaxTeamId {
    __block NSInteger teamId = -1;
    NSManagedObjectContext* bgCtx = [LOCAL_DATA_MANAGER managedObjectContext];
    [bgCtx performBlockAndWait:^{
        NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:@"EmployeeCategoryEntity"];
        [request setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"idx" ascending:NO]]];
        [request setFetchLimit:1];
        
        NSError* error = nil;
        NSArray* result = [bgCtx executeFetchRequest:request error:&error];
        
        if ([result count] > 0) {
            EmployeeCategoryEntity* categoryEntity = (EmployeeCategoryEntity*)[result firstObject];
            teamId = [categoryEntity.idx integerValue];
        }
    }];
    
    return teamId;
}

- (void)deleteFriend:(EmployeeEntity*)person completion:(void (^)(NSError *))completionBlock {
    if (![person.isFriend boolValue]) {
        if (completionBlock) {
            completionBlock(nil);
        }
//        SDK_DEBUG_LOG("非好友无法删除");
        return;
    }
    
    TSDK_RESULT result = tsdk_del_friend([person.contactId intValue], [self.currentContactGroupId intValue]);
    if (result == TSDK_SUCCESS) {
        ESpaceLocalDataManager * localManager = LOCAL_DATA_MANAGER;
        NSManagedObjectID *personObjID = person.objectID;
        dispatch_async(espace_coredata_management_queue, ^{
            NSManagedObjectContext* bgCtx = [localManager backgroundObjectContext];
            [bgCtx performBlockAndWait:^{
                EmployeeEntity *shadowPerson = (EmployeeEntity *)[bgCtx objectWithID:personObjID];
                shadowPerson.isFriend = [NSNumber numberWithBool:NO];
                shadowPerson.category  = nil;
                [bgCtx saveToPersistent];
                if (completionBlock) {
                    completionBlock(nil);
                }
            }];
        });
    }
    
}

- (EmployeeEntity*)employeeFromCopyMemoryUser:(EmployeeEntity*)memoryUser
{
    if (memoryUser.managedObjectContext == [LOCAL_DATA_MANAGER managedObjectContext])
    {
        return memoryUser;
    }
    else
    {
        dispatch_sync(espace_coredata_management_queue, ^{
            NSManagedObjectContext* bgCtx = [LOCAL_DATA_MANAGER backgroundObjectContext];
            [bgCtx performBlockAndWait:^{
                EmployeeEntity* bgEntity = [self userWithAccount:memoryUser.account inContext:bgCtx autoCreate:NO];
                if (!bgEntity) {
                    bgEntity = [self userWithAccount:memoryUser.account
                                           inContext:bgCtx
                                          autoCreate:YES];
                }
                bgEntity.address = memoryUser.address;
                bgEntity.assistantList = memoryUser.assistantList;
                bgEntity.bdHideFlag = memoryUser.bdHideFlag;
                bgEntity.isBindnoShow = memoryUser.isBindnoShow;
                bgEntity.bindNumber = memoryUser.bindNumber;
                bgEntity.contact = memoryUser.contact;
                bgEntity.deptDesc = memoryUser.deptDesc;
                bgEntity.deptDescEnglish = memoryUser.deptDescEnglish;
                bgEntity.deptName = memoryUser.deptName;
                bgEntity.displayName = memoryUser.displayName;
                bgEntity.domain = memoryUser.domain;
                bgEntity.email = memoryUser.email;
                bgEntity.fax = memoryUser.fax;
                bgEntity.faxList = memoryUser.faxList;
                bgEntity.foreignName = memoryUser.foreignName;
                bgEntity.homePage = memoryUser.homePage;
                bgEntity.homePhone = memoryUser.homePhone;
                bgEntity.interPhoneList = memoryUser.interPhoneList;
                bgEntity.m2 = memoryUser.m2;
                bgEntity.mobile = memoryUser.mobile;
                bgEntity.mobileList = memoryUser.mobileList;
                bgEntity.nativeName = memoryUser.nativeName;
                bgEntity.notesMail = memoryUser.notesMail;
                bgEntity.officePhone = memoryUser.officePhone;
                bgEntity.originMobile = memoryUser.originMobile;
                bgEntity.originOffice = memoryUser.originOffice;
                bgEntity.otherInfo = memoryUser.otherInfo;
                bgEntity.phone = memoryUser.phone;
                bgEntity.phoneList = memoryUser.phoneList;
                bgEntity.pinyinName = memoryUser.pinyinName;
                bgEntity.position = memoryUser.position;
                bgEntity.postalCode = memoryUser.postalCode;
                bgEntity.room = memoryUser.room;
                bgEntity.sex = memoryUser.sex;
                bgEntity.shortNumber = memoryUser.shortNumber;
                bgEntity.signature = memoryUser.signature;
                bgEntity.simplifiedPinyin = memoryUser.simplifiedPinyin;
                bgEntity.softClientExtPhone = memoryUser.softClientExtPhone;
                bgEntity.softClientExtPhoneDomain = memoryUser.softClientExtPhoneDomain;
                bgEntity.sp2 = memoryUser.sp2;
                bgEntity.sp2Domain = memoryUser.sp2Domain;
                bgEntity.sp3 = memoryUser.sp3;
                bgEntity.sp3Domain = memoryUser.sp3Domain;
                bgEntity.sp4 = memoryUser.sp4;
                bgEntity.sp4Domain = memoryUser.sp4Domain;
                bgEntity.sp5 = memoryUser.sp5;
                bgEntity.sp5Domain = memoryUser.sp5Domain;
                bgEntity.sp6 = memoryUser.sp6;
                bgEntity.sp6Domain = memoryUser.sp6Domain;
                bgEntity.staffNo = memoryUser.staffNo;
                bgEntity.timezone = memoryUser.timezone;
                bgEntity.timezoneValue = memoryUser.timezoneValue;
                bgEntity.spDomain = memoryUser.spDomain;
                bgEntity.voip = memoryUser.voip;
                bgEntity.voip2 = memoryUser.voip2;
                bgEntity.voip2Domain = memoryUser.voip2Domain;
                bgEntity.voip3 = memoryUser.voip3;
                bgEntity.voip4 = memoryUser.voip4;
                bgEntity.voip5 = memoryUser.voip5;
                bgEntity.voip6 = memoryUser.voip6;
                bgEntity.voipDomain = memoryUser.voipDomain;
                bgEntity.voipList = memoryUser.voipList;
                bgEntity.headId = memoryUser.headId;
                bgEntity.contactId = memoryUser.contactId;
                bgEntity.name = memoryUser.name;
                bgEntity.infoUpdateTime = [NSDate date];
                [bgCtx saveToPersistent];
            }];
        });
        
        return [self userWithAccount:memoryUser.account
                           inContext:[LOCAL_DATA_MANAGER managedObjectContext]
                          autoCreate:NO];
    }
}

#pragma mark - contact search history record

- (ContactEntity *)insertSearchHistoryRecord:(ContactEntity *)insertContact
{
    if (![insertContact isKindOfClass:[ContactEntity class]]) {
        return nil;
    }
    
    ESpaceLocalDataManager * localManager = LOCAL_DATA_MANAGER;
    // query max searchIndex and +1
    NSManagedObjectContext* context = [localManager managedObjectContext];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"searchIndex > 0"];
    NSSortDescriptor *sortDesc = [[NSSortDescriptor alloc] initWithKey:@"searchIndex" ascending:NO];
    NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass([ContactEntity class])
                                              inManagedObjectContext:context];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    fetchRequest.entity = entity;
    fetchRequest.sortDescriptors = [NSArray arrayWithObject:sortDesc];
    fetchRequest.predicate = predicate;
    NSArray *array = [context executeFetchRequest:fetchRequest error:nil];
    NSInteger maxSearchIndex = 1;
    if ([array count] > 0) {
        maxSearchIndex = [[(ContactEntity *)array.firstObject searchIndex] integerValue] + 1;
    }
    
    // chang memory EmployeeEntity to database
    ContactEntity *tmpContactEntity = insertContact;
    if ([insertContact isKindOfClass:[EmployeeEntity class]]
        && (insertContact.managedObjectContext != [localManager managedObjectContext]))
    {
        tmpContactEntity = [self employeeFromCopyMemoryUser:(EmployeeEntity*)insertContact];
    }
    
    // update searchID
    NSManagedObjectID *oldID = tmpContactEntity.objectID;
    dispatch_async(espace_coredata_management_queue, ^{
        NSManagedObjectContext *bgCtx = [localManager backgroundObjectContext];
        [bgCtx performBlockAndWait:^{
            ContactEntity *newContact = (ContactEntity *)[bgCtx objectWithID:oldID];
            newContact.searchIndex = [NSNumber numberWithInteger:maxSearchIndex];
            [bgCtx saveToPersistent];
        }];
    });
    
    return tmpContactEntity;
}

- (NSArray *)querySearchHistoryRecord
{
    NSManagedObjectContext* context = [LOCAL_DATA_MANAGER managedObjectContext];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"searchIndex > 0"];
    NSSortDescriptor *sortDesc = [[NSSortDescriptor alloc] initWithKey:@"searchIndex" ascending:NO];
    NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass([ContactEntity class])
                                              inManagedObjectContext:context];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    fetchRequest.entity = entity;
    fetchRequest.sortDescriptors = [NSArray arrayWithObject:sortDesc];
    fetchRequest.predicate = predicate;
    fetchRequest.fetchLimit = 10;
    return [context executeFetchRequest:fetchRequest error:nil];
}

- (void)clearQuerySearchHistoryRecord
{
    ESpaceLocalDataManager * localManager = LOCAL_DATA_MANAGER;
    dispatch_async(espace_coredata_management_queue, ^{
        NSManagedObjectContext *bgCtx = [localManager backgroundObjectContext];
        [bgCtx performBlockAndWait:^{
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"searchIndex > 0"];
            NSSortDescriptor *sortDesc = [[NSSortDescriptor alloc] initWithKey:@"searchIndex" ascending:YES];
            NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass([ContactEntity class])
                                                      inManagedObjectContext:bgCtx];
            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
            fetchRequest.entity = entity;
            fetchRequest.sortDescriptors = [NSArray arrayWithObject:sortDesc];
            fetchRequest.predicate = predicate;
            NSArray *contacts = [bgCtx executeFetchRequest:fetchRequest error:nil];
            for (ContactEntity *tmpContact in contacts) {
                tmpContact.searchIndex = 0;
            }
            [bgCtx saveToPersistent];
        }];
    });
}

#pragma mark - private method
//-(NSString *)getCompareName:(ECSFullSyncAckUser *)user
//{
//    NSString *compareName = [self foreignNameOrNativeName:user];
//
//    if([compareName length] == 0) {
//        compareName = user.name;
//    }
//    if ([compareName length] == 0) {
//        if ([user.account length] > 0) {
//            compareName = user.account;
//        }
//        else {
//            compareName = user.bindnumber;
//        }
//    }
//    return compareName;
//}
//
///**
// *  获取英文名字或本地名字,中文环境，nativename非空，取nativename；非中文环境，foreignName非空，取foreignName
// *
// *  @param user 联系人对象
// *
// *  @return 用户名字
// */
//-(NSString*)foreignNameOrNativeName:(ECSFullSyncAckUser *)user
//{
//    NSString *tempName = nil;
//    if ([[ECSUtils clientLanguage] isEqualToString:@"ZH"]) {
//        if ([user.nativeName length] > 0) {
//            tempName = user.nativeName;
//        }
//    }else{
//        if([user.foreignName length] > 0)
//        {
//            tempName = user.foreignName;
//        }
//    }
//    return tempName;
//}

#pragma mark- 老版本升级到coreData版本时允许调用

//- (EmployeeEntity*)forceCreatUserWithAccount:(NSString*)userAccount inContext:(NSManagedObjectContext*)context {
//    if (0 == [userAccount length] || nil == context) {
//        SDK_DEBUG_LOG("userAccount length is zero, or context is nil.");
//        return nil;
//    }
//    NSEntityDescription* userEntity = [NSEntityDescription entityForName:@"EmployeeEntity" inManagedObjectContext:context];
//    EmployeeEntity* user = [[EmployeeEntity alloc] initWithEntity:userEntity insertIntoManagedObjectContext:context];
//    user.account = userAccount;
//    user.contactId = userAccount;
//    user.classType = [NSNumber numberWithInteger:ContactUserType];
//    [self createSpecialChatSessionForContact:user];
//    [self createCallSessionForContact:user];
//
//    return user;
//}

//- (GroupEntity*)forceCreatGroupWithId:(NSString*)_id
//                                 type:(NSInteger) type
//                            inContext:(NSManagedObjectContext*)context {
//    if (0 == [_id length] || nil == context) {
//        SDK_DEBUG_LOG("group id length is zero, or context is nil.");
//        return nil;
//    }
//    NSEntityDescription* groupEntity = [NSEntityDescription entityForName:@"GroupEntity" inManagedObjectContext:context];
//    NSEntityDescription* folderEntity = [NSEntityDescription entityForName:@"GroupFileEntity" inManagedObjectContext:context];
//    GroupFileEntity * rootFolder = [[GroupFileEntity alloc] initWithEntity:folderEntity insertIntoManagedObjectContext:context];
//    rootFolder.type = [NSNumber numberWithUnsignedInteger:ESpaceGPFolderType];
//    rootFolder.id = @"0";
//    rootFolder.createAt = [NSDate date];
//    GroupEntity* group = [[GroupEntity alloc] initWithEntity:groupEntity insertIntoManagedObjectContext:context];
//    group.contactId = _id;
//    group.groupType = [NSNumber numberWithInteger:type];
//    group.classType = [NSNumber numberWithInteger:ContactGroupType];
//    group.msgRecvOpt = [NSNumber numberWithInteger:ECSMarkGroupReceiveUnmute];
//    group.rootFolder = rootFolder;
//    NSPredicate* groupAssistentPredicate = [NSPredicate predicateWithFormat:@"type=%@ AND body CONTAINS %@", [NSNumber numberWithInteger:ESpaceAssistantGroupInvite], _id];
//    AssistantMessageEntity * groupAssistentMsg = [ESpaceLocalDataManager fetchOneObject:groupAssistentPredicate inEnitity:@"AssistantMessageEntity" inContext:context];
//    if (groupAssistentMsg.managedObjectContext && !groupAssistentMsg.deleted) {
//        groupAssistentMsg.action = [NSNumber numberWithInteger:ESpaceAssistantAccept];
//    }
//    [self createSpecialChatSessionForContact:group];
//
//    return group;
//}
//
//- (SpecialChatSessionEntity *)createSpecialChatSessionForContact:(ContactEntity *)contact {
//    SpecialChatSessionEntity* chatSession = (SpecialChatSessionEntity*)contact.chatSession;
//    if (contact && (!chatSession || chatSession.isDeleted)) {
//        NSEntityDescription* chatSessionEntity = [NSEntityDescription entityForName:@"SpecialChatSessionEntity" inManagedObjectContext:contact.managedObjectContext];
//        chatSession = [[SpecialChatSessionEntity alloc] initWithEntity:chatSessionEntity insertIntoManagedObjectContext:contact.managedObjectContext];
//        chatSession.parent = (NSManagedObject*)[ESpaceLocalDataManager rootChatSessionGroupInContext:contact.managedObjectContext];
//        chatSession.priority = [NSNumber numberWithInt:-1];
//        contact.chatSession = chatSession;
//    }
//    return chatSession;
//}

- (void)postNotification:(NSString *)key with:(NSMutableArray *)array{
    NSData *registerData;
    if ([NSJSONSerialization isValidJSONObject:array]) {
        NSError *error;
        registerData = [NSJSONSerialization dataWithJSONObject:array options:NSJSONWritingPrettyPrinted error:&error];
        //NSLog(@"Register JSON0:%@",[[NSString alloc] initWithData:registerData encoding:NSUTF8StringEncoding]);
    }
    dispatch_async_main_safe(^{
        [[NSNotificationCenter defaultCenter] postNotificationName:key object:registerData];
    })
}
#pragma mark-

- (void) getUserInfoWithAccount:(NSString *)account andContext:(NSManagedObjectContext*)bgCtx completionBlock:(void (^)(NSManagedObjectID* objectid, NSError* error)) completionBlock
{
    TSDK_S_IM_USER_INFO userInfo;
    memset(&userInfo, 0, sizeof(TSDK_S_IM_USER_INFO));
    
    TSDK_RESULT result = tsdk_get_user_info([account UTF8String], &userInfo);

    if (result == TSDK_SUCCESS) {
        __weak typeof(self) weakSelf = self;
        
        dispatch_async(espace_coredata_management_queue, ^{
            {
                [bgCtx performBlockAndWait:^{
                    EmployeeEntity* bgEntity = [weakSelf userWithAccount:account inContext:bgCtx autoCreate:YES];
                    if ([bgEntity.account isEqualToString:[eSpaceDBService sharedInstance].localDataManager.currentUser.account]) {
                        bgEntity.isFriend = [NSNumber numberWithBool:YES];
                    }
                    if (!bgEntity.managedObjectContext || bgEntity.isDeleted) {
                        if (completionBlock) {
                            NSError *error = [NSError errorWithDomain:ECSContactErrorDomain code:ECSContactQueryServerContactError userInfo:nil];
                            completionBlock(nil, error);
                        }
                        return;
                    }
                        bgEntity.contactId = [NSString stringWithUTF8String:userInfo.staff_account];
                        bgEntity.account = [NSString stringWithUTF8String:userInfo.staff_account];
                        bgEntity.name = [NSString stringWithUTF8String:userInfo.name];
                        bgEntity.sex = [[NSNumber numberWithInteger:(NSUInteger)userInfo.gender] stringValue];
                        bgEntity.signature = [NSString stringWithUTF8String:userInfo.signature];
                        bgEntity.deptName = [NSString stringWithUTF8String:userInfo.department_name_cn];
                        bgEntity.fax = [NSString stringWithUTF8String:userInfo.fax];
                        bgEntity.email = [NSString stringWithUTF8String:userInfo.email];
                        bgEntity.address = [NSString stringWithUTF8String:userInfo.address];
                        bgEntity.bindNumber = [NSString stringWithUTF8String:userInfo.bind_number];
                        bgEntity.mobile = [NSString stringWithUTF8String:userInfo.mobile];
                        bgEntity.shortNumber = [NSString stringWithUTF8String:userInfo.short_phone];
                        bgEntity.homePhone = [NSString stringWithUTF8String:userInfo.home_phone];
                        bgEntity.phone = [NSString stringWithUTF8String:userInfo.ip_phone_number];
                    
                        if ([bgEntity.headId length] == 0) {
                            bgEntity.headId = @"0";
                        }
                        if (![bgEntity.isFriend boolValue] && [bgEntity.contactId length] > 0) {
                            [[ESpaceContactService sharedInstance].nonFriendsRefreshTagsDic setObject:bgEntity.contactId forKey:bgEntity.contactId];
                        }
                    [bgCtx saveToPersistent];
                    bgEntity.itemLocalStatus = ItemLoaded;
                    if (completionBlock) {
                        completionBlock(bgEntity.objectID, nil);
                    }
                    
                }];
                
            }
        });
    }
}

- (void) createContactGroupWithGroupName:(NSString *)name completionBlock:(void (^) (NSString * groupId, NSError* error))completionBlock
{
    TSDK_S_ADD_CONTACT_GROUP_REQ_PARAM req_param;
    memset(&req_param, 0, sizeof(TSDK_S_ADD_CONTACT_GROUP_REQ_PARAM));
    strcpy(req_param.group_name, [name UTF8String]);
    
    TSDK_INT64 *group_id = (TSDK_INT64 *)malloc(16);
    memset_s(group_id, 16, 0, 16);
    TSDK_RESULT result = tsdk_add_contact_group(&req_param, group_id);
    
    if (result == TSDK_SUCCESS) {
        dispatch_async(espace_coredata_management_queue, ^{
            NSManagedObjectContext *bgCtx = [LOCAL_DATA_MANAGER backgroundObjectContext];
            NSDate* now = [NSDate date];
            [bgCtx performBlockAndWait:^{
                EmployeeCategoryEntity* employeeCategory = [self employeeCategoryWithId:[NSString stringWithFormat:@"%lld", group_id[0]] inContext:bgCtx autoCreate:YES];
                employeeCategory.name = name;
                employeeCategory.num = 0;
                employeeCategory.lastUpdateTime = now;
                employeeCategory.id = [NSString stringWithFormat:@"%lld", group_id[0]];
                
                [bgCtx saveToPersistentAndWait];
                
                if (completionBlock) {
                    completionBlock([NSString stringWithFormat:@"%lld", group_id[0]], nil);
                }
            }];
            
        });
    }
}

- (void) deleteContactGroupWithGroupId:(NSString *)groupId completionBlock:(void (^) (NSError* error))completionBlock
{
    TSDK_RESULT result = tsdk_del_contact_group([groupId longLongValue]);
    if (result == TSDK_SUCCESS) {
        dispatch_async(espace_coredata_management_queue, ^{
            NSManagedObjectContext *bgCtx = [LOCAL_DATA_MANAGER backgroundObjectContext];
            [bgCtx performBlockAndWait:^{
                NSArray* clearCategorys = [ESpaceLocalDataManager fetchObjects:nil inEnitity:@"EmployeeCategoryEntity" inContext:bgCtx];
                for (EmployeeCategoryEntity* category in clearCategorys) {
                    if ([category.id isEqualToString:groupId]) {
                        [bgCtx deleteObject:category];
                    }
                }
                [bgCtx saveToPersistentAndWait];
                
                if (completionBlock) {
                    completionBlock(nil);
                }
            }];
        });
    }
}

- (void) setSelfSignature:(NSString*)signature completion:(void(^)(NSError* error))completionBlock {
    
    TSDK_S_IM_USER_INFO userInfo;
    memset(&userInfo, 0, sizeof(TSDK_S_IM_USER_INFO));
    strcpy(userInfo.signature, [signature UTF8String]);
    strcpy(userInfo.staff_account, [[LOCAL_DATA_MANAGER userAccount] UTF8String]);
    
    TSDK_RESULT result = tsdk_set_user_info(&userInfo);
    
    ESpaceLocalDataManager * localManager = LOCAL_DATA_MANAGER;
    if (result == TSDK_SUCCESS) {
        dispatch_async(espace_coredata_management_queue, ^{
            NSManagedObjectContext* bgCtx = [localManager backgroundObjectContext];
            [bgCtx performBlockAndWait:^{
                
                EmployeeEntity* selfEntity = [[ESpaceContactService sharedInstance] userWithAccount:[LOCAL_DATA_MANAGER userAccount] inContext:bgCtx autoCreate:YES];;
                selfEntity.signature = signature;
                
                [bgCtx saveToPersistent];
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    if (completionBlock) {
                        completionBlock(nil);
                    }
                });
                
            }];
        });
    }
    
}

- (void)detectUserStatusWithAccountArray:(NSArray *)accountArray
{
    if (accountArray.count == 0) {
        return;
    }
    TSDK_S_IM_USER_STATUS_DETECT_PARAM detect_param;
    TSDK_S_IM_USER_BASE_INFO *account_list = (TSDK_S_IM_USER_BASE_INFO *)malloc(accountArray.count * sizeof(TSDK_S_IM_USER_BASE_INFO));
    memset_s(account_list, accountArray.count * sizeof(TSDK_S_IM_USER_BASE_INFO), 0, accountArray.count * sizeof(TSDK_S_IM_USER_BASE_INFO));
    detect_param.account_count = accountArray.count;
    if (accountArray.count > 0) {
        for (int i = 0; i < accountArray.count; i++) {
            strcpy(account_list[i].staff_account, [accountArray[i] UTF8String]);
        }
    }
    detect_param.account_list = account_list;
    TSDK_RESULT result = tsdk_detect_user_status(&detect_param);
    if (result == TSDK_SUCCESS) {
        
    }
}

- (void) setSelfStatus:(ESpaceUserStatus)status completion:(void(^)(NSError* error))completionBlock {
    NSString* currentUser = [[[ECSAppConfig sharedInstance] currentUser] account];
    
    TSDK_S_IM_USER_STATUS_INFO statusInfo;
    memset(&statusInfo, 0, sizeof(TSDK_S_IM_USER_STATUS_INFO));
    statusInfo.status = (TSDK_E_IM_USER_STATUS)status;
    
    TSDK_RESULT result = tsdk_set_personal_status(&statusInfo);
    if (result == TSDK_SUCCESS) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            EspaceUserOnlineStatus* onlineStatus = [[ESpaceContactService sharedInstance] onlineStatusForUser:currentUser forceSubscribe:YES];
            onlineStatus.clientType = ESpaceClientType_Mobile;
            
            onlineStatus.userStatus = status;
            if (completionBlock){
                completionBlock(nil);
            }
        });
    }
    
}


- (void)sendMessageWithMessage:(TsdkSendChatMsgInfo *)messageInfo completion:(void(^)(TsdkSendChatMsgResult *result ,NSError *error))completionBlock
{
    TSDK_S_SEND_CHAT_MSG_INFO chat_msg;
    memset(&chat_msg, 0, sizeof(TSDK_S_SEND_CHAT_MSG_INFO));
    chat_msg.chat_type = messageInfo.chatType;
    chat_msg.chat_media_type = messageInfo.chatMediaType;
    chat_msg.source_type = messageInfo.sourceType;
    strcpy(chat_msg.origin, [messageInfo.origin UTF8String]);
    
    if (messageInfo.target) {
        strcpy(chat_msg.target, [messageInfo.target UTF8String]);
    }
    if (messageInfo.groupId) {
        strcpy(chat_msg.group_id, [messageInfo.groupId UTF8String]);
        strcpy(chat_msg.target, [messageInfo.groupId UTF8String]);
    }
    
    NSString *message = [NSString stringWithFormat:@"<r><n></n><g>0</g><c>&lt;imbody&gt;&lt;imagelist&gt;&lt;/imagelist&gt;&lt;content&gt;%@&lt;/content&gt;&lt;html&gt;&lt;/html&gt;&lt;/imbody&gt;</c></r>",messageInfo.content];
    strcpy(chat_msg.content, [message UTF8String]);
    
    chat_msg.client_chat_id = messageInfo.clientChatId;
    
    TSDK_RESULT result = tsdk_send_message(&chat_msg);
    if (result == TSDK_SUCCESS) {
        DDLogInfo(@"tsdk_send_message,SUCCEEDED");
        if (completionBlock) {
            self.sendMsgBackAction = completionBlock;
        }
    }
}

- (void)setInputStateWithAccount:(NSString *)account isInPuttin:(BOOL)isInPutting
{
    TSDK_RESULT result = tsdk_set_inputting([account UTF8String], isInPutting);
    
    if (result == TSDK_SUCCESS) {
        DDLogInfo(@"tsdk_set_inputting,SUCCEEDED");
    }
    
}

- (void)setMessageIsReadedWithReadinfoArray:(NSArray *)msgReadInfo
{
    TSDK_S_SET_MSG_READ_PARAM setReadParam;
    memset(&setReadParam, 0, sizeof(TSDK_S_SET_MSG_READ_PARAM));
    TSDK_S_SET_MSG_READ_INFO *readMsgList = (TSDK_S_SET_MSG_READ_INFO *)malloc(msgReadInfo.count * sizeof(TSDK_S_SET_MSG_READ_INFO));
    memset_s(readMsgList, msgReadInfo.count * sizeof(TSDK_S_SET_MSG_READ_INFO), 0, msgReadInfo.count * sizeof(TSDK_S_SET_MSG_READ_INFO));
    for (int i = 0; i < msgReadInfo.count; i++) {
        TsdkSetChatMsgReadInfo *readInfo = msgReadInfo[i];
        readMsgList[i].history_msg_type = readInfo.historyMsgType;
        readMsgList[i].msg_id = readInfo.msgid;
        strcpy(readMsgList[i].origin, [readInfo.account UTF8String]);
    }
    setReadParam.read_msg_count = msgReadInfo.count;
    setReadParam.read_msg_list = readMsgList;

    TSDK_RESULT result = tsdk_set_message_read(&setReadParam);
    
    if (result == TSDK_SUCCESS) {
        DDLogInfo(@"tsdk_set_message_read,SUCCEEDED");
    }
    free(readMsgList);
}

- (TsdkQueryHistoryMsgResult *)fillHistoryMsgResultWithTsdkResult:(TSDK_S_QUERY_HISTORY_MSG_RESULT)result
{
    TsdkQueryHistoryMsgResult *msgResult = [[TsdkQueryHistoryMsgResult alloc] init];
    msgResult.queryType = result.query_type;
    msgResult.historyMsgType = result.history_msg_type;
    msgResult.account = [NSString stringWithUTF8String:result.origin];
    msgResult.totalCount = result.total_count;
    msgResult.chatMsgCount = result.chat_msg_count;

    TSDK_S_CHAT_MSG_INFO* msg_id_list = result.chat_msg_list;
    NSMutableArray *msgList = [[NSMutableArray alloc]init];
    for (int i = 0; i < result.chat_msg_count; i++) {
        TsdkChatMessageInfo *msgInfo = [self msgInfoToChatMessage:&msg_id_list[i]];
        [msgList addObject:msgInfo];
    }
    msgResult.chatMsgList = [NSArray arrayWithArray:msgList];
    return msgResult;
}

- (void)queryHistoryMessagesWithParam:(TsdkQueryHistoryMsgParam *)param andObjectId:(NSManagedObjectID *)objectId
{
    TSDK_S_QUERY_HISTORY_MSG_PARAM queryParam;
    memset(&queryParam, 0, sizeof(TSDK_S_QUERY_HISTORY_MSG_PARAM));
    TSDK_S_QUERY_HISTORY_MSG_RESULT queryResult;
    memset(&queryResult, 0, sizeof(TSDK_S_QUERY_HISTORY_MSG_RESULT));

    queryParam.history_msg_type = param.historyMsgType;
    strcpy(queryParam.origin, [param.account UTF8String]);
    if (param.msgid != 0) {
        queryParam.query_type = TSDK_E_HISTORY_CHAT_MSG_QUERY_BEFORE;
        queryParam.msg_id = param.msgid;
    }else{
        queryParam.query_type = TSDK_E_HISTORY_CHAT_MSG_QUERY_FIRST;
    }
    if (param.count != 0) {
        queryParam.count = param.count;
    }
    
    TSDK_RESULT result = tsdk_query_history_message(&queryParam,&queryResult);
    if (result == TSDK_SUCCESS) {
        DDLogInfo(@"tsdk_query_history_message,SUCCEEDED");
        ESpaceLocalDataManager * localManager = LOCAL_DATA_MANAGER;
        dispatch_async(espace_coredata_management_queue, ^{
            NSManagedObjectContext* bgCtx = [localManager managedObjectContext];
            [bgCtx performBlockAndWait:^{
                TsdkQueryHistoryMsgResult *historyResult = [self fillHistoryMsgResultWithTsdkResult:queryResult];
                
                ChatSessionEntity* chatSession = (ChatSessionEntity*)[bgCtx objectWithID:objectId];
                
                if (chatSession.managedObjectContext && !chatSession.isDeleted) {
                    
                    NSManagedObjectContext * bgCtx = chatSession.managedObjectContext;
                    for (TsdkChatMessageInfo* message in historyResult.chatMsgList) {
                        
//                        [self didReceiveChatMessage:message];
//
                        //EmployeeEntity* from = [[ESpaceContactService sharedInstance] userWithAccount:message.from inContext:bgCtx autoCreate:YES];
                        ContactEntity* to = nil;
                        ContactEntity *from = nil;
                        //判断是否是系统消息
//                        if (ESpaceMessageFromThirdSys == message.senderType) {
//                            from = [TUPMediator_ContactService M_systemInfoWithAppID:message.appID inContex:bgCtx autoCreat:YES];
//                        }else{
                            from = [self userWithAccount:message.account inContext:bgCtx autoCreate:YES];
//                        }
                        
                        
                        if (message.chatType == TSDK_E_CHAT_MSG_TYPE_FIXED_GROUP || message.chatType == TSDK_E_CHAT_MSG_TYPE_TEMP_GROUP) {
                            to = chatSession.target;
                        }
                        else{
                            if ([message.account length] > 0) {
                                from.contactId = message.account;
                            }
                            to = [self userWithAccount:message.target inContext:bgCtx autoCreate:YES];
                        }

                        NSPredicate* predicate = [NSPredicate predicateWithFormat:@"messageId=%lld", message.serverMsgId];


                        ChatMessageEntity* messageEntity = [ESpaceLocalDataManager fetchOneObject:predicate inEnitity:@"ChatMessageEntity" inContext:chatSession.managedObjectContext];
                        if (!messageEntity) {

//                            //多图文消息兼容,公众号转发消息、链接分享不进行解析
                            NSArray* subContentArray = [NSArray arrayWithObject:@""];
                            if (message.content) {
                                subContentArray = [NSArray arrayWithObject:message.content];
                            }
                            for (int i = 0 ; i < subContentArray.count ;i++) {
                                NSString* subString = [subContentArray objectAtIndex:i];
                                long long index = i;
                                NSDate* timestamp = [NSDate date];
                                if (message.utcStamp) {
                                    timestamp = [NSDate dateWithTimeIntervalSince1970:((message.utcStamp + index) / 1000.0)];
                                }
                                BOOL isReaded;//= index == 0 ? ([from isMe] ? YES : readed) : YES;
//                                if ([from isKindOfClass:[EmployeeEntity class]]) {
//                                    isReaded = index == 0 ? ([TUPMediator_ContactService M_EmployeeIsMe:(EmployeeEntity *)from] ? YES : readed) : YES;
//                                }else{
                                    isReaded = YES;
//                                }

                                BOOL isMe = NO;
                                if ([(EmployeeEntity *)from isKindOfClass:[EmployeeEntity class]]) {
                                    EmployeeEntity* tmpEmployee = (EmployeeEntity*)from;
                                    isMe = ![tmpEmployee.contactId compare:LOCAL_DATA_MANAGER.userAccount options:NSLiteralSearch];;
                                }

                                ChatSessionEntity *chatSession = isMe == YES ? to.chatSession : from.chatSession;
                                if (message.chatType == TSDK_E_CHAT_MSG_TYPE_FIXED_GROUP || message.chatType == TSDK_E_CHAT_MSG_TYPE_TEMP_GROUP) {
                                    chatSession = to.chatSession;
                                }

                                messageEntity = [self createMessageForSession:chatSession timestamp:timestamp readed:isReaded];
                                messageEntity.from = from;
                                messageEntity.to = to;
                                messageEntity.messageId = [NSString stringWithFormat:@"%lld",message.serverMsgId];
                                messageEntity.readDetail = [NSNumber numberWithBool:YES];
                                subString = [subString stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"];
                                subString = [subString stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"];
                                ECSImChatMsgXmlInfo *xmlInfo = [[ECSImChatMsgXmlInfo alloc] initWithXmlUserInfo:subString];
                                if (xmlInfo.content!= nil) {
                                    messageEntity.body = xmlInfo.content;
                                }else{
                                    messageEntity.body = subString;
                                }

                                messageEntity.total = [NSNumber numberWithInteger:subContentArray.count];
                            }

                        }
                        else{
//                            //若找到重复的消息，要将本地消息的状态更改为已发送，同时不会新插入消息
//                            if (ESpaceMsgStatusSended != messageEntity.transferStatus.unsignedIntegerValue) {
//                                //DDLogInfo(@"handle send failed message %@", message.id);  //su TODO
//                                messageEntity.transferStatus = @(ESpaceMsgStatusSended);
//                                messageEntity.messageId = [NSString stringWithFormat:@"lld",message.serverMsgId];
//                                messageEntity.receiveTimestamp = [ECSUtils dateFromMillisecondUTCValue:message.serverDeliverTime];
//                            }

                        }

                    }
                

                    [bgCtx saveToPersistent];
                }
                
            }];
        });

    }
}

- (void)deleteHistoryMessageWithParam:(TsdkDeleteHistoryMsgParam *)param
{
    TSDK_S_DEL_HISTORY_MSG_PARAM deleteParam;
    memset(&deleteParam, 0, sizeof(TSDK_S_DEL_HISTORY_MSG_PARAM));
    deleteParam.msg_type = param.msgType;
    deleteParam.op_type = param.opType;
    strcpy(&deleteParam.origin, [param.account UTF8String]);
    deleteParam.msg_id_count = param.count;
    TSDK_S_MSG_BASE_INFO *baseInfo = malloc(param.count * sizeof(TSDK_S_MSG_BASE_INFO));
    memset_s(baseInfo, param.count * sizeof(TSDK_S_MSG_BASE_INFO), 0, param.count * sizeof(TSDK_S_MSG_BASE_INFO));
    for (int i = 0; i < param.count; i++) {
        TsdkMsgBaseInfo *msgBaseInfo = param.msgIdList[i];
        long long msgId = msgBaseInfo.msgId;
        baseInfo[i].msg_id = msgId;
    }
    deleteParam.msg_id_list = baseInfo;
    TSDK_RESULT result = tsdk_delete_history_message(&deleteParam);
    if (result == TSDK_SUCCESS) {
        free(baseInfo);
        DDLogInfo(@"tsdk_delete_history_message,SUCCEEDED");
        
        dispatch_async(espace_coredata_management_queue, ^{
            ESpaceLocalDataManager * localManager = LOCAL_DATA_MANAGER;
            NSManagedObjectContext* bgCtx = [localManager backgroundObjectContext];
            [bgCtx performBlockAndWait:^{
                for (int i = 0; i < param.count; i++) {
                    TsdkMsgBaseInfo *msgBaseInfo = param.msgIdList[i];
                    long long msgId = msgBaseInfo.msgId;
                    
//                    ChatMessageEntity* messageEntity = nil;
                    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"messageId=%lld", msgId];
                    //                    messageEntity = [ESpaceLocalDataManager fetchOneObject:predicate inEnitity:@"ChatMessageEntity" inContext:bgCtx];
                    NSArray *arr = [ESpaceLocalDataManager fetchObjects:predicate inEnitity:@"ChatMessageEntity" inContext:bgCtx];
                    
                    if (arr.count > 0) {
                        ChatSessionEntity *session = ((ChatMessageEntity *)arr[0]).to.chatSession;
                        //                        NSArray *msgArray = [NSArray arrayWithObject:messageEntity];
                        
                        NSSet *messages = [NSSet setWithArray:arr];
                        
                        [session localDeleteMessages:messages];
//                                                    [session localDeleteMessages:messages completion:nil];
                        
                    }
                    
//                    for (ChatMessageEntity* messageEntity in arr) {
//                        NSMutableArray *idArray = [[NSMutableArray alloc] init];
//                        if (arr && [arr count] > 0) {
////                            ChatMessageEntity *message = messageEntity;
//                            [idArray addObject:messageEntity.objectID];
//
//                        }
//                        if (idArray.count > 0) {
//                            ChatSessionEntity *session = messageEntity.to.chatSession;
//                            //                        NSArray *msgArray = [NSArray arrayWithObject:messageEntity];
//
//                            NSSet *messages = [NSSet setWithArray:idArray];
//
//                                            [session localDeleteMessages:messages];
////                            [session localDeleteMessages:messages completion:nil];
//
//                        }
//                    }
                }
                
                [bgCtx processPendingChanges];
//                if ([bgCtx hasChanges]) {
//                    [bgCtx save:nil];
//                }
                [bgCtx saveToPersistent];
            }];
        });
    }
}

- (void)withDrawMessageParam:(TsdkMsgWithDrawReqParam *)param
{
    TSDK_S_CHAT_MSG_WITHDRAW_REQ_PARAM withdraw_msg_req;
    memset(&withdraw_msg_req, 0, sizeof(TSDK_S_CHAT_MSG_WITHDRAW_REQ_PARAM));
    if (param.origin.length > 0 && param.origin != nil) {
        strcpy(withdraw_msg_req.origin, [param.origin UTF8String]);
    }
    if (param.originname.length > 0 && param.originname != nil) {
        strcpy(withdraw_msg_req.origin_name, [param.originname UTF8String]);
    }
    if (param.target.length > 0 && param.target != nil) {
        strcpy(withdraw_msg_req.target, [param.target UTF8String]);
    }
    withdraw_msg_req.withdraw_msg_type = param.withdrawMsgType;
    if (param.groupName.length > 0 && param.groupName != nil) {
        strcpy(withdraw_msg_req.group_name, [param.groupName UTF8String]);
    }
    withdraw_msg_req.withdraw_msg_count = param.withdrawMsgCount;
    withdraw_msg_req.is_include_last_msg = param.isIncludeLastMsg;
    
//    NSArray *msgList = param.msgList;
    TSDK_S_MSG_BASE_INFO *baseInfo = malloc(param.withdrawMsgCount * sizeof(TSDK_S_MSG_BASE_INFO));
    memset_s(baseInfo, param.withdrawMsgCount * sizeof(TSDK_S_MSG_BASE_INFO), 0, param.withdrawMsgCount * sizeof(TSDK_S_MSG_BASE_INFO));
    for (int i = 0; i < param.withdrawMsgCount; i++) {
        TsdkMsgBaseInfo *msgBaseInfo = param.msgList[i];
        long long msgId = msgBaseInfo.msgId;
        baseInfo[i].msg_id = msgId;
    }
    withdraw_msg_req.withdraw_msg_list = baseInfo;
    
    TSDK_RESULT result = tsdk_withdraw_message(&withdraw_msg_req);
    
    if (TSDK_SUCCESS == result) {
        DDLogInfo(@"tsdk_withdraw_message,SUCCEEDED");
    }
}

- (void)moveFriendToNewGroupWithNewGroupId:(NSString *)newGroupId andContactId:(NSString *)contactId andAccount:(NSString *)account
{
    TSDK_S_CONTACT_MOVE_GROUP_REQ_PARAM req_param;
    memset(&req_param, 0, sizeof(TSDK_S_CONTACT_MOVE_GROUP_REQ_PARAM));
    req_param.id = [contactId longLongValue];
    req_param.new_group_id = [newGroupId  longLongValue];
    req_param.op_type = TSDK_E_CONTACT_MOVE_GROUP_MOVE_TO_NEW;
    req_param.old_group_id = [self.currentContactGroupId longLongValue];
    
    TSDK_RESULT result = tsdk_move_contact(&req_param);
    
    if (result == TSDK_SUCCESS) {
        dispatch_async(espace_coredata_management_queue, ^{
            ESpaceLocalDataManager * localManager = LOCAL_DATA_MANAGER;
            NSManagedObjectContext* bgCtx = [localManager backgroundObjectContext];
            [bgCtx performBlockAndWait:^{
                
                EmployeeEntity* newFriend = [self userWithAccount:account inContext:bgCtx];
                EmployeeCategoryEntity* tempTeam = [self employeeCategoryWithId:newGroupId inContext:bgCtx autoCreate:NO];
                EmployeeCategoryEntity* oldTempTeam = [self employeeCategoryWithId:self.currentContactGroupId inContext:bgCtx autoCreate:NO];
                if (![newFriend.isFriend boolValue]) {
                    newFriend.isFriend = [NSNumber numberWithBool:YES];
                }
                
                if (oldTempTeam.idx != nil) {
                    [newFriend removeCategoryObject:oldTempTeam];
                }
                if (tempTeam.idx != nil) {
                    [newFriend addCategoryObject:tempTeam];
                }
                
                [bgCtx saveToPersistent];
                
            }];
        });
    }
}

@end
