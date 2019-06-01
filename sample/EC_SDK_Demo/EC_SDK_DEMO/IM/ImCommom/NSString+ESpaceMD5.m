//
//  NSString+ESpaceMD5.m
//  eSpaceIOSSDK
//
//  Created by wangxiangyang on 11/9/16.
//  Copyright © 2016 HuaWei. All rights reserved.
//

#import "NSString+ESpaceMD5.h"
#import <CommonCrypto/CommonDigest.h>


@implementation NSString (ESpaceMD5)

- (NSString *)MD5 {
    const char * pointer = [self UTF8String];
    unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];//
    
    CC_MD5(pointer, (CC_LONG)strlen(pointer), md5Buffer);
    
    NSMutableString *string = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [string appendFormat:@"%02x",md5Buffer[i]];
    
    return [string substringWithRange:NSMakeRange(8, 16)];
}

- (NSString *)combinedWithMD5 {
    return [NSString stringWithFormat:@"%@%@", self, [self MD5]];
}

@end
