//
//  CallLogEntity.h
//
//  Created on 8/11/15.
//  Copyright (c) 2017 Huawei Tech. Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "MessageEntity.h"

typedef NS_ENUM(NSUInteger, ESpaceCallLogType) {
    ESpaceUnknownCall   = 0,    //未作处理
    ESpaceMissedCall    = 1,    //未接到
    ESpaceReceivedCall  = 2,    //拨入
    ESpaceOutgointCall  = 3     //拨出
};


@interface CallLogEntity : MessageEntity

@property (nonatomic, retain) NSNumber  * duration;
@property (nonatomic, retain) NSNumber  * callType;
@property (nonatomic, retain) NSString  * callerPhoneNumber;  //主叫
@property (nonatomic, retain) NSString  * calleePhoneNumber;  //被叫
@property (nonatomic, retain) NSNumber  * callMethod;
@end
