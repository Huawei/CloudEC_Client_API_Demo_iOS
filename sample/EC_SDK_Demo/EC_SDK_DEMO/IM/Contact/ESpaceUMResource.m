//
//  ESpaceUMResource.m
//  eSpaceUI
//
//  Created by huawei on 15/4/23.
//  Copyright (c) 2015年 www.huawei.com. All rights reserved.
//
#import <AVFoundation/AVFoundation.h>
#import <MobileCoreServices/MobileCoreServices.h>

#import "ESpaceUMResource.h"
#import "ESpaceImage.h"
#import "ESpaceMediaService.h"
#import "ECSafeMutableDictionary.h"
#import "ECSFileManager.h"
#import "ECSUtils.h"
#import <objc/runtime.h>
#import "NSString+FileType.h"
#import "ECSErrorCode.h"
#import "NSURL+Export.h"
#import "ECSUserMAAInfo.h"
#import "ECSAppConfig.h"
#import "ECSUMService.h"

#define UM_IMG_WIDTH_HEIGHT_MAX_FACTOR  2.0
#define UM_ONEBOX_MAX_LENGHT            2048

const char * umresource_objc_associate_key = "ESpaceUMResource_HttpOpeartion";

NSMapTable* umReourcesCache;

@interface ESpaceUMResource()

@property (nonatomic, strong) NSMutableDictionary* uploadCompletionBlockes;
@property (nonatomic, strong) NSMutableDictionary* downloadCompletionBlockes;
@property (nonatomic, strong) NSMutableDictionary* deleteCompletionBlockes;
@property (nonatomic, strong) NSOperation* operation;
@property (nonatomic, assign) BOOL isCached;
- (void) _setUmStatus:(ESpaceUMResourceStatus)umStatus;
- (NSString*) defaultExtention;
@end

@implementation ESpaceUMResource

@synthesize umStatus = _umStatus;
@synthesize name = _name;
@synthesize umFailedReason;

- (instancetype)init {
    if (self = [super init]) {
        _progress = [[NSProgress alloc] init];
        _uploadCompletionBlockes = [NSMutableDictionary dictionary];
        _downloadCompletionBlockes = [NSMutableDictionary dictionary];
        _deleteCompletionBlockes = [NSMutableDictionary dictionary];
        _fileType = FILETYPE_NORMAL;
    }
    return self;
}

- (BOOL)cachedResource {
    return self.isCached;
}

- (NSProgress *)progress {
    return _progress;
}

- (NSString *) fileName {
    NSString* name = _name;
    if ([self remoteResource]) {
        name = [ECSUtils MD5StringFromStr:self.resourcePath];
        NSString* ext = [_name pathExtension];
        if (!ext) {
            ext = [self defaultExtention];
        }
        if (ext) {
            name = [name stringByAppendingPathExtension:ext];
        }
    }
    return name;
}

- (NSString *)defaultExtention {
    return nil;
}

- (void)setUploadCompletion:(void (^)(NSError *))completionBlock forKey:(NSString *)key {
    if (!key || !completionBlock) {
        return;
    }
    @synchronized(_uploadCompletionBlockes) {
        _uploadCompletionBlockes[key] = [completionBlock copy];
    }
}

- (void) setDownloadCompletion:(void (^)(NSError *))completionBlock forKey:(NSString *)key {
    if (!key || !completionBlock) {
        return;
    }
    @synchronized(_downloadCompletionBlockes) {
        _downloadCompletionBlockes[key] = [completionBlock copy];
    }
}

- (void) setDeleteCompletion:(void(^)(NSError* error)) completionBlock forKey:(NSString*) key{
    if (!key || !completionBlock) {
        return;
    }
    @synchronized(_deleteCompletionBlockes) {
        _deleteCompletionBlockes[key] = [completionBlock copy];
    }
}


- (instancetype) initWithResource:(ESpaceUMResource*) resource {
    if (self = [self init]) {
        NSString* url = resource.resourcePath;
        self.resourcePath = url;
        self.umType = resource.umType;
        self.size = resource.size;
        self.name = resource.name;
        
        self.width = resource.width;
        self.height = resource.height;
        self.duration = resource.duration;
        self.accessCode = resource.accessCode;
        [self _setUmStatus:resource.umStatus];
        self.localDirectory = resource.localDirectory;
        self.tmpDirectory = resource.tmpDirectory;
    }
    return self;
}

- (BOOL) localExites {
    BOOL bDir = YES;
    return ([[ECSFileManager defaultManager] fileExistsAtPath:self.localFilePath isDirectory:&bDir] && !bDir);
}

- (NSString *)description {
    NSMutableString* description = [NSMutableString stringWithString:@"/:um_begin{"];
    NSString* type = @"";
    switch (_umType) {
        case ESpaceUMTypeFile:
            type = UM_FILE_TYPE;
            break;
        case ESpaceUMTypeAudio:
            type = UM_AUDIO_TYPE;
            break;
        case ESpaceUMTypeVideo:
            type = UM_VIDEO_TYPE;
            break;
        case ESpaceUMTypeFax:
            type = UM_FAX_TYPE;
            break;
        case ESpaceUMTypeImage:
            type = UM_IMG_TYPE;
            break;
        default:
            break;
    }
    [description appendFormat:@"%@|%@|%lld|%@|%lu", self.resourcePath, type, _size, _name, (unsigned long)_duration];
    if ([self.accessCode length] != 0) {
//        if (self.width || self.height) {
            [description appendFormat:@"|%ld;%ld;%@", (long)self.width, (long)self.height, self.accessCode];
//        } else {
//            [description appendFormat:@"|%@", self.accessCode];
//        }
        
    } else {
        //if (self.width || self.height) {
            [description appendFormat:@"|%ld;%ld", (long)self.width, (long)self.height];
        //}
    }
    [description appendString:@"}/:um_end"];
    return description;
}

- (NSString *) localFilePath {
    return [self.localDirectory stringByAppendingPathComponent:self.fileName];
}

- (void) setLocalDirectory:(NSString *)localPath {
    if (localPath
        && _localDirectory
        && [localPath caseInsensitiveCompare:_localDirectory] == NSOrderedSame) {
        return;
    }
    _localDirectory = localPath;
    if (self.fileName && localPath) {
        if ([[ECSFileManager defaultManager] fileExistsAtPath:self.localFilePath]) {
            if (_umStatus != ESpaceUMStatusUploaded
                && _umStatus != ESpaceUMStatusUploadFailed
                && _umStatus != ESpaceUMStatusUploading) {
                [self _setUmStatus:ESpaceUMStatusDownloaded];;
            }
        }
    }
}

+ (NSSet *)keyPathsForValuesAffectingLocalFilePath
{
    return [NSSet setWithObjects:@"localPath", @"name", nil];
}

