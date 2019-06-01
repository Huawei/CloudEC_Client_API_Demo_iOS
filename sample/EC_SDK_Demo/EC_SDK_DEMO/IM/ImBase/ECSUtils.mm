//
//  ECSUtils.m
//  eSpaceIOSSDK
//
//  Created by lichuange on 12-5-3.
//  Copyright 2012 Huawei Technologies Co., Ltd. All rights reserved.
//

#import "ECSUtils.h"
//#import "ECSLogCofig.h"
//#import <ctk.h>
#import <string>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
//#include "PYCode.h"
#include <sys/sysctl.h>
#import <CommonCrypto/CommonDigest.h>
#import <UIKit/UIDevice.h>
#import "tsdk_def.h"
//#import "dk_interface.h"
#import "ECSAppConfig.h"
#import "ECSUserConfig.h"
#import <UIKit/UIKit.h>
#include <sys/sysctl.h>
#import <sys/socket.h>
#import <net/if.h>
#import <net/if_dl.h>
#import <ifaddrs.h>
#import <arpa/inet.h>
#import <netdb.h>
#import "ECSSandboxHelper.h"
//#import <mip.h>

#define CHECKCSTR(str) (((str) == NULL) ? "" : (str))

@implementation ECSUtils
+ (BOOL)chargeIsThirdpartyInfo:(NSString *)appID{
    if (0 == appID.length || [appID isEqualToString:[ECSAppConfig sharedInstance].appID]) {
        return NO;
    }else{
        return YES;
    }
}

+ (BOOL)chargeIsThirdpartyMessage:(NSString *)appID{
    if (appID.length != 0) {
        if ([appID isEqualToString:[ECSAppConfig sharedInstance].appID]) {
            return NO;
        }
        return YES;
    }
    return YES;
}

+ (NSDictionary*)paraseUrlProperty:(NSURL *)url
{
    if (nil == url) {
        //SDK_INFO_LOG("paraseUrlProperty failed url is nil");
        return nil;
    }
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    NSString *query = [url query];
    NSArray *params = [query componentsSeparatedByString:@"&"];
    for (NSString *param in params) {
        NSArray *kv = [param componentsSeparatedByString:@"="];
        if ([kv count] == 2) {
            if (nil == kv[1] || nil == kv[0]) {
                //SDK_ERROR_LOG("token error: param error");
                return dict;
            }
            [dict setObject:kv[1] forKey:kv[0]];
        }
    }
    
    return dict;
}

+ (NSString*)replacePlusWithOOFromCallingNumber:(NSString *)callNumbber
{
    if (callNumbber.length <= 0) {
        return callNumbber;
    }
    NSString *firstChar = [callNumbber substringToIndex:1];
    NSString *othersStr = [callNumbber substringFromIndex:1];
    if ([firstChar isEqualToString:@"+"]) {
        NSMutableString *replacedStr = [NSMutableString stringWithCapacity:1];
        [replacedStr appendString:@"00"];
        [replacedStr appendString:othersStr];
        return replacedStr;
    }else{
        return callNumbber;
    }
}

