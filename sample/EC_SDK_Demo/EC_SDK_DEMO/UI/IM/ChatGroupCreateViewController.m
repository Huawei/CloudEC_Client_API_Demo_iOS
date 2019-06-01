//
//  ChatGroupCreateViewController.m
//  EC_SDK_DEMO
//
//  Created by huawei on 2019/1/23.
//  Copyright © 2019年 cWX160907. All rights reserved.
//

#import "ChatGroupCreateViewController.h"

@interface ChatGroupCreateViewController ()
@property (weak, nonatomic) IBOutlet UILabel *GroupNameLabel;
@property (weak, nonatomic) IBOutlet UITextView *GroupNameTextView;
@property (weak, nonatomic) IBOutlet UILabel *BulletinLabel;
@property (weak, nonatomic) IBOutlet UITextView *BulletinTextView;
@property (weak, nonatomic) IBOutlet UILabel *DescLabel;
@property (weak, nonatomic) IBOutlet UITextView *DescTextView;
@property (weak, nonatomic) IBOutlet UILabel *FixGroupLabel;
@property (weak, nonatomic) IBOutlet UISwitch *FixGroupSwitch;

@end

@implementation ChatGroupCreateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
