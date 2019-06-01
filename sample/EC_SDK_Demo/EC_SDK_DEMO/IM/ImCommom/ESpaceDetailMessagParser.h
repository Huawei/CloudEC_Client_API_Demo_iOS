/**
 * @file ESpaceDetailMessagParser.h
 *
 * Copyright (c) 2015年 Huawei Tech. Co., Ltd. All rights reserved. \n
 *
 * @brief [en]Description:Messag parse service operation class head file.
 * [cn]描述：消息解析业务操作类头文件。 \n
 **/

#import "ESpaceRichTextBaseParser.h"

/**
 * [en] This class is about message parse service operation.
 * [cn] 消息解析业务操作类
 **/
@interface ESpaceDetailMessagParser : ESpaceRichTextBaseParser

/**
 * @brief [en] This method is used to get instance object.
 *        <br>[cn] 获取单例对象
 *
 * @retval instancetype                           <b>:</b><br>[en]Return an instance object .
 *                                                        <br>[cn] 返回一个单例对象
 * @attention [en] NA.
 *            <br>[cn] NA
 * @see NA
 **/
+ (instancetype) sharedInstance;


/**
 * @brief [en] This method is used to match all emotion.
 *        <br>[cn] 搜索所有emotion
 *
 * @param [in] NSString* content    <b>:</b><br>[en]Indicates string waiting for parse.
 *                                          <br>[cn] 待分析的字符串
 * @retval NSArray *                <b>:</b><br>[en]Return emotion hit array if success, or return nil .
 *                                          <br>[cn] 成功返回NSTextCheckingResult描述的emotion hit数组，失败返回nil
 * @attention [en] NA
 *            <br>[cn] NA
 * @see NA
 **/
- (NSArray*) emotionMatches:(NSString*) content;


/**
 * @brief [en] This method is used to match all telephone number.
 *        <br>[cn] 搜索所有电话号码
 *
 * @param [in] NSString* content    <b>:</b><br>[en]Indicates string waiting for parse.
 *                                          <br>[cn] 待分析的字符串
 * @retval NSArray *                <b>:</b><br>[en]Return telephone hit array if success, or return nil .
 *                                          <br>[cn] 成功返回NSTextCheckingResult描述的电话号码 hit数组，失败返回nil
 * @attention [en] NA
 *            <br>[cn] NA
 * @see NA
 **/
- (NSArray*) telphoneMatches:(NSString*) content;


/**
 * @brief [en] This method is used to match all link.
 *        <br>[cn] 搜索所有链接
 *
 * @param [in] NSString* content    <b>:</b><br>[en]Indicates string waiting for parse.
 *                                          <br>[cn] 待分析的字符串
 * @retval NSArray *                <b>:</b><br>[en]Return link hit array if success, or return nil.
 *                                          <br>[cn] 成功返回NSTextCheckingResult描述的链接 hit数组，失败返回nil
 * @attention [en] NA
 *            <br>[cn] NA
 * @see NA
 **/
- (NSArray*) urlMatches:(NSString*) content;


/**
 * @brief [en] This method is used to match all um resource.
 *        <br>[cn] 搜索所有富媒体
 *
 * @param [in] NSString* content    <b>:</b><br>[en]Indicates string waiting for parse.
 *                                          <br>[cn] 待分析的字符串
 * @retval NSArray *                <b>:</b><br>[en]Return um resource hit array if success, or return nil.
 *                                          <br>[cn] 成功返回NSTextCheckingResult描述的富媒体 hit数组，失败返回nil
 * @attention [en] NA
 *            <br>[cn] NA
 * @see NA
 **/
- (NSArray*) umMatches:(NSString*) content;


/**
 * @brief [en] This method is used to format url link string.
 *        <br>[cn] 格式化url链接字符串
 *
 * @param [in] NSString* content    <b>:</b><br>[en]Indicates string waiting for format.
 *                                          <br>[cn] 待格式化字符串
 * @retval NSURL *                  <b>:</b><br>[en]Return NSURL object if success, or return nil .
 *                                          <br>[cn] 如果成功返回NSURL对象，否则返回nil
 * @attention [en] NA
 *            <br>[cn] NA
 * @see NA
 **/
