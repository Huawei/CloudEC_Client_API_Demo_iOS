#import <Foundation/Foundation.h>
#import "ECSMAARequestOperation.h"
#import "ECSIMessagingServiceMessage.h"

@interface ECSMarkReadOperation : ECSMAARequestOperation

@property (nonatomic, strong) ECSMarkRead* markReadRequest;
@property (nonatomic, strong) ECSMarkReadAck* markReadResponse;

@end

@interface ECSGetMsgLogOperation : ECSMAARequestOperation

@property (nonatomic, strong) ECSGetMsgLog* getMsgLogRequest;
@property (nonatomic, strong) ECSGetMsgLogAck* getMsgLogResponse;

@end

@interface ECSDelMsgLogOperation : ECSMAARequestOperation

@property (nonatomic, strong) ECSDelMsgLog* delMsgLogRequest;
@property (nonatomic, strong) ECSDelMsgLogAck* delMsgLogResponse;

@end

@interface ECSChatMessageOperation : ECSMAASupportResendRequestOperation

@property (nonatomic, strong) ECSChatMessage* chatMessageRequest;
@property (nonatomic, strong) ECSChatMessageAck* chatMessageResponse;

@end

@interface ECSSendGroupMsgOperation : ECSMAASupportResendRequestOperation

@property (nonatomic, strong) ECSSendGroupMsg* sendGroupMsgRequest;
@property (nonatomic, strong) ECSSendGroupMsgAck* sendGroupMsgResponse;

@end

@interface ECSSendTempGroupMsgOperation : ECSMAARequestOperation

@property (nonatomic, strong) ECSSendTempGroupMsg* sendTempGroupMsgRequest;
@property (nonatomic, strong) ECSSendTempGroupMsgAck* sendTempGroupMsgResponse;

@end

@interface ECSGetRoamingMsgOperation : ECSMAARequestOperation

@property (nonatomic, strong) ECSGetRoamingMsg* getRoamingMsgRequest;
@property (nonatomic, strong) ECSGetRoamingMsgAck* getRoamingMsgResponse;

@end

@interface ECSDelRoamingMsgOperation : ECSMAARequestOperation

@property (nonatomic, strong) ECSDelRoamingMsg* delRoamingMsgRequest;
@property (nonatomic, strong) ECSDelRoamingMsgAck* delRoamingMsgResponse;

@end

//@interface ECSNewsMessageOperation : ECSMAARequestOperation
//
//@property (nonatomic, strong) ECSNewsMessage* newsMessageRequest;
//@property (nonatomic, strong) ECSNewsMessageAck* newsMessageResponse;
//
//@end

@interface ECSQueryNewsListOperation : ECSMAARequestOperation

@property (nonatomic, strong) ECSQueryNewsList* queryNewsListRequest;
@property (nonatomic, strong) ECSQueryNewsListAck* queryNewsListResponse;

@end

@interface ECSQueryNewsOperation : ECSMAARequestOperation

@property (nonatomic, strong) ECSQueryNews* queryNewsRequest;
@property (nonatomic, strong) ECSQueryNewsAck* queryNewsResponse;
@end

@interface ECSOprMsgOperation : ECSMAARequestOperation

@property (nonatomic, strong) ECSOprMsg* oprMsgRequest;
@property (nonatomic, strong) ECSOprMsgAck* oprMsgResponse;

@end
