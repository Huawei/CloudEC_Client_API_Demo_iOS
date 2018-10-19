//
//  LocalNotificationCenter.m
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

#import "LocalNotificationCenter.h"
#import <TUPIMSDK/TUPIMSDK.h>
#import <TUPIOSSDK/TUPIOSSDK.h>
#import "CallService.h"

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
//    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeBadge|UIUserNotificationTypeAlert|UIUserNotificationTypeSound) categories:nil];
//    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
//    [[UIApplication sharedApplication] registerForRemoteNotifications];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onReceiveNewMessage:) name:TUP_RECEIVE_SINGLE_MESSAGE_NOTIFY object:nil];//person chatMessage notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onReceiveNewMessage:) name:TUP_RECEIVE_GROUP_MESSAGE_NOTIFY object:nil];//group chatMessage notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onReceiveNewCall:) name:TSDK_COMING_CALL_NOTIFY object:nil];//coming call notification
}

- (void)onReceiveNewMessage:(NSNotification *)notification
{
    NSManagedObjectID* moId = [notification.userInfo objectForKey:TUP_RECEIVE_MESSAGE_NOTIFY_KEY];
    if (nil == moId) {
        return;
    }
    ChatMessageEntity* messageEntity = (ChatMessageEntity*)[[LOCAL_DATA_MANAGER managedObjectContext] objectWithID:moId];
    if (nil == messageEntity) {
        return;
    }
    [self receiveNewMessage:messageEntity];
}

- (void)receiveNewMessage:(ChatMessageEntity* )message {
    if (message.readed.integerValue == 1) {
        return;
    }
    
    [self sendLocalNotification:message];
    
    [UIApplication sharedApplication].applicationIconBadgeNumber += 1;

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
    
    
    UILocalNotification *localNTF = [[UILocalNotification alloc] init];
    localNTF.alertBody = tipMsg;
    localNTF.fireDate = [[NSDate date] dateByAddingTimeInterval:0.2];
    
    [[UIApplication sharedApplication] scheduleLocalNotification:localNTF];
}

/**
 This method is used to send push message

 @param message ChatMessageEntity
 */
- (void)sendLocalNotification:(ChatMessageEntity *)message
{
    NSString * tipFormat = nil;
    NSString * tipMsg = nil;
    
    ESpaceContentType contentType = [message.contentType integerValue];
    
    switch (contentType) {
        case ESpaceAudioContentType:
            tipFormat = @"%@ sent an audio clip.";
            break;
        case ESpaceVideoContentType:
            tipFormat = @"%@ sent a video clip.";
            break;
        case ESpaceImageContentType:
            tipFormat = @"%@ sent a pictrue.";
            break;
        case ESpaceFileContentType:
            tipFormat = @"%@ sent a file.";
            break;
        default:
            tipFormat = @"%@ sent a message.";
            break;
    }
    
    EmployeeEntity* from = (EmployeeEntity*)message.from;
    tipMsg = [NSString stringWithFormat:tipFormat,from.uiDisplayName];
    
    UILocalNotification *localNTF = [[UILocalNotification alloc] init];
    localNTF.alertBody = tipMsg;
    localNTF.fireDate = [[NSDate date] dateByAddingTimeInterval:0.2];
    
    [[UIApplication sharedApplication] scheduleLocalNotification:localNTF];
}


@end
