//
//  CreateConfViewController.h
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

#import <UIKit/UIKit.h>
#import "ECConfInfo.h"
#import "ECCurrentConfInfo.h"
//#import "AddAttendeeViewController.h"

@interface TableViewCellModel : NSObject
@property (nonatomic, copy) NSString * strKey;
@property (nonatomic, assign) SEL configureBlock;
@property (nonatomic, assign) SEL selectedAction;

- (instancetype)initWithKey:(NSString *)key ConfigureBlock:(SEL)configBlock action:(SEL)action;
@end

@interface CreateConfViewController : UIViewController

{
@protected
    UITableView *_itemsTable;
    ECCurrentConfInfo *_conferenceInfo;
}
@property (nonatomic, strong, readonly) UILabel *confTypeLabel;
@property (nonatomic, strong, readonly) UILabel *confBeginTimeLabel;
@property (nonatomic, strong, readonly) UILabel *confTimeIntervalLabel;
@property (nonatomic, strong, readonly) UITextField *selectedNumberLabel;
//@property (nonatomic, strong, readonly) UILabel *attendeeLabel;
@property (nonatomic, strong, readonly) UILabel *attendeeCountLabel;
@property (nonatomic, strong, readonly) UITextField *confSubjectTextField;
//@property (nonatomic, strong, readonly) ESpaceConfAttendeesView *attendeeView;
@property (nonatomic ,strong) UITextField *inputNumTextField;

@property (nonatomic, strong, readonly) NSDictionary *itemsDicIndexs;
@property (nonatomic, strong, readonly) NSDictionary *itemModelsDic;
@property (nonatomic, strong) ECCurrentConfInfo *conferenceInfo;
@property (nonatomic, strong) NSString *currentCallbackNumber;

@property (nonatomic, strong) NSMutableArray *selectedAttendeArray;

@end
