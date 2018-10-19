//
//  CallTipView.m
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

#import "CallTipView.h"

@interface CallTipView()

@end

@implementation CallTipView

+(instancetype)shareInstance
{
    static CallTipView *_callTipView = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _callTipView = [[CallTipView alloc] init];
    });
    return _callTipView;
}

-(void)showCommingCallTipViewInUIView:(UIView *)superView delegate:(id)delegate
{
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"CallTipView" owner:self options:nil];
    _commingView = [nib objectAtIndex:0];
    _commingView.delegate = delegate;
    _commingView.center = CGPointMake([UIScreen mainScreen].bounds.size.width/2, [UIScreen mainScreen].bounds.size.height/2);
    _commingView.bounds = CGRectMake(0, 0,376,280);
    [superView addSubview:_commingView];
}

-(void)removeCommingCallTipView
{
    if (_commingView)
    {
        [_commingView removeFromSuperview];
        _commingView = nil;
    }
}

- (IBAction)transferAcion:(id)sender {
    if ([self.delegate respondsToSelector:@selector(clickCommingTipViewButton:)])
    {
        [self.delegate clickCommingTipViewButton:TRANSFER_CALL];
    }
}

- (IBAction)audioAnswerAction:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(clickCommingTipViewButton:)])
    {
        [self.delegate clickCommingTipViewButton:AUDIO_ANSWER_COMMING_CALL];
    }
}

- (IBAction)videoAnswerAction:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(clickCommingTipViewButton:)])
    {
        [self.delegate clickCommingTipViewButton:VIDEO_ANSWER_COMMING_CALL];
    }
}

- (IBAction)refuseCommingCallAction:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(clickCommingTipViewButton:)])
    {
        [self.delegate clickCommingTipViewButton:REFUSE_COMMING_CALL];
    }
}

-(void)setCurrentCallType:(TUP_CALL_TYPE)currentCallType
{
    _currentCallType = currentCallType;
    if (currentCallType == CALL_AUDIO)
    {
        _videoAnswerCallBtn.hidden = YES;
        _commingCallTipLabel.text = @"Inviting you to a audio call";
    }
    else
    {
        _videoAnswerCallBtn.hidden = NO;
        _commingCallTipLabel.text = @"Inviting you to a video call";
    }
}

-(void)setCurrentConfType:(ConfType)currentConfType
{
    _currentConfType = currentConfType;
    if (currentConfType == AudioConfType)
    {
        _videoAnswerCallBtn.hidden = YES;
        _commingCallTipLabel.text = @"Inviting you to a audio conference";
    }
    else
    {
        _videoAnswerCallBtn.hidden = NO;
        _commingCallTipLabel.text = @"Inviting you to a video conference";
    }
}

@end
