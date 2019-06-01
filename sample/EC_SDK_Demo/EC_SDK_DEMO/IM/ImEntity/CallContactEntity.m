//
//  CallContactEntity.m
//  eSpace
//
//  Created by yemingxing on 7/31/15.
//  Copyright (c) 2015 www.huawei.com. All rights reserved.
//

#import "CallContactEntity.h"
#import "ECSUtils.h"
#import "ESpaceContactHeadImageService.h"

@implementation CallContactEntity
@synthesize uiDisplayName = _uiDisplayName;
//ECSEntryptCoreDataStringProp(phoneNumber, PhoneNumber)

- (NSString *)uiDisplayName {
    [self willAccessValueForKey:@"uiDisplayName"];
    _uiDisplayName = self.name.length > 0 ? self.name : self.phoneNumber;
    [self didAccessValueForKey:@"uiDisplayName"];
    return _uiDisplayName;
}

- (UIImage*) defaultHeadImage {
    return [[ESpaceContactHeadImageService sharedInstance] defaultCallContactHeadImage];
}

- (BOOL)isEqualToContact:(CallContactEntity *)c
{
    if ([super isEqualToContact:c]) {
        return YES;
    }
    
    if (![c isKindOfClass:self.class]) {
        return NO;
    }
    
    if ([self.phoneNumber isEqualToString:c.phoneNumber]) {
        return YES;
    }
    return NO;
}

@end
