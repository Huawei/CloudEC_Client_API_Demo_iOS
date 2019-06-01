//
//  ESpaceContactHeadImageService.m
//  eSpaceIOSSDK
//
//  Created by wangxiangyang on 7/15/16.
//  Copyright © 2016 HuaWei. All rights reserved.
//

#import "ESpaceContactHeadImageService.h"
#import "ESpaceLocalDataManager.h"


NSString* const HEADIMAGE_EMPLOYEEENTITY_ZERO			= @"EmployeeEntity_0";
NSString* const HEADIMAGE_EMPLOYEEENTITY_ONE			= @"EmployeeEntity_1";
NSString* const HEADIMAGE_EMPLOYEEENTITY_TWO			= @"EmployeeEntity_2";
NSString* const HEADIMAGE_EMPLOYEEENTITY_THREE			= @"EmployeeEntity_3";
NSString* const HEADIMAGE_EMPLOYEEENTITY_FORE			= @"EmployeeEntity_4";
NSString* const HEADIMAGE_EMPLOYEEENTITY_FIVE			= @"EmployeeEntity_5";
NSString* const HEADIMAGE_EMPLOYEEENTITY_SIX			= @"EmployeeEntity_6";
NSString* const HEADIMAGE_EMPLOYEEENTITY_SEVEN			= @"EmployeeEntity_7";
NSString* const HEADIMAGE_EMPLOYEEENTITY_EIGHT			= @"EmployeeEntity_8";
NSString* const HEADIMAGE_EMPLOYEEENTITY_NINE			= @"EmployeeEntity_9";
NSString* const HEADIMAGE_CUSTOMCONTACTENTITY 			= @"CustomContactEntity";
NSString* const HEADIMAGE_LOCALCONTACTENTITY  			= @"LocalContactEntity";
NSString* const HEADIMAGE_GROUPENTITY       			= @"GroupEntity";
NSString* const HEADIMAGE_CALLCONTACTENTITY 			= @"CallContactEntity";

@implementation ESpaceContactHeadImageService

+ (instancetype) sharedInstance {
    static dispatch_once_t onceToken;
    static ESpaceContactHeadImageService* service;
    dispatch_once(&onceToken, ^{
        service = [[ESpaceContactHeadImageService alloc] init];
    });
    return service;
}

- (UIImage *)defaultEmpolyeeHeadImageWithHeadId:(NSString *)headId {

    NSString *(^imageNameBlock)(NSString*, NSString*) = ^(NSString *key, NSString* headId){
        
        NSString* imageName = nil;
        if (self.contactHeadImageInfo) {
            imageName = [self.contactHeadImageInfo objectForKey:key];
        }
        
        if (0 == [imageName length]) {
            imageName = [NSString stringWithFormat:@"default_head_image_%@", headId];
        }
        
        return imageName;
    };
    
    if (nil == headId) {
        return nil;
    }
    
    NSString* imageName = nil;
    
    if (0 == [headId length]) {
        imageName = imageNameBlock(HEADIMAGE_EMPLOYEEENTITY_ZERO, @"0");
    }
    
    switch ([headId integerValue]) {
        case 0:
            imageName = imageNameBlock(HEADIMAGE_EMPLOYEEENTITY_ZERO, headId);
            break;
        case 1:
            imageName = imageNameBlock(HEADIMAGE_EMPLOYEEENTITY_ONE, headId);
            break;
        case 2:
            imageName = imageNameBlock(HEADIMAGE_EMPLOYEEENTITY_TWO, headId);
            break;
        case 3:
            imageName = imageNameBlock(HEADIMAGE_EMPLOYEEENTITY_THREE, headId);
            break;
        case 4:
            imageName = imageNameBlock(HEADIMAGE_EMPLOYEEENTITY_FORE, headId);
            break;
        case 5:
            imageName = imageNameBlock(HEADIMAGE_EMPLOYEEENTITY_FIVE, headId);
            break;
        case 6:
            imageName = imageNameBlock(HEADIMAGE_EMPLOYEEENTITY_SIX, headId);
            break;
        case 7:
            imageName = imageNameBlock(HEADIMAGE_EMPLOYEEENTITY_SEVEN, headId);
            break;
        case 8:
            imageName = imageNameBlock(HEADIMAGE_EMPLOYEEENTITY_EIGHT, headId);
            break;
        case 9:
            imageName = imageNameBlock(HEADIMAGE_EMPLOYEEENTITY_NINE, headId);
            break;
        default:
            break;
    }
    return [imageName length] > 0 ? ECS_IMG(imageName) : nil;
    
}

- (UIImage *)defaultCustomContactHeadImage {
    NSString* imageName = nil;
    if (self.contactHeadImageInfo) {
        imageName = [self.contactHeadImageInfo objectForKey:HEADIMAGE_CUSTOMCONTACTENTITY];
    }
    
    if (0 == [imageName length]) {
        imageName = @"ic_contact_normal_head_02";
    }
    
    return ECS_IMG(imageName);
}

- (UIImage *)defaultLocalContactHeadImage {
    NSString* imageName = nil;
    if (self.contactHeadImageInfo) {
        imageName = [self.contactHeadImageInfo objectForKey:HEADIMAGE_LOCALCONTACTENTITY];
    }
    
    if (0 == [imageName length]) {
        imageName = @"ic_contact_normal_head_02";
    }
    
    return ECS_IMG(imageName);    
}

- (UIImage *)defaultCallContactHeadImage {
    
    NSString* imageName = nil;
    if (self.contactHeadImageInfo) {
        imageName = [self.contactHeadImageInfo objectForKey:HEADIMAGE_EMPLOYEEENTITY_ZERO];
    }
    
    if (0 == [imageName length]) {
        imageName = @"default_head_image_0";
    }
    
    return ECS_IMG(imageName);
}

- (UIImage *)defaultGroupHeadImage {
    NSString* imageName = nil;
    if (self.contactHeadImageInfo) {
        imageName = [self.contactHeadImageInfo objectForKey:HEADIMAGE_GROUPENTITY];
    }
    
    if (0 == [imageName length]) {
        imageName = @"group_default_headImage";
    }
    
    return ECS_IMG(imageName);
}

@end
