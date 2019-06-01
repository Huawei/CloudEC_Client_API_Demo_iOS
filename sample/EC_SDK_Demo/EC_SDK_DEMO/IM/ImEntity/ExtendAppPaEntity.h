//
//  ExtendAppPaEntity.h
//  
//
//  Created on 5/24/16.
//
//

#import <Foundation/Foundation.h>
#import "ContactEntity.h"
@interface ExtendAppPaEntity : ContactEntity

@property (nullable, nonatomic, retain) NSString *eName;
@property (nullable, nonatomic, retain) NSString *cName;
@property (nullable, nonatomic, retain) NSNumber *isDiscoveryShow;
@property (nullable, nonatomic, retain) NSNumber *isSessionShow;
@property (nullable, nonatomic, retain) NSNumber *isFirstUse;

@end


