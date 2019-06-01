//
//  ECSUserConfig.m
//  eSpaceIOSSDK
//
//  Created by yemingxing on 2/23/15.
//  Copyright (c) 2015 huawei. All rights reserved.
//

#import "ECSUserConfig.h"
#import "ECSUtils.h"
//#import "ECSMAAUtils.h"
#import "ECSAppConfig.h"
//#import "ECSLogCofig.h"
//#import "ECSUserMAAInfo.h"
//#import <ctk.h>

/********************* account relative configs **********************/
NSString* const ECSConfigsDBVersionKey			= @"ECSConfigsDBVersionKey";
NSString* const ECSConfigsTimestampKey			= @"ECSConfigsTimestampKey";
NSString* const ECSConfigsRememberPasswordKey	= @"ECSConfigsRememberPasswordKey";
NSString* const ECSConfigsAutoLoginKey			= @"ECSConfigsAutoLoginKey";
NSString* const ECSConfigsPasswordKey			= @"ECSConfigsPasswordKey";
NSString* const ECSConfigsPasswordSaveTypeKey   = @"ECSConfigsPasswordSaveTypeKey";

NSString* const ECSConfigsContactModeKey		= @"ECSConfigsContactModeKey";
NSString* const ECSConfigsDefaultModeKey		= @"ECSConfigsDefaultModeKey";
NSString* const ECSConfigsPhotoOrientationKey	= @"ECSConfigsPhotoOrientationKey";
NSString* const ECSConfigsQuickRevertContentsKey = @"ECSConfigsQuickRevertContentsKey";
NSString* const ECSConfigsVoiceMailNumberKey	= @"ECSConfigsVoiceMailNumberKey";

NSString* const ECSConfigsDBFileNameKey			= @"ECSConfigsDBFileNameKey";
NSString* const ECSConfigsGuideViewVersionKey   = @"ECSConfigsGuideViewVersionKey";
NSString* const ECSConfigsHistoryGuideViewVersionKey   = @"ECSConfigsHistoryGuideViewVersionKey";
NSString* const ECSConfigsContactGuideViewVersionKey   = @"ECSConfigsContactGuideViewVersionKey";
NSString* const ECSConfigsImGuideViewVersionKey   = @"ECSConfigsImGuideViewVersionKey";
NSString* const ECSConfigsWelcomeHintVersionKey   = @"ECSConfigsWelcomeHintVersionKey";

NSString* const ECSConfigsSettingCountryCodeKey  = @"ECSConfigsSettingCountryCodeKey";


NSString* const ECSIsHttpsRequestKey            = @"ECSIsHttpsRequest";
NSString* const ECSNewCircleTopicValueKey       = @"ECSNewCircleTopicValueKey";

NSString* const ECSPublicAccountTimestampKey    = @"ECSPublicAccountTimestampKey";

NSString* const kECSKeyCircleHasNewInvite       = @"kECSKeyCircleHasNewInvite";
NSString* const kECSKeyCircleStateSyncTimestamp = @"kECSKeyCircleStateSyncTimestamp";

NSString* const ECSConfigIsFirstBfcpSildRemindKey		= @"ECSConfigIsFirstBfcpSildRemindKey";



@implementation ECSUserConfig
@synthesize password;
@synthesize token;
@synthesize mainCall;
@synthesize customNumbers;

#define RETURN_VAILIDNUM(num) if([num length]>0) return num;
- (NSString*)mainCall {
//    RETURN_VAILIDNUM([ECSUtils plistDataDecrypt:mainCall]);
//    RETURN_VAILIDNUM(self.maaInfo.mobile)
//    if (self.maaInfo.bindnoHideFlag == 0) {
//        RETURN_VAILIDNUM(self.maaInfo.bindNo);
//    }
//
//    //3、顺序排列
//    RETURN_VAILIDNUM(self.maaInfo.m2)
//    RETURN_VAILIDNUM(self.maaInfo.shortPhone)
//    RETURN_VAILIDNUM(self.maaInfo.sp2)
//    RETURN_VAILIDNUM(self.maaInfo.sp3)
//    RETURN_VAILIDNUM(self.maaInfo.sp4)
//    RETURN_VAILIDNUM(self.maaInfo.sp5)
//    RETURN_VAILIDNUM(self.maaInfo.sp6)
//    RETURN_VAILIDNUM(self.maaInfo.voip)
//    RETURN_VAILIDNUM(self.maaInfo.voip2)
//    RETURN_VAILIDNUM(self.maaInfo.voip3)
//    RETURN_VAILIDNUM(self.maaInfo.voip4)
//    RETURN_VAILIDNUM(self.maaInfo.voip5)
//    RETURN_VAILIDNUM(self.maaInfo.voip6)
//    RETURN_VAILIDNUM(self.maaInfo.officePhone)
//    RETURN_VAILIDNUM(self.maaInfo.phone)

    return mainCall;
}