+ (NSString *)standardizedCallNumber:(NSString *)callNumber {
    if (callNumber.length == 0) {
        return @"";
    }
    
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[^0-9*#+]" options:0 error:&error];
    if (error) {
        //SDK_WRN_LOG("NSRegularExpression error:" << error.description.UTF8String);
        return callNumber;
    }
    NSMutableString *str = [NSMutableString stringWithString:callNumber];
    [regex replaceMatchesInString:str options:0 range:NSMakeRange(0, callNumber.length) withTemplate:@""];
    return str;
}


+ (void)deviceProximityMonitoringAndIdleTimer:(BOOL)enable
{
    [[UIDevice currentDevice] setProximityMonitoringEnabled:enable];
    [[UIApplication sharedApplication] setIdleTimerDisabled:enable];
}

/**
 *  过滤Text字符串中不属于strRuler字符串中的字符
 *
 *  @param Text     待过滤的字符串
 *  @param strRuler 符合过滤规则的字符串
 *
 *  @return 过滤后的字符串
 */
+ (NSString *)maskText:(NSString*)Text Ruler:(NSString*)strRuler
{
    if (nil == Text || nil == strRuler)
    {
        return 0;
    }
    
    NSUInteger iTextLen = [Text length];
    NSMutableString* strRtn = [[NSMutableString alloc] init];
    for (int i = 0; i < iTextLen; ++i) {
        NSRange range = NSMakeRange(i, 1);
        NSString* strEvery = [Text substringWithRange:range];
        if([strRuler rangeOfString:strEvery].length > 0){
            [strRtn appendString:strEvery];
        }
    }
    
    return strRtn;
}

+ (BOOL)isHaveAuthorityForMediaType:(NSString *)mediaType {
    BOOL isAllow = YES;
//    if ([ECSUtils isOSMajorVersionHigherThanVersion:IOS_MAINVERSION_7]) {
//        ::AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
//        switch (authStatus) {
//            case ::AVAuthorizationStatusNotDetermined:
//            case ::AVAuthorizationStatusRestricted:
//            case ::AVAuthorizationStatusDenied:
//                isAllow = NO;
//                break;
//            case ::AVAuthorizationStatusAuthorized:
//                break;
//            default:
//                break;
//        }
//    }
    return isAllow;
}

+ (NSString *)hideMobileNumber:(NSString *)number {
    if ([number length] == 0) {
        return nil;
    }
    NSInteger maxCount = 4;
    NSInteger maxHideCount = [number length] < maxCount ? [number length] : maxCount;
    NSMutableString *hideNumber = [NSMutableString stringWithString:number];
    NSMutableString *hideStr = [NSMutableString string];
    for (NSInteger i = 0; i < maxHideCount; i++) {
        [hideStr appendString:@"*"];
    }
    [hideNumber replaceCharactersInRange:NSMakeRange([number length]-maxHideCount, maxHideCount) withString:hideStr];
    return hideNumber;
}

+ (NSString*) clientBundleVersion {
    NSString* boundleVersion = [[ECSSandboxHelper shareInstance].UIResourceBundle objectForInfoDictionaryKey:(__bridge NSString*)kCFBundleVersionKey];
    return boundleVersion;
}

+ (NSString*) clientLanguage {
    NSString* la = [[NSLocale preferredLanguages] objectAtIndex:0];
    NSRange range = [la rangeOfString:@"-"];
    if (range.location != NSNotFound) {
        la = [la substringToIndex:range.location];
    }
    return [la uppercaseString];
}

+ (NSString*)addDomainField:(NSString*)inString domain:(NSString*)domain
{
	if (([inString length] <= 0) || ([domain length] <= 0))
		return inString;
	
	return [NSString stringWithFormat:@"%@@%@", inString, domain];
}

+ (NSString*)removeDomainField:(NSString*)inString
{
	if ([inString length] <= 0) 
    {
		return inString;
	}
	
	NSRange range = [inString rangeOfString:@"@"];
    
	if (range.length != 0) 
    {
		range = NSMakeRange(0, range.location);
		return [inString substringWithRange:range];
	}
	else 
    {
		return inString;
	}
}

+(NSString*)domainFromNumber:(NSString*)number
{
	if ([number length] <= 0) 
    {
		return @"";
	}
	
	NSRange range = [number rangeOfString:@"@"];
    
	if (range.length != 0) 
    {
		range = NSMakeRange(range.location + 1, [number length] - range.location - 1);
		return [number substringWithRange:range];
	}
	else 
    {
		return @"";
	}
}

+ (NSString*)addPrefix:(NSString*)inString prefix:(NSString*)prefix 
{
	if ([inString length] <= 0 || [prefix length] <= 0) 
    {
		return inString;
	}
	
	return [NSString stringWithFormat:@"%@%@", prefix, inString];
}


+ (NSString*)removePrefix:(NSString*)inString prefix:(NSString*)prefix 
{
	if ([inString length] <= 0 || [prefix length] <= 0) 
    {
		return inString;
	}
	
	if ([inString hasPrefix:prefix]) {
		return [inString substringFromIndex:[prefix length]];
	}
	else {
		return inString;
	}
}

+ (NSString*)addSuffix:(NSString*)inString suffix:(NSString*)suffix 
{
	if (([inString length] <= 0) || ([suffix length] <= 0))
		return inString;
	
	return [inString stringByAppendingString:suffix];
}

+ (NSString*)removeSuffix:(NSString*)inString suffix:(NSString*)suffix 
{
	if ([inString length] <= 0 || [suffix length] <= 0) 
    {
		return inString;
	}
	
	NSRange range = [inString rangeOfString:suffix];
    
	if (range.length != 0) 
    {
		range = NSMakeRange(0, range.location);
		return [inString substringWithRange:range];
	}
	else 
    {
		return inString;
	}
}

//+(NSData*)AESEncrypt:(NSData*)inData key:(NSData*)key initVector:(NSData*)initVector
//{
//    if (nil == inData || nil == key || nil == initVector)
//    {
//        //SDK_ERROR_LOG("input parameter invalid : inData , key or initVector is nil");
//        return nil;
//    }
//    ctk::AES aes(ctk::istr([key bytes], [key length]), ctk::istr([initVector bytes], [initVector length]));
//    ctk::Bytes outData;
//    aes.encrypt(ctk::istr([inData bytes], [inData length]), outData);
//    return [NSData dataWithBytes:outData.data() length:outData.size()]; // return copy of outData
//}
//
//+(NSInteger)getAESValidSize:(ctk::Bytes&)data
//{
//    NSInteger validLength = data.size();
//    while (validLength >= 1 && data[validLength - 1] == 0)
//    {
//        --validLength;
//    }
//    return validLength;
//}

//+(NSData*)AESdecrypt:(NSData*)inData key:(NSData*)key initVector:(NSData*)initVector isRemovePadding:(BOOL)isRemovePadding
//{
//    if ([inData length]==0 || [key length]==0|| [initVector length]==0)
//    {
//        //SDK_ERROR_LOG("input parameter invalid : inData , key or initVector is nil");
//        return nil;
//    }
//    if ([inData length] % 16 != 0)
//    {
//        //SDK_ERROR_LOG("[inData length] % 16 != 0");
//        return nil;
//    }
//    ctk::AES aes(ctk::istr([key bytes], [key length]), ctk::istr([initVector bytes], [initVector length]));
//    ctk::Bytes outData;
//    aes.decrypt(ctk::istr([inData bytes], [inData length]), outData);
//    if (isRemovePadding)
//    {
//        return [NSData dataWithBytes:outData.data() length:[ECSUtils getAESValidSize:outData]]; // return copy of outData
//    }
//    else
//    {
//        return [NSData dataWithBytes:outData.data() length:outData.size()]; // return copy of outData
//    }
//}

//+(NSString*)base64:(NSData*)inData
//{
//    std::string outString;
//    mip::msg::base64(ctk::istr([inData bytes], [inData length]), outString);
//    return [NSString stringWithUTF8String:outString.c_str()]; // return copy of outString
//}

//+(NSData*)unbase64:(NSData*)inData
//{
//    ctk::Bytes outData;
//    mip::msg::unbase64(ctk::istr([inData bytes], [inData length]), outData);
//    return [NSData dataWithBytes:outData.data() length:outData.size()]; // return copy of outData
//}

+(NSString *)MD5StringFromStr:(NSString*)str{
    
    if([str length] == 0)
        return nil;
    
    const char *value = [str UTF8String];
    
    unsigned char outputBuffer[CC_MD5_DIGEST_LENGTH];
    CC_MD5(value, (CC_LONG)strlen(value), outputBuffer);
    
    NSMutableString *outputString = [[NSMutableString alloc] initWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(NSInteger count = 0; count < CC_MD5_DIGEST_LENGTH; count++){
        [outputString appendFormat:@"%02x",outputBuffer[count]];
    }
    
    return outputString;
}

/*获取sha1*/
+(NSString*)sha1:(NSData*)data{
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    
    CC_SHA1(data.bytes, (CC_LONG)data.length, digest);
    
    NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return output;
}

+ (NSString *)sha256:(NSString *)inStr {
    if(inStr.length == 0) {
        return nil;
    }
    
    const char *value = [inStr UTF8String];
    
    unsigned char outputBuffer[CC_SHA256_DIGEST_LENGTH];
    CC_SHA256(value, (CC_LONG)strlen(value), outputBuffer);
    
    NSMutableString *outputString = [[NSMutableString alloc] initWithCapacity:CC_SHA256_DIGEST_LENGTH * 2];
    for(NSInteger count = 0; count < CC_SHA256_DIGEST_LENGTH; count++){
        [outputString appendFormat:@"%02x",outputBuffer[count]];
    }
    
    NSString *sha256 = [outputString uppercaseString];
    
    return sha256;
}

+(NSString*)dbEncryptGuarderWithAccount:(NSString*) escpaceNumber
{   
    return [NSString stringWithFormat:@"%@%@",escpaceNumber,[self deviceUUID]];
}


//static NSString* const CONSTString = @"AQEFDFGHUK986JMK";
static NSString* const AESInitVector = @"7B6D6A04";


+(NSString*)plistDataEncrypt:(NSString*)data
{
	if ([data length] == 0) 
	{
//		//SDK_ERROR_LOG("plistDataEncrypt: data is null");
		return data;
	}
    NSString * deviceID = [self deviceUUID];
	NSString * aesKey = [ECSUtils MD5StringFromStr:[NSString stringWithFormat:@"%@%@", deviceID, [ECSAppConfig sharedInstance].plistSecurityRandomStr]];
	NSData* encryptData = [ECSUtils AESEncrypt:[data dataUsingEncoding:NSUTF8StringEncoding] key:[aesKey dataUsingEncoding:NSUTF8StringEncoding] initVector:[AESInitVector dataUsingEncoding:NSUTF8StringEncoding]];
	return [ECSUtils base64:encryptData];
}

+(NSString*)plistDataDecrypt:(NSString*)data
{
	if ([data length] == 0) 
	{
//		//SDK_ERROR_LOG("plistDataDecrypt:data is null");
		return data;
	}
    NSString * localMacOrUUID = [self deviceUUID];
	NSString * aesKey = [ECSUtils MD5StringFromStr:[NSString stringWithFormat:@"%@%@", localMacOrUUID, [ECSAppConfig sharedInstance].plistSecurityRandomStr]];
	NSData* unbase64Data = [ECSUtils unbase64:[data dataUsingEncoding:NSUTF8StringEncoding]];
	NSData* decryptData = [ECSUtils AESdecrypt:unbase64Data key:[aesKey dataUsingEncoding:NSUTF8StringEncoding] initVector:[AESInitVector dataUsingEncoding:NSUTF8StringEncoding] isRemovePadding:YES];
	if (decryptData == nil) 
	{
		return nil;
	}
	
	return [[NSString alloc] initWithData:decryptData encoding:NSUTF8StringEncoding];
}

//static const char * const s_DBCONSTString = "aedkfjdiodiejjfk";
static const char * const s_DBAESInitVector = "fhkp8hji01jdjdkf";
//static ctk::AES * s_aesForDBDataEncrypt = NULL;

//+(NSData*)aesKeyData{
//    NSData *aesKey = nil;
//    NSString* salt = [ECSAppConfig sharedInstance].dbSecurityRandomStr;
//    TUP_UCHAR *key = (TUP_UCHAR*)[salt UTF8String];
//    TUP_UINT32 lenth = (TUP_UINT32)[salt length]+1;
//    TUP_UCHAR *pucderivedkey = NULL;
//
//    pucderivedkey = (TUP_UCHAR*)malloc(lenth*sizeof(TUP_UCHAR));
//    if (NULL == pucderivedkey) {
//        return nil;
//    }
//    TUP_UINT32 ret = tup_pkcs5_derivekey(key,
//                                         lenth,
//                                         5000,
//                                         32,
//                                         pucderivedkey);
//    if (ret == TUP_SUCCESS) {
//        aesKey = [NSData dataWithBytes:pucderivedkey length:lenth];
//    }else{
//        aesKey = nil;
//    }
//    free(pucderivedkey);
//
//    return aesKey;
//}

+(NSString*)databaseDataEncrypt:(NSString*)data
{
//    if ([data length] == 0)
//    {
////        //SDK_ERROR_LOG("databaseDataEncrypt: data is null");
//        return data;
//    }
//    if (s_aesForDBDataEncrypt == NULL)
//    {
//        AESKEY_MODE aesMode = [ECSAppConfig sharedInstance].currentUser.aesMode;
//        //SDK_DEBUG_LOG("current database data encrypt mode is = " << aesMode);
//
//        if (aesMode != AESKEY_MODE_UNKNOW){
//            if (aesMode == AESKEY_MODE_DYNAMIC){
//                //SDK_DEBUG_LOG("databaseDataEncrypt using new key");
//                NSData *dataAESKey = [ECSUtils aesKeyData];
//                if ([dataAESKey length] > 0) {
//                    s_aesForDBDataEncrypt = new ctk::AES(ctk::istr([dataAESKey bytes], [dataAESKey length]), ctk::istr(s_DBAESInitVector, strlen(s_DBAESInitVector)));
//                }
//            }else{
//                //SDK_DEBUG_LOG(@"databaseDataEncrypt using old key");
//                NSString* dbKeyValue = [ECSAppConfig sharedInstance].dbSecurityRandomStr;
//                s_aesForDBDataEncrypt = new ctk::AES(ctk::istr([dbKeyValue UTF8String], strlen([dbKeyValue UTF8String])), ctk::istr(s_DBAESInitVector, strlen(s_DBAESInitVector)));
//            }
//        }
//    }
//    NSData * inData = [data dataUsingEncoding:NSUTF8StringEncoding];
////    ctk::Bytes outData;
////    s_aesForDBDataEncrypt->encrypt(ctk::istr([inData bytes], [inData length]), outData);
//    std::string outString;
////    mip::msg::base64(ctk::istr(outData.data(), outData.size()), outString);
//    return [NSString stringWithUTF8String:outString.c_str()]; // return copy of outString
    return nil;
}

+(NSString*)databaseDataDecrypt:(NSString*)data
{
//    if ([data length] == 0)
//    {
////        //SDK_ERROR_LOG("databaseDataDecrypt: data is null");
//        return data;
//    }
//    NSData * inData = [data dataUsingEncoding:NSUTF8StringEncoding];
////    ctk::Bytes unbase64Data;
////    mip::msg::unbase64(ctk::istr([inData bytes], [inData length]), unbase64Data);
//
//    if (unbase64Data.size() % 16 != 0)
//    {
//        ////SDK_ERROR_LOG("[inData length] % 16 != 0");
//        return nil;
//    }
//    if (s_aesForDBDataEncrypt == NULL)
//    {
//        AESKEY_MODE aesMode = [ECSAppConfig sharedInstance].currentUser.aesMode;
//        //SDK_DEBUG_LOG("current database data decrypt mode is = " << aesMode);
//
//        if (aesMode != AESKEY_MODE_UNKNOW){
//            if (aesMode == AESKEY_MODE_DYNAMIC){
//                //SDK_DEBUG_LOG("databaseDataDecrypt using new key");
//                NSData *dataAESKey = [ECSUtils aesKeyData];
//                if ([dataAESKey length] > 0) {
//                    s_aesForDBDataEncrypt = new ctk::AES(ctk::istr([dataAESKey bytes], [dataAESKey length]), ctk::istr(s_DBAESInitVector, strlen(s_DBAESInitVector)));
//                }
//            }else{
//                //SDK_DEBUG_LOG("databaseDataDecrypt using old key");
//                NSString* dbKeyValue = [ECSAppConfig sharedInstance].dbSecurityRandomStr;
//                s_aesForDBDataEncrypt = new ctk::AES(ctk::istr([dbKeyValue UTF8String], strlen([dbKeyValue UTF8String])), ctk::istr(s_DBAESInitVector, strlen(s_DBAESInitVector)));
//            }
//
//        }
//    }
//    ctk::Bytes outData;
//    s_aesForDBDataEncrypt->decrypt(ctk::istr(unbase64Data.data(), unbase64Data.size()), outData);
//    return [[NSString alloc] initWithData:[NSData dataWithBytes:outData.data() length:[ECSUtils getAESValidSize:outData]] encoding:NSUTF8StringEncoding];
    return nil;
}

#define DATABASE_DATA_ENCRYPT_AND_DECRYPT_TESTCASE(data)		NSAssert([[ECSUtils databaseDataDecrypt:[ECSUtils databaseDataEncrypt:(data)]] isEqualToString:(data)], (data))

+(void)databaseDataEncryptAndDecryptTest:(NSString *)testString
								forTimes:(NSInteger)times
{
	/* cases */
	DATABASE_DATA_ENCRYPT_AND_DECRYPT_TESTCASE(@"abc");
	DATABASE_DATA_ENCRYPT_AND_DECRYPT_TESTCASE(@"123");
	DATABASE_DATA_ENCRYPT_AND_DECRYPT_TESTCASE(@"@#$&&(*&(");
	DATABASE_DATA_ENCRYPT_AND_DECRYPT_TESTCASE(@"史蒂夫合口呼客户");
	DATABASE_DATA_ENCRYPT_AND_DECRYPT_TESTCASE(@"第三個進口數量多瘋狂過來 ");
	DATABASE_DATA_ENCRYPT_AND_DECRYPT_TESTCASE(@"  ");
	DATABASE_DATA_ENCRYPT_AND_DECRYPT_TESTCASE(@"asfhk136487史蒂夫合口呼客户28adajhdks");
	DATABASE_DATA_ENCRYPT_AND_DECRYPT_TESTCASE(@"asfhk136487史蒂夫合口呼客户28adajhdks2324");
	DATABASE_DATA_ENCRYPT_AND_DECRYPT_TESTCASE(@"asfhk136487史sdfssh45645蒂夫合口呼客户28adajhdks2324");

	 double timeStart = CFAbsoluteTimeGetCurrent();
	
	 for (int i = 0; i < times; i++) 
	 {
		 NSString* encryptData = [ECSUtils databaseDataEncrypt:testString];
		 NSString* decryptData = [ECSUtils databaseDataDecrypt:encryptData];
		 [decryptData length];
	 }
	 
	 double timeEnd = CFAbsoluteTimeGetCurrent();
	 
	 NSLog(@"================ used time = %f, %ld times for input[%@]", (timeEnd - timeStart), (long)times, testString);
}

+(NSString*)convertVersionIntToString:(NSInteger)version;
{
	if (version <= 0)
	{
		//SDK_ERROR_LOG("version <= 0");
		return nil;
	}
	return [NSString stringWithFormat:@"%ld.%ld.%ld", (long)(version/10000)%100, (long)(version/100)%100, (long)version%100];
}

+(NSInteger)convertVersionStringToInt:(NSString*)strVersion
{
	if ([strVersion length] == 0)
	{
		//SDK_ERROR_LOG("strVersion is null");
		return -1;
	}
	NSArray* comps = [strVersion componentsSeparatedByString:@"."];
	if (nil != comps && [comps count] == 3) 
	{
		return [[comps objectAtIndex:0] intValue]*10000 + [[comps objectAtIndex:1] intValue]*100 + [[comps objectAtIndex:2] intValue];
	}
	//SDK_ERROR_LOG("version format invalid");
	return -1;
}

/* 获取设备名称，"ipad1,1",ipad2,1", 逗号后数字表示1－wifi版，2－3G版 */
+ (NSString*)getDeviceVersion 
{
	size_t size;
	sysctlbyname("hw.machine", NULL, &size, NULL, 0);
	char *machine = (char*)malloc(size);
	sysctlbyname("hw.machine", machine, &size, NULL, 0); 
	NSString *platform = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding]; 
	free(machine);
	return platform;
}

+ (BOOL)isJailbroken
{
    BOOL jailbroken = NO;
    NSString *cydiaPath = @"/Applications/Cydia.app";
    NSString *aptPath = @"/private/var/lib/apt/";
    if ([[NSFileManager defaultManager] fileExistsAtPath:cydiaPath]) {
        jailbroken = YES;
    }
    if ([[NSFileManager defaultManager] fileExistsAtPath:aptPath]) {
        jailbroken = YES;
    }
    
    return jailbroken;
}

+ (NSString *)getUA {
    NSString *ua = [NSString stringWithFormat:@"IOS:%@", [UIDevice currentDevice].systemVersion];
    if ([ECSUtils isJailbroken]) {
        ua = [ua stringByAppendingString:@"(JB)"];
    }
    return ua;
}

+ (UIDeviceMode) platformString {
    NSString *platform = [self getDeviceVersion];
    /*iPhone*/
    if (0 != [platform rangeOfString:@"iPhone3"].length) {
        return UIDeviceMode_Iphone4;
    }
    if (0 != [platform rangeOfString:@"iPhone4"].length) {
        return UIDeviceMode_Iphone4S;
    }
    if ([platform isEqualToString:@"iPhone5,1"] || [platform isEqualToString:@"iPhone5,2"]) {
        return UIDeviceMode_Iphone5;
    }
    if ([platform isEqualToString:@"iPhone5,3"] || [platform isEqualToString:@"iPhone5,4"]) {
        return UIDeviceMode_Iphone5C;
    }
    if (0 != [platform rangeOfString:@"iPhone6"].length) {
        return UIDeviceMode_Iphone5S;
    }
    if (0 != [platform rangeOfString:@"iPhone7,2"].length) {
        return UIDeviceMode_Iphone6;
    }
    if (0 != [platform rangeOfString:@"iPhone7,1"].length) {
        return UIDeviceMode_Iphone6_Plus;
    }
    if (0 != [platform rangeOfString:@"iPhone8,1"].length) {
        return UIDeviceMode_Iphone6S;
    }
    if (0 != [platform rangeOfString:@"iPhone8,2"].length) {
        return UIDeviceMode_Iphone6S_Plus;
    }
    
    
    /*iPad*/
    if ([platform isEqualToString:@"iPad2,1"]
        || [platform isEqualToString:@"iPad2,2"]
        ||[platform isEqualToString:@"iPad2,3"]
        || [platform isEqualToString:@"iPad2,4"]) {
        return UIDeviceMode_Ipad2;
    }
    if ([platform isEqualToString:@"iPad2,5"]
        || [platform isEqualToString:@"iPad2,6"]
        ||[platform isEqualToString:@"iPad2,7"]) {
        return UIDeviceMode_IpadMini;
    }
    if ([platform isEqualToString:@"iPad3,1"]
        || [platform isEqualToString:@"iPad3,2"]
        ||[platform isEqualToString:@"iPad3,3"]) {
        return UIDeviceMode_Ipad3;
    }
    if ([platform isEqualToString:@"iPad3,4"]
        || [platform isEqualToString:@"iPad3,5"]
        ||[platform isEqualToString:@"iPad3,6"]) {
        return UIDeviceMode_Ipad4;
    }
    
    if ([platform isEqualToString:@"iPad4,4"]
        || [platform isEqualToString:@"iPad4,5"]) {
        return UIDeviceMode_IpadMini2;
    }
    if ([platform isEqualToString:@"iPad4,1"]
        || [platform isEqualToString:@"iPad4,2"]) {
        return UIDeviceMode_Ipad5;
    }
    
    return UIDeviceMode_Unknown;
}

+ (NSString *)deviceTypeString
{
    UIDeviceMode deviceMode = [self platformString];
    switch (deviceMode)
    {
        case UIDeviceMode_Iphone3G:
            return @"iPhone 3G";
            break;
        case UIDeviceMode_Iphone3GS:
            return @"iPhone 3GS";
            break;
        case UIDeviceMode_Iphone4:
            return @"iPhone 4";
            break;
        case UIDeviceMode_Iphone4S:
            return @"iPhone 4S";
            break;
        case UIDeviceMode_Iphone5:
            return @"iPhone 5";
            break;
        case UIDeviceMode_Iphone5C:
            return @"iPhone 5C";
            break;
        case UIDeviceMode_Iphone5S:
            return @"iPhone 5S";
            break;
        case UIDeviceMode_Ipad2:
            return @"iPad 2";
            break;
        case UIDeviceMode_Ipad3:
            return @"iPad 3";
            break;
        case UIDeviceMode_IpadMini:
            return @"iPad mini 1";
            break;
        case UIDeviceMode_Ipad4:
            return @"iPad 4";
            break;
        case UIDeviceMode_Ipad5:
            return @"iPad 5";
            break;
        case UIDeviceMode_IpadMini2:
            return @"iPad mini 2";
            break;
        case UIDeviceMode_Iphone6:
            return @"iPhone 6";
            break;
        case UIDeviceMode_Iphone6_Plus:
            return @"iPhone 6 Plus";
            break;
        case UIDeviceMode_Iphone6S:
            return @"iPhone 6S";
            break;
        case UIDeviceMode_Iphone6S_Plus:
            return @"iPhone 6S Plus";
            break;
        default:
            return @"iPhone";
            break;
    }
    return @"iPhone";
}

+(SCREEN_SIZE)deviceScreenSize{
    UIDeviceMode deviceMode = [self platformString];
    SCREEN_SIZE size = SCREEN_SIZE_4;
    switch (deviceMode)
    {
        case UIDeviceMode_Iphone3G:
        case UIDeviceMode_Iphone3GS:
        case UIDeviceMode_Iphone4:
        case UIDeviceMode_Iphone4S:
            size = SCREEN_SIZE_3_5;
            break;
        default:
            size = SCREEN_SIZE_4;
            break;
    }
    
    return size;
}

//// 获取名字拼音
//+ (NSArray*)getEnglishStr:(NSString *)str{
//    const unichar c_min = 0x4E00;//在unicode编码下,汉字收录起点
//    const unichar c_max = 0x9FA5;//在unicode编码下,汉字收录终点
//
//    NSStringEncoding encgbk = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
//
//    NSMutableString * temString = [NSMutableString stringWithCapacity:1];
//    NSMutableString *simplifiedPinyin = [NSMutableString stringWithCapacity:3];
//
//    for (NSUInteger index = 0 ; index < [str length] ; index ++) {
//        unichar c = [str characterAtIndex:index];
//        if (c >= c_min && c_max >= c) {
//            NSString *subStr = [str substringWithRange:NSMakeRange(index, 1)];
//            //const char *fullStr = GetFullPy([subStr cStringUsingEncoding:encgbk]).c_str();
//            NSString* fullStr = [NSString stringWithFormat:@"%s",GetFullPy([subStr cStringUsingEncoding:encgbk]).c_str()];
//            if (fullStr != NULL)
//            {
//                //IOS8下原实现方法可能出现简拼获取错误
//                //[temString appendFormat:@"%s",fullStr];
//                //[simplifiedPinyin appendFormat:@"%c",fullStr[0]];
//                [temString appendFormat:@"%@",fullStr];
//                [simplifiedPinyin appendFormat:@"%@",[fullStr substringWithRange:NSMakeRange(0, 1)]];
//            }
//        }
//        else {
//            NSString * subStr = [str substringWithRange:NSMakeRange(index, 1)];
//            [temString appendString:subStr];
//            [simplifiedPinyin appendString:subStr];
//        }
//    }
//
//    return [NSArray arrayWithObjects:temString,simplifiedPinyin, nil];
//
//    //return [NSArray arrayWithObject:temString];
//}

/******************************************************************************
 函数名称  : containDisCountinuousString
 函数描述  : 查找字符串srcString是否有按顺序包含serachString中的字串
 输入参数  : srcString：原始字串 searchString：需要匹配的字串
 输出参数  : N/A
 返回值    : True代表有查找到
 备注      :	N/A
 ******************************************************************************/
+(BOOL)containDisCountinuousString:(NSString *)srcString searchStr:(NSString *)searchString{
	NSRange srcRange = {0, 0};
	NSRange searchRange = {0, 1};
	NSString *tmpSrcString = srcString;
	
	for (searchRange.location = 0; searchRange.location < [searchString length]; searchRange.location++) {
		NSString *subSearchStr = [searchString substringWithRange:searchRange];
		srcRange = [tmpSrcString rangeOfString:subSearchStr];
		if (srcRange.location == NSNotFound) {
			return FALSE;
		}
		tmpSrcString = [tmpSrcString substringFromIndex:srcRange.location + 1];
	}
	
	return TRUE;
}

+(NSMutableArray*)subStringsInStr:(NSString*)aStr withSeperators:(NSArray*)seperatorAry
{
	NSMutableCharacterSet *characterSet = [[NSMutableCharacterSet alloc] init];
	for (NSString *seperator in seperatorAry) {
		[characterSet addCharactersInString:seperator];
	}
	
	return [NSMutableArray arrayWithArray:[aStr componentsSeparatedByCharactersInSet:characterSet]];
}

//+ (NSString *)chineseStringWithString:(NSString *)astr {//只转化中文
//	const unichar c_min = 0x4E00;//在unicode编码下,汉字收录起点
//	const unichar c_max = 0x9FA5;//在unicode编码下,汉字收录终点
//	
//	NSStringEncoding encgbk = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
//	
//	NSMutableString * temString = [NSMutableString stringWithCapacity:1];
//	for (NSUInteger index = 0 ; index < [astr length] ; index ++) {
//		unichar c = [astr characterAtIndex:index];
//		if (c >= c_min && c_max >= c) {
//			NSString * subStr = [astr substringWithRange:NSMakeRange(index, 1)];
//			[temString appendFormat:@"%s",GetFullPy([subStr cStringUsingEncoding:encgbk]).c_str()];
//		}
//		else {
//			NSString * subStr = [astr substringWithRange:NSMakeRange(index, 1)];
//			[temString appendString:subStr];
//		}
//	}
//	
//	return temString;
//}

+ (BOOL)IsContainChinese:(NSString*)strName	// 判断字符串中是否有中文字符
{
	if(nil == strName || 0 == [strName length])
		return NO;
	
	for(int i = 0; i < [strName length]; ++i){
		
		unichar c = [strName characterAtIndex:i];
		if (0x4E00 <= c && 0x9FA5 >= c) {
			return YES;
		}
	}
	return NO;
}

+ (BOOL)IsInitialChinese:(NSString *)strName //判断字符串的首字为中文字符
{
    if(nil == strName || 0 == [strName length])
		return NO;
	
    unichar c = [strName characterAtIndex:0];
    if (0x4E00 <= c && 0x9FA5 >= c) {
        return YES;
    }
    
	return NO;
}

+ (NSString *)notNilString:(NSString *)inString {
	return inString == nil ? @"" : inString;
}

//+ (NSInteger)getRandomNumber {
////	srand(time(0));
////	return rand();
//    return HW_RANDOM_INT(INT_MAX);
//}

+ (BOOL)isOSMajorVersionHigherThanVersion:(IOS_MAINVERSION)version
{
    static NSUInteger _deviceSystemMajorVersion = -1;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _deviceSystemMajorVersion = [[[[[UIDevice currentDevice] systemVersion] componentsSeparatedByString:@"."] objectAtIndex:0] intValue];
    });
    return _deviceSystemMajorVersion >= version;
}

