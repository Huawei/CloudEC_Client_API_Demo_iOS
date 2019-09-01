//
//  CallWindowController.h
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CallWindowController : NSObject

@property (nonatomic,assign)BOOL cameraClose;
@property (nonatomic,assign)BOOL cameraCaptureIndex;

+ (instancetype)shareInstance;

- (void)showStartCallView:(unsigned int)callId;

- (void)deviceMotionOrientationChanged;

- (void)setVideoWindow;

@end
