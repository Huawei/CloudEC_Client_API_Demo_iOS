//
//  ContactGroupListViewController.m
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

#import "ContactGroupListViewController.h"
#import "EmployeeCategoryEntity.h"
#import "EmployeeCategoryEntity+ServiceObject.h"
#import "ESpaceContactService.h"

#import "eSpaceDBService.h"
#import "ManagerService.h"

@interface ContactGroupListViewController ()
@property (nonatomic, strong) NSMutableArray *contactGroups;
@end

@implementation ContactGroupListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Group Selected";
    self.contactGroups = [NSMutableArray arrayWithArray:[EmployeeCategoryEntity allCategoryEntities]];
    
    UIBarButtonItem *btn = [[UIBarButtonItem alloc]initWithTitle:@"Create" style:UIBarButtonItemStylePlain target:self action:@selector(createGroup)];
    self.navigationItem.rightBarButtonItem = btn;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)createGroup
{
    UIAlertController *alertCon = [UIAlertController alertControllerWithTitle:nil message:@"Please enter new contact group name" preferredStyle:UIAlertControllerStyleAlert];
    [alertCon addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"name";
        textField.secureTextEntry = NO;
    }];

    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UITextField *nameFiled = alertCon.textFields.firstObject;

        
        NSString *name = nameFiled.text;

        if (name != nil) {
            [[ESpaceContactService sharedInstance] createContactGroupWithGroupName:name completionBlock:^(NSString *groupId, NSError* error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (error == nil) {
                        self.contactGroups = [NSMutableArray arrayWithArray:[EmployeeCategoryEntity allCategoryEntities]];
                        [self.tableView reloadData];
                    }
                });
            }];
        }
        
    }];
    [alertCon addAction:okAction];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:nil];
    [alertCon addAction:cancelAction];
    [self presentViewController:alertCon animated:YES completion:nil];
}

- (void)deleteContactGroupWithIndexRow:(NSInteger)row
{
    EmployeeCategoryEntity *entity = self.contactGroups[row -1];
    
    for (id obj in entity.members) {
        if ([obj isKindOfClass:[EmployeeEntity class]]) {
            [[ESpaceContactService sharedInstance] deleteFriend:obj completion:^(NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (!error) {
                    }else {
                    }
                });
                
            }];
        }
    }
    
    [[ESpaceContactService sharedInstance] deleteContactGroupWithGroupId:entity.id completionBlock:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error == nil) {
                self.contactGroups = [NSMutableArray arrayWithArray:[EmployeeCategoryEntity allCategoryEntities]];
                [self.tableView reloadData];            }
        });
    }];
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
        [ESpaceContactService sharedInstance].currentContactGroupId = nil;
    }else {
        category = self.contactGroups[indexPath.row-1];
        [ESpaceContactService sharedInstance].currentContactGroupId = category.id;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectedContactGroupCategory:)]) {
        [self.delegate didSelectedContactGroupCategory:category];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        if (indexPath.row != 0) {
            [self deleteContactGroupWithIndexRow:indexPath.row];
        }
    }
}

@end
