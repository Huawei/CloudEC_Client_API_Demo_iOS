//
//  CreateGroupController.m
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

#import "CreateGroupController.h"
#import "ContactSearchResultController.h"
#import "MemberCollectionViewCell.h"
#import "ContactListCell.h"
#import <CoreData/CoreData.h>
#import "EmployeeCategoryEntity.h"
#import "EmployeeEntity.h"
#import "GroupEntity.h"

#import "eSpaceDBService.h"
#import "NSManagedObjectContext+Persistent.h"
#import "ESpaceContactService.h"
#import "ECSAppConfig.h"

@interface CreateGroupController ()<ContactSearchDelegate, UISearchBarDelegate, UISearchControllerDelegate, NSFetchedResultsControllerDelegate, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource>
@property (nonatomic, strong)  UICollectionView *selectedMemberCollect;        // show the selected members
@property (nonatomic, strong)  UITableView *addMemberTableView;                // current add member tableView
@property (nonatomic, strong) ContactSearchResultController *resultController; // current searchResultController
@property (nonatomic, strong) UISearchController *searchController;            // current searchController
@property (nonatomic, strong) NSManagedObjectContext *searchMemoryContext;     // current seatch memoryContext
@property (nonatomic, strong) NSMutableArray *selectMembersArray;              // selected members array
@property (nonatomic, strong) NSFetchedResultsController *contactFetchCtrl;    // current contact fetchResultController
@property (nonatomic, strong) EmployeeCategoryEntity* categoryFilter;          // category entity
@property (nonatomic, assign) NSInteger searchPageIndex;                       // current search page index
@property (nonatomic, strong) NSLayoutConstraint *collectionViewHeight;        // layout constraint
@property (nonatomic, copy) NSString *currentSearchText;                       // current search text
@property (nonatomic, assign) NSUInteger currentMaxWeight;                     // current max weight

@end

@implementation CreateGroupController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self adjustConstraintIfNeed];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [self configSubviews];
    [self loadDataSource];
    [self configDelegate];
    
    [self addRightBtn];
    [self.addMemberTableView setEditing:YES];
//    self.addMemberTableView.allowsMultipleSelectionDuringEditing = YES;
    [self.addMemberTableView registerNib:[UINib nibWithNibName:@"ContactListCell" bundle:nil] forCellReuseIdentifier:@"ContactListCell"];
    [self.selectedMemberCollect registerNib:[UINib nibWithNibName:@"MemberCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"MemberCollectionViewCell"];
}

- (void)addRightBtn
{
    UIBarButtonItem *btnItem = [[UIBarButtonItem alloc]initWithTitle:@"Finish" style:UIBarButtonItemStylePlain target:self action:@selector(onFinishBtnAction)];
    self.navigationItem.rightBarButtonItem = btnItem;
}

- (void)createChatGroupWithGroupType:(ECSGroupType)groupType
{
    NSMutableArray *accountArray = [[NSMutableArray alloc]init];
    for (EmployeeEntity *employee in _selectMembersArray) {
        if ([employee isKindOfClass:[EmployeeEntity class]]) {
            [accountArray addObject:employee.account];
        }else{
            if (employee.name) {
                [accountArray addObject:employee.name];
            }
        }
    }
    if (accountArray.count > 0) {
        
        if (accountArray.count <= 1) {
            return;
        }
        NSString *groupName = [ECSAppConfig sharedInstance].latestAccount;
        for (NSString *memName in accountArray)
        {
            groupName = [groupName stringByAppendingFormat:@",%@",memName];
        }
        [[ESpaceContactService sharedInstance] createGroupWithName:groupName enName:groupName groupType:groupType userAccountList:accountArray ownerAccount:[ECSAppConfig sharedInstance].latestAccount announce:@"" intro:@"" completion:^(NSString *groupId, NSString *failedList, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (error)
                {
                    NSLog(@"error:%@",[error description]);
                    [self showMessage:@"Create failed"];
                }
                else
                {
                    NSLog(@"groupId--- :%@",groupId);
                    [self.navigationController popViewControllerAnimated:YES];
                }
            });
        }];
    }
}

