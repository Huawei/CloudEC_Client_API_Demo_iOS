//
//  ESpaceContactService.h
//  eSpaceUI
//
//  Created by yemingxing on 3/19/15.
//  Copyright (c) 2015 www.huawei.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>

#import "EmployeeEntity.h"
#import "CallContactEntity.h"
#import "AssistantMessageEntity.h"
#import "MsgLogSessionEntity.h"
#import "CustomContactEntity.h"
#import "SpecialChatSessionEntity.h"
#import "ThirdPartSysEntity.h"
#import "ECSafeMutableDictionary.h"
//#import "ECSLoginService.h"
//#import "ECSGroupManageService.h"
//#import "ECSContactService.h"
#import "EmployeeEntity.h"

#import "tsdk_im_interface.h"
#import "TsdkChatMessage.h"
#import "SessionEntity.h"
#import "ChatMessageEntity.h"

extern NSString* ESPACE_USER_STATUS_CHANGED;
extern NSString* ESPACE_USER_STATUS_CHANGED_BY_ACCOUNT;
extern NSString* ESPACE_CONTACT_FULL_SYNC_FINISHED;
extern NSString* ESpaceAddFriendNotify;
extern NSString* ESpaceAddFriendNotify_TitleKey;
extern NSString* TUP_USER_STATUS_CHANGED;


typedef NS_ENUM(NSInteger, ESpaceSearchFlag) {
    ESpaceSearchFlagFuzzyMatch = 0,
    ESpaceSearchFlagExactMatch = 1// 来去电时通过号码匹配的场景，此时MAA服务器应使用精确查询（返回结果超过1个时，uc2.0返回多条，终端取第一条，华为uc则返回失败）
};

@interface ESpaceContactService : NSObject

+ (instancetype) sharedInstance;

//@property (nonatomic, strong, readonly) ECSContactService *contactService;
@property (nonatomic, assign, readonly) ECSLoginServiceStatus loginStatus;
@property (nonatomic, strong, readonly) NSMutableSet * validGroupHeadImages;
@property (nonatomic, strong, readonly) ECSafeMutableDictionary *nonFriendsRefreshTagsDic;// 记录非好友刷新标志
@property (nonatomic, copy) NSString *currentContactGroupId;

/**
 *  [en]
 *  [cn] 判断某个联系人是否有IM权限
 *
 *  @param employ eSpace联系人
 *
 *  @return IM权限能力
 */
+ (BOOL)imAbilityOfPerson:(EmployeeEntity*)employ;

/**
 *  [en]
 *  [cn] 判断某个联系人是否有状态权限
 *
 *  @param employ eSpace联系人
 *
 *  @return 状态权限能力
 */
+ (BOOL)presenceAbilityOfPerson:(EmployeeEntity*)employ;

/**
 *  [en]
 *  [cn] 隐藏小e助手session
 */
- (void) hideAssistentSession;

/**
 *  [en]
 *  [cn] 根据联系人创建对话session
 *
 *  @param contact 联系人
 *
 *  @return 对话session
 */
- (ChatSessionEntity *)createChatSessionForContact:(ContactEntity *)contact;

/**
 *  [en]
 *  [cn] 根据contact构造msgLog session
 *
 *  @param contact ContactEntity
 *
 *  @return MsgLogSessionEntity
 */
- (MsgLogSessionEntity *)creatMsgLogSessionForContact:(ContactEntity *)contact;

/**
 *  [en]
 *  [cn] 根据号码生成通话对象
 *
 *  @param phoneNumber 号码
 *  @param context     上下文
 *  @param bAutoCreate 是否自动创建对象
 *
 *  @return 通话对象
 */
- (CallContactEntity*) callContactWithPhoneNumber:(NSString*)phoneNumber
                                        inContext:(NSManagedObjectContext*)context
                                       autoCreate:(BOOL) bAutoCreate;
/**
 *  [en]
 *  [cn] 根据联系人账号生成联系人
 *
 *  @param userAccount 账号
 *  @param context     上下文
 *  @param bAutoCreate 自动创建
 *
 *  @return 联系人
 */
