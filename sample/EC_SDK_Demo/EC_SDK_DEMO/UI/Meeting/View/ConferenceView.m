/*
 * Copyright 2015 Huawei Technologies Co., Ltd. All rights reserved.
 * eSDK is licensed under the Apache License, Version 2.0 ^(the "License"^);
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *      http://www.apache.org/licenses/LICENSE-2.0
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "ConferenceView.h"
#import "EAGLView.h"
#import "TUPService.h"
#import "IMView.h"



#define DEFAULT_COLOR [UIColor colorWithRed:24/255.0 green:68/255.0 blue:126/255.0 alpha:1]
@interface ConferenceView()<IMViewDelegate>


@property (assign, nonatomic) BOOL isForceHideShareImageView;
@property (assign, nonatomic) BOOL isTransformFrame;
@property (nonatomic)EAGLView *remoteView;
@property (nonatomic)EAGLView *locationView;
@end

@implementation ConferenceView

-(instancetype)init
{
    if (self = [super init])
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ConferenceView" owner:self options:nil];
        self = [nib objectAtIndex:0];
        _isForceHideShareImageView = NO;
        _shareImageView.hidden = YES;
        _moreMenuView.hidden = YES;
    }
    return self;
}

-(void)setIsEnterConf:(BOOL)isEnterConf
{
    _isEnterConf = isEnterConf;
    if (!isEnterConf)
    {
        _upgradeButton.enabled = NO;
        _listButton.enabled = NO;
        _moreButton.enabled = NO;
        [_upgradeButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        [_listButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        [_moreButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    }
    else
    {
        _upgradeButton.enabled = YES;
        _listButton.enabled = YES;
        _moreButton.enabled = YES;
        [_upgradeButton setTitleColor:DEFAULT_COLOR forState:UIControlStateNormal];
        [_listButton setTitleColor:DEFAULT_COLOR  forState:UIControlStateNormal];
        [_moreButton setTitleColor:DEFAULT_COLOR  forState:UIControlStateNormal];
    }
}

-(void)setIsDataConf:(BOOL)isDataConf
{
    _isDataConf = isDataConf;
    if (isDataConf)
    {
        _speakerLabel.hidden = YES;
        _upgradeButton.enabled = NO;
        _listButton.enabled = YES;
        _moreButton.enabled = YES;
        [_upgradeButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [_listButton setTitleColor:DEFAULT_COLOR forState:UIControlStateNormal];
        [_moreButton setTitleColor:DEFAULT_COLOR forState:UIControlStateNormal];
    }
    else
    {
        _speakerLabel.hidden = NO;
        _upgradeButton.enabled = YES;
        _listButton.enabled = YES;
        _moreButton.enabled = NO;
        [_upgradeButton setTitleColor:DEFAULT_COLOR forState:UIControlStateNormal];
        [_listButton setTitleColor:DEFAULT_COLOR  forState:UIControlStateNormal];
        [_moreButton setTitleColor:[UIColor grayColor]  forState:UIControlStateNormal];
    }
}
-(void)showDesktopShareView:(UIImage *)shareData
{
    _shareImageView.image = shareData;
    if (_isForceHideShareImageView)
    {
        _shareImageView.hidden = YES;
        return;
    }
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        if (!_isTransformFrame)
        {
            _shareImageView.transform = CGAffineTransformMakeRotation(M_PI/2);
            _shareImageView.bounds = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width);
        }
    }
    _isTransformFrame = YES;
    _shareImageView.hidden = NO;
}


-(void)selfCallbackShowDeaktopShareView
{
    _shareImageView.hidden = NO;
}

-(void)hideDesktopShareView
{
    _shareImageView.hidden = YES;
    _isForceHideShareImageView = NO;
    _moreMenuView.hidden = YES;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        if (_isTransformFrame)
        {
            _shareImageView.transform = CGAffineTransformMakeRotation(M_PI/2 + M_PI/2 + M_PI/2 + M_PI/2);
            _shareImageView.bounds = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
        }
    }
    _isTransformFrame = NO;
}

-(void)selfCallbackHideDeaktopShareView
{
    _shareImageView.hidden = YES;
}


- (IBAction)closeCallButtonAction:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(clickConferenceToolBarType:)])
    {
        [_delegate clickConferenceToolBarType:CONF_END_BUTTON];
    }
}


-(void)hideVideoCallView
{
    if (_remoteView)
    {
        [_remoteView removeFromSuperview];
        _remoteView = nil;
    }
    if (_locationView)
    {
        [_locationView removeFromSuperview];
        _locationView = nil;
    }
    
}
- (IBAction)showShareButtonAction:(id)sender
{
    dispatch_async(dispatch_get_main_queue(), ^{
        _isForceHideShareImageView = NO;
        [self selfCallbackShowDeaktopShareView];
    });
}

- (IBAction)hideShareButtonAction:(id)sender
{
    dispatch_async(dispatch_get_main_queue(), ^{
        _isForceHideShareImageView = YES;
        [self selfCallbackHideDeaktopShareView];
    });
}


- (IBAction)dialNumberButtonAction:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(clickConferenceToolBarType:)])
    {
        [_delegate clickConferenceToolBarType:CONF_DIAL_NUMBER_BUTTON];
    }
}


- (IBAction)moreButtonAction:(id)sender
{
    if (_moreMenuView.hidden )
    {
        _moreMenuView.hidden = NO;
    }
    else
    {
        _moreMenuView.hidden = YES;
    }
}

- (IBAction)siteListButtonAction:(id)sender
{
    if ([_delegate respondsToSelector:@selector(clickConferenceToolBarType:)])
    {
        [_delegate clickConferenceToolBarType:CONF_SITE_LIST_BUTTON];
    }
}

- (IBAction)upgradeButtonAction:(id)sender
{
    if ([_delegate respondsToSelector:@selector(clickConferenceToolBarType:)])
    {
        [_delegate clickConferenceToolBarType:CONF_UPGRADE_BUTTON];
    }
}
- (IBAction)secondPlateButtonAction:(id)sender
{
    if ([_delegate respondsToSelector:@selector(clickConferenceToolBarType:)])
    {
        [_delegate clickConferenceToolBarType:CONF_DIAL_NUMBER_BUTTON];
    }
}



@end
