//
//  EmployeeCategoryEntity.m
//  eSpaceUI
//
//  Created by yemingxing on 3/16/15.
//  Copyright (c) 2015 www.huawei.com. All rights reserved.
//

#import "EmployeeCategoryEntity.h"
#import "EmployeeEntity.h"
#import "ECSUtils.h"
//#import "ESpaceContactHeadImageService.h"

@implementation EmployeeCategoryEntity

@dynamic id;
@dynamic idx;
@dynamic num;
@dynamic members;
@dynamic lastUpdateTime;

//ECSEntryptCoreDataStringProp(name, Name)

- (UIImage *)defaultHeadImage {
//    return [[ESpaceContactHeadImageService sharedInstance] defaultEmpolyeeHeadImageWithHeadId:@"0"];
    return nil;
}

@end
