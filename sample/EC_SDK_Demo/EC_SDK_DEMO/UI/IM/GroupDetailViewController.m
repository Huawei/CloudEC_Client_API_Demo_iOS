//
//  GroupDetailViewController.m
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

#import "GroupDetailViewController.h"
#import <TUPIOSSDK/TUPIOSSDK.h>
#import <TUPIOSSDK/PersonEntity.h>
#import <TUPContactSDK/GroupEntity+ServiceObject.h>
#import "HeadImageView.h"
#import "GroupHeadViewCell.h"
#import "MembersViewController.h"
#import "GroupInfoModifyController.h"
//#import "CreateGroupViewController.h"

@interface GroupDetailViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *infoTableView;    // current tableView
@property (nonatomic, strong) UISwitch *lockGroup;                  // group lock switch
@property (nonatomic, strong) UISwitch *muteChat;                   // group mute seitch
@property (nonatomic,strong) NSArray *keyPathArray;                 // group cell info array


@end

@implementation GroupDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.automaticallyAdjustsScrollViewInsets =  NO;
    _keyPathArray = @[@"name",@"members",@"fixed",@"groupType",@"state",@"owner",@"announce",@"intro"];
    for (NSString *tempStr in _keyPathArray)
    {
        [self.groupModel addObserver:self forKeyPath:tempStr options:NSKeyValueObservingOptionNew context:NULL];
    }
    
    [self.infoTableView registerNib:[UINib nibWithNibName:@"GroupHeadViewCell" bundle:nil] forCellReuseIdentifier:@"GroupHeadViewCell"];
    
    UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(10, 0, self.view.bounds.size.width-20, 40)];
    [btn setTitle:@"Quit" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn setBackgroundColor:[UIColor redColor]];
    [btn setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    btn.clipsToBounds = YES;
    btn.layer.cornerRadius = 8;
    [btn addTarget:self action:@selector(deleteBtnAction) forControlEvents:UIControlEventTouchUpInside];
    self.infoTableView.tableFooterView = btn;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.title = self.groupModel.name;
    [self.infoTableView reloadData];
    
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    NSLog(@"observeValueForKeyPath=========== keyPath:%@",keyPath);
    [self.infoTableView reloadData];
    
}

-(void)dealloc
{
    for (NSString *tempStr in _keyPathArray)
    {
        [self.groupModel removeObserver:self forKeyPath:tempStr context:NULL];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - private method
/**
 This method is used to deal mete group action

 @param senderSwitch UISwitch
 */
-(void)switchMuteGroup:(UISwitch *)senderSwitch
{
    if (senderSwitch.on)
    {
        [self onGroupMute];
    }
    else
    {
        [self onGroupUnmute];
    }
}

/**
 This method is used to mute group
 */
-(void)onGroupMute
{
    __weak typeof(self) weakSelf = self;
    [self.groupModel muteGroup:^(NSError *error)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!error)
            {
                NSLog(@"mute group success!");
            }
            else
            {
                [weakSelf showMessage:[NSString stringWithFormat:@"Mute gruop failed :%@",[error description]]];
                return ;
            }
        });
    }];
}

/**
 This method is used to unmute group
 */
-(void)onGroupUnmute
{
    __weak typeof(self) weakSelf = self;
    [self.groupModel unmuteGroup:^(NSError *error)
     {
         dispatch_async(dispatch_get_main_queue(), ^{
             if (!error)
             {
                 NSLog(@"unmute group success!");
             }
             else
             {
                 [weakSelf showMessage:[NSString stringWithFormat:@"Unmute gruop failed :%@",[error description]]];
                 return ;
             }
         });
     }];
}

/**
 This method is used to change groupType between fixGroup and chatGroup

 @param swit UISwitch
 */
