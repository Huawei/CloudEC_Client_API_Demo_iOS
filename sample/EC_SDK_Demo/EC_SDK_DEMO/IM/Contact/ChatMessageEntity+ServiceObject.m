//
//  ChatMessageEntity+ServiceObject.m
//  eSpace
//
//  Created by yemingxing on 8/10/15.
//  Copyright (c) 2015 www.huawei.com. All rights reserved.
//

#import "ChatMessageEntity+ServiceObject.h"
//#import "GroupEntity+ServiceObject.h"
#import "ChatSessionEntity+ServiceObject.h"
#import "MessageEntity+ServiceObject.h"
//#import "eSpaceIOSSDK.h"
#import "MessageEntity+ServiceObject.h"
#import "ESpaceIMessageService.h"
//#import "ESpaceContactService.h"
#import <objc/runtime.h>
//#import "PublicAccountMsgEntity+ServiceObject.h"
//#import "PublicAccountEntity+ServiceObject.h"
//#import "PublicAccountSessionEntity+ServiceObject.h"
//#import "PublicAccountMsgItemEntity+ServiceObject.h"
//#import "ECSFileManager.h"
#import "NSManagedObjectContext+Persistent.h"
//#import "eSpaceIOSService.h"
#import "ECSUtils.h"
//#import "ESpaceDetailMessagParser.h"
//#import "ESpaceEventRecordModel.h"
#import "ECSErrorCode.h"
#import "NSManagedObject+ECS_Utility.h"
#import "NSString+Transform.h"
#import "eSpaceDBService.h"
#import "ECSAppConfig.h"
#import "EmployeeEntity.h"

#import "ESpaceContactService.h"
#import "TsdkChatMessage.h"

@implementation ESpaceJSONMessage

- (instancetype)initWithContent:(NSString *)body
{
    if (self = [super init]) {
        NSDictionary* jsonDic = [NSJSONSerialization JSONObjectWithData:[body dataUsingEncoding:NSUTF8StringEncoding]
                                                                options:NSJSONReadingAllowFragments
                                                                  error:nil];
        for (NSString* key in [jsonDic keyEnumerator])
        {
            id value = [jsonDic valueForKey:key];
            SEL sel = NSSelectorFromString(key);
            if ([self respondsToSelector:sel]) {
                [self setValue:value forKeyPath:key];
            }
        }
    }
    return self;
}

- (NSString *)description {
    NSMutableDictionary* muteDic = [NSMutableDictionary dictionary];
    id clz = [self class];
    unsigned int outCount, i;
    objc_property_t * props = class_copyPropertyList(clz, &outCount);
    for (i = 0; i< outCount; ++i) {
        objc_property_t prop = props[i];
        NSString* propName = [NSString stringWithCString:property_getName(prop) encoding:NSUTF8StringEncoding];
        SEL propSel = NSSelectorFromString(propName);
        if ([self respondsToSelector:propSel]) {
            
            IMP imp = [self methodForSelector:propSel];
            id (*func)(id,SEL) = (void*)imp;
            id val = func(self,propSel);
            
            //id val = [self performSelector:propSel];
            if ([val conformsToProtocol:@protocol(NSCoding)]) {
                [muteDic setValue:val forKey:propName];
            }
            
        }
    }
    if (props) {
        free(props);
    }
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:muteDic options:0 error:nil];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

@end

@implementation ESpacePublicAccountMessage
//su TODO
//- (instancetype)initWithPublicAccountMsg:(PublicAccountMsgEntity *)paMsg forMessageItemIndex:(NSInteger)index
//{
//    if ([[paMsg messageItems] count] <= index)
//    {
//        return nil;
//    }
//    
//    if (self = [super init])
//    {
//        PublicAccountSessionEntity *session = (PublicAccountSessionEntity *)paMsg.session;
//        PublicAccountEntity *publicAccount = (PublicAccountEntity *)session.target;
//        PublicAccountMsgItemEntity *msgItem = [paMsg.messageItems objectAtIndex:index];
//        
//        _publicSource = paMsg.publicSource;
//        _publicAccount = publicAccount.contactId;
//        _publicName = publicAccount.name;
//        _title = msgItem.title;
//        _digest = msgItem.digest;
//        _mediaPath = msgItem.umRemoteURL;
//        _contentUrl = msgItem.contentURL;
//        _sourceUrl = msgItem.sourceURL;
//        _msgType = paMsg.contentType;
//    }
//    return self;
//}
//@synthesize umResource = _umResource;

//- (NSString *)mediaPath {
//    if (!_mediaPath) {
//        _mediaPath = [self.umResource description];
//    }
//    return _mediaPath;
//}

//- (void)setUmResource:(ESpaceUMResource *)umResource {
//    _umResource = umResource;
//    self.mediaPath = umResource.resourcePath;
//}

