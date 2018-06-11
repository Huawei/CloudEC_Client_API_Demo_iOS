//
//  UIImage+Stretchable.h
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//
#import <UIKit/UIKit.h>

#define UIStretchableImage(imageName)                    [UIImage stretchableImageNamed:imageName]
#define UIStretchableImageR(imageName, width, height)    [UIImage stretchableImageNamed:imageName relativeImageWidth:width relativeImageHeight:height]
#define UIStretchableImageA(imageName, width, height)    [UIImage stretchableImageNamed:imageName withLeftCapWidth:width topCapHeight:height]

@interface UIImage (Stretchable)

+ (UIImage *)stretchableImageNamed:(NSString *)imageName;
+ (UIImage *)stretchableImageNamed:(NSString *)imageName relativeImageWidth:(double)width relativeImageHeight:(double)height;
+ (UIImage *)stretchableImageNamed:(NSString *)imageName withLeftCapWidth:(NSInteger)width topCapHeight:(NSInteger)height;

@end