-(void)switchValueChange:(UISwitch *)swit
{
    if (![self isGroupManager])
    {
        if (ECSFixGroup == [self.groupModel.groupType integerValue])
        {
            _lockGroup.on = YES;
        }
        else
        {
            _lockGroup.on = NO;
        }
        [self showMessage:@"You are not the manager!"];
        return;
    }
    ECSGroupType groupType;
    if ([self.groupModel.groupType intValue] == ECSFixGroup)//讨论组
    {
        groupType = ECSChatGroup;
        _lockGroup.on = NO;
    }
    else
    {
        groupType = ECSFixGroup;
        _lockGroup.on = YES;
    }
    DDLogInfo(@"groupType---- :%ld",(long)groupType);
    __weak typeof(self) weakSelf = self;
    [self.groupModel changeGroupTypeTo:groupType completion:^(NSError *error)
     {
         if (error)
         {
             [weakSelf showMessage:@"Switch to group type failed!"];
             return ;
         }
         else
         {
             NSLog(@"Switch to group type success!");
             [weakSelf showMessage:@"Switch to group type success!"];
             // [self.navigationController popViewControllerAnimated:YES];
         }
     }];
}

/**
 This method is used to deal delete button action
 */
- (void)deleteBtnAction
{
    UIAlertController *alertCtrl = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *exitAction = [UIAlertAction actionWithTitle:@"Exit" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self onExitButtonPress];
    }];
    UIAlertAction *delete = [UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self onDeleteGroupPress];
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    [alertCtrl addAction:exitAction];
    if ([self isGroupManager]) {
        [alertCtrl addAction:delete];
    }
    [alertCtrl addAction:cancel];
    [self presentViewController:alertCtrl animated:YES completion:nil];
    
}

/**
 This method is used to exit the group
 */
