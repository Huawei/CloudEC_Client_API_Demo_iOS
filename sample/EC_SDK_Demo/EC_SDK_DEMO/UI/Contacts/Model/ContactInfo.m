//
//  ContactInfo.m
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

#import "ContactInfo.h"

@implementation ContactInfo

+ (ContactInfo *)contactInfoTransformFrom:(TSDK_S_CONTACTS_INFO)contactInfo
{
    ContactInfo *info = [[ContactInfo alloc] init];
    info.staffAccount    = [NSString stringWithUTF8String:contactInfo.staff_account];
    info.personName      = [NSString stringWithUTF8String:contactInfo.person_name];
    info.staffno         = [NSString stringWithUTF8String:contactInfo.staff_no];
    info.terminal        = [NSString stringWithUTF8String:contactInfo.terminal];
    info.terminal2       = [NSString stringWithUTF8String:contactInfo.terminal2];
    info.deptName        = [NSString stringWithUTF8String:contactInfo.department_name];
    info.title           = [NSString stringWithUTF8String:contactInfo.title];
    info.mobile          = [NSString stringWithUTF8String:contactInfo.mobile];
    info.homephone       = [NSString stringWithUTF8String:contactInfo.home_phone];
    info.email           = [NSString stringWithUTF8String:contactInfo.email];
    info.officePhone     = [NSString stringWithUTF8String:contactInfo.office_phone];
    info.officePhone2    = [NSString stringWithUTF8String:contactInfo.office_phone2];
    info.officePhone3    = [NSString stringWithUTF8String:contactInfo.office_phone3];
    info.officePhone4    = [NSString stringWithUTF8String:contactInfo.office_phone4];
    info.officePhone5    = [NSString stringWithUTF8String:contactInfo.office_phone5];
    info.officePhone6    = [NSString stringWithUTF8String:contactInfo.office_phone6];
    info.otherphone      = [NSString stringWithUTF8String:contactInfo.other_phone];
    info.otherphone2     = [NSString stringWithUTF8String:contactInfo.other_phone2];
    info.gender          = [NSString stringWithUTF8String:contactInfo.gender];
    info.zipCode         = [NSString stringWithUTF8String:contactInfo.zip_code];
    info.address         = [NSString stringWithUTF8String:contactInfo.address];
    info.signature       = [NSString stringWithUTF8String:contactInfo.signature];
    
    return info;
}

@end