//- (ESpaceUMResource *)umResource {
//    if (!_umResource) {
//        _umResource = [[ESpaceUMResourceManager sharedInstance] umResourceFromString:self.mediaPath];
//    }
//    return _umResource;
//}

@end

@implementation ESpaceSharedLinkMessage
//@synthesize umResource = _umResource;

- (instancetype)init {
    if (self = [super init]) {
        self.accessMode = [NSNumber numberWithInteger:1];
    }
    return self;
}
//
//- (NSString *)imgUrl {
//    if (!_imgUrl) {
//        _imgUrl = [self.umResource description];
//    }
//    return _imgUrl;
//}

//- (void)setUmResource:(ESpaceUMResource *)umResource {
//    _umResource = umResource;
//    self.imgUrl = [umResource description];
//}

//- (ESpaceUMResource *)umResource {
//    if (!_umResource) {
//        _umResource = [[ESpaceUMResourceManager sharedInstance] umResourceFromString:self.imgUrl];
//    }
//    return _umResource;
//}
@end

@implementation ChatMessageEntity (ServiceObject)

- (BOOL) supportAction:(NSInteger) action {
    
    NSArray* umResource = [self umResources];
    if (action & ESpaceMessageCopy) {
        return umResource.count == 0;
    } else if (action & ESpaceMessageDelete) {
        return [self.transferStatus integerValue] != ESpaceMsgStatusSending;
    } else if (action & ESpaceMessageTransmit) {
        return YES;
    } else if (action & ESpaceMessageBatchOperation) {
        return YES;
    }else if (action & ESpacemessageRecall){
        EmployeeEntity *entity = (EmployeeEntity *)self.from;
        
        if ([self.transferStatus integerValue] == ESpaceMsgStatusSended && [entity isEqual:LOCAL_DATA_MANAGER.currentUser]) {
            return YES;
        }
    }
    return NO;
}

- (void) send:(void (^)(NSError* error)) completionBlock {
//    NSArray* umResources = [self umResources];
//    NSString* body = self.body;
//    NSManagedObjectID* oid = self.objectID;
//    NSInteger contentType = [self.contentType integerValue];
//    ESpaceLocalDataManager * localManager = LOCAL_DATA_MANAGER;

//    void (^resourceUploadead)(BOOL, BOOL) = ^(BOOL succeed, BOOL cancel) {
//        //jinlujinlu 可以返回url供拼装umresource，且umresource可传入！
//        NSArray* tokens = [[ESpaceDetailMessagParser sharedInstance] parseContent:body]; //jinlujinlu 重复解析多余！
//        NSMutableString* bodyContent = [NSMutableString string];
//        if (contentType == ESpacePublicAccountContentType
//            || contentType == ESpaceShareLinkContentType) {
//            NSData* jsonData = [body dataUsingEncoding:NSUTF8StringEncoding];
//            if (jsonData) {
//                NSDictionary* dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:nil];
//
//                ESpaceUMResource* umResource = [umResources lastObject];
//                if ([dic isKindOfClass:[NSDictionary class]]) {
//                    NSMutableDictionary* bodyDic = [NSMutableDictionary dictionaryWithDictionary:dic];
//                    if (contentType == ESpacePublicAccountContentType) {
//                        [bodyDic setValue:[umResource description] forKey:@"mediaPath"];
//                    }
//                    else if (contentType == ESpaceShareLinkContentType) {
//                        [bodyDic setValue:[umResource description] forKey:@"imgUrl"];
//                    }
//                    jsonData = [NSJSONSerialization dataWithJSONObject:bodyDic options:NSJSONWritingPrettyPrinted error:nil];
//                    [bodyContent appendString:[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]];
//                }
//            }
//        } else {
//            for (ECSControl* control in tokens) {
//                if ([control isKindOfClass:[ESpaceUMPlaceHolder class]]) {
//                    ESpaceUMPlaceHolder* placeHolder = (ESpaceUMPlaceHolder*)control;
//                    [bodyContent appendString:[placeHolder.umResource description]];
//                } else {
//                    [bodyContent appendString:control.text];
//                }
//            }
//        }
//
//        NSManagedObjectContext* bgCtx = [localManager backgroundObjectContext];
//        [bgCtx performBlock:^{
//            ChatMessageEntity* chatMessage = (ChatMessageEntity*)[bgCtx objectWithID:oid];
//            if (chatMessage.managedObjectContext && !chatMessage.isDeleted) {
//                if (succeed) {
//                    chatMessage.body = bodyContent;
//                    //                [bgCtx save:nil];
//                    [bgCtx saveToPersistent];
//                    [chatMessage sendBody:completionBlock];
//                } else {
//                    chatMessage.body = bodyContent;
//                    chatMessage.transferStatus = [NSNumber numberWithInteger:cancel ? ESpaceMsgStatusSendCancelled : ESpaceMsgStatusSendFailed];
//                    //                [bgCtx save:nil];
//                    [bgCtx saveToPersistent];
//                    if (completionBlock) {
//                        NSError* error = [NSError errorWithDomain:ECSInstantMessageErrorDomain
//                                                             code:ECSInstantMessageResourceUploadError
//                                                         userInfo:nil];//
//                        completionBlock(error);
//                    }
//                }
//            } else {
//                if (completionBlock) {
//                    NSError* error = [NSError errorWithDomain:ECSInstantMessageErrorDomain
//                                                         code:ECSInstantMessageResourceUploadError
//                                                     userInfo:nil];
//                    completionBlock(error);
//                }
//            }
//        }];
//    };

    self.transferStatus = [NSNumber numberWithInteger:ESpaceMsgStatusSending];
    if (self.managedObjectContext.concurrencyType != NSMainQueueConcurrencyType) {
        [self.managedObjectContext save:nil];
    }

//    if ([umResources count] > 0) {
//
//        for (ESpaceUMResource* resource in umResources) {
//            if ([resource needUpload] && resource.umStatus == ESpaceUMStatusUploading) {
//                //DDLogWarn(@"message um resource is uploading, wait last sending finish."); //su TODO
//                if (completionBlock) {
//                    NSError* error = [NSError errorWithDomain:ECSInstantMessageErrorDomain
//                                                         code:ECSInstantMessageResourceUploadError
//                                                     userInfo:nil];
//                    completionBlock(error);
//                }
//                return;
//            }
//        }
//
//        __block NSInteger succeedCount = 0;
//        __block NSInteger failedCount = 0;
//
//        for (ESpaceUMResource* umResource in umResources) {
//            if (![umResource remoteResource]) {
//                [umResource upload:^(NSError *error) {
//                    if (!error) {
//                        [ChatMessageEntity moveEncUMResource:umResource];
//                        succeedCount ++;
//                    } else {
//                        failedCount ++;
//                    }
//                    if (succeedCount + failedCount == [umResources count]) {
//                        resourceUploadead(failedCount == 0, error.code == ECSCommonMAACancelledError);
//                    }
//                }];
//            } else {
//                ++ succeedCount;
//                if (succeedCount + failedCount == [umResources count]) {
//                    resourceUploadead(failedCount == 0, NO);
//                }
//            }
//        }
//    } else {
        [self sendBody:completionBlock];
//    }

}


