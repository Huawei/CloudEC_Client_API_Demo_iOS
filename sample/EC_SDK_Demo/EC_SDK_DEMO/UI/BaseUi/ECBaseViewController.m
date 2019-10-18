//
//  ECBaseViewController.m
//  EC_SDK_DEMO
//
//  Created by huawei on 2019/10/9.
//  Copyright © 2019 cWX160907. All rights reserved.
//

#import "ECBaseViewController.h"
#import "UIView+Exclusive.h"

@interface ECBaseViewController ()

@end

@implementation ECBaseViewController

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}


- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

-(void) viewDidLoad {
    
    [super viewDidLoad];
    
//    NSString *myPageName = NSStringFromClass([self class]);
//
//    [[ESpaceEventRecordModel shareEventRecordModel] recordEventActionWithPageName:myPageName];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.isViewAnimation = YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.navigationController.navigationBar exclusiveAllSubButtons];
    self.isViewAnimation = NO;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.isViewAnimation = YES;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    self.isViewAnimation = NO;
}

- (BOOL)prefersStatusBarHidden
{
    return NO;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

@end
