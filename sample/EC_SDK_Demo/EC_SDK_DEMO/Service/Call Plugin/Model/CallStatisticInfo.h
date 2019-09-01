//
//  CallStatisticInfo.h
//  EC_SDK_DEMO
//
//  Created by huawei on 2019/8/27.
//  Copyright © 2019年 cWX160907. All rights reserved.
//

#import <UIKit/UIKit.h>
@class VideoStreamInfo,AudioStreamInfo;

NS_ASSUME_NONNULL_BEGIN

@interface CallStatisticInfo : NSObject

@property (nonatomic, assign) NSInteger callId;
@property (nonatomic, assign) NSInteger signalStrength;
@property (nonatomic, assign) NSInteger negoBandwidth;    // 会话协商出的带宽
@property (nonatomic, copy) NSString *negoAudioCodec;    // 会话协商出的所支持的音频编解码列表
@property (nonatomic, copy) NSString *negoVideoCodec;    // 会话协商出的所支持的视频编解码列表
@property (nonatomic, assign) NSInteger effectiveBitrate;    // 有效带宽(组件探测出的下行方向总tmmbr)
@property (nonatomic, strong) AudioStreamInfo *audioStreamInfo;  // 音频流信息
@property (nonatomic, strong) VideoStreamInfo *videoStreamInfo;  // 单流视频流信息
@property (nonatomic, assign) BOOL isSvcConf;    // 是否多流视频会议
@property (nonatomic, assign) NSInteger svcStreamCount;    // 多流视频流信息数
@property (nonatomic, strong) NSArray *svcStreamInfoArray;    // 多流视频流信息 TSDK_S_VIDEO_STREAM_INFO

@property (nonatomic, strong) VideoStreamInfo *dataStreamInfo;  // data流信息

@end

NS_ASSUME_NONNULL_END
