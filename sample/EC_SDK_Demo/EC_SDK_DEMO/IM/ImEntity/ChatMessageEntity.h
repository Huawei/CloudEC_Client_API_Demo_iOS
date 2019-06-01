/**
 * @file ChatMessageEntity.h
 *
 * Copyright (c) 2017 Huawei Tech. Co., Ltd. All rights reserved. \n
 *
 * @brief [en]Description:IM message basic service function class head file.
 * [cn]描述：IM消息基础业务功能类头文件。 \n
 **/

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "MessageEntity.h"

/**
 * [en]This enum is about message flag.
 * [cn]消息标识
 */
typedef NS_ENUM(NSInteger, ESpaceMessageFlag) {
    ESpaceMessageFlagNormal = 0,                /**< [en]Indicates normal message.
                                                 <br>[cn]正常消息 */
    ESpaceMessageFlagSensitiveWord = 1,         /**< [en]Indicates sensitive word.
                                                 <br>[cn]敏感词提示 */
    ESpaceMessageFlagOversize = 2,              /**< [en]Indicates message flag over size.
                                                 <br>[cn]消息超大 */
    ESpaceMessageFlagUndeliver = 3,             /**< [en]Indicates message undeliver.
                                                 <br>[cn]消息未送达 */
    ESpaceMessageFlagSendFailed = 4,            /**< [en]Indicates message send failed.
                                                 <br>[cn]消息发送失败 */
    ESpaceMessageFlagGroupMemberChanged = 5,    /**< [en]Indicates group member changed.
                                                 <br>[cn]群组成员变更 */
    ESpaceMessageFlagGroupStateChanged = 6,     /**< [en]Indicates group state changed.
                                                 <br>[cn]群组状态变更 */
    ESpaceMessageFlagGroupInfoChanged = 7,      /**< [en]Indicates group info changed.
                                                 <br>[cn]群组信息更改 */
    ESpaceMessageFlagRecalled = 8,              /**< [en]Indicates flag recalled.
                                                 <br>[cn]消息撤回 */
    ESpaceMessageFlagGroupAnnounceChanged = 9,  /**< [en]Indicates group announce changed.
                                                 <br>[cn]群组公告更新 */
    ESpaceMessageFlagVideoCall = 10             /**< [en]Indicates video call.
                                                 <br>[cn]WL视频通话 */
};

/**
 * [en]This enum is about message sending type.
 * [cn]发送消息类型
 */
typedef NS_ENUM(NSUInteger, ESpaceSenderType){
    ESpaceMessageFromEspace = 0,        /**< [en]Indicates espace message.
                                         <br>[cn]Espace消息 */
    ESpaceMessageFromThirdPart = 1,     /**< [en]Indicates third part message.
                                         <br>[cn]第三方发送消息 */
    ESpaceMessageFromThirdSys = 2       /**< [en]Indicates system message.
                                         <br>[cn]系统消息 */
};

@class EmployeeEntity;


/**
 * [en] This class is about Im message basic service info.
 * [cn] IM消息基础业务信息类
 **/
@interface ChatMessageEntity : MessageEntity

@property (nonatomic, retain) NSNumber * readDetail;
@property (nonatomic, retain) NSNumber * flag;
@property (nonatomic, retain) NSString * body_ref;
@property (nonatomic, retain) NSSet *at;
@property (nonatomic, retain) NSNumber * subIndex;
@property (nonatomic, retain) NSNumber * total;
@property (nonatomic, retain) NSNumber *senderType;
@property (nonatomic, retain) NSString *appName;
@property (nonatomic, retain) NSString *appID;
@property (nonatomic, retain) NSString *msgEx;// 开放性第三方应用使用

@end


/**
 * [en] This class is about IM message basic service function.
 * [cn] IM消息基础业务功能类
 **/
@interface ChatMessageEntity (CoreDataGeneratedAccessors)

/**
 * @brief [en] This method is used to add at object.
 *        <br>[cn] 添加@的联系人对象
 *
 * @param [in] EmployeeEntity* value         <b>:</b><br>[en] Indicates contact object.
 *                                                   <br>[cn] 联系人对象
 * @attention [en] NA.
 *            <br>[cn] NA
 * @see NA
 **/
- (void)addAtObject:(EmployeeEntity *)value;

/**
 * @brief [en] This method is used to remove at object.
 *        <br>[cn] 删除@的联系人对象
 *
 * @param [in] EmployeeEntity* value         <b>:</b><br>[en] Indicates contact object.
 *                                                   <br>[cn] 联系人对象
 * @attention [en] NA.
 *            <br>[cn] NA
 * @see NA
 **/
- (void)removeAtObject:(EmployeeEntity *)value;

/**
 * @brief [en] This method is used to add at object set.
 *        <br>[cn] 添加@的联系人对象集合
 *
 * @param [in] NSSet* values                 <b>:</b><br>[en] Indicates contact object set.
 *                                                   <br>[cn] 联系人对象(EmployeeEntity *)集合
 * @attention [en] NA.
 *            <br>[cn] NA
 * @see NA
 **/
- (void)addAt:(NSSet *)values;

/**
 * @brief [en] This method is used to remove at object set.
 *        <br>[cn] 删除@的联系人对象集合
 *
 * @param [in] NSSet* values                 <b>:</b><br>[en] Indicates contact object set.
 *                                                   <br>[cn] 联系人对象(EmployeeEntity *)集合
 * @attention [en] NA.
 *            <br>[cn] NA
 * @see NA
 **/
- (void)removeAt:(NSSet *)values;
@end
