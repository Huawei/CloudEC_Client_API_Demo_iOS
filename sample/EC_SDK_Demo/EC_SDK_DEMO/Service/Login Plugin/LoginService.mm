//
//  LoginService.mm
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

#import "LoginService.h"
#include "string.h"
#include <netdb.h>
#include <net/if.h>
#include <ifaddrs.h>
#include <arpa/inet.h>
#include <dlfcn.h>
#include <sys/sysctl.h>
#import "LoginInfo.h"
#import "Initializer.h"
#import "LoginCenter.h"
#import "CommonUtils.h"
#import "ManagerService.h"
#import "tsdk_manager_interface.h"
#import "tsdk_error_def.h"


@interface LoginService()

/**
 *Indicates login info and part of authrize result
 *登陆信息以及部分鉴权结果
 */
@property (nonatomic, strong)LoginInfo *loginInfo;

@end

@implementation LoginService

/**
 *Indicates delegate of LoginInterface protocol
 *LoginInterface协议的代理
 */
@synthesize delegate;

/**
 *Indicates current login info and part of authrize result
 *当前登陆信息以及部分鉴权结果
 */
@synthesize currentLoginInfo;

@synthesize serviceStatus;

/**
 *This method is used to init this class, in this method add observer for notification
 *该类的初始化方法，其中添加了两个事件监听
 */
-(instancetype)init
{
    if (self = [super init])
    {
        //monitor the notification of sip status change
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(loginSipStatusChangedNotify)
                                                     name:LOGIN_UNREGISTERED_RESULT
                                                   object:nil];
    }
    return self;
}

/**
 This method is used to do when self be released.
 loginService被释放时，做去初始化操作
 */
-(void)dealloc
{
    [self unInitLoginServer];
}

/**
 *This method is used to get login status after receiving sip register notification
 *收到sip登陆回调后设置登陆状态
 */
- (void)loginSipStatusChangedNotify
{
    [self respondsLoginDelegateWithType:LOGINOUT_EVENT result:nil];
}

/**
 *This method is used to respond login delegate with event type
 *根据事件类型将消息传递给代理
 */
-(void)respondsLoginDelegateWithType:(TUP_LOGIN_EVENT_TYPE)type result:(NSDictionary *)resultDictionary
{
    DDLogInfo(@"post to UI");
    if (self.delegate && [self.delegate respondsToSelector:@selector(loginEventCallback:result:)])
    {
//        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate loginEventCallback:type result:resultDictionary];
//        });
    }
}

/**
 *This method is used to account login
 *账号登陆接口
 */
-(void)authorizeLoginWithLoginInfo:(LoginInfo *)LoginInfo completionBlock:(void (^)(BOOL isSuccess, NSError *error))completionBlock
{
    //TSDK_S_DISPLAY_LOCAL_INFO display_info;
    //memset(&display_info, 0, sizeof(TSDK_S_DISPLAY_LOCAL_INFO));
    //strcpy(display_info.display_name, [@"self name" UTF8String]);
    //tsdk_set_config_param(TSDK_E_CONFIG_DISPLAY_LOCAL_INFO, &display_info);
    
    self.loginInfo = LoginInfo;
    // 登陆uportal鉴权
    [[LoginCenter sharedInstance] loginWithAccount:LoginInfo.account
                                          password:LoginInfo.password
                                         serverUrl:LoginInfo.regServerAddress
                                        serverPort:LoginInfo.regServerPort.integerValue
                                      localAddress:[CommonUtils
                                                    getLocalIpAddressWithIsVPN:[CommonUtils checkIsVPNConnect]]
                                        completion:^(BOOL isSuccess, NSError *error)
     {
         dispatch_async(dispatch_get_main_queue(), ^{
             if (isSuccess) {
                 
                 
                 
                 //             [eSpaceDBService sharedInstance].localDataManager = [[ESpaceLocalDataManager alloc] initWithUserAccount:userConfig.account];
                 //             ESPACE_APP_DELEGATE.localDataManager = [eSpaceDBService sharedInstance].localDataManager;
                 
                 
                 
//                 //搜索自己软终端号码
//                 [[ManagerService contactService] searchContactsToConfigSelfTerminalNum];
                 
                 if (completionBlock) {
                     completionBlock(YES, nil);
                 }
                 
             }else {
                 if (completionBlock) {
                     completionBlock(isSuccess, error);
                     //                 [ManagerService loginService].serviceStatus = ECServiceKickOff;
                 }
             }
         });
         
     }];
}

/**
 *This method is usde to logout
 *账号登出
 */
- (void)logout
{
    [[LoginCenter sharedInstance] logout];
    [ManagerService loginService].serviceStatus = ECServiceLogout;
}

#pragma Public method
/**
 *This method is used to obtain current login info
 *获取当前登陆信息
 */
-(LoginInfo *)obtainCurrentLoginInfo
{
    return _loginInfo;
}

/**
 *This method is used to obtain token
 *获取鉴权token
 */
-(NSString *)obtainToken
{
    return [[LoginCenter sharedInstance] currentServerInfo].token;
}

/**
 *This method is used to obtain server info
 *获取服务器信息
 */
-(LoginServerInfo *)obtainAccessServerInfo
{
    return [[LoginCenter sharedInstance] currentServerInfo];
}

#pragma mark - Authorize

/**
 *This method is used to uninit login server
 *去初始化服务器信息
 */
-(BOOL)unInitLoginServer
{
    TSDK_RESULT result = tsdk_uninit();
    
    DDLogInfo(@"Login_Log: tsdk_uninit result = %#x",result);
    return result == TSDK_SUCCESS ? YES : NO;
}

@end

