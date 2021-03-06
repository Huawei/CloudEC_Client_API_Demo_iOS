//
//  LoginCenter.m
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

#import "LoginCenter.h"
#import "Initializer.h"
#import "Defines.h"
#include <arpa/inet.h>
#import "tsdk_error_def.h"
#import "tsdk_login_def.h"
#import "tsdk_login_interface.h"
#import "tsdk_manager_interface.h"
#import "CommonUtils.h"
#import "ManagerService.h"
#import "CallWindowController.h"

NSString * const UPortalTokenKey = @"UPortalTokenKey";
NSString * const CallRegisterStatusKey = @"CallRegisterStatusKey";
NSString * const PushTimeEnableRecoud = @"PushTimeEnableRecoud";

static LoginCenter *g_loginCenter = nil;

@interface LoginCenter ()<TupLoginNotification>
{
    dispatch_queue_t _uportalPushConfigQueue;           //push设置队列(串行)
}
@property (nonatomic, strong)LoginServerInfo *loginServerInfo;         // LoginServerInfo
@property (nonatomic, assign)BOOL bSTGTunnel;                          // is connected STG or not
@property (nonatomic, assign)TUP_FIREWALL_MODE firewallMode;           // fire wall mode
@property (nonatomic, strong)void (^callBackAction)(BOOL, NSError*);   // block
@property (nonatomic, copy)NSString *ipAddress;                        // ip address

@end

@implementation LoginCenter

/**
 * This method is used to init this class
 * 初始化该类
 */
- (id)init
{
    if (self = [super init]) {
        _uportalPushConfigQueue = dispatch_queue_create("com.huawei.tsdk.uportalPushConfig", DISPATCH_QUEUE_SERIAL);
        [Initializer registerLoginCallBack:self];
        _isResuming = NO;
    }
    return self;
}

/**
 *This method is used to creat single instance of this class
 *创建该类的单例
 */
+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        g_loginCenter = [[LoginCenter alloc] init];
    });
    return g_loginCenter;
}

/**
 * This method is used to login uportal authorize.
 * 登陆uportal鉴权
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
              completion:(void (^)(BOOL isSuccess, NSError *error))completionBlock
{
    [self configSipRelevantParam];
    TSDK_S_LOGIN_PARAM loginParam;
    memset(&loginParam, 0, sizeof(TSDK_S_LOGIN_PARAM));
    loginParam.user_id = 1;
    loginParam.auth_type = TSDK_E_AUTH_NORMAL;
    strcpy(loginParam.user_name, [account UTF8String]);
    strcpy(loginParam.password, [pwd UTF8String]);
    loginParam.server_type = TSDK_E_SERVER_TYPE_PORTAL;
    strcpy(loginParam.server_addr, [serverUrl UTF8String]);
    loginParam.server_port = (TSDK_UINT16)port;
    TSDK_RESULT result = tsdk_login(&loginParam);
    DDLogInfo(@"Login_Log: tsdk_login result = %#x",result);
    
    if (result != TSDK_SUCCESS)
    {
        if (completionBlock) {
            completionBlock(NO, nil);
        }
    }
    else {
        self.callBackAction = completionBlock;
        self.ipAddress = localAddress;
    }
}

-(void)configSipRelevantParam
{
    //config local ip
    TSDK_S_LOCAL_ADDRESS local_ip;
    memset(&local_ip, 0, sizeof(TSDK_S_LOCAL_ADDRESS));
    NSString *ip = [CommonUtils getLocalIpAddressWithIsVPN:[CommonUtils checkIsVPNConnect]];
    strcpy(local_ip.ip_address, [ip UTF8String]);
    local_ip.is_try_resume = TSDK_FALSE;
    TSDK_RESULT configResult = tsdk_set_config_param(TSDK_E_CONFIG_LOCAL_ADDRESS, &local_ip);
    DDLogInfo(@"config local address result: %d; local ip is: %@", configResult, ip);

    
//    TSDK_S_IOS_PUSH_PARAM pushParam;
//    memset(&pushParam, 0, sizeof(TSDK_S_IOS_PUSH_PARAM));
//    pushParam.app_id = 1;
//    pushParam.language = TSDK_E_LANGUAGE_ZH;
//      //苹果推送服务器类型（1：生产环境 ; 2：测试环境）
//    pushParam.apns_env_type = TSDK_E_APNS_TEST_ENV;
//    //推送服务证书编号（1 espace appstore ；2 espace 企业；3 espace hd 企业；4 espace hd appstore）; 5 cloudLink appstore ; 6 cloudLink 企业  ，默认值0
//    pushParam.apns_cret_type = TSDK_E_APNS_CRET_1;
//    strcpy(pushParam.device_token, [[ECSAppConfig sharedInstance].deviceToken UTF8String]);
//    strcpy(pushParam.voip_token, [[ECSAppConfig sharedInstance].voipToken UTF8String]);
//    configResult = tsdk_set_config_param(TSDK_E_CONFIG_IOS_PUSH_PARAM, &pushParam);
//    DDLogInfo(@"config param result: %d", configResult);
    
}


/**
 * This method is used to get uportal login server info.
 * 获取当前登陆信息
 *@return server info
 */