- (void)setMainCall:(NSString *)callNum{
    mainCall = [ECSUtils plistDataEncrypt:callNum];
}

- (void)setCustomNumbers:(NSString *)Numbers{
    customNumbers = [ECSUtils plistDataEncrypt:Numbers];
}

- (NSString*)customNumbers {
    return [ECSUtils plistDataDecrypt:customNumbers];
}


- (NSInteger)imDisplayFont {
    if (0 == _imDisplayFont) {
        _imDisplayFont = 15.5f;
    }
    return _imDisplayFont;
}

- (NSInteger)autoAcceptTime {
    if (_autoAcceptTime == 0) {
        _autoAcceptTime = 1;
    }

    return _autoAcceptTime;
}

- (NSString*)password{
    if (0 == [password length]) {
        return password;
    }
    NSString* dePw = [ECSUtils plistDataDecrypt:password];
    NSString* pwWithoutSalt = [ECSUtils psw:dePw withoutSalt:_account];
    return pwWithoutSalt;
}

- (NSString *)token
{
    if (0 == [token length]) {
        return nil;
    }

    NSString *deToken = [ECSUtils plistDataDecrypt:token];
    NSString *tokenWithoutSalt = [ECSUtils psw:deToken withoutSalt:_account];

    return tokenWithoutSalt;
}

- (NSDictionary *)bulletinInfos{
    if (nil == _bulletinInfos) {
        _bulletinInfos =  [NSMutableDictionary dictionary];
    }
    return _bulletinInfos;
}

- (NSMutableArray *)lbsIdInfoArray{
    if (nil == _lbsIdInfoArray) {
        _lbsIdInfoArray = [NSMutableArray array];
    }
    return _lbsIdInfoArray;
}

- (NSMutableArray *)lbsNameInfoArray{
    if (nil == _lbsNameInfoArray) {
        _lbsNameInfoArray = [NSMutableArray array];
    }
    return _lbsNameInfoArray;
}

- (NSInteger)lastSavedbatterySavingMode {
    if (-1 == _lastSavedbatterySavingMode) {
        return self.batterySavingMode;
    }
    return _lastSavedbatterySavingMode;
}

- (NSInteger)batterySavingMode {
    if (NO == [self isSupportFunction:EN_FUNC_BATTERYSAVING_MODE]) {
        return BATTERY_MODE_STANDARD;
    }
    NSInteger batteryModeValue = _batterySavingMode;
    if (-1 == batteryModeValue) {
        if ([self isSupportFunction:EN_FUNC_BATTERYSAVING_MODE]
            && ![self isUCV2Solution]) {  //uc2.0解决方案默认为标准模式，不做省电开启
            batteryModeValue = BATTERY_MODE_NORMAL;
        }
        else{
            batteryModeValue = BATTERY_MODE_STANDARD;
        }
    }


    return batteryModeValue;
}

- (void)setPassword:(NSString *)pw{
    if ([pw length]) {
        NSString* pwWithSalt = [ECSUtils psw:pw withSalt:_account];
        password = [ECSUtils plistDataEncrypt:pwWithSalt];
    }
    else{
        password = @"";
    }
}

- (void)setToken:(NSString *)tk
{
    if ([tk length]) {
        NSString *tokenAddedSalt = [ECSUtils psw:tk withSalt:_account];
        token = [ECSUtils plistDataEncrypt:tokenAddedSalt];
    } else {
        token = @"";
    }
}

