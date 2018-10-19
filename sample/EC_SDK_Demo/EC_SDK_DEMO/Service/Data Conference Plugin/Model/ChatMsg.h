//
//  ChatMsg.h
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

#import <Foundation/Foundation.h>

@interface ChatMsg : NSObject

@property (nonatomic,assign) unsigned int nFromUserid;        // user id from who send message
@property (nonatomic,assign) unsigned int nMsgLen;            // message length
@property (nonatomic,assign) int nMsgType;                    // message type
@property (nonatomic,assign) int nFromGroupID;                // group id from which group send message
@property (nonatomic,assign) unsigned int userId;             // user id
@property (nonatomic,assign) unsigned short nSequenceNmuber;  // the sequence of number
@property (nonatomic,assign) long long time;                  // time
@property (nonatomic, copy) NSString *lpMsg;                  // message
@property (nonatomic, copy) NSString *fromUserName;           // user name from who send message

@end