//- (void) recallMessage:(void (^)(NSError* error)) completionBlock{
//    //NSArray* umResources = [self umResources];
//    //NSManagedObjectID* oid = self.objectID;
//    NSString *messageId = self.messageId;
//    ESpaceLocalDataManager * localManager = LOCAL_DATA_MANAGER;
//
//    NSUInteger flag = 0;  //标记p2p消息或群组消息 1:p2p消息 2:群组消息
//    ContactEntity *contact = self.to;
//    if ([contact isKindOfClass:[GroupEntity class]]) {
//        flag = 2;   //群组消息
//    }else{
//        flag = 1;   //p2p消息
//    }
//
//
//    [self withdrawSelfMessageWithType:flag completion:^(NSError *error) {
//        if (!error) {
//            //删除本地entity
//            //NSManagedObjectID* oid = self.objectID;
//            dispatch_async(espace_coredata_management_queue, ^{
//                NSManagedObjectContext* bgCtx = [localManager backgroundObjectContext];
//                [bgCtx performBlockAndWait:^{
//                    //ChatMessageEntity* shadow = (ChatMessageEntity*) [bgCtx objectWithID:oid];
//                    //NSArray *msgArr =
//                    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"messageId=%@ AND flag=%@",messageId,[NSNumber numberWithInteger:ESpaceMessageFlagNormal]];
//                    NSArray *arr = [ESpaceLocalDataManager fetchObjects:predicate inEnitity:@"ChatMessageEntity" inContext:bgCtx];
//                    if (arr && [arr count] > 0) {
//                        ChatMessageEntity *message = (ChatMessageEntity *)[arr objectAtIndex:0];
//                        if (message && [message canFillFault]) {
//                            ChatSessionEntity *session = message.to.chatSession;
//                            ChatMessageEntity* msgEntity = [[ESpaceIMessageService sharedInstance] createMessageForSession:message.to.chatSession timestamp:message.receiveTimestamp flag:ESpaceMessageFlagRecalled readed:YES];
//                            //msgEntity.messageId = shadow.messageId;
//                            //msgEntity.dataBaseId = shadow.dataBaseId;
//                            msgEntity.from = message.from;
//                            msgEntity.to = message.to;
//                            msgEntity.flag = [NSNumber numberWithInteger:ESpaceMessageFlagRecalled];
//                            msgEntity.body = [NSString stringWithFormat:ECSLocalizedString(@"opr_msg_withdraw_hint",nil),ECSLocalizedString(@"opr_msg_withdraw_you",nil)];
//                            msgEntity.receiveTimestamp = message.receiveTimestamp;
//
//                            ESpaceUMResource *resource = [message.umResources lastObject];
//                            if ([resource localExites]) {
//                                if ([resource isKindOfClass:[ESpaceUMAudioResource class]]) {
//                                    ESpaceUMAudioResource *audio = (ESpaceUMAudioResource *)resource;
//                                    dispatch_async(dispatch_get_main_queue(), ^{
//                                        [audio stop];
//                                    });
//                                }
//                            }
//                            NSSet *revokset = [NSSet setWithArray:arr];
//                            [session localDeleteMessages:revokset];
//                            if ([bgCtx hasChanges]) {
//                                [bgCtx save:nil];
//                            }
//                            [bgCtx saveToPersistent];
//                        }
//                    }
//                }];
//            });
//
//            if (completionBlock) {
//                completionBlock(nil);
//            }
//        }else{
//            completionBlock(error);
//        }
//    }];
//}

