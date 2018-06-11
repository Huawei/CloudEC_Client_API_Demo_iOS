//
//  NSObject+NSString_StringSizeWithFont_h.h
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//
#import <UIKit/UIKit.h>

@interface NSString (SizeWithFont)//兼容ios6、ios7

- (CGSize)sizeWithMyFont:(UIFont*)fontToUse;
- (CGSize)sizeWithMyFont:(UIFont *)font forWidth:(CGFloat)width lineBreakMode:(NSLineBreakMode)lineBreakMode;
- (CGSize)sizeWithMyFont:(UIFont *)font constrainedToSize:(CGSize)size;
- (CGSize)sizeWithMyFont:(UIFont *)font constrainedToSize:(CGSize)size lineBreakMode:(NSLineBreakMode)lineBreakMode;

@end
