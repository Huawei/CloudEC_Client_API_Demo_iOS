//
//  CallLogMessage.m
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

#import "CallLogMessage.h"

@implementation CallLogMessage

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.startTime forKey:@"startTime"];
    [aCoder encodeInteger:self.durationTime forKey:@"durationTime"];
    [aCoder encodeInteger:self.callLogType forKey:@"callLogType"];
    [aCoder encodeObject:self.callerPhoneNumber forKey:@"callerPhoneNumber"];
    [aCoder encodeObject:self.calleePhoneNumber forKey:@"calleePhoneNumber"];
    [aCoder encodeObject:self.callMethod forKey:@"callMethod"];
    [aCoder encodeInteger:self.callId forKey:@"callId"];
    [aCoder encodeBool:self.isConnected forKey:@"isConnected"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.startTime = [aDecoder decodeObjectForKey:@"startTime"];
        self.durationTime = [aDecoder decodeIntegerForKey:@"durationTime"];
        self.callLogType = [aDecoder decodeIntegerForKey:@"callLogType"];
        self.callerPhoneNumber = [aDecoder decodeObjectForKey:@"callerPhoneNumber"];
        self.calleePhoneNumber = [aDecoder decodeObjectForKey:@"calleePhoneNumber"];
        self.callMethod = [aDecoder decodeObjectForKey:@"callMethod"];
        self.callId = [aDecoder decodeIntegerForKey:@"callId"];
        self.isConnected = [aDecoder decodeBoolForKey:@"isConnected"];
    }
    return self;
}

@end
