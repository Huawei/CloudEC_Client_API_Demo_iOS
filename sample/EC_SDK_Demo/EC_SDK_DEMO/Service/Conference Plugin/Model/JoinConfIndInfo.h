//
//  JoinConfIndInfo.h
//  EC_SDK_DEMO
//
//  Created by huawei on 2019/8/16.
//  Copyright © 2019年 cWX160907. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "tsdk_conference_def.h"


@interface JoinConfIndInfo : NSObject

@property (nonatomic, assign) int callId;       // 呼叫ID，软终端号码入会时有效
@property (nonatomic, assign) TSDK_E_CONF_MEDIA_TYPE confMediaType;   // 媒体类型
@property (nonatomic, assign) BOOL isHdConf;   // 是否高清视频会议
@property (nonatomic, assign) TSDK_E_CONF_ENV_TYPE confEnvType;  // 会议组网类型
@property (nonatomic, assign) BOOL isSvcConf;  // 是否多流会议
@property (nonatomic, assign) int svcLableCount;  // 多流Lable有效个数
@property (nonatomic, copy) NSArray * svcLable;   // 多流Lable对应的ssrc值
@property (nonatomic, assign) BOOL isSelfJoinConf;  // 是否已经加入会议

@end