//撤回消息
//- (void)withdrawSelfMessageWithType:(NSUInteger)type completion:(void (^)(NSError* error))completionBlock{
//    ECSOprMsg *opt = [[ECSOprMsg alloc] init];
//    opt.ActionType = @"OprMsg";
//    opt.user = [[ECSAppConfig sharedInstance] currentUser].account;
//    opt.oprType = 0; //0:withDraw
//    opt.messageType = type;
//    if ([self.from isKindOfClass:[EmployeeEntity class]]) {
//        EmployeeEntity *employ = (EmployeeEntity *)self.from;
//        opt.sender = employ.account;
//    }
//    if ( 1 == type) {
//        //p2p消息，target填对方的账号
//        EmployeeEntity *toPeople = (EmployeeEntity *)self.to;
//        opt.targetId = toPeople.account;
//    }else if ( 2 == type){
//        GroupEntity *toGroup = (GroupEntity *)self.to;
//        opt.targetId = toGroup.contactId;
//    }
//    opt.msgIDList = [NSArray arrayWithObject:self.messageId];
//    opt.lastMsgFlag = 0;
//    //
//    NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:@"ChatMessageEntity"];
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"session=%@ AND flag=%@ AND transferStatus=%@", self.session,[NSNumber numberWithInteger:ESpaceMessageFlagNormal],[NSNumber numberWithInteger:ESpaceMsgStatusSended]];
//    NSSortDescriptor *msgTimeDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"receiveTimestamp" ascending:NO];
//    [request setPredicate:predicate];
//    [request setSortDescriptors:@[msgTimeDescriptor]];
//    [request setFetchLimit:1];
//    NSError* reqError = nil;
//    NSArray* result = [[LOCAL_DATA_MANAGER managedObjectContext] executeFetchRequest:request error:&reqError];
//
//    if (!reqError || [result count] > 0) {
//        ChatMessageEntity *entity = (ChatMessageEntity *)[result lastObject];
//        if (![entity.messageId isEqualToString:self.messageId]) {
//            opt.lastMsgFlag = 1;
//        }
//    }
//
//    [[ESpaceIMessageService sharedInstance].imessageService oprMsgWithRequest:opt completionBlock:^(ECSOprMsgAck *retMsg, NSError *error) {
//        if (!error) {
//            if (completionBlock) {
//                completionBlock(nil);
//            }
//        }else{
//            NSError *retError = nil;
//            NSInteger timoutCount = 0;
//            NSNumber *overTime = nil;
//
//            if (ECSCommonRecallMessageTimeOutError == retMsg.retval) {
//                //超过撤回时间
//                timoutCount = retMsg.timeoutInfo;
//                overTime = [NSNumber numberWithInteger:timoutCount];
//                NSDictionary *userInfo = [NSDictionary dictionaryWithObject:overTime forKey:ECSRecallMessageTimeOutKey];
//                retError = [[NSError alloc] initWithDomain:ECSRecallMessageTimeOutErrorDomain code:ECSCommonRecallMessageTimeOutError userInfo:userInfo];
//            }else{
//                timoutCount = retMsg.timeoutInfo;
//                overTime = [NSNumber numberWithInteger:timoutCount];
//                NSDictionary *userInfo = [NSDictionary dictionaryWithObject:overTime forKey:ECSRecallMessageTimeOutKey];
//                retError = [[NSError alloc] initWithDomain:ECSCommonErrorDomain code:ECSCommonMaaUndefinedError userInfo:userInfo];
//            }
//
//            if (completionBlock) {
//                completionBlock(retError);
//            }
//        }
//    }];
//
//}


