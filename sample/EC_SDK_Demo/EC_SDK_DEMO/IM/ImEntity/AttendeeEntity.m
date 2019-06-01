//
//  AttendeeEntity.m
//  
//
//  Created by jinlu on 15/7/15.
//
//

#import "AttendeeEntity.h"
#import "ContactEntity.h"
#import "MeetingSessionEntity.h"
#import "ECSUtils.h"

@implementation AttendeeEntity

@dynamic auth;
@dynamic ecspaceAccount;
@dynamic mediaType;
@dynamic number;
@dynamic role;
@dynamic state;
@dynamic mediaState;
@dynamic userID;
@dynamic attendeeOf;
@dynamic convenerOf;
@dynamic masterOf;
@dynamic matchedContact;

//ECSEntryptCoreDataStringProp(displayName, DisplayName)
//ECSEntryptCoreDataStringProp(domain, Domain)

@end
