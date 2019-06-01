/**
 * @file GroupEntity+ServiceObject.h
 *
 * Copyright (c) 2017 Huawei Tech. Co., Ltd. All rights reserved. \n
 *
 * @brief [en]Description:TUP group business operations class head file .
 * [cn]描述：TUP 群组业务操作类头文件。 \n
 **/

#import "GroupEntity.h"
//#import "ECSGroupManageService.h"

#import "tsdk_im_def.h"
#import "Defines.h"

/**
 * [en]This enum is about group sign type.
 * [cn]群组标记类型
 */
typedef NS_ENUM(NSInteger, ECSMarkGroupType){
    
    ChatGroupModifyDefaultParam = 0,     /**< [en]Indicates xxxx
                                                     [cn]修改默认参数，即群组中可修改的所有参数 */
    ChatGroupModifyOwner,                 /**< [en]Indicates xxxx
                                                     [cn]修改(转移)群组管理员 */
    ChatGroupModifyMsgPromotPolicy,     /**< [en]Indicates xxxx
                                                     [cn]修改群组消息提示策略 */
    ChatGroupModifyFixDiscussStauts,    /**< [en]Indicates xxxx
                                                     [cn]修改讨论组固化状态 */
    ChatGroupModifyGroupType,
    
    ChatGroupModifyBuff,
};

/**
 * [en]This enum is about group mute.
 * [cn]群组静音操作
 */
typedef NS_ENUM(NSInteger, ECSMarkGroupMuteOption){
    ECSMarkGroupReceiveMute = 0,    /**< [en]Indicates mute.
                                     <br>[cn]静音 */
    ECSMarkGroupReceiveUnmute = 1,  /**< [en]Indicates unmute.
                                     <br>[cn]取消静音 */
};

/**
 * [en]This enum is about group fixed operation .
 * [cn]群组固化操作
 */
typedef NS_ENUM(NSInteger, ECSMarkGroupFixOption){
    ECSMarkGroupUnfixed = 0,        /**< [en]Indicates unfixed.
                                     <br>[cn]取消固化 */
    ECSMarkGroupFixed = 1,          /**< [en]Indicates fixed .
                                     <br>[cn]固化 */
};

/**
 * [en]This enum is about group mark of like  .
 * [cn]群组喜欢操作
 */
typedef NS_ENUM(NSInteger, ECSMarkGroupFavourite) {
    ECSMarkGroupUnfavourited = 0,   /**< [en]Indicates abolish like.
                                     <br>[cn]取消喜欢 */
    ECSMarkGroupFavourited = 1,     /**< [en]Indicates like.
                                     <br>[cn]喜欢 */
};

typedef NS_ENUM(NSInteger, ECSGroupManageType) {
    ECSGroupCreate = 0,
    ECSGroupDelete = 1,
    ECSGroupModify = 2,
    ECSGroupTransferAdmin = 3,
    ECSGroupChangeType = 4,
    ECSGroupAdministratorQuitButNotDismiss = 5,
    ECSGroupModifyGroupSpace = 6
};

typedef NS_ENUM(NSInteger, ECSGroupJoinType) {
    ECSGroupJoinAuto = 0,
    ECSGroupJoinApply = 1,
    ECSGroupJoinDeny = 2
};


/**
 * [en] This class is about group information.
 * [cn] 群组信息类
 **/
@interface GroupSpaceInfo : NSObject

