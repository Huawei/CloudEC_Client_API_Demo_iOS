//
//  CommonUtils.m
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

#import "CommonUtils.h"
#include <netdb.h>
#include <net/if.h>
#include <ifaddrs.h>
#include <arpa/inet.h>
#include <dlfcn.h>
#include <sys/sysctl.h>

#define IOS_CELLULAR    @"pdp_ip0"
#define IOS_WIFI        @"en0"
#define IOS_VPN         @"utun0"
#define IP_ADDR_IPv4    @"ipv4"
#define IP_ADDR_IPv6    @"ipv6"

#define CHECKCSTR(str) (((str) == NULL) ? "" : (str))
#define CONSTVALUEZERO               0
#define CONSTVALUEONE                1
#define CONSTVALUETWO                2
#define CONSTVALUETHREE              3
#define ASCNUMZERO                   48
#define ASCNUMNINE                   57
#define ADDRESSBOARD                 128
#define ASCPOINT                     46
#define MAX_PORT        65535

@implementation CommonUtils

/**
 *This method is used to get single instance of this class
 *获取该类唯一实例
 */
+(instancetype)shareInstance
{
    static CommonUtils *_commonUtils = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _commonUtils = [[CommonUtils alloc] init];
    });
    return _commonUtils;
}

/**
 *This method is used to transform UTC date to local date
 *将UTC时间转为本地时间
 @param utcDate UTC date
 @return string
 */
+(NSString *)getLocalDateFormateUTCDate:(NSString *)utcDate
{
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    //输入格式
//    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
//    //    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
//    //    [dateFormatter setTimeZone:timeZone];
//    NSString *dateString = [dateFormatter stringFromDate:utcDate];
//    NSLog(@"dateString-- :%@",dateString);
//    return dateString;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //input
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    [dateFormatter setTimeZone:timeZone];
    NSDate *dateFormatted = [dateFormatter dateFromString:utcDate];
    //output
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSTimeZone *localTimeZone = [NSTimeZone localTimeZone];
    [dateFormatter setTimeZone:localTimeZone];
    NSString *dateString = [dateFormatter stringFromDate:dateFormatted];
    return dateString;
}

/**
 *This method is used to save user config
 *保存用户数据
 *@param anyValue value
 *@param key destination string
 */
+(void)userDefaultSaveValue:(id)anyValue forKey:(NSString *)key
{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setObject:anyValue forKey:key];
    [userDefault synchronize];
}

+(id)getUserDefaultValueWithKey:(NSString *)key
{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    id anyValue = [userDefault objectForKey:key];
    return anyValue;
}

/**
 *This method is used to decode string from base64
 *对base64编码的字符串进行解码
 *@param base64 destination string
 *@return string
 */
+ (NSString *)textFromBase64String:(NSString *)base64
{
    NSData *data = [[NSData alloc] initWithBase64EncodedString:base64 options:0];
    NSString *text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return text;
}

/**
 *This method is used to check is VPN connect or not
 *检查vpn是否连接
 *@return YES or NO
 */
+(BOOL)checkIsVPNConnect
{
    NSDictionary *addresses = [CommonUtils getIPAddresses];
    DDLogInfo(@"all addresses: %@", addresses);
    NSString *pppIpv4 = addresses[@"utun1/ipv4"];
    DDLogInfo(@"pppIpv4:%@",pppIpv4);
    DDLogInfo(@"current have ppp0:%d",pppIpv4.length > 0 ? YES : NO);
    return pppIpv4.length > 0 ? YES : NO;
}

/**
 *This method is used to get local IP address
 *获取本地ip地址
 @param isVpnAddress YES or NO
 @return YES or NO
 */
+(NSString *)getLocalIpAddressWithIsVPN:(BOOL)isVpnAddress
{
    NSString *tempIP = @"";
    if (isVpnAddress)
    {
        NSDictionary *addresses = [CommonUtils getIPAddresses];
        NSString *pppIpv4 = addresses[@"utun1/ipv4"];
        tempIP = pppIpv4;
        DDLogInfo(@"pppipv4: %@",pppIpv4);
    }
    else
    {
        tempIP = [CommonUtils getIPAddress:YES];
    }
    DDLogInfo(@"tempIP---- :%@",tempIP);
    return tempIP;
}

/**
 *This method is used to get ip address
 *获取ip地址
 */
+ (NSString *)getIPAddress:(BOOL)preferIPv4
{
    NSArray *searchArray = preferIPv4 ?
    @[ IOS_VPN @"/" IP_ADDR_IPv4, IOS_VPN @"/" IP_ADDR_IPv6, IOS_WIFI @"/" IP_ADDR_IPv4, IOS_WIFI @"/" IP_ADDR_IPv6, IOS_CELLULAR @"/" IP_ADDR_IPv4, IOS_CELLULAR @"/" IP_ADDR_IPv6 ] :
    @[ IOS_VPN @"/" IP_ADDR_IPv6, IOS_VPN @"/" IP_ADDR_IPv4, IOS_WIFI @"/" IP_ADDR_IPv6, IOS_WIFI @"/" IP_ADDR_IPv4, IOS_CELLULAR @"/" IP_ADDR_IPv6, IOS_CELLULAR @"/" IP_ADDR_IPv4 ] ;
    
    NSDictionary *addresses = [CommonUtils getIPAddresses];
    NSLog(@"addresses: %@", addresses);
    NSString *pppIpv4 = addresses[@"ppp0/ipv4"];
    NSLog(@"pppIpv4:%@",pppIpv4);
    __block NSString *address;
    [searchArray enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop)
     {
         address = addresses[key];
         //筛选出IP地址格式
         if([CommonUtils isValidateIP:address])
         {
             *stop = YES;
         }
     } ];
    
    if ([address length] == 0)
    {
        address = [CommonUtils getIPAddresses][@"en1/ipv4"];
    }
    NSLog(@"address:%@",address);
    return address ? address : @"0.0.0.0";
}

