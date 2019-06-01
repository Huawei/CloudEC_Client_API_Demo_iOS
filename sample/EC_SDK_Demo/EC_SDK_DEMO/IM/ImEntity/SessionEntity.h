/**
 * @file SessionEntity.h
 *
 * Copyright (c) 2017 Huawei Tech. Co., Ltd. All rights reserved. \n
 *
 * @brief [en]Description:message session basic service info class head file.
 * [cn]描述：消息会话基础业务信息类头文件。 \n
 **/

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

/**
 * [en]This enum is about chat object display  priority.
 * [cn]聊天对象显示优先级
 */
typedef enum SESSION_PRIORITY_
{
    SESSION_PRIORITY_Hide = -1, /**< [en]xxxx.
                                 <br>[cn] */
    SESSION_PRIORITY_Zero = 0,  /**< [en]xxxx.
                                 <br>[cn]0 */
    SESSION_PRIORITY_One  = 1,  /**< [en]xxxx.
                                 <br>[cn]1 */
    SESSION_PRIORITY_Two  = 2   /**< [en]xxxx.
                                 <br>[cn]2 */
}SESSION_PRIORITY;

@class MessageEntity;

/**
 * [en] This class is about info session basic service info.
 * [cn] 消息会话基础业务信息类
 **/
@interface SessionEntity : NSManagedObject

@property (nonatomic, retain) NSNumber * unreadCount;
@property (nonatomic, retain) NSDate * timestamp;
@property (nonatomic, retain) NSSet *messages;
@property (nonatomic, retain) NSManagedObject *parent;
@property (nonatomic, retain) NSNumber * priority;//SESSION_PRIORITY
@property (nonatomic, retain) NSString * sessionId;
@property (nonatomic, retain) NSNumber * reportUnread;
@property (nonatomic, retain) MessageEntity * latestMessage;
@property (nonatomic, retain) NSNumber * unreadMsgNum;


/**
 * @brief [en] This method is used to get message id by corresponding message.
 *        <br>[cn] 根据消息id获取对应的消息
 *
 * @param [in] NSString* msgId                    <b>:</b><br>[en] Indicates message id.
 *                                                        <br>[cn] 消息id
 * @retval MessageEntity *                        <b>:</b><br>[en] Return message object if successm or return nil.
 *                                                        <br>[cn] 成功返回消息对象，失败返回nil
 * @attention [en] NA.
 *            <br>[cn] NA
 * @see NA
 **/
- (MessageEntity*) messageWithId:(NSString*) msgId;

//- (void)createTimestampForDate:(NSDate*) date;


/**
 * @brief [en] This method is used to judge whether can be hided.
 *        <br>[cn] 判断是否可以被隐藏
 *
 * @retval BOOL *                   <b>:</b><br>[en] Return yes if true, or return no.
 *                                          <br>[cn] 是返回YES，否返回NO
 * @attention [en] NA.
 *            <br>[cn] NA
 * @see NA
 **/
- (BOOL)canHide;


/**
 * @brief [en] This method is used to hide self.
 *        <br>[cn] 隐藏自己
 *
 * @attention [en] NA.
 *            <br>[cn] NA
 * @see NA
 **/
- (void)hide;


/**
 * @brief [en] This method is used to mark all message read.
 *        <br>[cn] 标记所有消息为已读消息
 *
 * @attention [en] SessionGroupEntity rewrite this method, gurantee all node message be marked read, must invoke in espace_core_data_managed_queue.
 *            <br>[cn] SessionGroupEntity对此方法重写,保证所有子节点的message都标记已读，必须在espace_core_data_managed_queue中被调用
 * @see NA
 **/
- (void)localMarkReadAll;


/**
 * @brief [en] This method is used to mark read all message.
 *        <br>[cn] 标记所有消息为已读消息
 *
 * @param [out] completionBlock                 <b>:</b><br>[en] Indicates handle result block, carry error info.
 *                                                      <br>[cn] 处理结果Block，携带错误信息(NSError*)
 * @attention [en] NA.
 *            <br>[cn] NA
 * @see NA
 */
- (void)localMarkReadAll:(void (^)(NSError* error)) completionBlock;


/**
 * @brief [en] This method is used to judge can mark top.
 *        <br>[cn] 判断是否可以被置顶
 *
 * @retval BOOL *                   <b>:</b><br>[en] Return yes if true, or return no  .
 *                                          <br>[cn] 是返回YES，否返回NO
 * @attention [en] NA.
 *            <br>[cn] NA
 * @see NA
 **/
- (BOOL)canMarkTop;


/**
 * @brief [en] This method is used to mark self top.
 *        <br>[cn] 置顶
 *
 * @attention [en] NA.
 *            <br>[cn] NA
 * @see NA
 **/
- (void)markTop;


/**
 * @brief [en] This method is used to cancel mark top.
 *        <br>[cn] 取消置顶
 *
 * @attention [en] NA.
 *            <br>[cn] NA
 * @see NA
 **/
- (void)cancelMarkTop;


/**
 * @brief [en] This method is used to update latest message.
 *        <br>[cn] 更新最新消息
 *
 * @retval MessageEntity *                        <b>:</b><br>[en] Return latest message if success, or return nil .
 *                                                        <br>[cn] 成功返回最新消息对象，失败返回nil
 * @attention [en] attention whether is real and use higher effect arithmetic auto updateLatestmesssage when delete message.
 *            <br>[cn] 注意真假及删除消息时使用效率较高的算法自动updateLatestmesssage，此方法只适合此场景之外的更新lastestmessage比如删除contact
 * @see NA
 **/
- (MessageEntity*) updateLatestMessage;


