//
//  CallView.m
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

#import "CallView.h"
#import "Defines.h"
#import "ManagerService.h"
#import "CallInfo.h"
#import "DialSecondPlate.h"

#define UISCREEN_WIDTH  [UIScreen mainScreen].bounds.size.width
#define UISCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
#define LocalCameraFront (1)
#define LocalCameraBack (0)
#define DEFAULT_COLOR [UIColor colorWithRed:24/255.0 green:68/255.0 blue:126/255.0 alpha:1]
@interface CallView()
{
    NSInteger _cameraFaceingIndex;
    NSInteger _cameraRotation;
    NSInteger _lastCameraRotationWhenFrontIndex;
}

//@property (weak, nonatomic) IBOutlet UIView *toolBarView;

@property (weak, nonatomic) IBOutlet UIButton *closeCallButton;
@property (weak, nonatomic) IBOutlet UIButton *changeCallTypeButton;
//@property (weak, nonatomic) IBOutlet UIButton *switchCameraButton;
//@property (weak, nonatomic) IBOutlet UIButton *closeCameraButton;
@property (weak, nonatomic) IBOutlet UIButton *muteMicButton;
@property (weak, nonatomic) IBOutlet UIButton *routeButton;
@property (weak, nonatomic) IBOutlet UIButton *holdButton;
@property (weak, nonatomic) IBOutlet UIButton *transferButton;
@property (weak, nonatomic) IBOutlet UIButton *addContact;
@property (weak, nonatomic) IBOutlet UIImageView *headImage;

@end

@implementation CallView

-(instancetype)init
{
    if (self = [super init])
    {
        _cameraFaceingIndex = LocalCameraFront;
        _cameraRotation = 0;
        _lastCameraRotationWhenFrontIndex = 0;
        _isLeaveConference = NO;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideCurrentCallViewToolbar)];
        [self addGestureRecognizer:tap];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateSpeakerStatus:) name:NTF_AUDIOROUTE_CHANGED object:nil];
        
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"CallView" owner:self options:nil];
        _showOrient = UIInterfaceOrientationPortrait;
        self = [nib objectAtIndex:0];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)hideCurrentCallViewToolbar
{
    if ([DialSecondPlate shareInstance].isShow)
    {
        [[DialSecondPlate shareInstance] hideView];
        return;
    }
    [_toolBarView setHidden:!_toolBarView.hidden];
}

- (void)updateSpeakerStatus:(NSNotification *)notification
{
    ROUTE_TYPE currentRoute = (ROUTE_TYPE)[notification.userInfo[AUDIO_ROUTE_KEY] integerValue];
    if (currentRoute == ROUTE_LOUDSPEAKER_TYPE)
    {
        [_routeButton setImage:[UIImage imageNamed:@"voice_headphonebt_normal"] forState:UIControlStateNormal];
    } else {
        [_routeButton setImage:[UIImage imageNamed:@"voice_call_speaker_normal"] forState:UIControlStateNormal];
    }
}

-(void)setCurrentTupCallInfo:(CallInfo *)currentTupCallInfo
{
    _currentTupCallInfo = currentTupCallInfo;
    if (currentTupCallInfo.stateInfo.callType == 0)
    {
        _headImage.hidden = NO;
        _tipLabel.hidden = NO;
        _tipLabel.text = [NSString stringWithFormat:@"%@",currentTupCallInfo.stateInfo.callNum];
        _closeCameraButton.enabled = NO;
        _switchCameraButton.enabled = NO;
        _transferButton.hidden = NO;
        _holdButton.hidden = NO;
        _addContact.hidden = NO;

        
        [_changeCallTypeButton setImage:[UIImage imageNamed:@"voice_call_video_normal"] forState:UIControlStateNormal];
        [_toolBarView setBackgroundColor:[UIColor clearColor]];
    }
    else
    {
        _headImage.hidden = YES;
        _tipLabel.hidden = YES;
        _closeCameraButton.enabled = YES;
        _switchCameraButton.enabled = YES;
        _transferButton.hidden = YES;
        _holdButton.hidden = YES;
        _addContact.hidden = YES;
        [_changeCallTypeButton setImage:[UIImage imageNamed:@"btn_video_call_voice_normal"] forState:UIControlStateNormal];
        UIColor *color = [[UIColor blackColor] colorWithAlphaComponent:0.3];
        [_toolBarView setBackgroundColor:color];
    }
    
    ROUTE_TYPE currentRoute = [[ManagerService callService] obtainMobileAudioRoute];
    if (currentRoute == ROUTE_LOUDSPEAKER_TYPE)
    {
        [_routeButton setImage:[UIImage imageNamed:@"voice_headphonebt_normal"] forState:UIControlStateNormal];
    } else {
        [_routeButton setImage:[UIImage imageNamed:@"voice_call_speaker_normal"] forState:UIControlStateNormal];
    }
}

