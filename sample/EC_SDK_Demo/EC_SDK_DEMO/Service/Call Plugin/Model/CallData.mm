//
//  CallData.mm
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

#import "CallData.h"

@implementation CallData

- (instancetype)init
{
    if (self = [super init])
    {
        self.remoteNumber = @"";
        self.callId = 0;
        self.status = CallStatusIdle;
        self.isSelfCaller = NO;
    }
    return self;
}

- (void)dealloc
{
    self.remoteNumber = nil;
}

@end
