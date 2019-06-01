//
//  CircleComment.m
//  eSpace
//
//  Created by huawei on 15/6/4.
//  Copyright (c) 2015年 www.huawei.com. All rights reserved.
//

#import "CircleComment.h"
#import "MessageEntity.h"
#import "CircleSessionEntity.h"
#import "SessionGroupEntity.h"
#import "ECSUtils.h"
//#import "MessageEntity+ServiceObject.h" TODO wxy

@implementation CircleComment

@dynamic commentType;
@dynamic meInvolved;

//ECSEntryptCoreDataStringProp(draft, Draft)

//TODO wxy
//- (BOOL)canBeLatestMessage {
////    CircleSessionEntity* circleSession = (CircleSessionEntity*)self.session;
//    BOOL bMeInvolved = [self.meInvolved boolValue];
//    BOOL fromMe = [self fromSelf];
//    return bMeInvolved && !fromMe;
//}

@end
