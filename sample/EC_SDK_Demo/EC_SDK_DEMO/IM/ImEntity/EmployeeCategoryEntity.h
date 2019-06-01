/**
 * @file EmployeeCategoryEntity.h
 *
 * Copyright (c) 2017 Huawei Tech. Co., Ltd. All rights reserved. \n
 *
 * @brief [en]Description:Employee dept basic service function info class head file.
 * [cn]描述：职员部门基础业务功能信息类头文件。 \n
 **/

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class EmployeeEntity;

/**
 * [en] This class is about custom define contact basic info.
 * [cn] 自定义联系人基础信息类
 **/
@interface EmployeeCategoryEntity : NSManagedObject

@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) NSNumber * idx;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * num;
@property (nonatomic, retain) NSSet *members;
@property (nonatomic, retain) NSDate * lastUpdateTime;
@end

/**
 * [en] This class is about custom define contact basic service entity.
 * [cn] 自定义联系人基础业务功能类
 **/
@interface EmployeeCategoryEntity (CoreDataGeneratedAccessors)

/**
 * @brief [en] This method is used to add members object.
 *        <br>[cn] 添加成员对象
 *
 * @param [in] EmployeeEntity* value                <b>:</b><br>[en] Indicates member object.
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
 * @brief [en] This method is used to add members set.
 *        <br>[cn] 添加成员集合
 *
 * @param [in] NSSet* values                        <b>:</b><br>[en] Indicates member set.
 *                                                          <br>[cn] 成员对象(EmployeeEntity *)集合
 * @attention [en] NA.
 *            <br>[cn] NA
 * @see NA
 **/
- (void)addMembers:(NSSet *)values;

/**
 * @brief [en] This method is used to remove members set.
 *        <br>[cn] 删除成员集合
 *
 * @param [in] NSSet* values                        <b>:</b><br>[en] Indicates member set.
 *                                                          <br>[cn] 成员对象(EmployeeEntity *)集合
 * @attention [en] NA.
 *            <br>[cn] NA
 * @see NA
 **/
- (void)removeMembers:(NSSet *)values;

@end
