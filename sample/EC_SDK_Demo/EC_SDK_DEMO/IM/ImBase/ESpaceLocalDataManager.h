/**
 * @file ESpaceLocalDataManager.h
 *
 * Copyright (c) 2017 Huawei Tech. Co., Ltd. All rights reserved. \n
 *
 * @brief [en]Description:The head file of local data manage class.
 * [cn]描述：本地数据管理类头文件。 \n
 **/

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "ECSSandboxHelper.h"

@class SessionGroupEntity;
@class EmployeeEntity;
@class AssistantSessionEntity;

/**
 * [en]Indicates local loading status.
 * [cn]本地加载状态
 */
typedef NS_ENUM(NSInteger, ItemLocalStatus) {
    ItemNotLoaded = 0,              /**< [en]Indicates not loaded.
                                     <br>[cn]未加载 */
    ItemLoading = 1,                /**< [en]Indicates loading.
                                     <br>[cn]正在加载 */
    ItemLoaded = 2                  /**< [en]Indicates has loaded.
                                     <br>[cn]已加载 */
};

#define ROOT_CHAT_SESSION_GROUP           @"ROOT_CHAT_SESSION_GROUP"
#define ROOT_CIRCLE_SESSION_GROUP         @"ROOT_CIRCLE_SESSION_GROUP"
#define ROOT_PUBLIC_ACCOUNT_SESSION_GROUP @"ROOT_PUBLIC_ACCOUNT_SESSION_GROUP"
#define ROOT_CALL_SESSION_GROUP           @"ROOT_CALL_SESSION_GROUP"
#define ASSISTANT_SESSION_ENTITY          @"ASSISTANT_SESSION_ENTITY"
#define COREDATA_MANAGEMENT_QUEUE_NAME    "com.huawei.espace.coredata"

#define TUP_IOS_FRAMEWORK_BUNDLE_ID @"com.huawei.eSpaceMclientV2"


#define ECS_IMG(name) [UIImage imageNamed:(name) inBundle:[ECSSandboxHelper shareInstance].UIResourceBundle compatibleWithTraitCollection:nil]

#define ECSLocalizedString(key, comment) \
[[ECSSandboxHelper shareInstance].UIResourceBundle localizedStringForKey:(key) value:@"" table:nil]

extern dispatch_queue_t espace_coredata_management_queue;//coreData存储队列


/**
 * [en] This class is about local data manager.
 * [cn] 本地数据管理类
 **/
@interface ESpaceLocalDataManager : NSObject

@property (copy, nonatomic, readonly) NSString* userAccount; //初始化数据库使用的账号，maa返回的账号
@property (nonatomic, strong, readonly) SessionGroupEntity* rootChatSessionGroup;
@property (nonatomic, strong, readonly) SessionGroupEntity* rootCircleSessionGroup;
@property (nonatomic, strong, readonly) SessionGroupEntity* rootPublicAccountSessionGroup;//parent=rootChatSessionGroup
@property (nonatomic, strong, readonly) NSURL* userDataHome;//数据库存放目录
@property (nonatomic, strong, readonly) EmployeeEntity* currentUser;//当前登录的用户


/**
 * @brief [en] This method is used to get main thread context.
 *        <br>[cn] 主线程context
 *
 * @retval NSManagedObjectContext *       <b>:</b><br>[en] Return main thread context if success, or return nil.
 *                                                <br>[cn] 成功返回主线程context，失败返回nil
 * @attention [en] NA
 *            <br>[cn] NA
 * @see NA
 **/
- (NSManagedObjectContext*) managedObjectContext;


/**
 * @brief [en] This method is used to get background thread context.
 *        <br>[cn] 后台线程context
 *
 * @retval NSManagedObjectContext *       <b>:</b><br>[en] Return background thread context if success, or return nil.
 *                                                <br>[cn] 成功返回后台线程context，失败返回nil
 * @attention [en] NA
 *            <br>[cn] NA
 * @see NA
 **/
- (NSManagedObjectContext*) backgroundObjectContext;


/**
 * @brief [en] This method is used to get coredata model.
 *        <br>[cn] CoreData数据模型
 *
 * @retval NSManagedObjectModel *         <b>:</b><br>[en] Return coredata model if success, or return nil.
 *                                                <br>[cn] 成功返回CoreData数据模型，失败返回nil
 * @attention [en] NA
 *            <br>[cn] NA
 * @see NA
 **/
- (NSManagedObjectModel *)managedObjectModel;


