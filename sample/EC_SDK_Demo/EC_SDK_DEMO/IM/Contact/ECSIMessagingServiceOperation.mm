#import "ECSIMessagingServiceMessage+Parser.h"
#import "ECSIMessagingServiceOperation.h"
//#import "eSpaceIOSSDK.h" TODO wangxiangyang
#import "ECSErrorCode.h"

@implementation ECSMarkReadOperation

- (void) doStart {
	mip::msg::MarkRead* markRead = new mip::msg::MarkRead();
	[self.markReadRequest parseMsg:(*markRead)];
	self->_message = markRead;
	[super doStart];
}

- (void) doFinish:(mip::msg::BaseMsg*)retObj withError:(NSError*)error {
	if(retObj && !error) {
		self.markReadResponse = [[ECSMarkReadAck alloc] initWithMsg:(mip::msg::MarkReadAck*)retObj];
	}
	[super doFinish:retObj withError:error];
}

@end

@implementation ECSGetMsgLogOperation

- (void) doStart {
	mip::msg::GetMsgLog* getMsgLog = new mip::msg::GetMsgLog();
	[self.getMsgLogRequest parseMsg:(*getMsgLog)];
	self->_message = getMsgLog;
	[super doStart];
}

- (void) doFinish:(mip::msg::BaseMsg*)retObj withError:(NSError*)error {
	if(retObj && !error) {
		self.getMsgLogResponse = [[ECSGetMsgLogAck alloc] initWithMsg:(mip::msg::GetMsgLogAck*)retObj];
	}
	[super doFinish:retObj withError:error];
}

@end

@implementation ECSDelMsgLogOperation

- (void) doStart {
	mip::msg::DelMsgLog* delMsgLog = new mip::msg::DelMsgLog();
	[self.delMsgLogRequest parseMsg:(*delMsgLog)];
	self->_message = delMsgLog;
	[super doStart];
}

- (void) doFinish:(mip::msg::BaseMsg*)retObj withError:(NSError*)error {
	if(retObj && !error) {
		self.delMsgLogResponse = [[ECSDelMsgLogAck alloc] initWithMsg:(mip::msg::DelMsgLogAck*)retObj];
	}
	[super doFinish:retObj withError:error];
}

@end

@implementation ECSChatMessageOperation

- (void) doStart {
	mip::msg::ChatMessage* chatMessage = new mip::msg::ChatMessage();
	[self.chatMessageRequest parseMsg:(*chatMessage)];
	self->_message = chatMessage;
	[super doStart];
}

- (void) doFinish:(mip::msg::BaseMsg*)retObj withError:(NSError*)error {
    
    if (error && self.supportResend) {
        switch (error.code) {
            case ECSCommonMAATimeOutError:
                [self handleTimeout];
                break;
            case ECSCommonMAACancelledError:
                [self handleMaaCancelled];
                break;
            case ECSCommonSocketCloseError:
                [self handleMaaCancelled];
                break;
            case ECSCommonMAAResendFailedError:
                [super doFinish:NULL withError:error];
                break;
            default:
                [super doFinish:NULL withError:error];
                break;
        }
    }
    else{
        if(retObj && !error) {
            self.chatMessageResponse = [[ECSChatMessageAck alloc] initWithMsg:(mip::msg::ChatMessageAck*)retObj];
        }
        [super doFinish:retObj withError:error];
    }
}

@end

@implementation ECSSendGroupMsgOperation

- (void) doStart {
	mip::msg::SendGroupMsg* sendGroupMsg = new mip::msg::SendGroupMsg();
	[self.sendGroupMsgRequest parseMsg:(*sendGroupMsg)];
	self->_message = sendGroupMsg;
	[super doStart];
}

- (void) doFinish:(mip::msg::BaseMsg*)retObj withError:(NSError*)error {
    if (error && self.supportResend) {
        switch (error.code) {
            case ECSCommonMAATimeOutError:
                [self handleTimeout];
                break;
            case ECSCommonMAACancelledError:
                [self handleMaaCancelled];
                break;
            case ECSCommonSocketCloseError:
                [self handleMaaCancelled];
                break;
            case ECSCommonMAAResendFailedError:
                [super doFinish:NULL withError:error];
                break;
            default:
                [super doFinish:NULL withError:error];
                break;
        }
    }
    else{
        if(retObj && !error) {
            self.sendGroupMsgResponse = [[ECSSendGroupMsgAck alloc] initWithMsg:(mip::msg::SendGroupMsgAck*)retObj];
        }
        [super doFinish:retObj withError:error];
    }
}

@end

@implementation ECSSendTempGroupMsgOperation

