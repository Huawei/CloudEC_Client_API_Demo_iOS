//
//  ConfCameraInfo.h
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

#import <Foundation/Foundation.h>

@interface ConfCameraInfo : NSObject

@property (nonatomic) unsigned int userId;             //user Id
@property (nonatomic) unsigned int deviceId;           //device Id
@property (nonatomic, retain) NSString *cameraName;    //camera name
@property (nonatomic, strong) id videoView;            //video View

@end
