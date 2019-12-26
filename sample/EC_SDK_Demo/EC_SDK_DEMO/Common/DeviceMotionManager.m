//
//  ESpaceDeviceMotionManager.m
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

#import "DeviceMotionManager.h"

#import "Defines.h"

@interface DeviceMotionManager ()
//@property (nonatomic, strong) CMMotionManager *motionManager;
//@property (nonatomic, assign) UIDeviceOrientation lastOrientation;
@end

static DeviceMotionManager *g_deviceManager = nil;

@implementation DeviceMotionManager

/**
 *This method is used to init this class
 *初始化方法
 */
- (instancetype)init
{
    if (self = [super init]) {
        _motionManager = [[CMMotionManager alloc] init];
        _motionManager.deviceMotionUpdateInterval = 1.0/2.0; //采集频率
        _lastOrientation = UIDeviceOrientationPortrait;
    }
    return self;
}

/**
 *This method is used to get single instance of this class
 *获取本类唯一实例
 */
+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        g_deviceManager = [[DeviceMotionManager alloc] init];
    });
    return g_deviceManager;
}

/**
 *This method is used to stop device motion updates
 *暂停加速器及螺旋仪数据采集
 */
- (void)stopDeviceMotionManager
{
    if (nil != _motionManager && _motionManager.isDeviceMotionAvailable)
    {
        [_motionManager stopDeviceMotionUpdates];
    }
}

/**
 *This method is used to start device motion manager
 *开启速器及螺旋仪数据采集
 */
- (void)startDeviceMotionManager
{
    [self stopDeviceMotionManager];
    //开始采集设备方向
    if (_motionManager.isDeviceMotionAvailable) {
//        _lastOrientation = UIDeviceOrientationUnknown;
        [_motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:^(CMDeviceMotion *data,NSError *error){
            [self performSelectorOnMainThread:@selector(currentDeviceOrientation:) withObject:data waitUntilDone:YES];
        }];
    }
    
}

/**
 *This method is used to detect device orientation when orientation is locked
 *方向被锁定键时，使用此方法检测设备方向
 */
- (void)currentDeviceOrientation:(CMDeviceMotion *)deviceMotion
{
    UIDeviceOrientation orientation = UIDeviceOrientationLandscapeLeft;
    if (_motionManager.isDeviceMotionAvailable) {
        CMDeviceMotion *data = deviceMotion;//_orientationDetectCM.deviceMotion;
        double fabGravityX = fabs(data.gravity.x);
        double fabGravityY = fabs(data.gravity.y);
        double fabGravityZ = fabs(data.gravity.z);
        if (fabGravityX >= fabGravityY && fabGravityX >= fabGravityZ) {
            if (data.gravity.x >= 0) {
                orientation = UIDeviceOrientationLandscapeRight;
            }
            else
            {
                orientation = UIDeviceOrientationLandscapeLeft;
            }
        }
        else if(fabGravityY > fabGravityX && fabGravityY > fabGravityZ)
        {
            if (data.gravity.y >= 0) {
                orientation = UIDeviceOrientationPortraitUpsideDown;
            }
            else
            {
                orientation = UIDeviceOrientationPortrait;
            }
        }
        else if (fabGravityZ > fabGravityX && fabGravityZ > fabGravityY)
        {
            return;
//            if (data.gravity.z >= 0) {
//                orientation = UIDeviceOrientationFaceDown;
//            }
//            else
//            {
//                orientation = UIDeviceOrientationFaceUp;
//            }
        }
        
    }
    if (orientation != _lastOrientation) {
        _lastOrientation = orientation;
        [[NSNotificationCenter defaultCenter] postNotificationName:ESPACE_DEVICE_ORIENTATION_CHANGED object:nil];
    }
}

/**
 *This method is used to adjust both front and back camer rotation according to device interface orientation
 *根据设备屏幕方向调整摄像头方向（横竖屏，上下方向）；
 */