- (void) doStart {
	mip::msg::SendTempGroupMsg* sendTempGroupMsg = new mip::msg::SendTempGroupMsg();
	[self.sendTempGroupMsgRequest parseMsg:(*sendTempGroupMsg)];
	self->_message = sendTempGroupMsg;
	[super doStart];
}

- (void) doFinish:(mip::msg::BaseMsg*)retObj withError:(NSError*)error {
	if(retObj && !error) {
		self.sendTempGroupMsgResponse = [[ECSSendTempGroupMsgAck alloc] initWithMsg:(mip::msg::SendTempGroupMsgAck*)retObj];
	}
	[super doFinish:retObj withError:error];
}

@end

@implementation ECSGetRoamingMsgOperation

- (void) doStart {
	mip::msg::GetRoamingMsg* getRoamingMsg = new mip::msg::GetRoamingMsg();
	[self.getRoamingMsgRequest parseMsg:(*getRoamingMsg)];
	self->_message = getRoamingMsg;
	[super doStart];
}

- (void) doFinish:(mip::msg::BaseMsg*)retObj withError:(NSError*)error {
	if(retObj && !error) {
		self.getRoamingMsgResponse = [[ECSGetRoamingMsgAck alloc] initWithMsg:(mip::msg::GetRoamingMsgAck*)retObj];
	}
	[super doFinish:retObj withError:error];
}

@end

@implementation ECSDelRoamingMsgOperation

- (void) doStart {
	mip::msg::DelRoamingMsg* delRoamingMsg = new mip::msg::DelRoamingMsg();
	[self.delRoamingMsgRequest parseMsg:(*delRoamingMsg)];
	self->_message = delRoamingMsg;
	[super doStart];
}

- (void) doFinish:(mip::msg::BaseMsg*)retObj withError:(NSError*)error {
	if(retObj && !error) {
		self.delRoamingMsgResponse = [[ECSDelRoamingMsgAck alloc] initWithMsg:(mip::msg::DelRoamingMsgAck*)retObj];
	}
	[super doFinish:retObj withError:error];
}

@end

//@implementation ECSNewsMessageOperation
//
//- (void) doStart {
//	mip::msg::NewsMessage* newsMessage = new mip::msg::NewsMessage();
//	[self.newsMessageRequest parseMsg:(*newsMessage)];
//	self->_message = newsMessage;
//	[super doStart];
//}
//
//- (void) doFinish:(mip::msg::BaseMsg*)retObj withError:(NSError*)error {
//	if(retObj && !error) {
//		self.newsMessageResponse = [[ECSNewsMessageAck alloc] initWithMsg:(mip::msg::NewsMessageAck*)retObj];
//	}
//	[super doFinish:retObj withError:error];
//}
//
//@end

@implementation ECSQueryNewsListOperation

- (void) doStart {
	mip::msg::QueryNewsList* queryNewsList = new mip::msg::QueryNewsList();
	[self.queryNewsListRequest parseMsg:(*queryNewsList)];
	self->_message = queryNewsList;
	[super doStart];
}

- (void) doFinish:(mip::msg::BaseMsg*)retObj withError:(NSError*)error {
	if(retObj && !error) {
		self.queryNewsListResponse = [[ECSQueryNewsListAck alloc] initWithMsg:(mip::msg::QueryNewsListAck*)retObj];
	}
	[super doFinish:retObj withError:error];
}

@end

@implementation ECSQueryNewsOperation

- (void) doStart {
	mip::msg::QueryNews* queryNews = new mip::msg::QueryNews();
	[self.queryNewsRequest parseMsg:(*queryNews)];
	self->_message = queryNews;
	[super doStart];
}

- (void) doFinish:(mip::msg::BaseMsg*)retObj withError:(NSError*)error {
	if(retObj && !error) {
		self.queryNewsResponse = [[ECSQueryNewsAck alloc] initWithMsg:(mip::msg::QueryNewsAck*)retObj];
	}
	[super doFinish:retObj withError:error];
}

@end

@implementation ECSOprMsgOperation

- (void) doStart {
    mip::msg::OprMsg* oprMsg = new mip::msg::OprMsg();
    [self.oprMsgRequest parseMsg:(*oprMsg)];
    self->_message = oprMsg;
    [super doStart];
}

- (void) doFinish:(mip::msg::BaseMsg*)retObj withError:(NSError*)error {
    if(retObj && !error) {
        self.oprMsgResponse = [[ECSOprMsgAck alloc] initWithMsg:(mip::msg::OprMsgAck*)retObj];
    }else if(retObj){
        self.oprMsgResponse = [[ECSOprMsgAck alloc] initWithMsg:(mip::msg::OprMsgAck*)retObj];
    }
    [super doFinish:retObj withError:error];
}

@end
