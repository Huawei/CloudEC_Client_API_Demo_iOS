//
//  ECSDKProgressHud.m
//  EC_SDK_DEMO
//
//  Created by huawei on 2019/8/23.
//  Copyright © 2019年 cWX160907. All rights reserved.
//

#import "ECSDKProgressHud.h"

static int changeCount;

@implementation ProgressLabel

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.layer.cornerRadius = 8;
        self.layer.masksToBounds = YES;
        self.backgroundColor = [UIColor blackColor];
        self.numberOfLines = 0;
        self.textAlignment = NSTextAlignmentCenter;
        self.textColor = [UIColor whiteColor];
        self.font = [UIFont systemFontOfSize:15];
    }
    return self;
}

- (void)setMessageText:(NSString *)text
{
    [self setText:text];
    
    CGRect rect = [self.text boundingRectWithSize:CGSizeMake([UIScreen mainScreen].bounds.size.width - 20, MAXFLOAT)
                                          options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading
                                       attributes:@{NSFontAttributeName:self.font}
                                          context:nil];
    CGFloat width = rect.size.width + 20;
    CGFloat height = rect.size.height + 20;
    CGFloat x = ([UIScreen mainScreen].bounds.size.width - width)/2;
    CGFloat y = [UIScreen mainScreen].bounds.size.height - height - 59 ;
    
    self.frame = CGRectMake(x, y, width, height);
    
}

@end

@implementation ECSDKProgressHud

+ (instancetype)shareInstance
{
    static ECSDKProgressHud *progressHUD = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,^{
        progressHUD = [[ECSDKProgressHud alloc] init];
    });
    return progressHUD;
}

- (instancetype)init
{
        self = [super init];
        if (self) {
            progressLabel = [[ProgressLabel alloc] init];
            countTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(changeTime) userInfo:nil repeats:YES];
            countTimer.fireDate = [NSDate distantFuture];
        }
    return self;
}

- (void)makeProgressHUD:(NSString *)message duration:(CGFloat)duration
{
    if ([message length] == 0) {
        return;
    }
    
    [progressLabel setMessageText:message];
    
    [[[UIApplication sharedApplication] keyWindow] addSubview:progressLabel];
    
    progressLabel.alpha = 0.8;
    countTimer.fireDate = [NSDate distantPast];
    
    changeCount = duration;
}

- (void)changeTime
{
    if (changeCount-- <= 0) {
        countTimer.fireDate = [NSDate distantFuture];
        [UIView animateWithDuration:0.2f animations:^{
            progressLabel.alpha = 0;
        } completion:^(BOOL finished) {
            [progressLabel removeFromSuperview];
        }];
    }
}


@end
