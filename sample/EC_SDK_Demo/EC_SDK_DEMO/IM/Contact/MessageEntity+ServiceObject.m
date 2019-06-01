//
//  MessageEntity+Remote.m
//  eSpaceUI
//
//  Created by yemingxing on 3/24/15.
//  Copyright (c) 2015 www.huawei.com. All rights reserved.
//
#import <AVFoundation/AVFoundation.h>
#import <objc/runtime.h>

//#import "TUPIOSSDK.h"
//#import "NSURL+Export.h"
#import "ChatSessionEntity+ServiceObject.h"
#import "MessageEntity+ServiceObject.h"
#import "ContactEntity.h"
#import "GroupEntity.h"
#import "ESpaceIMessageService.h"
//#import "eSpaceIOSSDK.h"
//#import "ESpaceDetailMessagParser.h"  //wxy todo
//#import "ECSFileManager.h"
//#import "ESpaceUMResource.h"
#import "NSManagedObjectContext+Persistent.h"
#import "eSpaceDBService.h"
//#import "ESpaceDetailMessagParser.h"

//#import "eSpaceIOSService.h"

@implementation MessageEntity (Remote)

- (BOOL) fromSelf {
    NSString* currentUser = LOCAL_DATA_MANAGER.userAccount;
    return (self.from.contactId && [self.from.contactId compare:currentUser] == NSOrderedSame);
}

//PublicAccountMsgData{
//    "publicSource"  :"公众号来源，1：内部公众号，2：w3m公众号"
//    "publicAccount" :"公众号账号"
//    "publicName"    :"公众号名称"
//    "sourceUrl"     :"分享原文路径"
//    "title"         :"分享的标题"
//    "digest"        :"分享的正文摘要"
//    "mediaPath"     :"图片下载地址"
//    "msgType"       :"消息类型"
//    "contentUrl"    :"链接地址"
//}

//ShareLinkData{
//    "appid"         :""
//    "imgSourceType" :"分享类型：1 内部；2 外部"
//    "source"        :"分享来源，分享来自"
//    "imgUrl"        :"图片下载地址"
//    "sourceUrl"     :"分享原文路径"
//    "title"         :"分享的标题"
//    "digest"        :"分享的正文摘要"
//    "comment"       :"评论意见"
//}

//- (NSArray*) umResources {
//    if (self.contentType.integerValue == ESpaceTextContentType) {
//        return nil;
//    }
//    ESpaceContentType contentType = [self.contentType integerValue];
//    if (contentType == ESpacePublicAccountContentType
//        || contentType == ESpaceShareLinkContentType) {
//        NSData* jsonData = [self.body dataUsingEncoding:NSUTF8StringEncoding];
//        if (jsonData) {
//            NSDictionary* dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:nil];
//            if ([dic isKindOfClass:[NSDictionary class]]) {
//                if (contentType == ESpacePublicAccountContentType) {
//                    NSArray* resources = [self umResourceTokensFromString:[dic valueForKey:@"mediaPath"]];
//                    NSNumber* source = [dic valueForKey:@"publicSource"];
//                    if (source.integerValue == 2) {
//                        for (ESpaceUMResource* res in resources) {
//                            res.resourceCatalog = ECSUMResourcePublic;
//                        }
//                    }
//                    return resources;
//                } else if (contentType == ESpaceShareLinkContentType) {
//                    NSArray* resources = [self umResourceTokensFromString:[dic valueForKey:@"imgUrl"]];
//                    NSNumber* source = [dic valueForKey:@"accessMode"];
//                    ECSUMResourceCatalog catalog = ECSUMResourceInternal;
//
//                    if (source == nil) { //android card msg
//                        catalog = ECSUMResourceInternal;
//                    } else  if (source.integerValue == 0) {
//                        catalog = ECSUMResourcePublic;
//                    } else if (source.integerValue == 1) {
//                        catalog = ECSUMResourceInternal;
//                    } else if (source.integerValue == 2) {
//                        catalog = ECSUMResourceEmail;
//                    }
//                    if (catalog != ECSUMResourceInternal) {
//                        for (ESpaceUMResource* res in resources) {
//                            res.resourceCatalog = catalog;
//                        }
//                    }
//                    return resources;
//                }
//            }
//        }
//        return nil;
//    } else {
//        return [self umResourceTokensFromString:self.body];
//    }
//}

