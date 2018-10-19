//
//  LoginCenter.h
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

#import <Foundation/Foundation.h>
#import "LoginServerInfo.h"

typedef NS_ENUM(NSInteger, CallSipStatus)
{
    kCallSipStatusUnRegistered         = 0,     // sip status: unregistered
    kCallSipStatusRegistering          = 1,     // sip status: registering
    kCallSipStatusRegistered           = 2,     // sip status: registered
};

@interface LoginCenter : NSObject

/**
 *This method is used to creat single instance of this class
 *创建该类的单例
 */
+ (instancetype)sharedInstance;

/**
 * This method is used to login uportal authorize.
 *登陆uportal鉴权
 *@param account user account
 *@param pwd user password
 *@param serverUrl uportal address
 *@param port uportal port
 *@param localAddress  device current ip address
 *@param completionBlock login result call back
 */
- (void)loginWithAccount:(NSString *)account
                password:(NSString *)pwd
               serverUrl:(NSString *)serverUrl
              serverPort:(NSUInteger)port
            localAddress:(NSString *)localAddress
              completion:(void (^)(BOOL isSuccess, NSError *error))completionBlock;

/**
 * This method is used to sip account logout.
 * sip账号注销
 */
- (BOOL)logout;

/**
 * This method is used to get uportal login server info.
 * 获取当前登陆信息
 *@return server info
 */
- (LoginServerInfo *)currentServerInfo;

/**
 * This method is used to judge whether server connect use stg tunnel
 * 是否连接STG隧道
 *@return BOOL
 */
- (BOOL)isSTGTunnel;

///**
// * This method is used to set push service
// * 设置PUSH服务
// */
//- (void)configUportalAPNSEnable:(BOOL)enable noPushStartTime:(NSString*)strartTime noPushEndTime:(NSString*)endTime enableNoPushByTime:(BOOL)enableNoPushByTime;

/**设置PUSH服务
 * This method is used to set configuration information
 * 设置配置信息
 */
-(void)configSipRelevantParam;

@end

extern NSString * const UPortalTokenKey;
extern NSString * const CallRegisterStatusKey;
extern NSString * const PushTimeEnableRecoud;

