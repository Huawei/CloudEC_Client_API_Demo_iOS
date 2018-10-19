//
//  ContactChatViewController.m
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

#import <TUPContactSDK/TupContactService.h>
#import <TUPIOSSDK/eSpaceDBService.h>
#import <TUPIOSSDK/PersonEntity.h>
#import <TUPIOSSDK/EmployeeEntity.h>

#import "GroupCell.h"
#import "ContactListCell.h"
#import "ChatSessionCell.h"
#import "PersonDetailViewController.h"
#import "ContactChatViewController.h"
#import "ContactSearchResultController.h"
#import "ChatGroupListViewController.h"
#import "ContactGroupListViewController.h"
#import "ChatViewController.h"
#import "AssistantViewController.h"
#import "Defines.h"

@interface ContactChatViewController ()<UISearchBarDelegate, UISearchControllerDelegate, ContactSearchDelegate, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate, SelectedContactGroupDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;                    // current tableView
@property (nonatomic, strong) UISearchController *searchController;             // current searchController
@property (nonatomic, strong) ContactSearchResultController *resultController;  // current searchResultController
@property (nonatomic, assign)NSInteger searchPageIndex;                         // current search page index
@property (nonatomic, copy) NSString *currentSearchText;                        // current search text
@property (nonatomic, assign) NSUInteger currentMaxWeight;                      // current max weight
@property (nonatomic, strong) NSManagedObjectContext *searchMemoryContext;      // current search memory context
@property (nonatomic, assign) NSUInteger currentShowType;                       // 0: Chat Session List; 1: Contact List
@property (nonatomic, strong) NSArray *groupKinds;                              // kinfs of groups array
@property (nonatomic, strong) NSFetchedResultsController *chatRecentFetchCtrl;  // current chat recent fetchreult controller
@property (nonatomic, strong) NSFetchedResultsController *contactFetchCtrl;     // current contact fetchresult controller
@property (nonatomic, strong) EmployeeCategoryEntity* categoryFilter;           // categroy entity

@property (nonatomic, strong) UIActivityIndicatorView *chatViewLoginingActivityIndicator;

@end

@implementation ContactChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.groupKinds = @[@GROUP_KIND_CHAT,         // chat groups
                        @GROUP_KIND_CONTACT,      // contact groups
                        @E_ASSISTANT];            // e assistant
    
    self.resultController = [[ContactSearchResultController alloc] init];
    self.resultController.delegate = self;
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:self.resultController];
    
    [self setWhiteSearchBar];
    [self.searchController.searchBar sizeToFit];
    
    self.tableView.tableHeaderView = self.searchController.searchBar;
    
    self.searchController.searchBar.delegate = self;
    self.searchController.delegate = self;
    self.definesPresentationContext = YES;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"GroupCell" bundle:nil] forCellReuseIdentifier:@"GroupCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"ContactListCell" bundle:nil] forCellReuseIdentifier:@"ContactListCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"ChatSessionCell" bundle:nil] forCellReuseIdentifier:@"ChatSessionCell"];
    
    if ([ECSAppConfig sharedInstance].currentUser.isAutoLogin) {
        [self autoLoginAction];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(maaLoginSuccessedAction)
                                                 name:MAA_LOGIN_SUCCESSED
                                               object:nil];
    
//    [self loadDataSource];
//    [self.tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

-(UIActivityIndicatorView *)chatViewLoginingActivityIndicator
{
    if (_chatViewLoginingActivityIndicator == nil) {
        _chatViewLoginingActivityIndicator = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
    }
    return _chatViewLoginingActivityIndicator;
}

- (void)autoLoginAction
{
//    dispatch_sync(dispatch_get_main_queue(), ^{
    
        UIBarButtonItem *btn = [[UIBarButtonItem alloc]initWithCustomView:self.chatViewLoginingActivityIndicator];
        
        self.navigationItem.rightBarButtonItem = btn;
        
        self.chatViewLoginingActivityIndicator.hidden = NO;
        [self.chatViewLoginingActivityIndicator startAnimating];
//    });
}

- (void)maaLoginSuccessedAction
{
    dispatch_sync(dispatch_get_main_queue(), ^{
        [self loadDataSource];
        [self.tableView reloadData];
        self.chatViewLoginingActivityIndicator.hidden = YES;
        [self.chatViewLoginingActivityIndicator stopAnimating];
    });
    
}

