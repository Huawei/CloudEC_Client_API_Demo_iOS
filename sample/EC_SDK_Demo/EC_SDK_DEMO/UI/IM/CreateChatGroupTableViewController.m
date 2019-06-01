//
//  CreateChatGroupTableViewController.m
//  EC_SDK_DEMO
//
//  Created by huawei on 2019/1/22.
//  Copyright © 2019年 cWX160907. All rights reserved.
//

#import "CreateChatGroupTableViewController.h"

#import "GroupInfoModifyController.h"

@interface CreateChatGroupTableViewController ()
@property (nonatomic, strong) UISwitch *fixGroup;

@end

@implementation CreateChatGroupTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.automaticallyAdjustsScrollViewInsets =  NO;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 3;
    }else if (section == 1)
    {
        return 1;
    }

    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"CreateChatGroupDetailCell"];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"CreateChatGroupDetailCell"];
    }
    
    NSString *contentItem = nil;
    NSString *detailText = nil;
    UIColor *cellTextColor = [UIColor darkGrayColor];
    UIFont *cellTextFont = [UIFont systemFontOfSize:15.0];
    
    
    
    if (indexPath.section == 0)
    {
        if (indexPath.row == 0) {
//            detailText = _groupModel.name.length > 0 ? _groupModel.name : @"No Group Name";
            contentItem = @"group name";
        }else if (indexPath.row == 1){
//            detailText = _groupModel.announce.length > 0 ? _groupModel.announce : @"No Bulletin";
            contentItem = @"Bulletin";
        }else if (indexPath.row == 2){
//            detailText = _groupModel.intro.length > 0 ?_groupModel.intro : @"No Description";
            contentItem = @"Desc.";
        }else{
            
        }
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
    }else if (indexPath.section == 1)
    {
        if(indexPath.row == 0)
        {
            _fixGroup = [[UISwitch alloc] init];
            [_fixGroup addTarget:self action:@selector(switchValueChange:) forControlEvents:UIControlEventValueChanged];
            cell.accessoryView = _fixGroup;
            _fixGroup.on = NO;
            contentItem = @"fix group";
        }
    }
    
    cell.textLabel.text = contentItem;
    cell.textLabel.textColor = cellTextColor;
    cell.textLabel.font = cellTextFont;
    cell.detailTextLabel.text = detailText;
    cell.detailTextLabel.font = [UIFont systemFontOfSize:13.0f];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        GroupInfoModifyController *ctrl = [[GroupInfoModifyController alloc]init];
//        ctrl.group = self.groupModel;
        ctrl.modifyType = (GroupInfoModifyType)indexPath.row;
        [self.navigationController pushViewController:ctrl animated:YES];
    }
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
