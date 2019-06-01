//
//  MeetingSessionEntity.h
//  
//
//  Created on 15/8/3.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class AttendeeEntity;

@interface MeetingSessionEntity : NSManagedObject

@property (nonatomic, retain) NSString * accesscode;
@property (nonatomic, retain) NSString * chairmanPwd;
@property (nonatomic, retain) NSString * confID;
@property (nonatomic, retain) NSNumber * confType;
@property (nonatomic, retain) NSDate * endTime;
@property (nonatomic, retain) NSNumber * isFiltered;
@property (nonatomic, retain) NSNumber * mediaType;
@property (nonatomic, retain) NSString * memberPwd;
@property (nonatomic, retain) NSString * outerAccesscode;
@property (nonatomic, retain) NSString * parentConfID;
@property (nonatomic, retain) NSString * passcode;
@property (nonatomic, retain) NSNumber * srtpPolicy;
@property (nonatomic, retain) NSDate * startTime;
@property (nonatomic, retain) NSNumber * status;
@property (nonatomic, retain) NSString * subject;
@property (nonatomic, retain) NSNumber * tlsPolicy;
@property (nonatomic, retain) NSString * dataConfInfo;
@property (nonatomic, retain) NSNumber * confCategory;
@property (nonatomic, retain) NSNumber * loadFullInfo;
@property (nonatomic, retain) NSSet *attendees;
@property (nonatomic, retain) AttendeeEntity *convener;
@property (nonatomic, retain) AttendeeEntity *master;
@end

@interface MeetingSessionEntity (CoreDataGeneratedAccessors)

- (void)addAttendeesObject:(AttendeeEntity *)value;
- (void)removeAttendeesObject:(AttendeeEntity *)value;
- (void)addAttendees:(NSSet *)values;
- (void)removeAttendees:(NSSet *)values;

@end
