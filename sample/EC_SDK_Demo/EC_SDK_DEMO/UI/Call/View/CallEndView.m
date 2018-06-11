//
//  CallEndView.m
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

#import "CallEndView.h"
#import "ManagerService.h"

@interface CallEndView()
@end

@implementation CallEndView

+(instancetype)shareInstance
{
    static CallEndView *_callEndView = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _callEndView = [[CallEndView alloc] init];
    });
    return _callEndView;
}

-(instancetype)init
{
    if (self = [super init])
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"CallEndView" owner:self options:nil];
        self = [nib objectAtIndex:0];
    }
    return self;
}

-(void)showCallEndViewInUIView:(UIView *)superView
{
    self.center = CGPointMake([UIScreen mainScreen].bounds.size.width/2, [UIScreen mainScreen].bounds.size.height/2);
    self.bounds = CGRectMake(0, 0,258,154);
    [superView addSubview:self];
}
- (IBAction)transferButtonAction:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(transferButtonAction)])
    {
        [self.delegate transferButtonAction];
    }
}

- (IBAction)closeCallButtonAction:(id)sender
{
    [[ManagerService callService] closeCall:self.callId];
    [self removeFromSuperview];
}

-(void)removeCallEndView
{
    [self removeFromSuperview];
}

@end