- (NSURL*) formatUrl:(NSString*) urlStr;

//一下方法用于子类化时使用，子类可使用[super xxx]得到相应地control然后对这些control做定制，如添加事件，修改外观或直接替换父类实现


/**
 * @brief [en] This method is used to parse url string.
 *        <br>[cn] 解析URL字符
 *
 * @param [in] NSString* urlStr     <b>:</b><br>[en]Indicates url string.
 *                                          <br>[cn] url字符
 * @retval ESpaceUrlLink *          <b>:</b><br>[en]Return ESpaceUrlLink object if success, or return nil .
 *                                          <br>[cn] 成功返回ESpaceUrlLink对象，否则返回nil
 * @attention [en] According to url string, parse out corresponding ESpaceUrlLink object
 *            <br>[cn] 根据传入的url字符解析出对应的ESpaceUrlLink对象
 * @see NA
 **/
- (ESpaceUrlLink*) parseUrlControl:(NSString*) urlStr;


/**
 * @brief [en] This method is used to parse telephone string.
 *        <br>[cn] 解析号码字符
 *
 * @param [in] NSString* telStr     <b>:</b><br>[en]Indicates telephone string.
 *                                          <br>[cn] 数字字符
 * @retval ESpaceTelLink *          <b>:</b><br>[en]Return ESpaceUrlLink object if success, or return nil .
 *                                          <br>[cn] 成功返回ESpaceTelLink对象，否则返回nil
 * @attention [en] According to url string, parse out corresponding ESpaceUrlLink object
 *            <br>[cn] 根据传入的字符解析出对应的号码对象ESpaceTelLink
 * @see NA
 **/
- (ESpaceTelLink*) parseTelControl:(NSString*) telStr;


/**
 * @brief [en] This method is used to parse um resource.
 *        <br>[cn] 解析富媒体资源
 *
 * @param [in] ESpaceUMResource* resource     <b>:</b><br>[en]Indicates um resource.
 *                                                    <br>[cn] 富媒体
 * @retval ESpaceUMPlaceHolder *              <b>:</b><br>[en]Return ESpaceUMPlaceHolder object if success, or return nil .
 *                                                    <br>[cn] 成功返回占位对象ESpaceUMPlaceHolder，否则返回nil
 * @attention [en] According to um resource, generate corresponding um place holder
 *            <br>[cn] 根据传入的富媒体生成对应的富媒体占位对象
 * @see NA
 **/
//- (ESpaceUMPlaceHolder*) parseUMPlaceHolderWithResource:(ESpaceUMResource*) resource;


/**
 * @brief [en] This method is used to parse plain text.
 *        <br>[cn] 解析普通文本
 *
 * @param [in] NSString* plainText            <b>:</b><br>[en]Indicates plain text.
 *                                                    <br>[cn] 普通文本
 * @retval ECSTextLabel *                     <b>:</b><br>[en]Return ECSTextLabel object if success, or return nil.
 *                                                    <br>[cn] 成功返回ECSTextLabel对象，否则返回nil
 * @attention [en] According to normal text, generate text place holder object ECSTextLabel
 *            <br>[cn] 根据普通文本生成文本占位对象ECSTextLabel
 * @see NA
 **/
- (ECSTextLabel*) parsePlainText:(NSString*) plainText;


/**
 * @brief [en] This method is used to parse email string.
 *        <br>[cn] 解析邮件字符
 *
 * @param [in] NSString* email                <b>:</b><br>[en]Indicates email string.
 *                                                    <br>[cn] 邮件字符
 * @retval ESpaceEmailLink *                  <b>:</b><br>[en]Return ESpaceEmailLink object if success, or return nil.
 *                                                    <br>[cn] 成功返回ESpaceEmailLink对象，否则返回nil
 * @attention [en] According to email string, generate corresponding place holder object ESpaceEmailLink
 *            <br>[cn] 根据邮件字符生成对应的占位对象ESpaceEmailLink
 * @see NA
 **/
- (ESpaceEmailLink*) parseEmail:(NSString*) email;

@end