- (LoginServerInfo *)currentServerInfo
{
    return _loginServerInfo;
}

/**
 * This method is used to judge whether server connect use stg tunnel.
 * 是否连接STG隧道
 *@return BOOL
 */
- (BOOL)isSTGTunnel
{
    return _bSTGTunnel;
}

/**
 * This method is used to sip account logout.
 * sip账号注销
 */
-(BOOL)logout
{
//    [self logoutStopPush];
    
    TSDK_RESULT ret = tsdk_logout();
    BOOL result = (TSDK_SUCCESS == ret) ? YES : NO;
    return result;
}

/**
 * This method is used to deel login event callback and login sip event callback from service.
 * 分发登陆业务和登陆sip业务相关回调
 *@param module TUP_MODULE
 *@param notification Notification
 */
- (void)loginModule:(TUP_MODULE)module notification:(Notification *)notification
{
    [self onRecvLoginNotification:notification];
}

-(void)onRecvLoginNotification:(Notification *)notify
{
    CallSipStatus sipStatus = kCallSipStatusUnRegistered;
    switch(notify.msgId)
    {
        case TSDK_E_LOGIN_EVT_AUTH_SUCCESS:
        {
            TSDK_S_IM_LOGIN_PARAM *im_login_parama = (TSDK_S_IM_LOGIN_PARAM *)notify.data;
            
            LoginServerInfo *LoginAccessServer = [[LoginServerInfo alloc] init];
            LoginAccessServer.eserverUri = [NSString stringWithUTF8String:im_login_parama->e_server_uri];
            LoginAccessServer.maaUri = [NSString stringWithUTF8String:im_login_parama->maa_server_uri];
            LoginAccessServer.sipAccount = [NSString stringWithUTF8String:im_login_parama->account];
            LoginAccessServer.sipPwd= [NSString stringWithUTF8String:im_login_parama->password];
            LoginAccessServer.token = [NSString stringWithUTF8String:im_login_parama->token];
            self.loginServerInfo = LoginAccessServer;
                        
//            NSArray *pushTime = [CommonUtils getUserDefaultValueWithKey:PushTimeEnableRecoud];
//            NSString *noPushStart = nil;
//            NSString *noPushEnd = nil;
//            BOOL enableNoPushByTime = NO;
//            if (pushTime != nil) {
//                enableNoPushByTime = [pushTime[0] boolValue];
//                noPushStart = pushTime[1];
//                noPushEnd = pushTime[2];
//            }
//            [self configUportalAPNSEnable:YES noPushStartTime:noPushStart noPushEndTime:noPushEnd enableNoPushByTime:enableNoPushByTime];
            
            DDLogInfo(@"authorize success");
            break;
        }
        case TSDK_E_LOGIN_EVT_AUTH_FAILED:
        {
            TSDK_UINT32 reasonCode = notify.param2;
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:LOGIN_AUTH_FAILED object:nil userInfo:nil];
            });
            _isResuming = NO;
            [ManagerService loginService].serviceStatus = ECServiceInvalidAccountOrPassword;
            DDLogInfo(@"authorize failed, reason code: %d", reasonCode);
            break;
        }
        case TSDK_E_LOGIN_EVT_AUTH_REFRESH_FAILED:
        {
            TSDK_UINT32 reasonCode = notify.param2;
            [ManagerService loginService].serviceStatus = ECServiceInvalidAccountOrPassword;
            DDLogInfo(@"authorize refresh failed, reason code: %d", reasonCode);
            break;
        }
        case TSDK_E_LOGIN_EVT_LOGIN_SUCCESS:
        {
            TSDK_S_LOGIN_SUCCESS_INFO *login_success_info = notify.data;
            
            TSDK_E_SERVICE_ACCOUNT_TYPE accountType = notify.param2;
            if (accountType == TSDK_E_VOIP_SERVICE_ACCOUNT) {
                
                DDLogInfo(@"sip have been login");
                [ManagerService loginService].serviceStatus = ECServiceLogin;
                BOOL needAutoLogin = [CommonUtils getUserDefaultBoolValueWithKey:NEED_AUTO_LOGIN];
                if (!needAutoLogin) {
                    [CommonUtils userDefaultSaveBoolValue:YES forKey:NEED_AUTO_LOGIN];
                }
                if (_isResuming) {
                    _isResuming = NO;
                    return;
                }
                sipStatus = kCallSipStatusRegistered;
                [self isSipRegistered:sipStatus];
                
                if (login_success_info != NULL) {
                    [ManagerService confService].uPortalConfType = [self configDeployMode:login_success_info->conf_env_type];
                }
            }else if (accountType == TSDK_E_IM_SERVICE_ACCOUNT){
//                DDLogInfo(@"im have been login");
//                [ManagerService loginService].serviceStatus = ECServiceLogin;
            }else{
                
            }
            
            break;
        }
        case TSDK_E_LOGIN_EVT_LOGIN_FAILED:
        {
            TSDK_E_SERVICE_ACCOUNT_TYPE accountType = notify.param2;
            if (accountType == TSDK_E_VOIP_SERVICE_ACCOUNT) {
                if (_isResuming) {
                    _isResuming = NO;
                    return;
                }
                sipStatus = kCallSipStatusUnRegistered;
                TSDK_UINT32 reasonCode = notify.param2;
                [ManagerService loginService].serviceStatus = ECServiceLogout;
                [[ManagerService callService] hangupAllCall];
                [[ManagerService confService] confCtrlLeaveConference];
                [[ManagerService confService] restoreConfParamsInitialValue];
                DDLogInfo(@"sip login failed, reason code: %d", reasonCode);
                [self isSipRegistered:sipStatus];
            }
            
            break;
        }
        case TSDK_E_LOGIN_EVT_LOGOUT_SUCCESS:
        {
            TSDK_E_SERVICE_ACCOUNT_TYPE accountType = notify.param2;
            if (accountType == TSDK_E_VOIP_SERVICE_ACCOUNT) {
                DDLogInfo(@"sip unregister");
                sipStatus = kCallSipStatusUnRegistered;
                [ManagerService loginService].serviceStatus = ECServiceLogout;
            }
            
            break;
        }
        case TSDK_E_LOGIN_EVT_LOGOUT_FAILED:
        {
            sipStatus = kCallSipStatusRegistered;
            TSDK_UINT32 reasonCode = notify.param2;
            [ManagerService loginService].serviceStatus = ECServiceLogout;
            DDLogInfo(@"sip logout failed, reason code: %d", reasonCode);
            break;
        }
        case TSDK_E_LOGIN_EVT_FORCE_LOGOUT:
        {
            TSDK_E_SERVICE_ACCOUNT_TYPE accountType = notify.param2;
            if (accountType == TSDK_E_VOIP_SERVICE_ACCOUNT) {
                [self logout];
                DDLogInfo(@"sip unregister");
                sipStatus = kCallSipStatusUnRegistered;
            }
            
            [ManagerService loginService].serviceStatus = ECServiceKickOff;
            break;
        }
        case TSDK_E_LOGIN_EVT_VOIP_ACCOUNT_STATUS:
        {
            TSDK_S_VOIP_ACCOUNT_INFO* voip_account_info = notify.data;
            NSString *number = [NSString stringWithUTF8String:voip_account_info->number];
            NSString *terminal = [NSString stringWithUTF8String:voip_account_info->terminal];
            if (terminal == nil || terminal.length == 0) {
                terminal = number;
            }
            if (terminal.length > 0) {
                [ManagerService callService].terminal = terminal;
            }
            
            
            break;
        }
        case TSDK_E_LOGIN_EVT_IM_ACCOUNT_STATUS:
        {
            break;
        }
        case TSDK_E_LOGIN_EVT_FIREWALL_DETECT_FAILED:
        {
            break;
        }
        case TSDK_E_LOGIN_EVT_BUILD_STG_TUNNEL_FAILED:
        {
            break;
        }
        case TSDK_E_LOGIN_EVT_GET_TEMP_USER_RESULT:
        {
            TSDK_UINT32 reasonCode = notify.param2;
            if (reasonCode != TSDK_SUCCESS) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:LOGIN_GET_TEMP_USER_INFO_FAILD object:nil userInfo:nil];
                });
            }
            break;
        }
        case TSDK_E_LOGIN_EVT_LOGIN_RESUMING_IND:
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:LOGIN_AND_CONF_RESUMING_NOTIFY object:nil];
            });
            _isResuming = YES;
            break;
        }
            
        case TSDK_E_LOGIN_EVT_LOGIN_RESUME_RESULT:
        {
            _isResuming = NO;
            if ([CallWindowController shareInstance].needSetLocalIp) {
                [CallWindowController shareInstance].needSetLocalIp = NO;
                //config local ip
                TSDK_S_LOCAL_ADDRESS local_ip;
                memset(&local_ip, 0, sizeof(TSDK_S_LOCAL_ADDRESS));
                NSString *ip = [CommonUtils getLocalIpAddressWithIsVPN:[CommonUtils checkIsVPNConnect]];
                strcpy(local_ip.ip_address, [ip UTF8String]);
                local_ip.is_try_resume = TSDK_TRUE;
                TSDK_RESULT configResult = tsdk_set_config_param(TSDK_E_CONFIG_LOCAL_ADDRESS, &local_ip);
                DDLogInfo(@"config local address result: %d; local ip is: %@", configResult, ip);
            }
        }
            break;
        default:
            break;
    }
}

