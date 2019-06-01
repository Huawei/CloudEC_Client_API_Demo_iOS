/**
 * @file NSString+ESpaceMD5.h
 *
 * Copyright © 2017 Huawei Tech. Co., Ltd. All rights reserved. \n
 *
 * @brief [en]Description:generate string service operation class head file.
 * [cn]描述：生成字符串业务操作类头文件。 \n
 **/

#import <Foundation/Foundation.h>

/**
 * [en] This class is about generate string service operation.
 * [cn] 生成字符业务串操作类
 **/
@interface NSString (ESpaceMD5)


/**
 * @brief [en] This method is used to generate MD5 string.
 *        <br>[cn] 生成MD5字符串
 *
 * @retval NSString *               <b>:</b><br>[en] Return md5 string if success, or return nil.
 *                                          <br>[cn] 成功返回MD5字符串，失败返回nil
 * @attention [en] NA
 *            <br>[cn] NA
 * @see NA
 **/
- (NSString *)MD5;


/**
 * @brief [en] This method is used to generate string combine self whith md5.
 *        <br>[cn] 生成self与MD5拼接的字符串
 *
 * @retval NSString *               <b>:</b><br>[en] Return combined string if success, or return nil.
 *                                          <br>[cn] 成功返回self与MD5拼接的字符串，失败返回nil
 * @attention [en] NA
 *            <br>[cn] NA
 * @see NA
 **/
- (NSString *)combinedWithMD5;

@end
