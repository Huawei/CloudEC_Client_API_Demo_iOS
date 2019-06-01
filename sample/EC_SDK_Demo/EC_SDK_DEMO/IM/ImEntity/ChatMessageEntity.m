//
//  ChatMessageEntity.m
//  eSpace
//
//  Created by yemingxing on 8/10/15.
//  Copyright (c) 2015 www.huawei.com. All rights reserved.
//

#import "ChatMessageEntity.h"
#import "EmployeeEntity.h"

@implementation ChatMessageEntity

@dynamic readDetail;
@dynamic flag;
@dynamic body_ref;
@dynamic at;
@dynamic subIndex;
@dynamic total;
@dynamic msgEx;
@dynamic appName;
@dynamic appID;
@dynamic senderType;

- (BOOL)canBeLatestMessage {
    return [self.type integerValue] == ESpaceIMMSGType && ([self.flag integerValue] == ESpaceMessageFlagNormal || [self.flag integerValue] == ESpaceMessageFlagRecalled);
}

- (BOOL)canBeSelected {
    return self.type.integerValue != ESpaceSysTimeMSGType && self.flag.integerValue == ESpaceMessageFlagNormal;
}

@end
