//
//  LoginInterface.h
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//


#ifndef LoginInterface_h
#define LoginInterface_h

#import "Defines.h"

@class LoginInfo,LoginServerInfo;
@protocol LoginServiceDelegate <NSObject>
@required

/**
 * This method is used to deel login event callback
 * 登陆事件回调处理
 *@param loginEvent                 Indicates login event
 *                                  登陆事件
 *@param resultDictionary           result value
 *                                  回调信息集
 */
-(void)loginEventCallback:(TUP_LOGIN_EVENT_TYPE)loginEvent result:(NSDictionary *)resultDictionary;
@end

@protocol LoginInterface <NSObject>

/**
 *Indicates login service delegate
 *登陆业务代理
 */
@property (nonatomic, assign)id<LoginServiceDelegate> delegate;

/**
 *Indicates current login info
 *当前登陆信息
 */
@property (nonatomic,strong) LoginInfo *currentLoginInfo;

/**
 * This method is used to uportal login
 * 鉴权登陆
 *@param LoginInfo                   Indicates login params
 *                                   登陆参数
 *@param completionBlock             Indicates login result callback
 *                                   登陆结果回调
 */
-(void)authorizeLoginWithLoginInfo:(LoginInfo *)LoginInfo completionBlock:(void (^)(BOOL isSuccess, NSError *error))completionBlock;

/**
 * This method is used to logout server
 * 注销
 */
- (void)logout;

/**
 * This mehod is used to get current login info
 * 获取当前登陆信息
 *@return TUPLoginInfo *              Indicates login info
 *                                    登陆信息
 */
-(LoginInfo *)obtainCurrentLoginInfo;

/**
 * This method is used to get token
 * 获取token
 *@return token                        Indicates token
 *                                     鉴权凭证
 */
-(NSString *)obtainToken;

/**
 * This method is used to get access server info
 * 获取服务器信息
 *@return TUPLoginServerInfo*          Indicates access server info
 *                                     获取服务器信息
 */
-(LoginServerInfo *)obtainAccessServerInfo;


@end

#endif /* LoginInterface_h */


