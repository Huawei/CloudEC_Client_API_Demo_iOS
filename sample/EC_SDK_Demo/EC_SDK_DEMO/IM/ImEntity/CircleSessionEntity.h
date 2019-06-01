//
//  CircleSessionEntity.h
//
//  Created on 15/6/4.
//  Copyright (c) 2017年 Huawei Tech. Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "SessionEntity.h"

@class EmployeeEntity;

typedef NS_ENUM(NSInteger, CircleSessionType) {
    CircleSessionText = 0,
    CircleSessionTextAndUM = 1,
    CircleSessionShareLink = 2
};

typedef NS_ENUM(NSInteger, CircleSessinoStatus) {
    CircleSessionSended = 0,
    CircleSessionSending = 0x10000,
    CircleSessionSendFailed = 0x20000
};

typedef NS_ENUM(NSInteger, CircleSessionValidStatus) {
    CircleSessionInValid = 0,
    CircleSessionValid = 1,
    CircleSessionDeleted = 2
};

typedef NS_ENUM(NSInteger, CircleTopicQueryForPeopleType) {
    CircleQueryForPeopleNormal,
    CircleQueryForPeopleInital
};

@interface CircleSessionEntity : SessionEntity

@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSDate * lastUpdate;
@property (nonatomic, retain) NSString * umList;
@property (nonatomic, retain) NSNumber * replyCount;
@property (nonatomic, retain) NSNumber * favorCount;
@property (nonatomic, retain) NSNumber * transferStatus;
@property (nonatomic, retain) NSNumber * contentType;
@property (nonatomic, retain) NSString * contentExt;
@property (nonatomic, retain) EmployeeEntity *topicOwner;
@property (nonatomic, retain) NSDate * initialTimestamp;
@property (nonatomic, retain) NSNumber * valid;
@property (nonatomic, retain) NSNumber * meInvolved;
@property (nonatomic, retain) NSDate * initialDate;
@property (nonatomic, retain) NSString* draft;

@property (nonatomic, retain) NSNumber * contentFolded;

- (BOOL) hasSharedLink;

@end
