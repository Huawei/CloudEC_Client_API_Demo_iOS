/**
 * @file ChatSessionEntity.h
 *
 * Copyright (c) 2017 Huawei Tech. Co., Ltd. All rights reserved. \n
 *
 * @brief [en]Description:chat session basic service function info class file definition.
 * [cn]描述：聊天会话基础业务功能信息类文件定义。 \n
 **/

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "SessionEntity.h"

/**
 * [en]This enum is about chat state.
 * [cn]聊天状态
 */
typedef NS_ENUM(NSInteger, ECSChatState) {
    ECSChatStateNotLoad = 0,        /**< [en]Indicates not load.
                                     <br>[cn]未加载 */
    ECSChatStateLoaded = 1          /**< [en]Indicates loaded.
                                     <br>[cn]已加载 */
};

@class ContactEntity;

/**
 * [en] This class is about chat session basic service function info.
 * [cn] 聊天会话基础业务功能信息类
 **/
@interface ChatSessionEntity : SessionEntity

@property (nonatomic, retain) ContactEntity *target;
@property (nonatomic, retain) NSNumber * isAtMe;
@property (nonatomic, retain) NSString * draft;
@property (nonatomic, retain) NSNumber * realUnReceiveMsgNum;//nsinteger
@property (nonatomic, retain) NSNumber * chatState;//nsinteger ECSChatState

@end
