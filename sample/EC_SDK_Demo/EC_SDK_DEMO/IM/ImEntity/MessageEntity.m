//
//  MessageEntity.m
//  eSpaceUI
//
//  Created by yemingxing on 3/13/15.
//  Copyright (c) 2015 www.huawei.com. All rights reserved.
//

#import "MessageEntity.h"
#import "ContactEntity.h"
#import "SessionEntity.h"
#import "NSDate+LocalString.h"
//#import "ESpaceUMResource.h"
#import "ECSUtils.h"
#import "NSManagedObjectContext+Persistent.h"
#import "ECSAppConfig.h"
#import "NSManagedObject+ECS_Utility.h"
#import "eSpaceDBService.h"

@implementation MessageEntity

@dynamic messageId;
@dynamic body;
@dynamic contentType;
@dynamic receiveTimestamp;
@dynamic transferStatus;
@dynamic readed;
@dynamic title;
@dynamic type;
@dynamic from;
@dynamic session;
@dynamic to;
@dynamic localStatus;
@dynamic dataBaseId;
@dynamic translateBody;
@dynamic translateState;

//ECSEntryptCoreDataStringProp(body, Body)
//ECSEntryptCoreDataStringProp(title, Title)
//ECSEntryptCoreDataStringProp(translateBody, TranslateBody)

- (BOOL) canBeLatestMessage {
    return YES;
}

- (BOOL) supportAction:(NSInteger) action {
    return YES;
}

- (BOOL)failed {
    NSInteger status = [self.transferStatus integerValue];
    return status == ESpaceMsgStatusSendFailed || status == ESpaceMsgStatusSendCancelled;
}

//- (NSString *)messageDesc4MergeForward {
//    NSString *messagDesc;
//    switch ([self.contentType integerValue]) {
//        case ESpaceUnknowContentType:
//            messagDesc = ECSLocalizedString(@"im_msgtype_unkonwn", @"【未知】");
//            break;
//
//        case ESpaceAudioContentType:
//            messagDesc = ECSLocalizedString(@"im_msgtype_audo", @"【声音】");
//            break;
//
//        case ESpaceVideoContentType:
//            messagDesc = ECSLocalizedString(@"im_msgtype_video", @"【视频】");
//            break;
//
//        case ESpaceImageContentType:
//            messagDesc = ECSLocalizedString(@"im_msgtype_picture", @"【图片】");
//            break;
//
//        case ESpaceFileContentType:
//            messagDesc = ECSLocalizedString(@"im_msgtype_file", @"【文件】");
//            break;
//
//        case ESpacePublicAccountContentType:
//        case ESpaceShareLinkContentType:
//        case ESpacePaImageTextContentType:
//        case ESpaceLightAppPaContentType:
//        case ESpaceCardMsgSharedType:
//        case ESpaceCardMsgOrderType:
//        case ESpaceCardMsgRecordType:
//            messagDesc = ECSLocalizedString(@"im_msgtype_card", @"【分享卡片】");
//            break;
//
//        case ESpaceEmailContentType:
//            messagDesc = ECSLocalizedString(@"unsupported_message_type", @"未知消息类型，您当前版本不支持，请您升级为最新版本");
//            break;
//
//
//        case ESpaceTextContentType:
//        default:
//            messagDesc = self.body;
//            if ([self.translateBody length]) {
//                messagDesc = [messagDesc stringByAppendingFormat:@"\n\n%@", self.translateBody];
//            }
//    }
//
//    return messagDesc;
//}

- (BOOL)canBeSelected {
    return self.type.integerValue != ESpaceSysTimeMSGType;
}

//- (BOOL)isLengthOverLimit {
//    NSInteger maxLength = [ESPACE_CURRENT_USER_CFG maxMsgSize];
//    BOOL isText = [self.contentType integerValue] == ESpaceTextContentType;
//    BOOL isOverLimit = [self.body length] > maxLength;
//    return isText && isOverLimit;
//}

- (void)setReaded:(NSNumber *)readed {
    NSNumber* number = [self primitiveValueForKey:@"readed"];
    if (![number boolValue] || [number boolValue] != [readed boolValue]) {
        [self willChangeValueForKey:@"readed"];
        [self setPrimitiveValue:readed forKey:@"readed"];
        [self.session willAccessValueForKey:@"unreadCount"];
        NSNumber* unreadNumber = [self.session primitiveValueForKey:@"unreadCount"];
        NSInteger unread = unreadNumber.integerValue;
        NSInteger newCount = 0;
        if (readed.boolValue) {
            if (unread > 0) {
                newCount = unread - 1;
            }
        } else {
            newCount = unread + 1;
        }
        if (unread != newCount) {
            self.session.unreadCount = [NSNumber numberWithInteger:newCount];
        }
        [self.session didAccessValueForKey:@"unreadCount"];
        [self didChangeValueForKey:@"readed"];
    }
}

- (void)setFrom:(ContactEntity *)from {
    [self willChangeValueForKey:@"from"];
    [self setPrimitiveValue:from forKey:@"from"];
    [self didChangeValueForKey:@"from"];
    from.weight = [NSNumber numberWithInteger:from.weight.integerValue + 1];
}

- (void)setTo:(ContactEntity *)to {
    [self willChangeValueForKey:@"to"];
    [self setPrimitiveValue:to forKey:@"to"];
    [self didChangeValueForKey:@"to"];
    to.weight = [NSNumber numberWithInteger:to.weight.integerValue + 1];
}

- (void)localDeleteSelf {
    if (NO == [self canFillFault]) {
        return;
    }
    SessionEntity * session = self.session;
    [self.session removeMessagesObject:self];
    [session updateLatestMessage];
    [self.managedObjectContext deleteObject:self];
}

- (void)localDeleteSelf:(void (^)(NSError* error)) completionBlock {
    
    NSManagedObjectID* oid = self.objectID;
    ESpaceLocalDataManager * localManager = LOCAL_DATA_MANAGER;
    dispatch_async(espace_coredata_management_queue, ^{
        NSManagedObjectContext* bgCtx = [localManager backgroundObjectContext];
        [bgCtx performBlockAndWait:^{
            MessageEntity* shadow = (MessageEntity*)[bgCtx objectWithID:oid];
            if ([self canFillFault]) {
                [shadow localDeleteSelf];
                [bgCtx saveToPersistent];
            }
            if (completionBlock) {
                completionBlock(nil);
            }
        }];
    });
}
@end