@property (nonatomic, strong) NSNumber *id;//long
@property (nonatomic, copy) NSString *name;//string 团队空间名称
@property (nonatomic, copy) NSString *description;//tring 团队空间描述
@property (nonatomic, strong) NSNumber *curNumbers;//int 成员数量
@property (nonatomic, strong) NSNumber *createdAt;//long 创建时间
@property (nonatomic, copy) NSString *createdBy;//long 创建者的id
@property (nonatomic, copy) NSString *createdByUserName;//string 创建者的名称
@property (nonatomic, strong) NSNumber *ownedBy;//long 拥有者的id
@property (nonatomic, copy) NSString *ownedByUserName;//string 拥有者的名称
@property (nonatomic, strong) NSNumber *spaceQuota;//long团队空间容量，单位字节
@property (nonatomic, strong) NSNumber *status;//byte 状态：0可用；1:禁用
@property (nonatomic, strong) NSNumber *spaceUsed;//long 团队空间已使用的容量，单位为字节
@property (nonatomic, strong) NSNumber *maxVersions;//int最大版本数，默认值－1，表示无限制
@property (nonatomic, strong) NSNumber *maxMembers;//int 团队空间最大成员数限制，默认－1，表示无限制
@property (nonatomic, strong) NSNumber *regionId;//int 存储区域id

@end


/**
 * [en] This class is about group business operation .
 * [cn] 群组业务操作类
 **/
@interface GroupEntity (ServiceObject)


/**
 * @brief [en]This method is used to query group icon portrait membership information .
 *        <br>[cn] 查询群组头像拼接的成员信息
 *
 * @param [out] completionBlock             <b>:</b><br>[en] Indicates handle result block carry error message and member information array .
 *                                                  <br>[cn] 处理结果Block，携带错误信息和获取到的成员信息数组(NSError*, NSArray*)
 * @attention [en] NA.
 *            <br>[cn] NA
 * @see NA
 **/
- (void) queryMemberInfoForGroupPic:(void (^)(NSError* error, NSArray *info)) completionBlock;


/**
 * @brief [en]This method is used to load group icon portrait.
 *        <br>[cn] 重载群组头像
 *
 * @param [in] BOOL* needForceLoad     <b>:</b><br>[en] Indicates forced loading default NO.
 *                                             <br>[cn] 是否强制加载；默认传NO即可
 * @attention [en] KVO GroupEntity`s state attribute call GroupEntity`s headImageLocalPath method gets the path to the downloaded picture .
 *                 warning:Unity by context`s core object of data call
 *            <br>[cn] KVO GroupEntity的state属性, 调用GroupEntity的headImageLocalPath方法获取下载的图片的路径。
 *            <br>[cn] 注意:此方法都统一由main context的core data对象调用，否则无法通过headLocalStatus保证无重复调用
 * @see NA
 **/
- (void) reloadHeadImage:(BOOL)needForceLoad;


/**
 * @brief [en]This method is used to load head image.
 *        <br>[cn] 获取群组头像
 *
 * @param [in] BOOL* needForceLoad     <b>:</b><br>[en] Indicates need forced loading if false queried content will not be repeat  .
 *                                             <br>[cn] 是否需要强制获取，NO则对于查询过的不会重复查询
 * @param [out] completionBlock        <b>:</b><br>[en] Indicates handle result block carry error message and icon portrait .
 *                                             <br>[cn] 处理结果Block，携带获取到的群组头像和错误信息(UIImage*, NSError*)
 * @attention [en] NA.
 *            <br>[cn] NA
 * @see NA
 **/
- (void) loadHeadImage:(BOOL)needForceLoad completion:(void (^)(UIImage* imageData, NSError* error)) completionBlock;


/**
 * @brief [en]This method is used to queried group members .
 *        <br>[cn] 查询群组成员
 *
 * @param [out] completionBlock             <b>:</b><br>[en] Indicates handle result block carry error message.
 *                                                  <br>[cn] 处理结果Block，携带错误信息(NSError*)
 * @attention [en] NA.
 *            <br>[cn] NA
 * @see NA
 **/
- (void) queryGroupMember:(void (^)(NSError* error)) completionBlock;


/**
 * @brief [en]This method is used to dismiss group .
 *        <br>[cn] 解散群组
 *
 * @param [out] completionBlock             <b>:</b><br>[en] Indicates handle result block carry error message.
 *                                                  <br>[cn] 处理结果Block，携带错误信息(NSError*)
 * @attention [en] NA.
 *            <br>[cn] NA
 * @see NA
 **/
