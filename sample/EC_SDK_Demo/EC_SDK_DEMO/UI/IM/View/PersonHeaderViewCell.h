//
//  PersonHeaderViewCell.h
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

#import <UIKit/UIKit.h>

@class EmployeeEntity;
@interface PersonHeaderViewCell : UITableViewCell
@property (nonatomic, weak) UIViewController *parentViewCtrl;   // parent viewController
@property (nonatomic, strong) EmployeeEntity *employee;         // current employeeEntity

@end
