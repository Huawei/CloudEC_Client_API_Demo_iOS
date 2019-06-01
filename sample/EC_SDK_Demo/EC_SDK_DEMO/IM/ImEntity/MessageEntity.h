/**
 * @file MessageEntity.h
 *
 * Copyright (c) 2017 Huawei Tech. Co., Ltd. All rights reserved. \n
 *
 * @brief [en]Description:info basic service info class head file.
 * [cn]描述：消息基础业务信息类头文件。 \n
 **/

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ContactEntity, SessionEntity, EmployeeEntity;

/**
 * [en]This enum is about message type.
 * [cn]消息类型
 */
typedef NS_ENUM(NSInteger, ESpaceContentType) {
    ESpaceTextContentType = 0,          /**< [en]Indicates text.
                                         <br>[cn]文本 */
    ESpaceAudioContentType = 1,         /**< [en]Indicates audio .
                                         <br>[cn]语音 */
    ESpaceVideoContentType = 2,         /**< [en]Indicates video.
                                         <br>[cn]视频 */
    ESpaceImageContentType = 3,         /**< [en]Indicates picture.
                                         <br>[cn]图片 */
    ESpaceFileContentType = 4,          /**< [en]Indicates file.
                                         <br>[cn]文件 */
    ESpacePublicAccountContentType = 5, /**< [en]Indicates public account forward message.
                                         <br>[cn]公众号转发消息 */
    ESpaceShareLinkContentType = 7,     /**< [en]Indicates picture link.
                                         <br>[cn]图文链接 */
    ESpaceMixContentType = 8,           /**< [en]Indicates picture mix.
                                         <br>[cn]图文混排 */
    ESpaceEmailContentType = 9,         /**< [en]Indicates email.
                                         <br>[cn]email */
    ESpaceCardMsgSharedType = 10,       /**< [en]Indicates shared type.
                                         <br>[cn]分享类 */
    ESpaceCardMsgOrderType = 11
};

/**
 * [en]This enum is about message operation.
 * [cn]消息长按支持的操作类型
 */
typedef NS_ENUM(NSInteger, ESpaceMessageAction) {
    ESpaceMessageCopy = 0x1,            /**< [en]Indicates copy.
                                         <br>[cn]拷贝 */
    ESpaceMessageDelete = 0x2,          /**< [en]Indicates delete.
                                         <br>[cn]删除 */
    ESpaceMessageTransmit = 0x4,        /**< [en]Indicates transmit.
                                         <br>[cn]转发 */
    ESpacemessageRecall = 0x08,         /**< [en]Indicates recall.
                                         <br>[cn]撤回 */
    ESpaceMessageBatchOperation = 0x100 /**< [en]Indicates batch operation.
                                         <br>[cn]更多 */
};

/**
 * [en]This enum is about Im message type.
 * [cn]IM消息类型
 */
typedef NS_ENUM(NSInteger, ESpaceMessageType) {
    ESpaceSysTimeMSGType = -1,          /**< [en]Indicates time.
                                         <br>[cn]时间类消息 */
    ESpaceIMMSGType = 0,                /**< [en]Indicates normal.
                                         <br>[cn]正常聊天消息 */
    ESpaceCallMsgType = 1,              /**< [en]Indicates call.
                                         <br>[cn]呼叫类型消息 */
    ESpaceVoiceMailMsgType = 2          /**< [en]Indicates voice mail.
                                         <br>[cn]语音留言消息 */
};

/**
 * [en]This enum is about im message status.
 * [cn]IM消息状态
 */