/**
 *This method is used to judge whether ip address is valid
 *判断ip地址是否有效
 */
+ (BOOL)isValidateIP:(NSString *)ipAddress
{
    if (ipAddress.length == 0)
    {
        return NO;
    }
    NSString *urlRegEx = @"^([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\."
    "([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\."
    "([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\."
    "([01]?\\d\\d?|2[0-4]\\d|25[0-5])$";
    
    NSError *error;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:urlRegEx options:0 error:&error];
    
    if (regex != nil)
    {
        NSTextCheckingResult *firstMatch=[regex firstMatchInString:ipAddress options:0 range:NSMakeRange(0, [ipAddress length])];
        
        if (firstMatch)
        {
            NSRange resultRange = [firstMatch rangeAtIndex:0];
            NSString *result=[ipAddress substringWithRange:resultRange];
            DDLogInfo(@"isValidatIP result:%@",result);
            return YES;
        }
    }
    return NO;
}

/**
 *This method is used to get ip address
 *获取ip地址
 */
+ (NSDictionary *)getIPAddresses
{
    NSMutableDictionary *addresses = [NSMutableDictionary dictionaryWithCapacity:8];
    
    // retrieve the current interfaces - returns 0 on success
    struct ifaddrs *interfaces;
    if(!getifaddrs(&interfaces))
    {
        // Loop through linked list of interfaces
        struct ifaddrs *interface;
        for(interface=interfaces; interface; interface=interface->ifa_next)
        {
            if(!(interface->ifa_flags & IFF_UP) /* || (interface->ifa_flags & IFF_LOOPBACK) */ )
            {
                continue; // deeply nested code harder to read
            }
            const struct sockaddr_in *addr = (const struct sockaddr_in*)interface->ifa_addr;
            char addrBuf[ MAX(INET_ADDRSTRLEN, INET6_ADDRSTRLEN) ];
            if(addr && (addr->sin_family==AF_INET || addr->sin_family==AF_INET6))
            {
                NSString *name = [NSString stringWithUTF8String:interface->ifa_name];
                NSString *type;
                if(addr->sin_family == AF_INET)
                {
                    if(inet_ntop(AF_INET, &addr->sin_addr, addrBuf, INET_ADDRSTRLEN))
                    {
                        type = IP_ADDR_IPv4;
                    }
                }
                else
                {
                    const struct sockaddr_in6 *addr6 = (const struct sockaddr_in6*)interface->ifa_addr;
                    if(inet_ntop(AF_INET6, &addr6->sin6_addr, addrBuf, INET6_ADDRSTRLEN))
                    {
                        type = IP_ADDR_IPv6;
                    }
                }
                if(type)
                {
                    NSString *key = [NSString stringWithFormat:@"%@/%@", name, type];
                    addresses[key] = [NSString stringWithUTF8String:addrBuf];
                }
            }
        }
        // Free memory
        freeifaddrs(interfaces);
    }
    return [addresses count] ? addresses : nil;
}

/**
 *This method is used to check string is empty or not
 *判断字符串是否为非空
 *@param string destination string
 *@return YES or NO
 */
+(BOOL)checkIsNotEmptyString:(NSString *)string
{
    BOOL isNotEmpty = NO;
    if (string == nil || string == NULL || [string isEqualToString:@""])
    {
        isNotEmpty = NO;
    }
    else
    {
        isNotEmpty = YES;
    }
    return isNotEmpty;
}

/**
 *This method is used to set view controller orientation
 *旋转屏幕
 *@param toOrientation
 */
+ (void)setToOrientation:(UIDeviceOrientation)toOrientation
{
    //旋转到toOrientation方向之前，需要先将系统的orientation方向设置成当前界面的方向,确保触发旋转动作
    if (toOrientation == [[UIDevice currentDevice] orientation] && toOrientation == UIDeviceOrientationPortrait)
    {
        [[UIDevice currentDevice] setValue:[NSNumber numberWithInt:UIDeviceOrientationLandscapeLeft] forKey:@"orientation"];
    }
    else if (toOrientation == [[UIDevice currentDevice] orientation]
             && (toOrientation == UIDeviceOrientationLandscapeLeft || toOrientation == UIDeviceOrientationLandscapeRight))
    {
        [[UIDevice currentDevice] setValue:[NSNumber numberWithInt:UIDeviceOrientationPortrait] forKey:@"orientation"];
    }
    
    [[UIDevice currentDevice] setValue:[NSNumber numberWithInt:toOrientation] forKey:@"orientation"];
}

/**
 *This method is used to get Image from disk
 *从图片文件夹获取图片
 *@param imageFile image file path
 *@return image
 */
+ (UIImage *) attachImageFile:(NSString*) imageFile {
//    UIImage* image = [[ESpaceImageCache sharedInstance] imageWithKey:imageFile];
//    if (image) {
//        return image;
//    } else {
//        NSData* imageData = [[NSFileManager defaultManager] contentsAtPath:imageFile];
//        UIImage* image = nil;
//        if (imageData) {
//            image = [UIImage imageWithData:imageData];
//            return image;
//        }
//    }
    return nil;
}

@end
