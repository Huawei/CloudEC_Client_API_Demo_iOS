//
//  CallLogMessage.h
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

#import <Foundation/Foundation.h>
typedef NS_ENUM(NSUInteger, CallLogType) {
    UnknownCall   = 0,    // no deal
    MissedCall    = 1,    // miss call
    ReceivedCall  = 2,    // receive call
    OutgointCall  = 3     // outgoing call
};


@interface CallLogMessage : NSObject
@property (nonatomic, strong) NSString *startTime;            // call start time
@property (nonatomic, assign) NSInteger durationTime;         // call duration time
@property (nonatomic, assign) CallLogType callLogType;        // call log type
@property (nonatomic, retain) NSString  * callerPhoneNumber;  // caller phone number
@property (nonatomic, retain) NSString  * calleePhoneNumber;  // callee phone numeber
@property (nonatomic, retain) NSNumber  * callMethod;         // call method
@property (nonatomic, assign) NSInteger callId;               // call Id
@property (nonatomic, assign) BOOL isConnected;               // is connected or not
@end
