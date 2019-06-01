//
//  ECSAppConfig.m
//  eSpaceIOSSDK
//
//  Created by yemingxing on 2/23/15.
//  Copyright (c) 2015 huawei. All rights reserved.
//

#import "ECSAppConfig.h"
#import "ECSDefines.h"
#import <UIKit/UIKit.h>
// TEST
#import "ECSUtils.h"
#import "ECSSandboxHelper.h"
//#import "ECSLogCofig.h"
//#import <ctk.h>
//#import <TUPNetworkSDK/ECSNetworkConfig.h>


NSString* const ECSConfigsVersionKey			= @"ECSConfigsVersionKey";
NSString* const ECSConfigsMaaIPAddressKey		= @"ECSConfigsMaaIPAddressKey";
NSString* const ECSConfigsMaaIPPortKey			= @"ECSConfigsMaaIPPortKey";
NSString* const ECSConfigsCWIPAddressKey		= @"ECSConfigsCWIPAddressKey";
NSString* const ECSConfigsLatestUsedAccountKey	= @"ECSConfigsLatestUsedAccountKey";
NSString* const ECSConfigsUsedAccountskey		= @"ECSConfigsUsedAccountskey";
NSString* const ECSConfigsIsFirstUsedKey		= @"ECSConfigsIsFirstUsedKey";
NSString* const ECSConfigsUserConfigs           = @"ECSConfigsUserConfigs";
NSString* const ECSConfigsServerAbility         = @"ECSConfigsServerAbility";

NSString* const ECSLoggerLevelKey			    = @"ECSLoggerLevelKey";
NSString* const ECSConfigsIsCertificateCheckedEnabledKey = @"ECSConfigsIsCertificateCheckedEnabledKey"; //登录鉴权证书校验是否开启
NSString* const ECSConfigsIsAnyOfficeLoginEnabledKey = @"ECSConfigsIsAnyOfficeLoginEnabledKey"; // 安全网关隧道登录是否开启
NSString* const ECSConfigsIsAppstoreCer         = @"ECSConfigsIsAppstoreCer"; // 是否时AppStore证书打包，CI使用；
NSString* const ECSConfigsIsSVNEnabledKey		= @"ECSConfigsIsSVNEnabledKey";// 安全网关单点登录是否开启
NSString* const ECSConfigsSVNIPAddressKey		= @"ECSConfigsSVNIPAddressKey"; // 安全网关地址
NSString* const ECSConfigsSVNIPPortKey			= @"ECSConfigsSVNIPPortKey"; // 安全网关端口号
NSString* const ECSConfigsSVNAccountKey			= @"ECSConfigsSVNAccountKey";
NSString* const ECSConfigsSVNPasswordKey		= @"ECSConfigsSVNPasswordKey";
NSString* const ECSConfigsIsSVNSameAccountKey   = @"ECSConfigsIsSVNSameAccountKey";
NSString* const ECSConfigsIsLoggerEnabledKey	= @"ECSConfigsIsLoggerEnabledKey";
NSString* const ECSConfigsTraceModeKey          = @"ECSConfigsTraceModeKey";
NSString* const ECSConfigsSVNPwdSaveTypeKey     = @"ECSConfigsSVNPwdSaveTypeKey";

NSString* const  ECSBackgroudOfflineTimeKey = @"ECSBackgroudOfflineTimeKey";

NSString* const  ECSConfigPosterIDKey = @"ECSConfigPosterIDKey";
NSString* const  ECSConfigPosterTimeStampKey = @"ECSConfigPosterTimeStampKey";
NSString* const  ECSConfigPosterBeginTimeKey = @"ECSConfigPosterBeginTimeKey";
NSString* const  ECSConfigPosterEndTimeKey = @"ECSConfigPosterEndTimeKey";

NSString* const ECSConfigsDeviceTokenKey           =  @"ECSConfigsDeviceTokenKey";

NSString* const ECSApnsTypeKey                      = @"ECSApnsTypeKey";

NSString* const ECSDeviceTypeKey					= @"ECSDeviceTypeKey";

NSString* const ECSLanguageKey						= @"ECSLanguageKey";

NSString* const ECSConfigsLatestAnyOfficeUsedAccountKey = @"ECSConfigsLatestAnyOfficeUsedAccountKey";

NSString* const ECSPhoneCallTipKey                = @"ECSPhoneCallTipKey";
NSString* const ECSCTDCallTipKey                  = @"ECSCTDCallTipKey";
NSString* const ECSCertsCheckedRetKey              = @"ECSCertsCheckedRetKey";
NSString* const ECSConfigIsAcceptPrivacy          = @"ECSConfigIsAcceptPrivacy";

NSString* const ECSConfigsDBRandomStringKey         = @"ECSConfigsDBRandomStringKey";
NSString* const ECSConfigsPLRandomStringKey         = @"ECSConfigsPLRandomStringKey";

NSString* const ECSAppIDStringKey = @"ECSAppIDStringKey";
NSString* const ECSAppNameStringKey = @"ECSAppNameStringKey";
NSString* const ECSAppUrlStringKey = @"ECSAppUrlStringKey";

