//
//  PersonDetailViewCell.h
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

#import <UIKit/UIKit.h>

#define DETAIL_SEX        0  // sex
#define DETAIL_SIGNATURE  1  // signature
#define DETAIL_DEPARTMENT 2  // department
#define DETAIL_POSITION   3  // position
#define DETAIL_ACCOUNT    4  // uc account
#define DETAIL_FAX        5  // fax
#define DETAIL_MAIL       6  // email
#define DETAIL_ZIPCODE    7  // zip code
#define DETAIL_ADRESS     8  // address

#define DETAIL_BIND_NUMBER        100  // bind number
#define DETAIL_MOBILE             101  // cellphone number
#define DETAIL_SHORT_NUMBER       102  // office phone number
#define DETAIL_HOME_PHONE         103  // home phone number
#define DETAIL_PHONE              104  // other phone number

@class EmployeeEntity;
@interface PersonDetailViewCell : UITableViewCell

@property (nonatomic, strong) NSNumber *index;            // touch index
@property (nonatomic, strong) EmployeeEntity *employee;   // current employeeEntity

@end

@interface PersonInfoViewCell : PersonDetailViewCell

@end

@interface PersonNumberViewCell : PersonDetailViewCell

@end
