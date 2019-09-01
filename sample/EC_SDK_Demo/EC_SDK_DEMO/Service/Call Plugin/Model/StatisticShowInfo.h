//
//  StatisticShowInfo.h
//  EC_SDK_DEMO
//
//  Created by huawei on 2019/8/28.
//  Copyright © 2019年 cWX160907. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface StatisticShowInfo : NSObject


@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) NSInteger bandWidth;    // 有效带宽
@property (nonatomic, assign) long long lossFraction;  // 接收方丢包率(%)
@property (nonatomic, assign) long long delay;    // 接收方平均时延(ms)
@property (nonatomic, assign) long long jitter;    // 接收方平均抖动(ms)
@property (nonatomic, copy) NSString *frameSize;    // 接收(解码)图像分辨率描述
@property (nonatomic, assign) NSInteger frameRate;    // 接收(解码)视频帧率



@end

NS_ASSUME_NONNULL_END