/**
 This method is used to deal finish bitton action
 */
- (void)onFinishBtnAction
{
    UIAlertController *alertCtrl = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *fixGroupAction = [UIAlertAction actionWithTitle:@"Fix Group" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self createChatGroupWithGroupType:ECSFixGroup];
    }];
    UIAlertAction *chatGroupAction = [UIAlertAction actionWithTitle:@"Chat Group" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self createChatGroupWithGroupType:ECSChatGroup];
    }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    [alertCtrl addAction:fixGroupAction];
    [alertCtrl addAction:chatGroupAction];
    [alertCtrl addAction:cancel];
    [self presentViewController:alertCtrl animated:YES completion:nil];
    
//        [[ESpaceContactService sharedInstance] createGroupWithName:groupName enName:groupName userAccountList:accountArray announce:@"" intro:@"" completion:^(NSString *groupId, NSString *failedList, NSError *error)
//                      {
//                          dispatch_async(dispatch_get_main_queue(), ^{
//                              if (error)
//                              {
//                                  NSLog(@"error:%@",[error description]);
//                                  [self showMessage:@"Create failed"];
//                              }
//                              else
//                              {
//                                  NSLog(@"groupId--- :%@",groupId);
//                                  [self.navigationController popViewControllerAnimated:YES];
//                              }
//                          });
//                      }];
//
//
//        if (self.createGroupType == ADD_USER) {
//            [self.currentGroup inviteUsers:accountArray desc:nil completion:^(NSString *faildList, NSError *error)
//             {
//                 dispatch_async(dispatch_get_main_queue(), ^{
//                     if (error && error.code != 39)
//                     {
//                         NSLog(@"error--- :%@ faildList:%@",[error description],faildList);
//                         [self showMessage:@"Invite failed"];
//                     }
//                     else
//                     {
//                         NSLog(@"invite success");
//                         [self.navigationController popViewControllerAnimated:YES];
//                     }
//                 });
//             }];
//        }else{
//            if (accountArray.count <= 1) {
//                return;
//            }
//            NSString *groupName = [ECSAppConfig sharedInstance].latestAccount;
//            for (NSString *memName in accountArray)
//            {
//                groupName = [groupName stringByAppendingFormat:@",%@",memName];
//            }
//            [[TupContactService sharedInstance] createGroupWithName:groupName enName:groupName userAccountList:accountArray announce:@"" intro:@"" completion:^(NSString *groupId, NSString *failedList, NSError *error)
//             {
//                 dispatch_async(dispatch_get_main_queue(), ^{
//                     if (error)
//                     {
//                         NSLog(@"error:%@",[error description]);
//                         [self showMessage:@"Create failed"];
//                     }
//                     else
//                     {
//                         NSLog(@"groupId--- :%@",groupId);
//                         [self.navigationController popViewControllerAnimated:YES];
//                     }
//                 });
//             }];
}

/**
 This method is used to config self delegate
 */
- (void)configDelegate
{
    _selectMembersArray = [[NSMutableArray alloc]init];
    self.addMemberTableView.delegate = self;
    self.addMemberTableView.dataSource = self;
    
    self.resultController = [[ContactSearchResultController alloc] init];
    self.resultController.delegate = self;
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:self.resultController];
    
    [self.searchController.searchBar sizeToFit];
    
    self.addMemberTableView.tableHeaderView = self.searchController.searchBar;
    self.searchController.searchBar.backgroundColor = [UIColor lightGrayColor];
    
    self.searchController.searchBar.delegate = self;
    self.searchController.delegate = self;
    self.definesPresentationContext = YES;
}

/**
 This method is used to config subviews
 */