//- (NSArray*) umResourceTokensFromString:(NSString*) str {
//    if ([str length] == 0) {
//        return nil;
//    }
//    NSMutableArray* ums = [NSMutableArray array];
//    NSArray* tokens = [[ESpaceDetailMessagParser sharedInstance] parseContent:str];
//    for (NSObject* token in tokens) {
//        if ([token isKindOfClass:[ESpaceUMPlaceHolder class]]) {
//            ESpaceUMPlaceHolder* control = (ESpaceUMPlaceHolder*) token;
//            if (control.umResource) {
//                if ([control.umResource isKindOfClass:[ESpaceUMImgResource class]]) {
//                    ESpaceUMImgResource* imageResource = (ESpaceUMImgResource*) control.umResource;
//                    if (!imageResource.thumbnailDirectory) {//未与本地文件关联
//                        imageResource.thumbnailDirectory = [self directoryForUMResourceThumbnails];
//                        imageResource.resourceCatalog = [self msgUMResourceCatalog];
//                    }
//                }
//                
//                if ([control.umResource isKindOfClass:[ESpaceUMVideoResource class]]) {
//                    ESpaceUMVideoResource* videoResource = (ESpaceUMVideoResource*) control.umResource;
//                    videoResource.thumbnailDirectory = [self directoryForUMResourceThumbnails];
//                }
//                if (!control.umResource.localDirectory) {
//                    control.umResource.localDirectory = [self directoryForUMResources];
//                }
//                if (!control.umResource.tmpDirectory) {
//                    if (control.umResource.umType == ESpaceUMTypeFile || control.umResource.umType == ESpaceUMTypeImage || control.umResource.umType == ESpaceUMTypeVideo) {
//                        control.umResource.tmpDirectory = [self dircetoryForUMResourceTmpdir];
//                    }
//                    //control.umResource.tmpDirectory = [self dircetoryForUMResourceTmpdir];
//                }
//                [ums addObject:control.umResource];
//            }
//        }
//    }
//    return ums;
//}

//// 子类重写此方法判断图片的下载来源
//- (ECSUMResourceCatalog)msgUMResourceCatalog
//{
//    return ECSUMResourceInternal;
//}

- (NSString*) directoryForUMResources {
    if ([self.session isKindOfClass:[ChatSessionEntity class]]) {
        ChatSessionEntity* chatSession = (ChatSessionEntity*)self.session;
        if (chatSession.target.contactId) {
            NSURL* url = [[[LOCAL_DATA_MANAGER userDataHome] URLByAppendingPathComponent:@"chat"] URLByAppendingPathComponent:chatSession.target.contactId];
            NSFileManager * fileManager = [NSFileManager defaultManager];
            BOOL bDir = NO;
            if ((![fileManager fileExistsAtPath:url.path isDirectory:&bDir]
                 || !bDir) && url) {
                [fileManager createDirectoryAtURL:url withIntermediateDirectories:YES attributes:nil error:nil];
            }
            return url.path;
        } else {
            return nil;
        }
    } else {
        return nil;
    }
}

- (NSString*) dircetoryForUMResourceTmpdir{
    NSString* path = [self directoryForUMResources];
    if (path) {
        NSString *thumbDir = [path stringByAppendingPathComponent:@"tmp"];
        NSFileManager * fileManager = [NSFileManager defaultManager];
        BOOL bDir = NO;
        if (thumbDir && (![fileManager fileExistsAtPath:thumbDir isDirectory:&bDir]
                         || !bDir)) {
            [fileManager createDirectoryAtPath:thumbDir withIntermediateDirectories:YES attributes:nil error:nil];
        }
        return thumbDir;
    }
    return nil;
}

