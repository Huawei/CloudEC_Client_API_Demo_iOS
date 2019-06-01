//
//  NSManagedObject+ECS_Utility.m
//  eSpaceIOSSDK
//
//  Created by heleiwu on 8/22/16.
//  Copyright © 2016 HuaWei. All rights reserved.
//

#import "NSManagedObject+ECS_Utility.h"

@implementation NSManagedObject (ECS_Utility)

- (BOOL)canFillFault {
    // 1) Per Apple, "may" be nil if |managedObject| was deleted but not always.
    if (![self managedObjectContext]) {
        return NO;
    }
    
    // 2) Clone |managedObject|. All Properties will be un-faulted if deleted.
    NSManagedObjectID *objectID             = [self objectID];
    NSManagedObject   *managedObjectClone   = [[self managedObjectContext] objectWithID:objectID];      // Always returns an object. Assumed to exist in the Persistent Store. If it does not exist in the Persistent Store, firing a fault on any of its Properties will throw an exception.
    
    // 3) Fire faults for Properties. If any throw an exception, it was deleted.
    NSEntityDescription *entityDescription  = [managedObjectClone entity];
    NSDictionary        *propertiesByName   = [entityDescription propertiesByName];
    NSArray             *propertyNames      = [propertiesByName allKeys];
    
    @try
    {
        for (id propertyName in propertyNames)
            (void)[managedObjectClone valueForKey:propertyName];
        return YES;                  // Not deleted.
    }
    @catch (NSException *exception)
    {
        if ([[exception name] isEqualToString:NSObjectInaccessibleException])
            return NO;             // Deleted.
        else {
            [exception raise];
        }
    }
}

@end