- (void)configSubviews
{
    // table view
    self.addMemberTableView.tableHeaderView = self.searchController.searchBar;
    self.addMemberTableView.translatesAutoresizingMaskIntoConstraints = NO;
    self.addMemberTableView.decelerationRate                          = (UIScrollViewDecelerationRateFast + UIScrollViewDecelerationRateNormal) / 2.0;
    [self.view addSubview:_addMemberTableView];
    
    /*table view 索引背景颜色*/
    if ([self.addMemberTableView respondsToSelector:@selector(setSectionIndexColor:)]) {
        self.addMemberTableView.sectionIndexBackgroundColor           = [UIColor clearColor];
        self.addMemberTableView.sectionIndexTrackingBackgroundColor   = [UIColor clearColor];
//        self.addMemberTableView.sectionIndexColor = RGBACOLOR(0x53, 0x53, 0x53, 1);
    }
    
    // collection view
    self.selectedMemberCollect.translatesAutoresizingMaskIntoConstraints = NO;
    self.selectedMemberCollect.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.selectedMemberCollect];

    [self.selectedMemberCollect registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([UICollectionViewCell class])];
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout*)self.selectedMemberCollect.collectionViewLayout;
    flowLayout.itemSize                    = CGSizeMake(60, 75);
    flowLayout.minimumLineSpacing          = 8;
    flowLayout.minimumInteritemSpacing     = 9;
    flowLayout.sectionInset         = UIEdgeInsetsMake(9, 8, 9, 8);
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    
    // add constraints
    UIView* collectionView          = self.selectedMemberCollect;
    id<UILayoutSupport> topGuide    = self.topLayoutGuide;
    id<UILayoutSupport> bottomGuide = self.bottomLayoutGuide;
    UIView* table          = self.addMemberTableView;
    
    NSDictionary* views    = NSDictionaryOfVariableBindings(collectionView, topGuide, bottomGuide, table);
    NSArray *vconstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[topGuide]-0-[collectionView]-0-[table]-0-[bottomGuide]" options:0 metrics:nil views:views];
    NSString *strHVirual = [NSString stringWithFormat:@"H:|[collectionView]|"];
    NSArray* hconstraints  = [NSLayoutConstraint constraintsWithVisualFormat:strHVirual options:0 metrics:nil views:views];
    CGFloat currentHeight = self.selectMembersArray.count == 0 ? 0 : 69;
    _collectionViewHeight = [NSLayoutConstraint constraintWithItem:collectionView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:currentHeight];
    [self.view addConstraint:_collectionViewHeight];
    [self.view addConstraints:vconstraints];
    [self.view addConstraints:hconstraints];
    hconstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[table]|" options:0 metrics:nil views:views];
    [self.view addConstraints:vconstraints];
    [self.view addConstraints:hconstraints];

    [self.view setNeedsUpdateConstraints];
    [self.view updateConstraintsIfNeeded];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (UICollectionView *)selectedMemberCollect
{
    if (nil == _selectedMemberCollect) {
        UICollectionViewFlowLayout* flowLayout = [[UICollectionViewFlowLayout alloc] init];
        _selectedMemberCollect = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        _selectedMemberCollect.dataSource = self;
        _selectedMemberCollect.delegate   = self;
        _selectedMemberCollect.showsHorizontalScrollIndicator = NO;
    }
    
    return _selectedMemberCollect;
}

- (UITableView *)addMemberTableView
{
    if (nil == _addMemberTableView) {
        _addMemberTableView = [[UITableView alloc] initWithFrame:CGRectZero];
        _addMemberTableView.separatorStyle  = UITableViewCellSeparatorStyleNone;
        _addMemberTableView.dataSource      = self;
        _addMemberTableView.delegate        = self;
    }
    return _addMemberTableView;
}

/**
 This method is used to load self friends
 */
- (void)loadDataSource
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSPredicate* contentPredicate = [NSPredicate predicateWithFormat:@"isFriend=%@ AND contactId!=%@", [NSNumber numberWithBool:YES], [eSpaceDBService sharedInstance].localDataManager.userAccount];
    
    if (_categoryFilter) {
        contentPredicate = [NSPredicate predicateWithFormat:@"isFriend=%@ AND category CONTAINS %@", [NSNumber numberWithBool:YES], _categoryFilter];
    }

    NSEntityDescription *entity = [NSEntityDescription entityForName:@"PersonEntity" inManagedObjectContext:self.searchMemoryContext];
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

