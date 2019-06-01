//
//  ESpaceIMessageService.h
//
//  * Copyright(C), 2012-2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

#import <Foundation/Foundation.h>
#import "ChatSessionEntity.h"
#import "ContactEntity.h"
#import "ECSafeMutableDictionary.h"
#import "ChatMessageEntity.h"
#import "ECSDefines.h"
#import "DeptSessionEntity.h"
//#import "ECSOprCommandService.h"
//#import "ECSIMessagingService.h"
//#import "ECSOprCommandService.h" //su TODO
#define DEPARTMENT_SESSION_LOCAL_ID    @"DEPARTMENT_SESSION_LOCAL_ID"
#define DEPARTMENT_SESSION_ROAMING_ID  @"DEPARTMENT_SESSION_ROAMING_ID"

//新系统公告通知
ECS_EXTERN NSString* const ESPACE_NEW_BULLETIN_NOTIFY;
//收到点对点聊天消息
ECS_EXTERN NSString* const ESPACE_RECEIVE_SINGLE_MESSAGE_NOTIFY;
//收到群组聊天消息
ECS_EXTERN NSString* const ESPACE_RECEIVE_GROUP_MESSAGE_NOTIFY;
//消息通知键值,value:NSManagedObjectID
ECS_EXTERN NSString* const ESPACE_RECEIVE_MESSAGE_NOTIFY_KEY;
//收到部门通知消息
ECS_EXTERN NSString* const ESPACE_RECEIVE_DEPT_MESSAGE_NOTIFY;
//消息撤回通知
ECS_EXTERN NSString* const ESPACE_MESSAGE_RECALLED_NOTIFY;//ESPACE_RECEIVE_DEPT_MESSAGE_NOTIFY_KEY
//消息撤回通知key
ECS_EXTERN NSString* const ESPACE_MESSAGE_RECALLED_NOTIFY_KEY;
ECS_EXTERN NSString* const ESPACE_MESSAGE_RECALLED_NOTIFY_MSGSTATE_KEY;
ECS_EXTERN NSString* const ESPACE_MESSAGE_RECALLED_MEDIA_UM_NOTIFY_KEY;
ECS_EXTERN NSString* const ESPACE_MESSAGE_RECALLED_FILE_UM_NOTIFY_KEY;
//清空聊天记录通知
ECS_EXTERN NSString* const ESPACE_CLEAR_ALL_MESSAGE_NOTIFY;

// 从服务器接收到消息通知（群组消息,个人消息）
ECS_EXTERN NSString * const JSAPIReceiveMessagesNotify;
ECS_EXTERN NSString * const JSAPIReceiveMessagesNotifyKey;
ECS_EXTERN NSString * const JSAPIReceiveMessagesInterfaceKey;// enum RecMessageInterface
ECS_EXTERN NSString * const JSAPIReceiveMessagesListKey;

typedef NS_ENUM(NSInteger, RecMessageInterface) {
    RecMessageInterfaceUnknow = 0,
    RecMessageInterfaceGroupMsgNotify = 1,
    RecMessageInterfaceChatMsgNotify = 2,
    RecMessageInterfaceUnreadNotify = 3
};

typedef enum
{
    MsgMarkReadForIM	= 1,//单聊IM
    MsgMarkReadForGroup = 2,//群聊IM
    MsgMarkReadForOther = 6 //其它消息（系统公告、部门通知、固定群邀请等群组消息、UMS传真通知、好友提示）
}MsgMarkReadType;//仅支持沙特版本

typedef enum {
    NewMsgMarkRead_IM           = 0,//单聊
    NewMsgMarkRead_Group        = 1,//固定群/讨论组IM消息
    NewMsgMarkRead_SMS          = 2,//短信
    NewMsgMarkRead_SystemNotice = 3,//系统公告
    NewMsgMarkRead_Other        = 4 //其它（P2P文件传输、好友邀请、群组邀请、群组通知）
}NewMsgMarkReadType;//基线版本

typedef NS_ENUM(NSInteger, ESpaceRoamingMessageType) {
    ESpaceRoamingMessage_Single = 1,
    ESpaceRoamingMessage_Group  = 2
};

@interface ESpaceIMessageService : NSObject/*<ECSOprCommandServiceDelegate,ECSIMessagingServiceDelegate>*/
//@property (nonatomic, strong) ECSIMessagingService* imessageService;
@property (nonatomic, strong, readonly) ECSafeMutableDictionary* validSessions;

+ (instancetype) sharedInstance;

+ (DeptSessionEntity*)localDeptSessionEntityWithContext:(NSManagedObjectContext*)
    context;

+ (DeptSessionEntity*)roamingDeptSessionEntityWithContext:(NSManagedObjectContext*)context;

- (ChatMessageEntity*) createMessageForSession:(SessionEntity*) session
                                     timestamp:(NSDate*) date
                                          flag:(NSInteger) flag
                                        readed:(BOOL) readed;

- (ChatMessageEntity*) createMessageForSession:(SessionEntity*) session
                                 timestamp:(NSDate*) date
                                    readed:(BOOL) readed;

/**
 *  [en]
 *  [cn]向服务器置消息已读
 *
 *  @param session 聊天对象
 */
- (void) markRead:(SessionEntity*) session;

/**
 *  [en]
 *  [cn]批量置本地未读消息为已读,非异步操作
 *
 *  @param session 聊天对象
 */
