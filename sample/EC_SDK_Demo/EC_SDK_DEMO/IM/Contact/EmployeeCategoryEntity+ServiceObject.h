/**
 * @file EmployeeCategoryEntity+ServiceObject.h
 *
 * Copyright (c) 2017 Huawei Tech. Co., Ltd. All rights reserved. \n
 *
 * @brief [en]Description:TUP head file of linkman group head file
 * [cn]描述：TUP 联系人分组业务操作类头文件。 \n
 **/

#import "EmployeeCategoryEntity.h"


/**
 * [en] This class is about contact group
 * [cn] 联系人分组业务操作类
 **/
@interface EmployeeCategoryEntity (ServiceObject)


/**
 * @brief [en]This method is used to get Enterprise contact friends on line 
 *        <br>[cn] 获取所有在线的企业联系人好友
 *
 * @retval NSArray *                <b>:</b><br>[en] Indicates success return list<EmployeeEntity *>  fail return nil
 *                                          <br>[cn] 成功返回联系人(EmployeeEntity *)数组，失败返回nil
 * @attention [en] NA.
 *            <br>[cn] NA
 * @see NA
 **/
- (NSArray *)onlineMembers;


/**
 * @brief [en]This method is used to get.all group of linkman
 *        <br>[cn] 获取所有联系人分组
 *
 * @retval NSArray *                <b>:</b><br>[en] Indicates success return list<EmployeeCategoryEntity *>  fail return nil.
 *                                          <br>[cn] 成功返回所有联系人分组(EmployeeCategoryEntity *)，失败返回nil
 * @attention [en] NA.
 *            <br>[cn] NA
 * @see NA
 **/
+ (NSArray *)allCategoryEntities;


/**
 * @brief [en]This method is used to get specify group of linkman 
 *        <br>[cn] 获取指定联系人分组
 *
 * @param [in] NSNumber* idx          <b>:</b><br>[en] Indicates group index.
 *                                            <br>[cn] 分组索引
 * @retval EmployeeCategoryEntity     <b>:</b><br>[en] Indicates success return object of linkman group fail return nil..
 *                                            <br>[cn] 成功返回联系人分组对象，失败返回nil
 * @attention [en] NA.
 *            <br>[cn] NA
 * @see NA
 **/
+ (EmployeeCategoryEntity *)categoryWithID:(NSNumber *)idx;

@end
