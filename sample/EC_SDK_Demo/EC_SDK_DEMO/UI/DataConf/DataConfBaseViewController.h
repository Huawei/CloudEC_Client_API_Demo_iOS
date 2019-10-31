//
//  DataConfBaseViewController.h
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

#import <UIKit/UIKit.h>
#import "ConfAttendeeInConf.h"

#import "CallStatisticInfo.h"
#import "SignalDataScrollView.h"
#import "StatisticShowInfo.h"
#import "ImageViewBtn.h"
#import "EAGLView.h"
#import "ECBaseViewController.h"

#define SCREEN_WIDTH MIN(self.view.bounds.size.width, self.view.bounds.size.height)
#define SCREEN_HIGHT MAX(self.view.bounds.size.height, self.view.bounds.size.width)

@interface DataConfBaseViewController : ECBaseViewController

@property (nonatomic,strong) UIView  *barView;
@property (nonatomic,strong) UIButton* endBtn;
@property (nonatomic,strong) UIButton* voiceBtn;
@property (nonatomic,strong) UIButton* muteBtn;
@property (nonatomic,strong) UIView *bottomView;
@property (nonatomic, copy) NSString *selfNumber;

@property (nonatomic, strong)ConfAttendeeInConf *selfConfInfo;

@property (nonatomic, strong)UITapGestureRecognizer *baseTap;

@property (nonatomic, strong) ImageViewBtn *signalBtn;
@property (nonatomic, strong) UIView *signalBackView;
@property (nonatomic, strong) SignalDataScrollView *signalDataScrollView;

@property (nonatomic, assign) UIDeviceOrientation confLastOrientation;

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