//+ (BOOL) moveEncUMResource:(ESpaceUMResource*)umResource {
//    BOOL bEncSucceded = YES;
//    if ([umResource needEncrypt]) {
//        NSString* orgFilePath = umResource.localFilePath;
//        NSString* tmpFilePath = [orgFilePath stringByAppendingPathExtension:@"tmp"];
//        if ([[NSFileManager defaultManager] moveItemAtPath:orgFilePath toPath:tmpFilePath error:nil]) {
//            bEncSucceded = [[ECSFileManager defaultManager] encryptPlainFile:tmpFilePath toPath:orgFilePath];
//            if (bEncSucceded) {
//                [[NSFileManager defaultManager] removeItemAtPath:tmpFilePath error:nil];
//                if ([umResource isKindOfClass:[ESpaceUMImgResource class]]) {
//                    ESpaceUMImgResource* umImageResource = (ESpaceUMImgResource*)umResource;
//                    
//                    NSString* orgThumbFilePath = umImageResource.localThumbFilePath;
//                    NSString* tmpThumbFilePath = [orgThumbFilePath stringByAppendingPathExtension:@"tmp"];
//                    [[NSFileManager defaultManager] moveItemAtPath:orgThumbFilePath toPath:tmpThumbFilePath error:nil];
//                    bEncSucceded = [[ECSFileManager defaultManager] encryptPlainFile:tmpThumbFilePath toPath:orgThumbFilePath];
//                    if (bEncSucceded) {
//                        [[NSFileManager defaultManager] removeItemAtPath:tmpThumbFilePath error:nil];
//                    }
//                }
//            } else {
//                [[NSFileManager defaultManager] moveItemAtPath:tmpFilePath toPath:orgFilePath error:nil];
//            }
//        }
//    }
//    return bEncSucceded;
//}

- (void) sendBody:(void (^)(NSError* error)) completionBlock {

    ContactEntity* to = self.to;
    if (!self.messageId) {
        self.messageId = [LOCAL_DATA_MANAGER randomMessageId];
    }

//    if ([to isGroupEntity]) {
//        [self sendToGroup:completionBlock];
//    } else {
    [self sendToPerson:[to isGroupEntity] completion:completionBlock];
//    }
}

