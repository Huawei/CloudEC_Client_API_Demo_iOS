/**
 * @file ECSAppConfig.h
 *
 * Copyright(C), 2012-2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED. \n
 *
 * @brief [en]Description:user device service operation class head file.
 * [cn]描述：用户设备业务操作类头文件。 \n
 **/

#import <Foundation/Foundation.h>
#import "ECSUserConfig.h"
//#import "ECSServerAbility.h"
//#import "ECSLogCofig.h"

ECS_EXTERN NSString* const ECSConfigsVersionKey;			// 键值类型：NSNumber of int，取值范围：NA，默认值：NA，描述：NA
ECS_EXTERN NSString* const ECSConfigsMaaIPAddressKey;		// 键值类型：NSString，取值范围：NA，默认值：NA，描述：NA
ECS_EXTERN NSString* const ECSConfigsMaaIPPortKey;			// 键值类型：NSString，取值范围：NA，默认值：NA，描述：NA
ECS_EXTERN NSString* const ECSConfigsCWIPAddressKey;		// 键值类型：NSString，取值范围：NA，默认值：NA，描述：NA
ECS_EXTERN NSString* const ECSConfigsLatestUsedAccountKey;	// 键值类型：NSString，取值范围：NA，默认值：NA，描述：NA
ECS_EXTERN NSString* const ECSConfigsUsedAccountskey;		// 键值类型：NSArray，取值范围：NA，默认值：NA，描述：NA
ECS_EXTERN NSString* const ECSConfigsIsFirstUsedKey;		// 键值类型：NSNumber of bool，取值范围：NA，默认值：NA，描述：NA

ECS_EXTERN NSString* const ECSConfigsIsSVNEnabledKey;		// 键值类型：NSNumber of bool，取值范围：NA，默认值：NA，描述：NA
ECS_EXTERN NSString* const ECSConfigsSVNIPAddressKey;		// 键值类型：NSString，取值范围：NA，默认值：NA，描述：NA
ECS_EXTERN NSString* const ECSConfigsSVNIPPortKey;			// 键值类型：NSString，取值范围：NA，默认值：NA，描述：NA
ECS_EXTERN NSString* const ECSConfigsSVNAccountKey;			// 键值类型：NSString，取值范围：NA，默认值：NA，描述：NA
ECS_EXTERN NSString* const ECSConfigsSVNPasswordKey;		// 键值类型：NSString，取值范围：NA，默认值：NA，描述：NA
ECS_EXTERN NSString* const ECSConfigsIsSVNSameAccountKey;   // 键值类型：NSString，取值范围：NA，默认值：NA，描述：NA
ECS_EXTERN NSString* const ECSConfigsIsLoggerEnabledKey;	// 键值类型：NSNumber of bool，取值范围：NA，默认值：NA，描述：NA
ECS_EXTERN NSString* const ECSConfigsTraceModeKey;          // 键值类型: NSNumber of int:取值返回HMETraceMode
ECS_EXTERN NSString* const ECSConfigsSVNPwdSaveTypeKey;     // 键值类型：NSNumber of PSW_PROTECT_TYPE，取值范围：NA，默认值：NA，描述：NA

ECS_EXTERN NSString* const ECSBackgroudOfflineTimeKey;      // 键值类型：NSNumber of BKGOFFLINE_TIME，取值范围：NA，默认值：NA，描述：NA

ECS_EXTERN NSString* const  ECSConfigPosterIDKey;           // 键值类型：NSString，取值范围：NA，默认值：NA，描述：NA
ECS_EXTERN NSString* const  ECSConfigPosterTimeStampKey;    // 键值类型：NSNumber of NSTimeInterval，取值范围：NA，默认值：NA，描述：NA
ECS_EXTERN NSString* const  ECSConfigPosterBeginTimeKey;    // 键值类型：NSNumber of NSTimeInterval，取值范围：NA，默认值：NA，描述：NA
ECS_EXTERN NSString* const  ECSConfigPosterEndTimeKey;      // 键值类型：NSNumber of NSTimeInterval，取值范围：NA，默认值：NA，描述：NA

ECS_EXTERN NSString* const ECSConfigsDeviceTokenKey;               // 键值类型：NSString，取值范围：{设备devicetoken}，默认值：@""，描述：设备devicetoken

ECS_EXTERN NSString* const ECSApnsTypeKey;

ECS_EXTERN NSString* const ECSDeviceTypeKey; // 键值类型：NSString，取值范围：{DEVICE_TYPE_IPAD, DEVICE_TYPE_IPHONE, DEVICE_TYPE_IPAD_MEETTING}，默认值：DEVICE_TYPE_IPAD，描述：移动客户端OS类型
ECS_EXTERN NSString* const ECSVoIPTokenKey;   //键值类型：NSString,取值范围：{设备voip push使用token}，默认值：@""，描述：设备voip push使用token