+ (NSString *)deviceUUID {
    NSString *uuid = @"";
    if ([[UIDevice currentDevice] respondsToSelector:@selector(identifierForVendor)]) {
        uuid = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    }
    return uuid;
}

/**
 *  根据日期获取精确到毫秒的UTC时间
 *
 *  @param paraDate 时间
 *
 *  @return 精确到毫秒的UTC时间
 */
+ (long long)millisecondUTCFromDate:(NSDate*)paraDate{
    NSTimeInterval timeValue = [paraDate timeIntervalSince1970];
    long long changedValue = 0;
    if ([[NSString stringWithFormat:@"%f", timeValue] length] == 10) {
        changedValue = [[NSString stringWithFormat:@"%f000",timeValue] longLongValue];
    }
    else{
        changedValue = timeValue*1000;
    }
    return changedValue;
}

/**
 *  将精确到毫秒的UTC时间转换为NSDate
 *
 *  @param millisecondUTCValue 精确到毫秒的UTC时间
 *
 *  @return NSDate
 */
+ (NSDate*)dateFromMillisecondUTCValue:(long long)millisecondUTCValue{
    NSInteger valueLength = [[NSString stringWithFormat:@"%llu", millisecondUTCValue] length];
    long double timeValue = millisecondUTCValue;
    if (10 != valueLength) {
        timeValue /= 1000;
    }
    NSDate* tempDate = [NSDate dateWithTimeIntervalSince1970:timeValue];
    
    return tempDate;
}