- (void) dismiss:(void (^)(NSError* error)) completionBlock;


/**
 * @brief [en]This method is used to transfer group administrator privileges .
 *        <br>[cn] 转移群组管理员权限
 *
 * @param [in] EmployeeEntity* other   <b>:</b><br>[en] Indicates new administrator.
 *                                             <br>[cn] 新的管理员
 * @param [out] completionBlock        <b>:</b><br>[en] Indicates handle result block carry error message.
 *                                             <br>[cn] 处理结果Block，携带错误信息(NSError*)
 * @attention [en] NA.
 *            <br>[cn] NA
 * @see NA
 **/
- (void) transferAdminTo:(EmployeeEntity*) other completion:(void (^)(NSError* error)) completionBlock;


/**
 * @brief [en]This method is used to converted to fixed group or discussion group  .
 *        <br>[cn] 转换固定群或者讨论组
 *
 * @param [in] ECSGroupType* gt        <b>:</b><br>[en] Indicates converted to fixed group write ECSFixGroup，discussion group write ECSChatGroup.
 *                                             <br>[cn] 转成固定群填写ECSFixGroup，转成讨论组填ECSChatGroup
 * @param [out] completionBlock        <b>:</b><br>[en] Indicates handle result block carry error message.
 *                                             <br>[cn] 处理结果Block，携带错误信息(NSError*)
 * @attention [en] NA.
 *            <br>[cn] NA
 * @see NA
 **/
- (void) changeGroupTypeTo:(ECSGroupType) gt completion:(void (^)(NSError* error)) completionBlock;


/**
 * @brief [en]This method is used to update group information .
 *        <br>[cn] 修改群组信息
 *
 * @param [in] NSString* groupName               <b>:</b><br>[en] Indicates new group name.
 *                                                       <br>[cn] 新群组名称
 * @param [in] ECSGroupJoinType* joinCondition   <b>:</b><br>[en] Indicates join type. 0:unconditional 1:need validation 2:not allowed to join .
 *                                                       <br>[cn] 加入群组类型，0 自由加入；1需要验证；2：不允许加入。对应GroupEntity的joinFlag字段的值
 * @param [in] NSString* announce                <b>:</b><br>[en] Indicates new notice .
 *                                                       <br>[cn] 新公告
 * @param [in] NSString* intro                   <b>:</b><br>[en] Indicates new brief introduction .
 *                                                       <br>[cn] 新简介
 * @param [out] completionBlock                  <b>:</b><br>[en] Indicates handle result block carry error message.
 *                                                       <br>[cn] 处理结果Block，携带错误信息(NSError*)
 * @attention [en] Indicates contain name /notice/brief introduction
 *            <br>[cn] 包括名称/群公告/群简介，相关参数每次只能修改一个
 * @see NA
 **/
- (void) updateGroupWithName:(NSString*) groupName
               joinCondition:(ECSGroupJoinType) joinCondition
                    announce:(NSString*) announce
                       intro:(NSString*) intro
                  completion:(void (^)(NSError* error)) completionBlock;

/**
 * @brief [en]This method is used to modify group information.
 *        <br>[cn] 修改群组信息
 *
 * @param [in] NSString* groupName               <b>:</b><br>[en] Indicates new group name.
 *                                                       <br>[cn] 新群组名称
 * @param [in] NSString* enName                  <b>:</b><br>[en] Indicates english group name.
 *                                                       <br>[cn] 英文群组名
 * @param [in] NSString* announce                <b>:</b><br>[en] Indicates new notice.
 *                                                       <br>[cn] 新公告
 * @param [in] NSString* intro                   <b>:</b><br>[en] Indicates new brief introduction.
 *                                                       <br>[cn] 新简介
 * @param [out] completionBlock                  <b>:</b><br>[en] Indicates handle result block carry error message.
 *                                                       <br>[cn] 处理结果Block，携带错误信息(NSError*)
 * @attention [en] Indicates contain name /notice/brief introduction.
 *            <br>[cn] 包括名称/群公告/群简介/英文群组名，相关参数每次只能修改一个
 * @see NA
 **/
