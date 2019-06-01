//
//  GroupFileEntity.m
//  eSpace
//
//  Created by yemingxing on 7/31/15.
//  Copyright (c) 2015 www.huawei.com. All rights reserved.
//

#import "GroupFileEntity.h"
#import "GroupEntity.h"
#import "GroupFileEntity.h"
#import "ECSUtils.h"
#import "NSString+FileType.h"

@implementation GroupFileEntity

@dynamic info;
@dynamic type;
@dynamic userPriv;
@dynamic transferStatus;
@dynamic id;
//@dynamic progress;
@dynamic size;
@dynamic queuePriority;
@dynamic createAt;
@dynamic ownedByGroup;
@dynamic fileOwner;
@dynamic parent;
@dynamic membes;
@dynamic needUpdate;

//@synthesize umResource = _umResource;

////ECSEntryptCoreDataStringProp(name, Name)

//- (ESpaceUMResource *)umResource {
//    [self willAccessValueForKey:@"umResource"];
//    if (!_umResource) {
//        if (self.info) {
//            NSDictionary* infoDic = [NSJSONSerialization JSONObjectWithData:[self.info dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:nil];
//            NSString* url = nil;
//            NSString* accessCode = nil;
//            if (infoDic) {
//                url = [infoDic valueForKey:@"downloadUrl"];
//                accessCode = [infoDic valueForKey:@"fileAccessCode"];
//            }
//            if (url) {
//                _umResource = [[ESpaceUMResourceManager sharedInstance] cachedResourceForUrl:url];
//                if (!_umResource) {
//                    NSUInteger type = [self.type unsignedIntegerValue];
//                    if (type > ESpaceGPOfficeEnd && type < ESpaceGPImageEnd) {
//                        ESpaceUMImgResource* imageResource = [[ESpaceUMImgResource alloc] init];
//                        imageResource.thumbnailDirectory = [self.ownedByGroup directoryForGroupFileThumbnails];
//                        _umResource = imageResource;
//                    } else if (type > ESpaceGPImageEnd && type < ESpaceGPVideoEnd) {
//                        _umResource = [[ESpaceUMVideoResource alloc] init];
//                    } else if (type > ESpaceGPVideoEnd && type < ESpaceGPAudioEnd) {
//                        _umResource = [[ESpaceUMAudioResource alloc] init];
//                    } else {
//                        _umResource = [[ESpaceUMResource alloc] init];
//                    }
//                    _umResource.name = self.name;
//                    _umResource.localDirectory = [self.ownedByGroup directoryForGoupFiles];
//                    _umResource.resourcePath = url;
//                    _umResource.accessCode = accessCode;
//                    _umResource.size = [self.size integerValue];
//                }
//            }
//        }
//    }
//
//    ESpaceUMResource* resource = _umResource;
//    [self didAccessValueForKey:@"umResource"];
//    return resource;
//}

//- (void)setUmResource:(ESpaceUMResource *)umResource {
////    [self willChangeValueForKey:@"umResource"];
//    _umResource = umResource;
//    [self didAccessValueForKey:@"umResource"];
//    return;
//}

- (NSString *)name {
    [self willAccessValueForKey:@"name"];
    NSString* name = [self primitiveValueForKey:@"name"];
//    name = [ECSUtils databaseDataDecrypt:name];
    name = name;
    [self didAccessValueForKey:@"name"];
    return name;
}

- (void)setName:(NSString *)name {
    self.type = [NSNumber numberWithUnsignedInteger:[name fileType]];
    [self willChangeValueForKey:@"name"];
//    name = [ECSUtils databaseDataEncrypt:name];
    [self setPrimitiveValue:name forKey:@"name"];
    [self didChangeValueForKey:@"name"];
}

- (void)localDeleteSelf {
    [self.parent removeMembesObject:self];
    [self.managedObjectContext deleteObject:self];
}
@end