+(NSString*)psw:(NSString*)pswStr withSalt:(NSString*)saltStr{
    return [NSString stringWithFormat:@"%@%@",[saltStr lowercaseString],pswStr];
}

+(NSString*)psw:(NSString*)pswStr withoutSalt:(NSString*)saltStr{
    NSString *finalStr = pswStr;
    
    if ([pswStr hasPrefix:[saltStr lowercaseString]]) {
        finalStr = [pswStr substringFromIndex:[saltStr length]];
    }
    return finalStr;
}

+ (NSString*)getRandomSaltString {
    
    NSMutableString* randomSaltString = nil;
    uint8_t randomBytes[8];
    int result = SecRandomCopyBytes(kSecRandomDefault, 8, randomBytes);
    if (result == 0) {
        randomSaltString = [[NSMutableString alloc] initWithCapacity:8*2];
        for (NSInteger index = 0; index < 8; index++) {
            [randomSaltString appendFormat:@"%02x", randomBytes[index]];
        }
    }
    else{
        //SDK_DEBUG_LOG("secRandommCopyBytes failed for some reason");
    }
    
    return randomSaltString;
}

+ (NSDictionary*)allLocalIpAddress
{
    NSMutableDictionary *addressDic = nil;
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        addressDic = [[NSMutableDictionary alloc] init];
        while (temp_addr != NULL) {
            if( temp_addr->ifa_addr->sa_family == AF_INET) {    // ipv4
                // Check if interface is en0 which is the wifi connection on the iPhone
                NSString *addressName = [[NSString stringWithUTF8String:CHECKCSTR(temp_addr->ifa_name)] lowercaseString];
                NSString *addressIp = [NSString stringWithUTF8String:CHECKCSTR(inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr))];
                if([addressName length]==0 || [addressIp length]==0)
                {
                    //SDK_DEBUG_LOG("Name or ip is empty, name = " << [addressName UTF8String] << ", ip = " << [addressIp UTF8String]);
                    continue;
                }
                if ([addressName rangeOfString:@"tap"].length != 0 ||
                    [addressName rangeOfString:@"tun"].length != 0 ||//IPSec
                    [addressName rangeOfString:@"ppp"].length != 0) {//pptp
                    //SDK_DEBUG_LOG("vpn name = " << [addressName UTF8String]<<", ip = " << [addressIp UTF8String]);
                    [addressDic setObject:addressIp forKey:@"vpn"];
                }
                else{
                    [addressDic setObject:addressIp forKey:addressName];
                }
            }
            else if (temp_addr->ifa_addr->sa_family == AF_INET6){ // ipv6
                // todo: IPV6
            }
            
            temp_addr = temp_addr->ifa_next;
        }
    }
    freeifaddrs(interfaces);
    
    return addressDic;
}