- (IBAction)closeCallButtonAction:(id)sender
{
    [self respondsDelegateWithType:CLOSE_CALL_BUTTON];
}

-(void) changeLastCameraRotationWhenFrontIndex
{
    if (_cameraFaceingIndex == LocalCameraFront && _lastCameraRotationWhenFrontIndex != _cameraRotation)
    {
        _lastCameraRotationWhenFrontIndex = _cameraRotation;
    }
}

- (IBAction)dialNumberButtonAction:(id)sender
{
    if ([DialSecondPlate shareInstance].isShow)
    {
        [[DialSecondPlate shareInstance] hideView];
        return;
    }
    [self respondsDelegateWithType:DIAL_NUMBER_BUTTON];
}

- (IBAction)changeCallTypeButtonAction:(id)sender
{
    [self respondsDelegateWithType:CHANGE_CALL_TYPE_BUTTON];
}

- (IBAction)holdButtonAction:(id)sender
{
    [self respondsDelegateWithType:HOLD_BUTTON];
}
- (IBAction)transferButtonAction:(id)sender
{
    [self respondsDelegateWithType:TRANSFER_BUTTON];
}
- (IBAction)muteMicButtonAction:(id)sender
{
    [self respondsDelegateWithType:MUTE_MIC_BUTTON];
}

- (IBAction)switchCameraButtonAction:(id)sender
{
    [self respondsDelegateWithType:SWITCH_CAMERA_BUTTON];
}

- (IBAction)closeCameraButtonAction:(id)sender
{
    [self respondsDelegateWithType:CLOSE_CAMERA_BUTTON];
}

- (IBAction)routeButtonAction:(id)sender
{
    [self respondsDelegateWithType:ROUTE_BUTTON];
}

-(void)respondsDelegateWithType:(CALL_TOOLBAR_BUTTON_TYPE)type
{
    if ([_delegate respondsToSelector:@selector(clickCallToolBarType:callViewTag:)])
    {
        [_delegate clickCallToolBarType:type callViewTag:self.tag];
    }
}

-(void)setIsCameraClose:(BOOL)isCameraClose
{
    _isCameraClose = isCameraClose;
}


-(void)setIsMuteMic:(BOOL)isMuteMic
{
    _isMuteMic = isMuteMic;
    if (isMuteMic) {
        [_muteMicButton setImage:[UIImage imageNamed:@"voice_call_mute_hold"] forState:UIControlStateNormal];
    }
    else {
        [_muteMicButton setImage:[UIImage imageNamed:@"voice_call_mute_normal"] forState:UIControlStateNormal];
    }
}

-(void)setIsHold:(BOOL)isHold
{
    _isHold = isHold;
    if (isHold) {
        [_holdButton setImage:[UIImage imageNamed:@"voice_call_resume_normal"] forState:UIControlStateNormal];
    }
    else {
        [_holdButton setImage:[UIImage imageNamed:@"voice_call_hold_normal"] forState:UIControlStateNormal];
    }
}

@end
