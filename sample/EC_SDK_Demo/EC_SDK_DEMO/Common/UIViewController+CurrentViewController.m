//
//  UIViewController+CurrentViewController.m
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

#import "UIViewController+CurrentViewController.h"

@implementation UIViewController (CurrentViewController)

/**
 *This method is used to get current view controller
 *获取当前试图控制器
 */
+ (UIViewController *)currentViewController {
    UIViewController *rootViewController = [[UIApplication sharedApplication].keyWindow rootViewController];
    return [self topViewControllerForViewController:rootViewController];
}

/**
 *This method is used to get current view controller
 *获取当前试图控制器
 */
+ (UIViewController *)topViewControllerForViewController:(UIViewController *)rootViewController {
    if ([rootViewController isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tabbarController = (UITabBarController *)rootViewController;
        return [self topViewControllerForViewController:tabbarController.selectedViewController];
    }
    if ([rootViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navigationController = (UINavigationController *)rootViewController;
        return [self topViewControllerForViewController:navigationController.visibleViewController];
    }
    
    if (rootViewController.presentedViewController) {
        return [self topViewControllerForViewController:rootViewController.presentedViewController];
    }
    
    return rootViewController;
}

@end
