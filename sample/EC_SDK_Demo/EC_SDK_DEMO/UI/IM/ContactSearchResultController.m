//
//  ContactSearchResultController.m
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

#import "ContactSearchResultController.h"

#import <TUPIOSSDK/EmployeeEntity.h>
#import <TUPIOSSDK/eSpaceDBService.h>
#import <TUPContactSDK/TupContactService.h>

@interface ContactSearchResultController ()<UITableViewDelegate, UITableViewDataSource>

@end

@implementation ContactSearchResultController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.searchArray = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //show load more view
    [self showTableFooterView];
}

#pragma mark - UITableViewDelegate and UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.searchArray.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    EmployeeEntity *tempEm;
    EmployeeEntity *employee = self.searchArray[indexPath.row];
    NSManagedObjectContext *context = [LOCAL_DATA_MANAGER managedObjectContext];
    EmployeeEntity *localEmployee = [[TupContactService sharedInstance] userWithAccount:employee.account
                                                                              inContext:context
                                                                             autoCreate:NO];
    if (localEmployee) {
        tempEm = localEmployee;
    }else {
        tempEm = [[TupContactService sharedInstance] employeeFromCopyMemoryUser:(EmployeeEntity *)employee];
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(showPersonDetailInfo:)]) {
        [self.delegate showPersonDetailInfo:tempEm];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    }
    EmployeeEntity *employee = self.searchArray[indexPath.row];
    cell.textLabel.text = employee.name;
    cell.textLabel.textColor = [UIColor darkGrayColor];
    cell.textLabel.font = [UIFont systemFontOfSize:15];
    cell.detailTextLabel.text = employee.deptName;
    cell.detailTextLabel.textColor = [UIColor lightGrayColor];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:10];
    return cell;
}

#pragma mark - private method
- (UIView *)tableFooterView {
    UIButton *loadMoreBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [loadMoreBtn setFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, 40)];
    [loadMoreBtn setTitle:@"Load More Persons" forState:UIControlStateNormal];
    [loadMoreBtn addTarget:self action:@selector(loadMorePersons) forControlEvents:UIControlEventTouchUpInside];
    return loadMoreBtn;
}

- (void)showTableFooterView {
    self.tableView.tableFooterView = [self tableFooterView];
}

- (void)hideTableFooterView {
    self.tableView.tableFooterView = [[UIView alloc] init];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadMorePersons {
    if (self.delegate && [self.delegate respondsToSelector:@selector(searchContacts)]) {
        [self.delegate searchContacts];
    }
}

@end
