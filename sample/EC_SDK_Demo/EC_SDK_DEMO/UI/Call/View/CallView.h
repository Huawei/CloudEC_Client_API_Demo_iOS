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
typedef enum
{
    JOIN_CALL_BUTTON,
    CLOSE_CALL_BUTTON,
    CHANGE_SOUND_ROUTE_BUTTON,
    DIAL_NUMBER_BUTTON,
    CHANGE_CALL_TYPE_BUTTON,
    CLOSE_CAMERA_BUTTON,
    SWITCH_CAMERA_BUTTON,
    ROUTE_BUTTON,
    TRANSFER_BUTTON,
    HOLD_BUTTON,
    MUTE_MIC_BUTTON,
    SITE_LIST_BUTTON,
    DATA_CONFERENCE_BUTTON
}CALL_TOOLBAR_BUTTON_TYPE;


@protocol CallViewDelegate<NSObject>
@optional
-(void)clickCallToolBarType:(CALL_TOOLBAR_BUTTON_TYPE)type callViewTag:(NSInteger)callViewTag;
@end
@interface CallView : UIView
@property (weak, nonatomic) IBOutlet UIButton *closeCameraButton;
@property (weak, nonatomic) IBOutlet UIButton *switchCameraButton;

@property (weak, nonatomic) IBOutlet UIView *toolBarView;
@property (weak, nonatomic) IBOutlet UILabel *tipLabel;
@property (nonatomic,assign)id<CallViewDelegate> delegate;
@property (nonatomic,assign)BOOL isCameraClose;
@property (nonatomic,assign)BOOL isMuteMic;
@property (nonatomic,assign)BOOL isHold;
@property (nonatomic,assign)BOOL isLeaveConference;
@property (nonatomic,strong)CallInfo *currentTupCallInfo;
@property (nonatomic,assign)UIInterfaceOrientation showOrient;
@end
