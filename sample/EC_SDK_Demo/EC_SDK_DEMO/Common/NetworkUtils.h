//
//  NetworkUtils.h
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

#import <Foundation/Foundation.h>
#import "Reachability.h"

extern NSString *const NETWORK_STATUS_CHAGNE_NOTIFY;    

@interface NetworkUtils : NSObject
/**
 NetworkUtils instance
 
 @return NetworkUtils value
 */
+(instancetype)shareInstance;
/**
 get current network state
 
 @return NetworkStatus value
 */
-(NetworkStatus)getCurrentNetworkStatus;

@end
