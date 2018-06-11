//
//  NetworkAddressBookController.m
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

#import "NetworkAddressBookController.h"

#import "ContactInfo.h"
#import "SearchParam.h"
#import "ManagerService.h"
#import "DeptInfo.h"
#import "SearchResultInfo.h"
#import "DeptListCell.h"
#import "AddressSearchResultController.h"
#import "AddressDetailViewController.h"
#import "AddressMemberListController.h"

#define BGCOLOR [UIColor colorWithRed:0.92 green:0.92 blue:0.92 alpha:1];

@interface NetworkAddressBookController ()<TUPContactServiceDelegate, AddressSearchResultDelegate, UISearchBarDelegate, UISearchControllerDelegate>

@property (nonatomic, strong) UIView *sectionHeaderView;              // select department crumbs view
@property (nonatomic, strong) UIScrollView *scrollView;               // department scrollerView
@property (nonatomic, strong) NSMutableArray *crumbsBtns;             // crumbs buttons array
@property (nonatomic, strong) NSMutableArray *crumbsDepts;            // crumbs department array
@property (nonatomic, strong) DeptInfo *currentDept;               // current department info
@property (nonatomic, strong) NSMutableArray *deptList;               // current department's sub departments array
@property (nonatomic, strong) NSMutableDictionary *dataDic;           // Dic Record loaded departments
@property (nonatomic, assign) int searchPageIndex;                    // current search index
@property (nonatomic, copy) NSString *currentSearchText;              // current seatch text
@property (nonatomic, strong) UISearchController *searchController;   // search controller
@property (nonatomic, strong) AddressSearchResultController *resultController;  //address searchResultController

@end

@implementation NetworkAddressBookController

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
                [self.resultController hideTableFooterView];
            }
            _searchPageIndex++;
            [self.resultController.searchArray addObjectsFromArray:contactList];
            [self.resultController.tableView reloadData];
        }
            break;
            
        case CONTACT_E_SEARCH_DEPARTMENT_RESULT: {
            BOOL result = [resultDictionary[TUP_CONTACT_EVENT_RESULT_KEY] boolValue];
            if (!result) {
                [self showMessage:@"Search department failed!"];
            }
            SearchResultInfo *resultInfo = resultDictionary[TUP_DEPARTMENT_RESULT_KEY];
            if (resultInfo.ulItemNum == 0) {
                [self showMessage:@"NO sub departments!"];
            }
            NSArray *deptList = resultDictionary[TUP_DEPARTMENT_KEY];
            [_dataDic setValue:deptList forKey:_currentDept.deptId];
            [_deptList removeAllObjects];
            [_deptList addObjectsFromArray:deptList];
            [self updateTopCrumbsBy:_currentDept];
            [self.tableView reloadData];
        }
            break;
            
        default:
            break;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [ManagerService contactService].delegate = self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Address Book";
    self.tableView.backgroundColor = BGCOLOR;
    
    _deptList = [[NSMutableArray alloc] init];
    _crumbsBtns = [[NSMutableArray alloc] init];
    _crumbsDepts = [[NSMutableArray alloc] init];
    _dataDic = [[NSMutableDictionary alloc] init];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"DeptListCell" bundle:nil] forCellReuseIdentifier:@"DeptListCell"];
    self.tableView.tableFooterView = [[UIView alloc] init];
    
    DeptInfo *firstDept = [[DeptInfo alloc] init];
    firstDept.deptId = @"-1";
    firstDept.deptName = @"Address Book";
    _currentDept = firstDept;
    
    self.resultController = [[AddressSearchResultController alloc] init];
    self.resultController.delegate = self;
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:self.resultController];
    
    [self setWhiteSearchBar];
    [self.searchController.searchBar sizeToFit];
    
    self.tableView.tableHeaderView = self.searchController.searchBar;
    
    self.searchController.searchBar.delegate = self;
    self.searchController.delegate = self;
    self.definesPresentationContext = YES;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Members"
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(showCurrentDeptMembersView)];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[ManagerService contactService] searchDeptListWithID:@"-1"];
    });
    
}

/**
 This method is used to show current department members
 */
- (void)showCurrentDeptMembersView {
    AddressMemberListController *memVC = [[AddressMemberListController alloc] initWithCurrentDept:_currentDept];
    [self.navigationController pushViewController:memVC animated:YES];
}

