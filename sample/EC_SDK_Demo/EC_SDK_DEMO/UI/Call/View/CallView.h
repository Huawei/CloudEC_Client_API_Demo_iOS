//
//  CallView.h
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//
#import <UIKit/UIKit.h>
#import "Defines.h"

@class CallInfo;

@protocol CallViewDelegate<NSObject>
@optional
-(void)clickCallToolBarType:(CALL_TOOLBAR_BUTTON_TYPE)type callViewTag:(NSInteger)callViewTag;
@end
@interface CallView : UIView
@property (weak, nonatomic) IBOutlet UIButton *closeCameraButton;
@property (weak, nonatomic) IBOutlet UIButton *switchCameraButton;

@property (weak, nonatomic) IBOutlet UIView *toolBarView;
@property (weak, nonatomic) IBOutlet UILabel *tipLabel;
@property (nonatomic,weak)id<CallViewDelegate> delegate;
@property (nonatomic,assign)BOOL isCameraClose;
@property (nonatomic,assign)BOOL isMuteMic;
@property (nonatomic,assign)BOOL isHold;
@property (nonatomic,assign)BOOL isloudSpeak;
@property (nonatomic,assign)BOOL isLeaveConference;
@property (nonatomic,strong)CallInfo *currentTupCallInfo;
@property (nonatomic,assign)UIInterfaceOrientation showOrient;
@end
