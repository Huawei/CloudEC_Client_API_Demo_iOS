//
//  UserSignatureSettingController.m
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

#import "UserSignatureSettingController.h"

#import "CommonUtils.h"
#import <TUPIOSSDK/TUPUserSettingService.h>
#import <TUPIOSSDK/TUPIOSSDK.h>

@interface UserSignatureSettingController ()

@property (weak, nonatomic) IBOutlet UITextView *textView;    // text view

@end

@implementation UserSignatureSettingController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"Signature";
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(saveSignature)];
    self.textView.text = LOCAL_DATA_MANAGER.currentUser.signature;
}

- (void)saveSignature {
    [[TUPUserSettingService sharedInstance] setSelfSignature:_textView.text completion:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!error) {
                [self showMessage:@"Save success."];
                [self performSelector:@selector(back) withObject:nil afterDelay:1];
            }else {
                [self showMessage:@"Save failed."];
            }
        });
    }];
}

- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark
#pragma mark --- AlertShow ---
-(void)showMessage:(NSString *)msg {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                   message:msg
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [self presentViewController:alert animated:NO completion:nil];
    [NSTimer scheduledTimerWithTimeInterval:0.5
                                     target:self
                                   selector:@selector(creatAlert:)
                                   userInfo:alert
                                    repeats:NO];
}

- (void)creatAlert:(NSTimer *)timer {
    UIAlertController *alert = [timer userInfo];
    [alert dismissViewControllerAnimated:YES completion:nil];
    alert = nil;
}

@end
