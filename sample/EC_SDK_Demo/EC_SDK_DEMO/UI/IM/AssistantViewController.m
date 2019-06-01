//
//  AssistantViewController.m
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

#import "AssistantViewController.h"
#import "AssistantCell.h"
#import <CoreData/CoreData.h>

@interface AssistantViewController ()<NSFetchedResultsControllerDelegate>
@property (nonatomic, strong) NSFetchedResultsController *chatRecentFetchCtrl;   // chat recent fetchResultController
@end

@implementation AssistantViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Assistant";
    
    [self loadDataSource];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"AssistantCell" bundle:nil] forCellReuseIdentifier:@"AssistantCell"];
    
}

/**
 This method is used to config chatRecentFetchCtrl
 */
- (void)loadDataSource
{
//    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
//    NSEntityDescription *entity = [NSEntityDescription entityForName:@"AssistantMessageEntity" inManagedObjectContext:[[eSpaceDBService sharedInstance].localDataManager managedObjectContext]];
//    NSSortDescriptor *timestampDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"receiveTimestamp" ascending:NO];
//    [fetchRequest setEntity:entity];
//    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects: timestampDescriptor, nil]];
//
//    _chatRecentFetchCtrl = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:[[eSpaceDBService sharedInstance].localDataManager managedObjectContext] sectionNameKeyPath:nil cacheName:nil];
    _chatRecentFetchCtrl.delegate = self;
    [_chatRecentFetchCtrl performFetch:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.chatRecentFetchCtrl.fetchedObjects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AssistantCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AssistantCell"];
    AssistantMessageEntity *message = self.chatRecentFetchCtrl.fetchedObjects[indexPath.row];
    cell.messageEntity = message;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

#pragma mark --- FetchResultControllerDelegate ---

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(nullable NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(nullable NSIndexPath *)newIndexPath
{
    [self.tableView reloadData];
}

@end
