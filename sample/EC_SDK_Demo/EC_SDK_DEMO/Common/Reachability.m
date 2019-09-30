//
//  Reachability.m
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//
#import <arpa/inet.h>
#import <ifaddrs.h>
#import <netdb.h>
#import <sys/socket.h>
#import <netinet/in.h>

#import <CoreFoundation/CoreFoundation.h>

#import "Reachability.h"
#import <CoreTelephony/CTTelephonyNetworkInfo.h>

#pragma mark IPv6 Support
//Reachability fully support IPv6.  For full details, see ReadMe.md.


NSString *kReachabilityChangedNotification = @"kReachabilityChangedNotification";
NSString *kECSReachabilityParamKey = @"kECSReachabilityParamKey";

typedef  __attribute__((NSObject)) SCNetworkReachabilityRef ECSNetworkReachabilityRef;

@interface Reachability() {
//    BOOL _alwaysReturnLocalWiFiStatus; //default is NO
//    SCNetworkReachabilityRef _reachabilityRef;
    CFRunLoopRef _currentRunLoop;
}
@property (nonatomic, strong) ECSNetworkReachabilityRef reachabilityRef;
@property (nonatomic) BOOL alwaysReturnLocalWiFiStatus;
- (void) updateCurrentReachabilityStatus;
@end

static void ReachabilityCallback(SCNetworkReachabilityRef target, SCNetworkReachabilityFlags flags, void* info)
{
#pragma unused (target, flags)
    NSCAssert(info != NULL, @"info was NULL in ReachabilityCallback");
    
    @autoreleasepool {
        Reachability *noteObject = (__bridge Reachability *)info;
        BOOL bValidInfo = [noteObject isKindOfClass: [Reachability class]];
        NSCAssert(bValidInfo, @"info was wrong class in ReachabilityCallback");
//        ECSNetworkReachability* noteObject = (__bridge ECSNetworkReachability *)info;
        [noteObject updateCurrentReachabilityStatus];
        // Post a notification to notify the client that the network reachability changed.
//        if ([NSThread isMainThread]) {
//            [[NSNotificationCenter defaultCenter] postNotificationName: kReachabilityChangedNotification object: noteObject];
//        } else {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [[NSNotificationCenter defaultCenter] postNotificationName: kReachabilityChangedNotification object: noteObject];
//            });
//        }
    }
}

@implementation Reachability

@synthesize networkReachabilityFlags = _networkReachabilityFlags;
@synthesize currentReachabilityStatus = _currentReachabilityStatus;

- (SCNetworkReachabilityFlags) networkReachabilityFlags
{
    SCNetworkReachabilityFlags flags = 0;
    if (self.reachabilityRef) {
        SCNetworkReachabilityGetFlags(self.reachabilityRef, &flags);
    }
    return flags;
}

- (void)setHostName:(NSString *)hostName
{
    if (0 == hostName.length) {
        return;
    }
    
    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithName(NULL, [hostName UTF8String]);
    SCNetworkReachabilityFlags flags;
    if (SCNetworkReachabilityGetFlags(reachability, &flags))
    {
        _currentReachabilityStatus = [Reachability networkStatusForFlags:flags];
    }

    self.reachabilityRef = reachability;
    self.alwaysReturnLocalWiFiStatus = NO;
    if (NULL != reachability) {
        CFRelease(reachability);
        reachability = NULL;
    }
    
}

+ (instancetype)reachabilityWithHostName:(NSString *)hostName
{
    Reachability* returnValue = [[Reachability alloc] init];
    [returnValue setHostName:hostName];
    return returnValue;
}


+ (instancetype)reachabilityWithAddress:(const struct sockaddr *)hostAddress
{
    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (const struct sockaddr *)hostAddress);
    
    Reachability* returnValue = NULL;
    
    if (reachability != NULL)
    {
        returnValue = [[self alloc] init];
        if (returnValue != nil)
        {
            SCNetworkReachabilityFlags flags;
            if (SCNetworkReachabilityGetFlags(reachability, &flags))
            {
                returnValue->_currentReachabilityStatus = [self networkStatusForFlags:flags];
            }
            returnValue.reachabilityRef = reachability;
            returnValue.alwaysReturnLocalWiFiStatus = NO;
        }
        CFRelease(reachability);
    }
    return returnValue;
}



