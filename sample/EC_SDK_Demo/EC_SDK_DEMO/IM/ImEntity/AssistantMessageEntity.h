/**
 * @file AssistantMessageEntity.h
 *
 * Copyright (c) 2017 Huawei Tech. Co., Ltd. All rights reserved. \n
 *
 * @brief [en]Description:notify class message head file.
 * [cn]描述：通知类消息头文件。 \n
 **/

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "MessageEntity.h"

extern NSString* const kESpaceGroupInviteGroupId;

/**
 * [en]This enum is about opertation result after receive group invite or friend invite.
 * [cn]收到群邀请或者好友邀请后的操作及操作结果
 */
typedef NS_ENUM(NSInteger, ESpaceAssistantActionType) {
    ESpaceAssistantUndetermined,    /**< [en]Indicates undetermined.
                                     <br>[cn]未定义 */
    ESpaceAssistantAccept,          /**< [en]Indicates accept.
                                     <br>[cn]接收 */
    ESpaceAssistantDeny,            /**< [en]Indicates deny.
                                     <br>[cn]拒绝 */
    ESpaceAssistantIgnore           /**< [en]Indicates ignore.
                                     <br>[cn]忽略 */
};

/**
 * [en]This enum is about message type.
 * [cn]消息类型
 */
typedef NS_ENUM(NSInteger, ESpaceAssistantMsgType) {
    ESpaceAssistantAddedFriend = 1,     /**< [en]Indicates add friend.
                                         <br>[cn]添加好友 */
    ESpaceAssistantGroupInvite          /**< [en]Indicates invite join group.
                                         <br>[cn]邀请加入群组 */
};

/**
 * [en] Indicates assistant message entity.
 * [cn] 通知消息
 **/
@interface AssistantMessageEntity : MessageEntity

@property (nonatomic, retain) NSNumber * action;

@end