- (void) updateGroupWithName:(NSString*) groupName
                      enName:(NSString*) enName
               joinCondition:(ECSGroupJoinType) joinCondition
                    announce:(NSString*) announce
                       intro:(NSString*) intro
                  completion:(void (^)(NSError* error)) completionBlock;


/**
 * @brief [en]This method is used to invite to join groups.
 *        <br>[cn] 邀请加入群组
 *
 * @param [in] NSArray* userAccounts             <b>:</b><br>[en] Indicates invite group member account number 
 *                                                       <br>[cn] 邀请的群组成员的帐号
 * @param [in] NSString* desc                    <b>:</b><br>[en] Indicates add description default null 
 *                                                       <br>[cn] 添加描述，通常情况下传空
 * @param [out] completionBlock                  <b>:</b><br>[en] Indicates handle result block carry error message and add failed member account .
 *                                                       <br>[cn] 处理结果Block，携带添加失败的成员账号和错误信息(NSString*, NSError*)
 * @attention [en] Indicates add failed member account semicolon separation 
 *            <br>[cn] 添加失败的成员账号之间用分号隔开
 * @see NA
 **/
- (void) inviteUsers:(NSArray*) userAccounts
                desc:(NSString*) desc
          completion:(void (^)(NSString* faildList, NSError* error)) completionBlock;

//todo jl
/**
 * @brief [en]This method is used to invite to join groups.
 *        <br>[cn] 邀请加入群组
 *
 * @param [in] NSArray* userAccounts             <b>:</b><br>[en] Indicates invite group member account number
 *                                                       <br>[cn] 邀请的群组成员的帐号
 * @param [in] NSString* desc                    <b>:</b><br>[en] Indicates add description default null
 *                                                       <br>[cn] 添加描述，通常情况下传空
 * @param [out] completionBlock                  <b>:</b><br>[en] Indicates handle result block carry error message and add failed member account .
 *                                                       <br>[cn] 处理结果Block，携带添加失败的成员账号和错误信息(NSString*, NSError*)
 * @attention [en] Indicates add failed member account semicolon separation
 *            <br>[cn] 添加失败的成员账号之间用分号隔开
 * @see NA
 **/
- (void) inviteUser:(NSString*) userAccount
                desc:(NSString*) desc
          completion:(void (^)(NSString* faildList, NSError* error)) completionBlock;


/**
 * @brief [en]This method is used to apply to join group.
 *        <br>[cn] 发起加入群组请求
 *
 * @param [in] NSString* desc                    <b>:</b><br>[en] Indicates join group of description.
 *                                                       <br>[cn] 入群的请求说明
 * @param [out] completionBlock                  <b>:</b><br>[en] Indicates handle result block carry error message.
 *                                                       <br>[cn] 处理结果Block，携带错误信息(NSError*)
 * @attention [en] NA.
 *            <br>[cn] NA
 * @see NA
 **/
- (void) applyToJoinWithDesc:(NSString*) desc
                  completion:(void (^)(NSError* error)) completionBlock;


/**
 * @brief [en]This method is used to leave group.
 *        <br>[cn] 离开群组
 *
 * @param [out] completionBlock                  <b>:</b><br>[en] Indicates handle result block carry error message.
 *                                                       <br>[cn] 处理结果Block，携带错误信息(NSError*)
 * @attention [en] NA.
 *            <br>[cn] NA
 * @see NA
 **/
- (void) leaveGroup:(void (^)(NSError* error)) completionBlock;


/**
 * @brief [en]This method is used to kick users.
 *        <br>[cn] 踢出群组
 *
 * @param [in] NSArray* userAccounts             <b>:</b><br>[en] Indicates account number of the group members kicking out .
 *                                                       <br>[cn] 踢出的群组成员的帐号
 * @param [out] completionBlock                  <b>:</b><br>[en] Indicates treatment result block carry error message.
 *                                                       <br>[cn] 处理结果Block，携带错误信息(NSError*)
 * @attention [en] NA.
 *            <br>[cn] NA
 * @see NA
 **/