- (void) sendToPerson:(BOOL)isPerson completion:(void (^)(NSError* error)) completionBlock {
    
    TsdkSendChatMsgInfo *sendInfo = [[TsdkSendChatMsgInfo alloc] init];
    if (isPerson) {
        GroupEntity *group = (GroupEntity *)self.to;
        if ([group.groupType intValue] == ECSFixGroup) {
            sendInfo.chatType = TSDK_E_CHAT_MSG_TYPE_FIXED_GROUP;
        }else{
            sendInfo.chatType = TSDK_E_CHAT_MSG_TYPE_TEMP_GROUP;
        }
        sendInfo.groupId = group.contactId;
        
    }else{
        sendInfo.chatType = TSDK_E_CHAT_MSG_TYPE_SINGLE_CHAT;
        sendInfo.target = ((EmployeeEntity *)self.to).account;
    }
    
    sendInfo.chatMediaType = TSDK_E_CHAT_MSG_MEDIA_TYPE_TEXT;
    sendInfo.sourceType = TSDK_E_CHAT_MSG_SOURCE_IM_DIALOG;
    sendInfo.origin = LOCAL_DATA_MANAGER.userAccount;
    
    sendInfo.content = self.body;
    sendInfo.clientChatId = [self.messageId longLongValue];
    
    [[ESpaceContactService sharedInstance] sendMessageWithMessage:sendInfo completion:^(TsdkSendChatMsgResult *result ,NSError *error) {
            ESpaceLocalDataManager * localManager = LOCAL_DATA_MANAGER;
            NSManagedObjectID* oid = self.objectID;
            NSManagedObjectContext* bgCtx = [localManager backgroundObjectContext];
            [bgCtx performBlock:^{
                
                MessageEntity* message = (MessageEntity*)[bgCtx objectWithID:oid];
                if ([message canFillFault]) {
                    if (error) {
                        message.transferStatus = [NSNumber numberWithUnsignedInteger:ESpaceMsgStatusSendFailed];
                    } else {
                        //NSArray* umResources = [message umResources];
                        message.transferStatus = [NSNumber numberWithUnsignedInteger:ESpaceMsgStatusSended];
                        message.messageId = [NSString stringWithFormat:@"%lld", result.serverMsgId];
                        if (result.utcStamp != 0) {
                            message.receiveTimestamp = [ECSUtils dateFromMillisecondUTCValue:result.utcStamp];
                            [message.session updateLatestMessage];//解决本地时间与服务器时间不一致时最后一条记录显示错误的问题
                        }
                    }
                    [bgCtx saveToPersistent];
                }
                
                if (completionBlock) {
                    completionBlock(error);
                }
                
            }];
    }];
    
    
//    ECSChatMessage* msg = [[ECSChatMessage alloc] init];
//    msg.from = [ECSAppConfig sharedInstance].currentUser.account;//self.from.contactId;
//    msg.to = self.to.contactId;
//    msg.body = self.body;
//    msg.type = @"chat";
//    msg.contentType = [self.contentType unsignedIntegerValue];
//    msg.body_id = self.messageId;
//    msg.msgEx = self.msgEx;
//    msg.appName = self.appName;
//    msg.appID = self.appID;
//    msg.senderType = [self.senderType integerValue];
//    NSManagedObjectID* oid = self.objectID;
//    self.transferStatus = [NSNumber numberWithUnsignedInteger:ESpaceMsgStatusSending];
//
//    long long startTime = ( long long)[[NSDate date] timeIntervalSince1970]*1000;
//    ESpaceLocalDataManager * localManager = LOCAL_DATA_MANAGER;
//    [[ESpaceIMessageService sharedInstance].imessageService chatMessageWithRequest:msg completionBlock:^(ECSChatMessageAck *retMsg, NSError *error) {
//        NSManagedObjectContext* bgCtx = [localManager backgroundObjectContext];
//        [bgCtx performBlock:^{
//
//            if (error ) { //it is fail then record.
//                NSTimeInterval nowTime = [[NSDate date] timeIntervalSince1970]*1000;
//                long long  offsetTime = ( long long)nowTime - startTime;
//                //su TODO
////                if ((offsetTime > 0))
////                    [[ESpaceEventRecordModel shareEventRecordModel]  recordCapabilityWithId:CAPABLE_FAILED_SEND_MSG_ID withDuration:(NSInteger)offsetTime ];
//            }
//
//            NSMutableArray *messageList = [[NSMutableArray alloc] init];
//            MessageEntity* message = (MessageEntity*)[bgCtx objectWithID:oid];
//            if ([message canFillFault]) {
//                if (error) {
//                    message.transferStatus = [NSNumber numberWithUnsignedInteger:ESpaceMsgStatusSendFailed];
//                } else {
//                    //NSArray* umResources = [message umResources];
//                    message.transferStatus = [NSNumber numberWithUnsignedInteger:ESpaceMsgStatusSended];
//                    message.messageId = retMsg.id;
//                    if (retMsg.time != 0) {
//                        message.receiveTimestamp = [ECSUtils dateFromMillisecondUTCValue:retMsg.time];
//                        [message.session updateLatestMessage];//解决本地时间与服务器时间不一致时最后一条记录显示错误的问题
//                    }
//                }
//                [bgCtx saveToPersistent];
//                [messageList addObject:message.objectID];
//            }
//
//            if (completionBlock) {
//                completionBlock(error);
//            }
//            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//                [[NSNotificationCenter defaultCenter] postNotificationName:JSAPIReceiveMessagesNotify
//                                                                    object:nil
//                                                                  userInfo:@{JSAPIReceiveMessagesNotifyKey : messageList,
//                                                                             JSAPIReceiveMessagesInterfaceKey : [NSNumber numberWithInteger:RecMessageInterfaceUnknow]}];
//            });
//        }];
//    }];
}

