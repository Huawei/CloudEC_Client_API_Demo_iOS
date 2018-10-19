//
//  DialSecondPlate.m
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//


#import "DialSecondPlate.h"

@interface DialSecondPlate()
{
    BOOL _isShow;
}
@property (weak, nonatomic)IBOutlet UILabel *dialLabel;
@end

@implementation DialSecondPlate

+(instancetype)shareInstance
{
    static DialSecondPlate *_dialSecondPlateView = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _dialSecondPlateView = [[DialSecondPlate alloc] init];
    });
    return _dialSecondPlateView;
}

-(instancetype)init
{
    if (self = [super init])
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"DialSecondPlate" owner:self options:nil];
        self = [nib objectAtIndex:0];
        _isShow = NO;
    }
    return self;
}

-(void)showViewInSuperView:(UIView *)superView Delegate:(id)delegate
{
    _isShow = YES;
    _dialLabel.text = @"";
    self.delegate = delegate;
    self.bounds = CGRectMake(0, 0,240,300);
    self.center = CGPointMake(superView.bounds.size.width/2, superView.bounds.size.height/2);
    [superView addSubview:self];
}

-(void)hideView
{
    [self removeFromSuperview];
    _isShow = NO;
}

-(BOOL)isShow
{
    return _isShow;
}

- (IBAction)dialBtnClicked:(id)sender
{
    UIButton *button = sender;
    _dialLabel.text = [_dialLabel.text stringByAppendingString:button.titleLabel.text];
    [self respondsDelegateWithButtonTitle:button.titleLabel.text];
}

-(void)respondsDelegateWithButtonTitle:(NSString *)buttonTitle
{
    if ([_delegate respondsToSelector:@selector(clickDialSecondPlate:)])
    {
        [_delegate clickDialSecondPlate:buttonTitle];
    }
}

@end