- (void) markReadLocal:(SessionEntity *)session;

/**
 *  [en]
 *  [cn]专门针对聊天消息置已读
 *
 *  @param session 聊天对象
 */
- (void)MarkReadMessageRequest:(ChatSessionEntity*)session message:(ChatMessageEntity*)chatMsg;

/**
 *  [en]
 *  [cn]专门针对第三方点对点消息置已读
 *
 *  @param session 聊天对象
 */
- (void)MarkReadP2PMessageForTHirdPartyRequest:(ChatSessionEntity*)session message:(ChatMessageEntity*)chatMsg;

/* targetId : 对端帐号或固定群ID ,如果类型为MsgMarkReadForOther,则不需传此参数*/
/**
 *  [en]
 *  [cn]置消息已读
 *
 *  @param type     消息类型，仅适用沙特项目
 *  @param targetId type=1,newType=0时填对方的eSpace账号；
                    type=2,newType=1时填群组ID
 *  @param msgId    消息ID
 *  @param newType  消息类型，适用基线功能，不包含沙特
 */
- (void)markReadRequest:(MsgMarkReadType)type
                   targetId:(NSString *)targetId
                      msgId:(NSString *)msgId
                 newMsgType:(NewMsgMarkReadType)newType;

/**
 *  [en]
 *  [cn]置消息已读接口
 *
 *  @param targetId type=1,newType=0时填对方的eSpace账号；
                    type=2,newType=1时填群组ID
 *  @param msgId    消息ID
 *  @param type     消息类型
 */
- (void)markReadRequestWithTargetId:(NSString *)targetId
                              msgId:(NSString *)msgId
                            msgType:(NewMsgMarkReadType)type;

/**
 *  [en]
 *  [cn]敏感词过滤
 *
 *  @param inputString 过滤后的字符串
 */
- (NSString*)filterSensitiveWords:(NSString *)inputString;

/**
 *  [en]
 *  [cn]删除消息
 *
 *  @param messages        要删除的MessageEntity数组（为空表示全部删除）
 *  @param messages        MessageEntity的session(messages可能为空）
 *  @param target          contactentity对象
 *  @param completionBlock 回调
 */
- (void) deleteMessages:(NSArray*) messages
                session:(SessionEntity*) session
                 target:(ContactEntity*)target
        completionBlock:(void (^)(NSError* error)) completionBlock;

/**
 *  [en]
 *  [cn]将发送中的消息置为失败,包括IM、topic、comment、publicAccount message
 */
- (void) markSendingMessageToFailed;

#pragma mark 漫游消息id管理相关接口

/**
 *  [en]
 *  [cn]获取当前漫游的最小消息id
 *
 *  @param contact 聊天对象
 *
 *  @return 最小消息id
 */
- (NSString*)previousMessageid:(ContactEntity*)contact;

/**
 *  [en]
 *  [cn]获取当前漫游的最大消息id
 *
 *  @param contact 聊天对象
 *
 *  @return 最大消息id
 */
- (NSString*)latestMessageId:(ContactEntity*)contact;

/**
 *  [en]
 *  [cn]向漫游消息id列表添加新的记录
 *
 *  @param messages 新的消息对象ChatMessageEntity
 *  @param contact 聊天对象
 */
- (void)insertRoamingMessageIdBasedMsg:(NSArray*)messages andContact:(ContactEntity*)contact;

/**
 *  [en]
 *  [cn]从漫游消息id列表中删除记录
 *
 *  @param messages 待删除的消息记录ChatMessageEntity
 *  @param contact 聊天对象
 */
- (void)deleteRoamingMessageIdBasedMsg:(NSArray*)messages andContact:(ContactEntity*)contact;

/**
 *  [en]
 *  [cn]判断某个消息id是否已经在漫游列表中
 *
 *  @param message 待判断的消息对象
 *  @param contact 聊天对象
 *
 *  @return 是否存在
 */
- (BOOL)containedRoamingMessageIdBasedMessage:(ChatMessageEntity*)message andContact:(ContactEntity*)contact;

/**
 *  [en]
 *  [cn]发送p2p命令行消息
 *
 *  @param userArray user账号数组
 *  @param msgBody   消息体
 *
 *  @return 是否存在
 */
//- (void)sendOprCommandMessageToUsers:(NSArray *)userArray withMsg:(NSString *)msgBody completionBlock:(void (^)(NSError* error, ECSOprCommandAck* result)) completionBlock;

/**
 *  [en]
 *  [cn]发送命令行消息到群组
 *
 *  @param groupId   群ID
 *  @param msgBody   消息体
 *
 *  @return 是否存在
 */
//- (void)sendOprCommandMessageToGroup:(NSString *)groupId withMsg:(NSString *)msgBody completionBlock:(void (^)(NSError* error, ECSOprCommandAck* result)) completionBlock;

/**
 *  [en]
 *  [cn]设置或取消个人静音
 *
 *  @param account      个人账号
 *  @param muteFlag     静音标志
 *  @param completionBlock 回调
 */
- (void)setSelfMuteForMobile:(NSString *)account withMuteFlag:(BOOL)muteFlag completion:(void(^)(NSError* error))completionBlock;

/**
 *  [en]
 *  [cn]查询个人静音状态
 *
 *  @param account      个人账号
 *  @param completionBlock 回调
 */
- (void)queryMuteState:(NSString *)account completion:(void(^)(NSError* error))completionBlock;

@end
