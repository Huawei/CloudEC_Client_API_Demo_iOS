//
//  GroupHeadViewCell.m
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

#import "GroupHeadViewCell.h"
#import "HeadImageView.h"
#import "ChatViewController.h"
#import "GroupEntity.h"

@interface GroupHeadViewCell()
@property (weak, nonatomic) IBOutlet HeadImageView *groupHeadImageView;   // group head image view
@property (weak, nonatomic) IBOutlet UILabel *groupNameLabel;             // show group name
@property (weak, nonatomic) IBOutlet UIButton *chatBtn;                   // chat message button

@end
@implementation GroupHeadViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setGroup:(GroupEntity *)group
{
    _group = group;
    [_groupHeadImageView setContactEntity:group];
    _groupNameLabel.text = group.name;
}


/**
 This method is used to jump to chatMessage view

 @param sender sender
 */
- (IBAction)chatBtnAction:(id)sender {
    ChatViewController *chatViewCtrl = [[ChatViewController alloc] initWithNibName:@"ChatViewController" bundle:nil];
    chatViewCtrl.session = _group.chatSession;
    [_parentViewCtrl.navigationController pushViewController:chatViewCtrl animated:YES];
}

@end
