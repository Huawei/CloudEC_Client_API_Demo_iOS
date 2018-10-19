//
//  PersonDetailViewCell.m
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

#import "PersonDetailViewCell.h"
#import <TUPIOSSDK/EmployeeEntity.h>
#import <TUPIOSSDK/eSpaceDBService.h>

#define PERSON_SEX_FEMALE   @"0"
#define PERSON_SEX_MALE     @"1"
#define PERSON_SEX_UNKNOWN  @"2"

@implementation PersonDetailViewCell


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier];
    if (self) {
        self.textLabel.font = [UIFont systemFontOfSize:15];
        self.textLabel.textColor = [UIColor darkGrayColor];
        self.detailTextLabel.font = [UIFont systemFontOfSize:13];
    }
    return self;
}

- (void)setEmployee:(EmployeeEntity *)employee {
    _employee = employee;
}

@end

@implementation PersonInfoViewCell

- (void)setEmployee:(EmployeeEntity *)employee {
    [super setEmployee:employee];
    [self loadPersonDetailInfo];
}


/**
 This method is used to load person detail info
 */
- (void)loadPersonDetailInfo {
    
    NSString *title;
    NSString *detail;
    switch ([self.index integerValue]) {
        case DETAIL_SEX:
            title = @"Sex";
            detail = [self SexDescribe];
            break;
        case DETAIL_SIGNATURE:
            if ([self.employee.account isEqualToString:LOCAL_DATA_MANAGER.currentUser.account]) {
                self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }else {
                self.accessoryType = UITableViewCellAccessoryNone;
            }
            title = @"Signature";
            detail = self.employee.signature;
            break;
        case DETAIL_DEPARTMENT:
            title = @"Department";
            if ([self.employee.deptDesc length] > 0) {
                detail = self.employee.deptDesc;
            }else {
                detail = self.employee.deptName;
            }
            break;
        case DETAIL_POSITION:
            title = @"Position";
            detail = self.employee.position;
            break;
        case DETAIL_ACCOUNT:
            title = @"Account";
            detail = self.employee.account;
            break;
        case DETAIL_FAX:
            title = @"Fax";
            detail = self.employee.fax;
            break;
        case DETAIL_MAIL:
            title = @"Mail";
            detail = self.employee.email;
            break;
        case DETAIL_ZIPCODE:
            title = @"Zip code";
            detail = self.employee.postalCode;
            break;
        case DETAIL_ADRESS:
            title = @"Address";
            detail = self.employee.address;
            break;
            
        default:
            break;
    }
    self.textLabel.text = title;
    self.detailTextLabel.text = detail;
}

- (NSString *)SexDescribe {
    NSString *sex = nil;
    NSString *sexStr = self.employee.sex;
    if ([sexStr isEqualToString:PERSON_SEX_FEMALE]) {
        sex = @"Female";
    }else if ([sexStr isEqualToString:PERSON_SEX_MALE]) {
        sex = @"Male";
    }else {
        sex = @"Unknown";
    }
    return sex;
}

@end

@implementation PersonNumberViewCell

- (void)setEmployee:(EmployeeEntity *)employee {
    [super setEmployee:employee];
    [self loadPersonNumber];
}


/**
 This method is used to load person number
 */
- (void)loadPersonNumber {
    
    NSString *title;
    NSString *detail;
    switch ([self.index integerValue]) {
        case DETAIL_BIND_NUMBER:
            title = @"Bind Number";
            detail = self.employee.bindNumber;
            break;
        case DETAIL_MOBILE:
            title = @"Mobile";
            detail = self.employee.mobile;
            break;
        case DETAIL_SHORT_NUMBER:
            title = @"Short Number";
            if (self.employee.shortNumber.length > 0) {
                detail = self.employee.shortNumber;
            }else {
                detail = self.employee.sp2; //sp3, sp4...
            }
            break;
        case DETAIL_HOME_PHONE:
            title = @"Home Phone";
            detail = self.employee.homePhone;
            break;
        case DETAIL_PHONE:
            title = @"Phone";
            detail = self.employee.phone;
            break;
            
        default:
            break;
    }
    self.textLabel.text = title;
    self.detailTextLabel.text = detail;
}

@end