-(NSManagedObjectContext *)searchMemoryContext
{
    if (!_searchMemoryContext) {
        _searchMemoryContext = [[eSpaceDBService sharedInstance].localDataManager memoryObjectContext];
    }
    return _searchMemoryContext;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 This method is used to adjust constraint
 */
- (void)adjustConstraintIfNeed{
    if (_selectMembersArray.count && _collectionViewHeight.constant == 0) {
        self.view.userInteractionEnabled = NO;
        [self.view layoutIfNeeded];
        [UIView animateWithDuration:0.25 animations:^{
            _collectionViewHeight.constant = 69;
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            self.view.userInteractionEnabled = YES;
        }];
    }
    else if (_selectMembersArray.count == 0 && _collectionViewHeight.constant == 69){
        self.view.userInteractionEnabled = NO;
        [self.view layoutIfNeeded];
        [UIView animateWithDuration:0.25 animations:^{
            _collectionViewHeight.constant = 0;
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            self.view.userInteractionEnabled = YES;
        }];
    }
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
#pragma mark - UISearchControllerDelegate
- (void)willPresentSearchController:(UISearchController *)searchController {
    
    [self setEdgesForExtendedLayout:UIRectEdgeAll];
    [self.navigationController.view setNeedsLayout];
    if (0 == _collectionViewHeight.constant) {
        [self.searchController.searchBar setBackgroundImage:[UIImage imageNamed:@"nav_blue"]
                                             forBarPosition:UIBarPositionTopAttached
                                                 barMetrics:UIBarMetricsDefault];
    }
    else if (69 == _collectionViewHeight.constant) {
        [self.searchController.searchBar setBackgroundImage:[UIImage imageNamed:@"nav_blank"]
                                             forBarPosition:UIBarPositionAny
                                                 barMetrics:UIBarMetricsDefault];
    }

}

- (void)willDismissSearchController:(UISearchController *)searchController {
    
    [self setEdgesForExtendedLayout:UIRectEdgeAll];
    [self.navigationController.view setNeedsLayout];
    [self.searchController.searchBar setBackgroundImage:[UIImage imageNamed:@"nav_blank"]
                                         forBarPosition:UIBarPositionAny
                                             barMetrics:UIBarMetricsDefault];
    
    [self resetResultControllerParams];
}

- (void)resetResultControllerParams {
    self.searchPageIndex = 1;
    [self.resultController.searchArray removeAllObjects];
    [self.resultController showTableFooterView];
    [self.resultController.tableView reloadData];
}


#pragma mark - collectionDelegate

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _selectMembersArray.count;
}

-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MemberCollectionViewCell *cell = (MemberCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"MemberCollectionViewCell" forIndexPath:indexPath];
    
    [cell setPerson:_selectMembersArray[indexPath.row]];
    
    return cell;
}

- (BOOL)collectionView:(UICollectionView *)collectionView deleteItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self.selectMembersArray removeObjectAtIndex:indexPath.row];
    [collectionView performBatchUpdates:^{
        [collectionView deleteItemsAtIndexPaths:[NSArray arrayWithObject:indexPath]];
    } completion:nil];
    [self adjustConstraintIfNeed];
    
    return YES;
}

- (BOOL)collectionView:(UICollectionView *)collectionView addItem:(id)item
{
    if (nil == item) {
        return NO;
    }
    EmployeeEntity *employee = item;
    NSInteger index = self.selectMembersArray.count;
    [self.selectMembersArray addObject:employee];
    [self adjustConstraintIfNeed];
    
    NSIndexPath *tmpIndexPath = [NSIndexPath indexPathForRow:index inSection:0];
    [collectionView performBatchUpdates:^{
        [collectionView insertItemsAtIndexPaths:@[tmpIndexPath]];
    } completion:^(BOOL finished) {
        if (!finished) {
            return;
        }
    }];
    
    return YES;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    [self collectionView:collectionView deleteItemAtIndexPath:indexPath];
    
}

