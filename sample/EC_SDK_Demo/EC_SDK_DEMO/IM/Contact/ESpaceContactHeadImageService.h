/**
 * @file ESpaceContactHeadImageService.h
 *
 * Copyright © 2017 Huawei Tech. Co., Ltd.. All rights reserved. \n
 *
 * @brief [en]Description:contact head basic function class head file.
 * [cn]描述：联系人头像基础功能类头文件。 \n
 **/

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

extern NSString* const HEADIMAGE_EMPLOYEEENTITY_ZERO;
extern NSString* const HEADIMAGE_EMPLOYEEENTITY_ONE;
extern NSString* const HEADIMAGE_EMPLOYEEENTITY_TWO;
extern NSString* const HEADIMAGE_EMPLOYEEENTITY_THREE;
extern NSString* const HEADIMAGE_EMPLOYEEENTITY_FORE;
extern NSString* const HEADIMAGE_EMPLOYEEENTITY_FIVE;
extern NSString* const HEADIMAGE_EMPLOYEEENTITY_SIX;
extern NSString* const HEADIMAGE_EMPLOYEEENTITY_SEVEN;
extern NSString* const HEADIMAGE_EMPLOYEEENTITY_EIGHT;
extern NSString* const HEADIMAGE_EMPLOYEEENTITY_NINE;
extern NSString* const HEADIMAGE_CUSTOMCONTACTENTITY;
extern NSString* const HEADIMAGE_LOCALCONTACTENTITY;
extern NSString* const HEADIMAGE_GROUPENTITY;
extern NSString* const HEADIMAGE_CALLCONTACTENTITY;

/**
 * [en] This class is about contact head basic function.
 * [cn] 联系人头像基础功能类
 **/
@interface ESpaceContactHeadImageService : NSObject


/**
 *  键值约定为:
 HEADIMAGE_EMPLOYEEENTITY_ZERO-------@"image name"
 HEADIMAGE_EMPLOYEEENTITY_ONE--------@"image name"
 HEADIMAGE_EMPLOYEEENTITY_TWO--------@"image name"
 HEADIMAGE_EMPLOYEEENTITY_THREE------@"image name"
 HEADIMAGE_EMPLOYEEENTITY_FORE-------@"image name"
 HEADIMAGE_EMPLOYEEENTITY_FIVE-------@"image name"
 HEADIMAGE_EMPLOYEEENTITY_SIX--------@"image name"
 HEADIMAGE_EMPLOYEEENTITY_SEVEN------@"image name"
 HEADIMAGE_EMPLOYEEENTITY_EIGHT------@"image name"
 HEADIMAGE_EMPLOYEEENTITY_NINE-------@"image name"
 HEADIMAGE_CUSTOMCONTACTENTITY-------@"image name"
 HEADIMAGE_LOCALCONTACTENTITY--------@"image name"
 HEADIMAGE_GROUPENTITY---------------@"image name"
 HEADIMAGE_CALLCONTACTENTITY---------@"image name"
 */
@property (nonatomic, strong) NSDictionary* contactHeadImageInfo;//若需要自定义默认头像，需提前设置好

/**
 * @brief [en] This method is used to get single object.
 *        <br>[cn] 获取单例对象
 *
 * @retval instancetype                           <b>:</b><br>[en] Return an instance type.
 *                                                        <br>[cn] 返回一个单例对象
 * @attention [en] NA.
 *            <br>[cn] NA
 * @see NA
 **/
+ (instancetype) sharedInstance;


/**
 * @brief [en] This method is used to get contact default head.
 *        <br>[cn] 获取联系人默认头像
 *
 * @param [in] NSString* headId                   <b>:</b><br>[en] Indicates head id.
 *                                                        <br>[cn] 头像ID
 * @retval UIImage *                              <b>:</b><br>[en] Return head if success, or return nil.
 *                                                        <br>[cn] 成功返回头像，失败返回nil
 * @attention [en] NA.
 *            <br>[cn] NA
 * @see NA
 **/
- (UIImage *)defaultEmpolyeeHeadImageWithHeadId:(NSString *)headId;


/**
 * @brief [en] This method is used to get default custom contact head image.
 *        <br>[cn] 获取自定义联系人默认头像
 *
 * @retval UIImage *                              <b>:</b><br>[en] Return head if success, or return nil.
 *                                                        <br>[cn] 成功返回头像，失败返回nil
 * @attention [en] NA.
 *            <br>[cn] NA
 * @see NA
 **/
- (UIImage *)defaultCustomContactHeadImage;


/**
 * @brief [en] This method is used to get default local contact head image.
 *        <br>[cn] 获取本地联系人默认头像
 *
 * @retval UIImage *                              <b>:</b><br>[en] Return head if success, or return nil.
 *                                                        <br>[cn] 成功返回头像，失败返回nil
 * @attention [en] NA.
 *            <br>[cn] NA
 * @see NA
 **/
- (UIImage *)defaultLocalContactHeadImage;


/**
 * @brief [en] This method is used to get default call contact head image.
 *        <br>[cn] 获取呼叫联系人默认头像
 *
 * @retval UIImage *                              <b>:</b><br>[en] Return head if success, or return nil.
 *                                                        <br>[cn] 成功返回头像，失败返回nil
 * @attention [en] NA.
 *            <br>[cn] NA
 * @see NA
 **/
- (UIImage *)defaultCallContactHeadImage;


/**
 * @brief [en] This method is used to get group default head image.
 *        <br>[cn] 获取群组默认头像
 *
 * @retval UIImage *                              <b>:</b><br>[en] Return head if success, or return nil.
 *                                                        <br>[cn] 成功返回头像，失败返回nil
 * @attention [en] NA.
 *            <br>[cn] NA
 * @see NA
 **/
- (UIImage *)defaultGroupHeadImage;

@end