-(void)isSipRegistered:(CallSipStatus) sipStatus
{
    if (sipStatus == kCallSipStatusRegistered) {
        if (self.callBackAction) {
            self.callBackAction(YES, nil);
        }
    }
    else if (sipStatus == kCallSipStatusUnRegistered) {
        if (self.callBackAction) {
            self.callBackAction(NO, nil);
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:LOGIN_UNREGISTERED_RESULT object:nil userInfo:nil];
    }
    else {
        
    }
}

/**
 *This method is used to config deploy mode
 *配置部署模式（uportal 会议类型）
 */
- (EC_CONF_TOPOLOGY_TYPE)configDeployMode:(TSDK_E_CONF_ENV_TYPE)deployMode
{
    EC_CONF_TOPOLOGY_TYPE uPortalConfType = CONF_TOPOLOGY_BUTT;
    switch (deployMode) {
        case TSDK_E_CONF_ENV_HOSTED_CONVERGENT_CONFERENCE:
            // mediax组网， mediax会议
            uPortalConfType = CONF_TOPOLOGY_MEDIAX;
            break;
        case TSDK_E_CONF_ENV_ON_PREMISES_CONVERGENT_CONFERENCE:
            // smc组网， smc会议
            uPortalConfType = CONF_TOPOLOGY_SMC;
            break;
        default:
            DDLogInfo(@"deploy is error, ignore!");
            break;
    }
//
    return uPortalConfType;
}

