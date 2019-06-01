#import "ECSIMessagingServiceMessage+Parser.h"
@implementation ECSMarkRead

- (void) parseMsg:(mip::msg::MarkRead&) msg {
    msg.ActionType() = [self.ActionType UTF8String];
    msg.markType() = (int32_t)self.markType;
    msg.from() = [self.from UTF8String];
    msg.to() = [self.to UTF8String];
    msg.id() = [self.id UTF8String];
    msg.msgTag() = (int32_t)self.msgTag;
}

@end

@implementation ECSMarkReadAck

- (id) initWithMsg:(const mip::msg::MarkReadAck*) pMsg {
    if( self = [super initWithMsg:pMsg]) {
    }
    return self;
}

@end

@implementation ECSGetMsgLog

- (void) parseMsg:(mip::msg::GetMsgLog&) msg {
    msg.ActionType() = [self.ActionType UTF8String];
    msg.messageType() = (int32_t)self.messageType;
    msg.user() = [self.user UTF8String];
    msg.startTime() = (int32_t)self.startTime;
    msg.endTime() = (int32_t)self.endTime;
    msg.pageSize() = (int32_t)self.pageSize;
    msg.pageNum() = (int32_t)self.pageNum;
    msg.targetID() = [self.targetID UTF8String];
    msg.recordAmount() = (int32_t)self.recordAmount;
}

@end

@implementation ECSGetMsgLogAckMessageLog

- (id) initWithMsg:(const mip::msg::GetMsgLogAck::MessageLog*) pMsg {
    if( self = [super init]) {
        self.id = [NSString stringWithUTF8String:pMsg->id().data()];
        self.to = [NSString stringWithUTF8String:pMsg->to().data()];
        self.from = [NSString stringWithUTF8String:pMsg->from().data()];
        self.type = [NSString stringWithUTF8String:pMsg->type().data()];
        self.name = [NSString stringWithUTF8String:pMsg->name().data()];
        self.body = [NSString stringWithUTF8String:pMsg->body().data()];
        self.time = pMsg->time();
        self.title = [NSString stringWithUTF8String:pMsg->title().data()];
        self.autoReply = pMsg->autoReply();
        self.owner = [NSString stringWithUTF8String:pMsg->owner().data()];
    }
    return self;
}

@end

@implementation ECSGetMsgLogAck

- (id) initWithMsg:(const mip::msg::GetMsgLogAck*) pMsg {
    if( self = [super initWithMsg:pMsg]) {
        self.recordAmount = pMsg->recordAmount();
        
        NSMutableArray* __logList = [[NSMutableArray alloc] init];
        for (std::vector<mip::msg::GetMsgLogAck::MessageLog>::const_iterator it = pMsg->logList().begin(); it != pMsg->logList().end(); ++it) {
            [__logList addObject:[[ECSGetMsgLogAckMessageLog alloc] initWithMsg:&(*it)]];
        }
        self.logList = __logList;
        
    }
    return self;
}

@end

@implementation ECSDelMsgLog

- (void) parseMsg:(mip::msg::DelMsgLog&) msg {
    msg.ActionType() = [self.ActionType UTF8String];
    msg.messageType() = (int32_t)self.messageType;
    msg.user() = [self.user UTF8String];
    msg.type() = self.type;
    msg.id() = [self.id UTF8String];
    msg.who() = [self.who UTF8String];
}

@end

@implementation ECSDelMsgLogAck

- (id) initWithMsg:(const mip::msg::DelMsgLogAck*) pMsg {
    if( self = [super initWithMsg:pMsg]) {
    }
    return self;
}

@end

@implementation ECSChatMessage

- (void) parseMsg:(mip::msg::ChatMessage&) msg {
    msg.to() = [self.to UTF8String];
    msg.from() = [self.from UTF8String];
    msg.name() = [self.name UTF8String];
    msg.type() = [self.type UTF8String];
    msg.title() = [self.title UTF8String];
    msg.autoReply() = self.autoReply;
    msg.body() = [self.body UTF8String];
    msg.body_time() = [self.body_time UTF8String];
    msg.body_id() = [self.body_id UTF8String];
    msg.body_milltime() = self.milltime;
    msg.contentType() = (int32_t)self.contentType;
    msg.headid() = [self.headid UTF8String];
    msg.appID() = [self.appID UTF8String];
    msg.appName() = [self.appName UTF8String];
    msg.senderType() = (int32_t)self.senderType;
    msg.msgEx() = [self.msgEx UTF8String];
}