#pragma mark
#pragma mark --- AddressSearchResultDelegate ---
- (void)searchMoreContacts {
    SearchParam *searchParam = [[SearchParam alloc] init];
    searchParam.acSearchItem = _currentSearchText;
    searchParam.ulPageIndex = _searchPageIndex;
    searchParam.ulExactSearch = 0;
    searchParam.ulSeqNo = rand() + 101;
    searchParam.acDepId = _currentDept.deptId;
    [[ManagerService contactService] searchContactWithParam:searchParam];
}

- (void)showContactDetailInfo:(ContactInfo *)contactInfo {
    AddressDetailViewController *detailVC = [[AddressDetailViewController alloc] initWithTupPerson:contactInfo];
    [self.navigationController pushViewController:detailVC animated:YES];
    [self.searchController setActive:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [ManagerService contactService].delegate = nil;
}

#pragma mark
#pragma mark --- Table view delegate dataSource ---

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 60;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return self.sectionHeaderView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _deptList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DeptListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DeptListCell"];
    DeptInfo *info = _deptList[indexPath.row];
    cell.deptName.text = info.deptName;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    DeptInfo *info = _deptList[indexPath.row];
    _currentDept = info;
    NSArray *deptList = [_dataDic valueForKey:info.deptId];
    if (deptList) {
        [_deptList removeAllObjects];
        [_deptList addObjectsFromArray:deptList];
        [self updateTopCrumbsBy:_currentDept];
        [self.tableView reloadData];
    }else {
        [[ManagerService contactService] searchDeptListWithID:info.deptId];
    }
}

#pragma mark
#pragma mark --- SearchBar ---
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self searchMoreContacts];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (![self.currentSearchText isEqualToString:searchText]) {
        [self resetResultControllerParams];
        self.currentSearchText = searchText;
    }
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

#pragma mark
#pragma mark --- INNER ---
- (UIView *)sectionHeaderView {
    if (!_sectionHeaderView) {
        _sectionHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.tableView.frame), 64)];
        _sectionHeaderView.backgroundColor = BGCOLOR;
        [_sectionHeaderView addSubview:self.scrollView];
    }
    return _sectionHeaderView;
}

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.tableView.frame), 44)];
        _scrollView.backgroundColor = [UIColor whiteColor];
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.scrollsToTop = NO;
    }
    return _scrollView;
}

/**
 This method is used to update top crumbs

 @param dept DeptInfo
 */
- (void)updateTopCrumbsBy:(DeptInfo *)dept {
    
    BOOL isCrumbsBtnExist = NO;
    for (UIButton *tempBtn in self.crumbsBtns) {
        if ([dept.deptId integerValue] == tempBtn.tag) {
            isCrumbsBtnExist = YES;
            break;
        }
    }
    
    if (isCrumbsBtnExist) {
        NSInteger index = NSNotFound;
        index = [self.crumbsDepts indexOfObject:dept];
        if (index != NSNotFound) {
            NSInteger needDelForeIndex = index+1;
            for (NSInteger i = needDelForeIndex; i<self.crumbsBtns.count; i++) {
                UIView *view = self.crumbsBtns[i];
                [view removeFromSuperview];
            }
            NSRange needDelRange = NSMakeRange(needDelForeIndex, self.crumbsDepts.count-needDelForeIndex);
            [self.crumbsDepts removeObjectsInRange:needDelRange];
            [self.crumbsBtns removeObjectsInRange:needDelRange];
            
            UIButton *lastBtn = self.crumbsBtns.lastObject;
            if (lastBtn) {
                self.scrollView.contentSize = CGSizeMake(CGRectGetMaxX(lastBtn.frame), 40.0f);
            }
        }
    }else {
        UIButton *newButton = [self createCrumbsBtnByDept:dept];
        [self.crumbsDepts addObject:dept];
        [self.crumbsBtns addObject:newButton];
        [self.scrollView addSubview:newButton];
        [self.scrollView setContentSize:CGSizeMake(CGRectGetMaxX(newButton.frame), 40.0f)];
    }
    
    [self updateLastCrumbsViewFontTextColor];
    
    CGFloat offset = self.scrollView.contentSize.width-self.view.frame.size.width;
    if (offset>0) {
        [self.scrollView setContentOffset:CGPointMake(offset, 0) animated:YES];
    }else {
        [self.scrollView setContentOffset:CGPointZero animated:YES];
    }
}