- (void) setName:(NSString *)name {
    _name = name;
    if (name && self.localDirectory) {
        if ([[ECSFileManager defaultManager] fileExistsAtPath:self.localFilePath]) {
            [self _setUmStatus:ESpaceUMStatusUploaded];
        }
    }
}

- (void)setResourcePath:(NSString *)resourcePath {
    if (self.isCached && resourcePath && ![_resourcePath isEqualToString:resourcePath]) {
        [umReourcesCache setObject:self forKey:resourcePath];
    }
    _resourcePath = resourcePath;
}

- (void)_setUmFailedReason:(ESpaceUMFailedReason)failedReason {
    umFailedReason = failedReason;
}

- (void) _setUmStatus:(ESpaceUMResourceStatus)umStatus {
    if (_umStatus == umStatus) {
        return;
    }
    if (umStatus == ESpaceUMStatusDownloaded) {
        if (_umStatus == ESpaceUMStatusUploaded
            || _umStatus == ESpaceUMStatusUploadFailed
            || _umStatus == ESpaceUMStatusUploading) {
            return;
        }
    }
//    [self willChangeValueForKey:@"umStatus"];
    _umStatus = umStatus;
//    [self didChangeValueForKey:@"umStatus"];
}

- (BOOL) needDownload {
    /*ECSUserConfig* currentUser = [[ECSAppConfig sharedInstance] currentUser];*/
//    if ([currentUser isSupportFunction:EN_FUNC_UM]) {
        NSURL* url = [NSURL URLWithString:self.resourcePath];
        if (url.scheme) {
            if ([url isFileURL]) {
                return NO;
            } else {
                return self.umStatus != ESpaceUMStatusDownloading
                && self.umStatus != ESpaceUMStatusDownloaded
                && self.umStatus != ESpaceUMStatusUploading
                && self.umStatus != ESpaceUMStatusUploadFailed;
            }
        } else {//umserver使用非标准url
            return self.umStatus != ESpaceUMStatusDownloading
            && self.umStatus != ESpaceUMStatusDownloaded
            && self.umStatus != ESpaceUMStatusUploading
            && self.umStatus != ESpaceUMStatusUploadFailed;
        }
//    } else {
//        return NO;
//    }
}

- (void) downloadIfNeeded {
    if ([self needDownload]) {
        [self download:nil];
    }
}

- (void) downloadIfNeeded:(void(^)(NSError* error))completion {
    if ([self needDownload]) {
        [self download:completion];
    }
}

- (BOOL) remoteResource {
    NSURL* url = [NSURL URLWithString:self.resourcePath];
    if (url) {
        if (url.scheme) {
            if ([url isFileURL]) {
                return NO;
            } else {
                return YES;
            }
        } else {//umserver使用非标准url
            return YES;
        }
    }
    return NO;
}

- (BOOL) needUpload {
    NSURL* url = [NSURL URLWithString:self.resourcePath];
    if (url) {
        if (url.scheme) {
            if ([url isFileURL]) {
                return self.umStatus != ESpaceUMStatusUploading
                && self.umStatus != ESpaceUMStatusDownloading
                && self.umStatus != ESpaceUMStatusUploaded;
            } else {
                return NO;
            }
        } else {//umserver使用非标准url
            return NO;
        }
    } else {
        return self.umStatus != ESpaceUMStatusUploading
        && self.umStatus != ESpaceUMStatusDownloading
        && self.umStatus != ESpaceUMStatusUploaded;
    }
    
}

- (BOOL)canPreview {
    ESpaceGPFileType fileType = [self.name fileType];
    NSString* extension = [[self.name pathExtension] lowercaseString];
    CFStringRef fileExtension = (__bridge CFStringRef)extension;
    CFStringRef fileUTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, fileExtension, NULL);
    NSString *mimeType = (__bridge_transfer NSString*)UTTypeCopyPreferredTagWithClass(fileUTI, kUTTagClassMIMEType);
    
    BOOL isOfficeDoc = (ESpaceGPUnknownFile < fileType && fileType < ESpaceGPOfficeEnd);
    BOOL isImage = (ESpaceGPOfficeEnd < fileType && fileType < ESpaceGPImageEnd);
    BOOL isVideo = (ESpaceGPImageEnd < fileType && fileType < ESpaceGPVideoEnd);
    BOOL isAudio = (ESpaceGPVideoEnd < fileType && fileType < ESpaceGPAudioEnd);

    Boolean result = FALSE;
    if (isOfficeDoc) {
        result = TRUE;
    } else if (isImage) {
        result = UTTypeConformsTo(fileUTI, kUTTypeImage);
    } else if (isVideo) {
        result = [AVURLAsset isPlayableExtendedMIMEType:mimeType];
    } else if (isAudio) {
        result = [AVURLAsset isPlayableExtendedMIMEType:mimeType];
    } else {
        result = UTTypeConformsTo(fileUTI, kUTTypeText);
    }
    
    if (fileUTI) {
        CFRelease(fileUTI);
    }
    
    return (result == TRUE);
}

- (void) uploadIfNeeded {
    if ([self needUpload]) {
        [self upload:nil];
    }
}

