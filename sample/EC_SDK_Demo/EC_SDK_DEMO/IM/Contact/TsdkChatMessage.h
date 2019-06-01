//
//  TsdkChatMessage.h
//  EC_SDK_DEMO
//
//  Created by huawei on 2019/2/15.
//  Copyright © 2019年 cWX160907. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "tsdk_im_def.h"

@interface TsdkChatMessage : NSObject

@property (nonatomic, copy) NSString* to;
@property (nonatomic, copy) NSString* from;
@property (nonatomic, copy) NSString* name;
@property (nonatomic, copy) NSString* type;//chat
@property (nonatomic, copy) NSString* title;
@property (nonatomic, assign) BOOL autoReply;//0
@property (nonatomic, copy) NSString* body;
@property (nonatomic, copy) NSString* body_time;
@property (nonatomic, copy) NSString* body_id;
@property (nonatomic, assign) long long milltime;
@property (nonatomic, assign) NSInteger contentType;//0
@property (nonatomic, copy) NSString* headid;
@property (nonatomic, copy) NSString* appName;
@property (nonatomic, copy) NSString* appID;
@property (nonatomic, assign) NSInteger senderType;
@property (nonatomic, copy) NSString* msgEx;

@end

@interface TsdkSendChatMsgInfo : NSObject
@property (nonatomic,assign) long long region_id;                                          /**< [en][optional]Indicates xxxxxxx.
                                                                 [cn][可选]服务器区域ID */
@property (nonatomic, assign)TSDK_E_CHAT_MSG_TYPE chatType;                                 /**< [en]Indicates xxxxxx.
                                                                 [cn]聊天消息类型 */
@property (nonatomic, assign) TSDK_E_CHAT_MSG_MEDIA_TYPE chatMediaType;                     /**< [en]Indicates media type.
                                                                [cn]聊天消息媒体类型 */
@property (nonatomic, assign) TSDK_E_CHAT_MSG_SOURCE_TYPE sourceType;                        /**< [en]Indicates xxxxx.
                                                                 [cn]聊天消息发送窗口类型 */
@property (nonatomic, copy) NSString * origin;                   /**< [en]Indicates xxxxxxx.
                                                                 [cn]消息来源方(发送方)账号 */
@property (nonatomic, copy) NSString * origin_Name;            /**< [en][optional]Indicates xxxxxxxxxxxx .
                                                                    [cn][可选]消息来源方(发送方)名字 */
@property (nonatomic, copy) NSString * target;                   /**< [en]Indicates xxxxxx.
                                                                 [cn]消息目的方(接收方)账号或者群组ID */
@property (nonatomic, copy) NSString * groupId;               /**< [en]Indicates xxxx.
                                                                 [cn]群组ID（群组消息必填）*/
@property (nonatomic, copy) NSString * content;              /**< [en]Indicates mseeage content.
                                                                 [cn]消息内容 */
@property (nonatomic,assign) long long clientChatId;                                      /**< [en]Indicates the client-generated message ID.
                                                                 [cn]客户端生成的消息ID */
@property (nonatomic,assign) long long atUserCount;                                      /**< [en]Indicates xxxxxxxxxx.
                                                                 [cn]@用户账号个数 */
@property (nonatomic, strong) NSArray * atUserList;                         /**< [en]Indicates xxxxxxx.
                                                                 [cn]@用户账号列表 TSDK_S_IM_USER_BASE_INFO* */

@end

@interface TsdkSetChatMsgReadInfo : NSObject

@property (nonatomic, assign) TSDK_E_HISTORY_CHAT_MSG_TYPE historyMsgType;
@property (nonatomic, copy) NSString *account;
@property (nonatomic, assign) long long msgid;

@end

@interface TsdkQueryHistoryMsgParam : NSObject

@property (nonatomic, assign) TSDK_E_HISTORY_CHAT_MSG_QUERY_TYPE queryType;
@property (nonatomic, assign) TSDK_E_HISTORY_CHAT_MSG_TYPE historyMsgType;
@property (nonatomic, copy) NSString *account;
@property (nonatomic, assign) long long msgid;
@property (nonatomic, assign) int count;

@end

@interface TsdkMsgBaseInfo : NSObject

@property (nonatomic, assign) long long msgId;

@end

@interface TsdkDeleteHistoryMsgParam : NSObject

@property (nonatomic, assign) TSDK_E_CHAT_MSG_BASE_TYPE msgType;
@property (nonatomic, assign) TSDK_E_DEl_HISTORY_CHAT_MSG_OP_TYPE  opType;
@property (nonatomic, copy) NSString *account;
@property (nonatomic, assign) NSInteger count;
@property (nonatomic, strong) NSArray* msgIdList;    //TsdkMsgBaseInfo

@end


@interface TsdkImUserBaseInfo : NSObject

@property (nonatomic, copy) NSString *account;

@end


@interface TsdkChatMessageInfo : NSObject