- (NSNumber*)increasedDbId {
    if (nil == _increasedDbId) {
        _increasedDbId = [NSNumber numberWithUnsignedInteger:0];
    }

    return _increasedDbId;
}

- (id) initWithAccount:(NSString*) account {
    if (self = [self init]) {
        _account = account;
        [self setDefaultValueForConfig];
    }
    return self;
}

- (void)setDefaultValueForConfig
{
    self.lastPaSyncTimestamp    = @"0";
    self.showWelcomeMessage     = YES;
    self.bFirstUse = YES;
    self.callModeType           = ECSCallModeCTDType;
    self.incomingCallRing       = 1;
    self.voiceMailRing          = 1;
    self.instantMessageRing     = 1;
    self.notifyAndBulletinRing  = 1;
    self.imDisplayFont          = 15.5f;
    self.isDisplayLBSInfo       = [NSNumber numberWithInteger:1];
    self.batterySavingMode      = -1;
    self.lastSavedbatterySavingMode = -1;
    self.aesMode                = AESKEY_MODE_DYNAMIC;
    self.circleStateSyncTimestamp  = @"0";
    self.unusedLightAppPaNums = [NSNumber numberWithInteger:0];
    self.unusedLocalAppPaNums = [NSNumber numberWithInteger:0];
    self.isLocalCallPrompt      = YES;
    self.isUmDownLoadPrompt     = YES;
    self.isHaveNewCircleInvite  = [NSNumber numberWithBool:NO];
    self.isMaaConfEnable = YES;
    self.increasedDbId = [NSNumber numberWithUnsignedInteger:0];
    self.isShutCTDTip = NO;
    self.isMute = NO;//0:静音 1:非静音
    self.VoipPushSwitch = NO;           //默认未进行登记,需要触发登记业务
    self.userTempVoipPushSwitch = YES; //默认进行voip后台push登记
    self.mutilTerminalRemindStatus = -1;
    self.isFirstBfcpSildRemind = YES;
}

