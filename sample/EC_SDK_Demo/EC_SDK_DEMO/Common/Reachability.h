//
//  Reachability.h
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

#import <Foundation/Foundation.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import <netinet/in.h>


typedef enum : NSInteger {
	ECSNotReachable = 0,
    ECSReachableViaWiFi,
    ECSReachableVia2G,
    ECSReachableVia3G,
    ECSReachableVia4G,
    ECSReachableViaWWAN
} NetworkStatus;

#pragma mark IPv6 Support
//Reachability fully support IPv6.  For full details, see ReadMe.md.


extern NSString *kReachabilityChangedNotification;
extern NSString *kECSReachabilityParamKey;

@interface Reachability : NSObject

/*!
 * Use to check the reachability of a given host name.
 */
+ (instancetype)reachabilityWithHostName:(NSString *)hostName;

/*!
 * Use to check the reachability of a given IP address.
 */
+ (instancetype)reachabilityWithAddress:(const struct sockaddr *)hostAddress;

/*!
 * Checks whether the default route is available. Should be used by applications that do not connect to a particular host.
 */
+ (instancetype)reachabilityForInternetConnection;

/*!
 * Checks whether a local WiFi connection is available.
 */
+ (instancetype)reachabilityForLocalWiFi;

/*!
 * Start listening for reachability notifications on the current run loop.
 */
- (BOOL)startNotifier;
- (void)stopNotifier;
- (void)setHostName:(NSString *)hostName;

@property(readonly, assign, nonatomic) NetworkStatus currentReachabilityStatus;
@property(readonly, assign, nonatomic) SCNetworkReachabilityFlags networkReachabilityFlags;

/*!
 * WWAN may be available, but not active until a connection has been established. WiFi may require a connection for VPN on Demand.
 */
- (BOOL)connectionRequired;


/**
 获取当前蜂窝网络下的网络类型

 @return 当前蜂窝网络下的网络类型字符串描述
 */
- (NSString *)cellularNetType;

@end


