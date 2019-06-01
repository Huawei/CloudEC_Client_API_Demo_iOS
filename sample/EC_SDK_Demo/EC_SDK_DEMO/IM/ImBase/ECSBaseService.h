//
//  ECSBaseService.h
//  eSpaceIOSSDK
//
//  Created by yemingxing on 3/4/15.
//  Copyright (c) 2015 huawei. All rights reserved.
//

#ifndef eSpaceIOSSDK_ECSBaseService_h
#define eSpaceIOSSDK_ECSBaseService_h

@interface ECSBaseService : NSObject
@property (nonatomic, strong, readonly) NSMutableDictionary* notifyMap;
/*
 绑定接收的notfiy到本实例的selector一个mCode只能对应一个selector（不同服务实例可以重复注册一个mCode），
 selector只能有一个参数，并且参数类型为mip::msg::BaseMsg*或其子类指针，注意此selector会被异步执行，
 priority指定异步过程优先级，默认为NSOperationQueuePriorityNormal
 */
- (void) bindNotificationCode:(NSInteger) mCode withSelector:(SEL) aSelector withPriority:(NSOperationQueuePriority) priority;

- (void) bindNotificationCode:(NSInteger) mCode withSelector:(SEL) aSelector;

- (void) bindNotificationCode:(NSInteger)mCode withMsgType:(NSInteger)msgType withSelector:(SEL)aSelector withPriority:(NSOperationQueuePriority)p;

- (void) bindNotificationCode:(NSInteger)mCode withMsgType:(NSInteger)msgType withSelector:(SEL)aSelector;

- (void) internalInit;
@end

#endif