/**
 This method is used to load current chat and contact data source
 */
- (void)loadDataSource
{
    self.searchMemoryContext = [[eSpaceDBService sharedInstance].localDataManager memoryObjectContext];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSPredicate* contentPredicate = [NSPredicate predicateWithFormat:@"parent=%@ AND priority >= 0", [eSpaceDBService sharedInstance].localDataManager.rootChatSessionGroup];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ChatSessionEntity" inManagedObjectContext:[[eSpaceDBService sharedInstance].localDataManager managedObjectContext]];
    NSSortDescriptor *priorityDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"priority" ascending:NO];
    NSSortDescriptor *timestampDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:NO];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:contentPredicate];
    [fetchRequest setRelationshipKeyPathsForPrefetching:@[@"latestMessage", @"latestMessage.from"]];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:priorityDescriptor, timestampDescriptor, nil]];
    _chatRecentFetchCtrl = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:[[eSpaceDBService sharedInstance].localDataManager managedObjectContext] sectionNameKeyPath:nil cacheName:nil];
    _chatRecentFetchCtrl.delegate = self;
    [_chatRecentFetchCtrl performFetch:nil];
    
    
    fetchRequest = [[NSFetchRequest alloc] init];
    if (_categoryFilter) {
        contentPredicate = [NSPredicate predicateWithFormat:@"isFriend=%@ AND category CONTAINS %@", [NSNumber numberWithBool:YES], _categoryFilter];
    } else {
        contentPredicate = [NSPredicate predicateWithFormat:@"isFriend=%@ AND contactId!=%@", [NSNumber numberWithBool:YES], [eSpaceDBService sharedInstance].localDataManager.userAccount];
    }
    
    entity = [NSEntityDescription entityForName:@"PersonEntity" inManagedObjectContext:[[eSpaceDBService sharedInstance].localDataManager managedObjectContext]];
    NSSortDescriptor *accountDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"nameIndex" ascending:YES];
    NSSortDescriptor *nameDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    NSSortDescriptor *IdDesriptor = [NSSortDescriptor sortDescriptorWithKey:@"contactId" ascending:YES];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:contentPredicate];
    [fetchRequest setSortDescriptors:@[accountDescriptor,nameDescriptor,IdDesriptor]];
    
    _contactFetchCtrl = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:[[eSpaceDBService sharedInstance].localDataManager managedObjectContext] sectionNameKeyPath:nil cacheName:nil];
    _contactFetchCtrl.delegate = self;
    [_contactFetchCtrl performFetch:nil];
}


/**
 this is method use to change chat viewController and contact viewController

 @param sender sender
 */
- (IBAction)switchBtnClicked:(id)sender
{
    UISegmentedControl * ctrl = (UISegmentedControl *)sender;
    _currentShowType = ctrl.selectedSegmentIndex;
    [_tableView reloadData];
}

#pragma mark
#pragma mark --- UISearchBarDelegate ---
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self searchContacts];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (![self.currentSearchText isEqualToString:searchText]) {
        
        [self resetResultControllerParams];
        self.currentSearchText = searchText;
    }
}

