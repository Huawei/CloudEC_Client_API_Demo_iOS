//
//  NetworkUtils.m
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

#import "NetworkUtils.h"

NSString *const NETWORK_STATUS_CHAGNE_NOTIFY = @"NETWORK_STATUS_CHAGNE_NOTIFY";

@interface NetworkUtils()

@property (nonatomic) Reachability *internetReachability;

@end

@implementation NetworkUtils

/**
 *This method is used to creat single instance of this class
 *创建该类的单例
 */
+(instancetype)shareInstance
{
    static NetworkUtils *_networkUtils = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _networkUtils = [[NetworkUtils alloc] init];
    });
    return _networkUtils;
}

/**
 *This method is used to init this class
 *初始化方法
 */
-(instancetype)init
{
    if (self = [super init])
    {
        [self startUpNetWorkStatusMonitoring];
    }
    return self;
}

/**
 *This method is used to start up network status monitoring
 *开启网络状态监测
 */
-(void)startUpNetWorkStatusMonitoring
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    self.internetReachability = [Reachability reachabilityForInternetConnection];
    [self.internetReachability startNotifier];
}

/**
 *This method is used to post notification about current network
 *通知当前的网络状态
 */
- (void) reachabilityChanged:(NSNotification *)note
{
    NetworkStatus netStatus = [self.internetReachability currentReachabilityStatus];
    [[NSNotificationCenter defaultCenter] postNotificationName:NETWORK_STATUS_CHAGNE_NOTIFY object:[NSNumber numberWithInteger:netStatus]];
}

/**
 *This method is used to get current network status
 *获取当前的网络状态
 */
-(NetworkStatus)getCurrentNetworkStatus
{
    NetworkStatus netStatus = [self.internetReachability currentReachabilityStatus];
    return netStatus;
}

/**
 *This method is used to remove observer of notification kReachabilityChangedNotification
 *移除对事件kReachabilityChangedNotification的监听
 */
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
}

@end