- (BOOL)adjustCamerRotation:(NSUInteger *)cameraRotation
            displayRotation:(NSUInteger *)displayRotation
               byCamerIndex:(NSUInteger)index
       interfaceOrientation:(UIInterfaceOrientation)interface
{
    if (_lastOrientation != UIDeviceOrientationFaceUp && _lastOrientation != UIDeviceOrientationFaceDown)
    {
        // 0:0度 ; 1:90度 ；2:180度 ；3:270度
        if (_lastOrientation == UIDeviceOrientationPortrait)
        {
            if (interface == UIInterfaceOrientationPortrait)
            {
                if (index == CameraIndexFront)
                {
                    *cameraRotation = 3;
                    *displayRotation = 0;
                }
                else
                {
                    *cameraRotation = 3;
                    *displayRotation = 0;
                }
            }
            else
            {
                if (index == CameraIndexFront)
                {
                    *cameraRotation = 3;
                    *displayRotation = 3;
                }
                else
                {
                    *cameraRotation = 3;
                    *displayRotation = 3;
                }
            }
        }
        else if (_lastOrientation == UIDeviceOrientationLandscapeLeft)
        {
            if (interface == UIInterfaceOrientationPortrait)
            {
                if (index == CameraIndexFront)
                {
                    *cameraRotation = 0;
                    //*displayRotation = 0;
                    *displayRotation = 1;
                }
                else
                {
                    *cameraRotation = 2;
                    *displayRotation = 1;
                }
            }
            else
            {
                if (index == CameraIndexFront)
                {
                    *cameraRotation = 0;
                    *displayRotation = 0;
                }
                else
                {
                    *cameraRotation = 2;
                    *displayRotation = 0;
                }
            }
        }
        else if (_lastOrientation == UIDeviceOrientationLandscapeRight)
        {
            if (interface == UIInterfaceOrientationPortrait)
            {
                if (index == CameraIndexFront)
                {
                    *cameraRotation = 2;
                    //*displayRotation = 0;
                    *displayRotation = 3;
                }
                else
                {
                    *cameraRotation = 0;
                    *displayRotation = 3;
                }
            }
            else
            {
                if (index == CameraIndexFront)
                {
                    *cameraRotation = 2;
                    *displayRotation = 2;
                }
                else
                {
                    *cameraRotation = 0;
                    *displayRotation = 2;
                }
            }
            
        }
        else if (_lastOrientation == UIDeviceOrientationPortraitUpsideDown)
        {
            if (interface == UIInterfaceOrientationPortrait)
            {
                if (index == CameraIndexFront)
                {
                    *cameraRotation = 0;
                    *displayRotation = 2;
                }
                else
                {
                    *cameraRotation = 1;
                    *displayRotation = 2;
                }
            }
            else
            {
                if (index == CameraIndexFront)
                {
                    *cameraRotation = 1;
                    *displayRotation = 1;
                }
                else
                {
                    *cameraRotation = 1;
                    *displayRotation = 1;
                }
            }
        }
        return YES;
    }
    
    return NO;
}