NSString* const ECSServerEnvKey = @"ECSServerEnvKey";
NSString* const ECSVoIPTokenKey = @"ECSVoIPTokenKey";
NSString* const ECSUportalConfTypeKey = @"ECSUportalConfTypeKey";
NSString* const ECSUpdateAccountCaseSensitiveKey = @"ECSUpdateAccountCaseSensitiveKey";
NSString* const ECSUserAccountMapDicKey = @"ECSUserAccountMapDicKey";
NSString* const ECSIsLastSTGLoginKey = @"ECSIsLastSTGLoginKey";
NSString* const ECSIsChineseLanguageKey = @"ECSIsChineseLanguageKey";
NSString* const ECSProxyServerInfoKey = @"ESpaceProxyServerInfo";

@interface ECSAppConfig ()
@property (nonatomic, copy) NSString* latestAnyOfficeAccount;
@end

@implementation ECSAppConfig
@synthesize latestAccount = _latestAccount;
@synthesize svnPassword = _svnPassword;
@synthesize dbSecurityRandomStr;
@synthesize plistSecurityRandomStr;
@synthesize functionConfig;
@synthesize voipToken = _voipToken;

+ (instancetype) sharedInstance {
    static ECSAppConfig* appConfig;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        appConfig = [[ECSAppConfig alloc] initInternal];
    });
    return appConfig;
}

- (NSString*) posterPath {
    return [ECSAppConfig pathForPoster:self.posterId];
}

+ (NSString*) pathForPoster:(NSString*) posterId {
    if (posterId) {
        return [[ECSSandboxHelper shareInstance].tempPath stringByAppendingPathComponent:posterId];
    }
    return nil;
}

- (BOOL)subscribeState {
    return YES;
}

- (NSString *)deviceToken {
    if (!_deviceToken) {
        return @"";
    }
    return _deviceToken;
    
}

-(void)setVoipToken:(NSString *)voipToken{
    _voipToken = voipToken;
}

-(NSString *)voipToken{
    if (!_voipToken) {
        return @"";
    }
    return _voipToken;
}

+ (BOOL)isIphone {
    return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone;
}

+ (BOOL) isIpad {
    return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;
}

- (APNS_SERVER_TYPE) apnSrvType {
    APNS_SERVER_TYPE serverType = APNS_SERVER_TYPE_INVALID;
    if ([_apnsType isEqualToString:APNS_DEV]) {
        serverType = APNS_SERVER_TYPE_DEVELOPE;
    } else if ([_apnsType isEqualToString:APNS_PRODUCT]) {
        serverType = APNS_SERVER_TYPE_PRODUCTION;
    } else if ([_apnsType isEqualToString:APNS_ENTERPRISE]) {
        serverType = APNS_SERVER_TYPE_PRODUCTION;
    }
    return serverType;
}

- (APNS_CER_TYPE)apnCertType {
    APNS_CER_TYPE cerType = APNS_CER_TYPE_INVALID;
    if ([_apnsType isEqualToString:APNS_DEV]) {
        cerType = [ECSAppConfig isIphone] ? APNS_CER_TYPE_APPSTORE : APNS_CER_TYPE_APPSTORE_HD;
    } else if ([_apnsType isEqualToString:APNS_PRODUCT]) {
        cerType = [ECSAppConfig isIphone] ? APNS_CER_TYPE_APPSTORE : APNS_CER_TYPE_APPSTORE_HD;
    } else if ([_apnsType isEqualToString:APNS_ENTERPRISE]) {
        cerType = [ECSAppConfig isIphone] ? APNS_CER_TYPE_ENTERPRISE : APNS_CER_TYPE_ENTERPRISE_HD;
    }
    return cerType;
}
static const char * const s_DBCONSTString = "aedkfjdiodiejjfk";
- (void)setDbSecurityRandomStr:(NSString *)string {
    if (0 == [dbSecurityRandomStr length]) {//只允许设置一次
        if ([string length]) {
            dbSecurityRandomStr = string;
        }
        else{
            dbSecurityRandomStr = [NSString stringWithUTF8String:s_DBCONSTString];
        }
        
    }
    else{
        //SDK_DEBUG_LOG("dbSecurityRandomStr can not set value repeatly.");
        
    }
}

- (NSString*)dbSecurityRandomStr {
    //兼容老版本，老版本仍然使用固定key值进行加密；新安装采用随机固定key值进行加密
    if (0 == [dbSecurityRandomStr length]) {
        dbSecurityRandomStr = [NSString stringWithUTF8String:s_DBCONSTString];
    }
    
    return dbSecurityRandomStr;
}