- (id) initWithMsg:(const mip::msg::ChatMessage*) pMsg {
    if (self = [super init]) {
        self.to = [NSString stringWithUTF8String:pMsg->to().data()];
        self.from = [NSString stringWithUTF8String:pMsg->from().data()];
        self.name = [NSString stringWithUTF8String:pMsg->name().data()];
        self.type = [NSString stringWithUTF8String:pMsg->type().data()];
        self.title = [NSString stringWithUTF8String:pMsg->title().data()];
        self.autoReply = pMsg->autoReply();
        self.body = [NSString stringWithUTF8String:pMsg->body().data()];
        self.body_time = [NSString stringWithUTF8String:pMsg->body_time().data()];
        self.body_id = [NSString stringWithUTF8String:pMsg->body_id().data()];
        self.milltime = pMsg->body_milltime();
        self.contentType = pMsg->contentType();
        self.headid = [NSString stringWithUTF8String:pMsg->headid().data()];
        self.appID = [NSString stringWithUTF8String:pMsg->appID().data()];
        self.appName = [NSString stringWithUTF8String:pMsg->appName().data()];
        self.senderType = (int32_t)pMsg->senderType();
        self.msgEx = [NSString stringWithUTF8String:pMsg->msgEx().data()];
    }
    return self;
}

@end

@implementation ECSChatMessageAck

- (id) initWithMsg:(const mip::msg::ChatMessageAck*) pMsg {
    if( self = [super initWithMsg:pMsg]) {
        self.id = [NSString stringWithUTF8String:pMsg->id().data()];
        self.unread = pMsg->unread();
        self.time = pMsg->time();
    }
    return self;
}

@end

@implementation ECSSendGroupMsg

- (void) parseMsg:(mip::msg::SendGroupMsg&) msg {
    msg.to() = [self.to UTF8String];
    msg.from() = [self.from UTF8String];
    msg.type() = [self.type UTF8String];
    msg.owner() = [self.owner UTF8String];
    msg.id() = [self.id UTF8String];
    msg.time() = (int32_t)self.time;
    msg.name() = [self.name UTF8String];
    msg.jid() = [self.jid UTF8String];
    msg.body() = [self.body UTF8String];
    msg.groupType() = (int32_t)self.groupType;
    msg.contentType() = (int32_t)self.contentType;
    msg.milltime() = self.milltime;
    msg.headid() = [self.headid UTF8String];
    msg.atUserList() = [self.atUserList UTF8String];
    msg.appID() = [self.appID UTF8String];
    msg.appName() = [self.appName UTF8String];
    msg.senderType() = (int32_t)self.senderType;
    msg.msgEx() = [self.msgEx UTF8String];
}

- (id) initWithMsg:(const mip::msg::SendGroupMsg*) pMsg {
    if (self = [super init]) {
        self.to = [NSString stringWithUTF8String:pMsg->to().data()];
        self.from = [NSString stringWithUTF8String:pMsg->from().data()];
        self.type = [NSString stringWithUTF8String:pMsg->type().data()];
        self.owner = [NSString stringWithUTF8String:pMsg->owner().data()];
        self.id = [NSString stringWithUTF8String:pMsg->id().data()];
        self.time = pMsg->time();
        self.name = [NSString stringWithUTF8String:pMsg->name().data()];
        self.jid = [NSString stringWithUTF8String:pMsg->jid().data()];
        self.body = [NSString stringWithUTF8String:pMsg->body().data()];
        self.groupType = pMsg->groupType();
        self.contentType = pMsg->contentType();
        self.milltime = pMsg->milltime();
        self.headid = [NSString stringWithUTF8String:pMsg->headid().data()];
        self.atUserList = [NSString stringWithUTF8String:pMsg->atUserList().data()];
        self.appID = [NSString stringWithUTF8String:pMsg->appID().data()];
        self.appName = [NSString stringWithUTF8String:pMsg->appName().data()];
        self.senderType = (int32_t)pMsg->senderType();
        self.msgEx = [NSString stringWithUTF8String:pMsg->msgEx().data()];
    }
    return self;
}