- (EmployeeEntity*) userWithAccount:(NSString*) userAccount
                          inContext:(NSManagedObjectContext*) context
                         autoCreate:(BOOL) bAutoCreate;
/**
 *  [en]
 *  [cn] 根据用户id创建自定义联系人
 *
 *  @param userId      用户id
 *  @param context     上下文
 *  @param bAutoCreate 自动创建
 *
 *  @return 自定义联系人
 */
- (CustomContactEntity*) customUserWithId:(NSString*)userId
                                inContext:(NSManagedObjectContext*)context
                                autoCreat:(BOOL)bAutoCreate;

/**
 *  [en]
 *  [cn] 根据分组id创建分组
 *
 *  @param categoryId  分组id
 *  @param context     上下文
 *  @param bAutoCreate 自动创建
 *
 *  @return 分组
 */
- (EmployeeCategoryEntity*) employeeCategoryWithId:(NSString*)categoryId
                                         inContext:(NSManagedObjectContext*)context
                                        autoCreate:(BOOL)bAutoCreate;

/**
 *  [en]
 *  [cn] 根据群组id创建群组
 *
 *  @param _id         群组id
 *  @param type        群组类型
 *  @param context     上下文
 *  @param bAutoCreate 自动创建
 *
 *  @return 群组
 */
- (GroupEntity*) groupWithId:(NSString*) _id
                        type:(NSInteger) type
                   inContext:(NSManagedObjectContext*) context autoCreate:(BOOL) bAutoCreate;

/**
 *  [en]
 *  [cn] 根据群组id查找群组
 *
 *  @param _id         群组id
 *  @param context     上下文
 *
 *  @return 群组
 */
- (GroupEntity*) groupWithId:(NSString*) _id inContext:(NSManagedObjectContext *)context;

/**
 *  [en]
 *  [cn]根据appName创建thirdPartSystemInfoEntity
 *  @param _appName    第三方系统名称
 *  @param context     上下文
 *  @param bAutoCreat  自动创建
 *  @return 是否全量同步
 */

- (ThirdPartSysEntity*) systemInfoWithAppID:(NSString *)appName
                                            inContex:(NSManagedObjectContext *)context
                                           autoCreat:(BOOL)bAutoCreate;
/**
 *  [en]
 *  [cn] 是否需要全量同步联系人
 *
 *  @return 是否全量同步
 */
- (BOOL) needFullSyncContacts;

/**
 *  [en]
 *  [cn] 全量同步联系人
 *
 *  @param completionBlock 结果回调
 */
- (void) fullSyncContacts:(void (^)(NSError* error)) completionBlock;

/**
 *  [en]
 *  [cn] 部分同步联系人
 *
 *  @param completionBlock 结果回调
 */
- (void) partialSyncContacts:(void (^)(NSError* error)) completionBlock;

/**
 *  [en]
 *  [cn] 根据联系人账号查找对应的状态信息
 *
 *  @param account 联系人账号
 *  @param bForce  是否强制订阅
 *
 *  @return 状态信息
 */
- (EspaceUserOnlineStatus*) onlineStatusForUser:(NSString*) account forceSubscribe:(BOOL) bForce;

/**
 *  [en]
 *  [cn] 获取联系人状态
 *
 *  @param account 联系人账号
 *
 *  @return 状态
 */
- (EspaceUserOnlineStatus*) onlineStatusForUser:(NSString*) account;

/**
 *  [en]
 *  [cn] 生成小e助手提示信息
 *
 *  @param msgId     消息id
 *  @param timestamp 时间
 *  @param readed    是否已读
 *  @param ctx       上下文
 *
 *  @return 小e助手提示信息
 */
- (AssistantMessageEntity*) createAssistantMessageWithId:(NSString*) msgId timestamp:(NSDate*)timestamp readed:(BOOL)readed inContext:(NSManagedObjectContext*) ctx;

/**
 *  [en]
 *  [cn] 同步联系人，内部会自动判断全量同步还是部分同步
 *
 *  @param completionBlock 结果回调
 */