static NSString* const CONSTString = @"AQEFDFGHUK986JMK";
- (void)setPlistSecurityRandomStr:(NSString *)string {
    if (0 == [plistSecurityRandomStr length]) {//只允许设置一次
        if ([string length]) {
            plistSecurityRandomStr = string;
        }
        else{
            plistSecurityRandomStr = CONSTString;
        }
        
    }
    else{
        //SDK_DEBUG_LOG("plistSecurityRandomStr can not set value repeatly.");
    }
}
- (NSString*)plistSecurityRandomStr {
    //兼容老版本，老版本仍然使用固定key值进行加密；新安装采用随机固定key值进行加密
    if (0 == [plistSecurityRandomStr length]) {
        plistSecurityRandomStr = CONSTString;
    }
    
    return plistSecurityRandomStr;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_version forKey:ECSConfigsVersionKey];
    [aCoder encodeObject:_maaAddress forKey:ECSConfigsMaaIPAddressKey];
    [aCoder encodeInteger:_maaPort forKey:ECSConfigsMaaIPPortKey];
    [aCoder encodeObject:_cwAddress forKey:ECSConfigsCWIPAddressKey];
    [aCoder encodeObject:self.deviceToken forKey:ECSConfigsDeviceTokenKey];
    [aCoder encodeObject:_apnsType forKey:ECSApnsTypeKey];
    [aCoder encodeObject:_latestAccount forKey:ECSConfigsLatestUsedAccountKey];
    [aCoder encodeObject:_latestAnyOfficeAccount forKey:ECSConfigsLatestAnyOfficeUsedAccountKey];
    [aCoder encodeBool:_isFirstUsed forKey:ECSConfigsIsFirstUsedKey];
    [aCoder encodeBool:_isAnyOfficeLogin forKey:ECSConfigsIsAnyOfficeLoginEnabledKey];
    [aCoder encodeBool:_isCerChecked forKey:ECSConfigsIsCertificateCheckedEnabledKey];
    [aCoder encodeBool:_isSVNEnabled forKey:ECSConfigsIsSVNEnabledKey];
    [aCoder encodeObject:_svnAddress forKey:ECSConfigsSVNIPAddressKey];
    [aCoder encodeInteger:_svnPort forKey:ECSConfigsSVNIPPortKey];
    [aCoder encodeObject:_svnPassword forKey:ECSConfigsSVNPasswordKey];
    [aCoder encodeObject:_svnAccount forKey:ECSConfigsSVNAccountKey];
    [aCoder encodeBool:_isSVNAccountSameWithUserAccount forKey:ECSConfigsIsSVNSameAccountKey];
    [aCoder encodeBool:_isLogEnabled forKey:ECSConfigsIsLoggerEnabledKey];
    [aCoder encodeInteger:_trackMode forKey:ECSConfigsTraceModeKey];
    [aCoder encodeInteger:_svnPwdSaveType forKey:ECSConfigsSVNPwdSaveTypeKey];
    [aCoder encodeDouble:_bkgOfflineTime forKey:ECSBackgroudOfflineTimeKey];
    [aCoder encodeObject:_posterId forKey:ECSConfigPosterIDKey];
    [aCoder encodeDouble:_posterTimestamp forKey:ECSConfigPosterTimeStampKey];
    [aCoder encodeDouble:_posterBeginTime forKey:ECSConfigPosterBeginTimeKey];
    [aCoder encodeDouble:_posterEndTime forKey:ECSConfigPosterEndTimeKey];
    [aCoder encodeObject:_userConfigs forKey:ECSConfigsUserConfigs];
    [aCoder encodeInt64:_appLogLevel forKey:ECSLoggerLevelKey];
//    [aCoder encodeObject:_serverAbility forKey:ECSConfigsServerAbility];
    [aCoder encodeBool:_needPhoneCallTip forKey:ECSPhoneCallTipKey];
    [aCoder encodeBool:_needCTDCallTip forKey:ECSCTDCallTipKey];
    [aCoder encodeInteger:_certsCheckedRet forKey:ECSCertsCheckedRetKey];
    [aCoder encodeBool:_isAcceptPrivacy forKey:ECSConfigIsAcceptPrivacy];
    [aCoder encodeObject:_clientLanguage forKey:ECSLanguageKey];
    [aCoder encodeObject:dbSecurityRandomStr forKey:ECSConfigsDBRandomStringKey];
    [aCoder encodeObject:plistSecurityRandomStr forKey:ECSConfigsPLRandomStringKey];
    [aCoder encodeObject:_appID forKey:ECSAppIDStringKey];
    [aCoder encodeObject:_appName forKey:ECSAppNameStringKey];
    [aCoder encodeObject:_appUrl forKey:ECSAppUrlStringKey];
    [aCoder encodeInteger:_serverEnv forKey:ECSServerEnvKey];
    [aCoder encodeObject:self.voipToken forKey:ECSVoIPTokenKey];
    [aCoder encodeInteger:_uPortalConfType forKey:ECSUportalConfTypeKey];
    [aCoder encodeBool:_isUpdatedAccountCaseSensitive forKey:ECSUpdateAccountCaseSensitiveKey];
    [aCoder encodeObject:_userAccountMapDic forKey:ECSUserAccountMapDicKey];
    [aCoder encodeBool:_isLastSTGLogin forKey:ECSIsLastSTGLoginKey];
    [aCoder encodeBool:_isChineseLaguage forKey:ECSIsChineseLanguageKey];
    [aCoder encodeObject:_proxyServerInfo forKey:ECSProxyServerInfoKey];

}

