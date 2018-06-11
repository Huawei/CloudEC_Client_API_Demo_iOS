//
//  ConfCameraInfo.m
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

#import "ConfCameraInfo.h"

@implementation ConfCameraInfo

-(NSString*)description
{
    NSString *descriptionStr = [NSString stringWithFormat:@"CameraInfo: userId=%u,deviceId=%u,cameraName=%@,videoView=%p",self.userId,self.deviceId,self.cameraName,self.videoView];
    return descriptionStr;
}

@end
