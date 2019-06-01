//
//  ECSBaseService.m
//  eSpaceIOSSDK
//
//  Created by xieshuotao on 1/20/16.
//  Copyright © 2016 huawei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ECSBaseService.h"

@interface ECSBaseService()
@property (nonatomic, strong) NSMutableDictionary* notifyMap;
@end

@implementation ECSBaseService

- (id) init {
    if (self = [super init]) {
        self.notifyMap = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)internalInit {
    
}

- (void) bindNotificationCode:(NSInteger) mCode withSelector:(SEL) aSelector {
    [self bindNotificationCode:mCode withSelector:aSelector withPriority:NSOperationQueuePriorityNormal];
}

- (void) bindNotificationCode:(NSInteger) mCode withSelector:(SEL) aSelector withPriority:(NSOperationQueuePriority) p {
    NSValue* selVal = [NSValue valueWithPointer:aSelector];
    NSNumber* priority = [NSNumber numberWithInteger:p];
    NSNumber* command = [NSNumber numberWithInteger:mCode];
    NSArray* params = [NSArray arrayWithObjects:selVal, priority, nil];
    
    [self.notifyMap setObject:params forKey:command];
}

- (void) bindNotificationCode:(NSInteger)mCode withMsgType:(NSInteger)msgType withSelector:(SEL)aSelector withPriority:(NSOperationQueuePriority)p {
    NSValue* selVal = [NSValue valueWithPointer:aSelector];
    NSNumber* priority = [NSNumber numberWithInteger:p];
    NSNumber* command = [NSNumber numberWithInteger:mCode];
    NSNumber* type = [NSNumber numberWithInteger:msgType];
    NSArray* params = [NSArray arrayWithObjects:selVal, priority, type, nil];
    
    [self.notifyMap setObject:params forKey:command];
}

- (void) bindNotificationCode:(NSInteger)mCode withMsgType:(NSInteger)msgType withSelector:(SEL)aSelector {
    [self bindNotificationCode:mCode withMsgType:msgType withSelector:aSelector withPriority:NSOperationQueuePriorityNormal];
}
@end