- (id) initInternal {
    NSString* path  = [ECSAppConfig pathForAppConfig];
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        NSData* data = [NSData dataWithContentsOfFile:path];
        self = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        [self configNetworkService];
    } else {
        if (self = [self init]) {
            _isFirstUsed = YES;
            _needPhoneCallTip = YES;
            _needCTDCallTip = YES;
            _certsCheckedRet = ECSCertsStateUnKnow;
            _maaAddress = [ECSAppConfig defaultDomain];
            _maaPort = [ECSAppConfig defaultPort];
            _userConfigs = [NSMutableDictionary dictionary];
            _isAnyOfficeLogin = [ECSAppConfig isAnyOfficeLogin];
            _isCerChecked = [ECSAppConfig isCerChecked];
            _isSVNEnabled = [ECSAppConfig isSVNEnabled];
            _isLogEnabled = NO;
            _isAcceptPrivacy = NO;
            _svnAddress = [ECSAppConfig svnAddress];
            _svnPort = [ECSAppConfig svnPort];
            _serverEnv = [ECSAppConfig serverEnvironment];
            _isUpdatedAccountCaseSensitive = YES;
            _userAccountMapDic = [[NSMutableDictionary alloc] init];
            _version = @"V3.0.4.5";
            [self save];
            [self configNetworkService];
        }
    }

    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [self init]) {
        _version = [aDecoder decodeObjectOfClass:[NSString class] forKey:ECSConfigsVersionKey];
        _maaAddress = [aDecoder decodeObjectOfClass:[NSString class] forKey:ECSConfigsMaaIPAddressKey];
        _maaPort = [aDecoder decodeIntegerForKey:ECSConfigsMaaIPPortKey];
        _cwAddress = [aDecoder decodeObjectOfClass:[NSString class]  forKey:ECSConfigsCWIPAddressKey];
        _deviceToken = [aDecoder decodeObjectOfClass:[NSString class] forKey:ECSConfigsDeviceTokenKey];
        _apnsType = [aDecoder decodeObjectOfClass:[NSString class] forKey:ECSApnsTypeKey];
        _latestAccount = [aDecoder decodeObjectOfClass:[NSString class] forKey:ECSConfigsLatestUsedAccountKey];
        _latestAnyOfficeAccount = [aDecoder decodeObjectOfClass:[NSString class] forKey:ECSConfigsLatestAnyOfficeUsedAccountKey];
        _isFirstUsed = [aDecoder decodeBoolForKey:ECSConfigsIsFirstUsedKey];
        _isSVNEnabled = [aDecoder decodeBoolForKey:ECSConfigsIsSVNEnabledKey];
        _isAnyOfficeLogin = [aDecoder decodeBoolForKey:ECSConfigsIsAnyOfficeLoginEnabledKey];
        _isCerChecked = [aDecoder decodeBoolForKey:ECSConfigsIsCertificateCheckedEnabledKey];
        _svnAddress = [aDecoder decodeObjectOfClass:[NSString class] forKey:ECSConfigsSVNIPAddressKey];
        _svnPort = [aDecoder decodeIntegerForKey:ECSConfigsSVNIPPortKey];
        _svnAccount = [aDecoder decodeObjectOfClass:[NSString class] forKey:ECSConfigsSVNAccountKey];
        _svnPassword = [aDecoder decodeObjectOfClass:[NSString class] forKey:ECSConfigsSVNPasswordKey];
        _isSVNAccountSameWithUserAccount = [aDecoder decodeBoolForKey:ECSConfigsIsSVNSameAccountKey];
        _isLogEnabled = [aDecoder decodeBoolForKey:ECSConfigsIsLoggerEnabledKey];
        _trackMode = (HMETraceMode)[aDecoder decodeIntegerForKey:ECSConfigsTraceModeKey];
        _svnPwdSaveType = (PSW_PROTECT_TYPE)[aDecoder decodeIntegerForKey:ECSConfigsSVNPwdSaveTypeKey];
        _bkgOfflineTime = [aDecoder decodeDoubleForKey:ECSBackgroudOfflineTimeKey];
        _posterId = [aDecoder decodeObjectOfClass:[NSString class] forKey:ECSConfigPosterIDKey];
        _posterTimestamp = [aDecoder decodeDoubleForKey:ECSConfigPosterTimeStampKey];
        _posterBeginTime = [aDecoder decodeDoubleForKey:ECSConfigPosterBeginTimeKey];
        _posterEndTime = [aDecoder decodeDoubleForKey:ECSConfigPosterEndTimeKey];
        _appLogLevel = (ECSLogLevel)[aDecoder decodeIntegerForKey:ECSLoggerLevelKey];
        _userConfigs = [NSMutableDictionary dictionaryWithDictionary:[aDecoder decodeObjectOfClass:[NSDictionary class] forKey:ECSConfigsUserConfigs]];
//        _serverAbility = (ECSServerAbility*) [aDecoder decodeObjectOfClass:[ECSServerAbility class] forKey:ECSConfigsServerAbility];
        _needPhoneCallTip = [aDecoder decodeBoolForKey:ECSPhoneCallTipKey];
        _needCTDCallTip = [aDecoder decodeBoolForKey:ECSCTDCallTipKey];
        _certsCheckedRet = [aDecoder decodeIntegerForKey:ECSCertsCheckedRetKey];
        if (!_userConfigs) {
            _userConfigs = [NSMutableDictionary dictionary];
        }
        _isAcceptPrivacy = [aDecoder decodeBoolForKey:ECSConfigIsAcceptPrivacy];
        _clientLanguage = [aDecoder decodeObjectForKey:ECSLanguageKey];
        dbSecurityRandomStr = [aDecoder decodeObjectForKey:ECSConfigsDBRandomStringKey];
        plistSecurityRandomStr = [aDecoder decodeObjectForKey:ECSConfigsPLRandomStringKey];
        _appID = [aDecoder decodeObjectForKey:ECSAppIDStringKey];
        _appName = [aDecoder decodeObjectForKey:ECSAppNameStringKey];
        _appUrl = [aDecoder decodeObjectForKey:ECSAppUrlStringKey];
        _serverEnv = (ECSServerEnvironment)[aDecoder decodeIntegerForKey:ECSServerEnvKey];
        _voipToken = [aDecoder decodeObjectForKey:ECSVoIPTokenKey];
        _uPortalConfType = (ECSUPortalConfType)[aDecoder decodeIntegerForKey:ECSUportalConfTypeKey];
        
        if ([aDecoder containsValueForKey:ECSUpdateAccountCaseSensitiveKey]) {
            _isUpdatedAccountCaseSensitive = [aDecoder decodeBoolForKey:ECSUpdateAccountCaseSensitiveKey];
        }
        else{
            _isUpdatedAccountCaseSensitive = NO;
        }
        _userAccountMapDic = [NSMutableDictionary dictionaryWithDictionary:[aDecoder decodeObjectOfClass:[NSDictionary class] forKey:ECSUserAccountMapDicKey]];
        if (!_userAccountMapDic) {
            _userAccountMapDic = [[NSMutableDictionary alloc] init];
        }
        
        _isLastSTGLogin = [aDecoder decodeBoolForKey:ECSIsLastSTGLoginKey];
        _isChineseLaguage = [aDecoder decodeBoolForKey:ECSIsChineseLanguageKey];
        _proxyServerInfo = (ESpaceProxyServerInfo*) [aDecoder decodeObjectOfClass:[ESpaceProxyServerInfo class] forKey:ECSProxyServerInfoKey];

    }
    return self;
}

