//
//  ContactGroupListViewController.m
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

#import "ContactGroupListViewController.h"

#import <TUPContactSDK/EmployeeCategoryEntity+ServiceObject.h>

@interface ContactGroupListViewController ()
@property (nonatomic, strong) NSMutableArray *contactGroups;
@end

@implementation ContactGroupListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Group Selected";
    self.contactGroups = [NSMutableArray arrayWithArray:[EmployeeCategoryEntity allCategoryEntities]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.contactGroups.count+1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        cell.textLabel.textColor = [UIColor darkGrayColor];
        cell.textLabel.font = [UIFont systemFontOfSize:15];
    }
    if (0 == indexPath.row) {
        cell.textLabel.text = @"All Contacts";
    }else {
        EmployeeCategoryEntity *category = self.contactGroups[indexPath.row-1];
        cell.textLabel.text = [NSString stringWithFormat:@"%@(%lu)", category.name, (unsigned long)category.members.count];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    EmployeeCategoryEntity *category;
    if (0 == indexPath.row) {
        category = nil;
    }else {
        category = self.contactGroups[indexPath.row-1];
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectedContactGroupCategory:)]) {
        [self.delegate didSelectedContactGroupCategory:category];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end
