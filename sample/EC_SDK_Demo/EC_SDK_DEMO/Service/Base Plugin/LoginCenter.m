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

#import <TUPIOSSDK/ECSAppConfig.h>
#import <TUPIOSSDK/TUPMAALoginService.h>

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
//    [self configSipRelevantParam];
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
    NSArray *array = [CommonUtils getUserDefaultValueWithKey:SRTP_TRANSPORT_MODE];
    
    //config local ip
    TSDK_S_LOCAL_ADDRESS local_ip;
    memset(&local_ip, 0, sizeof(TSDK_S_LOCAL_ADDRESS));
    NSString *ip = [CommonUtils getLocalIpAddressWithIsVPN:[CommonUtils checkIsVPNConnect]];
    strcpy(local_ip.ip_address, [ip UTF8String]);
    TSDK_RESULT configResult = tsdk_set_config_param(TSDK_E_CONFIG_LOCAL_ADDRESS, &local_ip);
    DDLogInfo(@"config local address result: %d; local ip is: %@", configResult, ip);
    
    //config security param
    TSDK_E_MEDIA_SRTP_MODE mediaSrtpMode = TSDK_E_MEDIA_SRTP_MODE_DISABLE;
    SRTP_MODE srtpMode = [array[0] intValue];
    switch (srtpMode) {
        case SRTP_MODE_DISABLE:
            mediaSrtpMode = TSDK_E_MEDIA_SRTP_MODE_DISABLE;
            break;
        case SRTP_MODE_OPTION:
            mediaSrtpMode = TSDK_E_MEDIA_SRTP_MODE_OPTION;
            break;
        case SRTP_MODE_FORCE:
            mediaSrtpMode = TSDK_E_MEDIA_SRTP_MODE_FORCE;
            break;
        default:
            break;
    }
    TSDK_E_SIP_TRANSPORT_MODE transportMode = TSDK_E_SIP_TRANSPORT_UDP;
    TRANSPORT_MODE transmode = [array[1] intValue];
    switch (transmode) {
        case TRANSPORT_MODE_UDP:
            transportMode = TSDK_E_SIP_TRANSPORT_UDP;
            break;
        case TRANSPORT_MODE_TLS:
            transportMode = TSDK_E_SIP_TRANSPORT_TLS;
            break;
        case TRANSPORT_MODE_TCP:
            transportMode = TSDK_E_SIP_TRANSPORT_TCP;
            break;
        default:
            break;
    }
    TSDK_E_SECURITY_TUNNEL_MODE securityTunnelMode = TSDK_E_SECURITY_TUNNEL_MODE_DEFAULT;
    TUNNEL_MODE tunnelMode = [array[6] intValue];
    switch (tunnelMode) {
        case TUNNEL_MODE_DEFAULT:
            securityTunnelMode = TSDK_E_SECURITY_TUNNEL_MODE_DEFAULT;
            break;
        case TUNNEL_MODE_DISABLE:
            securityTunnelMode = TSDK_E_SECURITY_TUNNEL_MODE_DISABLE;
            break;
        default:
            break;
    }
    NSString *priorityTypeString = array[2];
    if (priorityTypeString == nil) {
        priorityTypeString = @"1";
    }
    CONFIG_PRIORITY_TYPE priorityType = [priorityTypeString intValue];
    TSDK_S_SERVICE_SECURITY_PARAM securityParam;
    memset(&securityParam, 0, sizeof(TSDK_S_SERVICE_SECURITY_PARAM));
    securityParam.is_apply_config_priority = (priorityType == CONFIG_PRIORITY_TYPE_APP);
    securityParam.sip_transport_mode = transportMode;
    securityParam.media_srtp_mode = mediaSrtpMode;
    securityParam.security_tunnel_mode = securityTunnelMode;
    configResult = tsdk_set_config_param(TSDK_E_CONFIG_SECURITY_PARAM, &securityParam);
    DDLogInfo(@"config security param result: %d", configResult);
    
    //config network info
    TSDK_S_NETWORK_INFO_PARAM networkInfo;
    memset(&networkInfo, 0, sizeof(TSDK_S_NETWORK_INFO_PARAM));
    NSString * isApplyConfigPriorityString = array[5];
    BOOL is_apply_config_priority = [isApplyConfigPriorityString boolValue];
    if (is_apply_config_priority || isApplyConfigPriorityString == nil)
    {
        networkInfo.sip_server_udp_port = [array[3] intValue];
        networkInfo.sip_server_tls_port = [array[4] intValue];
        networkInfo.sip_server_tcp_port = [array[3] intValue];
    }else{
        networkInfo.sip_server_udp_port = 0;
        networkInfo.sip_server_tls_port = 0;
        networkInfo.sip_server_tcp_port = 0;
    }

    configResult = tsdk_set_config_param(TSDK_E_CONFIG_NETWORK_INFO, &networkInfo);
    DDLogInfo(@"config network info result: %d", configResult);
    
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
            DDLogInfo(@"authorize failed, reason code: %d", reasonCode);
            break;
        }
        case TSDK_E_LOGIN_EVT_AUTH_REFRESH_FAILED:
        {
            TSDK_UINT32 reasonCode = notify.param2;
            DDLogInfo(@"authorize refresh failed, reason code: %d", reasonCode);
            break;
        }
        case TSDK_E_LOGIN_EVT_LOGIN_SUCCESS:
        {
            DDLogInfo(@"sip have been login");
            sipStatus = kCallSipStatusRegistered;
            [self isSipRegistered:sipStatus];
            TSDK_S_LOGIN_SUCCESS_INFO *login_success_info = notify.data;
            if (login_success_info != NULL) {
                [ManagerService confService].uPortalConfType = [self configDeployMode:login_success_info->conf_env_type];
            }
            break;
        }
        case TSDK_E_LOGIN_EVT_LOGIN_FAILED:
        {
            sipStatus = kCallSipStatusUnRegistered;
            TSDK_UINT32 reasonCode = notify.param2;
            DDLogInfo(@"sip login failed, reason code: %d", reasonCode);
            [self isSipRegistered:sipStatus];
            break;
        }
        case TSDK_E_LOGIN_EVT_LOGOUT_SUCCESS:
        {
            DDLogInfo(@"sip unregister");
            sipStatus = kCallSipStatusUnRegistered;
            [self isSipRegistered:sipStatus];
            break;
        }
        case TSDK_E_LOGIN_EVT_LOGOUT_FAILED:
        {
            sipStatus = kCallSipStatusRegistered;
            TSDK_UINT32 reasonCode = notify.param2;
            DDLogInfo(@"sip logout failed, reason code: %d", reasonCode);
            [self isSipRegistered:sipStatus];
            break;
        }
        case TSDK_E_LOGIN_EVT_FORCE_LOGOUT:
        {
            [self logout];
            DDLogInfo(@"sip unregister");
            sipStatus = kCallSipStatusUnRegistered;
            [self isSipRegistered:sipStatus];
            break;
        }
        case TSDK_E_LOGIN_EVT_VOIP_ACCOUNT_STATUS:
        {
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