- (void) syncContacts:(void (^)(NSError* error)) completionBlock;

/**
 *  [en]
 *  [cn] 同步第三方系统信息
 *
 *  @param completionBlock 结果回调
 */
- (void)syncThirdAppInfo:(void (^)(NSError* error)) completionBlock;

///**
// *  [en]
// *  [cn] 创建群组：支持传入成员对象进行创群
// *
// *  @param groupName       群名称
// *  @param groupType       群类型
// *  @param joinCondition   加入类型
// *  @param userAccounts    邀请用户列表
// *  @param announce        群组声明
// *  @param intro           群组简介
// *  @param completionBlock 结果回调
// */
//- (void) createGroupWithName:(NSString*) groupName
//                   groupType:(ECSGroupType) groupType
//               joinCondition:(ECSGroupJoinType) joinCondition
//                   initUsers:(NSArray *) users
//                    announce:(NSString*) announce
//                       intro:(NSString*) intro
//                  completion:(void (^)(NSString* groupId, NSString* failedList, NSError* error)) completionBlock;
//
///**
// *  [en]
// *  [cn] 创建群组:支持传入成员账号进行创群
// *
// *  @param groupName       群名称
// *  @param groupType       群类型
// *  @param joinCondition   加入类型
// *  @param userAccounts    邀请用户列表
// *  @param announce        群组声明
// *  @param intro           群组简介
// *  @param completionBlock 结果回调
// */
//- (void) createGroupWithName:(NSString*) groupName
//                   groupType:(ECSGroupType) groupType
//               joinCondition:(ECSGroupJoinType) joinCondition
//             userAccountList:(NSArray *) userAccounts
//                    announce:(NSString*) announce
//                       intro:(NSString*) intro
//                  completion:(void (^)(NSString* groupId, NSString* failedList, NSError* error)) completionBlock;
//
///**
// *  [en]
// *  [cn] 创建群组：支持传入成员对象进行创群
// *
// *  @param groupName       群名称
// *  @param groupType       群类型
// *  @param joinCondition   加入类型
// *  @param userAccounts    邀请用户列表
// *  @param announce        群组声明
// *  @param intro           群组简介
// *  @param completionBlock 结果回调
// */
//- (void) createGroupWithName:(NSString*) groupName
//                      enName:(NSString*) enName
//                   groupType:(ECSGroupType) groupType
//               joinCondition:(ECSGroupJoinType) joinCondition
//                   initUsers:(NSArray *) users
//                    announce:(NSString*) announce
//                       intro:(NSString*) intro
//                  completion:(void (^)(NSString* groupId, NSString* failedList, NSError* error)) completionBlock;
//
///**
// *  [en]
// *  [cn] 创建群组:支持传入成员账号进行创群
// *
// *  @param groupName       群名称
// *  @param groupType       群类型
// *  @param joinCondition   加入类型
// *  @param userAccounts    邀请用户列表
// *  @param announce        群组声明
// *  @param intro           群组简介
// *  @param completionBlock 结果回调
// */
- (void) createGroupWithName:(NSString*) groupName
                      enName:(NSString*) enName
                   groupType:(ECSGroupType) groupType
             userAccountList:(NSArray *) userAccounts
                ownerAccount:(NSString *) ownerAccount
                    announce:(NSString*) announce
                       intro:(NSString*) intro
                  completion:(void (^)(NSString* groupId, NSString* failedList, NSError* error)) completionBlock;

/**
 *  [en]
 *  [cn] 企业通讯录查询联系人
 *
 *  @param keyword         关键字
 *  @param pageIndex       页码
 *  @param pageSize        每页容量
 *  @param field           区域
 *  @param bShow           是否显示状态
 *  @param searchFlag      搜索类型
 *  @param ctx             上下文
 *  @param completionBlock 结果回调
 */
