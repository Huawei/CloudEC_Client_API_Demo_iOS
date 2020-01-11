//
//  CallTipView.h
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//
#import <UIKit/UIKit.h>
#import "Defines.h"
#import "CallInfo.h"

@protocol CallTipDelegate<NSObject>
@optional
-(void)clickCommingTipViewButton:(COMMING_VIEW_BTNACTION_TYPE)actionType;
@end

@interface CallTipView : UIView

//CommingView
@property (weak, nonatomic) IBOutlet UILabel *displayCallNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *commingCallTipLabel;
@property (weak, nonatomic) IBOutlet UIButton *audioAnswerCallBtn;
@property (weak, nonatomic) IBOutlet UIButton *videoAnswerCallBtn;
@property (weak, nonatomic) IBOutlet UIButton *refuesCommingCallBtn;

@property (nonatomic)CallTipView *commingView;
@property (assign,nonatomic)TUP_CALL_TYPE currentCallType;
@property (assign, nonatomic)ConfType currentConfType;
@property (nonatomic, weak)id<CallTipDelegate> delegate;
@property (assign, nonatomic)unsigned int callId;

+(instancetype)shareInstance;

-(void)showCommingCallTipViewInUIView:(UIView *)superView delegate:(id)delegate;
-(void)removeCommingCallTipView;

@end