+ (instancetype)reachabilityForInternetConnection
{
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;
    
    return [self reachabilityWithAddress:(struct sockaddr*)&zeroAddress];
}


+ (instancetype)reachabilityForLocalWiFi
{
    struct sockaddr_in localWifiAddress;
    bzero(&localWifiAddress, sizeof(localWifiAddress));
    localWifiAddress.sin_len = sizeof(localWifiAddress);
    localWifiAddress.sin_family = AF_INET;
    
    // IN_LINKLOCALNETNUM is defined in <netinet/in.h> as
    localWifiAddress.sin_addr.s_addr = htonl(IN_LINKLOCALNETNUM);
    
    Reachability* returnValue = [self reachabilityWithAddress: (struct sockaddr*)&localWifiAddress];
    if (returnValue != NULL)
    {
        returnValue.alwaysReturnLocalWiFiStatus = YES;
    }
    
    
    return returnValue;
}


#pragma mark - Start and stop notifier

- (BOOL)startNotifier
{
    BOOL returnValue = NO;
    CFTypeRef cfSelf = (__bridge CFTypeRef)self;
    SCNetworkReachabilityContext context = {0, (void *)cfSelf, NULL, NULL, NULL};
    
    if (SCNetworkReachabilitySetCallback(self.reachabilityRef, ReachabilityCallback, &context))
    {
        _currentRunLoop = CFRunLoopGetCurrent();
        if (SCNetworkReachabilityScheduleWithRunLoop(self.reachabilityRef, _currentRunLoop, kCFRunLoopDefaultMode))
        {
            returnValue = YES;
        }
    }
    return returnValue;
}


- (void)stopNotifier
{
    if (self.reachabilityRef)
    {
        SCNetworkReachabilityUnscheduleFromRunLoop(self.reachabilityRef, _currentRunLoop, kCFRunLoopDefaultMode);
        
    }
    _currentRunLoop = NULL;
}


- (void)dealloc
{
    [self stopNotifier];
    self.reachabilityRef = nil;
}


#pragma mark - Network Flag Handling

+ (NetworkStatus)localWiFiStatusForFlags:(SCNetworkReachabilityFlags)flags
{
    NetworkStatus returnValue = ECSNotReachable;
    
    if ((flags & kSCNetworkReachabilityFlagsReachable) && (flags & kSCNetworkReachabilityFlagsIsDirect))
    {
        returnValue = ECSReachableViaWiFi;
    }
    
    return returnValue;
}