- (void) queryCorpAdressBook:(NSString*) keyword
                   pageIndex:(NSInteger) pageIndex
                    pageSize:(NSInteger) pageSize
                       field:(NSString*) field
                  showStatus:(BOOL) bShow
                  searchFlag:(ESpaceSearchFlag) searchFlag
                   inContext:(NSManagedObjectContext*) ctx
                  completion:(void (^)(NSError* error, NSInteger count)) completionBlock;

/**
 *  [en]
 *  [cn] 本地联系人查询
 *
 *  @param keyword         关键字
 *  @param pageIndex       页码
 *  @param pageSize        每页容量
 *  @param field           区域
 *  @param bShow           是否显示状态
 *  @param searchFlag      搜索类型
 *  @param ctx             上下文
 *  @param lastMaxWeight   权重
 *  @param completionBlock 结果回调
 */
- (void) queryCorpAdressBook:(NSString*) keyword
                   pageIndex:(NSInteger) pageIndex
                    pageSize:(NSInteger) pageSize
                       field:(NSString*) field
                  showStatus:(BOOL) bShow
                  searchFlag:(ESpaceSearchFlag) searchFlag
                   inContext:(NSManagedObjectContext*) ctx
                   maxWeight:(NSInteger)lastMaxWeight
                  completion:(void (^)(NSError* error, NSInteger count)) completionBlock;

/**
 *  [en]
 *  [cn] 添加陌生人到已有到分组
 *
 *  @param person          待添加的人
 *  @param team            要添加到的分组
 *  @param team            是否需要通知
 *  @param completionBlock 结果回调
 */
- (void)addFriend:(EmployeeEntity*)person toExistedTeam:(EmployeeCategoryEntity*)team notify:(BOOL)needNotify completion:(void (^)(NSError* error)) completionBlock;

/**
 *  [en]
 *  [cn] 添加陌生人到新创建分组
 *
 *  @param person          待添加的人
 *  @param teamName        新创建分组的名字
 *  @param team            是否需要通知
 *  @param completionBlock 结果回调
 */
- (void)addFriend:(EmployeeEntity *)person toNewTeam:(NSString *)teamName notify:(BOOL)needNotify completion:(void (^)(NSError *))completionBlock;


/**
 *  [en]
 *  [cn] 添加陌生人到已知分组
 *
 *  @param account 陌生人联系人账号
 *  @param teamID 联系人分组id
 *  @param needNotify 是否通知对方被加为好友
 *  @param completionBlock 完成回调
 *  @discuss 数据库存在联系人则可以直接调用以上的addFriend:方法，且EmployeeEntity和EmployeeCategoryEntity都必须是数据库NSManagedObjectContext中的对象；否则调用以下方法来自动在数据库创建联系人并同步联系人信息
 */
- (void)addFriendWith:(NSString*)account toExistedTeam:(NSString*)teamID notify:(BOOL)needNotify completion:(void (^)(NSError* error)) completionBlock;


/**
 *  [en]
 *  [cn] 添加陌生人到新建分组
 *
 *  @param account 陌生人联系人账号
 *  @param teamName 新建分组名
 *  @param needNotify 是否通知对方被加为好友
 *  @param completionBlock 完成回调
 *  @discuss 数据库存在联系人则可以直接调用以上的addFriend:方法，且EmployeeEntity和EmployeeCategoryEntity都必须是数据库NSManagedObjectContext中的对象；否则调用以下方法来自动在数据库创建联系人并同步联系人信息
 */
- (void)addFriendWith:(NSString *)account toNewTeam:(NSString *)teamName notify:(BOOL)needNotify completion:(void (^)(NSError *))completionBlock;

/**
 *  [en]
 *  [cn] 删除好友
 *
 *  @param person          待删除的好友
 *  @param completionBlock 结果回调
 */
- (void)deleteFriend:(EmployeeEntity*)person completion:(void (^)(NSError *))completionBlock;

/**
 *  [en]
 *  [cn] 将只存在内存中的employee拷贝到数据库中
 *
 *  @param memoryUser 内存对象
 *
 *  @return 数据库中创建的的对象
 */
- (EmployeeEntity*)employeeFromCopyMemoryUser:(EmployeeEntity*)memoryUser;