#pragma mark - UITableView Datasource and delegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _contactFetchCtrl.fetchedObjects.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    EmployeeEntity *employee = _contactFetchCtrl.fetchedObjects[indexPath.row];
    ContactListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ContactListCell"];
    cell.person = employee;
    for (EmployeeEntity *person in self.selectMembersArray) {
        if ([person.account isEqualToString:employee.account]) {
            cell.selected = YES;
        }
    }
    for (EmployeeEntity *groupPerson in [self.currentGroup.members allObjects]) {
        if ([groupPerson.account isEqualToString:employee.account]) {
            cell.tintColor = [UIColor grayColor];
            cell.selected = YES;
        }
    }
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    EmployeeEntity *employee = _contactFetchCtrl.fetchedObjects[indexPath.row];
//    if ([employee.account isEqualToString:[ECSAppConfig sharedInstance].latestAccount]) {
//        return;
//    }
    for (EmployeeEntity *groupPerson in [self.currentGroup.members allObjects]) {
        if ([groupPerson.account isEqualToString:employee.account]) {
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            cell.tintColor = [UIColor grayColor];
            cell.selected = YES;
            return;
        }
    }
    [self collectionView:self.selectedMemberCollect addItem:employee];
    
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    EmployeeEntity *employee = _contactFetchCtrl.fetchedObjects[indexPath.row];
    
    NSInteger index = [_selectMembersArray indexOfObject:employee];
    NSIndexPath *tmpIndexPath = [NSIndexPath indexPathForRow:index inSection:0];
    
    [self collectionView:self.selectedMemberCollect deleteItemAtIndexPath:tmpIndexPath];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 59;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete | UITableViewCellEditingStyleInsert;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

#pragma mark - ContactSearchDelegate
- (void)searchContacts {
    __block NSArray *fetchedList = nil;
//    [[TupContactService sharedInstance] queryCorpAdressBook:self.currentSearchText
//                                                  pageIndex:self.searchPageIndex
//                                                   pageSize:50
//                                                      field:nil
//                                                 showStatus:NO
//                                                 searchFlag:0
//                                                  inContext:self.searchMemoryContext
//                                                 completion:^(NSError *error, NSInteger count)
//     {
//         dispatch_sync(dispatch_get_main_queue(), ^{
//             if (error) {
//                 NSLog(@"query Corp Adress Book failed: %@",error.description);
//                 return ;
//             }
//             if (count < 50) {
//                 [self.resultController hideTableFooterView];
//             }
//             if (count == 0) {
//                 [self showMessage:@"Sorry! No more data!"];
//                 return;
//             }
//             NSSortDescriptor *weightOrder = [[NSSortDescriptor alloc] initWithKey:@"weight" ascending:YES];
//             NSEntityDescription *entity = [NSEntityDescription entityForName:@"EmployeeEntity"
//                                                       inManagedObjectContext:self.searchMemoryContext];
//             NSPredicate *predicate = [NSPredicate predicateWithFormat:@"weight > %@",
//                                       [NSNumber numberWithUnsignedInteger:self.currentMaxWeight]];
//             NSFetchRequest *request = [[NSFetchRequest alloc] init];
//             request.entity = entity;
//             request.predicate = predicate;
//             request.sortDescriptors = [NSArray arrayWithObject:weightOrder];
//             fetchedList = [self.searchMemoryContext executeFetchRequest:request error:nil];
//             self.searchPageIndex++;
//             self.currentMaxWeight += [fetchedList count];
//             [self.resultController.searchArray addObjectsFromArray:fetchedList];
//             [self.resultController.tableView reloadData];
//         });
//     }];
}

- (void)showPersonDetailInfo:(EmployeeEntity *)employee {
    dispatch_async(dispatch_get_main_queue(), ^{
//        if ([employee.account isEqualToString:[ECSAppConfig sharedInstance].latestAccount]) {
//            return;
//        }
        for (EmployeeEntity *groupPerson in [self.currentGroup.members allObjects]) {
            if ([groupPerson.account isEqualToString:employee.account]) {
                return;
            }
        }
        for (EmployeeEntity *groupPerson in _selectMembersArray) {
            if ([groupPerson.account isEqualToString:employee.account]) {
                return;
            }
        }
        [self collectionView:self.selectedMemberCollect addItem:employee];
        [self dismissViewControllerAnimated:NO completion:nil];
    });
}

#pragma mark
#pragma showMessage

-(void)showMessage:(NSString *)msg
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:msg preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}


@end
