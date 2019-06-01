//
//  CircleSessionEntity.m
//  eSpace
//
//  Created by huawei on 15/6/4.
//  Copyright (c) 2015年 www.huawei.com. All rights reserved.
//

#import "CircleSessionEntity.h"
#import "CircleComment.h"
#import "NSDate+LocalString.h"
//#import "ESpaceDetailMessagParser.h"TODO wxy
#import "SessionGroupEntity.h"
#import "ECSUtils.h"
//#import "eSpaceIOSService.h"TODO wxy

@implementation CircleSessionEntity

@dynamic lastUpdate;
@dynamic umList;
@dynamic replyCount;
@dynamic favorCount;
@dynamic transferStatus;
@dynamic contentType;
@dynamic contentExt;
@dynamic topicOwner;
@dynamic initialTimestamp;
@dynamic valid;
@dynamic meInvolved;
@dynamic contentFolded;

//ECSEntryptCoreDataStringProp(content, Content)
//ECSEntryptCoreDataStringProp(draft, Draft)

- (NSDate *)initialDate {
    [self willAccessValueForKey:@"initialDate"];
    NSDate* date = [self.initialTimestamp datePart];
    [self didAccessValueForKey:@"initialDate"];
    return date;
}

- (void)setInitialDate:(NSDate *)initialDate {
    return;
}

//- (MessageEntity*) updateLatestMessage {
//    MessageEntity* lastestMsg = [self lastMessageByTimeStamp:NO];
//    if (lastestMsg != self.latestMessage) {
//        self.latestMessage = lastestMsg;
//        self.timestamp = lastestMsg.receiveTimestamp;
//    }
//    SessionGroupEntity* parent = (SessionGroupEntity*) self.parent;
//    if (parent && !parent.isDeleted) {
//        MessageEntity *parentLatestMessage = [parent lastMessageByTimeStamp:NO];
//        parent.latestMessage = parentLatestMessage;
//    }
//    return lastestMsg;
//}

- (void)setMeInvolved:(NSNumber *)meInvolved {
    [self willChangeValueForKey:@"meInvolved"];
    [self setPrimitiveValue:meInvolved forKey:@"meInvolved"];
    [self didChangeValueForKey:@"meInvolved"];
    for (CircleComment* comment in self.messages) {
        comment.meInvolved = meInvolved;
    }
    [self updateLatestMessage];
}

- (MessageEntity *)lastMessageByTimeStamp:(BOOL)ascending {
    //TODO wxy
//    NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:@"CircleComment"];
//    request.predicate = [NSPredicate predicateWithFormat:@"session=%@ AND meInvolved=%@ AND from.contactId!=%@", self, [NSNumber numberWithBool:YES], LOCAL_DATA_MANAGER.userAccount];
//    
//    [request setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"receiveTimestamp" ascending:ascending]]];
//    [request setFetchLimit:1];
//    NSError * error = nil;
//    
//    NSArray* results = [self.managedObjectContext executeFetchRequest:request error:&error];
//    if (error) {
//        DDLogError(@"error:(%@)",error.localizedDescription);
//        return nil;
//    }
//    return [results lastObject];
    
    return nil;
}

- (void)addMessages:(NSSet *)values {
    [super addMessages:values];
//    NSNumber* meInvovled = self.meInvolved;
    
    NSInteger replyCount = [self.replyCount integerValue];
    NSInteger favorCount = [self.favorCount integerValue];
    
    for (CircleComment* comment in values) {
        if ([comment.commentType integerValue] == CircleCommentFavor) {
            favorCount ++;
        } else {
            replyCount ++;
        }
//        comment.meInvolved = meInvovled;
    }
    if (replyCount != [self.replyCount integerValue]) {
        self.replyCount = [NSNumber numberWithInteger:replyCount];
    }
    if (favorCount != [self.favorCount integerValue]) {
        self.favorCount = [NSNumber numberWithInteger:favorCount];
    }
}

- (void)addMessagesObject:(MessageEntity *)value{
    [self addMessages:[NSSet setWithObject:value]];
}

- (void)removeMessages:(NSSet *)values {
    [super removeMessages:values];
    NSInteger replyCount = [self.replyCount integerValue];
    NSInteger favorCount = [self.favorCount integerValue];
    
    for (CircleComment* comment in values) {
        if ([comment.commentType integerValue] == CircleCommentReply) {
            replyCount--;
        }
        else{
            favorCount--;
        }
    }
    
    if (replyCount != [self.replyCount integerValue]) {
        self.replyCount = [NSNumber numberWithInteger:replyCount];
    }
    if (favorCount != [self.favorCount integerValue]) {
        self.favorCount = [NSNumber numberWithInteger:favorCount];
    }
}

- (void)removeMessagesObject:(MessageEntity *)value{
    [self removeMessages:[NSSet setWithObject:value]];
}

- (BOOL) hasSharedLink {
    //TODO wxy
//    NSArray* array = [[ESpaceDetailMessagParser sharedInstance] parseContent:[self.content length] ? self.content : self.contentExt];
//    for (ECSControl* ctrl in array) {
//        if ([ctrl isKindOfClass:[ESpaceUrlLink class]]) {
//            return YES;
//        }
//    }
    return NO;
}
@end
