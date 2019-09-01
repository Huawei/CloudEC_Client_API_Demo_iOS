//
//  SignalDataScrollView.h
//  EC_SDK_DEMO
//
//  Created by huawei on 2019/8/27.
//  Copyright © 2019年 cWX160907. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AudioStreamInfo.h"
#import "VideoStreamInfo.h"
#import "StatisticShowInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface SignalDataScrollView : UIScrollView
@property (nonatomic, strong) AudioStreamInfo *audioStreamInfo;
@property (nonatomic, strong) VideoStreamInfo *singleStream;
@property (nonatomic, strong) NSArray *mutiStreamArray;

@property (nonatomic, strong) NSArray *audioInfoArray;
@property (nonatomic, strong) NSArray *videoInfoArray;
@property (nonatomic, strong) NSArray *dataInfoArray;

@end

NS_ASSUME_NONNULL_END
