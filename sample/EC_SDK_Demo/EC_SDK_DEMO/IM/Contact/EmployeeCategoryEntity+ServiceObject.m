//
//  EmployeeCategoryEntity+ServiceObject.m
//  eSpace
//
//  Created by heleiwu on 7/16/15.
//  Copyright (c) 2015 www.huawei.com. All rights reserved.
//

#import "EmployeeCategoryEntity+ServiceObject.h"
#import "ESpaceContactService.h"
#import "eSpaceDBService.h"

@implementation EmployeeCategoryEntity (ServiceObject)

- (NSArray *)onlineMembers {
    NSMutableArray *olEmployees = [NSMutableArray arrayWithCapacity:0];
    for (id obj in self.members) {
        // Treat all CustomContactEntity as offline.
        if ([obj isKindOfClass:[EmployeeEntity class]]) {
            EmployeeEntity *employee = (EmployeeEntity *)obj;
            EspaceUserOnlineStatus* onlineStatus = [[ESpaceContactService sharedInstance] onlineStatusForUser:employee.account forceSubscribe:![employee.isFriend boolValue]];
            if ([onlineStatus isOnline]) {
                [olEmployees addObject:employee];
            }
        }
    }
    
    return olEmployees;
}

+ (NSArray *)allCategoryEntities {
    NSManagedObjectContext *context = [LOCAL_DATA_MANAGER managedObjectContext];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"idx != NULL"];
    NSArray *groups = [ESpaceLocalDataManager fetchObjects:predicate inEnitity:@"EmployeeCategoryEntity" inContext:context];
    if (groups.count > 0) {
        NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"idx" ascending:YES];
        groups = [groups sortedArrayUsingDescriptors:@[sort]];
    }
    return groups;
}

+ (EmployeeCategoryEntity *)categoryWithID:(NSNumber *)idx {
    NSManagedObjectContext *context = [LOCAL_DATA_MANAGER managedObjectContext];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"idx == %@", idx];
    NSArray *groups = [ESpaceLocalDataManager fetchObjects:predicate inEnitity:@"EmployeeCategoryEntity" inContext:context];
    return [groups firstObject];
}
@end
