//
//  VidePreviewController.m
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

#import "VidePreviewController.h"
#import "EAGLView.h"
#import "ManagerService.h"
#import "DeviceMotionManager.h"
#import "Defines.h"

@interface VidePreviewController ()
@property (nonatomic, assign)CameraIndex cameraIndex;

@end

@implementation VidePreviewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _cameraIndex = CameraIndexFront;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(deviceMotionOrientationChanged)
                                                 name:ESPACE_DEVICE_ORIENTATION_CHANGED
                                               object:nil];
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    EAGLView *preview = [EAGLView getPreviewView];
    [preview setFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame))];
    [preview setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    [[ManagerService callService] videoPreview:_cameraIndex toView:preview];
    [self.view addSubview:preview];
    [[DeviceMotionManager sharedInstance] startDeviceMotionManager];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[ManagerService callService] stopVideoPreview];
    EAGLView *preview = [EAGLView getPreviewView];
    [preview removeFromSuperview];
    [[DeviceMotionManager sharedInstance] stopDeviceMotionManager];
}

- (void)deviceMotionOrientationChanged
{
    NSUInteger cameraRotation = 0;
    NSUInteger displayRotation = 0;
    
    BOOL needAdjust = [[DeviceMotionManager sharedInstance] adjustCamerRotation:&cameraRotation displayRotation:&displayRotation byCamerIndex:_cameraIndex interfaceOrientation:UIInterfaceOrientationPortrait];
    if ([UIApplication sharedApplication].applicationState != UIApplicationStateActive)
    {
        return ;
    }
    
    if (!needAdjust) {
        return;
    }
    
    [[ManagerService callService] rotationVideoDisplay:displayRotation callId:0];
    [[ManagerService callService] rotationCameraCapture:cameraRotation callId:0];
}

- (IBAction)switchCamera
{
    CameraIndex index = _cameraIndex == CameraIndexFront ? CameraIndexBack :CameraIndexFront;
    EAGLView *preview = [EAGLView getPreviewView];
    [[ManagerService callService] stopVideoPreview];
    if ([[ManagerService callService] videoPreview:index toView:preview]) {
        _cameraIndex = index;
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