+ (NSString *)getLocalIPAddress {
    NSString *address = @"";
    
    NSDictionary* addressDic = [ECSUtils allLocalIpAddress];
    
    //SDK_DEBUG_LOG("All ip address = " << [[addressDic description] UTF8String]);
    
    NSString *wifiConnectionAd = [addressDic objectForKey:@"en0"]; //from wifi
    NSString *wifiConnectionAd1 = [addressDic objectForKey:@"en1"]; //from wifi
    NSString *cellPhoneConnectionAd = [addressDic objectForKey:@"pdp_ip0"]; //from cell phone connection
    //        NSString *vpnConnectionAd = [addressDic objectForKey:@"utun0"]; // from vpn IPSec
    //        if (0 == [vpnConnectionAd length]) {
    //            vpnConnectionAd = [addressDic objectForKey:@"ppp0"];//vpn pptp
    //        }
    NSString *vpnConnectionAd = [addressDic objectForKey:@"vpn"];
    
    if ([vpnConnectionAd length] != 0) {
        address = vpnConnectionAd;
    }
    else if ([wifiConnectionAd length]!=0)
    {
        address = wifiConnectionAd;
    }
    else if ([cellPhoneConnectionAd length]!=0)  //from cellphone connection
    {
        address = cellPhoneConnectionAd;
    }
    else if ([wifiConnectionAd1 length] != 0) {
        address = wifiConnectionAd1;
    }
    else{
        address = @"";
    }
    //SDK_DEBUG_LOG("Sip connection using local address = " << [address UTF8String]);
    // Free memory
    
    return address;
}