- (NSString*) directoryForUMResourceThumbnails {
    NSString* path = [self directoryForUMResources];
    if (path) {
        NSString *thumbDir = [path stringByAppendingPathComponent:@"thumb"];
        NSFileManager * fileManager = [NSFileManager defaultManager];
        BOOL bDir = NO;
        if (thumbDir && (![fileManager fileExistsAtPath:thumbDir isDirectory:&bDir]
            || !bDir)) {
            [fileManager createDirectoryAtPath:thumbDir withIntermediateDirectories:YES attributes:nil error:nil];
        }
        return thumbDir;
    }
    return nil;
}

//- (ESpaceUMResource *)umResourceByReuseUMResourceLocalFile:(ESpaceUMResource *)umResource keepOriginal:(BOOL)keepOriginal encrypted:(BOOL) encrypted {
//    NSString* umDir = [self directoryForUMResources];
//    if (!umDir) {
//        //DDLogError(@"Directory for UMResource is invalid"); //su TODO
//        return nil;
//    }
//
//    // a. Move original file to umresource directory.
//    BOOL isDir = NO;
//    NSError *error;
//    if (![[ECSFileManager defaultManager] fileExistsAtPath:umDir isDirectory:&isDir] || !isDir) {
//        [[ECSFileManager defaultManager] createDirectoryAtPath:umDir withIntermediateDirectories:YES attributes:nil error:&error];
//    }
//
//    ESpaceUMResource *newUMResource = [umResource copy];
//    newUMResource.localDirectory = umDir;
//    if (![umResource remoteResource]) {
//        NSString *ext = [umResource.name pathExtension];
//        newUMResource.name = [[[NSUUID UUID] UUIDString] stringByAppendingPathExtension:ext];
//        newUMResource.resourcePath = [NSURL fileURLWithPath:newUMResource.localFilePath].absoluteString;
//    }
//
//    NSString *umPath = newUMResource.localFilePath;
//    if ([umResource isLocalFileReady] && [[umResource localFilePath] caseInsensitiveCompare:umPath]) {
//        if (encrypted) {
//            if ([[ECSFileManager defaultManager] fileExistsAtPath:umPath isDirectory:&isDir] && !isDir) {
//                [[ECSFileManager defaultManager] removeItemAtPath:umPath error:&error];
//            }
//
//            if (keepOriginal) {
//                [[ECSFileManager defaultManager] copyItemAtPath:umResource.localFilePath toPath:umPath error:&error];
//            } else {
//                [[ECSFileManager defaultManager] moveItemAtPath:umResource.localFilePath toPath:umPath error:&error];
//            }
//        } else {
//            if ([[NSFileManager defaultManager] fileExistsAtPath:umPath isDirectory:&isDir] && !isDir) {
//                [[NSFileManager defaultManager] removeItemAtPath:umPath error:&error];
//            }
//
//            if (keepOriginal) {
//                [[NSFileManager defaultManager] copyItemAtPath:umResource.localFilePath toPath:umPath error:&error];
//            } else {
//                [[NSFileManager defaultManager] moveItemAtPath:umResource.localFilePath toPath:umPath error:&error];
//            }
//        }
//    }
//
//    // b. If type of umResource is image but not a gif picture, generate thumbnail with original file directly.
//    if (umResource.umType == ESpaceUMTypeImage) {
//        ESpaceUMImgResource* imgResource = (ESpaceUMImgResource*)umResource;
//        ESpaceUMImgResource* newImgResource = (ESpaceUMImgResource *)newUMResource;
//        newImgResource.thumbnailDirectory = [self directoryForUMResourceThumbnails];
//        newImgResource.thumbnailWidth = imgResource.thumbnailWidth;
//        newImgResource.thumbnailHeight = imgResource.thumbnailHeight;
//        newImgResource.maxThumbnailWidthHeight = imgResource.maxThumbnailWidthHeight;
//
//        if (![[ECSFileManager defaultManager] fileExistsAtPath:newImgResource.thumbnailDirectory isDirectory:&isDir] || !isDir) {
//            [[ECSFileManager defaultManager] createDirectoryAtPath:newImgResource.thumbnailDirectory withIntermediateDirectories:YES attributes:nil error:&error];
//        }
//
//        [newImgResource reuseUMImageResourceThumbnail:imgResource keepOriginal:keepOriginal encrypted:encrypted];
//    }
//
//    // c. If type of umResource is video,
//    if (umResource.umType == ESpaceUMTypeVideo && [umResource isLocalFileReady]) {
//        ESpaceUMVideoResource* videoResource = (ESpaceUMVideoResource*)umResource;
//        ESpaceUMVideoResource* newVideoResource = (ESpaceUMVideoResource*)newUMResource;
//        newVideoResource.thumbnailDirectory = [self directoryForUMResourceThumbnails];
//
//        if (![[ECSFileManager defaultManager] fileExistsAtPath:newVideoResource.thumbnailDirectory isDirectory:&isDir] || !isDir) {
//            [[ECSFileManager defaultManager] createDirectoryAtPath:newVideoResource.thumbnailDirectory withIntermediateDirectories:YES attributes:nil error:&error];
//        }
//
//        [newVideoResource reuseUMVideoResourceThumbnail:videoResource keepOriginal:keepOriginal encrypted:encrypted];
//    }
//
//    return newUMResource;
//}

