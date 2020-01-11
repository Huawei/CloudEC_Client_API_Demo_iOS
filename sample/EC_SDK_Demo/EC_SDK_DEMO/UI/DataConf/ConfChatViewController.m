//
//  ConfChatTableViewController.m
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

#import "ConfChatViewController.h"
#import "ManagerService.h"
#import "ChatMsg.h"
#import "CommonUtils.h"
#import "ConfAttendeeInConf.h"
#import "ConfListViewController.h"

@interface ConfChatViewController ()<UITextFieldDelegate,DataConferenceChatMessageDelegate>
@property (nonatomic,weak)IBOutlet UITextField *chatTextField;
@property (nonatomic,weak)IBOutlet UITableView *chatTableView;
@property (nonatomic,strong) NSMutableArray *chatMsgArray;
@property (nonatomic,weak)IBOutlet NSLayoutConstraint *bottomLayout;

@end

@implementation ConfChatViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [CommonUtils setToOrientation:UIDeviceOrientationPortrait];
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [ManagerService confService].chatDelegate = self;
    _chatMsgArray = [NSMutableArray array];
    _chatTableView.tableFooterView = [[UIView alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWilHide:) name:UIKeyboardWillHideNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(quitToListViewCtrl) name:CONF_QUITE_TO_CONFLISTVIEW object:nil];
}

- (void)quitToListViewCtrl
{
    
    UIViewController *list = nil;
    for (UIViewController *vc in self.navigationController.viewControllers) {
        if ([vc isKindOfClass:[ConfListViewController class]]) {
            list = vc;
            break;
        }
    }
    
    if (list) {
        [self.navigationController popToViewController:list animated:YES];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)dealloc
{
    //jl todo?
//    [ManagerService dataConfService].chatDelegate = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)didReceiveChatMessage:(ChatMsg *)chatMessage
{
    [_chatMsgArray addObject:chatMessage];
    [_chatTableView reloadData];
}

- (IBAction)singleTapInScreen:(id)sender
{
    [self.view endEditing:YES];
}

- (IBAction)sendMessage:(id)sender
{
    if (_chatTextField.text.length == 0) {
        return;
    }
    if ([[ManagerService confService] chatSendMsg:_chatTextField.text fromUsername:_selfInfo.name toUserId:0]) {
        _chatTextField.text = @"";
    }
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _chatMsgArray.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"chatMsgCell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"chatMsgCell"];
        [cell.textLabel setFont:[UIFont systemFontOfSize:13]];
    }
    ChatMsg *message = [_chatMsgArray objectAtIndex:indexPath.row];
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@: %@", message.fromUserName, message.lpMsg]];
    [string addAttributes:@{NSStrokeWidthAttributeName : @(2)} range:NSMakeRange(0, message.fromUserName.length+1)];
    cell.textLabel.attributedText = string;
    return cell;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    NSValue * value = [notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    NSNumber *duration = [notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    CGRect keyboardRect = [value CGRectValue];
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:duration.doubleValue animations:^{
        weakSelf.bottomLayout.constant = CGRectGetHeight(keyboardRect);
        [weakSelf.view layoutIfNeeded];
    }];
}

- (void)keyboardWilHide:(NSNotification *)notification
{
    NSNumber *duration = [notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:duration.doubleValue animations:^{
        weakSelf.bottomLayout.constant = 0;
        [weakSelf.view layoutIfNeeded];
    }];
}

@end
