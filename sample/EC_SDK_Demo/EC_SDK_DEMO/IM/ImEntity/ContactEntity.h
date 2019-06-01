/**
 * @file ContractEntity.h
 *
 * Copyright (c) 2017 Huawei Tech. Co., Ltd. All rights reserved. \n
 *
 * @brief [en]Description:TUP contact service opertation info class head file.
 * [cn]描述：TUP 联系人业务操作信息类头文件。 \n
 **/

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <UIKit/UIKit.h>
#import "ESpaceLocalDataManager.h"
#import "MsgLogSessionEntity.h"
#import "ESpaceContactHeadImageService.h"

@class ChatSessionEntity, MessageEntity,AttendeeEntity,CallSessionEntity;
//
//typedef NS_ENUM(NSInteger, HeadImageStatus) {
//    HeadImageInvalid = 0,
//    HeadImageLoading = 1,
//    HeadImageDownloaded = 2
//};

/**
 * [en]Thi enum is about contact type.
 * [cn]联系人类型分类
 */
typedef NS_ENUM(NSInteger, ContactType) {
    ContactUserType = 0,                /**< [en]Indicates user type.
                                         <br>[cn]用户类型 */
    ContactGroupType = 1,               /**< [en]Indicates group type.
                                         <br>[cn]分组类型 */
    ContactLocalType = 2,               /**< [en]Indicates local type.
                                         <br>[cn]本地类型 */
    ContactPublicAccountType = 3,       /**< [en]Indicates public account type.
                                         <br>[cn]公众号类型 */
    ContactLightAppPaType = 4,          /**< [en]Indicates light app type.
                                         <br>[cn]轻应用类型 */
    ContactLocalAppPaType = 5           /**< [en]Indicates local app type.
                                         <br>[cn]本地应用类型 */
};

/**
 * [en]This enum is about translate function switch state.
 * [cn]翻译功能开关状态
 */
typedef NS_ENUM(NSInteger, TranslateSwitchState) {
    TranslateSwitch_Undefine = 0,       /**< [en]Indicates undefine.
                                         <br>[cn]未定义 */
    TranslateSwitch_AutoOpened = 1,     /**< [en]Indicates auto opened.
                                         <br>[cn]默认打开 */
    TranslateSwitch_ManualOpened = 2,   /**< [en]Indicates manual opened.
                                         <br>[cn]键盘打开 */
    TranslateSwitch_Closed = 3          /**< [en]Indicates closed.
                                         <br>[cn]关闭 */
};

/**
 * [en]This enum is about translate language.
 * [cn]翻译语言
 */
typedef NS_ENUM(NSInteger, TranslateLanguage) {
    TranslateLanguage_Chinese = 0,      /**< [en]Indicates chinese.
                                         <br>[cn]中文 */
    TranslateLanguage_English = 1,      /**< [en]Indicates english.
                                         <br>[cn]英文 */
};

#define INVALID_HEAD_ID @"-1"

/**
 * [en] This class is about contact service opertation info.
 * [cn] 联系人业务操作信息类
 **/
@interface ContactEntity : NSManagedObject {
@protected
    NSUInteger headImageReloadCount;
}

@property (nonatomic, assign) ItemLocalStatus itemLocalStatus;
@property (nonatomic, assign) ItemLocalStatus headLocalStatus;

@property (nonatomic, retain) NSString * contactId;
@property (nonatomic, retain) NSString * headId;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * classType;
@property (nonatomic, retain) ChatSessionEntity *chatSession;
@property (nonatomic, retain) CallSessionEntity *callSession;
@property (nonatomic, retain) NSSet *recivMessages;
@property (nonatomic, retain) NSSet *sentMessages;
@property (nonatomic, retain) NSNumber * weight;
@property (nonatomic, retain) NSDate *infoUpdateTime;
@property (nonatomic, retain) NSSet *matchedAttendee;
@property (nonatomic, retain) NSString* nameIndex;// 名称的拼音，用于排序
@property (nonatomic, retain) MsgLogSessionEntity* msgLogSession;
@property (nonatomic, retain) NSNumber *searchIndex; // 记录是否被搜索过,0默认没有搜索过,数值越大排在搜索记录越前面
@property (nonatomic, retain) NSString *appID;
@property (nonatomic, retain) NSString *appName;

