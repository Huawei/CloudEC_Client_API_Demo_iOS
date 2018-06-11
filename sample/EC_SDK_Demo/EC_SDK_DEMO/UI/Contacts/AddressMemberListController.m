//
//  AddressMemberListController.m
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

#import "ManagerService.h"
#import "DeptInfo.h"
#import "ContactInfo.h"
#import "SearchParam.h"
#import "AddressMemberListController.h"
#import "AddressDetailViewController.h"

@interface AddressMemberListController ()<TUPContactServiceDelegate>

@property (nonatomic, strong) DeptInfo *dept;           // deptmenet info
@property (nonatomic, strong) NSMutableArray *dataArr;     // current department data array ,value:department info
@property (nonatomic, assign) int searchPageIndex;         // current search page index

@end

@implementation AddressMemberListController

- (void)contactEventCallback:(TUP_CONTACT_EVENT_TYPE)contactEvent result:(NSDictionary *)resultDictionary {
    switch (contactEvent) {
        case CONTACT_E_SEARCH_CONTACT_RESULT: {
            BOOL result = [resultDictionary[TUP_CONTACT_EVENT_RESULT_KEY] boolValue];
            if (!result) {
                [self showMessage:@"Search contact failed!"];
                return;
            }
            NSArray *contactList = resultDictionary[TUP_CONTACT_KEY];
            DDLogInfo(@"contactList count: %lu", (unsigned long)contactList.count);
            if (0 == contactList.count) {
                [self showMessage:@"Empty!"];
            }
            if (PAGE_ITEM_SIZE > contactList.count) {
                [self hideTableFooterView];
            }
            _searchPageIndex++;
            [self.dataArr addObjectsFromArray:contactList];
            [self.tableView reloadData];
        }
            break;
            
        default:
            break;
    }
}

- (instancetype)initWithCurrentDept:(DeptInfo *)dept {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        _dept = dept;
        _searchPageIndex = 1;
        _dataArr = [[NSMutableArray alloc] init];
        
        self.title = _dept.deptName;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [ManagerService contactService].delegate = self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // show load more view
    [self showTableFooterView];
    // when view did load ,search current department contacts
    [self searchContacts];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (nil == cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.font = [UIFont systemFontOfSize:16];
        cell.textLabel.textColor = [UIColor darkGrayColor];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:12];
        cell.detailTextLabel.textColor = [UIColor lightGrayColor];
    }
    ContactInfo *info = _dataArr[indexPath.row];
    cell.textLabel.text = info.personName;
    cell.detailTextLabel.text = info.deptName;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    ContactInfo *info = _dataArr[indexPath.row];
    // go to address contacts detail viewController
    AddressDetailViewController *detailVC = [[AddressDetailViewController alloc] initWithTupPerson:info];
    [self.navigationController pushViewController:detailVC animated:YES];
}


/**
 This method is used to search contacts
 */
- (void)searchContacts {
    SearchParam *searchParam = [[SearchParam alloc] init];
    searchParam.acSearchItem = @" ";
    searchParam.ulPageIndex = _searchPageIndex;
    searchParam.ulExactSearch = 0;
    searchParam.ulSeqNo = rand() + 101;
    searchParam.acDepId = _dept.deptId;
    [[ManagerService contactService] searchContactWithParam:searchParam];
}

#pragma mark
#pragma mark --- AlertShow ---
-(void)showMessage:(NSString *)msg {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                   message:msg
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [self presentViewController:alert animated:NO completion:nil];
    [NSTimer scheduledTimerWithTimeInterval:1
                                     target:self
                                   selector:@selector(creatAlert:)
                                   userInfo:alert
                                    repeats:NO];
}

- (void)creatAlert:(NSTimer *)timer {
    UIAlertController *alert = [timer userInfo];
    [alert dismissViewControllerAnimated:YES completion:nil];
    alert = nil;
}

- (UIView *)tableFooterView {
    UIButton *loadMoreBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [loadMoreBtn setFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, 40)];
    [loadMoreBtn setTitle:@"Load More Persons" forState:UIControlStateNormal];
    [loadMoreBtn addTarget:self action:@selector(searchContacts) forControlEvents:UIControlEventTouchUpInside];
    return loadMoreBtn;
}

/**
 This method is used to show load more view
 */
- (void)showTableFooterView {
    self.tableView.tableFooterView = [self tableFooterView];
}

/**
 This method is used to hide load more view
 */
- (void)hideTableFooterView {
    self.tableView.tableFooterView = [[UIView alloc] init];
}

@end