- (BOOL)conferenceAdjustCamerRotation:(NSUInteger *)cameraRotation
                      displayRotation:(NSUInteger *)displayRotation
                         byCamerIndex:(NSUInteger)index
                 interfaceOrientation:(UIInterfaceOrientation)interface
{
    if (_lastOrientation != UIDeviceOrientationFaceUp && _lastOrientation != UIDeviceOrientationFaceDown)
    {
        // 0:0度 ; 1:90度 ；2:180度 ；3:270度
        if (_lastOrientation == UIDeviceOrientationPortrait)
        {
            if (interface == UIInterfaceOrientationPortrait)
            {
                if (index == CameraIndexFront)
                {
                    *cameraRotation = 3;
                    *displayRotation = 0;
                }
                else
                {
                    *cameraRotation = 3;
                    *displayRotation = 0;
                }
            }
            else
            {
                if (index == CameraIndexFront)
                {
                    *cameraRotation = 3;
                    *displayRotation = 3;
                }
                else
                {
                    *cameraRotation = 3;
                    *displayRotation = 3;
                }
            }
        }
        else if (_lastOrientation == UIDeviceOrientationLandscapeLeft)
        {
            if (interface == UIInterfaceOrientationPortrait)
            {
                if (index == CameraIndexFront)
                {
                    *cameraRotation = 0;
                    *displayRotation = 0;
                }
                else
                {
                    *cameraRotation = 2;
                    *displayRotation = 0;
                }
            }
            else
            {
                if (index == CameraIndexFront)
                {
                    *cameraRotation = 0;
                    *displayRotation = 0;
                }
                else
                {
                    *cameraRotation = 2;
                    *displayRotation = 0;
                }
            }
        }
        else if (_lastOrientation == UIDeviceOrientationLandscapeRight)
        {
            if (interface == UIInterfaceOrientationPortrait)
            {
                if (index == CameraIndexFront)
                {
                    *cameraRotation = 2;
                    *displayRotation = 0;
                }
                else
                {
                    *cameraRotation = 0;
                    *displayRotation = 0;
                }
            }
            else
            {
                if (index == CameraIndexFront)
                {
                    *cameraRotation = 2;
                    *displayRotation = 2;
                }
                else
                {
                    *cameraRotation = 0;
                    *displayRotation = 2;
                }
            }
            
        }
        else if (_lastOrientation == UIDeviceOrientationPortraitUpsideDown)
        {
            if (interface == UIInterfaceOrientationPortrait)
            {
                if (index == CameraIndexFront)
                {
                    *cameraRotation = 0;
                    *displayRotation = 2;
                }
                else
                {
                    *cameraRotation = 1;
                    *displayRotation = 2;
                }
            }
            else
            {
                if (index == CameraIndexFront)
                {
                    *cameraRotation = 1;
                    *displayRotation = 1;
                }
                else
                {
                    *cameraRotation = 1;
                    *displayRotation = 1;
                }
            }
        }
        return YES;
    }
    
    return NO;
}

- (BOOL)isProtraitLockOn {
    UIApplication *app = [UIApplication sharedApplication];
    
    BOOL isOn = NO;
    if (KISIphoneX) {
        NSDictionary *_displayItemStates = [[[app valueForKeyPath:@"statusBar"] valueForKeyPath:@"_statusBar"] valueForKeyPath:@"_displayItemStates"];
        
        id value = _displayItemStates[@"_UIStatusBarIndicatorRotationLockItem"];
        NSLog(@"%@",[value class]);//_UIStatusBarDisplayItemState
        bool _dataEnabled =[[value valueForKeyPath:@"_dataEnabled"]boolValue];
        
        if (@available(iOS 12, *)) {
            for (id ieentifi in _displayItemStates.allKeys) {
                NSString *identifier = [NSString stringWithFormat:@"%@",ieentifi];
                if ([identifier isEqualToString:@"_UIStatusBarIndicatorRotationLockItem"]) {
                    value = _displayItemStates[ieentifi];
                    _dataEnabled =[[value valueForKeyPath:@"_dataEnabled"]boolValue];
                }
            }
        }
        if (_dataEnabled == YES) {
            isOn =  YES;
        }
    }else{
        UIView *foregroundView = [[app valueForKeyPath:@"statusBar"] valueForKey:@"foregroundView"];
        for (id child in foregroundView.subviews) {
            @try {
                id item = [child valueForKey:@"item"];
                int type = [[item valueForKey:@"type"] intValue];
                /*
                 UIStatusBarItem.type
                 0, 时间
                 3, 信号强度
                 4, 运营商
                 6, 网络
                 8, 电池
                 9, 电量百分比
                 12, 蓝牙
                 14, 闹钟
                 18, 竖屏锁定
                 34, 耳机
                 */
                if (type == 18) {
                    isOn = YES;
                    break;
                }

            }@catch (NSException *e) {}
        }
    }
    
    return isOn;
}


@end
