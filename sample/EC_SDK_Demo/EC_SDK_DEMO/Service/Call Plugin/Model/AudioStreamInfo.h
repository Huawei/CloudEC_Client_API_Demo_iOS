//
//  AudioStreamInfo.h
//  EC_SDK_DEMO
//
//  Created by huawei on 2019/8/27.
//  Copyright © 2019年 cWX160907. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AudioStreamInfo : NSObject

@property (nonatomic, assign) BOOL isSrtp;   //是否使用SRTP， 取值: 0 RTP, 1 SRTP
@property (nonatomic, copy) NSString *encodeProtocol;    // 编码协议描述(如：H.264/H.264 SVC)
@property (nonatomic, assign) NSInteger sendBitRate;    // 发送比特率(kbps)
@property (nonatomic, assign) long long sendLossFraction;  // 发送方丢包率(%)
@property (nonatomic, assign) long long sendDelay;    // 发送方平均时延(ms)
@property (nonatomic, assign) long long sendJitter;    // 发送方平均抖动(ms)
@property (nonatomic, copy) NSString *decodeProtocol;    // 解码协议描述(如：H.264/H.264 SVC)
@property (nonatomic, assign) NSInteger recvBitRate;    // 接收比特率(kbps)
@property (nonatomic, assign) long long recvLossFraction;  // 接收方丢包率(%)
@property (nonatomic, assign) long long recvDelay;    // 接收方平均时延(ms)
@property (nonatomic, assign) long long recvJitter;    // 接收方平均抖动(ms)
@property (nonatomic, assign) long long recvAverageMos;    // 接收方向MOS分平均值,用浮点数表示:取值范围[0, 5], 0表示该参数无效



@end

NS_ASSUME_NONNULL_END
