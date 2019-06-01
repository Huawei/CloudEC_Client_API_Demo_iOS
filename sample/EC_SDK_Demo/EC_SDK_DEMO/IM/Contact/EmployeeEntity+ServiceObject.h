/**
 * @file EmployeeEntity+ServiceObject.h
 *
 * Copyright (c) 2017 Huawei Tech. Co., Ltd. All rights reserved. \n
 *
 * @brief [en]Description:TUP head file of linkman group
 * [cn]描述：TUP 联系人业务操作类头文件。 \n
 **/

#import "EmployeeEntity.h"


/**
 * [en] This is a info class it's about linkman business  operation 
 * [cn] 联系人业务操作类
 **/
@interface EmployeeEntity (ServiceObject)

/**
 * @brief [en]This method is used to get whether need reload linkman
 *        <br>[cn] 检查是否需要重载联系人
 *
 * @retval BOOL                   <b>:</b><br>[en] Indicates need return YES, otherwise return NO.
 *                                        <br>[cn] 是返回YES，否返回NO
 * @attention [en] NA.
 *            <br>[cn] NA
 * @see NA
 **/
- (BOOL) needReload;


/**
 * @brief [en]This method is used to request reload linkman details.
 *        <br>[cn] 请求重载联系人详情
 *
 * @attention [en] The request send to server.
 *            <br>[cn] 该请求发送到服务器
 * @see NA
 **/
- (void) reloadDetail;


/**
 * @brief [en]This method is used to request reload contact details.
 *        <br>[cn] 请求重载联系人详情
 *
 * @param [out] completionBlock             <b>:</b><br>[en] Indicates handle result block carry error message.
 *                                                  <br>[cn] 处理结果Block，携带错误信息(NSError*)
 * @attention [en] The request send to server.
 *            <br>[cn] 该请求发送到服务器
 * @see NA
 **/
- (void) reloadDetailWith:(void (^)(NSError* error))completionBlock;


/**
 * @brief [en]This method is used to load contact head image.
 *        <br>[cn] 加载联系人头像
 *
 * @param [out] completionBlock             <b>:</b><br>[en] Indicates handle result block carry error message and linkman icon portrait message
 *                                                  <br>[cn] 处理结果Block，携带联系人头像信息和错误信息(UIImage*, NSError*)
 * @attention [en] NA.
 *            <br>[cn] NA
 * @see NA
 */
- (void) loadHeadImage:(void (^)(UIImage* imageData, NSError* error)) completionBlock;


/**
 * @brief [en]This method is used to load contact original icon portrait .
 *        <br>[cn] 加载联系人高清原始头像
 *
 * @param [out] completionBlock             <b>:</b><br>[en] Indicates handle result block carry error message and linkman original icon portrait message.
 *                                                  <br>[cn] 处理结果Block，携带联系人高清原始头像信息和错误信息(UIImage*, NSError*)
 * @attention [en] NA.
 *            <br>[cn] NA
 */
- (void) loadHDHeadImage:(void (^)(UIImage* imageData, NSError* error)) completionBlock;


/**
 * @brief [en]This method is used to judge whether is yourself 
 *        <br>[cn] 是否是自己
 *
 * @retval BOOL *                   <b>:</b><br>[en] Indicates true return yes ,false return no
 *                                          <br>[cn] 是返回YES，否返回NO
 * @attention [en] NA.
 *            <br>[cn] NA
 * @see NA
 **/
- (BOOL) isMe;
//- (NSString *)displayNameNeedNickName:(BOOL)optionNickName
//                          needAccount:(BOOL)optionAccount
//                           backUpName:(NSString *)optionName;


/**
 * @brief [en]This method is used to get all friends .
 *        <br>[cn] 获取所有好友
 *
 * @param [in] BOOL* onlineOnly     <b>:</b><br>[en] Indicates only get to friends of on line  yes set true ,no set false.
 *                                          <br>[cn] 是否只获取在线好友
 * @retval NSArray *                <b>:</b><br>[en] Indicates success return list<EmployeeEntity *>  fail return nil.
 *                                          <br>[cn] 成功返回所有符合条件的好友(EmployeeEntity *)数组，失败返回nil
 * @attention [en] Indicates contains custom contacts and enterprise friends 
 *            <br>[cn] 包含自定义联系人和企业好友
 * @see NA
 **/
- (NSArray *)allFriends:(BOOL)onlineOnly;


/**
 * @brief [en]This method is used to get all employee friends .
 *        <br>[cn] 获取自己所有的企业好友
 * @param [in] BOOL* onlineOnly     <b>:</b><br>[en] Indicates only get to friends of on line  yes set true ,no set false..
 *                                          <br>[cn] 是否只获取在线好友
 * @retval NSArray *                <b>:</b><br>[en] Indicates success return list<EmployeeEntity *>  fail return nil..
 *                                          <br>[cn] 成功返回所有符合条件的好友(EmployeeEntity *)数组，失败返回nil
 * @attention [en] Indicates don`t contains custom contacts 
 *            <br>[cn] 不包含自定义联系人
 * @see NA
 **/
- (NSArray *)allEmployeeFriends:(BOOL)onlineOnly;

@end