@end

@implementation ECSSendGroupMsgAck

- (id) initWithMsg:(const mip::msg::SendGroupMsgAck*) pMsg {
    if( self = [super initWithMsg:pMsg]) {
        self.id = [NSString stringWithUTF8String:pMsg->id().data()];
        self.unread = pMsg->unread();
        self.time = pMsg->time();
    }
    return self;
}

@end

@implementation ECSSendTempGroupMsg

- (void) parseMsg:(mip::msg::SendTempGroupMsg&) msg {
    msg.to() = [self.to UTF8String];
    msg.from() = [self.from UTF8String];
    msg.type() = [self.type UTF8String];
    msg.body() = [self.body UTF8String];
    msg.body_jid() = [self.body_jid UTF8String];
}

@end

@implementation ECSSendTempGroupMsgAck

- (id) initWithMsg:(const mip::msg::SendTempGroupMsgAck*) pMsg {
    if( self = [super initWithMsg:pMsg]) {
    }
    return self;
}

@end

@implementation ECSGetRoamingMsg

- (void) parseMsg:(mip::msg::GetRoamingMsg&) msg {
    msg.ActionType() = [self.ActionType UTF8String];
    msg.user() = [self.user UTF8String];
    msg.msgTag() = (int32_t)self.msgTag;
    msg.msgID() = [self.msgID UTF8String];
    msg.targetID() = [self.targetID UTF8String];
    msg.recordAmount() = (int32_t)self.recordAmount;
}

@end

@implementation ECSGetRoamingMsgAckMessage

- (id) initWithMsg:(const mip::msg::GetRoamingMsgAck::Message*) pMsg {
    if( self = [super init]) {
        self.id = [NSString stringWithUTF8String:pMsg->id().data()];
        self.to = [NSString stringWithUTF8String:pMsg->to().data()];
        self.from = [NSString stringWithUTF8String:pMsg->from().data()];
        self.msgTag = pMsg->msgTag();
        self.name = [NSString stringWithUTF8String:pMsg->name().data()];
        self.body = [NSString stringWithUTF8String:pMsg->body().data()];
        self.milltime = pMsg->milltime();
        self.autoReply = pMsg->autoReply();
        self.owner = [NSString stringWithUTF8String:pMsg->owner().data()];
        self.contentType = pMsg->contentType();
        self.cid = [NSString stringWithUTF8String:pMsg->cid().data()];
        self.appName = [NSString stringWithUTF8String:pMsg->appName().data()];
        self.appID = [NSString stringWithUTF8String:pMsg->appID().data()];
        self.senderType = (int32_t)pMsg->senderType();
        self.msgEx = [NSString stringWithUTF8String:pMsg->msgEx().data()];
    }
    return self;
}

@end

@implementation ECSGetRoamingMsgAck

- (id) initWithMsg:(const mip::msg::GetRoamingMsgAck*) pMsg {
    if( self = [super initWithMsg:pMsg]) {
        self.messageNum = pMsg->messageNum();
        self.startMsgID = [NSString stringWithUTF8String:pMsg->startMsgID().data()];
        self.endMsgID = [NSString stringWithUTF8String:pMsg->endMsgID().data()];
        
        NSMutableArray* __logList = [[NSMutableArray alloc] init];
        for (std::vector<mip::msg::GetRoamingMsgAck::Message>::const_iterator it = pMsg->logList().begin(); it != pMsg->logList().end(); ++it) {
            [__logList addObject:[[ECSGetRoamingMsgAckMessage alloc] initWithMsg:&(*it)]];
        }
        self.logList = __logList;
        
    }
    return self;
}

@end

@implementation ECSDelRoamingMsg

- (void) parseMsg:(mip::msg::DelRoamingMsg&) msg {
    msg.ActionType() = [self.ActionType UTF8String];
    msg.msgTag() = (int32_t)self.msgTag;
    msg.user() = [self.user UTF8String];
    msg.targetid() = [self.targetid UTF8String];
    msg.type() = self.type;
    if(self.msgList) {
        for(NSString* item in self.msgList) {
            ctk::String __msgList;
            __msgList = [item UTF8String];
            msg.msgList().push_back(__msgList);
        }
    }
}

