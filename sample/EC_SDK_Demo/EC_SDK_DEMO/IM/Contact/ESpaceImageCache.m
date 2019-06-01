//
//  ESpaceImageCache.m
//  eSpaceUI
//
//  Created by yemingxing on 3/19/15.
//  Copyright (c) 2015 www.huawei.com. All rights reserved.
//

#import "ESpaceImageCache.h"
#import <UIKit/UIKit.h>

#define CACHE_NAME @"com.huawei.espace.imagecache"

@interface ESpaceImageCache ()

@property (nonatomic, strong) NSCache* memCache;

@end

@implementation ESpaceImageCache

+ (instancetype) sharedInstance {
    static dispatch_once_t onceToken;
    static ESpaceImageCache* imageCache;
    dispatch_once(&onceToken, ^{
        imageCache = [[ESpaceImageCache alloc] init];
    });
    return imageCache;
}

- (void)setTotalMemoryLimit:(NSUInteger)totalMemoryLimit {
    _totalMemoryLimit = totalMemoryLimit;
    self.memCache.totalCostLimit = totalMemoryLimit;
}

- (void)setTotalItemLimit:(NSUInteger)totalItemLimit {
    _totalItemLimit = totalItemLimit;
    self.memCache.totalCostLimit = totalItemLimit;
}

- (instancetype)init {
    if (self = [super init]) {
        _memCache = [[NSCache alloc] init];
        _memCache.name = CACHE_NAME;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(clearMemory)
                                                     name:UIApplicationDidReceiveMemoryWarningNotification
                                                   object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidReceiveMemoryWarningNotification
                                                  object:nil];
}

- (void)clearMemory {
    [self.memCache removeAllObjects];
}

- (void) setImage:(UIImage*) image forKey:(NSString*) key {
    if (!image || ! key) {
        return;
    }
    NSData* data = UIImagePNGRepresentation(image);
    [self setImage:image forKey:key cost:data.length];
}

- (void)setImageData:(NSData *)imageData forKey:(NSString *)key {
    if (!imageData || !key) {
        return;
    }
    UIImage* image = [UIImage imageWithData:imageData];
    [self.memCache setObject:image forKey:key cost:imageData.length];
}

- (void) setImage:(UIImage*) image forKey:(NSString*) key cost:(NSInteger) cost {
    if (!image || ! key) {
        return;
    }
    [self.memCache setObject:image forKey:key cost:cost];
}

- (UIImage*) imageWithKey:(NSString*) key {
    if (!key) {
        return nil;
    }
    return [self.memCache objectForKey:key];
}

- (void) removeImageForKey:(NSString*) key {
    [self.memCache removeObjectForKey:key];
}

@end