+ (NetworkStatus)networkStatusForFlags:(SCNetworkReachabilityFlags)flags
{
    if ((flags & kSCNetworkReachabilityFlagsReachable) == 0)
    {
        // The target host is not reachable.
        return ECSNotReachable;
    }
    
    NetworkStatus returnValue = ECSNotReachable;
    
    if ((flags & kSCNetworkReachabilityFlagsConnectionRequired) == 0)
    {
        /*
         If the target host is reachable and no connection is required then we'll assume (for now) that you're on Wi-Fi...
         */
        returnValue = ECSReachableViaWiFi;
    }
    
    if ((((flags & kSCNetworkReachabilityFlagsConnectionOnDemand ) != 0) ||
         (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0))
    {
        /*
         ... and the connection is on-demand (or on-traffic) if the calling application is using the CFSocketStream or higher APIs...
         */
        
        if ((flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0)
        {
            /*
             ... and no [user] intervention is needed...
             */
            returnValue = ECSReachableViaWiFi;
        }
    }
    
    if ((flags & kSCNetworkReachabilityFlagsIsWWAN) == kSCNetworkReachabilityFlagsIsWWAN)
    {
        /*
         ... but WWAN connections are OK if the calling application is using the CFNetwork APIs.
         */
//        if ((flags & kSCNetworkReachabilityFlagsTransientConnection) == kSCNetworkReachabilityFlagsTransientConnection) {
//
//            returnValue = ECSReachableVia3G;
//
//            if((flags & kSCNetworkReachabilityFlagsConnectionRequired) == kSCNetworkReachabilityFlagsConnectionRequired) {
//
//                returnValue = ECSReachableVia2G;
//
//            }
//
//        }
//        else {
//            returnValue = ECSReachableViaWWAN;
//        }
        
        
        
        
        CTTelephonyNetworkInfo *phonyNetwork = [[CTTelephonyNetworkInfo alloc] init];
        NSString *currentStr = phonyNetwork.currentRadioAccessTechnology;
        if (currentStr) {
            if ([currentStr isEqualToString:CTRadioAccessTechnologyLTE]) {
                return ECSReachableVia4G;
            }else if ([currentStr isEqualToString:CTRadioAccessTechnologyGPRS]|| [currentStr isEqualToString:CTRadioAccessTechnologyEdge]){
                return ECSReachableVia2G;
            }else{
                return ECSReachableVia3G;
            }
        }
        
        if ((flags & kSCNetworkReachabilityFlagsTransientConnection) == kSCNetworkReachabilityFlagsTransientConnection) {
            if((flags & kSCNetworkReachabilityFlagsConnectionRequired) == kSCNetworkReachabilityFlagsConnectionRequired) {
                return ECSReachableVia2G;
            }
            return ECSReachableVia3G;
        }
        return ECSReachableViaWWAN;
        
    }
    
    return returnValue;
}


- (BOOL)connectionRequired
{
    NSAssert(self.reachabilityRef, @"connectionRequired called with NULL reachabilityRef");
    SCNetworkReachabilityFlags flags;
    
    if (SCNetworkReachabilityGetFlags(self.reachabilityRef, &flags))
    {
        return (flags & kSCNetworkReachabilityFlagsConnectionRequired);
    }
    
    return NO;
}

- (void)updateCurrentReachabilityStatus {
    
    NetworkStatus returnValue = ECSNotReachable;
    SCNetworkReachabilityFlags flags;
    
    if (SCNetworkReachabilityGetFlags(self.reachabilityRef, &flags))
    {
        if (self.alwaysReturnLocalWiFiStatus)
        {
            returnValue = [Reachability localWiFiStatusForFlags:flags];
        }
        else
        {
            returnValue = [Reachability networkStatusForFlags:flags];
        }
    }
    if (_currentReachabilityStatus != returnValue) {
        [self willChangeValueForKey:@"currentReachabilityStatus"];
        _currentReachabilityStatus = returnValue;
        [self didChangeValueForKey:@"currentReachabilityStatus"];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        DDLogDebug(@"network status: %lld",(long long)returnValue);
        NSDictionary *userInfo = @{kECSReachabilityParamKey : [NSNumber numberWithInteger:returnValue]};
        [[NSNotificationCenter defaultCenter] postNotificationName:kReachabilityChangedNotification
                                                            object:nil
                                                          userInfo:userInfo];
    });
}

- (NetworkStatus)currentReachabilityStatus
{
    return _currentReachabilityStatus;
}


#pragma mark - netType

- (NSString *)cellularNetType
{
    NSString *netconnType = @"";
    CTTelephonyNetworkInfo *info = [[CTTelephonyNetworkInfo alloc] init];
    NSString *currentStatus = info.currentRadioAccessTechnology;
    
    NSUInteger judgeStringLength = [@"CTRadioAccessTechnology" length];
    
    if (currentStatus.length > judgeStringLength)
    {
        netconnType = [currentStatus substringFromIndex:judgeStringLength - 1];
    }
    /*if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyGPRS"]) {
        netconnType = @"GPRS";
    }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyEdge"]) {
        netconnType = @"2.75G EDGE";
    }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyWCDMA"]){
        netconnType = @"WCDMA";
    }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyHSDPA"]){
        netconnType = @"3.5G HSDPA";
    }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyHSUPA"]){
        netconnType = @"3.5G HSUPA";
    }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyCDMA1x"]){
        netconnType = @"2G";
    }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyCDMAEVDORev0"]){
        netconnType = @"3G";
    }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyCDMAEVDORevA"]){
        netconnType = @"3G";
    }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyCDMAEVDORevB"]){
        netconnType = @"3G";
    }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyeHRPD"]){
        netconnType = @"HRPD";
    }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyLTE"]){
        netconnType = @"LTE";
    }*/
    DDLogInfo(@"netconnType is:%@", netconnType);
    return netconnType;
}



@end