@end

@implementation ECSDelRoamingMsgAck

- (id) initWithMsg:(const mip::msg::DelRoamingMsgAck*) pMsg {
    if( self = [super initWithMsg:pMsg]) {
    }
    return self;
}

@end

@implementation ECSNewsMessage

- (id) initWithMsg:(mip::msg::NewsMessage*) msg {
    if (self = [super init]) {
        self.title = [NSString stringWithUTF8String:msg->title().data()];
        self.id = [NSString stringWithUTF8String:msg->id().data()];
    }
    
    return self;
}

@end

@implementation ECSNewsMessageAck

- (id) initWithMsg:(const mip::msg::NewsMessageAck*) pMsg {
    if( self = [super initWithMsg:pMsg]) {
    }
    return self;
}

@end

@implementation ECSQueryNewsList

- (void) parseMsg:(mip::msg::QueryNewsList&) msg {
    msg.ActionType() = [self.ActionType UTF8String];
    msg.user() = [self.user UTF8String];
    msg.count() = (int32_t)self.count;
    msg.timestamp() = self.timestamp;
}

@end

@implementation ECSQueryNewsListAckRecord

- (id) initWithMsg:(const mip::msg::QueryNewsListAck::Record*) pMsg {
    if( self = [super init]) {
        self.title = [NSString stringWithUTF8String:pMsg->title().data()];
        self.id = [NSString stringWithUTF8String:pMsg->id().data()];
        self.time = pMsg->time();
    }
    return self;
}

@end

@implementation ECSQueryNewsListAck

- (id) initWithMsg:(const mip::msg::QueryNewsListAck*) pMsg {
    if( self = [super initWithMsg:pMsg]) {
        
        NSMutableArray* __list = [[NSMutableArray alloc] init];
        for (std::vector<mip::msg::QueryNewsListAck::Record>::const_iterator it = pMsg->list().begin(); it != pMsg->list().end(); ++it) {
            [__list addObject:[[ECSQueryNewsListAckRecord alloc] initWithMsg:&(*it)]];
        }
        self.list = __list;
        
    }
    return self;
}

@end

@implementation ECSQueryNews

- (void) parseMsg:(mip::msg::QueryNews&) msg {
    msg.ActionType() = [self.ActionType UTF8String];
    msg.user() = [self.user UTF8String];
    msg.id() = [self.id UTF8String];
}

@end

@implementation ECSQueryNewsAck

- (id) initWithMsg:(const mip::msg::QueryNewsAck*) pMsg {
    if( self = [super initWithMsg:pMsg]) {
        self.content = [NSString stringWithUTF8String:pMsg->content().data()];
    }
    return self;
}

@end

@implementation ECSChatMessageNotify

- (id) initWithMsg:(const mip::msg::ChatMessageNotify*) pMsg {
    if( self = [super init]) {
        self.from = [NSString stringWithUTF8String:pMsg->from().data()];
        self.to = [NSString stringWithUTF8String:pMsg->to().data()];
        self.name = [NSString stringWithUTF8String:pMsg->name().data()];
        self.type = [NSString stringWithUTF8String:pMsg->type().data()];
        self.body = [NSString stringWithUTF8String:pMsg->body().data()];
        self.body_time = [NSString stringWithUTF8String:pMsg->body_time().data()];
    }
    return self;
}

@end

@implementation ECSGroupMsgNotify

- (id) initWithMsg:(const mip::msg::GroupMsgNotify*) pMsg {
    if( self = [super init]) {
        self.from = [NSString stringWithUTF8String:pMsg->from().data()];
        self.to = [NSString stringWithUTF8String:pMsg->to().data()];
        self.type = [NSString stringWithUTF8String:pMsg->type().data()];
        self.body = [NSString stringWithUTF8String:pMsg->body().data()];
        self.body_jid = [NSString stringWithUTF8String:pMsg->body_jid().data()];
        self.body_name = [NSString stringWithUTF8String:pMsg->body_name().data()];
        self.body_time = pMsg->body_time();
        self.groupType = pMsg->groupType();
    }
    return self;
}

