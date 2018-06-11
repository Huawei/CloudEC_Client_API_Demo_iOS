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
	NotReachable = 0,
	ReachableViaWiFi,
	ReachableViaWWAN
} NetworkStatus;

#pragma mark IPv6 Support
//Reachability fully support IPv6.  For full details, see ReadMe.md.


extern NSString *kReachabilityChangedNotification;


@interface Reachability : NSObject

/**
 *This method is used to check the reachability of a given host name.
 *监测该名字的网络的状态
 */
+ (instancetype)reachabilityWithHostName:(NSString *)hostName;

/**
 *This method is used to check the reachability of a given IP address.
 *监测该ip地址的网络状态
 */
+ (instancetype)reachabilityWithAddress:(const struct sockaddr *)hostAddress;

/**
 *This method is used to checks whether the default route is available. Should be used by applications that do not connect to a particular host.
 *监测默认的路线网络是否可链接
 */
+ (instancetype)reachabilityForInternetConnection;


#pragma mark reachabilityForLocalWiFi
//reachabilityForLocalWiFi has been removed from the sample.  See ReadMe.md for more information.
//+ (instancetype)reachabilityForLocalWiFi;

/**
 *This method is used to start listening for reachability notifications on the current run loop.
 *开启监听当前回路网络状态通知
 */
- (BOOL)startNotifier;

/**
 *This method is used to stop listening for reachability notifications on the current run loop.
 *开启监听当前回路网络状态通知
 */
- (void)stopNotifier;

/**
 *This method is used to get current network status
 *获取当前网络的状态
 */
- (NetworkStatus)currentReachabilityStatus;

/**
 * This method is about WWAN may be available, but not active until a connection has been established. WiFi may require a connection for VPN on Demand.
 *业务进行需要网络已经链接
 */
- (BOOL)connectionRequired;

@end