//- (void) sendToGroup:(void (^)(NSError* error)) completionBlock {
//    GroupEntity* group = (GroupEntity*) self.to;
//    ECSGroupMsg* groupMsg = [[ECSGroupMsg alloc] init];
//
//    groupMsg.from = self.from.contactId;
//    groupMsg.to = self.to.contactId;
//    groupMsg.body = self.body;
//    groupMsg.type = @"groupchat";
//    groupMsg.owner = group.ownerId;
//    groupMsg.id = self.messageId;
//    groupMsg.contentType = [self.contentType integerValue];
//    groupMsg.msgEx = self.msgEx;
//    groupMsg.appID = self.appID;
//    groupMsg.appName = self.appName;
//    groupMsg.senderType = [self.senderType integerValue];
//
//    if ([self.at count] > 0) {
//        NSMutableArray* atUserList = [NSMutableArray array];
//        for (EmployeeEntity* atUser in self.at) {
//            [atUserList addObject:@{@"account":atUser.account}];
//        }
//        NSData* jsonData = [NSJSONSerialization dataWithJSONObject:atUserList options:0 error:nil];
//        NSString* atUsers = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
//        groupMsg.atUserList = atUsers;
//    }
//    NSManagedObjectID* oid = self.objectID;
//    self.transferStatus = [NSNumber numberWithUnsignedInteger:ESpaceMsgStatusSending];
//
//    long long startTime = ( long long)[[NSDate date] timeIntervalSince1970]*1000;
//    ESpaceLocalDataManager * localManager = LOCAL_DATA_MANAGER;
//    [[ESpaceIMessageService sharedInstance].imessageService sendGroupMsgWithRequest:groupMsg completionBlock:^(ECSSendGroupMsgAck *retMsg, NSError *error) {
//
//        //added by  wwx276172
//        if (error ) { //it is fail then record.
//            NSTimeInterval nowTime = [[NSDate date] timeIntervalSince1970]*1000;
//            long long  offsetTime = ( long long)nowTime - startTime;
//
////            if ((offsetTime > 0))
////                [[ESpaceEventRecordModel shareEventRecordModel]  recordCapabilityWithId:CAPABLE_FAILED_SEND_MSG_ID withDuration:(NSInteger)offsetTime ];
//        }
//
//        NSManagedObjectContext* bgCtx = [localManager backgroundObjectContext];
//        [bgCtx performBlock:^{
//            NSMutableArray *messageList = [[NSMutableArray alloc] init];
//            MessageEntity* message = (MessageEntity*)[bgCtx objectWithID:oid];
//            if ([message canFillFault]) {
//                if (error) {
//                    message.transferStatus = [NSNumber numberWithUnsignedInteger:ESpaceMsgStatusSendFailed];
//                } else {
//                    //NSArray* umResources = [message umResources];
//                    message.transferStatus = [NSNumber numberWithUnsignedInteger:ESpaceMsgStatusSended];
//                    message.messageId = retMsg.id;
//                    if (retMsg.time != 0) {
//                        message.receiveTimestamp = [ECSUtils dateFromMillisecondUTCValue:retMsg.time];
//                        [message.session updateLatestMessage];//解决本地时间与服务器时间不一致时最后一条记录显示错误的问题
//                    }
//                }
//                [messageList addObject:message.objectID];
//            }
////            if ([bgCtx hasChanges]) {
////                [bgCtx save:nil];
////            }
//            [bgCtx saveToPersistent];
//            if (completionBlock) {
//                completionBlock(error);
//            }
//
//            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//                [[NSNotificationCenter defaultCenter] postNotificationName:JSAPIReceiveMessagesNotify
//                                                                    object:nil
//                                                                  userInfo:@{JSAPIReceiveMessagesNotifyKey : messageList,
//                                                                             JSAPIReceiveMessagesInterfaceKey : [NSNumber numberWithInteger:RecMessageInterfaceUnknow]}];
//            });
//        }];
//
//    }];
//}



- (ESpaceContentType)contentTypeFromServerValue:(NSInteger)typeValue content:(NSString*)body{
    ESpaceContentType type = ESpaceTextContentType;
//    NSArray* tokens = [[ESpaceDetailMessagParser sharedInstance] parseContent:body];

    switch (typeValue) {
        case 0://纯文本
        case 1://语音
        case 2://视频
        case 3://图片
        case 4://文件
        case 8:{//图文混排子消息
//            //此处不直接使用服务器下发的value，而是自己解析后赋值，原因是防止服务器内容与类型值不对应
//            if (tokens.count == 1) {
//                NSObject* token = [tokens lastObject];
//                if ([token isKindOfClass:[ESpaceUMPlaceHolder class]]) {
//                    ESpaceUMPlaceHolder* control = (ESpaceUMPlaceHolder*) token;
//                    switch (control.umResource.umType) {
//                        case ESpaceUMTypeFile:
//                            type = ESpaceFileContentType;
//                            break;
//                        case ESpaceUMTypeAudio:
//                            type = ESpaceAudioContentType;
//                            break;
//                        case ESpaceUMTypeImage:
//                            type = ESpaceImageContentType;
//                            break;
//                        case ESpaceUMTypeVideo:
//                            type = ESpaceVideoContentType;
//                            break;
//                        default:
//                            break;
//                    }
//                }
//            }
            break;
        }
        case 5:
            type = ESpacePublicAccountContentType;
            break;
        case 6:
//            type = ESpaceUnknowContentType;
            break;
        case 7:
            type = ESpaceShareLinkContentType;
            break;
        case 10:
            type = ESpaceCardMsgSharedType;
            break;
        default:
            type = typeValue;
            break;
    }

    return type;
}