- (ESpaceFunctionConfig*)functionConfig {
    if (nil == functionConfig) {
        functionConfig = [[ESpaceFunctionConfig alloc] init];
    }
    
    return functionConfig;
}

//- (void)setSvnPassword:(NSString *)svnPwd
//{
//    // 如果清空svn密码，则不需要再做去加盐值, 加密
//    if (svnPwd.length == 0) {
//        _svnPassword = svnPwd;
//        return;
//    }
//
//    if (_svnPwdSaveType == PSW_PROTECT_SALT) {
//        svnPwd = [ECSUtils psw:svnPwd withSalt:_svnAccount];
//    }
//
//    svnPwd = [ECSUtils plistDataEncrypt:svnPwd];
//
//    _svnPassword = svnPwd;
//}

//- (NSString*)svnPassword
//{
//    if (_svnPassword.length == 0) {
//        return _svnPassword;
//    }
//
//    NSString* svnPwd = [ECSUtils plistDataDecrypt:_svnPassword];
//
//    if (_svnPwdSaveType == PSW_PROTECT_SALT) {
//        svnPwd = [ECSUtils psw:_svnPassword
//                   withoutSalt:_svnAccount];
//    }
//
//    return svnPwd;
//}

- (NSString *)latestAccount
{
    if (self.isAnyOfficeLogin) {
//        NSString *currentAccount = [[LoginAgent getInstance] getUserInfo].userName;
//        if (currentAccount.length > 0
//            && ![currentAccount isEqualToString:_latestAnyOfficeAccount]) {
//            _latestAnyOfficeAccount = currentAccount;
//            NSLog(@"_latestAnyOfficeAccount %@", _latestAnyOfficeAccount);
//        }
        return _latestAnyOfficeAccount;
    }
    return _latestAccount;
}

- (void)setLatestAccount:(NSString *)a
{
//    if (self.isAnyOfficeLogin) {
//        _latestAnyOfficeAccount = [a copy];
//    }
//    else {
        _latestAccount = [a copy];
//    }
    
//    [ECSNetworkConfig sharedInstance].latestAccount = _latestAccount;
}

- (ECSUserConfig*) currentUser {
    return [self configForUser:self.latestAccount];
}

- (ECSUserConfig*) configForUser:(NSString*) user {
    if ([user length] == 0) {
        return nil;
    }
    
    //根据参数user到映射表中查找真实账号
    NSString *convertUser = [self getAckAccountFromLoginAccount:[[NSString alloc] initWithString:user]];
    
    //区分账号大小写
    ECSUserConfig *config = [_userConfigs valueForKey:convertUser];
    if (!config) {
        config = [[ECSUserConfig alloc] initWithAccount:convertUser];
        [_userConfigs setObject:config forKey:convertUser];
    }
    
    return config;
}

+ (NSString*) pathForAppConfig{
    NSString* path = [[ECSSandboxHelper shareInstance].documentPath stringByAppendingPathComponent:@"AppConfig.plist"];
    return path;
}

- (BOOL) removeUserConfig:(NSString*) user {
    if ([user length] == 0) {
        return NO;
    }
    
    BOOL result = NO;
    
    //区分账号大小写
    ECSUserConfig *config = [_userConfigs valueForKey:user];
    if (config) {
        [_userConfigs removeObjectForKey:user];//要区分大小写
        result = YES;
    }
    
    return result;
}

- (BOOL)save {    
    NSData* data = [NSKeyedArchiver archivedDataWithRootObject:self];
    NSString* path = [ECSAppConfig pathForAppConfig];
    if (path) {
        return [data writeToFile:path atomically:YES];
    } else {
        return NO;
    }
}

- (NSArray *)allUserAccounts
{
    return [_userConfigs allKeys];
}

- (void)initializeSecurityRandomKey {
    if (self.isFirstUsed) {
        self.dbSecurityRandomStr = [ECSUtils getRandomSaltString];
        self.plistSecurityRandomStr = [ECSUtils getRandomSaltString];
    }
}

- (void)setUserConfig:(ECSUserConfig *)config forKey:(NSString *)key {
    if (nil == config || 0 == [key length]) {
        return;
    }
    [_userConfigs setObject:config forKey:key];
}

