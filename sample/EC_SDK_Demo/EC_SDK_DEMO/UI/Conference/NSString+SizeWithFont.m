//
//  NSObject+NSString_StringSizeWithFont_h.m
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

#import "NSString+SizeWithFont.h"

@implementation NSString (SizeWithFont)

- (CGSize)sizeWithMyFont:(UIFont*)fontToUse {
    CGSize tempSize = [self sizeWithAttributes:[NSDictionary dictionaryWithObject:fontToUse forKey:NSFontAttributeName]];
    tempSize.width = ceilf(tempSize.width);
    tempSize.height = ceilf(tempSize.height);
    return tempSize;
    
}

- (CGSize)sizeWithMyFont:(UIFont *)font forWidth:(CGFloat)width lineBreakMode:(NSLineBreakMode)lineBreakMode {
    CGRect rect = [self boundingRectWithSize:CGSizeMake(width, MAXFLOAT)
                                     options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading
                                  attributes:[NSDictionary dictionaryWithObject:font forKey:NSFontAttributeName]
                                     context:nil];
    rect.size.width = ceilf(rect.size.width);
    rect.size.height = ceilf(rect.size.height);
    return rect.size;
}

- (CGSize)sizeWithMyFont:(UIFont *)font constrainedToSize:(CGSize)size {
    CGRect rect = [self boundingRectWithSize:size
                                     options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading
                                  attributes:[NSDictionary dictionaryWithObject:font forKey:NSFontAttributeName]
                                     context:nil];
    rect.size.width = ceilf(rect.size.width);
    rect.size.height = ceilf(rect.size.height);
    return rect.size;
    
}

- (CGSize)sizeWithMyFont:(UIFont *)font constrainedToSize:(CGSize)size lineBreakMode:(NSLineBreakMode)lineBreakMode {
    CGRect rect = [self boundingRectWithSize:size
                                     options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading
                                  attributes:[NSDictionary dictionaryWithObject:font forKey:NSFontAttributeName]
                                     context:nil];
    rect.size.width = ceilf(rect.size.width);
    rect.size.height = ceilf(rect.size.height);
    return rect.size;
}

@end
