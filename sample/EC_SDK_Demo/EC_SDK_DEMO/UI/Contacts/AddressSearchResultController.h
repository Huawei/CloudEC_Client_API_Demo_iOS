//
//  AddressSearchResultController.h
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

#import <UIKit/UIKit.h>
#import "ECBaseTableViewController.h"

@class ContactInfo;
@protocol AddressSearchResultDelegate <NSObject>
/**
 This method is used to search contacts
 */
- (void)searchMoreContacts;
/**
 This method is used to go to person detail viewControlller
 
 @param contactInfo ContactInfo
 */
- (void)showContactDetailInfo:(ContactInfo *)contactInfo;

@end

@interface AddressSearchResultController : ECBaseTableViewController

@property (nonatomic,strong) NSMutableArray *searchArray;                // search person array
@property (nonatomic, weak) id<AddressSearchResultDelegate> delegate;

/**
 This method is used to show load more view
 */
- (void)showTableFooterView;

/**
 This method is used to hide load more view
 */
- (void)hideTableFooterView;

@end
