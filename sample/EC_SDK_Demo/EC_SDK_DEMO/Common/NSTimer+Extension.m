//
//  NSTimer+Extension.m
//  EC_SDK_DEMO
//
//  Created by huawei on 2019/9/18.
//  Copyright © 2019 cWX160907. All rights reserved.
//

#import "NSTimer+Extension.h"

@implementation NSTimer(Convenience)

+ (NSTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)interval
                                    repeats:(BOOL)repeats
                                   callback:(HYBVoidBlock)callback {
    return [NSTimer scheduledTimerWithTimeInterval:interval
                                            target:self
                                          selector:@selector(onTimerUpdateBlock:)
                                          userInfo:[callback copy]
                                           repeats:repeats];
}

+ (NSTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)interval
                                      count:(NSInteger)count
                                   callback:(HYBVoidBlock)callback {
    NSDictionary *userInfo = @{@"callback"     : [callback copy],
                               @"count"        : @(count)};
    return [NSTimer scheduledTimerWithTimeInterval:interval
                                            target:self
                                          selector:@selector(onTimerUpdateCountBlock:)
                                          userInfo:userInfo
                                           repeats:YES];
}

+ (void)onTimerUpdateBlock:(NSTimer *)timer {
    HYBVoidBlock block = timer.userInfo;
    
    if (block) {
        block();
    }
}

+ (void)onTimerUpdateCountBlock:(NSTimer *)timer {
    static NSUInteger currentCount = 0;
    
    NSDictionary *userInfo = timer.userInfo;
    HYBVoidBlock callback = userInfo[@"callback"];
    NSNumber *count = userInfo[@"count"];
    
    if (count.integerValue <= 0) {
        if (callback) {
            callback();
        }
    } else {
        if (currentCount < count.integerValue) {
            currentCount++;
//            if (callback) {
//                callback();
//            }
        } else {
            currentCount = 0;
            if (callback) {
                callback();
            }
            [timer unfireTimer];
        }
    }
}

- (void)fireTimer {
    [self setFireDate:[NSDate distantPast]];
}

- (void)unfireTimer {
    [self setFireDate:[NSDate distantFuture]];
}

@end
