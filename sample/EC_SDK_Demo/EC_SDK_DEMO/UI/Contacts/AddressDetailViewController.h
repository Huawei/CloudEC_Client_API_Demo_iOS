//
//  AddressDetailViewController.h
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

#import <UIKit/UIKit.h>
#import "ECBaseTableViewController.h"

@class ContactInfo;
@interface AddressDetailViewController : ECBaseTableViewController

- (instancetype)initWithTupPerson:(ContactInfo *)tupContact;

@end
