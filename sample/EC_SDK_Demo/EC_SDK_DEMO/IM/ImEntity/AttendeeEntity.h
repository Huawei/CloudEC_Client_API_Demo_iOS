//
//  AttendeeEntity.h
//  
//
//  Created by on 15/7/15.
//  Copyright (c) 2017 Huawei Tech. Co., Ltd. All rights reserved.


#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ContactEntity, MeetingSessionEntity;

@interface AttendeeEntity : NSManagedObject

@property (nonatomic, retain) NSNumber * auth;
@property (nonatomic, retain) NSString * displayName;
@property (nonatomic, retain) NSString * domain;
@property (nonatomic, retain) NSString * ecspaceAccount;
@property (nonatomic, retain) NSNumber * mediaType;
@property (nonatomic, retain) NSString * number;
@property (nonatomic, retain) NSNumber * role;
@property (nonatomic, retain) NSNumber * state;
@property (nonatomic, retain) NSNumber * mediaState;
@property (nonatomic, retain) NSString * userID;
@property (nonatomic, retain) MeetingSessionEntity *attendeeOf;
@property (nonatomic, retain) MeetingSessionEntity *convenerOf;
@property (nonatomic, retain) MeetingSessionEntity *masterOf;
@property (nonatomic, retain) ContactEntity *matchedContact;

@end
