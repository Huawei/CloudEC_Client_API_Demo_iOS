//
//  ContactInfo.h
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

#import <Foundation/Foundation.h>
#import "tsdk_eaddr_def.h"

@interface ContactInfo : NSObject

@property (nonatomic ,copy)NSString *staffAccount;      // the uc account
@property (nonatomic ,copy)NSString *personName;        // the person's name
@property (nonatomic ,copy)NSString *staffno;           // the person's staff number
@property (nonatomic ,copy)NSString *terminal;          // the person's ip number
@property (nonatomic ,copy)NSString *terminal2;         // the person's ip long number
@property (nonatomic ,copy)NSString *deptName;          // the person's department name
@property (nonatomic ,copy)NSString *title;             // the person's title
@property (nonatomic ,copy)NSString *mobile;            // the person's cellphone
@property (nonatomic ,copy)NSString *homephone;         // the person's home number
@property (nonatomic ,copy)NSString *email;             // the person's email
@property (nonatomic ,copy)NSString *officePhone;       // the person's seat phone
@property (nonatomic ,copy)NSString *officePhone2;      // the person's office phone No.2
@property (nonatomic ,copy)NSString *officePhone3;      // the person's office phone No.3
@property (nonatomic ,copy)NSString *officePhone4;      // the person's office phone No.4
@property (nonatomic ,copy)NSString *officePhone5;      // the person's office phone No.5
@property (nonatomic ,copy)NSString *officePhone6;      // the person's office phone No.6
@property (nonatomic ,copy)NSString *otherphone;        // the person's other phone number No.1
@property (nonatomic ,copy)NSString *otherphone2;       // the person's other phone number No.2
@property (nonatomic ,copy)NSString *gender;            // the person's gender
@property (nonatomic ,copy)NSString *zipCode;           // the person's zip code
@property (nonatomic ,copy)NSString *address;           // the person's address
@property (nonatomic ,copy)NSString *signature;         // the person's signature


/**
 This method is used to transform TSDK_S_CONTACTS_INFO data to ContactInfo data

 @param info TSDK_S_CONTACTS_INFO
 @return ContactInfo
 */
+ (ContactInfo *)contactInfoTransformFrom:(TSDK_S_CONTACTS_INFO)info;

@end