typedef NS_ENUM(NSUInteger, ESpaceMessageStatus) {
    ESpaceMsgStatusReceived = 0,                                        /**< [en]Indicates received.
                                                                         <br>[cn] 接收成功 */
    ESpaceMsgStatusSended = ESpaceMsgStatusReceived,                    /**< [en]Indicates sended.
                                                                         <br>[cn] 发送成功 */
    ESpaceMsgStatusDraft = 0x10000,                                     /**< [en]Indicates drafy.
                                                                         <br>[cn] 草稿 */
    ESpaceMsgStatusSending = 0x20000,                                   /**< [en]Indicates sending.
                                                                         <br>[cn] 发送中 */
    ESpaceMsgStatusReceiving = ESpaceMsgStatusSending,                  /**< [en]Indicates receiving.
                                                                         <br>[cn] 接收中 */
    
    ESpaceMsgStatusSendFailed = 0x40000,                                /**< [en]Indicates send failed.
                                                                         <br>[cn] 发送失败 */
    ESpaceMsgStatusReceiveFaied = ESpaceMsgStatusSendFailed,            /**< [en]Indicates receive faied.
                                                                         <br>[cn] 接收失败 */
    
    ESpaceMsgStatusSendCancelled = 0x80000,                             /**< [en]Indicates send cancelled.
                                                                         <br>[cn] 取消发送 */
    ESpaceMsgStatusReceiveCancelled = ESpaceMsgStatusSendCancelled      /**< [en]Indicates receive cancelled.
                                                                         <br>[cn] 取消接收 */
};

/**
 * [en]This enum is about message local status.
 * [cn]消息本地状态
 */
typedef NS_ENUM(NSInteger, ESpaceMessageLocalStatus) {
    ESpaceMessageLocalStatusExist = 0,  /**< [en]Indicates exist.
                                         <br>[cn]存在 */
    ESpaceMessageLocalStatusDeleted = 1 /**< [en]Indicates deleted.
                                         <br>[cn]被删除 */
};

/**
 * [en]This enum is about message translate state.
 * [cn]消息翻译状态
 */
typedef NS_ENUM(NSInteger, MsgTranslateState){
    MsgTranslate_UnTranslate = 0,       /**< [en]Indicates untranslate.
                                         <br>[cn]未翻译 */
    MsgTranslate_ManualTranslating = 1, /**< [en]Indicates manual translating.
                                         <br>[cn]人工翻译中 */
    MsgTranslate_AutoTranslating = 2,   /**< [en]Indicates auto translating.
                                         <br>[cn]自动翻译中 */
    MsgTranslate_ManualTranslated = 3,  /**< [en]Indicates manual translated.
                                         <br>[cn]人工翻译成功 */
    MsgTranslate_AutoTranslated = 4     /**< [en]Indicates auto translated.
                                         <br>[cn]自动翻译成功 */
};

/**
 * [en] This class is about message object basic service component info.
 * [cn] 消息对象基础业务组件信息类
 **/
@interface MessageEntity : NSManagedObject

@property (nonatomic, retain) NSString * messageId;
@property (nonatomic, retain) NSString * body;
@property (nonatomic, retain) NSNumber * contentType;
@property (nonatomic, retain) NSDate * receiveTimestamp;
@property (nonatomic, retain) NSNumber * transferStatus;
@property (nonatomic, retain) NSNumber * readed;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) ContactEntity *from;
@property (nonatomic, retain) SessionEntity *session;
@property (nonatomic, retain) ContactEntity *to;
@property (nonatomic, retain) NSNumber * localStatus;
@property (nonatomic, retain) NSNumber * dataBaseId;
@property (nonatomic, retain) NSString * translateBody;
@property (nonatomic, retain) NSNumber * translateState;//NSInter:MsgTranslateState


/**
 * @brief [en] This method is used to judge whether can be lastest message.
 *        <br>[cn] 判断是否可以作为最新的一条记录
 *
 * @retval BOOL *                   <b>:</b><br>[en] Return yes if true, or return no.
 *                                          <br>[cn] 是返回YES，否返回NO
 * @attention [en] NA.
 *            <br>[cn] NA
 * @see NA
 **/
- (BOOL)canBeLatestMessage;


