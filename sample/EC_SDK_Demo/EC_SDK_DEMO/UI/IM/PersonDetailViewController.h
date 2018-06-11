//
//  PersonDetailViewController.h
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

#import <UIKit/UIKit.h>

@class EmployeeEntity;
@interface PersonDetailViewController : UIViewController

- (instancetype)initWithPerson:(EmployeeEntity *)employee;

@end
