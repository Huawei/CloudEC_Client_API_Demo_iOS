//
//  ConfAttendee+StructParase.h
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

#import "ConfAttendee.h"
#import "tsdk_conference_def.h"
@interface ConfAttendee (StructParase)
+(ConfAttendee *)returnConfAttendeeWith:(TSDK_S_ATTENDEE_BASE_INFO)attendee;
@end