#pragma mark -
#pragma mark 数据缓冲管理

static NSMutableDictionary * s_cacheDataDict = nil;

#define CACHE_TYPE_KEY(type) ([NSString stringWithFormat:@"cache-%d", (type)])

+ (NSMutableDictionary *)cacheDataDict
{
	if (nil == s_cacheDataDict) 
	{
		s_cacheDataDict = [[NSMutableDictionary alloc] init];
	}
	return s_cacheDataDict;
}

+ (void)cacheData:(id)data withKey:(NSString *)key withType:(CacheDataType)type
{
	if (nil == data || [key length] == 0) 
	{
		return;
	}
	NSMutableDictionary * cache = [[ECSUtils cacheDataDict] objectForKey:CACHE_TYPE_KEY(type)];
	if (nil == cache) 
	{
		cache = [[NSMutableDictionary alloc] init];
		[[ECSUtils cacheDataDict] setObject:cache forKey:CACHE_TYPE_KEY(type)];
	}
	
	[cache setObject:data forKey:key];
}

+ (id)dataFromCacheForKey:(NSString *)key forType:(CacheDataType)type
{
	if ([key length] == 0) 
	{
		return nil;
	}
	NSMutableDictionary * cache = [[ECSUtils cacheDataDict] objectForKey:CACHE_TYPE_KEY(type)];
	if (nil == cache) 
	{
		return nil;
	}
	return [cache objectForKey:key];
}

