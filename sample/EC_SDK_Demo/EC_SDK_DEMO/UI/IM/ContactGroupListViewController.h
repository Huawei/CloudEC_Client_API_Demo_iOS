//
//  ContactGroupListViewController.h
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

#import <UIKit/UIKit.h>

@class EmployeeCategoryEntity;
@protocol SelectedContactGroupDelegate <NSObject>

/**
 This method is used to select contact group category

 @param category EmployeeCategoryEntity
 */
- (void)didSelectedContactGroupCategory:(EmployeeCategoryEntity *)category;

@end

@interface ContactGroupListViewController : UITableViewController

@property (nonatomic, weak) id<SelectedContactGroupDelegate> delegate;

@end