/**
 * @brief [en] This method is used to get coredata persistent store coordinator.
 *        <br>[cn] CoreData中数据库存取的协调器
 *
 * @retval NSPersistentStoreCoordinator *         <b>:</b><br>[en] Return coordinator if success, or return nil.
 *                                                        <br>[cn] 成功返回协调器，失败返回nil
 * @attention [en] NA
 *            <br>[cn] NA
 * @see NA
 **/
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator;


/**
 * @brief [en] This method is used to memory context.
 *        <br>[cn] 缓存context
 *
 * @retval NSPersistentStoreCoordinator *         <b>:</b><br>[en] Return memory context if success, or return nil.
 *                                                        <br>[cn] 成功返回缓存context，失败返回nil
 * @attention [en] NA
 *            <br>[cn] NA
 * @see NA
 **/
- (NSManagedObjectContext*) memoryObjectContext;


/**
 * @brief [en] This method is used to init user account.
 *        <br>[cn] 类初始化
 *
 * @param [in] NSString* userAccount              <b>:</b><br>[en] Indicates user account.
 *                                                        <br>[cn] 用户账号
 * @retval id                                     <b>:</b><br>[en] Return if success, fail return nil.
 *                                                        <br>[cn] 成功返回，失败返回nil
 * @attention [en] distinguish according by account.
 *            <br>[cn] 根据账号进行区分
 * @see NA
 **/
- (id)initWithUserAccount:(NSString*)userAccount;


/**
 * @brief [en] This method is used to get session object of assistant.
 *        <br>[cn] 获取小e助手的session对象
 *
 * @param [in] NSManagedObjectContext* ctx        <b>:</b><br>[en] Indicates context.
 *                                                        <br>[cn] 所在的context
 * @retval AssistantSessionEntity *               <b>:</b><br>[en] Return seesion object if success, or return nil.
 *                                                        <br>[cn] 成功返回小e助手的session对象，失败返回nil
 * @attention [en] xxxx.
 *            <br>[cn] NA
 * @see NA
 **/
+ (AssistantSessionEntity*) assistantSessionEntityInContext:(NSManagedObjectContext*) ctx;


/**
 * @brief [en] This method is used to in appointed context and data table, search an object according by query condition.
 *        <br>[cn] 在指定的context和数据表中，根据搜索条件查询一个对象
 *
 * @param [in] NSPredicate* predicate             <b>:</b><br>[en] Indicates query condition.
 *                                                        <br>[cn] 搜索条件
 * @param [in] NSString* entityName               <b>:</b><br>[en] Indicates entity name.
 *                                                        <br>[cn] 数据表名称
 * @param [in] NSManagedObjectContext* context    <b>:</b><br>[en] Indicates context.
 *                                                        <br>[cn] 上下文
 * @retval id                                     <b>:</b><br>[en] Return query object if success, or return nil.
 *                                                        <br>[cn] 成功返回查询对象，失败返回nil
 * @attention [en] xxxx.
 *            <br>[cn] NA
 * @see NA
 **/
+ (id) fetchOneObject:(NSPredicate*) predicate inEnitity:(NSString*) entityName inContext:(NSManagedObjectContext*) context;


/**
 * @brief [en] This method is used to in appointed context and data table, search several object according by query condition.
 *        <br>[cn] 在指定的context和数据表中，根据搜索条件查询多个对象
 *
 * @param [in] NSPredicate* predicate             <b>:</b><br>[en] Indicates query condition.
 *                                                        <br>[cn] 搜索条件
 * @param [in] NSString* entityName               <b>:</b><br>[en] Indicates entity name.
 *                                                        <br>[cn] 数据表名称
 * @param [in] NSManagedObjectContext* context    <b>:</b><br>[en] Indicates context.
 *                                                        <br>[cn] 上下文
 * @retval NSArray *                              <b>:</b><br>[en] Return query object if success, or return nil.
 *                                                        <br>[cn] 成功返回查询对象数组，失败返回nil
 * @attention [en] NA.
 *            <br>[cn] NA
 * @see NA
 **/
+ (NSArray *) fetchObjects:(NSPredicate*) predicate inEnitity:(NSString*) entityName inContext:(NSManagedObjectContext*) context;


/**
 * @brief [en] This method is used to get chat root session.
 *        <br>[cn] 获取聊天的根session
 *
 * @param [in] NSManagedObjectContext* context    <b>:</b><br>[en] Indicates context.
 *                                                        <br>[cn] 上下文
 * @retval SessionGroupEntity *                   <b>:</b><br>[en] Return chat root session object, or return nil.
 *                                                        <br>[cn] 成功返回聊天的根session对象，失败返回nil
 * @attention [en] NA.
 *            <br>[cn] NA
 * @see NA
 **/
+ (SessionGroupEntity*) rootChatSessionGroupInContext:(NSManagedObjectContext*) context;