//- (void)reuseUMResourceBody:(ESpaceUMResource *)umResource {
//    ESpaceUMResource *um = [self umResourceByReuseUMResourceLocalFile:umResource keepOriginal:NO encrypted:[umResource needEncrypt] && [umResource remoteResource]];
//    self.body = [um description];
//}

//- (void)reuseShareLineMessageBody:(ESpaceSharedLinkMessage *)msg {
//    ESpaceUMResource *um = [self umResourceByReuseUMResourceLocalFile:msg.umResource keepOriginal:NO encrypted:[msg.umResource remoteResource] && [msg.umResource needEncrypt]];
//    msg.umResource = um;
//    self.body = msg.description;
//}

//- (void)reuseMessageBody:(MessageEntity *)message {
//    NSInteger contentType = [message.contentType integerValue];
//    switch (contentType) {
//        case ESpaceImageContentType:
//        case ESpaceVideoContentType:
//        case ESpaceAudioContentType:{
//            NSMutableString *body = [NSMutableString stringWithCapacity:0];
//            NSArray *rResources = [message umResources];
//            for (ESpaceUMResource *resource in rResources) {
//                BOOL remoteResource = [resource remoteResource];
//                BOOL needEncript = [resource needEncrypt];
//                ESpaceUMResource *um = [self umResourceByReuseUMResourceLocalFile:resource keepOriginal:YES encrypted:remoteResource && needEncript];
//                [body appendString:um.description];
//            }
//
//            self.body = body;
//        }
//            break;
//        case ESpaceShareLinkContentType:{
//            ESpaceUMResource *resource = [[message umResources] lastObject];
//            if (resource) {
//                BOOL remoteResource = [resource remoteResource];
//                BOOL needEncript = [resource needEncrypt];
//                ESpaceUMResource *um = [self umResourceByReuseUMResourceLocalFile:resource keepOriginal:YES encrypted:remoteResource && needEncript];
//                NSData *data = [message.body dataUsingEncoding:NSUTF8StringEncoding];
//                id jsonObj = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
//                if ([jsonObj isKindOfClass:NSDictionary.class]) {
//                    NSMutableDictionary *muteDic = [(NSDictionary *)jsonObj mutableCopy];
//                    muteDic[@"imgUrl"] = um.description;
//                    NSData *newData = [NSJSONSerialization dataWithJSONObject:muteDic options:0 error:nil];
//                    self.body = [[NSString alloc] initWithData:newData encoding:NSUTF8StringEncoding];
//                }
//            }
//
//        }
//            break;
//
//        case ESpacePublicAccountContentType:
//        case ESpaceFileContentType:{
//            NSArray *rResources = [message umResources];
//            for (ESpaceUMResource *resource in rResources) {
//                BOOL remoteResource = [resource remoteResource];
//                BOOL needEncript = [resource needEncrypt];
//                [self umResourceByReuseUMResourceLocalFile:resource keepOriginal:YES encrypted:remoteResource && needEncript];
//            }
//            self.body = message.body;
//        }
//            break;
//
//        default:
//            self.body = message.body;
//            if ([message.translateBody length]) {
//                self.body = [self.body stringByAppendingFormat:@"\n\n%@", message.translateBody];
//            }
//            break;
//    }
//
//}

