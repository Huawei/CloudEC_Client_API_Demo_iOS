#import <Foundation/Foundation.h>
//#import "ECSBaseMsg.h"

//@interface ECSMarkRead : NSObject
//
//@property (nonatomic, copy) NSString* ActionType;//MarkRead
//@property (nonatomic, assign) NSInteger markType;//0
//@property (nonatomic, copy) NSString* from;
//@property (nonatomic, copy) NSString* to;
//@property (nonatomic, copy) NSString* id;
//@property (nonatomic, assign) NSInteger msgTag;//0
//
//@end
//
//@interface ECSMarkReadAck : ECSRootErrorMsg
//
//
//@end
//
//@interface ECSGetMsgLog : NSObject
//
//@property (nonatomic, copy) NSString* ActionType;//GetMsgLog
//@property (nonatomic, assign) NSInteger messageType;//0
//@property (nonatomic, copy) NSString* user;
//@property (nonatomic, assign) NSInteger startTime;//0
//@property (nonatomic, assign) NSInteger endTime;//0
//@property (nonatomic, assign) NSInteger pageSize;//0
//@property (nonatomic, assign) NSInteger pageNum;//0
//@property (nonatomic, copy) NSString* targetID;
//@property (nonatomic, assign) NSInteger recordAmount;//-1
//
//@end
//
//@interface ECSGetMsgLogAckMessageLog : NSObject
//
//@property (nonatomic, copy) NSString* id;
//@property (nonatomic, copy) NSString* to;
//@property (nonatomic, copy) NSString* from;
//@property (nonatomic, copy) NSString* type;
//@property (nonatomic, copy) NSString* name;
//@property (nonatomic, copy) NSString* body;
//@property (nonatomic, assign) NSInteger time;//0
//@property (nonatomic, copy) NSString* title;
//@property (nonatomic, assign) short autoReply;//0
//@property (nonatomic, copy) NSString* owner;
//
//@end
//
//@interface ECSGetMsgLogAck : ECSRootErrorMsg
//
//@property (nonatomic, assign) NSInteger recordAmount;//0
//@property (nonatomic, strong) NSArray* logList;//ECSGetMsgLogAckMessageLog array
//
//@end
//
//@interface ECSDelMsgLog : NSObject
//
//@property (nonatomic, copy) NSString* ActionType;//DelMsgLog
//@property (nonatomic, assign) NSInteger messageType;//0
//@property (nonatomic, copy) NSString* user;
//@property (nonatomic, assign) short type;//0
//@property (nonatomic, copy) NSString* id;
//@property (nonatomic, copy) NSString* who;
//
//@end
//
//@interface ECSDelMsgLogAck : ECSRootErrorMsg
//
//
//@end
//
@interface ECSChatMessage : NSObject

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

