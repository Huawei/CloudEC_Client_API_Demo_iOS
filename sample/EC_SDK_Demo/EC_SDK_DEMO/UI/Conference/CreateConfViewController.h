//
//  CreateConfViewController.h
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

#import <UIKit/UIKit.h>
#import "ECBaseViewController.h"

@interface TableViewCellModel : NSObject
@property (nonatomic, copy) NSString * strKey;
@property (nonatomic, assign) SEL configureBlock;
@property (nonatomic, assign) SEL selectedAction;

- (instancetype)initWithKey:(NSString *)key ConfigureBlock:(SEL)configBlock action:(SEL)action;
@end

@interface CreateConfViewController : ECBaseViewController

{
@protected
    UITableView *_itemsTable;
}
@property (nonatomic, strong, readonly) UILabel *confTypeLabel;
@property (nonatomic, strong, readonly) UILabel *confBeginTimeLabel;
@property (nonatomic, strong, readonly) UILabel *confTimeIntervalLabel;
@property (nonatomic, strong, readonly) UITextField *selectedNumberLabel;
@property (nonatomic, strong, readonly) UILabel *attendeeCountLabel;
@property (nonatomic, strong, readonly) UITextField *confSubjectTextField;
@property (nonatomic ,strong) UITextField *inputNumTextField;

@property (nonatomic, strong, readonly) NSDictionary *itemsDicIndexs;
@property (nonatomic, strong, readonly) NSDictionary *itemModelsDic;
@property (nonatomic, copy) NSString *currentCallbackNumber;

@property (nonatomic, strong) NSMutableArray *selectedAttendeArray;

@end
