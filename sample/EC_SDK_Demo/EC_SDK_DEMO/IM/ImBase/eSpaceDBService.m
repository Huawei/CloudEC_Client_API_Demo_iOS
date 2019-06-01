//
//  eSpaceIOSService.m
//  eSpaceIOSSDK
//
//  Created by wangzengyi on 16/1/28.
//  Copyright © 2016年 HuaWei. All rights reserved.
//

#import "eSpaceDBService.h"

@implementation eSpaceDBService

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static eSpaceDBService *service;
    dispatch_once(&onceToken, ^{
        service = [[eSpaceDBService alloc] init];
    });
    
    return service;
}
@end