ECS_EXTERN NSString* const ECSUportalConfTypeKey;  //键值类型：NSNumber of Integer,取值范围：{ECSUPortalConfType}，默认值：ECSUPortalConfTypeUSMConf，描述：uPortal会议组网下的会议组网类型

#define APNS_PRODUCT    @"APNS_PRODUCT"
#define APNS_DEV        @"APNS_DEV"
#define APNS_ENTERPRISE @"APNS_ENTERPRISE"
@class ESpaceFunctionConfig;
@class ESpaceProxyServerInfo;
@interface ECSAppConfig : NSObject <NSCoding>

@property (nonatomic, copy) NSString* version;   //客户端版本号 Client Version, Default "V3.0.4.5"
@property (nonatomic, copy) NSString* maaAddress;//MAA地址
@property (nonatomic, assign) NSUInteger maaPort;//MAA端口
@property (nonatomic, copy) NSString* cwAddress;
@property (nonatomic, copy) NSString* deviceToken;//设备token
@property (nonatomic, copy) NSString* deviceUUID;//设备UUID
@property (nonatomic, copy) NSString* apnsType;//消息push类型
@property (nonatomic, assign, readonly) APNS_SERVER_TYPE apnSrvType;
@property (nonatomic, assign, readonly) APNS_CER_TYPE apnCertType;
@property (nonatomic, copy) NSString* latestAccount;    // 最近一次鉴权账号, 可能为uPortal鉴权账号或者MAA账号
@property (nonatomic, assign) BOOL isFirstUsed;//是否首次使用
@property (nonatomic, assign) BOOL isSVNEnabled;//是否支持svn
@property (nonatomic, assign) BOOL isAnyOfficeLogin;//是否是anyoffice登录
@property (nonatomic, assign) BOOL isCerChecked;//是否需要证书校验
@property (nonatomic, assign) BOOL isMDMSSO;//是否单点登录
@property (nonatomic, copy) NSString* svnAddress;//svn地址
@property (nonatomic, assign) NSUInteger svnPort;//svn端口
@property (nonatomic, copy) NSString* svnAccount;//svn账号
@property (nonatomic, copy) NSString* svnPassword;//svn密码
@property (nonatomic, assign) BOOL isSVNAccountSameWithUserAccount;
@property (nonatomic, assign) BOOL isLogEnabled;//是否打开日志开关
@property (nonatomic, assign) HMETraceMode trackMode;//hme录制模式
@property (nonatomic, assign) PSW_PROTECT_TYPE svnPwdSaveType;//svn密码保存方式
@property (nonatomic, assign) NSTimeInterval bkgOfflineTime;
@property (nonatomic, copy) NSString* posterId;//宣传图片的id
@property (nonatomic, assign) NSTimeInterval posterTimestamp;//宣传图片的时间戳
@property (nonatomic, assign) NSTimeInterval posterBeginTime;//宣传图片启用时间
@property (nonatomic, assign) NSTimeInterval posterEndTime;//宣传图片失效时间
@property (nonatomic, readonly, copy) NSString* posterPath;//宣传图片地址
@property (nonatomic, strong) NSMutableDictionary* userConfigs;//登录用户的配置文件
@property (nonatomic, assign) ECSLogLevel appLogLevel;//日志打印级别
//@property (nonatomic, strong) ECSServerAbility* serverAbility;//服务器能力信息
@property (nonatomic, strong) NSDictionary *dataConfImgRsr; //对应的数据会场图片资源，不需要序列化
@property (nonatomic, assign) float deviceDPI; //设备DPI，不需要序列化
@property (nonatomic, assign) BOOL needPhoneCallTip;
@property (nonatomic, assign) BOOL needCTDCallTip;
@property (nonatomic, assign) NSInteger certsCheckedRet;
@property (nonatomic, assign) BOOL isAcceptPrivacy;
@property (nonatomic, copy) NSString* clientLanguage;//客户端语言，ZH 中文；EN 英文（默认）；TR 中文繁体；FR 法语；SP 西班牙语；PT葡萄牙语；AR阿拉伯语；POL 波兰语；RU 俄语
@property (nonatomic, readonly, copy) NSString* dbSecurityRandomStr;//db存储时用到的key值
@property (nonatomic, readonly, copy) NSString* plistSecurityRandomStr;//plist存储时用到的key值
@property (nonatomic, copy) NSString *appID;// 第三方应用登录时的应用id
@property (nonatomic, copy) NSString *appName;//第三方应用登陆时记录应用的appName;
@property (nonatomic, copy) NSString *appUrl;//第三方应用登陆时的appurl
@property (nonatomic, assign) ECSServerEnvironment serverEnv;   // 当前组网探测环境类型
@property (nonatomic, assign, readonly)BOOL isHWUCVersion;
@property (nonatomic, strong, readonly) ESpaceFunctionConfig *functionConfig;//功能设置开关,仅在程序启动时设置有效
@property (nonatomic, copy) NSString *voipToken;
@property (nonatomic, assign) ECSUPortalConfType uPortalConfType;//6.0组网下的会议组网类型
@property (nonatomic, assign) BOOL isUpdatedAccountCaseSensitive;//是否升级过客户端账号大小写敏感,默认NO
@property (nonatomic, strong) NSMutableDictionary *userAccountMapDic;//用户登录账号与真实账号的映射,key:登录账号;value:真实账号
@property (nonatomic, assign) BOOL isLastSTGLogin; //用户上一次是否需要stg隧道登录
@property (nonatomic, assign) BOOL isChineseLaguage;//是否为英文环境
@property (nonatomic, strong) ESpaceProxyServerInfo *proxyServerInfo;// 6.0组网下代理服务器信息

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
+ (instancetype) sharedInstance;