//
//@interface ECSChatMessageAck : ECSMessageErrorMsg
//
//@property (nonatomic, copy) NSString* id;
//@property (nonatomic, assign) NSInteger unread;//0
//@property (nonatomic, assign) long long time;
//@property (nonatomic, assign) long sno;
//
//@end
//
//@interface ECSSendGroupMsg : NSObject
//
//@property (nonatomic, copy) NSString* to;
//@property (nonatomic, copy) NSString* from;
//@property (nonatomic, copy) NSString* type;//groupchat
//@property (nonatomic, copy) NSString* owner;
//@property (nonatomic, copy) NSString* id;
//@property (nonatomic, assign) NSInteger time;//0
//@property (nonatomic, copy) NSString* name;
//@property (nonatomic, copy) NSString* jid;
//@property (nonatomic, copy) NSString* body;
//@property (nonatomic, assign) NSInteger groupType;//0
//@property (nonatomic, assign) NSInteger contentType;//0
//@property (nonatomic, assign) long long milltime;
//@property (nonatomic, copy) NSString* headid;
//@property (nonatomic, copy) NSString* atUserList;
//@property (nonatomic, copy) NSString* appName;
//@property (nonatomic, copy) NSString* appID;
//@property (nonatomic, assign) NSInteger senderType;
//@property (nonatomic, copy) NSString *msgEx;
//@end
//
//@interface ECSSendGroupMsgAck : ECSMessageErrorMsg
//
//@property (nonatomic, copy) NSString* id;
//@property (nonatomic, assign) NSInteger unread;//0
//@property (nonatomic, assign) long long time;
//@property (nonatomic, assign) long sno;
//
//@end
//
//@interface ECSSendTempGroupMsg : NSObject
//
//@property (nonatomic, copy) NSString* to;
//@property (nonatomic, copy) NSString* from;
//@property (nonatomic, copy) NSString* type;//tempgroupchat
//@property (nonatomic, copy) NSString* body;
//@property (nonatomic, copy) NSString* body_jid;
//
//@end
//
//@interface ECSSendTempGroupMsgAck : ECSMessageErrorMsg
//
//
//@end
//
//@interface ECSGetRoamingMsg : NSObject
//
//@property (nonatomic, copy) NSString* ActionType;//GetRoamingMsg
//@property (nonatomic, copy) NSString* user;
//@property (nonatomic, assign) NSInteger msgTag;
//@property (nonatomic, copy) NSString* msgID;
//@property (nonatomic, copy) NSString* targetID;
//@property (nonatomic, assign) NSInteger recordAmount;
//
//@end
//
//@interface ECSGetRoamingMsgAckMessage : NSObject
//
//@property (nonatomic, copy) NSString* id;
//@property (nonatomic, copy) NSString* to;
//@property (nonatomic, copy) NSString* from;
//@property (nonatomic, assign) NSInteger msgTag;
//@property (nonatomic, copy) NSString* name;
//@property (nonatomic, copy) NSString* body;
//@property (nonatomic, assign) long long milltime;
//@property (nonatomic, assign) short autoReply;//1
//@property (nonatomic, copy) NSString* owner;
//@property (nonatomic, assign) NSInteger contentType;
//@property (nonatomic, copy) NSString* cid;
//@property (nonatomic, assign) NSInteger senderType;
//@property (nonatomic, copy) NSString* appName;
//@property (nonatomic, copy) NSString *appID;
//@property (nonatomic, copy) NSString* msgEx;
//@end
//
//@interface ECSGetRoamingMsgAck : ECSRootErrorMsg
//
//@property (nonatomic, assign) NSInteger messageNum;
//@property (nonatomic, copy) NSString* startMsgID;
//@property (nonatomic, copy) NSString* endMsgID;
//@property (nonatomic, strong) NSArray* logList;//ECSGetRoamingMsgAckMessage array
//
//@end
//
//@interface ECSDelRoamingMsg : NSObject
//
//@property (nonatomic, copy) NSString* ActionType;//DelRoamingMsg
//@property (nonatomic, assign) NSInteger msgTag;
//@property (nonatomic, copy) NSString* user;
//@property (nonatomic, copy) NSString* targetid;
//@property (nonatomic, assign) short type;
//@property (nonatomic, strong) NSArray* msgList;//NSString array
//
//@end
//
//@interface ECSDelRoamingMsgAck : ECSRootErrorMsg
//
//
//@end
//
//@interface ECSNewsMessage : NSObject
//
//@property (nonatomic, copy) NSString* title;
//@property (nonatomic, copy) NSString* id;
//
//@end
//
//@interface ECSNewsMessageAck : ECSMessageErrorMsg
//
//
//@end
//
//@interface ECSQueryNewsList : NSObject
//
//@property (nonatomic, copy) NSString* ActionType;//QueryNewsList
//@property (nonatomic, copy) NSString* user;
//@property (nonatomic, assign) NSInteger count;//0
//@property (nonatomic, assign) long long timestamp;//0
//
//@end
//
//@interface ECSQueryNewsListAckRecord : NSObject
//
//@property (nonatomic, copy) NSString* title;
//@property (nonatomic, copy) NSString* id;
//@property (nonatomic, assign) long long time;//0
//
//@end
//
//@interface ECSQueryNewsListAck : ECSRootErrorMsg
//
//@property (nonatomic, strong) NSArray* list;//ECSQueryNewsListAckRecord array
//
//@end
//
//@interface ECSQueryNews : NSObject
//
//@property (nonatomic, copy) NSString* ActionType;//QueryNews
//@property (nonatomic, copy) NSString* user;
//@property (nonatomic, copy) NSString* id;
//
//@end
//
//@interface ECSQueryNewsAck : ECSRootErrorMsg
//
//@property (nonatomic, copy) NSString* content;
//
//@end
//
//@interface ECSChatMessageNotify : NSObject
//
//@property (nonatomic, copy) NSString* from;
//@property (nonatomic, copy) NSString* to;
//@property (nonatomic, copy) NSString* name;
//@property (nonatomic, copy) NSString* type;//chat
//@property (nonatomic, copy) NSString* body;
//@property (nonatomic, copy) NSString* body_time;
//
//@end
//
//@interface ECSGroupMsgNotify : NSObject
//
//@property (nonatomic, copy) NSString* from;
//@property (nonatomic, copy) NSString* to;
//@property (nonatomic, copy) NSString* type;//groupchat
//@property (nonatomic, copy) NSString* body;
//@property (nonatomic, copy) NSString* body_jid;
//@property (nonatomic, copy) NSString* body_name;
//@property (nonatomic, assign) NSInteger body_time;//0
//@property (nonatomic, assign) NSInteger groupType;//0
//
//@end
//
//@interface ECSGroupChatResultNotify : NSObject
//
//@property (nonatomic, copy) NSString* from;
//@property (nonatomic, copy) NSString* to;
//@property (nonatomic, copy) NSString* type;//groupchatundeliver
//@property (nonatomic, copy) NSString* body;
//@property (nonatomic, copy) NSString* body_jid;
//@property (nonatomic, copy) NSString* reason;
//@property (nonatomic, assign) NSInteger groupType;//0
//
//@end
//
//@interface ECSTempGroupMsgNotify : NSObject
//
//@property (nonatomic, copy) NSString* from;
//@property (nonatomic, copy) NSString* to;
//@property (nonatomic, copy) NSString* type;//tempgroupchat
//@property (nonatomic, copy) NSString* body;
//@property (nonatomic, copy) NSString* body_jid;
//@property (nonatomic, copy) NSString* body_time;
//@property (nonatomic, copy) NSString* body_name;
//
//@end
//
//@interface ECSUnreadMessagesNotifyChat : NSObject
//
//@property (nonatomic, copy) NSString* id;
//@property (nonatomic, copy) NSString* to;
//@property (nonatomic, copy) NSString* from;
//@property (nonatomic, copy) NSString* name;
//@property (nonatomic, copy) NSString* body;
//@property (nonatomic, assign) long long time;
//@property (nonatomic, copy) NSString* title;
//@property (nonatomic, assign) short autoReply;//1
//@property (nonatomic, copy) NSString* owner;
//@property (nonatomic, assign) NSInteger contentType;
//@property (nonatomic, assign) NSInteger senderType;
//@property (nonatomic, copy) NSString *appName;
//@property (nonatomic, copy) NSString *appID;
//@property (nonatomic, copy) NSString* msgEx;
//
//@end
//
//@interface ECSUnreadMessagesNotify : NSObject
//
//@property (nonatomic, copy) NSString* user;
//@property (nonatomic, assign) NSInteger msgTag;
//@property (nonatomic, strong) NSArray* chatList;//ECSUnreadMessagesNotifyChat array
//@property (nonatomic, assign) NSInteger num;
//@property (nonatomic, copy) NSString* maxID;
//@property (nonatomic, copy) NSString* minID;
//@property (nonatomic, assign) NSInteger isAt;
//
//
//@end
//
//@interface ECSMessageReadNotify : NSObject
//
//@property (nonatomic, assign) NSInteger msgTag;
//@property (nonatomic, copy) NSString* from;
//@property (nonatomic, copy) NSString* to;
//@property (nonatomic, copy) NSString* id;
//@end
//
//@interface ECSOprMsg : NSObject
//
//@property (nonatomic, copy) NSString* ActionType;//OprMsg
//@property (nonatomic, copy) NSString* user;
//@property (nonatomic, assign) short oprType;
//@property (nonatomic, assign) NSInteger messageType;
//@property (nonatomic, copy) NSString* sender;
//@property (nonatomic, copy) NSString* targetId;
//@property (nonatomic, strong) NSArray* msgIDList;//NSString array
//@property (nonatomic, assign) short lastMsgFlag;
//
//@end
//
//@interface ECSOprMsgAck : ECSRootErrorMsg
//@property (nonatomic, assign) NSInteger timeoutInfo;
//
//@end
//
//@interface ECSOprMsgNotify : NSObject
//
//@property (nonatomic, assign) short oprType;
//@property (nonatomic, copy) NSString* oprUser;
//@property (nonatomic, assign) NSInteger messageType;
//@property (nonatomic, copy) NSString* targetId;
//@property (nonatomic, strong) NSArray* msgIDList;//NSString array
//@property (nonatomic, copy) NSString* originAppId;
//@property (nonatomic, copy) NSString* receiver;
//@property (nonatomic, copy) NSString* messageId;
//@property (nonatomic, assign) BOOL isFromRemote;
//@property (nonatomic, assign) BOOL isOnlyPcCooperation;
//
//@end
