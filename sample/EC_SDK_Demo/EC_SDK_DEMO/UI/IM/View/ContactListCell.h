//
//  ContactListCell.h
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

#import <UIKit/UIKit.h>

@class PersonEntity;
@protocol ContactListShowDelegate <NSObject>

@optional

- (void)showGroupListWithPerson:(PersonEntity *)person;

@end

@interface ContactListCell : UITableViewCell

@property (nonatomic, strong) PersonEntity *person;   // current personEntity
@property (nonatomic, weak)id<ContactListShowDelegate> delegate;

@end
