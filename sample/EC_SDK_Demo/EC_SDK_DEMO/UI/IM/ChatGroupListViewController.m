//
//  ChatGroupListViewController.m
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

#import "ChatGroupListViewController.h"
#import "GroupListCell.h"
#import "GroupDetailViewController.h"
#import "CreateGroupController.h"
#import <CoreData/CoreData.h>

#import "eSpaceDBService.h"
#import "GroupEntity.h"
#import "GroupEntity+ServiceObject.h"

@interface ChatGroupListViewController ()<NSFetchedResultsControllerDelegate>
@property (nonatomic, strong) NSFetchedResultsController *groupFetchResultCtl;   // current group fetchResultController

@end

@implementation ChatGroupListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Group";
    UIBarButtonItem *btn = [[UIBarButtonItem alloc]initWithTitle:@"Create" style:UIBarButtonItemStylePlain target:self action:@selector(createGroup)];
    self.navigationItem.rightBarButtonItem = btn;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"GroupListCell" bundle:nil] forCellReuseIdentifier:@"GroupListCell"];
    [self loadAllGroups];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 This method is used to config group fetchResultController
 */
- (void)loadAllGroups
{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"GroupEntity"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(state = %@ OR state = %@)",[NSNumber numberWithInteger:ESpaceGroupStateExist],[NSNumber numberWithInteger:ESpaceGroupStateMemberLoaded]];
    NSSortDescriptor *typeDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"groupType" ascending:YES];
    NSSortDescriptor *contactIdDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"contactId" ascending:YES selector:@selector(localizedStandardCompare:)];
    fetchRequest.predicate = predicate;
    fetchRequest.sortDescriptors = @[typeDescriptor,contactIdDescriptor];

    _groupFetchResultCtl = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:[[eSpaceDBService sharedInstance].localDataManager managedObjectContext] sectionNameKeyPath:nil cacheName:nil];
    _groupFetchResultCtl.delegate = self;
    [_groupFetchResultCtl performFetch:nil];
}


/**
 This method is used to create a group
 */
- (void)createGroup{
    CreateGroupController *createCtrl = [[CreateGroupController alloc]init];
    createCtrl.createGroupType = CREATE_GROUP;
    [self.navigationController pushViewController:createCtrl animated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return _groupFetchResultCtl.fetchedObjects.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GroupListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GroupListCell"];
    cell.gruopEntity = _groupFetchResultCtl.fetchedObjects[indexPath.row];
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    GroupEntity *groupEntity = _groupFetchResultCtl.fetchedObjects[indexPath.row];
    __weak typeof(self) weakSelf = self;
    [groupEntity queryGroupMember:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            GroupDetailViewController *detailGroupCtrl = [[GroupDetailViewController alloc]initWithNibName:@"GroupDetailViewController" bundle:nil];
            detailGroupCtrl.groupModel = groupEntity;
            detailGroupCtrl.hidesBottomBarWhenPushed = YES;
            [weakSelf.navigationController pushViewController:detailGroupCtrl animated:YES];
        });
    }];
    
    
}

#pragma mark --- FetchResultControllerDelegate ---

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(nullable NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(nullable NSIndexPath *)newIndexPath
{
    [self.tableView reloadData];
}

@end