@property (nonatomic, assign) int regionId;                                //[可选]服务器区域ID
@property (nonatomic, assign) TSDK_E_CHAT_MSG_TYPE chatType;               //聊天消息类型
@property (nonatomic, assign) TSDK_E_CHAT_MSG_MEDIA_TYPE chatMediaType;    //聊天消息媒体类型
@property (nonatomic, assign) TSDK_E_CHAT_MSG_SOURCE_TYPE sourceType;      //聊天消息发送窗口类型
@property (nonatomic, copy) NSString *account;                           //消息来源方(发送方)账号
@property (nonatomic, copy) NSString *name;                              //消息来源方(发送方)名字
@property (nonatomic, copy) NSString *target;                            //消息目的方(接收方)账号或者群组ID
@property (nonatomic, copy) NSString *groupId;                           //群组ID(群组消息时有效)
@property (nonatomic, copy) NSString *content;                           //消息内容
@property (nonatomic, assign) long long clientMsgId;                             //客户端生成的消息ID
@property (nonatomic, assign) long long serverMsgId;                             //服务端生成的消息ID
@property (nonatomic, copy) NSString *groupName;                         //群组名称
@property (nonatomic, copy) NSString *groupNameEn;                       //群组英文名称
@property (nonatomic, assign) long long utcStamp;                                //UTC时间
@property (nonatomic, assign) long long serverDeliverTime;                       //服务器发送的时间
@property (nonatomic, assign) int atUserCount;                             //@用户账号个数
@property (nonatomic, strong) NSArray* atUserList;                         //@用户账号列表  TsdkImUserBaseInfo

@end

@interface TsdkQueryHistoryMsgResult : NSObject

@property (nonatomic, assign) TSDK_E_HISTORY_CHAT_MSG_QUERY_TYPE queryType;
@property (nonatomic, assign) TSDK_E_HISTORY_CHAT_MSG_TYPE historyMsgType;
@property (nonatomic, copy) NSString *account;
@property (nonatomic, assign) int totalCount;
@property (nonatomic, assign) int chatMsgCount;
@property (nonatomic, strong) NSArray* chatMsgList;   // TsdkChatMessageInfo

@end

@interface TsdkBatchChatMessageInfo : NSObject // TSDK_S_BATCH_CHAT_MSG_INFO

@property (nonatomic, assign) int count;
@property (nonatomic, strong) NSArray *messageList;  //TsdkChatMessageInfo
@property (nonatomic, assign) int unReadCount;
@property (nonatomic, assign) long long minMsgId;
@property (nonatomic, assign) long long maxMsgId;
@property (nonatomic, assign) BOOL isBeAt;

@end

@interface TsdkSendChatMsgResult : NSObject  // TSDK_S_SEND_CHAT_MSG_RESULT

@property (nonatomic, copy) NSString *target;
@property (nonatomic, assign) long long utcStamp;
@property (nonatomic, assign) long long clientMsgId;
@property (nonatomic, assign) long long serverMsgId;
@property (nonatomic, assign) int result;

@end

@interface TsdkMsgWithDrawReqParam : NSObject  // TSDK_S_SEND_CHAT_MSG_RESULT

@property (nonatomic, copy) NSString *origin;
@property (nonatomic, copy) NSString *originname;
@property (nonatomic, copy) NSString *target;
@property (nonatomic, assign) TSDK_E_CHAT_MSG_BASE_TYPE withdrawMsgType;
@property (nonatomic, copy) NSString *groupName;
@property (nonatomic, assign) int withdrawMsgCount;
@property (nonatomic, strong) NSArray *msgList;         //TSDK_S_MSG_BASE_INFO
@property (nonatomic, assign) BOOL isIncludeLastMsg;

@end

@interface TsdkMsgWithDrawResult : NSObject  // TSDK_S_CHAT_MSG_WITHDRAW_RESULT

@property (nonatomic, copy) NSString *origin;
@property (nonatomic, copy) NSString *target;
@property (nonatomic, assign) TSDK_E_CHAT_MSG_BASE_TYPE withdrawMsgType;
@property (nonatomic, assign) int withdrawMsgCount;
@property (nonatomic, strong) NSArray *msgList;         //TSDK_S_MSG_BASE_INFO
@property (nonatomic, assign) int timeout;
@property (nonatomic, assign) int result;

@end

@interface TsdkMsgWithDrawInfo : NSObject  // TSDK_S_CHAT_MSG_WITHDRAW_INFO

@property (nonatomic, copy) NSString *origin;
@property (nonatomic, copy) NSString *target;
@property (nonatomic, assign) TSDK_E_CHAT_MSG_BASE_TYPE withdrawMsgType;
@property (nonatomic, assign) int withdrawMsgCount;
@property (nonatomic, strong) NSArray *msgList;         //TSDK_S_MSG_BASE_INFO
@property (nonatomic, assign) long long unreadMsgId;

@end