/**
 * @brief [en] This method is used to check whether login on iphone.
 *        <br>[cn] 检查当前是否iPhone登录
 *
 * @retval BOOL *                   <b>:</b><br>[en] Return yes if true, or return no.
 *                                          <br>[cn] 是返回YES，否返回NO
 * @attention [en] NA.
 *            <br>[cn] NA
 * @see NA
 **/
+ (BOOL)isIphone;


/**
 * @brief [en] This method is used to check whether iPad login.
 *        <br>[cn] 检查当前是否iPad登录
 *
 * @retval BOOL *                   <b>:</b><br>[en] Return yes if true, or return no.
 *                                          <br>[cn] 是返回YES，否返回NO
 * @attention [en] NA.
 *            <br>[cn] NA
 * @see NA
 **/
+ (BOOL)isIpad;


/**
 * @brief [en] This method is used to get path for poster.
 *        <br>[cn] 获取宣传图路径
 *
 * @param [in] NSString* posterId   <b>:</b><br>[en] Indicates poster id.
 *                                          <br>[cn] 宣传图id
 * @retval NSString *               <b>:</b><br>[en] Return poster path if success, or return nil.
 *                                          <br>[cn] 成功返回宣传图路径，失败返回nil
 * @attention [en] NA
 *            <br>[cn] NA
 * @see NA
 **/
+ (NSString*) pathForPoster:(NSString*) posterId;


/**
 * @brief [en] This method is used to get appointed user config file.
 *        <br>[cn] 获取指定用户的配置文件
 *
 * @param [in] NSString* user       <b>:</b><br>[en] Indicates user account.
 *                                          <br>[cn] 用户账号
 * @retval ECSUserConfig *          <b>:</b><br>[en] Return config file if it already exist, or return after created.
 *                                          <br>[cn] 若已存在则返回已存在的配置文件，否则会创建后返回
 * @attention [en] If not exist  then created
 *            <br>[cn] 如果不存在会进行创建
 * @see NA
 **/
- (ECSUserConfig*) configForUser:(NSString*) user;


/**
 * @brief [en] This method is used to get current user config file.
 *        <br>[cn] 获取当前用户的配置文件
 *
 * @retval ECSUserConfig *          <b>:</b><br>[en] Return current login user config file, or return nil.
 *                                          <br>[cn] 成功返回当前登录用户的配置文件，未找到返回nil
 * @attention [en] If not exist  then created
 *            <br>[cn] 如果不存在会进行创建
 * @see NA
 **/
- (ECSUserConfig*) currentUser;


/**
 * @brief [en] This method is used to judge whether delete appointed user config file.
 *        <br>[cn] 判断是否删除指定用户的配置文件
 *
 * @param [in] NSString* user       <b>:</b><br>[en] Indicates user account.
 *                                          <br>[cn] 用户账号
 * @retval BOOL *                   <b>:</b><br>[en] Return yes if true, or return no.
 *                                          <br>[cn] 是返回YES，否返回NO
 * @attention [en] NA.
 *            <br>[cn] NA
 * @see NA
 **/
- (BOOL) removeUserConfig:(NSString*) user;


/**
 * @brief [en]This method is used to judge whether save config.
 *        <br>[cn] 判断是否保存配置文件
 *
 * @retval BOOL *                   <b>:</b><br>[en] Return yes if true, or return no.
 *                                          <br>[cn] 是返回YES，否返回NO
 * @attention [en] xxxx.
 *            <br>[cn] NA
 * @see NA
 **/
