//
//  DataConfBaseViewController.h
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

#import <UIKit/UIKit.h>
#import "ConfAttendeeInConf.h"

@interface DataConfBaseViewController : UIViewController

@property (nonatomic,strong) UIView  *barView;
@property (nonatomic,strong) UIButton* endBtn;
@property (nonatomic,strong) UIButton* voiceBtn;
@property (nonatomic,strong) UIButton* muteBtn;
@property (nonatomic,strong) UIView *bottomView;
@property (nonatomic, copy) NSString *selfNumber;

@property (nonatomic, strong)ConfAttendeeInConf *selfConfInfo;

@property (nonatomic, strong)UITapGestureRecognizer *baseTap;

- (CGFloat)selfViewWidth;
- (CGFloat)selfViewHeight;
- (BOOL)isSelfMaster;
- (void)goToConfListViewController;
- (void)showMessage:(NSString *)msg;

- (void)changeBtnContent:(UIButton *)btn;

- (UIButton *)createButtonByImage:(UIImage *)btnImage
                   highlightImage:(UIImage *)highlightImage
                            title:(NSString *)title
                           target:(id)target
                           action:(SEL)action;

@end
