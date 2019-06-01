/**
 * @file ECSSandboxHelper.h
 *
 * Copyright © 2017 Huawei Tech. Co., Ltd. All rights reserved. \n
 *
 * @brief [en]Description:get app library operation class head file.
 * [cn]描述：获取APP的目录操作类头文件。 \n
 **/

#import <Foundation/Foundation.h>

/**
 * [en] This class is about sand box path configuration.
 * [cn] 沙盒路径配置
 **/
@interface ECSSandboxConfiguration : NSObject

@property (nonatomic, copy)NSString *document;
@property (nonatomic, copy)NSString *library;
@property (nonatomic, copy)NSString *caches;
@property (nonatomic, copy)NSString *preferences;
@property (nonatomic, copy)NSString *temp;
@property (nonatomic, strong)NSBundle *UIResourceBundle;

@end

/**
 * [en] This class is about sand box helper.
 * [cn] 沙盒路径配置助手
 **/
@interface ECSSandboxHelper : NSObject

@property (nonatomic, strong)ECSSandboxConfiguration *sandboxConfiguration;

/*日志存放的根目录路径，程序会在此目录下按照如下方式生成子目录,默认目录为Library
 *     anyofficelog
 *     mip
 *Logs tuplog
 *     UI
 */
@property (nonatomic, copy) NSString *logFileSuperPath;//默认目录为Library
@property (nonatomic, copy) NSString *logFileRootName;//默认Logs
@property (nonatomic, copy, readonly) NSString *logFilePath;//比如.../Library/Logs

/**
 * @brief [en] This method is used to get instance object.
 *        <br>[cn] 获取单例对象
 *
 * @retval instancetype                           <b>:</b><br>[en] Return an instance object.
 *                                                        <br>[cn] 返回一个单例对象
 * @attention [en] NA.
 *            <br>[cn] NA
 * @see NA
 **/
+ (instancetype)shareInstance;


/**
 * @brief [en] This method is used to get app document path.
 *        <br>[cn] 获取app的document目录
 *
 * @retval NSString *               <b>:</b><br>[en] Return document path if success, or return nil.
 *                                          <br>[cn] 成功返回document目录，失败返回nil
 * @attention [en] xxxx
 *            <br>[cn] 默认为系统的document目录，如果有设置则返回设置的目录
 * @see NA
 **/
- (NSString *)documentPath;


/**
 * @brief [en] This method is used to get app library path.
 *        <br>[cn] 获取app的library目录
 *
 * @retval NSString *               <b>:</b><br>[en] Return library path if success, or return nil.
 *                                          <br>[cn] 成功返回library目录，失败返回nil
 * @attention [en] default system library path, if has set then return it
 *            <br>[cn] 默认为系统的library目录，如果有设置则返回设置的目录
 * @see NA
 **/
- (NSString *)libraryPath;


/**
 * @brief [en] This method is used to get caches path.
 *        <br>[cn] 获取app的caches目录
 *
 * @retval NSString *               <b>:</b><br>[en] Return caches path if success, or return nil.
 *                                          <br>[cn] 成功返回caches目录，失败返回nil
 * @attention [en] Default system caches path, if has set then return it
 *            <br>[cn] 默认为系统的caches目录，如果有设置则返回设置的目录
 * @see NA
 **/
- (NSString *)cachesPath;


/**
 * @brief [en] This method is used to get app preferences path.
 *        <br>[cn] 获取app的preferences目录
 *
 * @retval NSString *               <b>:</b><br>[en] Return preferences path if success, or return nil.
 *                                          <br>[cn] 成功返回preferences目录，失败返回nil
 * @attention [en] Default system preferences path, if has set then return it
 *            <br>[cn] 默认为系统的preferences目录，如果有设置则返回设置的目录
 * @see NA
 **/
- (NSString *)preferencesPath;


/**
 * @brief [en] This method is used to get app temp path.
 *        <br>[cn] 获取app的temp目录
 *
 * @retval NSString *               <b>:</b><br>[en] Return temp path if success, or return nil.
 *                                          <br>[cn] 成功返回temp目录，失败返回nil
 * @attention [en]  Default system temp path, if has set then return it
 *            <br>[cn] 默认为系统的temp目录，如果有设置则返回设置的目录
 * @see NA
 **/
- (NSString *)tempPath;


/**
 * @brief [en] This method is used to get app resource bundle.
 *        <br>[cn] 获取app的资源bundle
 *
 * @retval NSString *               <b>:</b><br>[en] Return bundle if success, or return nil.
 *                                          <br>[cn] 成功返回bundle，失败返回nil
 * @attention [en]  Default system mainBundle path, if has set then return it
 *            <br>[cn] 默认为系统的mainBundle，如果有设置则返回设置的bundle
 * @see NA
 **/
- (NSBundle *)UIResourceBundle;

@end
