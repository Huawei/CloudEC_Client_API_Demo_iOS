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
#import <TUPIOSSDK/TUPMAALoginService.h>
#import <TUPIOSSDK/ECSAppConfig.h>
#import <TUPIOSSDK/eSpaceDBService.h>
#import <TUPNetworkSDK/ECSSocketController.h>
#import "tsdk_manager_interface.h"
#import "tsdk_error_def.h"

#define NEEDMAALOGIN 1 // 是否需要MAA登陆
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
    if ([self.delegate respondsToSelector:@selector(loginEventCallback:result:)])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate loginEventCallback:type result:resultDictionary];
        });
    }
}

/**
 *This method is used to account login
 *账号登陆接口
 */
-(void)authorizeLoginWithLoginInfo:(LoginInfo *)LoginInfo completionBlock:(void (^)(BOOL isSuccess, NSError *error))completionBlock
{
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
         LoginServerInfo *info = [self obtainAccessServerInfo];
         // 配置sipAccount 和 token
//         [[ManagerService callService] configBussinessAccount:nil token:info.token];
         
         if (isSuccess) {
             if (completionBlock) {
                 completionBlock(YES, nil);
             }
#if NEEDMAALOGIN
             NSString *token = [CommonUtils textFromBase64String:info.token];
             // 第三方鉴权返回账号通过userNameForThirdParth字段返回。 tiket鉴权场景下通过userName字段返回。
             NSString* maaAccount = info.userName.length > 0 ? info.userName : info.userNameForThirdParty;
             
             // 非第三方或tiket鉴权场景下, 返回userName可能为空, MAA登录接口不支持空账号, 使用用户输入账号
             if (maaAccount.length == 0) {
                 maaAccount = LoginInfo.account;
             }
             
             //搜索自己软终端号码
             [[ManagerService contactService] searchContactsToConfigSelfTerminalNum];
             // 使用登陆maa时的account 作为当前ECSAppConfig的帐号
             [ECSAppConfig sharedInstance].currentUser.account = maaAccount;
             [eSpaceDBService sharedInstance].localDataManager = [[ESpaceLocalDataManager alloc] initWithUserAccount:maaAccount];
             
//             BOOL isSTGTunnel = [LoginCenter sharedInstance].isSTGTunnel;
             BOOL isSTGTunnel = NO;
             ECSSocketParam* param = nil;
             NSArray *serverInfos = nil;
             // 如果是链接STG隧道的情况下，maa登陆信息取maaStgUri的信息
             if (isSTGTunnel) {
                 serverInfos = [info.maaStgUri componentsSeparatedByString:@":"];
             } else {
                 serverInfos = [info.maaUri componentsSeparatedByString:@":"];
             }
             // serverInfos 只能存在serverIP和port两个元素，否则登陆失败
             if (serverInfos.count == 2)
             {
                 NSString *serverIP = serverInfos[0];
                 NSInteger port = [serverInfos[1] integerValue];
                 param = [[ECSSocketParam alloc] initWithHost:serverIP
                                                         port:port];
             }
             
             if (param == nil) {
                 return ;
             }
             
             // 应用目前都使用token鉴权
             [TUPMAALoginService sharedInstance].authType = LOGINAUTHTYPE_token;
//             [TUPMAALoginService sharedInstance].socketType = [LoginCenter sharedInstance].isSTGTunnel ? LOGINSOCKETTYPE_STG : LOGINSOCKETTYPE_NORMAL;
             [TUPMAALoginService sharedInstance].socketType = LOGINSOCKETTYPE_NORMAL;
             // 登陆MAA
             [[TUPMAALoginService sharedInstance] loginWithAccount:maaAccount
                                                                pw:token
                                                        serverList:@[param]
                                                          ssoToken:token
                                                        retryCount:3
                                                        completion:^(NSError *maaError)
              {
                  if (!maaError) {
                      DDLogError(@"MAA login faild!");
                  }
                 
              }];
#endif
         }else {
             if (completionBlock) {
                 completionBlock(isSuccess, error);
             }
         }
     }];
}

/**
 *This method is usde to logout
 *账号登出
 */
- (void)logout
{
    [[LoginCenter sharedInstance] logout];
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