//- (void)downloadThumbnails {
//    NSArray* ums = [self umResources];
//    for (ESpaceUMResource* um in ums) {
//        if (um.umType == ESpaceUMTypeImage) {
//            ESpaceUMImgResource* image = (ESpaceUMImgResource*) um;
//            NSString* thumbPath = [[self directoryForUMResourceThumbnails] stringByAppendingPathComponent:image.fileName];
//            if (image.thumbnailStatus != ESpaceThumbnailStatusDownloaded
//                && image.thumbnailStatus != ESpaceThumbnailStatusDownloading
//                && ![[ECSFileManager defaultManager] fileExistsAtPath:thumbPath]) {
//                if ([image isGif]) {
//                    [image downloadIfNeeded];
//                } else {
//                    [image downloadThumbnailIfNeeded];
//                }
//            }
//        } else if (um.umType == ESpaceUMTypeVideo) {
//            ESpaceUMVideoResource* video = (ESpaceUMVideoResource*) um;
//            video.thumbnailDirectory = [self directoryForUMResourceThumbnails];
//        } else if (um.umType == ESpaceUMTypeAudio) {
//            ESpaceUMAudioResource* audio = (ESpaceUMAudioResource*) um;
//            if (audio.umStatus != ESpaceUMStatusDownloaded
//                && audio.umStatus != ESpaceUMStatusDownloading
//                && ![audio localExites]) {
//                [audio downloadIfNeeded];
//            }
//        }
//    }
//}

- (void)removeSelf:(void (^)(NSError *))completionBlock {
    SessionEntity* session = self.session;
    if ([session isKindOfClass:[ChatSessionEntity class]]) {
        ContactEntity* target = ((ChatSessionEntity*)session).target;
        [[ESpaceIMessageService sharedInstance] deleteMessages:[NSArray arrayWithObject:self] session:session target:target completionBlock:completionBlock];
    } else {//local delete
        NSManagedObjectID* oid = self.objectID;
        NSManagedObjectContext* bgCtx = [LOCAL_DATA_MANAGER backgroundObjectContext];
        [bgCtx performBlock:^{
            MessageEntity* shadow = (MessageEntity*) [bgCtx objectWithID:oid];
            [shadow localDeleteSelf];
            [bgCtx saveToPersistent];
                
            if (completionBlock) {
                completionBlock(nil);
            }
        }];
    }
}

- (void) markReadLocal {
    
    NSManagedObjectID* oid = self.objectID;
    NSString* temMessageId = self.messageId;
    ESpaceLocalDataManager * localManager = LOCAL_DATA_MANAGER;
    dispatch_async(espace_coredata_management_queue, ^{
        NSManagedObjectContext* bgCtx = [localManager backgroundObjectContext];
        [bgCtx performBlockAndWait:^{
            MessageEntity* message = (MessageEntity*)[bgCtx objectWithID:oid];
            if (message.fault) {
                //DDLogError(@"message is fault, can not be mark read!");//su TODO
                if ([temMessageId length]) {
                    NSPredicate* queryPredicate = [NSPredicate predicateWithFormat:@"messageId = %@", temMessageId];
                    MessageEntity* temMsg = [ESpaceLocalDataManager fetchOneObject:queryPredicate inEnitity:@"MessageEntity" inContext:bgCtx];
                    if (nil == temMsg) {
                        //DDLogWarn(@"message is already deleted, no need to mark read local."); //su TODO
                        return;
                    }
                }
            }
            if (message.managedObjectContext && !message.isDeleted) {
                message.readed = [NSNumber numberWithBool:YES];
                [bgCtx saveToPersistent];
            }
        }];
    });
}

@end
