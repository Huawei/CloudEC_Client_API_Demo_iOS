/**
 * @file GroupEntity.h
 *
 * Copyright (c) 2017 Huawei Tech. Co., Ltd. All rights reserved. \n
 *
 * @brief [en]Description:group object basic servic component info class head file.
 * [cn]描述：群组对象基础业务组件信息类头文件。 \n
 **/

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "ContactEntity.h"

/**
 * [en]This enum is about group status.
 * [cn]群组状态
 */
typedef NS_ENUM(NSInteger, ESpaceGroupState) {
    ESpaceGroupStateExist = 0,                  /**< [en]Indicates normal.
                                                 <br>[cn]正常状态 */
    ESpaceGroupStateKicked = 1,                 /**< [en]Indicates kicked.
                                                 <br>[cn]被剔出群组 */
    ESpaceGroupStateLeaveActively = 2,          /**< [en]Indicates leave actively.
                                                 <br>[cn]主动离开群组 */
    ESpaceGroupStateDismissed = 4,              /**< [en]Indicates dismissed.
                                                 <br>[cn]群解散 */
    ESpaceGroupStateDisappearedUnKnow = 8,      /**< [en]Indicates disappeared unknow reason.
                                                 <br>[cn]未知原因群丢失 */
    ESpaceGroupStateMemberLoaded = 0x1000000    /**< [en]Indicates member loaded.
                                                 <br>[cn]群组成员已加载 */
};

@class EmployeeEntity, GroupFileEntity;

/**
 * [en] This class is about group entity basic service component info.
 * [cn] 群组对象基础业务组件信息类
 **/
@interface GroupEntity : ContactEntity

@property (nonatomic, retain) NSString * announce;
@property (nonatomic, retain) NSNumber * capacity;
@property (nonatomic, retain) NSNumber * fixed;
@property (nonatomic, retain) NSNumber * groupType; /* ECSGroupType */
@property (nonatomic, retain) NSString * intro;
@property (nonatomic, retain) NSNumber * joinFlag;//0:自由加入;1:需要验证;2:不允许加入
@property (nonatomic, retain) NSString * ownerId;
@property (nonatomic, retain) NSNumber * msgRecvOpt;
@property (nonatomic, retain) NSString * baseFileId;
@property (nonatomic, retain) NSSet *members;
@property (nonatomic, retain) EmployeeEntity *owner;
@property (nonatomic, retain) NSNumber * state; /* ESpaceGroupState */
@property (nonatomic, retain) GroupFileEntity * rootFolder;
@property (nonatomic, retain) NSNumber * isFavourited;
@property (nonatomic, retain) NSString * enName;
@property (nonatomic, retain) NSString * groupSpaceInfo;

/**
 * @brief [en] This method is used to get group file path by group id.
 *        <br>[cn] 根据群id获取群文件路径
 *
 * @param [in] NSString* groupId    <b>:</b><br>[en] Indicates group id.
 *                                          <br>[cn] 群组id
 * @retval NSString *               <b>:</b><br>[en] Return group file path if success, or return nil.
 *                                          <br>[cn] 成功返回群文件路径，失败返回nil
 * @attention [en] NA
 *            <br>[cn] NA
 * @see NA
 **/
+ (NSString*) directoryForGoupFilesWithId:(NSString*) groupId;

/**
 * @brief [en] This method is used to get group file path.
 *        <br>[cn] 获取群文件路径
 *
 * @retval NSString *               <b>:</b><br>[en] Return group file path if success, or return nil.
 *                                          <br>[cn] 成功返回群文件路径，失败返回nil
 * @attention [en] NA
 *            <br>[cn] NA
 * @see NA
 **/
- (NSString*) directoryForGoupFiles;

/**
 * @brief [en] This method is used to get group file thumbnails path.
 *        <br>[cn] 群文件缩略图路径
 *
 * @retval NSString *               <b>:</b><br>[en] Return thumbnails path if success, or return nil.
 *                                          <br>[cn] 成功返回缩略图路径，失败返回nil
 * @attention [en] NA
 *            <br>[cn] NA
 * @see NA
 **/
- (NSString*) directoryForGroupFileThumbnails;

/**
 * @brief [en] This method is used to get group member head id.
 *        <br>[cn] 群成员的头像id
 *
 * @param [in] NSSet* members       <b>:</b><br>[en] Indicates group member object.
 *                                          <br>[cn] 群成员对象
 * @retval NSString *               <b>:</b><br>[en] Indicates .
 *                                          <br>[cn] 群成员的头像id
 * @attention [en] NA
 *            <br>[cn] NA
 * @see NA
 **/
- (NSString*)headIdFromMembers:(NSSet*) members;

/**
 * @brief [en] This method is used to judge group member change whether should change head id.
 *        <br>[cn] 判断群组成员变化时是否改变群头像ID
 *
 * @param [in] NSString* memberId   <b>:</b><br>[en] Indicates member id.
 *                                          <br>[cn] 成员id
 * @param [in] NSString* headId     <b>:</b><br>[en] Indicates head id.
 *                                          <br>[cn] 头像id
 * @retval BOOL                     <b>:</b><br>[en] Return yes if true, or return no.
 *                                          <br>[cn] 是返回YES，否返回NO
 * @attention [en] NA.
 *            <br>[cn] NA
 * @see NA
 **/
- (BOOL)shouldChangeHeadIdWithMemberChanged:(NSString*) memberId headId:(NSString*) headId;

