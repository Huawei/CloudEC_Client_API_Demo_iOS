//
//  AddressSearchResultController.m
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

#import "AddressSearchResultController.h"
#import "ContactInfo.h"

@interface AddressSearchResultController ()

@end

@implementation AddressSearchResultController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _searchArray = [[NSMutableArray alloc] init];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _searchArray.count;
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
    ContactInfo *info = _searchArray[indexPath.row];
    cell.textLabel.text = info.personName;
    cell.detailTextLabel.text = info.deptName;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    ContactInfo *info = _searchArray[indexPath.row];
    if (self.delegate && [self.delegate respondsToSelector:@selector(showContactDetailInfo:)]) {
        [self.delegate showContactDetailInfo:info];
    }
}

- (UIView *)tableFooterView {
    UIButton *loadMoreBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [loadMoreBtn setFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, 40)];
    [loadMoreBtn setTitle:@"Load More Persons" forState:UIControlStateNormal];
    [loadMoreBtn addTarget:self action:@selector(loadMorePersons:) forControlEvents:UIControlEventTouchUpInside];
    return loadMoreBtn;
}

- (void)loadMorePersons:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(searchMoreContacts)]) {
        [self.delegate searchMoreContacts];
    }
}

- (void)showTableFooterView {
    self.tableView.tableFooterView = [self tableFooterView];
}

- (void)hideTableFooterView {
    self.tableView.tableFooterView = [[UIView alloc] init];
}

@end
