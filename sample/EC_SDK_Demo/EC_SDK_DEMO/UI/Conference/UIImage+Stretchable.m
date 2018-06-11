//
//  UIImage+Stretchable.m
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

#import "UIImage+Stretchable.h"

@implementation UIImage (Stretchable)

+ (UIImage *)stretchableImageNamed:(NSString *)imageName {
    return [UIImage stretchableImageNamed:imageName relativeImageWidth:0.5 relativeImageHeight:0.5];
}

+ (UIImage *)stretchableImageNamed:(NSString *)imageName relativeImageWidth:(double)width relativeImageHeight:(double)height{
    if (nil == imageName) {
        return nil;
    }

    UIImage *image = [UIImage imageNamed:imageName];
    if (nil == image) {
        return nil;
    }
    
    
    return [image stretchableImageWithLeftCapWidth:image.size.width * width topCapHeight:image.size.height * height];
}

+ (UIImage *)stretchableImageNamed:(NSString *)imageName withLeftCapWidth:(NSInteger)width topCapHeight:(NSInteger)height{
    if (nil == imageName) {
        return nil;
    }
    
    UIImage *image = [UIImage imageNamed:imageName];
    if (nil == image) {
        return nil;
    }
    
    return [image stretchableImageWithLeftCapWidth:width topCapHeight:height];
}

@end
