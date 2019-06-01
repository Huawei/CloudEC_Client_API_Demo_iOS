//
//  ECSUtils.h
//  eSpaceIOSSDK
//
//  Created on 12-5-3.
//  Copyright 2012 Huawei Technologies Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ECSDefines.h"

#define dispatch_async_main_safe(block) \
if ([NSThread isMainThread]) {\
block();\
} else {\
dispatch_async(dispatch_get_main_queue(), block);\
}

#define dispatch_sync_main_safe(block) \
if ([NSThread isMainThread]) {\
block();\
} else {\
dispatch_sync(dispatch_get_main_queue(), block);\
}

#define HEAD_IMG_WIDTH 40.0
#define HEAD_IMG_HEIGHT HEAD_IMG_WIDTH

#define NTF_ENTER_INTO_VIDEOVIEW    @"enterintovideoview"
#define ESPACE_CURRENT_USER_CFG ([[ECSAppConfig sharedInstance] currentUser])
#define CALLFILTER_RULER @"0123456789*#+"



#ifndef ECSEntryptCoreDataStringProp
#define ECSEntryptCoreDataStringProp(PROP, SETPROP)\
- (NSString *) PROP {\
[self willAccessValueForKey:@#PROP];\
NSString* propValue = [self primitiveValueForKey:@#PROP];\
[self didAccessValueForKey:@#PROP];\
return propValue;\
}\
- (void)set##SETPROP:(NSString *)PROP {\
[self willChangeValueForKey:@#PROP];\
NSString* propValue = PROP;\
[self setPrimitiveValue:propValue forKey:@#PROP];\
[self didChangeValueForKey:@#PROP];\
}
#endif

#define RETURN_IF_PARAM_NULL(param) do { if (NULL == param) { //SDK_WRN_LOG("Invalid param : " << ctk::String(#param) << " is null."); return; } } while(0)
#define RETURN_FALSE_IF_PARAM_NULL(param) do { if (NULL == param) { //SDK_WRN_LOG("Invalid param : " << ctk::String(#param) << " is null."); return false; } } while(0)
#define RETURN_NO_IF_PARAM_NULL(param) do { if (NULL == param) { //SDK_WRN_LOG("Invalid param : " << ctk::String(#param) << " is null."); return NO; } } while(0)

#define RETURN_NO_IF_PARAM_NIL(param) do { if (nil == param) { //SDK_WRN_LOG("Invalid param : " << ctk::String(#param) << " is nil."); return NO; } } while(0)
#define RETURN_IF_PARAM_NIL(param) do { if (nil == param) { //SDK_WRN_LOG("Invalid param : " << ctk::String(#param) << " is nil."); return; } } while(0)
#define RETURN_NIL_IF_PARAM_NIL(param) do { if (nil == param) { //SDK_WRN_LOG("Invalid param : " << ctk::String(#param) << " is nil."); return nil; } } while(0)


#define RETURN_NO_IF_PARAM_TEXT_EMPTY(param) do { if (nil == param || ![param isKindOfClass:[NSString class]] || [param length] == 0) { //SDK_WRN_LOG("Invalid string : " << ctk::String(#param) << " is empty."); return NO; } } while(0)
#define RETURN_IF_PARAM_TEXT_EMPTY(param) do { if (nil == param || ![param isKindOfClass:[NSString class]] || [param length] == 0) { //SDK_WRN_LOG("Invalid string : " << ctk::String(#param) << " is empty."); return; } } while(0)
#define RETURN_NIL_IF_PARAM_TEXT_EMPTY(param) do { if (nil == param || ![param isKindOfClass:[NSString class]] || [param length] == 0) { //SDK_WRN_LOG("Invalid string : " << ctk::String(#param) << " is empty."); return nil; } } while(0)

#define RETURN_NO_IF_ARRAY_IS_EMPTY(param) do { if (nil == param || ![param isKindOfClass:[NSArray class]] || [param count] == 0) { //SDK_WRN_LOG("Invalid array : " << ctk::String(#param) << " is empty."); return NO; } } while(0)
#define RETURN_IF_ARRAY_IS_EMPTY(param) do { if (nil == param || ![param isKindOfClass:[NSArray class]] || [param count] == 0) { //SDK_WRN_LOG("Invalid array : " << ctk::String(#param) << " is empty."); return; } } while(0)
#define RETURN_NIL_IF_ARRAY_IS_EMPTY(param) do { if (nil == param || ![param isKindOfClass:[NSArray class]] || [param count] == 0) { //SDK_WRN_LOG("Invalid array : " << ctk::String(#param) << " is empty."); return nil; } } while(0)

@interface ECSUtils : NSObject 
{

}

/**
 *  替换呼叫号码首字符'+'为'00'
 */
+ (NSString *)replacePlusWithOOFromCallingNumber:(NSString *)callNumbber;
/**
 * 检查替换呼叫号码字符串为合法字符: [^0-9*#+]
 */
+ (NSString *)standardizedCallNumber:(NSString *)callNumber;

+ (void)deviceProximityMonitoringAndIdleTimer:(BOOL)enable;
/**
 *  过滤Text字符串中不属于strRuler字符串中的字符
 *
 *  @param Text     待过滤的字符串
 *  @param strRuler 符合过滤规则的字符串
 *
 *  @return 过滤后的字符串
 */
+ (NSString *)maskText:(NSString*)Text Ruler:(NSString*)strRuler;

/**
 *  判断用户是否开启摄像头隐私权限
 *
 *  mediaType :AVMediaTypeVideo(视频)
 *
 *  @return 是否开启
 */
+ (BOOL)isHaveAuthorityForMediaType:(NSString *)mediaType;

/**
 *  号码隐藏显示
 *
 *  @param number 待隐藏的号码
 *
 *  @return 隐藏后的号码
 */
+ (NSString *)hideMobileNumber:(NSString *)number;






+ (NSString*) clientBundleVersion;

+ (NSString*) clientLanguage;
/*  add domain : 6000 -> 6000@domain 
    remove domain : 6000@domain -> 6000 */
+ (NSString*)addDomainField:(NSString*)inString domain:(NSString*)domain;
+ (NSString*)removeDomainField:(NSString*)inString;

+(NSString*)domainFromNumber:(NSString*)number;

+ (NSString*)addPrefix:(NSString*)inString prefix:(NSString*)prefix;
+ (NSString*)removePrefix:(NSString*)inString prefix:(NSString*)prefix;

+ (NSString*)addSuffix:(NSString*)inString suffix:(NSString*)suffix;
+ (NSString*)removeSuffix:(NSString*)inString suffix:(NSString*)suffix;

/*************************************************
 函数名称：AESEncrypt:key:initVector
 函数描述：aes加密
 输入参数：inData			--- 待加密数据
		  key			--- 密钥
		  initVector	--- 初始向量
 输出参数：无
 返回值：  加密后的数据
 其他：	  输入数据/密钥/初始向量自动补齐16字节对齐
 *************************************************/
+(NSData*)AESEncrypt:(NSData*)inData key:(NSData*)key initVector:(NSData*)initVector;

/*************************************************
 函数名称：AESdecrypt:key:initVector:isRemovePadding
 函数描述：aes解密
 输入参数：inData				--- 待加密数据
		  key				--- 密钥
		  initVector		--- 初始向量
		  isRemovePadding	--- 返回的数据是否需要去掉补齐的0
 输出参数：无
 返回值：  解密失败返回nil，成功返回解密数据
 其他：	  输入数据必须是16字节对齐，密钥/初始向量自动补齐16字节对齐
 *************************************************/
+(NSData*)AESdecrypt:(NSData*)inData key:(NSData*)key initVector:(NSData*)initVector isRemovePadding:(BOOL)isRemovePadding;

+(NSString*)base64:(NSData*)inData;
+(NSData*)unbase64:(NSData*)inData;

/*获取str的md5字符串*/
+(NSString *)MD5StringFromStr:(NSString*)str;

/*获取sha1*/
+(NSString*)sha1:(NSData*)data;

+ (NSString *)sha256:(NSString *)inStr;

/*生成数据库校验值，账号+本地mac地址*/
//+(NSString*)dbEncryptGuarder;

+(NSString*)plistDataEncrypt:(NSString*)data;
+(NSString*)plistDataDecrypt:(NSString*)data;

+(NSString*)databaseDataEncrypt:(NSString*)data;
+(NSString*)databaseDataDecrypt:(NSString*)data;

+(void)databaseDataEncryptAndDecryptTest:(NSString *)testString
								forTimes:(NSInteger)times;

/* 30102 -> 3.1.2 */
+(NSString*)convertVersionIntToString:(NSInteger)version;
/* 3.1.2 -> 30102 */
+(NSInteger)convertVersionStringToInt:(NSString*)strVersion;

/* 获取设备名称，"ipad1,1",ipad2,1", 逗号后数字表示1－wifi版，2－3G版 */
+ (NSString*)getDeviceVersion;

/*判断当前设备是否越狱*/
+ (BOOL)isJailbroken;

/**
 *  获取IOS系统版本
 *
 *  @return IOS系统版本
 */
+ (NSString *)getUA;

/*获取设备型号*/
+ (UIDeviceMode) platformString;

/*获取设备型号(string类型)*/
+ (NSString *)deviceTypeString;

/*获取设备屏幕尺寸*/
+(SCREEN_SIZE)deviceScreenSize;

// 获取名字拼音
//+(NSArray*)getEnglishStr:(NSString *)str;

+(BOOL)containDisCountinuousString:(NSString *)srcString searchStr:(NSString *)searchString;

//根据分隔符处理字符串
+(NSMutableArray*)subStringsInStr:(NSString*)aStr withSeperators:(NSArray*)seperatorAry;

//+ (NSString *)chineseStringWithString:(NSString *)astr;

/*!
    @method     
    @abstract   判断字符串中是否有中文字符
    @discussion 
*/
+ (BOOL)IsContainChinese:(NSString*)strName;

/*!
 @method
 @abstract   判断首字为中文字符
 @discussion
 */
+ (BOOL)IsInitialChinese:(NSString *)strName;

+ (NSString *)notNilString:(NSString *)inString;

//+ (NSInteger)getRandomNumber;

+ (BOOL)isOSMajorVersionHigherThanVersion:(IOS_MAINVERSION)version;//运行操作系统是否为version及以上

+ (NSString *)deviceUUID;//

/**
 *  根据日期获取精确到毫秒的UTC时间
 *
 *  @param paraDate 时间
 *
 *  @return 精确到毫秒的UTC时间
 */
+ (long long)millisecondUTCFromDate:(NSDate*)paraDate;

/**
 *  将精确到毫秒的UTC时间转换为NSDate
 *
 *  @param millisecondUTCValue 精确到毫秒的UTC时间
 *
 *  @return NSDate
 */
+ (NSDate*)dateFromMillisecondUTCValue:(long long)millisecondUTCValue;

/**
 *  生成盐值+密码字符串，盐值小写处理
 *
 *  @param pswStr 密码 saltStr 盐值
 *
 *  @return NSString
 */
+(NSString*)psw:(NSString*)pswStr withSalt:(NSString*)saltStr;

/**
 *  根据盐值还原原始密码
 *
 *  @param pswStr 当前密码 saltStr 盐值
 *
 *  @return NSString
 */
+(NSString*)psw:(NSString*)pswStr withoutSalt:(NSString*)saltStr;

/**
 *  利用安全随机函数生成字符串
 *
 *  @return 随机字符串
 */
+ (NSString*)getRandomSaltString;

/**
 *  解析URL格式的数据
 *
 *  @param url
 *
 *  @return key值为url中参数名，value为参数值的字典
 */
+ (NSDictionary*)paraseUrlProperty:(NSURL *)url;

/**
 *  获取所有本地ip地址
 *  
 *  @return NSDictionary
 *       key:   NSSString
                en0     from wifi
 *              en1     from wifi
 *              pdp_ip0 from cell phone connection
 *              vpn     from vpn
 *
 *       value:  NSSString
 */
+ (NSDictionary*)allLocalIpAddress;

+ (NSString *)getLocalIPAddress;
/**
 *  判断是否为第三方应用
 *
 *  @param string
 *
 *  @return 是返回YES,否则返回NO
 */
+ (BOOL)chargeIsThirdpartyInfo:(NSString *)appID;

/**
 *  判断是否为第三方消息
 *
 *  @param string
 *
 *  @return 是返回YES,否则返回NO
 */
+ (BOOL)chargeIsThirdpartyMessage:(NSString *)appID;

#pragma mark -
#pragma mark 数据缓冲管理
typedef enum
{
	/* SDK 1 ~ 99 */
	CacheDataType_ScheduleConf	= 1,
	CacheDataType_CallTrans		= 2,
	CacheDataType_Location		= 3,
	CacheDataType_AddFriend		= 4,
	CacheDataType_LogComponent	= 5,
	CacheDataType_ChatLogsComp	= 6,
	CacheDataType_GroupLogsComp	= 7,
	CacheDataType_LabelConfigListForSelf = 8,
	CacheDataType_LabelConfigListForOtherContact = 9,
	
	/* Custom 100 ~ 999 */
	
	CacheDataType_Unknown		= -1
}CacheDataType;

+ (void)cacheData:(id)data withKey:(NSString *)key withType:(CacheDataType)type;
+ (id)dataFromCacheForKey:(NSString *)key forType:(CacheDataType)type;
+ (void)removeDataFromCacheForKey:(NSString *)key forType:(CacheDataType)type;
+ (NSInteger)cacheDataCountForType:(CacheDataType)type;
+ (NSArray *)cachedDataForType:(CacheDataType)type;
+ (void)cleanCacheDataForType:(CacheDataType)type;
+ (void)cleanAllCacheData;

#pragma mark -
#pragma mark 枚举值调试信息管理

typedef enum
{
	/* SDK 1 ~ 99 */
	EnumDescType_CallServiceEvt		= 1,
	EnumDescType_CallServiceState	= 2,
	EnumDescType_LoginState			= 3,
	EnumDescType_LoginCompStatus	= 4,
	EnumDescType_FastSDK_REG_NotifyID	= 5,
	EnumDescType_FastSDK_CALL_NotifyID	= 6,
	EnumDescType_FastSDK_SUB_NotifyID	= 7,
	EnumDescType_SVNCompStatus		= 8,
    EnumDescType_eConf_Callback_Notify = 9,
    EnumDescType_TUP_Call_Notifications = 10,
    EnumDescType_TUP_Conference_Notifications = 11,
    EnumDescType_TUP_Login_Notifications = 12,
	/* Custom 100 ~ 999 */
	
	EnumDescType_Unknown
}EnumDescType;

+ (void)addEnumDescription:(NSString *)desc forEnum:(NSInteger)enumValue forType:(EnumDescType)type;
+ (NSString *)enumDescription:(NSInteger)enumValue forType:(EnumDescType)type;
+ (void)cleanAllEnumDescriptions;

#define ECSUTILES_ADD_ENUM_DESCRIPTION(enumValue, type) do { [ECSUtils addEnumDescription:[NSString stringWithFormat:@"%s", #enumValue] forEnum:enumValue forType:type]; } while(0)

+ (void)addEnumDescription:(NSString *)desc forEnum:(NSInteger)enumValue forIdentity:(const char *)identity;
+ (NSString *)enumDescription:(NSInteger)enumValue forIdentity:(const char *)identity;

#define ECSUTILES_ADD_ENUM_DESCRIPTION_FOR_IDENTITY(enumValue, identity) do { [ECSUtils addEnumDescription:[NSString stringWithFormat:@"%s", #enumValue] forEnum:enumValue forIdentity:identity]; } while(0)


@end

@interface NSString (NSStringExtend)

- (NSString *)substringToSeparator:(NSString *)separator;
- (NSString *)substringFromSeparator:(NSString *)separator;

@end

@interface NSString (NSStringDomain)

- (BOOL)isIPAddress;
- (BOOL)isDomainAddress;

@end


@interface NSMutableArray (UniqueModify)

- (void)addUniqueObject:(id)anObject;
- (void)removeUniqueObject:(id)anObject;

- (void)addNotNilObject:(id)anObject;
- (void)removeNotNilObject:(id)anObject;

@end

@interface NSFileManager (FileManagerExtend)

- (BOOL)checkDirectoryAndCreateIfNotExist:(NSString *)filePath;

@end

#define RETURN_IF_PARAM_NULL(param) do { if (NULL == param) { //SDK_WRN_LOG("Invalid param : " << ctk::String(#param) << " is null."); return; } } while(0)
#define RETURN_FALSE_IF_PARAM_NULL(param) do { if (NULL == param) { //SDK_WRN_LOG("Invalid param : " << ctk::String(#param) << " is null."); return false; } } while(0)
#define RETURN_NO_IF_PARAM_NULL(param) do { if (NULL == param) { //SDK_WRN_LOG("Invalid param : " << ctk::String(#param) << " is null."); return NO; } } while(0)

#define RETURN_NO_IF_PARAM_NIL(param) do { if (nil == param) { //SDK_WRN_LOG("Invalid param : " << ctk::String(#param) << " is nil."); return NO; } } while(0)
#define RETURN_IF_PARAM_NIL(param) do { if (nil == param) { //SDK_WRN_LOG("Invalid param : " << ctk::String(#param) << " is nil."); return; } } while(0)
#define RETURN_NIL_IF_PARAM_NIL(param) do { if (nil == param) { //SDK_WRN_LOG("Invalid param : " << ctk::String(#param) << " is nil."); return nil; } } while(0)


#define RETURN_NO_IF_PARAM_TEXT_EMPTY(param) do { if (nil == param || ![param isKindOfClass:[NSString class]] || [param length] == 0) { //SDK_WRN_LOG("Invalid string : " << ctk::String(#param) << " is empty."); return NO; } } while(0)
#define RETURN_IF_PARAM_TEXT_EMPTY(param) do { if (nil == param || ![param isKindOfClass:[NSString class]] || [param length] == 0) { //SDK_WRN_LOG("Invalid string : " << ctk::String(#param) << " is empty."); return; } } while(0)
#define RETURN_NIL_IF_PARAM_TEXT_EMPTY(param) do { if (nil == param || ![param isKindOfClass:[NSString class]] || [param length] == 0) { //SDK_WRN_LOG("Invalid string : " << ctk::String(#param) << " is empty."); return nil; } } while(0)

#define RETURN_NO_IF_ARRAY_IS_EMPTY(param) do { if (nil == param || ![param isKindOfClass:[NSArray class]] || [param count] == 0) { //SDK_WRN_LOG("Invalid array : " << ctk::String(#param) << " is empty."); return NO; } } while(0)
#define RETURN_IF_ARRAY_IS_EMPTY(param) do { if (nil == param || ![param isKindOfClass:[NSArray class]] || [param count] == 0) { //SDK_WRN_LOG("Invalid array : " << ctk::String(#param) << " is empty."); return; } } while(0)
#define RETURN_NIL_IF_ARRAY_IS_EMPTY(param) do { if (nil == param || ![param isKindOfClass:[NSArray class]] || [param count] == 0) { //SDK_WRN_LOG("Invalid array : " << ctk::String(#param) << " is empty."); return nil; } } while(0)

#define SHARE_INSTANCE_DECLARE(ClassName)	+ (ClassName *)shareInstance; \
											+ (void)destoryInstance;

#define SHARE_INSTANCE_IMPLEMENT(ClassName) static ClassName * shareInstance_ = nil; \
											+ (ClassName *)shareInstance { 	@synchronized(self) { if (nil == shareInstance_) { shareInstance_ = [[ClassName alloc] init]; } } return shareInstance_; } \
											+ (void)destoryInstance { @synchronized(self) { if (nil != shareInstance_) { /*[shareInstance_  release]; */shareInstance_ = nil; } } }

