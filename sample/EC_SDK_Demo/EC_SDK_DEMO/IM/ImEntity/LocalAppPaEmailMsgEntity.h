//
//  LocalAppPaEmailMsgEntity.h
//  
//
//  Created on 5/28/16.
//
//

#import <Foundation/Foundation.h>
#import "LocalAppPaMsgEntity.h"

@interface LocalAppPaEmailMsgEntity : LocalAppPaMsgEntity

@property (nullable, nonatomic, retain) NSString *senderAccount;
@property (nullable, nonatomic, retain) NSString *senderName;
@property (nullable, nonatomic, retain) NSString *senderEmailAdress;
@property (nullable, nonatomic, retain) NSString *emailTitle;
@property (nullable, nonatomic, retain) NSString *emailDigest;
@property (nullable, nonatomic, retain) NSString *emailID;
@property (nullable, nonatomic, retain) NSNumber *hasAttachment;
@property (nullable, nonatomic, retain) NSString *vipIndicators;
@property (nullable, nonatomic, retain) EmployeeEntity *sender;

@end