//- (ESpaceContentType) typeFromContent:(NSString*) body {
//    ESpaceContentType type = ESpaceTextContentType;
//    NSArray* tokens = [[ESpaceDetailMessagParser sharedInstance] parseContent:body];
//    if (tokens.count == 1) {
//        NSObject* token = [tokens lastObject];
//        if ([token isKindOfClass:[ESpaceUMPlaceHolder class]]) {
//            ESpaceUMPlaceHolder* control = (ESpaceUMPlaceHolder*) token;
//            switch (control.umResource.umType) {
//                case ESpaceUMTypeFile:
//                    type = ESpaceFileContentType;
//                    break;
//                case ESpaceUMTypeAudio:
//                    type = ESpaceAudioContentType;
//                    break;
//                case ESpaceUMTypeImage:
//                    type = ESpaceImageContentType;
//                    break;
//                case ESpaceUMTypeVideo:
//                    type = ESpaceVideoContentType;
//                    break;
//                default:
//                    break;
//            }
//        }
//    } else {
//        BOOL bRichText = NO;
//        for (NSObject* control in tokens) {
//            if ([control isKindOfClass:[ESpaceUMPlaceHolder class]]) {
//                bRichText = YES;
//                break;
//            }
//        }
//        if (bRichText) {
//            //type = ESpaceRtfContentType;
//        }
//    }
//    return type;
//}

- (void)markReadDetail {
    NSManagedObjectID *oid = self.objectID;
    ESpaceLocalDataManager * localManager = LOCAL_DATA_MANAGER;
    dispatch_async(espace_coredata_management_queue, ^{
        NSManagedObjectContext* ctx = [localManager backgroundObjectContext];
        [ctx performBlockAndWait:^{
            ChatMessageEntity* message = (ChatMessageEntity*)[ctx objectWithID:oid];
            if (message.managedObjectContext && !message.isDeleted) {
                message.readDetail = [NSNumber numberWithBool:YES];
                if ([ctx hasChanges]) {
                    [ctx save:nil];
                }
            }
        }];
    });
}

- (ChatMessageEntity *)nextUnreadDetailMessage {
    NSManagedObjectContext *context = self.managedObjectContext;
    NSPredicate* nextPredicate = [NSPredicate predicateWithFormat:@"session=%@ AND from=%@ AND contentType=1 AND readDetail=0 AND messageId>%@", self.session, self.from, self.messageId];
    NSSortDescriptor *timestampDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"receiveTimestamp" ascending:YES];
    NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:@"ChatMessageEntity"];
    [request setPredicate:nextPredicate];
    [request setSortDescriptors:@[timestampDescriptor]];
    [request setFetchLimit:1];
    
    __block NSArray* results = nil;
    [context performBlockAndWait:^{
        NSError * error = nil;
        results = [context executeFetchRequest:request error:&error];
    }];
    
    return [results lastObject];
}

- (void)markReadToServer {
    ChatSessionEntity* chatSession = (ChatSessionEntity*)self.session;
    if (chatSession) {
        MsgMarkReadType readType = [chatSession.target isGroupEntity] ? MsgMarkReadForGroup : MsgMarkReadForIM;
        NewMsgMarkReadType newType = readType == MsgMarkReadForGroup ? NewMsgMarkRead_Group : NewMsgMarkRead_IM;
        NSString * targetId = self.from.contactId;
        NSString * msgId = self.messageId;
        
        [[ESpaceIMessageService sharedInstance] markReadRequest:readType targetId:targetId msgId:msgId newMsgType:newType];
    }
}

- (BOOL)needShowPopMenu
{
    return YES;
}
//
// 敏感词过滤，此处还需特殊考虑是否为富媒体链接(待完成)
-(void)checkSensitivewWords
{
    NSString *originMsgBody = self.body;
    NSString* filterBody = [[ESpaceIMessageService sharedInstance] filterSensitiveWords:originMsgBody];
    if (NO == [filterBody isEqualToString:originMsgBody]) {
        self.body = filterBody;

        if (self.session == nil) {
            //DDLogWarn(@"message's session error");  //su TODO
            return;
        }
        ChatMessageEntity *filterMsg = [[ESpaceIMessageService sharedInstance] createMessageForSession:self.session
                                                                                             timestamp:[NSDate date]
                                                                                                readed:YES];
        filterMsg.flag = [NSNumber numberWithInteger:ESpaceMessageFlagSensitiveWord];
        filterMsg.receiveTimestamp = [NSDate date];
        filterMsg.body = ECSLocalizedString(@"sensitive_prompt", @"发送内容包含敏感词");
    }
}

// 群组消息时需检查有没有@对象;
- (void)checkAtPerson
{
    if (![self.session isKindOfClass:[ChatSessionEntity class]]) {
        //DDLogWarn(@"session type no match");   //su TODO
        return;
    }
    
    ContactEntity *contact = [(ChatSessionEntity *)self.session target];
    if ([contact isGroupEntity]) {
        NSArray *acounts = [self.body atPersonListWithGroup:(GroupEntity *)contact inText:self.body];
        for (NSString* account in acounts) {
            EmployeeEntity* employee = [[ESpaceContactService sharedInstance] userWithAccount:account inContext:self.managedObjectContext autoCreate:YES];
//            EmployeeEntity* employee = [TUPMediator_ContactService M_userWithAccount:account inContext:self.managedObjectContext autoCreate:YES];
            [self addAtObject:employee];
        }
    }
}

@end