@end

@implementation ECSGroupChatResultNotify

- (id) initWithMsg:(const mip::msg::GroupChatResultNotify*) pMsg {
    if( self = [super init]) {
        self.from = [NSString stringWithUTF8String:pMsg->from().data()];
        self.to = [NSString stringWithUTF8String:pMsg->to().data()];
        self.type = [NSString stringWithUTF8String:pMsg->type().data()];
        self.body = [NSString stringWithUTF8String:pMsg->body().data()];
        self.body_jid = [NSString stringWithUTF8String:pMsg->body_jid().data()];
        self.reason = [NSString stringWithUTF8String:pMsg->reason().data()];
        self.groupType = pMsg->groupType();
    }
    return self;
}

@end

@implementation ECSTempGroupMsgNotify

- (id) initWithMsg:(const mip::msg::TempGroupMsgNotify*) pMsg {
    if( self = [super init]) {
        self.from = [NSString stringWithUTF8String:pMsg->from().data()];
        self.to = [NSString stringWithUTF8String:pMsg->to().data()];
        self.type = [NSString stringWithUTF8String:pMsg->type().data()];
        self.body = [NSString stringWithUTF8String:pMsg->body().data()];
        self.body_jid = [NSString stringWithUTF8String:pMsg->body_jid().data()];
        self.body_time = [NSString stringWithUTF8String:pMsg->body_time().data()];
        self.body_name = [NSString stringWithUTF8String:pMsg->body_name().data()];
    }
    return self;
}

@end

@implementation ECSUnreadMessagesNotifyChat

- (id) initWithMsg:(const mip::msg::UnreadMessagesNotify::Chat*) pMsg {
    if( self = [super init]) {
        self.id = [NSString stringWithUTF8String:pMsg->id().data()];
        self.to = [NSString stringWithUTF8String:pMsg->to().data()];
        self.from = [NSString stringWithUTF8String:pMsg->from().data()];
        self.name = [NSString stringWithUTF8String:pMsg->name().data()];
        self.body = [NSString stringWithUTF8String:pMsg->body().data()];
        self.time = pMsg->time();
        self.title = [NSString stringWithUTF8String:pMsg->title().data()];
        self.autoReply = pMsg->autoReply();
        self.owner = [NSString stringWithUTF8String:pMsg->owner().data()];
        self.contentType = pMsg->contentType();
        self.appID = [NSString stringWithUTF8String:pMsg->appID().data()];
        self.appName = [NSString stringWithUTF8String:pMsg->appName().data()];
        self.senderType = (int32_t)pMsg->senderType();
        self.msgEx = [NSString stringWithUTF8String:pMsg->msgEx().data()];
    }
    return self;
}

@end

@implementation ECSUnreadMessagesNotify

- (id) initWithMsg:(const mip::msg::UnreadMessagesNotify*) pMsg {
    if( self = [super init]) {
        self.user = [NSString stringWithUTF8String:pMsg->user().data()];
        self.msgTag = pMsg->msgTag();
        
        NSMutableArray* __chatList = [[NSMutableArray alloc] init];
        for (std::vector<mip::msg::UnreadMessagesNotify::Chat>::const_iterator it = pMsg->chatList().begin(); it != pMsg->chatList().end(); ++it) {
            [__chatList addObject:[[ECSUnreadMessagesNotifyChat alloc] initWithMsg:&(*it)]];
        }
        self.chatList = __chatList;
        self.num = pMsg->chatList_num();
        self.maxID = [NSString stringWithUTF8String:pMsg->chatList_maxID().data()];
        self.minID = [NSString stringWithUTF8String:pMsg->chatList_minID().data()];
        self.isAt = (NSInteger)(pMsg->isAt());
        
    }
    return self;
}

@end

@implementation ECSMessageReadNotify

- (id) initWithMsg:(const mip::msg::MessageReadNotify*) pMsg {
    if( self = [super init]) {
        self.msgTag = pMsg->msgTag();
        self.from = [NSString stringWithUTF8String:pMsg->from().data()];
        self.to = [NSString stringWithUTF8String:pMsg->to().data()];
        self.id = [NSString stringWithUTF8String:pMsg->id().data()];
    }
    return self;
}

