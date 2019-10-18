//
//  ECBaseTableViewController.m
//  EC_SDK_DEMO
//
//  Created by huawei on 2019/10/9.
//  Copyright © 2019 cWX160907. All rights reserved.
//

#import "ECBaseTableViewController.h"

@interface ECBaseTableViewController ()

@end

@implementation ECBaseTableViewController

-(void) viewDidLoad {
    
    [super viewDidLoad];
    
//    NSString *myPageName = NSStringFromClass([self class]);
//
//     [[ESpaceEventRecordModel shareEventRecordModel] recordEventActionWithPageName:myPageName];
 
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.isViewAnimation = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
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


@end
