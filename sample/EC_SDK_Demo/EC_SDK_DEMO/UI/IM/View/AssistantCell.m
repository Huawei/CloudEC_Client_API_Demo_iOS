//
//  AssistantCell.m
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

#import "AssistantCell.h"
#import <TUPIOSSDK/AssistantMessageEntity.h>
#import <TUPIMSDK/AssistantMessageEntity+ServiceObject.h>
#import <TUPIOSSDK/EmployeeCategoryEntity.h>
#import <TUPContactSDK/EmployeeCategoryEntity+ServiceObject.h>
#import <TUPIOSSDK/EmployeeEntity.h>
#import <TUPContactSDK/TupContactService.h>
@interface AssistantCell()
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;        // show current message
@property (weak, nonatomic) IBOutlet UIButton *agreedBtn;          // agreed button

@end

@implementation AssistantCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setMessageEntity:(AssistantMessageEntity *)messageEntity
{
    _messageEntity = messageEntity;
    _messageLabel.text = messageEntity.title;
    
    if ([_messageEntity.action integerValue] == ESpaceAssistantUndetermined) {
        [_agreedBtn setTitle:@"agree" forState:UIControlStateNormal];
        [_agreedBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        _agreedBtn.layer.borderColor    = [UIColor blackColor].CGColor;
        _agreedBtn.enabled = YES;
    }else if ([_messageEntity.action integerValue] == ESpaceAssistantAccept)
    {
        [_agreedBtn setTitle:@"isAgreed" forState:UIControlStateDisabled];
        _agreedBtn.layer.borderColor = [UIColor clearColor].CGColor;
        [_agreedBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        _agreedBtn.enabled = NO;
    }
}


/**
 This method is used to deal agree button action

 @param sender sender
 */
- (IBAction)agreeBtnAction:(id)sender {
    if ([_messageEntity.type integerValue] == ESpaceAssistantGroupInvite) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self groupInvite];
        });
    }else if ([_messageEntity.type integerValue] == ESpaceAssistantAddedFriend){
        dispatch_async(dispatch_get_main_queue(), ^{
            [self addFriend];
        });
    }
    
}

/**
 This method is used to agreed a group invite
 */
- (void)groupInvite
{
    UIAlertController *alertCtrl = [UIAlertController alertControllerWithTitle:@"join group" message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *agreed = [UIAlertAction actionWithTitle:@"Agreed" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [_messageEntity acceptGroupInvite:^(NSError *error)
         {
             dispatch_async(dispatch_get_main_queue(), ^{
                 if (!error)
                 {
                     NSLog(@"join group success!");
                     [_agreedBtn setTitle:@"isAgreed" forState:UIControlStateDisabled];
                     _agreedBtn.layer.borderColor = [UIColor clearColor].CGColor;
                     [_agreedBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
                     _agreedBtn.enabled = NO;
                 }
                 else
                 {
                     NSLog(@"join group failed :%@",[error description]);
                     //                 [self showMessage:@"Join group failed!"];
                 }
             });
         }];
    }];
    UIAlertAction *reject = [UIAlertAction actionWithTitle:@"Reject" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [_messageEntity rejectGroupInvite:^(NSError *error)
         {
             dispatch_async(dispatch_get_main_queue(), ^{
                 if (!error)
                 {
                     NSLog(@"reject group success!");
                     [_agreedBtn setTitle:@"isReject" forState:UIControlStateDisabled];
                     _agreedBtn.layer.borderColor = [UIColor clearColor].CGColor;
                     [_agreedBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
                     _agreedBtn.enabled = NO;
                 }
                 else
                 {
                     NSLog(@"reject group failed :%@",[error description]);
//                     [self showMessage:@"Reject group failed!"];
                 }
             });
         }];
    }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    [alertCtrl addAction:agreed];
    [alertCtrl addAction:reject];
    [alertCtrl addAction:cancel];
    [self.window.rootViewController presentViewController:alertCtrl animated:YES completion:nil];
}

/**
 This method is used to add a friend
 */
- (void)addFriend {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Select The Group"
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];
    NSArray *groups = [EmployeeCategoryEntity allCategoryEntities];
    for (EmployeeCategoryEntity *group in groups) {
        UIAlertAction *action = [UIAlertAction actionWithTitle:group.name
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * _Nonnull action)
                                 {
                                     EmployeeEntity *emp = [[TupContactService sharedInstance] employeeFromCopyMemoryUser:(EmployeeEntity *)_messageEntity.from];
                                     [[TupContactService sharedInstance] addFriend:emp
                                                                     toExistedTeam:group
                                                                            notify:NO
                                                                        completion:^(NSError *error)
                                      {
                                          dispatch_async(dispatch_get_main_queue(), ^{
                                              if (!error) {
                                                  [_agreedBtn setTitle:@"isAgreed" forState:UIControlStateDisabled];
                                                  _agreedBtn.layer.borderColor = [UIColor clearColor].CGColor;
                                                  [_agreedBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
                                                  _agreedBtn.enabled = NO;
                                              }
                                          });
                                          
                                      }];
                                 }];
        [alertController addAction:action];
    }
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel"
                                                     style:UIAlertActionStyleDefault
                                                   handler:nil];
    [alertController addAction:cancel];
    [self.window.rootViewController presentViewController:alertController
                                            animated:YES
                                          completion:nil];
}


@end
