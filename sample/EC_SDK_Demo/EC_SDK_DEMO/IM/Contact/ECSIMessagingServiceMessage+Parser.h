#import <Foundation/Foundation.h>
#import "ECSIMessagingServiceMessage.h"
#import "ECSBaseMsg+Parser.h"

@interface ECSMarkRead (Parser)

- (void) parseMsg:(mip::msg::MarkRead&) msg;

@end

@interface ECSMarkReadAck(Parser)

- (id) initWithMsg:(const mip::msg::MarkReadAck*) pMsg;

@end
@interface ECSGetMsgLog (Parser)

- (void) parseMsg:(mip::msg::GetMsgLog&) msg;

@end

@interface ECSGetMsgLogAckMessageLog(Parser)

- (id) initWithMsg:(const mip::msg::GetMsgLogAck::MessageLog*) pMsg;

@end

@interface ECSGetMsgLogAck(Parser)

- (id) initWithMsg:(const mip::msg::GetMsgLogAck*) pMsg;

@end
@interface ECSDelMsgLog (Parser)

- (void) parseMsg:(mip::msg::DelMsgLog&) msg;

@end

@interface ECSDelMsgLogAck(Parser)

- (id) initWithMsg:(const mip::msg::DelMsgLogAck*) pMsg;

@end
@interface ECSChatMessage (Parser)

- (void) parseMsg:(mip::msg::ChatMessage&) msg;
- (id) initWithMsg:(const mip::msg::ChatMessage*) pMsg;
@end

@interface ECSChatMessageAck(Parser)

- (id) initWithMsg:(const mip::msg::ChatMessageAck*) pMsg;

@end
@interface ECSSendGroupMsg (Parser)

- (void) parseMsg:(mip::msg::SendGroupMsg&) msg;
- (id) initWithMsg:(const mip::msg::SendGroupMsg*) pMsg;

@end

@interface ECSSendGroupMsgAck(Parser)

- (id) initWithMsg:(const mip::msg::SendGroupMsgAck*) pMsg;

@end
@interface ECSSendTempGroupMsg (Parser)

- (void) parseMsg:(mip::msg::SendTempGroupMsg&) msg;

@end

@interface ECSSendTempGroupMsgAck(Parser)

- (id) initWithMsg:(const mip::msg::SendTempGroupMsgAck*) pMsg;

@end
@interface ECSGetRoamingMsg (Parser)

- (void) parseMsg:(mip::msg::GetRoamingMsg&) msg;

@end

@interface ECSGetRoamingMsgAckMessage(Parser)

- (id) initWithMsg:(const mip::msg::GetRoamingMsgAck::Message*) pMsg;

@end

@interface ECSGetRoamingMsgAck(Parser)

- (id) initWithMsg:(const mip::msg::GetRoamingMsgAck*) pMsg;

@end
@interface ECSDelRoamingMsg (Parser)

- (void) parseMsg:(mip::msg::DelRoamingMsg&) msg;

@end

@interface ECSDelRoamingMsgAck(Parser)

- (id) initWithMsg:(const mip::msg::DelRoamingMsgAck*) pMsg;

@end
@interface ECSNewsMessage (Parser)

- (id) initWithMsg:(mip::msg::NewsMessage*) msg;

@end

@interface ECSNewsMessageAck(Parser)

- (id) initWithMsg:(const mip::msg::NewsMessageAck*) pMsg;

@end
@interface ECSQueryNewsList (Parser)

- (void) parseMsg:(mip::msg::QueryNewsList&) msg;

@end

@interface ECSQueryNewsListAckRecord(Parser)

- (id) initWithMsg:(const mip::msg::QueryNewsListAck::Record*) pMsg;

@end

@interface ECSQueryNewsListAck(Parser)

- (id) initWithMsg:(const mip::msg::QueryNewsListAck*) pMsg;

@end
@interface ECSQueryNews (Parser)

- (void) parseMsg:(mip::msg::QueryNews&) msg;

@end

@interface ECSQueryNewsAck(Parser)

- (id) initWithMsg:(const mip::msg::QueryNewsAck*) pMsg;

@end

@interface ECSChatMessageNotify(Parser)

- (id) initWithMsg:(const mip::msg::ChatMessageNotify*) pMsg;

@end

@interface ECSGroupMsgNotify(Parser)

- (id) initWithMsg:(const mip::msg::GroupMsgNotify*) pMsg;

@end

@interface ECSGroupChatResultNotify(Parser)

- (id) initWithMsg:(const mip::msg::GroupChatResultNotify*) pMsg;

@end

@interface ECSTempGroupMsgNotify(Parser)

- (id) initWithMsg:(const mip::msg::TempGroupMsgNotify*) pMsg;

@end

@interface ECSUnreadMessagesNotifyChat(Parser)

- (id) initWithMsg:(const mip::msg::UnreadMessagesNotify::Chat*) pMsg;

@end

@interface ECSUnreadMessagesNotify(Parser)

- (id) initWithMsg:(const mip::msg::UnreadMessagesNotify*) pMsg;

@end

@interface ECSMessageReadNotify(Parser)

- (id) initWithMsg:(const mip::msg::MessageReadNotify*) pMsg;

@end

@interface ECSOprMsg(Parser)

- (void) parseMsg:(mip::msg::OprMsg&) msg;
- (id) initWithMsg:(const mip::msg::OprMsg*) pMsg;

@end

@interface ECSOprMsgAck(Parser)

- (id) initWithMsg:(const mip::msg::OprMsgAck*) pMsg;
- (void) parseMsg:(mip::msg::OprMsgAck&) msg;

@end

@interface ECSOprMsgNotify(Parser)

- (id) initWithMsg:(const mip::msg::OprMsgNotify*) pMsg;
- (void) parseMsg:(mip::msg::OprMsgNotify&) msg;

@end
