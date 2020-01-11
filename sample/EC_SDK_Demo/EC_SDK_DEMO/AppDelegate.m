 //
//  AppDelegate.m
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

#import "AppDelegate.h"
#import "NetworkUtils.h"
#import "ServiceManager.h"
#import "CallWindowController.h"
#import "ConfRunningViewController.h"
#import "ECSLogger.h"
#import <PushKit/PushKit.h>
#import <UserNotifications/UserNotifications.h>
#import "ViewController.h"
#import "ManagerService.h"
#import "LoginService.h"
#import "LoginInfo.h"
#import "CommonUtils.h"
#import "LoginServerInfo.h"
#import "Defines.h"
#import "SettingViewController.h"
#import "LoginViewController.h"
#import "LoginCenter.h"
#import "VideoShareViewController.h"
//#import "AudioConfViewController.h"
#import "LocalNotificationCenter.h"



@interface AppDelegate ()<PKPushRegistryDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
//    //注册voip push
//    PKPushRegistry *pushRegistry = [[PKPushRegistry alloc] initWithQueue:dispatch_get_main_queue()];
//    if (pushRegistry) {
//        //iOS8.1以下系统无法初始化PKPushRegistry对象，会导致crash问题
//        pushRegistry.delegate = self;
//        pushRegistry.desiredPushTypes = [NSSet setWithObject:PKPushTypeVoIP];
//    }else{
//        DDLogWarn(@"generate PKPushRegistry object failed, register voip push failed!");
//    }
//
    //注册apns push
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeBadge|UIUserNotificationTypeAlert|UIUserNotificationTypeSound) categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    [[UIApplication sharedApplication] registerForRemoteNotifications];
    
    [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
    }];
    
    
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:44.0/255 green:110.0/255 blue:232.0/255 alpha:1]];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    // Override point for customization after application launch.
    
    // DDLog init (write log to file)
//    [[ECSLogger shareInstance] addFileLogger];
    

    // start up tup module.(module: Call/Conference/SipLogin)
    [ServiceManager startup];
    
    // other UI Things
    [CallWindowController shareInstance];
    [NetworkUtils shareInstance];
    
    [[LocalNotificationCenter sharedInstance] start];
    
    //    [self gotoNormalFlow];
    
    return YES;
}

- (void)gotoNormalFlow {
    
        // check is auto login
        BOOL bNeedAutoLogin = [self shouldStartAutoLogin];
        if (bNeedAutoLogin) {
            [AppDelegate startAutoLogin];
            [AppDelegate gotoRecentChatSessionView];
        }
}


+ (void)startAutoLogin
{
    
    NSArray *array = [CommonUtils getUserDefaultValueWithKey:SERVER_CONFIG];

    LoginInfo *user = [[LoginInfo alloc] init];
    user.regServerAddress = array[0];
    user.regServerPort = array[1];
    user.account = [CommonUtils getUserDefaultValueWithKey:USER_ACCOUNT];
    user.password = [CommonUtils getUserDefaultValueWithKey:USER_PASSWORD];
    
    [[ManagerService loginService] authorizeLoginWithLoginInfo:user completionBlock:^(BOOL isSuccess, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
        });
    }];
}

- (BOOL)shouldStartAutoLogin
{
    BOOL needAutoLogin = [CommonUtils getUserDefaultBoolValueWithKey:NEED_AUTO_LOGIN];
    return needAutoLogin;
}

+ (void)gotoRecentChatSessionView
{
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    ViewController *baseViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"ViewController"];
    [UIApplication sharedApplication].delegate.window.rootViewController = baseViewController;
}



- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    

}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    __block UIBackgroundTaskIdentifier taskID = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [[UIApplication sharedApplication] endBackgroundTask:taskID];
        taskID = UIBackgroundTaskInvalid;
    }];
    

}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
//    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [[ManagerService confService] restoreConfParamsInitialValue];

}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    // Config APNS type and device token to uportal for APNS Notification.
//    const unsigned *tokenBytes = (const unsigned*)[deviceToken bytes];
//    NSString *hexToken = [NSString stringWithFormat:@"%08x%08x%08x%08x%08x%08x%08x%08x",
//                          ntohl(tokenBytes[0]), ntohl(tokenBytes[1]), ntohl(tokenBytes[2]),
//                          ntohl(tokenBytes[3]), ntohl(tokenBytes[4]), ntohl(tokenBytes[5]),
//                          ntohl(tokenBytes[6]), ntohl(tokenBytes[7])];
    
    NSString *str = [NSString stringWithFormat:@"%@",deviceToken];
    NSString *tokenStr = [[[str stringByReplacingOccurrencesOfString:@"<" withString:@""] stringByReplacingOccurrencesOfString:@">" withString:@""] stringByReplacingOccurrencesOfString:@" " withString:@""];

}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSString *errorDesc = [error localizedDescription];
    NSString *errorFailedReason = [error localizedFailureReason];
    NSString *errorRecoverySuggestion = [error localizedRecoverySuggestion];
    DDLogError(@"error desc:%@\nreson:%@\nsuggestion:%@",errorDesc,errorFailedReason,errorRecoverySuggestion);
}

-(void)pushRegistry:(PKPushRegistry *)registry didInvalidatePushTokenForType:(NSString *)type{
    DDLogError(@"type(%@)",type);
}