/**
 * @brief [en] This method is used to get latest message by time stamp.
 *        <br>[cn] 按照升序或者降序获取最新的消息
 *
 * @param [in] BOOL ascending                     <b>:</b><br>[en] Indicates ascending.
 *                                                        <br>[cn] 排序规则
 * @retval MessageEntity *                        <b>:</b><br>[en] Return latest message object if success or return nil.
 *                                                        <br>[cn] 成功返回最新的消息对象，失败返回nil
 * @attention [en] NA.
 *            <br>[cn] NA
 * @see NA
 **/
- (MessageEntity*) lastMessageByTimeStamp:(BOOL) ascending;


/**
 * @brief [en] This method is used to delete session from database.
 *        <br>[cn] 删除数据库中的session
 *
 * @attention [en] delete this session and reset unread father node unread and latest message from database, must invoke in espace_core_data_managed_queue.
 *            <br>[cn] 删除数据库中此session及session下所有message同时重置父节点未读数及最新消息，必须在espace_core_data_managed_queue中被调用
 * @see NA
 */
- (void)localDeleteSelf;


/**
 * @brief [en] This method is used to async delete session.
 *        <br>[cn] 异步删除session
 *
 * @param [out] completionBlock                 <b>:</b><br>[en] Indicates handle result block, carry errir message.
 *                                                      <br>[cn] 处理结果Block，携带错误信息(NSError*)
 * @attention [en] NA.
 *            <br>[cn] NA
 * @see NA
 */
- (void)localDeleteSelf:(void (^)(NSError* error)) completionBlock;


/**
 * @brief [en] This method is used to delete this session and reset unread father node unread and latest message from database.
 *        <br>[cn] 删除数据库中所有此session下的message同时重置父节点未读数及最新消息
 *
 * @attention [en] SessionGroupEntity rewrite this method, gurantee all node message be marked read, must invoke in espace_core_data_managed_queue.
 *            <br>[cn] SessionGroupEntity对此方法重写,保证所有子节点的message都被清除，必须在espace_core_data_managed_queue中被调用
 * @see NA
 */
- (void)localDeleteAllMessages;


/**
 * @brief [en] This method is used to async delete all message of session.
 *        <br>[cn] 异步删除session下的所有消息
 *
 * @param [out] completionBlock                 <b>:</b><br>[en] Indicates handle result block, carry errir message.
 *                                                      <br>[cn] 处理结果Block，携带错误信息(NSError*)
 * @attention [en] NA.
 *            <br>[cn] NA
 * @see NA
 */
- (void)localDeleteAllMessages:(void (^)(NSError* error)) completionBlock;


/**
 * @brief [en] This method is used to delete appointed message set.
 *        <br>[cn] 删除指定的消息集合
 *
 * @param [in] NSSet* msg                       <b>:</b><br>[en] Indicates message set.
 *                                                      <br>[cn] 消息(MessageEntity *)集合
 * @attention [en] NA.
 *            <br>[cn] NA
 * @see NA
 **/
- (void)localDeleteMessages:(NSSet*) msg;


/**
 * @brief [en] This method is used to async delete appointed message set.
 *        <br>[cn] 异步删除指定的消息集合
 *
 * @param [in] NSSet* msg                       <b>:</b><br>[en] Indicates message set.
 *                                                      <br>[cn] 消息(MessageEntity *)集合
 * @param [out] completionBlock                 <b>:</b><br>[en] Indicates handle result block, carry errir message.
 *                                                      <br>[cn] 处理结果Block，携带错误信息(NSError*)
 * @attention [en] NA.
 *            <br>[cn] NA
 * @see NA
 */
- (void)localDeleteMessages:(NSSet*) msg completion:(void (^)(NSError* error)) completionBlock;

@end

/**
 * [en] This class is abtou message session basic service info.
 * [cn] 消息会话基础业务信息类
 **/
@interface SessionEntity (CoreDataGeneratedAccessors)

/**
 * @brief [en] This method is used to add message to chat object.
 *        <br>[cn] 向聊天对象添加消息
 *
 * @param [in] MessageEntity* value                 <b>:</b><br>[en] Indicates message object.
 *                                                          <br>[cn] 消息对象
 * @attention [en] NA.
 *            <br>[cn] NA
 * @see NA
 **/
- (void)addMessagesObject:(MessageEntity *)value;

/**
 * @brief [en] This method is used to remove message object from chat object.
 *        <br>[cn] 从聊天对象删除消息
 *
 * @param [in] MessageEntity* value                 <b>:</b><br>[en] Indicates message object.
 *                                                          <br>[cn] 消息对象
 * @attention [en] NA.
 *            <br>[cn] NA
 * @see NA
 **/
- (void)removeMessagesObject:(MessageEntity *)value;

/**
 * @brief [en] This method is used to add message set to chat object.
 *        <br>[cn] 向聊天对象添加消息集合
 *
 * @param [in] NSSet* values                        <b>:</b><br>[en] Indicates message object set.
 *                                                          <br>[cn] 消息对象(MessageEntity *)集合
 * @attention [en] NA.
 *            <br>[cn] NA
 * @see NA
 **/
- (void)addMessages:(NSSet *)values;

/**
 * @brief [en] This method is used to remove message set from chat object.
 *        <br>[cn] 从聊天对象删除消息集合
 *
 * @param [in] NSSet* values                        <b>:</b><br>[en] Indicates message object set.
 *                                                          <br>[cn] 消息对象(MessageEntity *)集合
 * @attention [en] NA.
 *            <br>[cn] NA
 * @see NA
 **/
- (void)removeMessages:(NSSet *)values;
@end
