//
//  CallData.h
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

#import <Foundation/Foundation.h>

//Indicates call status enum
typedef NS_ENUM(NSUInteger, CallStatus)
{
    CallStatusIdle,
    CallStatusConneting,       //call is connecting
    CallStatusTalking,         //call is connected
    CallStatusEnd              //call is ended
};

//Inidcates call type
typedef NS_ENUM(NSUInteger, CallType)
{
    AudioCallType,
    VideoCallType
};

@interface CallData : NSObject
@property(nonatomic, assign)unsigned int callId;
@property(nonatomic, assign)CallStatus status;
@property(nonatomic, assign)CallType type;
@property(nonatomic, copy)NSString* remoteNumber;
@property(nonatomic, assign)BOOL isSelfCaller;      //whether is your start call

@end