//注意：请不要在initWithCoder方法中添加数据加解密的方法，否则容易造成循环调用
- (id) initWithCoder:(NSCoder *)aDecoder {
    if (self = [self init]) {
        _account = [aDecoder decodeObjectForKey:@"account"];
        password = [aDecoder decodeObjectForKey:@"password"];
        token = [aDecoder decodeObjectForKey:@"token"];
        _bFirstUse = [aDecoder decodeBoolForKey:@"bFirstUse"];
        _bRememberPassword = [aDecoder decodeBoolForKey:@"rememberPassword"];
        _dbVersion = [NSNumber numberWithInteger:[aDecoder decodeIntegerForKey:@"dbVersion"]];
        _configVersion = [NSNumber numberWithInteger:[aDecoder decodeIntegerForKey:@"configVersion"]];
        _lastSyncTimestamp = [NSDate dateWithTimeIntervalSince1970:[aDecoder decodeDoubleForKey:@"lastSyncTimestamp"]];
        _lastConfigSyncTimestamp = [NSDate dateWithTimeIntervalSince1970:[aDecoder decodeDoubleForKey:@"lastConfigSyncTimestamp"]];
//        _maaInfo = [aDecoder decodeObjectOfClass:[ECSUserMAAInfo class] forKey:@"maaInfo"];
//        _latestServerAddress = [aDecoder decodeObjectForKey:@"latestServerAddress"];
        _peopleNumber = [aDecoder decodeObjectForKey:@"peopleNumber"];
        _peopleRanking = [aDecoder decodeObjectForKey:@"peopleRanking"];
        _peopleSurpass = [aDecoder decodeObjectForKey:@"peopleSurpass"];
        _circleStateSyncTimestamp = [aDecoder decodeObjectForKey:@"circleStateSyncTimestamp"];
        _isHaveNewCircleTopic = [aDecoder decodeObjectForKey:@"isHaveNewCircleTopic"];
        _isHaveNewCircleInvite = [aDecoder decodeObjectForKey:@"isHaveNewCircleInvite"];
        _recentSessionsSyncTimestamp = [aDecoder decodeObjectForKey:@"recentSessionsSyncTimestamp"];
        _serverSyncContactTimestamp = [aDecoder decodeObjectForKey:@"serverSyncContactTimestamp"];
        _isAutoLogin = [aDecoder decodeBoolForKey:@"autologin"];
        _lastPaSyncTimestamp = [aDecoder decodeObjectForKey:@"lastPaSyncTimestamp"];
        _showWelcomeMessage = [aDecoder decodeBoolForKey:@"showWelcomeMessage"];
        _callModeType = (ECSCallModeType)[aDecoder decodeIntegerForKey:@"CallModeType"];
        _countryCode = [aDecoder decodeObjectForKey:@"countryCode"];
        _batterySavingMode = [aDecoder decodeIntegerForKey:@"batterySavingMode"];
        //版本升级场景:保持用户之前的设置
        if ([aDecoder containsValueForKey:@"lastSavedbatterySavingMode"]) {
            _lastSavedbatterySavingMode = [aDecoder decodeIntegerForKey:@"lastSavedbatterySavingMode"];
        }
        else{
            _lastSavedbatterySavingMode = _batterySavingMode;
        }
        //使用用户上次保存的省电模式
        if (-1 != _lastSavedbatterySavingMode) {
            _batterySavingMode = _lastSavedbatterySavingMode;
        }

        _imDisplayFont = [aDecoder decodeIntegerForKey:@"imDisplayFont"];

        mainCall = [aDecoder decodeObjectForKey:@"mainCall"];
        _vibrateValue = [aDecoder decodeBoolForKey:@"vibrateValue"];

        _isDisplayLBSInfo = [aDecoder decodeObjectForKey:@"isDisplayLBSInfo"];  //su
        _locationInfo = [aDecoder decodeObjectForKey:@"locationInfo"];        //su

        _onlyShowOnline = [aDecoder decodeBoolForKey:@"onlyShowOnline"];
        _matchMobileState = (MatchMobileState)[aDecoder decodeIntegerForKey:@"matchMobileState"];
        _bAutoAccept = [aDecoder decodeBoolForKey:@"bAutoAccept"];
        _autoAcceptTime = [aDecoder decodeIntegerForKey:@"autoAcceptTime"];
        customNumbers = [aDecoder decodeObjectForKey:@"customNumbers"];

        _incomingCallRing      = [aDecoder decodeIntegerForKey:@"incomingCallRing"];
        _instantMessageRing    = [aDecoder decodeIntegerForKey:@"instantMessageRing"];
        _voiceMailRing         = [aDecoder decodeIntegerForKey:@"voiceMailRing"];;
        _notifyAndBulletinRing = [aDecoder decodeIntegerForKey:@"notifyAndBulletinRing"];
        _bulletinInfos     = [aDecoder decodeObjectForKey:@"bulletinInfos"];
        if (nil == _bulletinInfos) {
            _bulletinInfos = [NSMutableDictionary dictionary];
        }
        _aesMode = (AESKEY_MODE)[aDecoder decodeIntegerForKey:@"aesMode"];

        _isLocalCallPrompt = [aDecoder decodeBoolForKey:@"isLocalCallPrompt"];
        _isUmDownLoadPrompt = [aDecoder decodeBoolForKey:@"isUmDownLoadPrompt"];
        _lbsIdInfoArray = [aDecoder decodeObjectForKey:@"lbsIdInfoArray"];
        if (nil == _lbsIdInfoArray) {
            _lbsIdInfoArray = [NSMutableArray array];
        }
        _lbsNameInfoArray = [aDecoder decodeObjectForKey:@"lbsNameInfoArray"];
        if (nil == _lbsNameInfoArray) {
            _lbsNameInfoArray = [NSMutableArray array];
        }
        _AlertedPwUpdateTipFlag = [aDecoder decodeBoolForKey:@"AlertedPwUpdateTipFlag"];
        _isMaaConfEnable = [aDecoder decodeBoolForKey:@"isMaaConfEnable"];
        _increasedDbId = [aDecoder decodeObjectForKey:@"increasedDbId"];
        _appID = [aDecoder decodeObjectForKey:@"appID"];
        _appName = [aDecoder decodeObjectForKey:@"appName"];
        _isShutCTDTip = [aDecoder decodeBoolForKey:@"isShutCTDTip"];

        _isFirstBfcpSildRemind = [aDecoder decodeBoolForKey:@"isFirstBfcpSildRemind"];

        _isMute = [aDecoder decodeBoolForKey:@"isMute"];
        if ([aDecoder containsValueForKey:@"VoipPushSwith"]) {
            _VoipPushSwitch = [aDecoder decodeBoolForKey:@"VoipPushSwith"];
        }else{
            _VoipPushSwitch = NO;
        }

        if ([aDecoder containsValueForKey:@"userTempVoipPushSwitch"]){
            _userTempVoipPushSwitch = [aDecoder decodeBoolForKey:@"userTempVoipPushSwitch"];
        }else{
            _userTempVoipPushSwitch = YES;
        }
        if ([aDecoder containsValueForKey:@"mutilTerminalRemindStatus"]) {
            _mutilTerminalRemindStatus = [aDecoder decodeIntegerForKey:@"mutilTerminalRemindStatus"];
        }
        else{
            _mutilTerminalRemindStatus = -1;
        }

        if ([aDecoder containsValueForKey:@"userGuiRemindInfo"]) {
            _userGuiRemindInfo = [aDecoder decodeObjectForKey:@"userGuiRemindInfo"];
        }
        else{
            _userGuiRemindInfo = [[NSMutableDictionary alloc] init];
        }

    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_account forKey:@"account"];
    [aCoder encodeObject:password forKey:@"password"];
    [aCoder encodeObject:token forKey:@"token"];

    [aCoder encodeBool:_bFirstUse forKey:@"bFirstUse"];
    [aCoder encodeBool:_bRememberPassword forKey:@"rememberPassword"];
    [aCoder encodeInteger:_dbVersion.integerValue forKey:@"dbVersion"];
    [aCoder encodeInteger:_configVersion.integerValue forKey:@"configVersion"];
    [aCoder encodeDouble:[_lastConfigSyncTimestamp timeIntervalSince1970] forKey:@"lastConfigSyncTimestamp"];
    [aCoder encodeDouble:[_lastSyncTimestamp timeIntervalSince1970] forKey:@"lastSyncTimestamp"];
    [aCoder encodeInteger:_batterySavingMode forKey:@"batterySavingMode"];
    [aCoder encodeInteger:_lastSavedbatterySavingMode forKey:@"lastSavedbatterySavingMode"];

//    [aCoder encodeObject:_maaInfo forKey:@"maaInfo"];
//    [aCoder encodeObject:_latestServerAddress forKey:@"latestServerAddress"];
    [aCoder encodeObject:_peopleNumber forKey:@"peopleNumber"];
    [aCoder encodeObject:_peopleRanking forKey:@"peopleRanking"];
    [aCoder encodeObject:_peopleSurpass forKey:@"peopleSurpass"];
    [aCoder encodeObject:_circleStateSyncTimestamp forKey:@"circleStateSyncTimestamp"];
    [aCoder encodeObject:_isHaveNewCircleTopic forKey:@"isHaveNewCircleTopic"];
    [aCoder encodeObject:_isHaveNewCircleInvite forKey:@"isHaveNewCircleInvite"];
    [aCoder encodeObject:_recentSessionsSyncTimestamp forKey:@"recentSessionsSyncTimestamp"];
    [aCoder encodeObject:_serverSyncContactTimestamp forKey:@"serverSyncContactTimestamp"];
    [aCoder encodeBool:_isAutoLogin forKey:@"autologin"];
    [aCoder encodeObject:_lastPaSyncTimestamp forKey:@"lastPaSyncTimestamp"];
    [aCoder encodeBool:_showWelcomeMessage forKey:@"showWelcomeMessage"];
    [aCoder encodeInteger:_callModeType forKey:@"CallModeType"];
    [aCoder encodeObject:_countryCode forKey:@"countryCode"];
    [aCoder encodeInteger:_imDisplayFont forKey:@"imDisplayFont"];
    [aCoder encodeObject:mainCall forKey:@"mainCall"];
    [aCoder encodeBool:_vibrateValue forKey:@"vibrateValue"];
    [aCoder encodeBool:_onlyShowOnline forKey:@"onlyShowOnline"];
    [aCoder encodeInteger:_matchMobileState forKey:@"matchMobileState"];
    [aCoder encodeBool:_bAutoAccept forKey:@"bAutoAccept"];
    [aCoder encodeInteger:_autoAcceptTime forKey:@"autoAcceptTime"];
    [aCoder encodeObject:customNumbers forKey:@"customNumbers"];
    [aCoder encodeInteger:_incomingCallRing forKey:@"incomingCallRing"];
    [aCoder encodeInteger:_instantMessageRing forKey:@"instantMessageRing"];
    [aCoder encodeInteger:_voiceMailRing forKey:@"voiceMailRing"];
    [aCoder encodeInteger:_notifyAndBulletinRing forKey:@"notifyAndBulletinRing"];
    [aCoder encodeObject:_bulletinInfos forKey:@"bulletinInfos"];

    [aCoder encodeObject:_locationInfo forKey:@"locationInfo"];                 //su
    [aCoder encodeObject:_isDisplayLBSInfo forKey:@"isDisplayLBSInfo"];           //su
    [aCoder encodeInteger:_aesMode forKey:@"aesMode"];
    [aCoder encodeBool:_isLocalCallPrompt forKey:@"isLocalCallPrompt"];
    [aCoder encodeBool:_isUmDownLoadPrompt forKey:@"isUmDownLoadPrompt"];

    [aCoder encodeObject:_lbsIdInfoArray forKey:@"lbsIdInfoArray"];
    [aCoder encodeObject:_lbsNameInfoArray forKey:@"lbsNameInfoArray"];
    [aCoder encodeBool:_AlertedPwUpdateTipFlag forKey:@"AlertedPwUpdateTipFlag"];
    [aCoder encodeBool:_isMaaConfEnable forKey:@"isMaaConfEnable"];
    [aCoder encodeObject:_increasedDbId forKey:@"increasedDbId"];
    [aCoder encodeObject:_appID forKey:@"appID"];
    [aCoder encodeObject:_appName forKey:@"appName"];
    [aCoder encodeBool:_isShutCTDTip forKey:@"isShutCTDTip"];
    [aCoder encodeBool:_isMute forKey:@"isMute"];
    [aCoder encodeBool:_VoipPushSwitch forKey:@"VoipPushSwith"];
    [aCoder encodeBool:_userTempVoipPushSwitch forKey:@"userTempVoipPushSwitch"];
    [aCoder encodeInteger:_mutilTerminalRemindStatus forKey:@"mutilTerminalRemindStatus"];
    [aCoder encodeBool:_isFirstBfcpSildRemind forKey:@"isFirstBfcpSildRemind"];
    [aCoder encodeObject:_userGuiRemindInfo forKey:@"userGuiRemindInfo"];

}
//
//- (void)setCallModeType:(ECSCallModeType)callModeType
//{
//    [self willChangeValueForKey:@"callModeType"];
//    _callModeType = callModeType;
//    [self didChangeValueForKey:@"callModeType"];
//}
//
- (BOOL)isSupportFunction:(SUPPORT_FUNC_TYPE)funcType {
//    return [self.maaInfo isSupportFunction:funcType];
    return YES;
}

- (BOOL)isHWUC{ //是否华为uc解决方案

    return NO;
}
//
//- (BOOL)isIPTSolution{//是否是IPT解决方案
//    return [ECSAppConfig sharedInstance].serverAbility.serverType == SERVERTYPE_UC_IPT;
//}
//
//-(BOOL)isUCV2Solution{
//    return [ECSAppConfig sharedInstance].serverAbility.serverType == SERVERTYPE_UC_V2;
//}
//
//- (BOOL)isSupportDisplayPhoneCall {
//    return !self.maaInfo.disablePhoneCall;
//}
//
//- (BOOL)hideMobileNum
//{
//    return self.maaInfo.hideMobileNum;
//}
//
//-(BOOL)isSupportConfMuteAll{
//    return self.maaInfo.confMute;
//}


@end