/**
 * @brief [en] This method is used to judge whether support action.
 *        <br>[cn] 判断消息是否支持某种操作类型
 *
 * @param [in] NSInteger action     <b>:</b><br>[en] Indicates operation type ESpaceMessageAction.
 *                                          <br>[cn] 操作类型ESpaceMessageAction
 * @retval BOOL *                   <b>:</b><br>[en] Return yes if true, or return no.
 *                                          <br>[cn] 是返回YES，否返回NO
 * @attention [en] NA.
 *            <br>[cn] NA
 * @see NA
 **/
- (BOOL)supportAction:(NSInteger) action;


/**
 * @brief [en] This method is used to judge whether message send failed.
 *        <br>[cn] 判断消息是否发送失败
 *
 * @retval BOOL *                   <b>:</b><br>[en] Return yes if true, or return no.
 *                                          <br>[cn] 是返回YES，否返回NO
 * @attention [en] NA.
 *            <br>[cn] NA
 * @see NA
 **/
- (BOOL)failed;


/**
// * @brief [en] This method is used to message desc for merge forward.
// *        <br>[cn] 返回合并转发时代内容
// *
// * @retval NSString *               <b>:</b><br>[en] Return string if success, or return nil.
// *                                          <br>[cn] 成功返回字符串，失败返回nil
// * @attention [en] NA
// *            <br>[cn] NA
// * @see NA
// **/
//- (NSString *)messageDesc4MergeForward;


/**
 * @brief [en] This method is used to judge whether message can be selected.
 *        <br>[cn] 判断消息是否可选
 *
 * @retval BOOL *                   <b>:</b><br>[en] Return yes if true, or return no.
 *                                          <br>[cn] 是返回YES，否返回NO
 * @attention [en] used to page option operation scene.
 *            <br>[cn] 用于界面多选操作场景
 * @see NA
 **/
- (BOOL)canBeSelected;


///**
// * @brief [en] This method is used to judge whether message length over limit.
// *        <br>[cn] 判断消息内容是否过长
// *
// * @retval BOOL *                   <b>:</b><br>[en] Return yes if true, or return no.
// *                                          <br>[cn] 是返回YES，否返回NO
// * @attention [en] NA.
// *            <br>[cn] NA
// * @see NA
// **/
//- (BOOL)isLengthOverLimit;


/**
 * @brief [en] This method is used to delete local data.
 *        <br>[cn] 删除本地数据
 *
 * @attention [en] delete this message same time reset father node unread number and newest message from database, must invoked in espace_core_data_managed_queue.
 *            <br>[cn] 删除数据库中此消息同时重置父节点未读数及最新消息，必须在espace_core_data_managed_queue中被调用
 * @see NA
 **/
- (void)localDeleteSelf;


/**
 * @brief [en] This method is used to delete local data.
 *        <br>[cn] 删除本地数据
 *
 * @param [out] completionBlock                 <b>:</b><br>[en] Indicates handle result block, carry error message.
 *                                                      <br>[cn] 处理结果Block，携带错误信息(NSError*)
 * @attention [en] delete this message same time reset father node unread number and newest message from database, must invoked in espace_core_data_managed_queue.
 *            <br>[cn] 删除数据库中此消息同时重置父节点未读数及最新消息，必须在espace_core_data_managed_queue中被调用
 * @see NA
 **/
- (void)localDeleteSelf:(void (^)(NSError* error)) completionBlock;
//@property (nonatomic, retain) NSNumber * version;
//@property (nonatomic, retain) NSNumber * pushed;
//@property (nonatomic, retain) NSSet * at;
@end

//@interface MessageEntity (CoreDataGeneratedAccessors)
//- (void)addAtObject:(EmployeeEntity *)value;
//- (void)removeAtObject:(EmployeeEntity *)value;
//- (void)addAt:(NSSet *)values;
//- (void)removeAt:(NSSet *)values;
//@end