- (void)onExitButtonPress
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:@"Are you sure exit the group?" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *refuseAction = [UIAlertAction actionWithTitle:@"NO" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
                                   {
                                       return ;
                                   }];
    UIAlertAction *answerAction = [UIAlertAction actionWithTitle:@"YES" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
                                   {
                                       __weak typeof(self) weakSelf = self;
                                       [_groupModel leaveGroup:^(NSError *error) {
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                               if (error)
                                               {
                                                   NSLog(@"error--- :%@",[error description]);
                                                   [weakSelf showMessage:@"Exit group failed!"];
                                               }
                                               else
                                               {
                                                   [weakSelf.navigationController popViewControllerAnimated:YES];
                                               }
                                           });
                                       }];
                                   }];
    [alertController addAction:refuseAction];
    [alertController addAction:answerAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

/**
 This method is used to delete the group
 */
- (void)onDeleteGroupPress
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:@"Are you sure dismiss the group?" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *refuseAction = [UIAlertAction actionWithTitle:@"NO" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
                                   {
                                       return ;
                                   }];
    UIAlertAction *answerAction = [UIAlertAction actionWithTitle:@"YES" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
                                   {
                                       __weak typeof(self) weakSelf = self;
                                       [_groupModel dismiss:^(NSError *error) {
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                               if (error)
                                               {
                                                   NSLog(@"error--- :%@",[error description]);
                                                   [weakSelf showMessage:@"Dismiss group failed!"];
                                               }
                                               else
                                               {
                                                   [weakSelf.navigationController popViewControllerAnimated:YES];
                                               }
                                           });
                                       }];
                                   }];
    [alertController addAction:refuseAction];
    [alertController addAction:answerAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

/**
 This method is used to judge is group manager or not
 
 @return is group manager or not
 */
-(BOOL)isGroupManager
{
    NSLog(@"self.groupModel.ownerId--- :%@",self.groupModel.ownerId);
    NSLog(@"[ECSAppConfig sharedInstance].latestAccount:%@",[ECSAppConfig sharedInstance].latestAccount);
    return [[ECSAppConfig sharedInstance].latestAccount isEqualToString:self.groupModel.ownerId];
}

-(void)showMessage:(NSString *)msg
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:msg preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark ----- UITableView Datasource and delegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    }else if (section == 1){
        return 3;
    }else if (section == 2){
        return 2;
    }else if (section == 3){
        return 1;
    }else{
        return 0;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * groupDetailCellIdentifier = @"groupDetailCellIdentifier";
    UITableViewCell * cell = nil;
    if (indexPath.section == 0) {
        GroupHeadViewCell *groupHeadViewCell = [tableView dequeueReusableCellWithIdentifier:@"GroupHeadViewCell"];
        groupHeadViewCell.group = self.groupModel;
        groupHeadViewCell.parentViewCtrl = self;
        cell = groupHeadViewCell;
    }else{
        cell = [tableView dequeueReusableCellWithIdentifier:groupDetailCellIdentifier];
        if (!cell)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:groupDetailCellIdentifier];
        }
        
        NSString *contentItem = nil;
        NSString *detailText = nil;
        UIColor *cellTextColor = [UIColor darkGrayColor];
        UIFont *cellTextFont = [UIFont systemFontOfSize:15.0];
        
        if (indexPath.section == 1)
        {
            if (indexPath.row == 0) {
                detailText = _groupModel.name.length > 0 ? _groupModel.name : @"No Group Name";
                contentItem = @"group name";
            }else if (indexPath.row == 1){
                detailText = _groupModel.announce.length > 0 ? _groupModel.announce : @"No Bulletin";
                contentItem = @"Bulletin";
            }else if (indexPath.row == 2){
                detailText = _groupModel.intro.length > 0 ?_groupModel.intro : @"No Description";
                contentItem = @"Desc.";
            }else{
                
            }
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
        }else if (indexPath.section == 2)
        {
            if(indexPath.row == 0)
            {
                _lockGroup = [[UISwitch alloc] init];
                [_lockGroup addTarget:self action:@selector(switchValueChange:) forControlEvents:UIControlEventValueChanged];
                cell.accessoryView = _lockGroup;
                if (ECSFixGroup == [self.groupModel.groupType integerValue])
                {
                    _lockGroup.on = YES;
                }
                else
                {
                    _lockGroup.on = NO;
                }
                if ([self isGroupManager]) {
                    _lockGroup.enabled = YES;
                }else{
                    _lockGroup.enabled = NO;
                }
                contentItem = @"fix group";
            }else if(indexPath.row == 1)
            {
                _muteChat = [[UISwitch alloc] init];
                [_muteChat addTarget:self action:@selector(switchMuteGroup:) forControlEvents:UIControlEventValueChanged];
                cell.accessoryView = _muteChat;
                if ([self.groupModel.msgRecvOpt intValue] == 0)
                {
                    _muteChat.on = YES;
                }
                else
                {
                    _muteChat.on = NO;
                }
                contentItem = @"mute group";
            }
            
        }else if (indexPath.section == 3){
            detailText = [NSString stringWithFormat:@"%lu",(unsigned long)[[_groupModel.members allObjects] count]];
            contentItem = @"members";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        
        cell.textLabel.text = contentItem;
        cell.textLabel.textColor = cellTextColor;
        cell.textLabel.font = cellTextFont;
        cell.detailTextLabel.text = detailText;
        cell.detailTextLabel.font = [UIFont systemFontOfSize:13.0f];
    }
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return 100;
    }else{
        return 44;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 1) {
        GroupInfoModifyController *ctrl = [[GroupInfoModifyController alloc]init];
        ctrl.group = self.groupModel;
        ctrl.modifyType = (GroupInfoModifyType)indexPath.row;
        [self.navigationController pushViewController:ctrl animated:YES];
    }else if (indexPath.section == 3){
        NSArray *array = [self.groupModel.members allObjects];
        MembersViewController *ctrl = [[MembersViewController alloc]init];
        ctrl.members = array;
        ctrl.group = self.groupModel;
        [self.navigationController pushViewController:ctrl animated:YES];
    }
}

#pragma mark - scroll delegate method
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.view endEditing:YES];
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

@end
