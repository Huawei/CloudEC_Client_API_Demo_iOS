//
//  MeetingSessionEntity.m
//  
//
//  Created by jinlu on 15/8/3.
//
//

#import "MeetingSessionEntity.h"
#import "AttendeeEntity.h"
#import "ECSUtils.h"

@implementation MeetingSessionEntity

@dynamic confID;
@dynamic confType;
@dynamic endTime;
@dynamic isFiltered;
@dynamic mediaType;
@dynamic parentConfID;
@dynamic srtpPolicy;
@dynamic startTime;
@dynamic status;
@dynamic tlsPolicy;
@dynamic confCategory;
@dynamic loadFullInfo;
@dynamic attendees;
@dynamic convener;
@dynamic master;

//ECSEntryptCoreDataStringProp(accesscode, Accesscode)
//ECSEntryptCoreDataStringProp(chairmanPwd, ChairmanPwd)
//ECSEntryptCoreDataStringProp(memberPwd, MemberPwd)
//ECSEntryptCoreDataStringProp(outerAccesscode, OuterAccesscode)
//ECSEntryptCoreDataStringProp(passcode, Passcode)
//ECSEntryptCoreDataStringProp(subject, Subject)
//ECSEntryptCoreDataStringProp(dataConfInfo, DataConfInfo)

@end