- (void)pushRegistry:(PKPushRegistry *)registry didUpdatePushCredentials:(PKPushCredentials *)pushCredentials forType:(PKPushType)type{
    DDLogInfo(@"enter!");
//    NSData *deviceToken = pushCredentials.token;
//    const unsigned *tokenBytes = (const unsigned*)[deviceToken bytes];
//    NSString *hexToken = [NSString stringWithFormat:@"%08x%08x%08x%08x%08x%08x%08x%08x",
//                          ntohl(tokenBytes[0]), ntohl(tokenBytes[1]), ntohl(tokenBytes[2]),
//                          ntohl(tokenBytes[3]), ntohl(tokenBytes[4]), ntohl(tokenBytes[5]),
//                          ntohl(tokenBytes[6]), ntohl(tokenBytes[7])];
    
    NSString *str = [NSString stringWithFormat:@"%@",pushCredentials.token];
    NSString *tokenStr = [[[str stringByReplacingOccurrencesOfString:@"<" withString:@""] stringByReplacingOccurrencesOfString:@">" withString:@""] stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    
}

-(BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray * _Nullable))restorationHandler {
//    [self.callKitManager startCallWithNumber:userActivity.startCallHandler];
    return YES;
}

- (void)pushRegistry:(PKPushRegistry *)registry didReceiveIncomingPushWithPayload:(PKPushPayload *)payload forType:(NSString *)type{
    
    NSDictionary *dicInfo = payload.dictionaryPayload;
//    NSString *callerName = dicInfo[@"CallerName"];
    NSString *state = dicInfo[@"State"];
    
    if(state && state.integerValue == 1){ //目前voip push消息有2种，根据push携带的消息字典中的State值来区分，分别是发起呼叫(0)和取消呼叫(1),这里如果是取消呼叫的消息，我们不进行处理
        DDLogInfo(@"[voip push] voip call canceled");
        return;
    }
    
//    UIUserNotificationType theType = [UIApplication sharedApplication].currentUserNotificationSettings.types;
//    if (theType == UIUserNotificationTypeNone) {
//        UIUserNotificationSettings *userNotificationSetting = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeBadge|UIUserNotificationTypeAlert|UIUserNotificationTypeSound) categories:nil];
//        [[UIApplication sharedApplication] registerUserNotificationSettings:userNotificationSetting];
//    }
//
//    UILocalNotification *localNTF = [[UILocalNotification alloc] init];
//    localNTF.alertBody = [NSString stringWithFormat:@"%@ 发来一个来电请求",callerName];
//    localNTF.fireDate = [[NSDate date] dateByAddingTimeInterval:0.2];
//
//    [[UIApplication sharedApplication] scheduleLocalNotification:localNTF];
    
}


#if __IPHONE_OS_VERSION_MAX_ALLOWED < 90000
- (NSUInteger)application:(UIApplication*)application supportedInterfaceOrientationsForWindow:(UIWindow*)window
#else //CB-12098.  Defaults to UIInterfaceOrientationMask for iOS 9+
- (UIInterfaceOrientationMask)application:(UIApplication*)application supportedInterfaceOrientationsForWindow:(UIWindow*)window
#endif
{
    // iPhone doesn't support upside down by default, while the iPad does.  Override to allow all orientations always, and let the root view controller decide what's allowed (the supported orientations mask gets intersected).
    NSUInteger supportedInterfaceOrientations = (1 << UIInterfaceOrientationPortrait) | (1 << UIInterfaceOrientationLandscapeLeft) | (1 << UIInterfaceOrientationLandscapeRight) | (1 << UIInterfaceOrientationPortraitUpsideDown);
    
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

/**
 *This method is used to switch to the conf running page
 *切换到正在召开的会议页面
 */
+(void)goConference
{
    UIViewController *controller = [UIApplication sharedApplication].delegate.window.rootViewController;
    if (![controller isKindOfClass:[UITabBarController class]]) {
        
        VideoShareViewController *runningView = [[VideoShareViewController alloc] init];
        runningView.hidesBottomBarWhenPushed = YES;
        
        [(UINavigationController *)controller pushViewController:runningView animated:YES];
        
        return;
    }
    UITabBarController *tabbar = (UITabBarController*)controller;
    tabbar.selectedIndex = 0;
    UINavigationController *navigationCtrl = tabbar.viewControllers[0];
//    if ([[navigationCtrl.viewControllers lastObject] isKindOfClass:[ConfRunningViewController class]]) {
//        return;
//    }
//    ConfRunningViewController *runningView = [[ConfRunningViewController alloc] init];
//    runningView.hidesBottomBarWhenPushed = YES;
    
    if ([[navigationCtrl.viewControllers lastObject] isKindOfClass:[VideoShareViewController class]]) {
        return;
    }
    

    VideoShareViewController *videoShareView = [[VideoShareViewController alloc] init];
    videoShareView.hidesBottomBarWhenPushed = YES;
    
    [navigationCtrl pushViewController:videoShareView animated:YES];
    
    DDLogInfo(@"goConference");
}

+ (void)appConfShareRequestAction
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:@"Accept Share Screen ?" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *refuseAction = [UIAlertAction actionWithTitle:@"Refuse" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [[ManagerService confService] cancelDataShareWithNumber:[ManagerService confService].selfJoinNumber];
        }];
        UIAlertAction *answerAction = [UIAlertAction actionWithTitle:@"Accept" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            [[NSNotificationCenter defaultCenter] postNotificationName:APP_START_SYSTEM_SHARE_VIEW object:nil];;
            
        }];
        [alertController addAction:refuseAction];
        [alertController addAction:answerAction];
        UIViewController *controller = [UIApplication sharedApplication].delegate.window.rootViewController;
        [controller presentViewController:alertController animated:YES completion:nil];
    });
}


@end
