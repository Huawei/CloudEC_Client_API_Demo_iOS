/**
 * @file NSString+Transform.h
 *
 * Copyright (c) 2017 Huawei Tech. Co., Ltd. All rights reserved. \n
 *
 * @brief [en]Description:string type head file.
 * [cn]描述：NSString类别文件。 \n
 **/

#define LAST_SECTION_INDEX  @"[" // Symble behind char 'Z'

#import <Foundation/Foundation.h>
#import "GroupEntity.h"

/**
 * [en] This class is about Transform type.
 * [cn] Transform类别
 **/
@interface NSString (Transform)


/**
 * @brief [en] This method is used to get first letter.
 *        <br>[cn] 获取首字母
 *
 * @retval NSString *               <b>:</b><br>[en] Return first letter if success, or return nil.
 *                                          <br>[cn] 成功返回首字母，失败返回nil
 * @attention [en] NA
 *            <br>[cn] NA
 * @see NA
 **/
- (NSString*)firstLetter;


/**
 * @brief [en] This method is used to get transformed string.
 *        <br>[cn] 获取汉字对应的拼音
 *
 * @retval NSString *               <b>:</b><br>[en] Return pinyin if success, or return nil.
 *                                          <br>[cn] 成功返回拼音，失败返回nil
 * @attention [en] other language return itself
 *            <br>[cn] 其他语种返回其自身
 * @see NA
 **/
- (NSString *)transformedString;


/**
 * @brief [en] This method is used to get index of name.
 *        <br>[cn] 返回名称的索引
 *
 * @retval NSString *               <b>:</b><br>[en] Return index if success, or return nil.
 *                                          <br>[cn] 成功返回索引，失败返回nil
 * @attention [en] NA
 *            <br>[cn] NA
 * @see NA
 **/
- (NSString *)nameIndex;


/**
 * @brief [en] This method is used to create at space.
 *        <br>[cn] 生成@字符
 *
 * @retval NSString *               <b>:</b><br>[en] Return @ space if success, or return nil.
 *                                          <br>[cn] 成功返回@字符，失败返回nil
 * @attention [en] NA
 *            <br>[cn] NA
 * @see NA
 **/
+ (NSString *)createAtSpace;


/**
 * @brief [en] This method is used to judge whether is number.
 *        <br>[cn] 判断是否是数字
 *
 * @retval BOOL *                   <b>:</b><br>[en] Return yes if true, or return no.
 *                                          <br>[cn] 是返回YES，否返回NO
 * @attention [en] NA.
 *            <br>[cn] NA
 * @see NA
 **/
- (BOOL) isNumberic;


/**
 * @brief [en] This method is used to analysis string with regular expression.
 *        <br>[cn] 字符串正则解析
 *
 * @param [in] NSString* regularExpression      <b>:</b><br>[en] Indicates regular expression.
 *                                                      <br>[cn] 正则表达式
 * @retval NSArray *                            <b>:</b><br>[en] Return regular match result if success, or return nil.
 *                                                      <br>[cn] 成功返回正则匹配结果(NSTextCheckingResult *)，失败返回nil
 * @attention [en] NA
 *            <br>[cn] NA
 * @see NA
 **/
- (NSArray*)analysisStringWithRegularExpression:(NSString*)regularExpression;


/**
 * @brief [en] This method is used to get person list with group.
 *        <br>[cn] 获取@的成员列表
 *
 * @param [in] GroupEntity* group               <b>:</b><br>[en] Indicates group.
 *                                                      <br>[cn] 群组
 * @param [in] NSString* text                   <b>:</b><br>[en] Indicates text content.
 *                                                      <br>[cn] 消息内容
 * @retval NSArray *                            <b>:</b><br>[en] Return person list, or return nil.
 *                                                      <br>[cn] 成功返回成员列表(EmployeeEntity *)，失败返回nil
 * @attention [en] NA
 *            <br>[cn] NA
 * @see NA
 **/
- (NSArray *)atPersonListWithGroup:(GroupEntity *)group inText:(NSString *)text;


/**
 * @brief [en] This method is used to generate corresponding string by file size.
 *        <br>[cn] 根据文件大小生成对应的字符串
 *
 * @param [in] long long size                   <b>:</b><br>[en] Indicates siez.
 *                                                      <br>[cn] 大小
 * @retval NSString *                           <b>:</b><br>[en] Return description string if success, or return nil.
 *                                                      <br>[cn] 成功返回描述大小的字符串，失败返回nil
 * @attention [en] NA
 *            <br>[cn] NA
 * @see NA
 **/
+ (NSString *)fileSizeString:(long long)size;
@end