/**
 This method is used to update crumbs text color
 */
- (void)updateLastCrumbsViewFontTextColor {
    if (self.crumbsBtns.count > 0) {
        UIButton *lastBtn = self.crumbsBtns.lastObject;
        [lastBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        if (self.crumbsBtns.count > 1) {
            UIButton *foreLastBtn = [self.crumbsBtns objectAtIndex:(self.crumbsBtns.count-2)];
            [foreLastBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        }
    }
}

/**
 This method is used to create crumbs button

 @param dept DeptInfo
 @return UIButton
 */
- (UIButton *)createCrumbsBtnByDept:(DeptInfo *)dept {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button.titleLabel setFont:[UIFont systemFontOfSize:17]];
    [button setTitle:dept.deptName forState:UIControlStateNormal];
    [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [button setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [button setTag:[dept.deptId integerValue]];
    [button addTarget:self action:@selector(goDesCrumbsDeptList:) forControlEvents:UIControlEventTouchUpInside];
    
    CGFloat titleWidth = [self widthByString:dept.deptName fontSize:17.0f];
    UIButton *lastButton = self.crumbsBtns.lastObject;
    if (lastButton) {
        [button setImage:[UIImage imageNamed:@"dept_arrow"] forState:UIControlStateNormal];
        [button setFrame:CGRectMake(CGRectGetMaxX(lastButton.frame), 0, 12.0f+titleWidth, 40.0f)];
    }else {
        [button setFrame:CGRectMake(13.0f, 0, titleWidth, 40.0f)];
    }
    return button;
}

/**
 This method is used to go to select department

 @param sender sender
 */
- (void)goDesCrumbsDeptList:(UIButton *)sender {
    if ([[NSString stringWithFormat:@"%ld", (long)sender.tag] isEqualToString:_currentDept.deptId]) {
        return;
    }
    for (DeptInfo *dept in self.crumbsDepts) {
        NSString *deptID = dept.deptId;
        if (sender.tag == [deptID integerValue]) {
            _currentDept = dept;
            [_deptList removeAllObjects];
            NSArray *deptList = [_dataDic valueForKey:deptID];
            [_deptList addObjectsFromArray:deptList];
            [self.tableView reloadData];
            [self updateTopCrumbsBy:dept];
            break;
        }
    }
}

/**
 This method is used to compute string width

 @param string strNSStringing
 @param fontSize CGFloat
 @return width
 */
- (CGFloat)widthByString:(NSString *)string fontSize:(CGFloat)fontSize {
    NSDictionary *attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:fontSize]};
    CGSize textSize = [string boundingRectWithSize:CGSizeMake(500, 40)
                                           options:NSStringDrawingUsesLineFragmentOrigin
                                        attributes:attributes
                                           context:nil].size;
    return textSize.width+10;
}

#pragma mark
#pragma mark --- SearchBar ---
- (void)setWhiteSearchBar {
    [self.searchController.searchBar setBackgroundImage:[UIImage imageNamed:@"nav_blank"]
                                         forBarPosition:UIBarPositionAny
                                             barMetrics:UIBarMetricsDefault];
}

- (void)setBlueSearchBar {
    [self.searchController.searchBar setBackgroundImage:[UIImage imageNamed:@"nav_blue"]
                                         forBarPosition:UIBarPositionTopAttached
                                             barMetrics:UIBarMetricsDefault];
}

#pragma mark
#pragma mark --- UISearchControllerDelegate ---
- (void)willPresentSearchController:(UISearchController *)searchController {
    
    [self setNavTabbarHidden:YES];
    [self setBlueSearchBar];
}

- (void)willDismissSearchController:(UISearchController *)searchController {
    
    [self setNavTabbarHidden:NO];
    [self setWhiteSearchBar];
    [self resetResultControllerParams];
}

- (void)resetResultControllerParams {
    self.searchPageIndex = 1;
    [self.resultController.searchArray removeAllObjects];
    [self.resultController showTableFooterView];
    [self.resultController.tableView reloadData];
}

- (void)setNavTabbarHidden:(BOOL)show {
    
    [self setEdgesForExtendedLayout:UIRectEdgeAll];
    [self setExtendedLayoutIncludesOpaqueBars:show];
    [self.navigationController.view setNeedsLayout];
}

@end
