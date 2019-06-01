//
//  CustomContactEntity.m
//  eSpace
//
//  Created by yemingxing on 8/3/15.
//  Copyright (c) 2015 www.huawei.com. All rights reserved.
//

#import "CustomContactEntity.h"

@implementation CustomContactEntity


- (UIImage*) defaultHeadImage {
    return [[ESpaceContactHeadImageService sharedInstance] defaultCustomContactHeadImage];
}

@end
