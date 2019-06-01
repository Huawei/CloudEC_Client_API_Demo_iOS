//
//  ChatSessionEntity.m
//  eSpaceUI
//
//  Created by yemingxing on 3/16/15.
//  Copyright (c) 2015 www.huawei.com. All rights reserved.
//

#import "ChatSessionEntity.h"
#import "ContactEntity.h"
#import "ECSUtils.h"
#import "ECSAppConfig.h"
#import "ChatMessageEntity.h"

@implementation ChatSessionEntity

@dynamic target;
@dynamic isAtMe;
@dynamic realUnReceiveMsgNum;
@dynamic chatState;

//ECSEntryptCoreDataStringProp(draft, Draft)

- (void)localMarkReadAll {
    [super localMarkReadAll];
    if ([self.isAtMe boolValue]) {
        self.isAtMe = [NSNumber numberWithBool:NO];
    }
}

- (MessageEntity *)lastMessageByTimeStamp:(BOOL)ascending{
    NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:@"ChatMessageEntity"];
    request.predicate = [NSPredicate predicateWithFormat:@"session=%@ AND type=%@ AND (flag=%@ OR flag=%@ OR flag=%@)", self, @0, @(ESpaceMessageFlagNormal),@(ESpaceMessageFlagRecalled), @(ESpaceMessageFlagVideoCall)];
    
    
    NSSortDescriptor* timeDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"receiveTimestamp" ascending:ascending];
    NSSortDescriptor* msgIdDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"messageId" ascending:ascending];
    NSSortDescriptor* dataBaseIdDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"dataBaseId" ascending:ascending];
    if ([[ECSAppConfig sharedInstance].currentUser isSupportFunction:EN_FUNC_ROAMING_MESSAGE]) {
        [request setSortDescriptors:@[timeDescriptor,msgIdDescriptor, dataBaseIdDescriptor]];
    }
    else {
        [request setSortDescriptors:@[dataBaseIdDescriptor, timeDescriptor]];
    }
    
    [request setFetchLimit:1];
    NSError * error = nil;
    
    NSArray* results = [self.managedObjectContext executeFetchRequest:request error:&error];
    return [results lastObject];
}

@end
