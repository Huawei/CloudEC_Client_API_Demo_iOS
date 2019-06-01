/**
 * @file ChatSessionEntity+ServiceObject.h
 *
 * Copyright(C), 2012-2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED. \n
 *
 * @brief [en]Description:Tup chat session operation class head file.
 * [cn]描述：TUP 聊天会话操作类头文件。 \n
 **/

#import "ChatSessionEntity.h"
//#import "ESpaceUMResource.h"
#import "ChatMessageEntity.h"
#import "ChatMessageEntity+ServiceObject.h"

#define DEFAULT_IM_RECORD_NUM 10

/**
 * [en]This enum is about session type.
 * [cn]会话类型
 */
typedef NS_ENUM(NSInteger, RecentSessionType){
    RecentSessionP2P = 0,               /**< [en]Indicates p2p.
                                         <br>[cn]点对点 */
    RecentSessionCall = 1,              /**< [en]Indicates audio session.
                                         <br>[cn]语音会话 */
    RecentSessionFixedGroup = 2,        /**< [en]Indicates fixed group session.
                                         <br>[cn]固定群会话 */
    RecentSessionSystem = 3,            /**< [en]Indicates system message.
                                         <br>[cn]系统消息 */
    RecentSessionPublicAccount = 4,     /**< [en]Indicates public account session.
                                         <br>[cn]公众号会话 */
    RecentSessionSMS = 5,               /**< [en]Indicates sms session.
                                         <br>[cn]短信会话 */
    RecentSessionDiscussGroup = 6       /**< [en]Indicates discussion group session.
                                         <br>[cn]讨论组会话 */
};


@interface ChatSessionEntity (ServiceObject)

/**
 * @brief [en] This method is used to send message.
 *        <br>[cn] 发送消息
 *
 * @param [in] NSString* messageBody        <b>:</b><br>[en] Indicates message body.
 *                                                  <br>[cn] 消息内容
 * @param [out] completionBlock             <b>:</b><br>[en] Indicates deeling result block, carry error message .
 *                                                  <br>[cn] 处理结果Block，携带错误信息(NSError*)
 * @attention [en] xxxx.
 *            <br>[cn] 该接口会解析发送内容是否为富媒体消息
 */
- (void) sendMessage:(NSString*) messageBody completionBlock:(void (^)(NSError* error)) completionBlock;

/**
  * @brief [en] This method is used to send offline file.
 *        <br>[cn] 发送富媒体接口
 *
 * @param [in] ESpaceUMResource* umResource        <b>:</b><br>[en] Indicates offline object.
 *                                                         <br>[cn] 富媒体对象
 * @param [out] completionBlock                    <b>:</b><br>[en] Indicates deeling result block, carry error message .
 *                                                         <br>[cn] 处理结果Block，携带错误信息(NSError*)
 */
//- (void) sendUMMessage:(ESpaceUMResource*)umResource completionBlock:(void (^)(NSError* error)) completionBlock;

/**
  * @brief [en] This method is used to forward message.
 *        <br>[cn] 转发消息
 *
 * @param [in] MessageEntity* message              <b>:</b><br>[en] Indicates wait forward message.
 *                                                         <br>[cn] 待转发消息
 * @param [out] completionBlock                    <b>:</b><br>[en] Indicates deeling result block, carry error message .
 *                                                         <br>[cn] 处理结果Block，携带错误信息(NSError*)
 */
- (void) forwardMessage:(MessageEntity*)message completionBlock:(void (^)(NSError* error)) completionBlock;

/**
  * @brief [en] This method is used to send message.
 *        <br>[cn] 发送消息
 *
 * @param [in] NSString* messageBody               <b>:</b><br>[en] Indicates message body.
 *                                                         <br>[cn] 消息正文
 * @param [in] NSString* msgExContent              <b>:</b><br>[en] Indicates message extra message.
 *                                                         <br>[cn] 消息附加消息
 * @param [out] completionBlock                    <b>:</b><br>[en] Indicates deeling result block, carry error message .
 *                                                         <br>[cn] 处理结果Block，携带错误信息(NSError*)
 * @attention [en] xxxx.
 *            <br>[cn] 支持群组和点对点消息, 第三方应用调用接口
 */
- (void)sendMessage:(NSString *)messageBody
              msgEx:(NSString *)msgExContent
    completionBlock:(void (^)(NSError *))completionBlock;

/**
  * @brief [en] This method is used to query roaming history message.
 *        <br>[cn] 查询漫游历史消息
 *
 * @param [in] NSString* beginId                   <b>:</b><br>[en] Indicates begin id.
 *                                                         <br>[cn] 查询的基准ID
 * @param [in] BOOL readed                         <b>:</b><br>[en] Indicates query returned record need marked status.
 *                                                         <br>[cn] 查询返回的记录需要标记的状态
 * @param [in] NSInteger loadCount                 <b>:</b><br>[en] Indicates load record count.
 *                                                         <br>[cn] 查询记录的数目
 * @param [out] completionBlock                    <b>:</b><br>[en] Indicates deeling result block, carry error message, query return record count and message id string array.
 *                                                         <br>[cn] 处理结果Block，携带错误信息、查询返回记录的数目以及消息ID字符串数组(NSError*, NSInteger, NSArray*)
 */
- (void) queryRoamingMessageBasedId:(NSString*)beginId
                             readed:(BOOL)readed
                              count:(NSInteger)loadCount
                         completion:(void (^)(NSError* error, NSInteger count, NSArray* msgLogIdList)) completionBlock;

/**
  * @brief [en] This method is used to save draft.
 *        <br>[cn] 保存草稿
 *
 * @param [in] NSString* draftContent              <b>:</b><br>[en] Indicates draft.
 *                                                         <br>[cn] 草稿
 * @param [out] completionBlock                    <b>:</b><br>[en] Indicates deeling result block, carry error message .
 *                                                         <br>[cn] 处理结果Block，携带错误信息(NSError*)
 */
- (void) saveDraft:(NSString*)draftContent completion:(void (^)(NSError* error)) completionBlock;

/**
  * @brief [en] This method is used to delete recent session history.
 *        <br>[cn] 删除最近对话记录
 *
 * @attention [en] xxxx.
 *            <br>[cn] NA
 * @see NA
 **/
- (void) deleteSelf;

/**
  * @brief [en] This method is used to clean history record.
 *        <br>[cn] 清除历史记录
 *
 * @param [out] completionBlock                    <b>:</b><br>[en] Indicates deeling result block, carry error message .
 *                                                         <br>[cn] 处理结果Block，携带错误信息(NSError*)
 */
- (void) cleanHistory:(void (^)(NSError* error)) completionBlock;

/**
  * @brief [en] This method is used to update isAtMe attribute.
 *        <br>[cn] 更新isAtMe属性
 *
 * @attention [en] NA.
 *            <br>[cn] NA
 * @see NA
 **/
- (void)updateIsAtMe;
@end
