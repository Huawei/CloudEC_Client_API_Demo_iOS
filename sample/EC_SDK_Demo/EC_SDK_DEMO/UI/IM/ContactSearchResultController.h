//
//  ContactSearchResultController.h
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

#import <UIKit/UIKit.h>

@class EmployeeEntity;
@protocol ContactSearchDelegate <NSObject>

/**
 This method is used to search contacts
 */
- (void)searchContacts;

/**
 This method is used to go to person detail viewControlller

 @param employee EmployeeEntity
 */
- (void)showPersonDetailInfo:(EmployeeEntity *)employee;

@end

@interface ContactSearchResultController : UIViewController
@property (nonatomic, weak) id<ContactSearchDelegate> delegate;
@property (nonatomic,strong) NSMutableArray *searchArray;          // current search contacts array
@property (weak, nonatomic) IBOutlet UITableView *tableView;       // current tableView

/**
 This method is used to show load more view
 */
- (void)showTableFooterView;
/**
 This method is used to hide load more view
 */
- (void)hideTableFooterView;

@end