- (ECSUserConfig *)getUserConfigForKey:(NSString *)key {
    if (0 == [key length] || nil == _userConfigs) {
        return nil;
    }
    
    return [_userConfigs objectForKey:key];
}

- (void)mapLoginAccount:(NSString *)loginAccount toAckAccount:(NSString *)ackAccount {
    if (0 == [loginAccount length] || 0 == [ackAccount length]) {
        return;
    }
    
    if (!_userAccountMapDic) {
        _userAccountMapDic = [[NSMutableDictionary alloc] init];
    }
    
    [_userAccountMapDic setObject:ackAccount forKey:loginAccount];
}

/**
 *  根据登录账号获取服务器返回的账号
 *
 *  @param loginAccount 用户输入的登录账号
 *
 *  @return 服务器返回的账号
 */
- (NSString *)getAckAccountFromLoginAccount:(NSString *)loginAccount {
    if (0 == [loginAccount length] || !_userAccountMapDic) {
        return nil;
    }
    
    NSString *parameter = [loginAccount copy];
    NSString *resultString = [_userAccountMapDic objectForKey:parameter];
    if (0 == [resultString length]) {
        resultString = parameter;
    }
    
    return resultString;
}

- (void)setAppID:(NSString *)appID
{
    if ([appID length] == 0) {
        _appID = @"";
        return;
    }
    _appID = appID;
}

- (void)setAppName:(NSString *)appName{
    if ([appName length] == 0) {
        _appName = @"";
        return;
    }
    _appName = appName;
}

- (void)setAppUrl:(NSString *)appUrl{
    if ([appUrl length] == 0) {
        _appUrl = @"";
        return;
    }
    _appUrl = appUrl;
}

- (void)setMaaAddress:(NSString *)maaAddress
{
    if (maaAddress.length == 0) {
        _maaAddress = @"";
        self.serverEnv = ECSServerEnvironmentUnknow;
        return;
    }
    
    // 地址变更，组网探测结果修改为未知
    if (![maaAddress isEqualToString:_maaAddress]) {
        self.serverEnv = ECSServerEnvironmentUnknow;
    }
    
    _maaAddress = maaAddress;
}

- (void)setMaaPort:(NSUInteger)maaPort
{
    // 端口变更，组网探测结果修改为未知
    if (maaPort != _maaPort) {
        self.serverEnv = ECSServerEnvironmentUnknow;
    }
    
    _maaPort = maaPort;
}


#pragma mark - static configuration
#pragma mark - 配置数据读取
+ (NSDictionary*)configInfo
{
    NSString *path = [[ECSSandboxHelper shareInstance].UIResourceBundle pathForResource:@"Configs" ofType:@"plist"];
    NSDictionary *info = [NSDictionary dictionaryWithContentsOfFile:path];
    return info;
}

//+ (BOOL)saveConfigInfo:(NSDictionary *)info
//{
//    if (nil == info) {
//        return NO;
//    }
//    NSString *path = [[NSBundle mainBundle] pathForResource:@"Configs" ofType:@"plist"];
//    NSData* data = [NSKeyedArchiver archivedDataWithRootObject:info];
//    return [data writeToFile:path atomically:YES];
//}

+ (BOOL)isCerChecked
{
    NSDictionary *info = [ECSAppConfig configInfo];
    NSNumber *nsbool = [info objectForKey:ECSConfigsIsCertificateCheckedEnabledKey];
    if (nil == nsbool) {
        //        NSLog(@"can not find configuration of |ECSConfigsIsCertificateCheckedEnabledKey|");
    }
    return nsbool.boolValue;
}

+ (BOOL)isAnyOfficeLogin
{
    NSDictionary *info = [ECSAppConfig configInfo];
    NSNumber *nsbool = [info objectForKey:ECSConfigsIsAnyOfficeLoginEnabledKey];
    if (nil == nsbool) {
//        NSLog(@"can not find configuration of |ECSConfigsIsAnyOfficeLoginEnabledKey|");
    }
    return nsbool.boolValue;
}

- (BOOL)isMDMSSO
{
#if !ESDK_HWSPACE
    NSDictionary *info = [ECSAppConfig configInfo];
    NSNumber *nsbool = [info objectForKey:ECSConfigsIsAppstoreCer]; //使用AppStore证书打包，则不采用MDMSSO
    if (nil == nsbool) {
        return YES;
    }
    return !nsbool.boolValue;
#endif
    return YES;
}

- (BOOL)isHWUCVersion
{
#if !ESDK_HWSPACE
    //使用AppStore证书打包为基线版本，HWUC版本使用企业证书打包
    NSDictionary *info = [ECSAppConfig configInfo];
    NSNumber *nsbool = [info objectForKey:ECSConfigsIsAppstoreCer];
    if (nil == nsbool) {
        return YES;
    }
    return !nsbool.boolValue;
#endif
    return YES;
}

+ (BOOL)isSVNEnabled
{
    NSDictionary *info = [ECSAppConfig configInfo];
    NSNumber *nsbool = [info objectForKey:ECSConfigsIsSVNEnabledKey];
    if (nil == nsbool) {
//        DDLogWarn(@"can not find configuration of |ECSConfigsIsSVNEnabledKey|");
        return NO;
    }
    return nsbool.boolValue;
}

