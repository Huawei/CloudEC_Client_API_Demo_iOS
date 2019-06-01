//
//  VoiceMailMesageEntity.h
//  
//
//  Created on 15/9/8.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class EmployeeEntity;

@interface VoiceMailMesageEntity : NSManagedObject

@property (nonatomic, retain) NSString * messageId;
@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) NSString * from;
@property (nonatomic, retain) NSString * domain;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * time;
@property (nonatomic, retain) NSNumber * duration;
@property (nonatomic, retain) NSNumber * status;
@property (nonatomic, retain) NSString * importance;
@property (nonatomic, retain) NSString * sensitivity;
@property (nonatomic, retain) NSString * shortCode;
@property (nonatomic, retain) EmployeeEntity *matchPerson;

@end