#pragma mark
#pragma mark --- UITableView ---

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.0f;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (_currentShowType == 0) {
        return 1;
    }
    else {
        return 2;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_currentShowType == 0) {
        return _chatRecentFetchCtrl.fetchedObjects.count;
    }
    else {
        if (0 == section) {
            return self.groupKinds.count;
        }else {
            return _contactFetchCtrl.fetchedObjects.count;
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    if (_currentShowType == 0) {
        ChatSessionCell* sessionCell = [tableView dequeueReusableCellWithIdentifier:@"ChatSessionCell"];
        [sessionCell setChatSession:_chatRecentFetchCtrl.fetchedObjects[indexPath.row]];
        cell = sessionCell;
    }
    else {
        if (0 == indexPath.section) {
            GroupCell *groupCell = [tableView dequeueReusableCellWithIdentifier:@"GroupCell"];
            groupCell.index = [self.groupKinds[indexPath.row] integerValue];
            groupCell.category = self.categoryFilter;
            cell = groupCell;
        }else {
            ContactListCell *contactCell = [tableView dequeueReusableCellWithIdentifier:@"ContactListCell"];
            contactCell.person = self.contactFetchCtrl.fetchedObjects[indexPath.row];
            cell = contactCell;
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (_currentShowType == 0) {
        ChatViewController *chatViewCtrl = [[ChatViewController alloc] initWithNibName:@"ChatViewController" bundle:nil];
        chatViewCtrl.session = self.chatRecentFetchCtrl.fetchedObjects[indexPath.row];
        chatViewCtrl.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:chatViewCtrl animated:YES];
    }
    else {
        if (0 == indexPath.section) {
            GroupCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            UIViewController *viewController;
            switch (cell.index) {
                case GROUP_KIND_CHAT:{
                    viewController = [[ChatGroupListViewController alloc] init];
                }
                    break;
                case GROUP_KIND_CONTACT:{
                    ContactGroupListViewController *tempVC = [[ContactGroupListViewController alloc] init];
                    tempVC.delegate = self;
                    viewController = tempVC;
                }
                    break;
                case E_ASSISTANT:{
                    viewController = [[AssistantViewController alloc] init];
                }
                    break;
                    
                default:
                    break;
            }
            if (viewController) {
                viewController.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:viewController animated:YES];
            }
        }else {
            PersonEntity *person = self.contactFetchCtrl.fetchedObjects[indexPath.row];
            if ([person isKindOfClass:[EmployeeEntity class]]) {
                [self showPersonDetailInfo:(EmployeeEntity *)person];
            }
        }
    }
}

#pragma mark --- SelectedContactGroupDelegate ---

- (void)didSelectedContactGroupCategory:(EmployeeCategoryEntity *)category {
    self.categoryFilter = category;
    _contactFetchCtrl = nil;
    _contactFetchCtrl.delegate = nil;
    [self loadDataSource];
    [_tableView reloadData];
}

#pragma mark --- FetchResultControllerDelegate ---

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(nullable NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(nullable NSIndexPath *)newIndexPath
{
    [_tableView reloadData];
}

#pragma mark
#pragma mark --- ContactSearchDelegate ---
- (void)searchContacts {
    __block NSArray *fetchedList = nil;
    [[TupContactService sharedInstance] queryCorpAdressBook:self.currentSearchText
                                                  pageIndex:self.searchPageIndex
                                                   pageSize:50
                                                      field:nil
                                                 showStatus:NO
                                                 searchFlag:0
                                                  inContext:self.searchMemoryContext
                                                 completion:^(NSError *error, NSInteger count)
     {
         dispatch_sync(dispatch_get_main_queue(), ^{
             if (error) {
                 NSLog(@"query Corp Adress Book failed: %@",error.description);
                 return ;
             }
             if (count < 50) {
                 [self.resultController hideTableFooterView];
             }
             if (count == 0) {
                 [self showMessage:@"Sorry! No more data!"];
                 return;
             }
             NSSortDescriptor *weightOrder = [[NSSortDescriptor alloc] initWithKey:@"weight" ascending:YES];
             NSEntityDescription *entity = [NSEntityDescription entityForName:@"EmployeeEntity"
                                                       inManagedObjectContext:self.searchMemoryContext];
             NSPredicate *predicate = [NSPredicate predicateWithFormat:@"weight > %@",
                                       [NSNumber numberWithUnsignedInteger:self.currentMaxWeight]];
             NSFetchRequest *request = [[NSFetchRequest alloc] init];
             request.entity = entity;
             request.predicate = predicate;
             request.sortDescriptors = [NSArray arrayWithObject:weightOrder];
             fetchedList = [self.searchMemoryContext executeFetchRequest:request error:nil];
             self.searchPageIndex++;
             self.currentMaxWeight += [fetchedList count];
             [self.resultController.searchArray addObjectsFromArray:fetchedList];
             [self.resultController.tableView reloadData];
         });
     }];
}

- (void)showPersonDetailInfo:(EmployeeEntity *)employee {
    PersonDetailViewController *detailVC = [[PersonDetailViewController alloc] initWithPerson:employee];
    detailVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:detailVC animated:YES];
    [self.searchController setActive:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    
    UIViewController *controller = [UIApplication sharedApplication].delegate.window.rootViewController;
    if (![controller isKindOfClass:[UITabBarController class]]) {
        return;
    }
    UITabBarController *tabbar = (UITabBarController*)controller;
    tabbar.tabBar.hidden = show;
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
#pragma mark --- AlertShow ---
-(void)showMessage:(NSString *)msg {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                   message:msg
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [self presentViewController:alert animated:NO completion:nil];
    [NSTimer scheduledTimerWithTimeInterval:0.5
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


@end
