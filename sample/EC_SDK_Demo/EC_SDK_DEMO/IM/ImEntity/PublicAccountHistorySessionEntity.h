//
//  PublicAccountHistorySessionEntity.h
//  
//
//  Created on 15/9/26.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "PublicAccountSessionEntity.h"

@class PublicAccountEntity;

@interface PublicAccountHistorySessionEntity : PublicAccountSessionEntity

@property (nonatomic, retain) PublicAccountEntity *paEntity;

@end
