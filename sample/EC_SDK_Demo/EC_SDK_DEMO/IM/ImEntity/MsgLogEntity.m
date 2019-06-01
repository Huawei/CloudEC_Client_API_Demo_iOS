//
//  MsgLogEntity.m
//  eSpace
//
//  Created by wangxiangyang on 15/8/31.
//  Copyright (c) 2015年 www.huawei.com. All rights reserved.
//

#import "MsgLogEntity.h"


@implementation MsgLogEntity

- (BOOL)supportAction:(NSInteger)action {
    if (action == ESpaceMessageCopy) {
        return YES;
    }
    return NO;
}

@end
