//
//  ESpaceImageCache.h
//
//  Created on 3/19/15.
//  Copyright (c) 2017 Huawei Tech. Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ESpaceImageCache : NSObject

@property (nonatomic, assign) NSUInteger totalMemoryLimit;
@property (nonatomic, assign) NSUInteger totalItemLimit;

+ (instancetype) sharedInstance;

- (void)clearMemory;

- (void) setImage:(UIImage*) image forKey:(NSString*) key;

- (void) setImageData:(NSData*) imageData forKey:(NSString*) key;

- (void) setImage:(UIImage*) image forKey:(NSString*) key cost:(NSInteger) cost;

- (UIImage*) imageWithKey:(NSString*) key;

- (void) removeImageForKey:(NSString*) key;

@end