+ (void)removeDataFromCacheForKey:(NSString *)key forType:(CacheDataType)type
{
	if ([key length] == 0) 
	{
		return;
	}
	NSMutableDictionary * cache = [[ECSUtils cacheDataDict] objectForKey:CACHE_TYPE_KEY(type)];
	if (nil == cache) 
	{
		return;
	}
	[cache removeObjectForKey:key];
}

+ (NSInteger)cacheDataCountForType:(CacheDataType)type
{
	NSMutableDictionary * cache = [[ECSUtils cacheDataDict] objectForKey:CACHE_TYPE_KEY(type)];
	if (nil == cache) 
	{
		return 0;
	}
	return [cache count];
}

+ (NSArray *)cachedDataForType:(CacheDataType)type
{
	NSMutableDictionary * cache = [[ECSUtils cacheDataDict] objectForKey:CACHE_TYPE_KEY(type)];
	return (nil == cache) ? nil : [cache allValues];
}

+ (void)cleanCacheDataForType:(CacheDataType)type
{
	[[ECSUtils cacheDataDict] removeObjectForKey:CACHE_TYPE_KEY(type)];
}

+ (void)cleanAllCacheData
{
	[[ECSUtils cacheDataDict] removeAllObjects];
}

#pragma mark -
#pragma mark 保存枚举值调试信息