#pragma mark- 老版本升级到coreData版本时允许调用
/**
 *  [en]
 *  [cn] 强制构建eSpace联系人:仅升级时允许调用
 *
 *  @param userAccount 账号
 *  @param context     上下文
 *
 *  @return eSpace联系人
 */
- (EmployeeEntity*)forceCreatUserWithAccount:(NSString*)userAccount inContext:(NSManagedObjectContext*)context;

/**
 *  [en]
 *  [cn] 强制构建群组，仅升级时允许调用
 *
 *  @param _id     群组id
 *  @param type    类型
 *  @param context 上下文
 *
 *  @return 群组
 */
- (GroupEntity*)forceCreatGroupWithId:(NSString*)_id
                                 type:(NSInteger) type
                            inContext:(NSManagedObjectContext*)context;

/**
 *  [en]
 *  [cn] 升级时构建聊天对象
 *
 *  @param contact 联系人或群组
 *
 *  @return 特殊聊天对象
 */
- (SpecialChatSessionEntity *)createSpecialChatSessionForContact:(ContactEntity *)contact;

#pragma mark - contact search history record

/**
 *  [en]
 *  [cn] 查询搜索历史记录,最多10条
 *
 *  @return 数据库中创建的的对象
 */
- (ContactEntity *)insertSearchHistoryRecord:(ContactEntity *)insertContact;

/**
 *  [en]
 *  [cn] 查询搜索历史记录,最多10条
 *
 *  @return 数据库中创建的的对象
 */
- (NSArray *)querySearchHistoryRecord;

/**
 *  [en]
 *  [cn] 清空搜索历史纪录
 */
- (void)clearQuerySearchHistoryRecord;

#pragma mark-
- (void) getUserInfoWithAccount:(NSString *)account andContext:(NSManagedObjectContext*)bgCtx completionBlock:(void (^)(NSManagedObjectID* objectid, NSError* error)) completionBlock;

- (void) createContactGroupWithGroupName:(NSString *)name completionBlock:(void (^) (NSString * groupId, NSError* error))completionBlock;

- (void) deleteContactGroupWithGroupId:(NSString *)groupId completionBlock:(void (^) (NSError* error))completionBlock;


#pragma mark - setting
/**
 *  [en]
 *  [cn]设置签名
 *  @param signature       签名内容
 *  @param completionBlock 设置结果
 */
- (void) setSelfSignature:(NSString*)signature completion:(void(^)(NSError* error))completionBlock;

/**
 *  [en]
 *  [cn] 探测用户状态
 *  @param accountArray      用户账号数组
 */
- (void)detectUserStatusWithAccountArray:(NSArray *)accountArray;

/**
 *  [en]
 *  [cn]设置状态
 *  @param status          状态
 *  @param completionBlock 设置结果
 */
- (void) setSelfStatus:(ESpaceUserStatus)status completion:(void(^)(NSError* error))completionBlock;

#pragma mark - message

- (void)sendMessageWithMessage:(TsdkSendChatMsgInfo *)messageInfo completion:(void(^)(TsdkSendChatMsgResult *result ,NSError *error))completionBlock;

- (ChatMessageEntity*) createMessageForSession:(SessionEntity*) session
                                     timestamp:(NSDate*) date
                                        readed:(BOOL) readed;

- (void)setInputStateWithAccount:(NSString *)account isInPuttin:(BOOL)isInPutting;

- (void)setMessageIsReadedWithReadinfoArray:(NSArray *)msgReadInfo;

- (void)queryHistoryMessagesWithParam:(TsdkQueryHistoryMsgParam *)param andObjectId:(NSManagedObjectID *)objectId;

- (void)deleteHistoryMessageWithParam:(TsdkDeleteHistoryMsgParam *)param;

- (void)withDrawMessageParam:(TsdkMsgWithDrawReqParam *)param;

- (void)moveFriendToNewGroupWithNewGroupId:(NSString *)newGroupId andContactId:(NSString *)contactId andAccount:(NSString *)account;

@end
