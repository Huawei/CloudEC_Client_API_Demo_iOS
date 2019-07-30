//
//  SampleHandler.m
//  ECSdkScreenShareExtension
//
//  Created by huawei on 2019/7/29.
//  Copyright © 2019年 cWX160907. All rights reserved.
//


#import "SampleHandler.h"
#import <CLoudLinkMeetingScreenShare/ScreenShareManager.h>

@interface SampleHandler()<ScreenShareManagerDelegate>
@property (strong, nonatomic) ScreenShareManager *screenShareManager;

@end

@implementation SampleHandler

- (instancetype)init {
    if (self = [super init]) {
        self.screenShareManager = [[ScreenShareManager alloc] initWithAppGroupIdentifier:@"group.eSpaceMclientV2"];
        self.screenShareManager.delegate = self;
    }
    return self;
}


- (void)broadcastStartedWithSetupInfo:(NSDictionary<NSString *,NSObject *> *)setupInfo {
    // User has requested to start the broadcast. Setup info from the UI extension can be supplied but optional.
    [self.screenShareManager broadcastStartedWithSetupInfo:setupInfo];
}

- (void)dealloc {
    self.screenShareManager = nil;
}

- (void)broadcastPaused {
    // User has requested to pause the broadcast. Samples will stop being delivered.
    [self.screenShareManager broadcastPaused];
}

- (void)broadcastResumed {
    // User has requested to resume the broadcast. Samples delivery will resume.
    [self.screenShareManager broadcastResumed];
}

- (void)broadcastFinished {
    // User has requested to finish the broadcast.
    [self.screenShareManager broadcastFinished];
}

- (void)processSampleBuffer:(CMSampleBufferRef)sampleBuffer withType:(RPSampleBufferType)sampleBufferType {
    
    switch (sampleBufferType) {
        case RPSampleBufferTypeVideo:
            // Handle video sample buffer
            [self.screenShareManager processSampleBuffer:sampleBuffer withType:RPSampleBufferTypeVideo];
            break;
        case RPSampleBufferTypeAudioApp:
            // Handle audio sample buffer for app audio
            break;
        case RPSampleBufferTypeAudioMic:
            // Handle audio sample buffer for mic audio
            break;
            
        default:
            break;
    }
}

- (void)screenShareManagerFinishBroadcastWithError:(NSError *)error {
    [self finishBroadcastWithError: error];
}
@end