- (void) deleted:(void(^)(NSError *error)) completionBlock{
    [self setDeleteCompletion:completionBlock forKey:@"__completionBlock"];
    //    if ([self.localFilePath length] == 0
    //        || ![[NSFileManager defaultManager] fileExistsAtPath:self.localFilePath]) {
    //        NSDictionary *userInfo = @{NSLocalizedFailureReasonErrorKey : [NSString stringWithFormat:@"file [%@] not exites!", self.localFilePath]};
    //        NSError* error = [NSError errorWithDomain:ECSUMErrorDomain code:ECSUMFileNotFoundError userInfo:userInfo];
    //        NSArray* callbacks = _deleteCompletionBlockes.allValues;
    //        for (ESpaceUMResourceCompletionBlock completionBlock in callbacks) {
    //            completionBlock(error);
    //        }
    //        [_deleteCompletionBlockes removeAllObjects];
    //        return;
    //    }
    
    //file ID == 0
    __weak typeof(self) weakSelf = self;
    NSOperation * operation = [[ECSUMService sharedInstance] deleted:self.fileID completionBlock:^(NSError *error) {
        __strong typeof(self) strongSelf = weakSelf;
        NSArray* callbacks = strongSelf.deleteCompletionBlockes.allValues;
        for (ESpaceUMResourceCompletionBlock completionBlock in callbacks) {
            completionBlock(error);
        }
        if (error) {
            NSLog(@"deleted error");
        }else{
            NSLog(@"deleted success");
        }
        [strongSelf.deleteCompletionBlockes removeAllObjects];
        if (strongSelf.operation) {
            objc_setAssociatedObject(strongSelf.operation, umresource_objc_associate_key, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
        
    } ];
    self.operation = operation;
    objc_setAssociatedObject(operation, umresource_objc_associate_key, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
}



- (void) download:(void(^)(NSError* error)) completionBlock{
    [self setDownloadCompletion:completionBlock forKey:@"__completionBlock"];
    NSString *downloadDir = self.tmpDirectory.length > 0 ? _tmpDirectory : _localDirectory;
    if ([self.resourcePath length] == 0) {
        NSDictionary *userInfo = @{NSLocalizedFailureReasonErrorKey : @"file resource path is null"};
        NSError* error = [NSError errorWithDomain:ECSUMErrorDomain  code:ECSUMFileResourcePathError userInfo:userInfo];
        NSArray* callbacks = _downloadCompletionBlockes.allValues;
        for (ESpaceUMResourceCompletionBlock completionBlock in callbacks) {
            completionBlock(error);
        }
        [_downloadCompletionBlockes removeAllObjects];
        return;
    }
    BOOL bDir = YES;
    if (_localDirectory && (![[ECSFileManager defaultManager] fileExistsAtPath:_localDirectory isDirectory:&bDir]
                            || !bDir)) {
        [[ECSFileManager defaultManager] createDirectoryAtPath:_localDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString* filePath = [_localDirectory stringByAppendingPathComponent:self.fileName];
    if ([[ECSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&bDir]
        && !bDir) {
        _umStatus = ESpaceUMStatusDownloaded;
        NSArray* callbacks = _downloadCompletionBlockes.allValues;
        for (ESpaceUMResourceCompletionBlock completionBlock in callbacks) {
            completionBlock(nil);
        }
        [_downloadCompletionBlockes removeAllObjects];
        return;
    }
    [self _setUmStatus:ESpaceUMStatusDownloading];
    
    long long startTime = ( long long)[[NSDate date] timeIntervalSince1970]*1000;
    
    __weak typeof(self) weakSelf = self;
    NSLog(@"<ESpaceUMResource> Start to download resource:%@", self);
    NSOperation * operation = [[ECSUMService sharedInstance] download:_resourcePath catalog:self.resourceCatalog encrypt:[self needEncrypt] progress:_progress accessCode:[self accessCode] bThumbnial:NO width:[self width] height:[self height] localPath:downloadDir fileName:self.fileName completionBlock:^(NSError *error,NSString* fileId) {
        __strong typeof(self) strongSelf = weakSelf;
        //added by  wwx276172
        if (!error ) {
            NSTimeInterval nowTime = [[NSDate date] timeIntervalSince1970]*1000;
            long long  offsetTime = ( long long)nowTime - startTime;
            
            if ((offsetTime > 0)){
//                [[ESpaceEventRecordModel shareEventRecordModel]  recordCapabilityWithId:CAPABLE_UM_DOWNLOAD_ID
//                                                                           withDuration:(NSInteger)offsetTime ];TODO wxy
            }
        } else {
            NSLog(@"<ESpaceUMResource> Failed to download resource:%@ \nerror:%@", [strongSelf description], error);
        }
        
        //        NSArray* callbacks = strongSelf.downloadCompletionBlockes.allValues;
        //        for (ESpaceUMResourceCompletionBlock completionBlock in callbacks) {
        //            completionBlock(error);
        //        }
        if (error) {
            //downloadDir.filename;
            NSString *filePath = [downloadDir stringByAppendingPathComponent:self.fileName];
            [[ECSFileManager defaultManager] removeItemAtPath:filePath error:nil];
            
            NSArray* callbacks = strongSelf.downloadCompletionBlockes.allValues;
            for (ESpaceUMResourceCompletionBlock completionBlock in callbacks) {
                completionBlock(error);
            }
            if (ECSCommonHttpForbiddenError == error.code) {
                [strongSelf _setUmFailedReason:ESpaceUMfailed_Forbidden];
            }
            else if (ECSCommonHttpNotFoundError == error.code) {
                [strongSelf _setUmFailedReason:ESpaceUMfailed_FileRemoved];
            }
            if ([self needEncrypt]) {
                [[ECSFileManager defaultManager] removeItemAtPath:downloadDir error:nil];
            }else{
                [[NSFileManager defaultManager] removeItemAtPath:downloadDir error:nil];
            }
            
            [strongSelf _setUmStatus:ESpaceUMStatusDownloadFailed];
        } else {
            if (_tmpDirectory.length > 0) {
                NSString *tmpFilePath = [_tmpDirectory stringByAppendingPathComponent:self.fileName];
                NSString *reallocalFile = [_localDirectory stringByAppendingPathComponent:self.fileName];
                NSError *error = nil;
                if ([self needEncrypt]) {
                    [[ECSFileManager defaultManager] moveItemAtPath:tmpFilePath toPath:reallocalFile error:&error];
                }else{
                    [[NSFileManager defaultManager] moveItemAtPath:tmpFilePath toPath:reallocalFile error:&error];
                }
            }
            NSArray* callbacks = strongSelf.downloadCompletionBlockes.allValues;
            for (ESpaceUMResourceCompletionBlock completionBlock in callbacks) {
                completionBlock(error);
            }
            [strongSelf _setUmStatus:ESpaceUMStatusDownloaded];
        }
        
        [strongSelf.downloadCompletionBlockes removeAllObjects];
        if (strongSelf.operation) {
            objc_setAssociatedObject(strongSelf.operation, umresource_objc_associate_key, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
    }];
    self.operation = operation;
    if (operation) {
        objc_setAssociatedObject(operation, umresource_objc_associate_key, self, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

- (void) upload:(void(^)(NSError* error)) completionBlock {
    NSString* filePath = [_localDirectory stringByAppendingPathComponent:_name];
    [self setUploadCompletion:completionBlock forKey:@"__completionBlock"];
    
    if ([filePath length] == 0
        || ![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        NSDictionary *userInfo = @{NSLocalizedFailureReasonErrorKey : [NSString stringWithFormat:@"file [%@] not exites!", filePath]};
        NSError* error = [NSError errorWithDomain:ECSUMErrorDomain code:ECSUMFileNotFoundError userInfo:userInfo];
        NSArray* callbacks = _uploadCompletionBlockes.allValues;
        for (ESpaceUMResourceCompletionBlock completionBlock in callbacks) {
            completionBlock(error);
        }
        [_uploadCompletionBlockes removeAllObjects];
        return;
    }
    [self _setUmStatus: ESpaceUMStatusUploading];
    
    //added by  wwx276172
    long long startTime = ( long long)[[NSDate date] timeIntervalSince1970]*1000;
    NSDictionary *fileAttr = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
    int filesz =[[fileAttr objectForKey:NSFileSize] intValue];
    __weak typeof(self) weakSelf = self;
    NSLog(@"<ESpaceUMResource> Start to upload resource:%@", self);
    self.operation = [[ECSUMService sharedInstance] upload:filePath progress:_progress fileType:self.fileType completionBlock:^(NSError *error, NSString *url,NSString* fileId, NSString *accessCode) {
        __strong typeof(self) strongSelf = weakSelf;
        //added by  wwx276172
        if (!error ) {
            NSTimeInterval nowTime = [[NSDate date] timeIntervalSince1970]*1000;
            long long  offsetTime = ( long long)nowTime - startTime;
            
            if ((offsetTime > 0)){
//                [[ESpaceEventRecordModel shareEventRecordModel]  recordCapabilityWithId:CAPABLE_UM_UPLOAD_ID
//                                                                           withDuration:(NSInteger)offsetTime
//                                                                         withCustomInfo:[NSString stringWithFormat:@"%d",filesz]];TODO wxy
            }
        } else {
            NSLog(@"<ESpaceUMResource> Failed to upload resource:%@ \nerror:%@", [strongSelf description], error);
        }
        
        
        if (url) {
            //rename local file name
            NSString* preLocalFilePath = strongSelf.localFilePath;
            BOOL hasThumbFilePath = [strongSelf respondsToSelector:@selector(localThumbFilePath)];
            NSString* preLocalThumbPath = hasThumbFilePath ? [strongSelf valueForKey:@"localThumbFilePath"] : nil;
            strongSelf.resourcePath = url;
            NSString* localThumbPath = hasThumbFilePath ? [strongSelf valueForKey:@"localThumbFilePath"] : nil;
            [[NSFileManager defaultManager] moveItemAtPath:preLocalFilePath toPath:strongSelf.localFilePath error:nil];
            if (preLocalThumbPath && localThumbPath) {
                [[NSFileManager defaultManager] moveItemAtPath:preLocalThumbPath toPath:localThumbPath error:nil];
            }
        }
        if (fileId) {
            //NSLog(@"------fileID-------- %@",fileId);
            weakSelf.fileID = fileId;
        }
        strongSelf.accessCode = accessCode;
        NSArray* callbacks = strongSelf.uploadCompletionBlockes.allValues;
        for (ESpaceUMResourceCompletionBlock completionBlock in callbacks) {
            completionBlock(error);
        }
        [strongSelf _setUmStatus:error ? ESpaceUMStatusUploadFailed : ESpaceUMStatusUploaded];
        [strongSelf.uploadCompletionBlockes removeAllObjects];
        
        if (strongSelf.operation) {
            objc_setAssociatedObject(strongSelf.operation, umresource_objc_associate_key, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
    }];
    if (self.operation) {
        objc_setAssociatedObject(self.operation, umresource_objc_associate_key, self, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

- (void)cancel {
    [self.operation cancel];
}

//制作缩略图
+ (UIImage*) createThumbnailForImage:(UIImage*) image maxSize:(CGSize) bounds{
    if (!image) {
        return nil;
    }
    CGFloat size = image.size.width/image.size.height;
    if (size >= 5 || size <= 0.2) {
        CGSize longImageThumbSize;
        if (size >= 5) {
            //宽图
            longImageThumbSize.width = 320;
            longImageThumbSize.height = image.size.height;
        }else{
            //长图
            longImageThumbSize.width = image.size.width;
            longImageThumbSize.height =640;
        }
        CGRect sizeRect = CGRectMake(0, 0, longImageThumbSize.width, longImageThumbSize.height);
        CGImageRef imageRef = image.CGImage;
        CGImageRef imagePartRef = CGImageCreateWithImageInRect(imageRef, sizeRect);
        UIImage *cropImage = [UIImage imageWithCGImage:imagePartRef];
        CGImageRelease(imagePartRef);

        return cropImage;
    }
    
    CGSize thumbSize = image.size;
    if (thumbSize.width  > bounds.width) {
        thumbSize.height = thumbSize.height * bounds.width / thumbSize.width;
        thumbSize.width = bounds.width;
    }
    if (thumbSize.height > bounds.height) {
        thumbSize.width =  thumbSize.width * bounds.height / thumbSize.height;
        thumbSize.height = bounds.height;
    }
    if (CGSizeEqualToSize(thumbSize, image.size)) {
        return image;
    } else {
        UIGraphicsBeginImageContextWithOptions(thumbSize, YES, 0);
        [image drawInRect:CGRectMake(0, 0, thumbSize.width, thumbSize.height)];
        UIImage* thumbnail = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return thumbnail;
    }
}

- (BOOL)needEncrypt {
    if (_umType == ESpaceUMTypeFile) {
        ESpaceGPFileType fileType = [_name fileType];
        if (ESpaceGPOfficeEnd < fileType && fileType < ESpaceGPImageEnd) {
            return NO;
        } else if (ESpaceGPImageEnd < fileType && fileType < ESpaceGPVideoEnd) {
            return NO;
        } else if (ESpaceGPVideoEnd < fileType && fileType < ESpaceGPAudioEnd) {
            return NO;
        }
        return [[ECSAppConfig sharedInstance] currentUser].maaInfo.wrMDMFile;
    }
    
    return [[ECSAppConfig sharedInstance] currentUser].maaInfo.enableEncryptData;
}

- (BOOL) needPrompt {
    return self.size >= (1024 * 1024);
}

- (BOOL) isLocalFileReady {
    switch (self.umStatus) {
        case ESpaceUMStatusUploading:
        case ESpaceUMStatusUploaded:
        case ESpaceUMStatusDownloaded:
        case ESpaceUMStatusUploadFailed: {
            return YES;
        }
            break;
            
        default:
            return NO;
            break;
    }
}


- (id)copyWithZone:(NSZone *)zone {
    id umResource = [[[self class] alloc] initWithResource:self];
    return umResource;
}
@end

@interface ESpaceUMImgResource()
@property (nonatomic, strong) NSMutableDictionary* thumbnailDownloadCompletionBlocks;
@property (nonatomic, strong) NSOperation * thumbnailOperation;
@end

@implementation ESpaceUMImgResource

@synthesize thumbnailStatus = _thumbnailStatus;

- (instancetype)init {
    if (self = [super init]) {
        _maxThumbnailWidthHeight = THUMBNAIL_PHOTO_WIDTH;
        _thumbnailDownloadCompletionBlocks = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)setThumbnailStatus:(ESpaceUMThumbnailStatus)thumbnailStatus {
    _thumbnailStatus = thumbnailStatus;
}

- (BOOL) thumbExites {
    BOOL bDir = YES;
    return [[ECSFileManager defaultManager] fileExistsAtPath:self.localThumbFilePath isDirectory:&bDir] && !bDir;
}

- (NSData*) localImageData {
    return [[ECSFileManager defaultManager] contentsAtPath:self.localFilePath];
}

- (NSData*) localThumbnailData {
    return [[ECSFileManager defaultManager] contentsAtPath:self.localThumbFilePath];
}

- (UIImage*) localThumbnail {
    UIImage* thumbnail = nil;
    NSData* imageData = [self localThumbnailData];
    if (imageData) {
        thumbnail = [UIImage imageWithData:imageData];
    }
    return thumbnail;
}

- (NSString *)defaultExtention {
    return @"png";
}

- (UIImage*) localImage {
    UIImage* image = nil;
    NSData* imageData = [[ECSFileManager defaultManager] contentsAtPath:self.localFilePath];
    
    if (imageData) {
        if ([self isGif]) {
            image = [ESpaceImage imageWithData:imageData];
        } else
        {
            image = [UIImage imageWithData:imageData];
        }
    }
    return image;
}

- (void)setThumbnailDownloadCompletion:(void (^)(NSError * error))completionBlock forKey:(NSString *)key {
    if (!key || !completionBlock) {
        return;
    }
    @synchronized(_thumbnailDownloadCompletionBlocks) {
        _thumbnailDownloadCompletionBlocks[key] = [completionBlock copy];
    }
}

- (NSString *)localThumbFilePath {
    return [self.thumbnailDirectory stringByAppendingPathComponent:self.fileName];
}

- (void)setThumbnailDirectory:(NSString *)thumbnailDirectory {
    _thumbnailDirectory = thumbnailDirectory;
    
    if (thumbnailDirectory && self.fileName.length > 0) {
        if ([[ECSFileManager defaultManager] fileExistsAtPath:[self localThumbFilePath]]) {
            if (_thumbnailStatus != ESpaceThumbnailStatusDownloaded) {
                [self setThumbnailStatus:ESpaceThumbnailStatusDownloaded];
            }
        }
    }
}


- (void)setName:(NSString *)name {
    [super setName:name];
    if (self.thumbnailDirectory && name) {
        if ([[ECSFileManager defaultManager] fileExistsAtPath:[self localThumbFilePath]]) {
            [self setThumbnailStatus:ESpaceThumbnailStatusDownloaded];
        }
    }
}

+ (NSSet *)keyPathsForValuesAffectingLocalThumbFilePath {
    return [NSSet setWithObjects:@"thumbnailFileName", @"name", @"thumbnailPath", nil];
}

- (BOOL) supportThumbnailDownload {
    //所有环境均支持缩略图下载，返回yes
    return YES;
//    ECSUserConfig* currentUser = [[ECSAppConfig sharedInstance] currentUser];
//    return currentUser.maaInfo.UMMode == 0 /*&& [currentUser isSupportFunction:EN_FUNC_UM]*/;
}

- (void) downloadThumbnailIfNeeded {
    if ([self supportThumbnailDownload]) {
        if (self.thumbnailStatus == ESpaceThumbnailStatusDownloaded
            || self.thumbnailStatus == ESpaceThumbnailStatusDownloading
            || self.umStatus == ESpaceUMStatusUploading) {
            return;
        }
        [self downloadThumbnail:nil];
    }
}

- (CGSize) thumbImgSize {
    CGFloat size = self.width/self.height;
    if (size >= 5 || size <= 0.2) {
        //认为是长图
        if (size >= 5) {
            CGFloat width = self.width/2;
            width = width > UM_ONEBOX_MAX_LENGHT ? UM_ONEBOX_MAX_LENGHT : width;                 //云盘限制，最长边不能超过2048
            CGFloat height = self.height/self.width * width;
            return CGSizeMake(width, height);
        }else{
            CGFloat height = self.height/2;
            height = height > UM_ONEBOX_MAX_LENGHT ? UM_ONEBOX_MAX_LENGHT : height;
            CGFloat width = size * height;
            return CGSizeMake(width, height);
        }
    }
    
    CGFloat width = _thumbnailWidth ?: _maxThumbnailWidthHeight * [UIScreen mainScreen].scale;
    CGFloat height = _thumbnailHeight ?: _maxThumbnailWidthHeight * [UIScreen mainScreen].scale;
    CGFloat factor = 1.0;
    if (!width) {
        width = THUMBNAIL_PHOTO_WIDTH;
    }
    if (!height) {
        height = THUMBNAIL_PHOTO_HEIGHT;
    }
    if (_thumbnailWidth && _thumbnailHeight) {
        factor = _thumbnailHeight > _thumbnailWidth ? _thumbnailHeight / _thumbnailWidth : _thumbnailWidth / _thumbnailHeight;
    } else {
        CGFloat tWidth = self.width;
        CGFloat tHeight = self.height;
        if (tWidth && tHeight) {
            factor = tHeight > tWidth ? tHeight / tWidth : tWidth / tHeight;
        }
    }
    if (factor >= UM_IMG_WIDTH_HEIGHT_MAX_FACTOR) {
        width *= UM_IMG_WIDTH_HEIGHT_MAX_FACTOR * 1.5;
        height *= UM_IMG_WIDTH_HEIGHT_MAX_FACTOR * 1.5;
    }
    //云盘限制，最长边不超过2048
    if (width > UM_ONEBOX_MAX_LENGHT) {
        //CGFloat tempWidth = width;
        height = UM_ONEBOX_MAX_LENGHT / width * height;
        width = UM_ONEBOX_MAX_LENGHT;
    }
    if (height > UM_ONEBOX_MAX_LENGHT){
        //CGFloat tempHeight = height;
        width = UM_ONEBOX_MAX_LENGHT / height * width;
        height = UM_ONEBOX_MAX_LENGHT;
    }
    return CGSizeMake(width, height);
}

- (void) downloadThumbnail:(void(^)(NSError* error)) completionBlock {
    [self setThumbnailDownloadCompletion:completionBlock forKey:@"__completionBlock"];
    NSString *downloadDir = self.tmpDirectory.length > 0 ? self.tmpDirectory : _thumbnailDirectory;
    if ([self.resourcePath length] == 0) {
        NSDictionary *userInfo = @{NSLocalizedFailureReasonErrorKey : @"file resource path is null"};
        NSError* error = [NSError errorWithDomain:ECSUMErrorDomain code:ECSUMFileResourcePathError userInfo:userInfo];
        NSArray* callbacks = _thumbnailDownloadCompletionBlocks.allValues;
        for (ESpaceUMResourceCompletionBlock completionBlock in callbacks) {
            completionBlock(error);
        }
        [_thumbnailDownloadCompletionBlocks removeAllObjects];
        return;
    }
    [self setThumbnailStatus:ESpaceThumbnailStatusDownloading];
    BOOL bDir = YES;
    if (_thumbnailDirectory && (![[ECSFileManager defaultManager] fileExistsAtPath:_thumbnailDirectory isDirectory:&bDir]
                                || !bDir)) {
        [[ECSFileManager defaultManager] createDirectoryAtPath:_thumbnailDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    }
    __weak typeof(self) weakSelf = self;
    CGSize thumbSize = [self thumbImgSize];
    NSLog(@"<ESpaceUMResource> Start to download thumbnail:%@", self);
    NSOperation * operation = [[ECSUMService sharedInstance] download:self.resourcePath
                                                                        catalog:self.resourceCatalog
                                                                        encrypt:[self needEncrypt]
                                                                       progress:nil
                                                                     accessCode:[self accessCode]
                                                                     bThumbnial:YES
                                                                          width:thumbSize.width
                                                                         height:thumbSize.height
                                                                      localPath:downloadDir
                                                                       fileName:self.fileName
                                                                completionBlock:^(NSError *error ,NSString* fileId) {
                                                                    __strong ESpaceUMImgResource* strongSelf = weakSelf;
                                                                    NSArray* callbacks = strongSelf.thumbnailDownloadCompletionBlocks.allValues;
                                                                    //                                          for (ESpaceUMResourceCompletionBlock completionBlock in callbacks) {
                                                                    //                                              completionBlock(error);
                                                                    //                                          }
                                                                    //[strongSelf.thumbnailDownloadCompletionBlocks removeAllObjects];
                                                                    //[strongSelf setThumbnailStatus:error ? ESpaceThumbnailStatusDownloadFailed : ESpaceThumbnailStatusDownloaded];
                                                                    if (error) {
                                                                        NSLog(@"<ESpaceUMResource> Failed to download thumbnail resource:%@ \nerror:%@", [strongSelf description], error);
                                                                        NSString *filePath = [downloadDir stringByAppendingPathComponent:self.fileName];
                                                                        [[ECSFileManager defaultManager] removeItemAtPath:filePath error:nil];
                                                                        for (ESpaceUMResourceCompletionBlock completionBlock in callbacks) {
                                                                            completionBlock(error);
                                                                        }
                                                                        [strongSelf setThumbnailStatus:ESpaceThumbnailStatusDownloadFailed];
                                                                    }else{
                                                                        if (self.tmpDirectory.length > 0) {
                                                                            NSString *tmpFilePath = [self.tmpDirectory stringByAppendingPathComponent:self.fileName];
                                                                            NSString *reallocalFile = [_thumbnailDirectory stringByAppendingPathComponent:self.fileName];
                                                                            if ([self needEncrypt]) {
                                                                                [[ECSFileManager defaultManager] moveItemAtPath:tmpFilePath toPath:reallocalFile error:nil];
                                                                            }else{
                                                                                [[NSFileManager defaultManager] moveItemAtPath:tmpFilePath toPath:reallocalFile error:nil];
                                                                            }
                                                                        }
                                                                        for (ESpaceUMResourceCompletionBlock completionBlock in callbacks) {
                                                                            completionBlock(error);
                                                                        }
                                                                        [strongSelf setThumbnailStatus:ESpaceThumbnailStatusDownloaded];
                                                                    }
                                                                    
                                                                    [strongSelf.thumbnailDownloadCompletionBlocks removeAllObjects];
                                                                    
                                                                    if (strongSelf.thumbnailOperation) {
                                                                        objc_setAssociatedObject(strongSelf.thumbnailOperation , umresource_objc_associate_key, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                                                                    }
                                                                }];
    self.thumbnailOperation = operation;
    if (operation) {
        objc_setAssociatedObject(operation, umresource_objc_associate_key, self, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

- (void)download:(void (^)(NSError *))completionBlock {
    NSString* thumbnailPath = self.localThumbFilePath;
    NSString* imagePath = self.localFilePath;
    NSString* thumbnailDirectory = self.thumbnailDirectory;
    BOOL needEncrypt = [self needEncrypt];
    __weak typeof(self) weakSelf = self;
    [self setDownloadCompletion:^(NSError *error) {
        if (!error) {
            BOOL bDir = YES;
            if (![[ECSFileManager defaultManager] fileExistsAtPath:thumbnailPath isDirectory:&bDir]
                || bDir) {
                NSData* imageData = [[ECSFileManager defaultManager] contentsAtPath:imagePath];
                if (imageData) {
                    UIImage* image = [UIImage imageWithData:imageData];
                    if (image) {
                        CGSize thumbSize = [weakSelf thumbImgSize];
                        UIImage* thumbnail = [ESpaceUMResource createThumbnailForImage:image maxSize:thumbSize];
                        if (thumbnail) {
                            NSData* data = UIImagePNGRepresentation(thumbnail);
                            needEncrypt ? [[ECSFileManager defaultManager] createDirectoryAtPath:thumbnailDirectory withIntermediateDirectories:YES attributes:nil error:nil] : [[NSFileManager defaultManager] createDirectoryAtPath:thumbnailDirectory withIntermediateDirectories:YES attributes:nil error:nil];
                            needEncrypt ? [[ECSFileManager defaultManager] createFileAtPath:thumbnailPath contents:data attributes:nil] : [[NSFileManager defaultManager] createFileAtPath:thumbnailPath contents:data attributes:nil];
                            [weakSelf setThumbnailStatus:ESpaceThumbnailStatusDownloaded];
                        }
                    }
                }
                
            }
        }
    } forKey:@"__generatethumbnailblock"];
    [super download:completionBlock];
}

- (CGSize)imageSize {
    CGSize imageSize = CGSizeMake(self.width / [UIScreen mainScreen].scale,
                                  self.height / [UIScreen mainScreen].scale);
    if (CGSizeEqualToSize(imageSize, CGSizeZero)) {
        UIImage *localThumbnail = [self localThumbnail];
        UIImage *localImage = [self localImage];
        if (localThumbnail) {
            imageSize = localThumbnail.size;
        } else if (localImage) {
            imageSize = localImage.size;
        } else {
            imageSize = CGSizeMake(135, 74);
        }
    }
    
    return imageSize;
}

- (BOOL)isGif {
    return [self.name.pathExtension caseInsensitiveCompare:@"gif"] == NSOrderedSame;
}

- (BOOL)canPreviewOriginal {
    return YES;                                  //图片大小下载不做限制
    //return self.size <= (10 * 1024 * 1024 * 10); // Less than 100M.
}

- (BOOL)isThumbnailReady {
    return self.thumbnailStatus == ESpaceThumbnailStatusDownloaded;
}

- (void)reuseUMImageResourceThumbnail:(ESpaceUMImgResource *)imgResource keepOriginal:(BOOL)keepOriginal encrypted:(BOOL)encrypted {
    // No need prepare thumbnail for GIF.
    if ([imgResource isGif]) {return;}
    if ([self isThumbnailReady]) {return;}
    
    NSError *error = nil;
    NSString* destThumbPath = [self localThumbFilePath];
    NSString* sourceThumbPath = [imgResource localThumbFilePath];
    if ([imgResource isThumbnailReady] && [sourceThumbPath caseInsensitiveCompare:destThumbPath]) {
        if (keepOriginal) {
            if (encrypted) {
                [[ECSFileManager defaultManager] copyItemAtPath:sourceThumbPath toPath:destThumbPath error:&error];
            } else {
                [[NSFileManager defaultManager] copyItemAtPath:sourceThumbPath toPath:destThumbPath error:&error];
            }
        } else {
            if (encrypted) {
                [[ECSFileManager defaultManager] moveItemAtPath:sourceThumbPath toPath:destThumbPath error:&error];
            } else {
                [[NSFileManager defaultManager] moveItemAtPath:sourceThumbPath toPath:destThumbPath error:&error];
            }
        }
    } else {
        NSData *imgData = nil;
        NSData *thumbImageData = nil;
        if ([imgResource localExites] && [imgResource isLocalFileReady]) {
            imgData = [imgResource localImageData];
        } else if ([self localExites] && [self isLocalFileReady]) {
            imgData = [self localImageData];
        }
        if (imgData) {
            UIImage *image = [UIImage imageWithData:imgData];
            UIImage* thumbnail = [ESpaceUMResource createThumbnailForImage:image maxSize:CGSizeMake(THUMBNAIL_PHOTO_WIDTH, THUMBNAIL_PHOTO_HEIGHT)];
            thumbImageData = UIImagePNGRepresentation(thumbnail);
            
            if (thumbImageData) {
                if (encrypted) {
                    [[ECSFileManager defaultManager] createFileAtPath:destThumbPath contents:thumbImageData attributes:nil];
                } else {
                    [[NSFileManager defaultManager] createFileAtPath:destThumbPath contents:thumbImageData attributes:nil];
                }
            }
        }
    }
}
@end

@interface ESpaceUMAudioResource()<ESpaceMediaServiceDelegate>

@property (nonatomic, strong) ESpaceUMAudioResourceFinishPlayingBlock finishBlock;

@end

@implementation ESpaceUMAudioResource

- (BOOL)play:(ESpaceUMAudioResourceFinishPlayingBlock)completionBlock {
    _finishBlock = [completionBlock copy];
    [[ESpaceMediaService sharedInstance] preparePlayNewAudio];
    [ESpaceMediaService sharedInstance].delegate = self;
    BOOL result = [[ESpaceMediaService sharedInstance] startPlayAudioResource:self loops:1];
    self.playing = result;
    return result;
}

- (BOOL)stop {
    self.playing = NO;
    BOOL result = [[ESpaceMediaService sharedInstance] stopPlayAudioResource];
    [ESpaceMediaService sharedInstance].delegate = nil;
    return  result;
}

- (void)setPlaying:(BOOL)playing {
    _playing = playing;
}

- (void)espaceMediaServiceDidFinishPlaying:(ESpaceMediaService *)mediaService force:(BOOL)force {
    self.playing = NO;
    [ESpaceMediaService sharedInstance].delegate = nil;
    self.finishBlock(force);
}

- (BOOL)needEncrypt {
    return NO;
}

- (BOOL)localExites {
    BOOL bDir = YES;
    return ([[NSFileManager defaultManager] fileExistsAtPath:self.localFilePath isDirectory:&bDir] && !bDir);
}

- (NSString *)defaultExtention {
    return @"wav";
}
@end

@implementation ESpaceUMVideoResource

@synthesize thumbnailStatus = _thumbnailStatus;

- (BOOL)localExites {
    BOOL bDir = YES;
    return ([[NSFileManager defaultManager] fileExistsAtPath:self.localFilePath isDirectory:&bDir] && !bDir);
}

- (NSString *)localThumbFilePath {
    NSString *originalName = [[self.fileName stringByDeletingPathExtension] stringByAppendingPathExtension:@"JPG"];
    return [self.thumbnailDirectory stringByAppendingPathComponent:originalName];
}

- (BOOL) hasThumbnail {
    BOOL bDir = NO;
    return [[NSFileManager defaultManager] fileExistsAtPath:self.localThumbFilePath isDirectory:&bDir] && !bDir;
}

- (UIImage*) localThumbnail {
    UIImage* thumbnail = nil;
    NSData* imageData = [NSData dataWithContentsOfFile:self.localThumbFilePath];
    if (imageData) {
        thumbnail = [UIImage imageWithData:imageData];
    }
    return thumbnail;
}

- (void)setThumbnailDirectory:(NSString *)thumbnailPath {
    _thumbnailDirectory = thumbnailPath;
    if (thumbnailPath && self.fileName && [self hasThumbnail]) {
        [self _setThumbnailStatus:ESpaceThumbnailStatusExported];
    }
}

- (void)download:(void (^)(NSError *))completionBlock {
    __weak typeof(self) weakSelf = self;
    [self setDownloadCompletion:^(NSError *error) {
        if (!error) {
            [weakSelf exportThumbnailIfNeed];
        }
    } forKey:@"__exportThumbnailIfNeed"];
    [super download:completionBlock];
}

- (void)setLocalDirectory:(NSString *)localDirectory {
    [super setLocalDirectory:localDirectory];
    [self exportThumbnailIfNeed];
}

- (void)setName:(NSString *)name {
    [super setName:name];
    [self exportThumbnailIfNeed];
}

- (void) _setThumbnailStatus:(ESpaceUMThumbnailStatus)thumbnailStatus {
    if (_thumbnailStatus == thumbnailStatus) {
        return;
    }
    _thumbnailStatus = thumbnailStatus;
}

- (void)exportThumbnailIfNeed {
    if (![self hasThumbnail] && [self localExites]) {
        [self _setThumbnailStatus:ESpaceThumbnailStatusExporting];
        NSURL *videoURL = [NSURL URLWithString:self.localFilePath];
        UIImage *thumbnail = [videoURL captureVideoThumbnail];
        if (thumbnail) {
            NSData* imageData = UIImagePNGRepresentation(thumbnail);
            if (imageData) {
                NSString* thumbPath = [self localThumbFilePath];
                BOOL bDir = NO;
                if (self.thumbnailDirectory && (![[NSFileManager defaultManager] fileExistsAtPath:self.thumbnailDirectory isDirectory:&bDir]
                    || !bDir)) {
                    [[NSFileManager defaultManager] createDirectoryAtPath:self.thumbnailDirectory withIntermediateDirectories:YES attributes:nil error:nil];
                }
                if([imageData writeToFile:thumbPath atomically:YES]) {
                    [self _setThumbnailStatus:ESpaceThumbnailStatusExported];
                } else {
                    [self _setThumbnailStatus:ESpaceThumbnailStatusExportFailed];
                }
            }
        }
    }
}

- (BOOL)needEncrypt {
    return NO;
}

- (NSString *)defaultExtention {
    return @"mp4";
}

- (void)reuseUMVideoResourceThumbnail:(ESpaceUMVideoResource *)videoResource keepOriginal:(BOOL)keepOriginal encrypted:(BOOL)encrypted {
    if ([self hasThumbnail]) {return;};
    
    NSError *error;
    NSString *sourceThumbPath = videoResource.localThumbFilePath;
    NSString *destThumbPath = self.localThumbFilePath;

    if ([videoResource isLocalFileReady] && [videoResource localExites]) {
        [videoResource exportThumbnailIfNeed];
    }
    
    if ([videoResource hasThumbnail] && [sourceThumbPath caseInsensitiveCompare:destThumbPath]) {
        if (keepOriginal) {
            if (encrypted) {
                [[ECSFileManager defaultManager] copyItemAtPath:sourceThumbPath toPath:destThumbPath error:&error];
            } else {
                [[NSFileManager defaultManager] copyItemAtPath:sourceThumbPath toPath:destThumbPath error:&error];
            }
        } else {
            if (encrypted) {
                [[ECSFileManager defaultManager] moveItemAtPath:sourceThumbPath toPath:destThumbPath error:&error];
            } else {
                [[NSFileManager defaultManager] moveItemAtPath:sourceThumbPath toPath:destThumbPath error:&error];
            }
        }
    } else if ([self isLocalFileReady] && [self localExites]){
        [self exportThumbnailIfNeed];
    }
}

@end

@interface ESpaceUMResourceManager()
@end

@implementation ESpaceUMResourceManager

- (instancetype)init {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        umReourcesCache = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsStrongMemory valueOptions:NSPointerFunctionsWeakMemory];
    });
    return [super init];
}

+ (instancetype) sharedInstance {
    static ESpaceUMResourceManager* manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[ESpaceUMResourceManager alloc] init];
    });
    return manager;
}

- (NSString*) keyForUmResource:(ESpaceUMResource *)umResource{
    if (!umResource || [umResource.resourcePath length] == 0 || [umResource.localFilePath length] == 0) {
        return nil;
    }
    NSString* resourceKey = [ECSUtils MD5StringFromStr:umResource.resourcePath];
    NSString* localKey = [ECSUtils MD5StringFromStr:umResource.localFilePath];
    return [NSString stringWithFormat:@"%@%@", resourceKey, localKey];
}

- (ESpaceUMResource*) cachedResourceForUrl:(NSString*) url {
    if (url) {
        ESpaceUMResource* runningResource = [umReourcesCache objectForKey:url];
        return runningResource;
    }
    return nil;
}

- (void) clearAllCache {
    [umReourcesCache removeAllObjects];
}

- (ESpaceUMResource*) umResourceFromString:(NSString*) umString {
    ESpaceUMResource* resource = [ESpaceUMResourceManager parseUMResourceFromString:umString];
    if (resource) {
        //此处resource对象是alloc出来的对象，通过umlist解析出来相应的内容赋值
        //通过resource的文件路径作为key 去缓存里找对应的umresource
        ESpaceUMResource* cachedResource = [self cachedResourceForUrl:resource.resourcePath];
        if (cachedResource && resource.umType == cachedResource.umType){
            return cachedResource;
        }
        if (resource.umType == ESpaceUMTypeImage) {
            resource = [[ESpaceUMImgResource alloc] initWithResource:resource];
        } else if (resource.umType == ESpaceUMTypeAudio) {
            resource = [[ESpaceUMAudioResource alloc] initWithResource:resource];
        } else if (resource.umType == ESpaceUMTypeVideo) {
            resource = [[ESpaceUMVideoResource alloc] initWithResource:resource];
        }
        if (resource && resource.resourcePath) {
            resource.isCached = YES;
            [umReourcesCache setObject:resource forKey:resource.resourcePath];
        }
    }
    return resource;
}

+ (ESpaceUMResource*) parseUMResourceFromString:(NSString*) resource {
    if (resource.length < 20) return nil;
    NSRange range = NSMakeRange(11, resource.length - 20);
    ESpaceUMResource* umResource = [[ESpaceUMResource alloc] init];
    resource = [resource substringWithRange:range];
    
    //通过umlist,此处为resource，解析对应um属性
    /*
     index: 0 :文件路径
     1: umType @"Img"
     2: size bit
     3: file name
     4: duration
     5: width:heigth
    */
    NSArray *commonTokens = [resource componentsSeparatedByString:@"|"];
    if (commonTokens.count < 5) {
//        DDLogError(@"Invalid input resource string, parameter is not enough: %@, at least five is needed!!!", resource);TODO wxy
        return nil;
    }
    umResource.resourcePath = commonTokens[0];
    umResource.umType = [ESpaceUMResourceManager umTypeFromString:commonTokens[1]];
    umResource.size = [commonTokens[2] longLongValue];
    umResource.name = commonTokens[3];
    umResource.duration = [commonTokens[4] integerValue];
    if (commonTokens.count >= 6) {
        NSArray* subTokens = [commonTokens[5] componentsSeparatedByString:@";"];
        if (subTokens.count > 0) {
            if (subTokens.count == 1) {
                umResource.accessCode = [subTokens lastObject];
            } else if (subTokens.count == 2) {
                umResource.width = [subTokens[0] floatValue];
                umResource.height = [subTokens[1] floatValue];
            } else {
                umResource.accessCode = [subTokens lastObject];
                umResource.width = [subTokens[0] floatValue];
                umResource.height = [subTokens[1] floatValue];
            }
        }
    }
    
    return umResource;
}

+ (ESpaceUMType)umTypeFromString:(NSString *)typeString {
    ESpaceUMType umType = ESpaceUMTypeUnknown;
    if ([typeString caseInsensitiveCompare:UM_FILE_TYPE] == NSOrderedSame) {
        umType = ESpaceUMTypeFile;
    } else if ([typeString caseInsensitiveCompare:UM_AUDIO_TYPE] == NSOrderedSame) {
        umType = ESpaceUMTypeAudio;
    } else if ([typeString caseInsensitiveCompare:UM_VIDEO_TYPE] == NSOrderedSame) {
        umType = ESpaceUMTypeVideo;
    } else if ([typeString caseInsensitiveCompare:UM_FAX_TYPE] == NSOrderedSame) {
        umType = ESpaceUMTypeFax;
    } else if ([typeString caseInsensitiveCompare:UM_IMG_TYPE] == NSOrderedSame) {
        umType = ESpaceUMTypeImage;
    }
    
    return umType;
}

@end