@property (nonatomic, strong, readonly) NSString* uiDisplayName;
@property (nonatomic, copy) NSString *remarkName;//备注名称
@property (nonatomic, retain) NSNumber *translateSwitchState;//NSInteger:TranslateSwitchState
@property (nonatomic, retain) NSDate *translateSwitchOpenedTime;
@property (nonatomic, retain) NSNumber *translateLanguage;//NSInteger:TranslateLanguage


/**
 * @brief [en] This method is used to get default head image with id.
 *        <br>[cn] 根据头像id获取默认头像
 *
 * @param [in] NSString* headId                   <b>:</b><br>[en] Indicates head id.
 *                                                        <br>[cn] 头像id
 * @retval UIImage *                              <b>:</b><br>[en] Return image if success, or return nil.
 *                                                        <br>[cn] 成功返回头像，失败返回nil
 * @attention [en] NA.
 *            <br>[cn] NA
 * @see NA
 **/
+ (UIImage*) defaultHeadImageWithId:(NSString*) headId;


/**
 * @brief [en] This method is used to get head saved local path.
 *        <br>[cn] 获取头像保存的本地路径
 *
 * @param [in] NSString* headId                   <b>:</b><br>[en] Indicates head id.
 *                                                        <br>[cn] 头像id
 * @param [in] NSString* userAccount              <b>:</b><br>[en] Indicates user account.
 *                                                        <br>[cn] 用户账号
 * @param [in] NSString* prefix                   <b>:</b><br>[en] Indicates prefix, default class.
 *                                                        <br>[cn] 前缀，默认为类的class
 * @retval NSString *                             <b>:</b><br>[en] Return local path if success, or return nil.
 *                                                        <br>[cn] 成功返回头像保存的本地路径，失败返回nil
 * @attention [en] NA
 *            <br>[cn] NA
 * @see NA
 **/
+ (NSString*) localPathForHeadId:(NSString*) headId account:(NSString*) userAccount prefix:(NSString*) prefix;


/**
 * @brief [en] This method is used to get default head image.
 *        <br>[cn] 默认头像
 *
 * @retval UIImage *                              <b>:</b><br>[en] Return image if success, or return nil.
 *                                                        <br>[cn] 成功返回头像，失败返回nil
 * @attention [en] NA.
 *            <br>[cn] NA
 * @see NA
 **/
- (UIImage*) defaultHeadImage;


/**
 * @brief [en] This method is used to get head image local path.
 *        <br>[cn] 头像本地存储路径
 *
 * @retval NSString *               <b>:</b><br>[en] Return path if success, or return nil.
 *                                          <br>[cn] 成功返回路径，失败返回nil
 * @attention [en] NA
 *            <br>[cn] NA
 * @see NA
 **/
- (NSString*) headImageLocalPath;


/**
 * @brief [en] This method is used to get head image key.
 *        <br>[cn] 头像键值
 *
 * @retval NSString *               <b>:</b><br>[en] Return key if success, or return nil.
 *                                          <br>[cn] 成功返回键值，失败返回nil
 * @attention [en] Use to get head image from local path
 *            <br>[cn] 用于从本地路径获取头像
 * @see NA
 **/
- (NSString*) headImageKey;


/**
 * @brief [en] This method is used to judge whether is contact object.
 *        <br>[cn] 判断是否是联系人对象
 *
 * @retval BOOL *                   <b>:</b><br>[en] Return yes if true, or return no.
 *                                          <br>[cn] 是返回YES，否返回NO
 * @attention [en] NA.
 *            <br>[cn] NA
 * @see NA
 **/
- (BOOL)isEmployeeEnity;


/**
 * @brief [en] This method use to judge whether is group object.
 *        <br>[cn] 判断是否是群组对象
 *
 * @retval BOOL *                   <b>:</b><br>[en] Return yes if true, or return no.
 *                                          <br>[cn] 是返回YES，否返回NO
 * @attention [en] NA.
 *            <br>[cn] NA
 * @see NA
 **/
- (BOOL)isGroupEntity;


/**
 * @brief [en] This method is used to judge whether is equal to contact.
 *        <br>[cn] 判断是否是同一个对象
 *
 * @param [in] ContactEntity* c     <b>:</b><br>[en] Indicates original object.
 *                                          <br>[cn] 待比较对象
 * @retval BOOL *                   <b>:</b><br>[en] Return yes if true, or return no.
 *                                          <br>[cn] 是返回YES，否返回NO
 * @attention [en] NA.
 *            <br>[cn] NA
 * @see NA
 **/
- (BOOL)isEqualToContact:(ContactEntity *)c;


