//
//  LocalNotificationCenter.m
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

#import "LocalNotificationCenter.h"
#import "CallService.h"
#import <UIKit/UIKit.h>
#import <UserNotifications/UserNotifications.h>

static LocalNotificationCenter * g_notificationCenter = nil;

@implementation LocalNotificationCenter

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        g_notificationCenter = [[LocalNotificationCenter alloc] init];
    });
    return g_notificationCenter;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)start
{

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onReceiveNewCall:) name:TSDK_COMING_CALL_NOTIFY object:nil];//coming call notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onReceiveNewConference:) name:EC_COMING_CONF_NOTIFY object:nil];
}


- (void)onReceiveNewCall:(NSNotification *)notification
{
    CallInfo *callInfo = (CallInfo *)notification.object;
    
    if (nil == callInfo)
    {
        DDLogWarn(@"nil calldata for the new conf invite message!");
        return;
    }
    __block NSString *tipMsg = @"%@的来电";
    if (CALL_VIDEO == callInfo.stateInfo.callType)
    {
        tipMsg = @"%@的视频来电";
    }
    
    if (nil != callInfo.stateInfo)
    {
        NSString *callName = callInfo.stateInfo.callName;
        if (callName.length == 0 || callName == nil) {
            callName = callInfo.stateInfo.callNum;
        }
        tipMsg = [NSString stringWithFormat:tipMsg, callName];
    }
    
    [self sendLocalNotificationWithTitle:@"call invite" body:tipMsg typeString:@"callNotification"];
    
}

- (void)onReceiveNewConference:(NSNotification *)notification
{
    __block NSString *tipMsg = @"会议中的来电";
    
    [self sendLocalNotificationWithTitle:@"conference invite" body:tipMsg typeString:@"conferenceNotification"];
    
}

- (void)sendLocalNotificationWithTitle:(NSString *)title body:(NSString *)body typeString:(NSString *)typeString
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
            if (@available(iOS 10, *)) {
                UNMutableNotificationContent * content = [[UNMutableNotificationContent alloc] init];
                content.title = [NSString localizedUserNotificationStringForKey:title arguments:nil];
                content.body = [NSString localizedUserNotificationStringForKey:body arguments:nil];
                content.sound = [UNNotificationSound defaultSound];
                UNTimeIntervalNotificationTrigger * trigger = [UNTimeIntervalNotificationTrigger
                                                               triggerWithTimeInterval:0.2f repeats:nil];
                
                UNNotificationRequest * request = [UNNotificationRequest requestWithIdentifier:typeString content:content trigger:trigger];
                UNUserNotificationCenter * center = [UNUserNotificationCenter currentNotificationCenter];
                [center addNotificationRequest:request withCompletionHandler:nil];
            }else{
                UILocalNotification *localNTF = [[UILocalNotification alloc] init];
                localNTF.alertBody = body;
                localNTF.fireDate = [[NSDate date] dateByAddingTimeInterval:0.2];
                localNTF.soundName = UILocalNotificationDefaultSoundName;
                
                [[UIApplication sharedApplication] scheduleLocalNotification:localNTF];
            }
        }
        
    });
}




@end