@end

@implementation ECSOprMsg

- (void) parseMsg:(mip::msg::OprMsg&) msg {
    msg.ActionType() = [self.ActionType UTF8String];
    msg.user() = [self.user UTF8String];
    msg.oprType() = self.oprType;
    msg.messageType() = (int32_t)self.messageType;
    msg.sender() = [self.sender UTF8String];
    msg.targetId() = [self.targetId UTF8String];
    if(self.msgIDList) {
        for(NSString* item in self.msgIDList) {
            ctk::String __msgIDList;
            __msgIDList = [item UTF8String];
            msg.msgIdList().push_back(__msgIDList);
        }
    }
    msg.lastMsgFlag() = self.lastMsgFlag;
}

- (id) initWithMsg:(const mip::msg::OprMsg*) pMsg {
    if( self = [super init]) {
        self.ActionType = [NSString stringWithUTF8String:pMsg->ActionType().data()];
        self.user = [NSString stringWithUTF8String:pMsg->user().data()];
        self.oprType = pMsg->oprType();
        self.messageType = pMsg->messageType();
        self.sender = [NSString stringWithUTF8String:pMsg->sender().data()];
        self.targetId = [NSString stringWithUTF8String:pMsg->targetId().data()];
        
        NSMutableArray* __msgIDList = [[NSMutableArray alloc] init];
        for (std::vector<ctk::String>::const_iterator it = pMsg->msgIdList().begin(); it != pMsg->msgIdList().end(); ++it) {
            [__msgIDList addObject:[NSString stringWithUTF8String:(*it).data()]];
        }
        self.msgIDList = __msgIDList;
        self.lastMsgFlag = pMsg->lastMsgFlag();
    }
    return self;
}

@end

@implementation ECSOprMsgAck

- (void) parseMsg:(mip::msg::OprMsgAck&) msg {
    msg.timeoutInfo() = self.timeoutInfo;
}

- (id) initWithMsg:(const mip::msg::OprMsgAck*) pMsg {
    if( self = [super initWithMsg:pMsg]) {
        self.timeoutInfo = pMsg->timeoutInfo();
    }
    return self;
}

@end

@implementation ECSOprMsgNotify

- (void) parseMsg:(mip::msg::OprMsgNotify&) msg {
    msg.oprType() = self.oprType;
    msg.oprUser() = [self.oprUser UTF8String];
    msg.messageType() = (int32_t)self.messageType;
    msg.targetId() = [self.targetId UTF8String];
    if(self.msgIDList) {
        for(NSString* item in self.msgIDList) {
            ctk::String __msgIDList;
            __msgIDList = [item UTF8String];
            msg.msgIdList().push_back(__msgIDList);
        }
    }
    msg.originAppId() = [self.originAppId UTF8String];
    msg.receiver() = [self.receiver UTF8String];
    msg.messageId() = [self.messageId UTF8String];
    msg.isFromRemote() = self.isFromRemote;
    msg.isOnlyPcCooperation() = self.isOnlyPcCooperation;
}

- (id) initWithMsg:(const mip::msg::OprMsgNotify*) pMsg {
    if( self = [super init]) {
        self.oprType = pMsg->oprType();
        self.oprUser = [NSString stringWithUTF8String:pMsg->oprUser().data()];
        self.messageType = pMsg->messageType();
        self.targetId = [NSString stringWithUTF8String:pMsg->targetId().data()];
        
        NSMutableArray* __msgIDList = [[NSMutableArray alloc] init];
        for (std::vector<ctk::String>::const_iterator it = pMsg->msgIdList().begin(); it != pMsg->msgIdList().end(); ++it) {
            [__msgIDList addObject:[NSString stringWithUTF8String:(*it).data()]];
        }
        self.msgIDList = __msgIDList;
        
        self.originAppId = [NSString stringWithUTF8String:pMsg->originAppId().data()];
        self.receiver = [NSString stringWithUTF8String:pMsg->receiver().data()];
        self.messageId = [NSString stringWithUTF8String:pMsg->messageId().data()];
        self.isFromRemote = pMsg->isFromRemote();
        self.isOnlyPcCooperation = pMsg->isOnlyPcCooperation();
    }
    return self;
}


@end