/**
 * @brief [en] This method is used to get root circle session group.
 *        <br>[cn] 获取同事圈的根session
 *
 * @param [in] NSManagedObjectContext* context    <b>:</b><br>[en] Indicates context.
 *                                                        <br>[cn] 上下文
 * @retval SessionGroupEntity *                   <b>:</b><br>[en] Return root circle session object, or return nil.
 *                                                        <br>[cn] 成功返回同事圈的根session对象，失败返回nil
 * @attention [en] NA.
 *            <br>[cn] NA
 * @see NA
 **/
+ (SessionGroupEntity*) rootCircleSessionGroupInContext:(NSManagedObjectContext*) context;


/**
 * @brief [en] This method is used to get public root session.
 *        <br>[cn] 获取公众号的根session
 *
 * @param [in] NSManagedObjectContext* context    <b>:</b><br>[en] Indicates context.
 *                                                        <br>[cn] 上下文
 * @retval SessionGroupEntity *                   <b>:</b><br>[en] Return public root session object if success, or return nil.
 *                                                        <br>[cn] 成功返回公众号的根session对象，失败返回nil
 * @attention [en] NA.
 *            <br>[cn] NA
 * @see NA
 **/
+ (SessionGroupEntity *)rootPublicAccountSessionInContext:(NSManagedObjectContext *)context;


/**
 * @brief [en] This method is used to get call root session.
 *        <br>[cn] 获取通话的根session
 *
 * @param [in] NSManagedObjectContext* context    <b>:</b><br>[en] Indicates context.
 *                                                        <br>[cn] 上下文
 * @retval SessionGroupEntity *                   <b>:</b><br>[en] Return call root session if success, or return nil.
 *                                                        <br>[cn] 成功返回通话的根session对象，失败返回nil
 * @attention [en] NA.
 *            <br>[cn] NA
 * @see NA
 **/
+ (SessionGroupEntity*) rootCallSessionGroupInContext:(NSManagedObjectContext*) context;


/**
 * @brief [en] This method is used to clean user account info.
 *        <br>[cn] 清空某个账号的信息
 *
 * @param [in] NSString* userAccount              <b>:</b><br>[en] Indicates user account.
 *                                                        <br>[cn] 用户账号
 * @attention [en] NA.
 *            <br>[cn] NA
 * @see NA
 **/
+ (void) cleanDataForUser:(NSString*) userAccount;


/**
 * @brief [en] This method is used to clean all user info of soffware.
 *        <br>[cn] 清除软件中所有的用户信息
 *
 * @attention [en] NA.
 *            <br>[cn] NA
 * @see NA
 **/
+ (void)cleanDataForAll;


/**
 * @brief [en] This method is used to judge whether exist user config .
 *        <br>[cn] 判断是否存在用户配置
 *
 * @retval BOOL *                   <b>:</b><br>[en] Return yes if true, or return no.
 *                                          <br>[cn] 是返回YES，否返回NO
 * @attention [en] NA.
 *            <br>[cn] NA
 * @see NA
 **/
+ (BOOL)isUserAccountExist;


/**
 * @brief [en] This method is used to get random message id.
 *        <br>[cn] 随机生成的消息id
 *
 * @retval NSString *               <b>:</b><br>[en] Return random message id if success,or return nil.
 *                                          <br>[cn] 成功返回随机字符串，失败返回nil
 * @attention [en] NA
 *            <br>[cn] NA
 * @see NA
 **/
- (NSString*) randomMessageId;


/**
 * @brief [en] This method is used to remove um resource info of user.
 *        <br>[cn] 清除用户的富媒体信息
 *
 * @param [in] NSString* userAccount   <b>:</b><br>[en] Indicates user account.
 *                                             <br>[cn] 用户账号
 * @attention [en] xxxx.
 *            <br>[cn] 仅删除原图
 * @see NA
 **/
+ (void)removeUmResourceForUser:(NSString *)userAccount;


/**
 * @brief [en] This method is used to get um resource file size of user.
 *        <br>[cn] 计算用户沙盒中富媒体文件的大小
 *
 * @param [in] NSString* userAccount              <b>:</b><br>[en] Indicates user account.
 *                                                        <br>[cn] 用户账号
 * @retval unsigned long long                     <b>:</b><br>[en] Return file size if success, unit is byte, fail reutn 0.
 *                                                        <br>[cn] 成功返回文件大小,单位byte，失败返回0
 * @attention [en] NA.
 *            <br>[cn] NA
 * @see NA
 **/
+ (unsigned long long)umFilesSizeForUser:(NSString *)userAccount;
@end
