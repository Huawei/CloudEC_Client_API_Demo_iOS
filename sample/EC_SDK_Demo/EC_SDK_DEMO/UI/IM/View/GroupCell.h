//
//  GroupCell.h
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

#import <UIKit/UIKit.h>

#define GROUP_KIND_CHAT      100 // chat groups
#define GROUP_KIND_CONTACT   101 // contact groups
#define E_ASSISTANT          103 // e assistant

@class EmployeeCategoryEntity;
@interface GroupCell : UITableViewCell

@property (nonatomic, assign) NSInteger index;                     // touch index
@property (nonatomic, strong) EmployeeCategoryEntity *category;    // current EmployeeCategoryEntity

@end