- (BOOL)save;


/**
 * @brief [en] This method is used to get all user config.
 *        <br>[cn] 获取所有的用户配置
 *
 * @retval NSArray *                <b>:</b><br>[en] Return user config set if success, or return nil.
 *                                          <br>[cn] 成功返回用户配置集合(NSString)，没有则返回nil
 * @attention [en] NA
 *            <br>[cn] NA
 * @see NA
 **/
- (NSArray *)allUserAccounts;


/**
 * @brief [en] This method is used to generate random security string key.
 *        <br>[cn] 生成随机安全字符key
 *
 * @attention [en] use to database encryption.
 *            <br>[cn] 用于数据库加密
 * @see NA
 **/
- (void)initializeSecurityRandomKey;


/**
 * @brief [en] This method is used to set user config.
 *        <br>[cn] 设置用户配置
 *
 * @param [in] ECSUserConfig* config         <b>:</b><br>[en] Indicates user config file.
 *                                                   <br>[cn] 用户配置文件
 * @param [in] NSString* key                 <b>:</b><br>[en] Indicates key.
 *                                                   <br>[cn] 键值
 * @attention [en] set user config file to app config.
 *            <br>[cn] 设置用户配置文件到app配置
 * @see NA
 **/
- (void)setUserConfig:(ECSUserConfig *)config forKey:(NSString *)key;


/**
 * @brief [en] This method is used to get appointed user config file.
 *        <br>[cn] 获取指定用户配置文件
 *
 * @param [in] NSString* key        <b>:</b><br>[en] Indicates key.
 *                                          <br>[cn] 键值
 * @retval ECSUserConfig *          <b>:</b><br>[en] Return config file if success, or return nil.
 *                                          <br>[cn] 成功返回配置文件，失败返回nil
 * @attention [en] Return nil if not exist
 *            <br>[cn] 不存在返回nil
 * @see NA
 **/
- (ECSUserConfig *)getUserConfigForKey:(NSString *)key;


/**
 * @brief [en] This method is used to set set login account map.
 *        <br>[cn] 设置登录账号的映射
 *
 * @param [in] NSString* loginAccount        <b>:</b><br>[en] Indicates user login account.
 *                                                   <br>[cn] 用户登录输入账号
 * @param [in] NSString* ackAccount          <b>:</b><br>[en] Indicates ack account.
 *                                                   <br>[cn] 登录返回账号
 * @attention [en] map relation between login account and ack account.
 *            <br>[cn] 登录账号与登录返回真实账号之间的映射
 * @see NA
 **/
- (void)mapLoginAccount:(NSString *)loginAccount toAckAccount:(NSString *)ackAccount;

#pragma mark - static configuration ----inner use
+ (NSDictionary*)configInfo;
+ (NSString*)defaultDomain;
+ (NSInteger)defaultPort;
+ (NSString*)w3URL;
+ (NSString*)directAccessList;
+ (NSString*)undirectAccessList;
+ (NSString*)w3HostAuth;
+ (NSString*)defaultMail;
+ (NSString*)aesSalt;
+ (BOOL)isShowServerSetting;
@end

/**
 * [en] This class is about appointed function switch.
 * [cn] UI指定功能开关
 **/
@interface ESpaceFunctionConfig : NSObject

@property (nonatomic, assign) BOOL supportPublicAccout; //default YES
@property (nonatomic, assign) BOOL supportCircle; //default YES
@property (nonatomic, assign) BOOL supportLocalContact; //default YES
@property (nonatomic, assign) BOOL supportSsoOperation; //default YES
@property (nonatomic, assign) BOOL supportGroupMemberChangeNotifyOnlyForOwner;//default NO
@property (nonatomic, assign) BOOL supportContactNickName;//default YES
@property (nonatomic, assign) BOOL supportContactRemarkName;//default NO
@property (nonatomic, assign) NSInteger roamingRecentSessionCount;//默认0，非0设置才可以生效
@property (nonatomic, assign) BOOL supportGroupAnnounceChangedNotify;//default NO


@end

@interface ESpaceProxyServerInfo : NSObject <NSCoding>

@property (nonatomic, copy)     NSString *proxyAddress;
@property (nonatomic, assign)   NSUInteger proxyPort;
@property (nonatomic, copy)     NSString *proxyAuthAccount;
@property (nonatomic, copy)     NSString *proxyAuthPsw;
@property (nonatomic, assign)   BOOL openProxy;
@property (nonatomic, assign)   BOOL openProxyAuth;

- (NSString *)filterProxyAddress;
- (NSUInteger)filterProxyPort;
- (NSString *)filterProxyAuthAccount;
- (NSString *)filterProxyAuthPsw;
@end

