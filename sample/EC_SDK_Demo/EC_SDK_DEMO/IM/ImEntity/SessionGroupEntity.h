/**
 * @file SessionGroupEntity.h
 *
 * Copyright (c) 2017 Huawei Tech. Co., Ltd. All rights reserved. \n
 *
 * @brief [en]Description:group session basic service function class head file.
 * [cn]描述：群组会话基础业务功能类头文件。 \n
 **/

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "SessionEntity.h"

@class SessionEntity;

/**
 * [en] This class is about group session basic service info.
 * [cn] 群组会话基础业务信息类
 **/
@interface SessionGroupEntity : SessionEntity

@property (nonatomic, retain) NSString * desc;
@property (nonatomic, retain) NSString * headId;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *child;


/**
 * @brief [en] This method is used to set lastest message for session.
 *        <br>[cn] 给session设置最后一条消息记录
 *
 * @param [in] MessageEntity* latestMessage         <b>:</b><br>[en] Indicates message record.
 *                                                          <br>[cn] 消息记录
 * @param [in] SessionEntity* session               <b>:</b><br>[en] Indicates sessionGroup object.
 *                                                          <br>[cn] sessionGroup对象
 * @attention [en] NA.
 *            <br>[cn] NA
 * @see NA
 **/
- (void)setLatestMessage:(MessageEntity *)latestMessage withSession:(SessionEntity*) session;

@end

/**
 * [en] This class is about group session basic service function.
 * [cn] 群组会话基础业务功能类
 **/
@interface SessionGroupEntity (CoreDataGeneratedAccessors)

/**
 * @brief [en] This method is used to add chat object to group.
 *        <br>[cn] 向group中添加聊天对象
 *
 * @param [in] SessionEntity* value                 <b>:</b><br>[en] Indicates session object.
 *                                                          <br>[cn] 聊天对象
 * @attention [en] NA.
 *            <br>[cn] NA
 * @see NA
 **/
- (void)addChildObject:(SessionEntity *)value;

/**
 * @brief [en] This method is used to remove chat object from group.
 *        <br>[cn] 从group中删除聊天对象
 *
 * @param [in] SessionEntity* value                 <b>:</b><br>[en] Indicates chat object.
 *                                                          <br>[cn] 聊天对象
 * @attention [en] NA.
 *            <br>[cn] NA
 * @see NA
 **/
- (void)removeChildObject:(SessionEntity *)value;

/**
 * @brief [en] This method is used to add chat object set to group.
 *        <br>[cn] 向group中添加聊天对象集合
 *
 * @param [in] NSSet* values                        <b>:</b><br>[en] Indicates chat object set.
 *                                                          <br>[cn] 聊天对象(SessionEntity *)集合
 * @attention [en] NA.
 *            <br>[cn] NA
 * @see NA
 **/
- (void)addChild:(NSSet *)values;

/**
 * @brief [en] This method is used to delete chat object set from group.
 *        <br>[cn] 从group中删除聊天对象集合
 *
 * @param [in] NSSet* values                        <b>:</b><br>[en] Indicates chat object set.
 *                                                          <br>[cn] 聊天对象(SessionEntity *)集合
 * @attention [en] NA.
 *            <br>[cn] NA
 * @see NA
 **/
- (void)removeChild:(NSSet *)values;

@end