/**
 * @brief [en] This method is used to judge group member change whether should change head id.
 *        <br>[cn] 判断群组成员变化时是否改变群头像ID
 *
 * @param [in] EmployeeEntity* employee     <b>:</b><br>[en] Indicates group member.
 *                                                  <br>[cn] 群成员
 * @retval BOOL                             <b>:</b><br>[en] Return yes if true, or return no.
 *                                                  <br>[cn] 是返回YES，否返回NO
 * @attention [en] NA.
 *            <br>[cn] NA
 * @see NA
 **/
- (BOOL)shouldChangeHeadIdWithMemberChanged:(EmployeeEntity*) employee;


/**
 * @brief [en] This method is used to check is fixGroup.
 *        <br>[cn] 判断是否为固定群
 *
 * @retval BOOL                     <b>:</b><br>[en] Return yes if true, or return no.
 *                                          <br>[cn] 是返回YES，否返回NO
 * @attention [en] NA.
 *            <br>[cn] NA
 * @see NA
 **/
- (BOOL)isFixGroup;


/**
 * @brief [en] This method is used to check is disscussion Group.
 *        <br>[cn] 判断是否为讨论组
 *
 * @retval BOOL                     <b>:</b><br>[en] Return yes if true, or return no.
 *                                          <br>[cn] 是返回YES，否返回NO
 * @attention [en] NA.
 *            <br>[cn] NA
 * @see NA
 **/
- (BOOL)isChatGroup;


/**
 * @brief [en] This method is used to check is group owner.
 *        <br>[cn] 判断是否是群主
 *
 * @retval BOOL                     <b>:</b><br>[en] Return yes if true, or return no.
 *                                          <br>[cn] 是返回YES，否返回NO
 * @attention [en] NA.
 *            <br>[cn] NA
 * @see NA
 **/
- (BOOL)checkPermission;


/**
 * @brief [en] This method is used to check whether the group contain this employee.
 *        <br>[cn] 判断群组是否包含某个联系人
 *
 * @param [in] EmployeeEntity* employee         <b>:</b><br>[en] Indicates .
 *                                                      <br>[cn] 联系人
 * @retval BOOL                                 <b>:</b><br>[en] Return yes if true, or return no.
 *                                                      <br>[cn] 是返回YES，否返回NO
 * @attention [en] NA.
 *            <br>[cn] NA
 * @see NA
 **/
- (BOOL)containsMember:(EmployeeEntity *)employee;


/**
 * @brief [en] This method is used to sorted by name with owner in first.
 *        <br>[cn] 群组成员排序，群主排在首位
 *
 * @retval NSArray *                <b>:</b><br>[en] return sorted array or empty if member contains nobody.
 *                                          <br>[cn] 成功返回排序后的成员数组，失败返回nil
 * @attention [en] NA
 *            <br>[cn] NA
 * @see NA
 **/
- (NSArray *)sortedMembers;
@end

@interface GroupEntity (CoreDataGeneratedAccessors)

/**
 * @brief [en] This method is used to add members object.
 *        <br>[cn] 添加成员对象
 *
 * @param [in] EmployeeEntity* value                <b>:</b><br>[en] Indicates group member object.
 *                                                          <br>[cn] 成员对象
 * @attention [en] NA.
 *            <br>[cn] NA
 * @see NA
 **/
- (void)addMembersObject:(EmployeeEntity *)value;

/**
 * @brief [en] This method is used to remove member object.
 *        <br>[cn] 删除成员对象
 *
 * @param [in] EmployeeEntity* value                <b>:</b><br>[en] Indicates member object.
 *                                                          <br>[cn] 成员对象
 * @attention [en] NA.
 *            <br>[cn] NA
 * @see NA
 **/
- (void)removeMembersObject:(EmployeeEntity *)value;

/**
 * @brief [en] This method is used to add member object set
 *        <br>[cn] 添加成员对象集合
 *
 * @param [in] NSSet* values                        <b>:</b><br>[en] Indicates group member object set.
 *                                                          <br>[cn] 成员对象(EmployeeEntity *)集合
 * @attention [en] NA.
 *            <br>[cn] NA
 * @see NA
 **/
- (void)addMembers:(NSSet *)values;

/**
 * @brief [en] This method is used to remove member object set.
 *        <br>[cn] 删除成员对象集合
 *
 * @param [in] NSSet* values                        <b>:</b><br>[en] Indicates member object set.
 *                                                          <br>[cn] 成员对象(EmployeeEntity *)集合
 * @attention [en] NA.
 *            <br>[cn] NA
 * @see NA
 **/
- (void)removeMembers:(NSSet *)values;

@end

/**
 * [en] This class is about group notify.
 * [cn] 用于群组通知类
 **/
@interface GroupInfo : NSObject
@property (nonatomic, copy) NSString *groupId;
@property (nonatomic, strong) NSString* groupName;
@property (nonatomic, strong) NSString* groupHeadImg;
@property (nonatomic, strong) NSString* groupMemberNum;                    //成员个数
@property (nonatomic, strong) NSMutableArray*  groupMemberlist;            //群组成员账号列表

/**
 * @brief [en] This method is used to add group info.
 *        <br>[cn] 添加群组信息
 *
 * @param [in] NSMutableDictionary* dir             <b>:</b><br>[en] Indicates group info object.
 *                                                          <br>[cn] 群组信息对象
 * @attention [en] NA.
 *            <br>[cn] NA
 * @see NA
 **/
- (void)addValueForDir:(NSMutableDictionary *)dir;
@end