static NSMutableDictionary * s_enumDescriptions = nil;

+ (NSMutableDictionary *)enumDescriptions
{
	if (nil == s_enumDescriptions) 
	{
		s_enumDescriptions = [[NSMutableDictionary alloc] init];
	}
	return s_enumDescriptions;
}

+ (void)addEnumDescription:(NSString *)desc forEnum:(NSInteger)enumValue forType:(EnumDescType)type;
{
	if (nil == desc) 
	{
		return;
	}
	[[ECSUtils enumDescriptions] setObject:desc	forKey:[NSString stringWithFormat:@"%d-%ld", type, (long)enumValue]];
}

+ (NSString *)enumDescription:(NSInteger)enumValue forType:(EnumDescType)type
{
	return [ECSUtils notNilString:[[ECSUtils enumDescriptions] objectForKey:[NSString stringWithFormat:@"%d-%ld", type, (long)enumValue]]];
}

+ (void)cleanAllEnumDescriptions
{
	if (nil != s_enumDescriptions) 
	{
		s_enumDescriptions = nil;
	}
}

+ (void)addEnumDescription:(NSString *)desc forEnum:(NSInteger)enumValue forIdentity:(const char *)identity {
	if (nil == desc || NULL == identity) 
	{
		return;
	}
	[[ECSUtils enumDescriptions] setObject:desc	forKey:[NSString stringWithFormat:@"%s-%ld", identity, (long)enumValue]];
}

+ (NSString *)enumDescription:(NSInteger)enumValue forIdentity:(const char *)identity {
	if (NULL == identity) {
		return @"";
	}
	return [ECSUtils notNilString:[[ECSUtils enumDescriptions] objectForKey:[NSString stringWithFormat:@"%s-%ld", identity, (long)enumValue]]];
}

@end

@implementation NSString (NSStringExtend)

- (NSString *)substringToSeparator:(NSString *)separator {
	NSArray * comps = [self componentsSeparatedByString:separator];
	if (nil != comps && [comps count] > 0) {
		return [comps objectAtIndex:0];
	}
	return self;
}

- (NSString *)substringFromSeparator:(NSString *)separator {
	NSArray * comps = [self componentsSeparatedByString:separator];
	if (nil != comps && [comps count] > 0) {
		return [comps lastObject];
	}
	return self;
}

@end

@implementation NSString (NSStringDomain)

- (BOOL)isIPAddress
{
    if (0 == self.length) {
        return NO;
    }
    // 判断ip地址的正则表达
    NSString *regexIP = @"^((25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])\\.){3}(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])$";//NSString *regex = @"([a-zA-Z]{1,63}|[a-zA-Z0-9\\.]{2,63})"; // TODO need refine this regular exporession.
    NSPredicate *preIP = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regexIP];
    return [preIP evaluateWithObject:self];
}

- (BOOL)isDomainAddress
{
    if (0 == self.length) {
        return NO;
    }
    NSString *regexISIP = @"[0-9//.]+";
    NSPredicate *preISIP = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regexISIP];
    // 判断是否是纯数字，如果是，则不符合域名个规则
    if ([preISIP evaluateWithObject:self]) {
        return NO;
    }
    // 判断域名的正则表达
    NSString *regexDomain = @"[a-zA-Z0-9][-a-zA-Z0-9]{0,62}(\\.[a-zA-Z0-9][-a-zA-Z0-9]{0,62})+\\.?";//NSString *regex = @"([a-zA-Z]{1,63}|[a-zA-Z0-9\\.]{2,63})"; // TODO need refine this regular exporession.
    NSPredicate *preDomain = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regexDomain];
    return [preDomain evaluateWithObject:self];
}

@end


@implementation NSMutableArray (UniqueModify)

- (void)addUniqueObject:(id)anObject {
	if ([self containsObject:anObject])
		return;
	
	[self addObject:anObject];
}

- (void)removeUniqueObject:(id)anObject {
	if ([self containsObject:anObject]) {
		[self removeObject:anObject];
	}
}

- (void)addNotNilObject:(id)anObject {
	if (nil != anObject) {
		[self addObject:anObject];
	}
}

- (void)removeNotNilObject:(id)anObject {
	if (nil != anObject) {
		[self removeObject:anObject];
	}
}

@end

@implementation NSFileManager (FileManagerExtend)

- (BOOL)checkDirectoryAndCreateIfNotExist:(NSString *)filePath {
	if ([filePath length] == 0) {
		//SDK_WRN_LOG("File path is null.");
		return NO;
	}
	
	if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
		return YES;
	}
	
	if (![[NSFileManager defaultManager] createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:NULL]) {
		//SDK_WRN_LOG(@"File not exists at path (" << [filePath UTF8String] << "), and create file failed.");
		return NO;
	}
	
	return YES;
}

@end