- (void) kickUsers:(NSArray*) userAccounts
        completion:(void (^)(NSError* error)) completionBlock;


/**
 * @brief [en]This method is used to mute group .
 *        <br>[cn] 设置屏蔽群组消息提醒
 *
 * @param [out] completionBlock                  <b>:</b><br>[en] Indicates handle result block carry error message.
 *                                                       <br>[cn] 处理结果Block，携带错误信息(NSError*)
 * @attention [en] NA.
 *            <br>[cn] NA
 * @see NA
 **/
- (void) muteGroup:(void (^)(NSError* error)) completionBlock;


/**
 * @brief [en]This method is used to cancel mute group.
 *        <br>[cn] 取消屏蔽群组消息提醒
 *
 * @param [out] completionBlock                  <b>:</b><br>[en] Indicates handle result block carry error message.
 *                                                       <br>[cn] 处理结果Block，携带错误信息(NSError*)
 * @attention [en] NA.
 *            <br>[cn] NA
 * @see NA
 **/
- (void) unmuteGroup:(void (^)(NSError* error)) completionBlock;


/**
 * @brief [en]This method is used to lock group .
 *        <br>[cn] 锁定群组
 *
 * @param [out] completionBlock                  <b>:</b><br>[en] Indicates handle result block carry error message.
 *                                                       <br>[cn] 处理结果Block，携带错误信息(NSError*)
 * @attention [en] NA.
 *            <br>[cn] NA
 * @see NA
 **/
- (void) fixGroup:(void (^)(NSError* error)) completionBlock;


/**
 * @brief [en]This method is used to cancel lock group.
 *        <br>[cn] 解除群组锁定
 *
 * @param [out] completionBlock                  <b>:</b><br>[en] Indicates handle result block carry error message.
 *                                                       <br>[cn] 处理结果Block，携带错误信息(NSError*)
 * @attention [en] NA.
 *            <br>[cn] NA
 * @see NA
 **/
- (void) unfixGroup:(void (^)(NSError* error)) completionBlock;


/**
 * @ingroup xxxx.
 * @brief [en]This method is used to fill groupInfo field .
 *        <br>[cn] 填充GroupInfo对应的字段
 *
 * @param [in] GroupInfo* info                  <b>:</b><br>[en] Indicates group information.
 *                                                      <br>[cn] 群组信息
 * @param [in] BOOL* flag                       <b>:</b><br>[en] Indicates whether need group member .
 *                                                      <br>[cn] 是否需要群成员
 * @attention [en] NA
 *            <br>[cn] NA
 * @see NA
 **/
- (void) fillGroupInfo:(GroupInfo *)info needGroupMember:(BOOL)flag;


///**
// * @brief [en]This method is used to collect or cancel collect group.
// *        <br>[cn] 收藏/取消收藏群组
// *
// * @param [in] BOOL* favourited                  <b>:</b><br>[en] Indicates whether collect.
// *                                                       <br>[cn] 是否收藏
// * @param [out] completionBlock                  <b>:</b><br>[en] Indicates handle result block carry error message.
// *                                                       <br>[cn] 处理结果Block，携带错误信息(NSError*)
// * @attention [en] NA.
// *            <br>[cn] NA
// * @see NA
// **/
//- (void)favouriteGroup:(BOOL)favourited  completion:(void (^)(NSError* error)) completionBlock;


/**
 * @brief [en]This method is used to open group space .
 *        <br>[cn] 开启群空间
 *
 * @param [out] completionBlock                  <b>:</b><br>[en] Indicates handle result block carry error message.
 *                                                       <br>[cn] 处理结果Block，携带错误信息(NSError*)
 * @attention [en] NA.
 *            <br>[cn] NA
 * @see NA
 **/
- (void)openGroupSpaceInfo:(void (^)(NSError* error)) completionBlock;
@end
