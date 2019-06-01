//
//  LocalAppPaEntity.h
//  
//
//  Created on 5/18/16.
//
//

#import <Foundation/Foundation.h>
#import "ExtendAppPaEntity.h"

typedef NS_ENUM(NSInteger, LocalAppPaLocation){
    LocalAppPaSUnknown = 0,
    LocalAppPaSRecentSession = 1,
    LocalAppPaSDiscovery = 2
};


@interface LocalAppPaEntity : ExtendAppPaEntity

@property (nullable, nonatomic, retain) NSNumber *isUsed;

@end