//+ (BOOL)setIsAnyOfficeLoginConfig:(BOOL)bValue
//{
//    NSMutableDictionary *info = [[ECSAppConfig configInfo] mutableCopy];
//    NSNumber *nsbool = @(bValue);
//    [info setObject:nsbool forKey:ECSConfigsIsAnyOfficeLoginEnabledKey];
//   
//    return [self saveConfigInfo:info];
//}

+ (BOOL)isShowServerSetting
{
    NSNumber *isShow = [[ECSAppConfig configInfo] objectForKey:@"kECSShowServerSettingKey"];
    if (![isShow boolValue]) {
        //SDK_WRN_LOG("can't find kECSShowServerSettingKey");
        return YES;
    }
    return [isShow boolValue];
}

+ (NSString*)defaultDomain
{
    NSDictionary *info = [ECSAppConfig configInfo];
    NSString *defaultDomain = [info objectForKey:@"kECSDefaultDomain"];
    return [defaultDomain length] > 0 ? defaultDomain : @"";
}

+ (NSInteger)defaultPort
{
    NSDictionary *info = [ECSAppConfig configInfo];
    NSString *defaultDomain = [info objectForKey:@"kECSDefaultPort"];
    return [defaultDomain length] > 0 ? [defaultDomain integerValue] : 0;
}

+ (NSString *)svnAddress
{
    NSString *address = [[ECSAppConfig configInfo] objectForKey:@"ECSConfigsSVNIPAddressKey"];
    return [address length] > 0 ? address : @"";
}

+ (NSUInteger)svnPort
{
    NSNumber *port = [[ECSAppConfig configInfo] objectForKey:@"ECSConfigsSVNIPPortKey"];
    if (![port boolValue]) {
//        DDLogWarn(@"can't find ECSConfigsSVNIPPortKey");// 调用此方法时DDLog日志模块还未初始化
        return 0;
    }
    return [port unsignedIntegerValue];
}

+ (NSString*)w3URL
{
    NSDictionary *info = [ECSAppConfig configInfo];
    NSString* w3URL = [info objectForKey:@"kECSW3URL"];
    return [w3URL length] > 0 ? w3URL : @"";
}

+ (NSString*)directAccessList
{
    NSDictionary *info = [ECSAppConfig configInfo];
    NSString* directAccessList = [info objectForKey:@"kECSDirectAccessList"];
    return [directAccessList length]>0? directAccessList : @"";
}

+ (NSString*)undirectAccessList
{
    NSDictionary *info = [ECSAppConfig configInfo];
    NSString* directAccessList = [info objectForKey:@"kECSUndirectAccessList"];
    return [directAccessList length]>0? directAccessList : @"";
}

+ (NSString*)w3HostAuth
{
    NSDictionary *info = [ECSAppConfig configInfo];
    NSString *w3HostAuth = [info objectForKey:@"kECSW3HostAuth"];
    return [w3HostAuth length] > 0 ? w3HostAuth : @"";
}

+ (NSString*)defaultMail
{
    NSDictionary *info = [ECSAppConfig configInfo];
    NSString *defaultMail = [info objectForKey:@"kECSDefaultMail"];
    return [defaultMail length] > 0 ? defaultMail : @"";
}

+ (NSString*)aesSalt
{
    NSDictionary *info = [ECSAppConfig configInfo];
    NSString *aesSalt = [info objectForKey:@""];
    return [aesSalt length] > 0 ? aesSalt : @"";
}

+ (ECSServerEnvironment)serverEnvironment
{
    NSDictionary* info = [ECSAppConfig configInfo];
    NSNumber* serverEnv = [info objectForKey:@"ECSServerEnvironment"];
    if (![serverEnv boolValue]) {
        return ECSServerEnvironmentUnknow;
    }
    return (ECSServerEnvironment)[serverEnv unsignedIntegerValue];
}

- (void)setIsUpdatedAccountCaseSensitive:(BOOL)updated {
    if (NO == updated) {//不允许外部设置为NO
        return;
    }
    _isUpdatedAccountCaseSensitive = updated;
}

#pragma mark Config Network

- (void)configNetworkService
{
//    ECSNetworkConfig *networkConfig = [ECSNetworkConfig sharedInstance];
//    networkConfig.isSVNEnabled = _isSVNEnabled;
//    networkConfig.isAnyOfficeLogin = _isAnyOfficeLogin;
//    networkConfig.isMDMSSO = self.isMDMSSO;
//    networkConfig.appLogLevel = _appLogLevel;
//    networkConfig.isLogEnabled = _isLogEnabled;
//    networkConfig.supportSsoOperation = self.functionConfig.supportSsoOperation;
//    networkConfig.latestAccount = _latestAccount;
//    networkConfig.version = _version;
}

- (void)setIsSVNEnabled:(BOOL)isSVNEnabled
{
    _isSVNEnabled = isSVNEnabled;
//    [ECSNetworkConfig sharedInstance].isSVNEnabled = _isSVNEnabled;
}

- (void)setIsAnyOfficeLogin:(BOOL)isAnyOfficeLogin
{
    _isAnyOfficeLogin = isAnyOfficeLogin;
//    [ECSNetworkConfig sharedInstance].isAnyOfficeLogin = _isAnyOfficeLogin;
}

- (void)setAppLogLevel:(ECSLogLevel)appLogLevel
{
    _appLogLevel = appLogLevel;
//    [ECSNetworkConfig sharedInstance].appLogLevel = _appLogLevel;
}