/**
 * @brief [en] This method is used delete contact.
 *        <br>[cn] 删除联系人
 *
 * @attention [en] delete this contact and attached session from database.
 *            <br>[cn] 删除数据库中此联系人及所有绑定的session同时重置父节点未读数及最新消息，必须在espace_core_data_managed_queue中被调用
 * @see NA
 **/
- (void)localDeleteSelf;


/**
 * @brief [en] This method is used to async delete contact.
 *        <br>[cn] 异步删除联系人
 *
 * @param [out] completionBlock        <b>:</b><br>[en] Return handle result block, carry error info.
 *                                             <br>[cn] 处理结果Block，携带错误信息(NSError*)
 * @attention [en] NA.
 *            <br>[cn] NA
 * @see NA
 **/
- (void)localDeleteSelf:(void (^)(NSError* error)) completionBlock;

@end

/**
 * [en] This class is about contact service operation info.
 * [cn] 联系人业务操作信息类
 **/
@interface ContactEntity (CoreDataGeneratedAccessors)

/**
 * @brief [en] This method is used to add single im message.
 *        <br>[cn] 添加单个IM消息
 *
 * @param [in] MessageEntity* value                 <b>:</b><br>[en] Indicates im message object.
 *                                                          <br>[cn] im消息对象
 * @attention [en] NA.
 *            <br>[cn] NA
 * @see NA
 **/
- (void) addRecivMessagesObject:(MessageEntity*)value;

/**
 * @brief [en] This method is used to remove single IM message.
 *        <br>[cn] 删除单个IM消息
 *
 * @param [in] MessageEntity* value                 <b>:</b><br>[en] Indicates im message object.
 *                                                          <br>[cn] im消息对象
 * @attention [en] NA.
 *            <br>[cn] NA
 * @see NA
 **/
- (void) removeRecivMessagesObject:(MessageEntity*)value;

/**
 * @brief [en] This method is used to add IM message set.
 *        <br>[cn] 添加IM消息集合
 *
 * @param [in] NSSet* values                        <b>:</b><br>[en] Indicates im message object set.
 *                                                          <br>[cn] im消息对象(MessageEntity *)集合
 * @attention [en] NA.
 *            <br>[cn] NA
 * @see NA
 **/
- (void) addRecivMessages:(NSSet*)values;

/**
 * @brief [en] This method is used to remove IM message set.
 *        <br>[cn] 删除IM消息集合
 *
 * @param [in] NSSet* values                        <b>:</b><br>[en] Indicates im message object set.
 *                                                          <br>[cn] im消息对象(MessageEntity *)集合
 * @attention [en] NA.
 *            <br>[cn] NA
 * @see NA
 **/
- (void) removeRecivMessages:(NSSet*)values;

/**
 * @brief [en] This method is used to add matched attendee.
 *        <br>[cn] 添加匹配到的与会者
 *
 * @param [in] AttendeeEntity* value                <b>:</b><br>[en] Indicates attendee object.
 *                                                          <br>[cn] 与会者对象
 * @attention [en] NA.
 *            <br>[cn] NA
 * @see NA
 **/
- (void)addMatchedAttendeeObject:(AttendeeEntity *)value;

/**
 * @brief [en] This method is used to remove matched attendee.
 *        <br>[cn] 删除匹配到的与会者
 *
 * @param [in] AttendeeEntity* value                <b>:</b><br>[en] Indicates attendee object.
 *                                                          <br>[cn] 与会者对象
 * @attention [en] NA.
 *            <br>[cn] NA
 * @see NA
 **/
- (void)removeMatchedAttendeeObject:(AttendeeEntity *)value;

/**
 * @brief [en] This method is used to add matched attendee set.
 *        <br>[cn] 添加匹配到的与会者集合
 *
 * @param [in] NSSet* values                        <b>:</b><br>[en] Indicates attendee object set.
 *                                                          <br>[cn] 与会者对象(AttendeeEntity *)集合
 * @attention [en] NA.
 *            <br>[cn] NA
 * @see NA
 **/
- (void)addMatchedAttendee:(NSSet *)values;

/**
 * @brief [en] This method is used to remove matched attendee set.
 *        <br>[cn] 删除匹配到的与会者集合
 *
 * @param [in] NSSet* values                        <b>:</b><br>[en] Indicates attendee object set.
 *                                                          <br>[cn] 与会者对象(AttendeeEntity *)集合
 * @attention [en] NA.
 *            <br>[cn] NA
 * @see NA
 **/
- (void)removeMatchedAttendee:(NSSet *)values;

@end