//- (void)configUportalAPNSEnable:(BOOL)enable noPushStartTime:(NSString*)strartTime noPushEndTime:(NSString*)endTime enableNoPushByTime:(BOOL)enableNoPushByTime
//{
//    TSDK_S_PUSH_SERVICE_INFO pushServerInfo;
//    memset(&pushServerInfo, 0, sizeof(TSDK_S_PUSH_SERVICE_INFO));
//    pushServerInfo.push_operation = enable ? TSDK_E_PUSH_REGISTER : TSDK_E_PUSH_ClOSE_PUSH;
//    pushServerInfo.enable_no_push_by_time = enableNoPushByTime;
//    
//    if (strartTime.length == 0 || strartTime == nil || endTime.length == 0 || endTime == nil)
//    {
//        strcpy(pushServerInfo.no_push_start_time, [@"00:00" UTF8String]);
//        strcpy(pushServerInfo.no_push_end_time, [@"00:00" UTF8String]);
//    }else
//    {
//        if (enableNoPushByTime) {
//            strcpy(pushServerInfo.no_push_start_time, [strartTime UTF8String]);
//            strcpy(pushServerInfo.no_push_end_time, [endTime UTF8String]);
//        }else{
//            strcpy(pushServerInfo.no_push_start_time, [@"00:00" UTF8String]);
//            strcpy(pushServerInfo.no_push_end_time, [@"00:00" UTF8String]);
//        }
//        
//    }
//    
//    TSDK_RESULT push_result = tsdk_set_push_service(&pushServerInfo);
//
//    DDLogInfo(@"tsdk_set_push_server,result = %d",push_result);
//}

//- (void)logoutStopPush
//{
//    NSArray *pushTime = [CommonUtils getUserDefaultValueWithKey:PushTimeEnableRecoud];
//    NSString *noPushStart = nil;
//    NSString *noPushEnd = nil;
//    BOOL enableNoPushByTime = NO;
//    if (pushTime != nil) {
//        enableNoPushByTime = [pushTime[0] boolValue];
//        noPushStart = pushTime[1];
//        noPushEnd = pushTime[2];
//    }
//    [self configUportalAPNSEnable:NO noPushStartTime:noPushStart noPushEndTime:noPushEnd enableNoPushByTime:NO];
//}

@end