- (void)setIsLogEnabled:(BOOL)isLogEnabled
{
    _isLogEnabled = isLogEnabled;
//    [ECSNetworkConfig sharedInstance].isLogEnabled = _isLogEnabled;
}

- (void)setVersion:(NSString *)version
{
    _version = version;
//    [ECSNetworkConfig sharedInstance].version = _version;
}

@end

@implementation ESpaceFunctionConfig

@synthesize supportPublicAccout;
@synthesize supportCircle ;
@synthesize supportLocalContact;
@synthesize supportGroupMemberChangeNotifyOnlyForOwner;
@synthesize supportContactNickName;
@synthesize supportContactRemarkName;
@synthesize roamingRecentSessionCount;
@synthesize supportGroupAnnounceChangedNotify;

-(id)init {
    if (self = [super init]) {
        self.supportPublicAccout = YES;
        self.supportCircle = YES;
        self.supportLocalContact = YES;
        self.supportSsoOperation = YES;
        self.supportGroupMemberChangeNotifyOnlyForOwner = NO;
        self.supportContactNickName = YES;
        self.supportContactRemarkName = NO;
        self.roamingRecentSessionCount = 0;
        self.supportGroupAnnounceChangedNotify = NO;
    }
    
    return self;
}

- (void)setSupportSsoOperation:(BOOL)supportSsoOperation
{
    _supportSsoOperation = supportSsoOperation;
}

@end

NSString* const ECSProxyServerAddress = @"ECSProxyServerAddress";
NSString* const ECSProxyServerPort = @"ECSProxyServerPort";
NSString* const ECSProxyServerAccount = @"ECSProxyServerAccount";
NSString* const ECSProxyServerPsw = @"ECSProxyServerPsw";
NSString* const ECSOpenProxyServer = @"ECSOpenProxyServer";
NSString* const ECSOpenProxyAuthServer = @"ECSOpenProxyAuthServer";

@implementation ESpaceProxyServerInfo
@synthesize proxyAuthPsw = _proxyAuthPsw;

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        _proxyAddress = [aDecoder decodeObjectOfClass:[NSString class] forKey:ECSProxyServerAddress];
        _proxyPort = [aDecoder decodeIntegerForKey:ECSProxyServerPort];
        _proxyAuthAccount = [aDecoder decodeObjectOfClass:[NSString class] forKey:ECSProxyServerAccount];
        _proxyAuthPsw = [aDecoder decodeObjectOfClass:[NSString class] forKey:ECSProxyServerPsw];
        _openProxy = [aDecoder decodeBoolForKey:ECSOpenProxyServer];
        _openProxyAuth = [aDecoder decodeBoolForKey:ECSOpenProxyAuthServer];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_proxyAddress forKey:ECSProxyServerAddress];
    [aCoder encodeInteger:_proxyPort forKey:ECSProxyServerPort];
    [aCoder encodeObject:_proxyAuthAccount forKey:ECSProxyServerAccount];
    [aCoder encodeObject:_proxyAuthPsw forKey:ECSProxyServerPsw];
    [aCoder encodeBool:_openProxy forKey:ECSOpenProxyServer];
    [aCoder encodeBool:_openProxyAuth forKey:ECSOpenProxyAuthServer];
}

- (instancetype)init
{
    if (self = [super init]) {
        _proxyAddress = @"";
        _proxyPort = 0;
        _proxyAuthAccount = @"";
        _proxyAuthPsw = @"";
        _openProxy = NO;
        _openProxyAuth = NO;
    }
    return self;
}

- (NSString *)proxyAddress
{
    if ([_proxyAddress length] == 0) {
        return @"";
    }
    return _proxyAddress;
}

- (NSString *)proxyAuthAccount
{
    if (_proxyAuthAccount.length == 0) {
        return @"";
    }
    return _proxyAuthAccount;
}

//- (void)setProxyAuthPsw:(NSString *)proxyAuthPsw
//{
//    // 如果清空svn密码，则不需要再做去加盐值, 加密
//    if (proxyAuthPsw.length == 0) {
//        _proxyAuthPsw = @"";
//        return;
//    }
//
//    _proxyAuthPsw = [ECSUtils plistDataEncrypt:proxyAuthPsw];
//}

//- (NSString *)proxyAuthPsw
//{
//    if (_proxyAuthPsw.length == 0) {
//        return @"";
//    }
//    return [ECSUtils plistDataDecrypt:_proxyAuthPsw];
//}

#pragma mark - 根据开关过滤过的代理参数
- (NSString *)filterProxyAddress
{
    if (self.openProxy == NO || [_proxyAddress length] == 0) {
        return @"";
    }
    return _proxyAddress;
}

- (NSUInteger)filterProxyPort
{
    if (self.openProxy == NO || 0 == _proxyPort) {
        return 0;
    }
    return _proxyPort;
}

- (NSString *)filterProxyAuthAccount
{
    if (self.openProxy == NO || self.openProxyAuth == NO || _proxyAuthAccount.length == 0) {
        return @"";
    }
    return _proxyAuthAccount;
}

//- (NSString *)filterProxyAuthPsw
//{
//    if (self.openProxy == NO || self.openProxyAuth == NO || _proxyAuthPsw.length == 0) {
//        return @"";
//    }
//    return [ECSUtils plistDataDecrypt:_proxyAuthPsw];
//}
@end
