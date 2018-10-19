//
//  CallHistoryViewController.m
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

#import "CallHistoryViewController.h"
#import "CallHistoryCell.h"
#import "ManagerService.h"

@interface CallHistoryViewController ()
@property (nonatomic, strong)NSMutableArray *callHistoryDataSources;  // call history data array

@end

@implementation CallHistoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"CallHistory";
    _callHistoryDataSources = [[NSMutableArray alloc]initWithArray:[self loadLocalCallHistoryData]];
    self.tableView.tableFooterView = [[UIView alloc]init];
    [self.tableView registerNib:[UINib nibWithNibName:@"CallHistoryCell" bundle:nil] forCellReuseIdentifier:@"CallHistoryCell"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source and delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _callHistoryDataSources.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CallHistoryCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CallHistoryCell" forIndexPath:indexPath];
    
    cell.callLogMessage = _callHistoryDataSources[indexPath.row];
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [_callHistoryDataSources removeObjectAtIndex:indexPath.row];
        [self.tableView reloadData];
        [self writeToLocalFileWith:_callHistoryDataSources];
    }
}

#pragma mark - DBPath Deal

/**
 This method is used to get DB paht

 @return filePath
 */
- (NSString *)callHistoryDBPath
{
    NSString *logPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *plistName = [NSString stringWithFormat:@"%@_allHistory.plist",[ManagerService callService].sipAccount];
    NSString *filePath = [logPath stringByAppendingPathComponent:plistName];
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        if ([[NSFileManager defaultManager] createFileAtPath:filePath
                                                    contents:nil
                                                  attributes:nil]) {
            return filePath;
        }else {
            DDLogWarn(@"create callHistory.plist failed!");
            return nil;
        }
    }
    return filePath;
}

/**
 This method is used to message write to local file

 @param array message array
 @return is succeed or not
 */
- (BOOL)writeToLocalFileWith:(NSArray *)array {
    NSString *path = [self callHistoryDBPath];
    if (path) {
        return [NSKeyedArchiver archiveRootObject:array toFile:path];
    }
    return NO;
}


/**
 This method is used to get loacl call history path data

 @return message array
 */
- (NSArray *)loadLocalCallHistoryData {
    NSString *path = [self callHistoryDBPath];
    if (path) {
        NSArray *array = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
        return array;
    }
    return nil;
}

@end
