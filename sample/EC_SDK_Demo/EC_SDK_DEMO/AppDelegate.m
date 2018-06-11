//
//  AppDelegate.m
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

#import "AppDelegate.h"
#import "NetworkUtils.h"
#import <TUPIOSSDK/TUPIOSSDK.h>
#import "ServiceManager.h"
#import "CallWindowController.h"
#import "ConfRunningViewController.h"
#import "ECSLogger.h"
#import "LocalNotificationCenter.h"
#import "ConfStatus.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:44.0/255 green:110.0/255 blue:232.0/255 alpha:1]];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    // Override point for customization after application launch.
    
    // DDLog init (write log to file)
    [[ECSLogger shareInstance] addFileLogger];
    [NetworkUtils shareInstance];
    
    // Config TUPIOSSDK log path
    NSString *logPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingString:@"/TUPC60log"];
    [ECSSandboxHelper shareInstance].logFileSuperPath = logPath;
    
    // init TUPIOSSDK (module: Contact/IM/Group/MAALogin)
    [ECSAppConfig sharedInstance].appLogLevel = kECSLogDebug;
    [ECSAppConfig sharedInstance].isLogEnabled = YES;
    [ECSAppConfig sharedInstance].version = @"V3.0.4.5";
    if ([ECSAppConfig sharedInstance].isFirstUsed)
    {
        [[ECSAppConfig sharedInstance] initializeSecurityRandomKey];
    }
    [TUPIOSSDKService start];

    // start up tup module.(module: Call/Conference/SipLogin)
    [ServiceManager startup];
    
    // other UI Things
    [CallWindowController shareInstance];
    [[LocalNotificationCenter sharedInstance] start];

    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    
    [[LOCAL_DATA_MANAGER managedObjectContext] saveToPersistent];
    [[ECSAppConfig sharedInstance] save];
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    __block UIBackgroundTaskIdentifier taskID = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [[UIApplication sharedApplication] endBackgroundTask:taskID];
        taskID = UIBackgroundTaskInvalid;
    }];
    
    [[LOCAL_DATA_MANAGER managedObjectContext] saveToPersistent];
    [[ECSAppConfig sharedInstance] save];
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    
    [[LOCAL_DATA_MANAGER managedObjectContext] saveToPersistent];
    [[ECSAppConfig sharedInstance] save];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    // Config APNS type and device token to MAA for APNS Notification.
    const unsigned *tokenBytes = (const unsigned*)[deviceToken bytes];
    NSString *hexToken = [NSString stringWithFormat:@"%08x%08x%08x%08x%08x%08x%08x%08x",
                          ntohl(tokenBytes[0]), ntohl(tokenBytes[1]), ntohl(tokenBytes[2]),
                          ntohl(tokenBytes[3]), ntohl(tokenBytes[4]), ntohl(tokenBytes[5]),
                          ntohl(tokenBytes[6]), ntohl(tokenBytes[7])];
    [ECSAppConfig sharedInstance].deviceToken = hexToken;
    [ECSAppConfig sharedInstance].apnsType = APNS_DEV;
}

/**
 *This method is used to switch to the conf running page
 *切换到正在召开的会议页面
 */
+(void)goConference:(ConfStatus *)confStatus
{
    UIViewController *controller = [UIApplication sharedApplication].delegate.window.rootViewController;
    if (![controller isKindOfClass:[UITabBarController class]]) {
        return;
    }
    UITabBarController *tabbar = (UITabBarController*)controller;
    tabbar.selectedIndex = 1;
    UINavigationController *navigationCtrl = tabbar.viewControllers[1];
    if ([[navigationCtrl.viewControllers lastObject] isKindOfClass:[ConfRunningViewController class]]) {
        return;
    }
    ConfRunningViewController *runningView = [[ConfRunningViewController alloc] init];
    runningView.currentStatus = confStatus;
    runningView.hidesBottomBarWhenPushed = YES;
    
    [navigationCtrl pushViewController:runningView animated:YES];
    DDLogInfo(@"goConference");
}


@end
