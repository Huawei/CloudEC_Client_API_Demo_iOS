//
//  PersonHeaderViewCell.m
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

#import "PersonHeaderViewCell.h"
#import <TUPIOSSDK/EmployeeEntity.h>
#import <TUPIOSSDK/eSpaceDBService.h>
#import <TUPContactSDK/TupContactService.h>
#import <TUPContactSDK/EmployeeEntity+ServiceObject.h>
#import "ChatViewController.h"
#import "HeadImageView.h"
#import "PreviewPersonHeadHDImageController.h"

@interface PersonHeaderViewCell ()

@property (weak, nonatomic) IBOutlet HeadImageView *headImg;            // head image view
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;                // name label
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;              // status label
@property (weak, nonatomic) IBOutlet UIButton *chatBtn;                 // chat btn
@property (nonatomic, strong) EspaceUserOnlineStatus* onlineStatus;     // user online status

@end

@implementation PersonHeaderViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.onlineStatus = [[TupContactService sharedInstance] onlineStatusForUser:self.employee.account
                                                                 forceSubscribe:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userStatusChanged:)
                                                 name:TUP_USER_STATUS_CHANGED
                                               object:nil];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showPersonHDHeadImageView:)];
    self.headImg.userInteractionEnabled = YES;
    [self.headImg addGestureRecognizer:tap];
}


/**
 This method is used to show HD head image when tap head image

 @param tap UITapGestureRecognizer
 */
- (void)showPersonHDHeadImageView:(UITapGestureRecognizer *)tap {
    
    PreviewPersonHeadHDImageController *HDCtrl = [[PreviewPersonHeadHDImageController alloc] initWithEmployee:self.employee];
    [self.parentViewCtrl.navigationController presentViewController:HDCtrl animated:NO completion:nil];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setEmployee:(EmployeeEntity *)employee {
    _employee = employee;
    if ([employee.account isEqualToString:LOCAL_DATA_MANAGER.currentUser.account]) {
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        self.statusLabel.hidden = YES;
        self.chatBtn.hidden = YES;
    }else {
        self.accessoryType = UITableViewCellAccessoryNone;
    }
    self.nameLabel.text = employee.name;
    [self reloadStateDescribe];
    [self.headImg setContactEntity:_employee];
}


/**
 This method is used to updata the statusLabel
 */
- (void)reloadStateDescribe {
    NSString *stateStr;
    self.onlineStatus = [[TupContactService sharedInstance] onlineStatusForUser:self.employee.account
                                                                 forceSubscribe:YES];
    switch (self.onlineStatus.userStatus) {
        case ESpaceUserStatusAvailable:
            stateStr = @"Online";
            self.statusLabel.textColor = [UIColor greenColor];
            break;
        case ESpaceUserStatusBusy:
            stateStr = @"Busy";
            self.statusLabel.textColor = [UIColor redColor];
            break;
        case ESpaceUserStatusAway:
            stateStr = @"Away";
            self.statusLabel.textColor = [UIColor orangeColor];
            break;
        case ESpaceUserStatusUninteruptable:
            stateStr = @"UnInterruptable";
            self.statusLabel.textColor = [UIColor redColor];
            break;
        case ESpaceUserStatusOffline:
        default:
            stateStr = @"Offline";
            self.statusLabel.textColor = [UIColor grayColor];
            break;
    }
    self.statusLabel.text = [NSString stringWithFormat:@"Status: %@", stateStr];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.headImg.layer.cornerRadius = 40;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


/**
 This method is used to reload status describe when receive status change motify

 @param notify NSNotification
 */
- (void)userStatusChanged:(NSNotification *)notify {
    [self reloadStateDescribe];
}


/**
 This method is used to jump to chat viewController when chat btn action

 @param sender sender
 */
- (IBAction)chat:(id)sender {
    ChatViewController *chatViewCtrl = [[ChatViewController alloc] initWithNibName:@"ChatViewController" bundle:nil];
    chatViewCtrl.session = _employee.chatSession;
    [_parentViewCtrl.navigationController pushViewController:chatViewCtrl animated:YES];
}


@end
