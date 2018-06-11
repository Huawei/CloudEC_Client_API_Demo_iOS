//
//  Initializer.h
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

#import <Foundation/Foundation.h>
#import "Notification.h"

typedef NS_ENUM(NSUInteger, TUP_MODULE)
{
    LOGIN_UPORTAL_MODULE,      // login uportal module
    CALL_SIP_MODULE,           // call sip module
    CALL_CTD_MODULE,           // call ctd module
    CONF_MODULE,               // conference module
    CONTACT_MODULE             // contact module
};

@protocol TupLoginNotification <NSObject>

/**
 * This method is used to deel login event callback and call sip event callback from service
 * 分发登陆业务和呼叫sip业务相关回调
 *@param module TUP_MODULE
 *@param notification Notification
 */
- (void)loginModule:(TUP_MODULE)module notification:(Notification *)notification;

@end

@protocol TupCallNotifacation <NSObject>

/**
 * This method is used to deel call event callback from service
 * 分发呼叫业务相关回调
 *@param module TUP_MODULE
 *@param notification Notification
 */
- (void)callModule:(TUP_MODULE)module notication:(Notification *)notification;

@end

@protocol TupConfNotifacation <NSObject>

/**
 * This method is used to deel conference event callback from service
 * 分发回控业务相关回调
 *@param module TUP_MODULE
 *@param notification Notification
 */
- (void)confModule:(TUP_MODULE)module notication:(Notification *)notification;

@end

@protocol ContactNotification <NSObject>

/**
 * This method is used to deel contact event callback from service
 * 分发联系人业务相关回调
 *@param module TUP_MODULE
 *@param notification Notification
 */
- (void)contactModule:(TUP_MODULE)module notification:(Notification *)notification;

@end

@interface Initializer : NSObject

+ (BOOL)startupWithLogPath:(NSString *)logPath;

+ (void)registerLoginCallBack:(id<TupLoginNotification>)loginDelegate;

+ (void)registerCallCallBack:(id<TupCallNotifacation>)callDelegate;

+ (void)registerConfCallBack:(id<TupConfNotifacation>)confDelegate;

+ (void)registerContactCallBack:(id<ContactNotification>)contactDelegate;

@end
