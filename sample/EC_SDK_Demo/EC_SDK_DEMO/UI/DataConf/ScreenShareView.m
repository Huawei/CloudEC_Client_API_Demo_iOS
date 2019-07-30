#import "ScreenShareView.h"
#import "Utils.h"

static ScreenShareView *instance = nil;

@interface ScreenShareView ()

@property(nonatomic, strong) UILabel *shareLableMsg; // “您正在共享屏幕”
@property(nonatomic, strong) UIButton *stopBtn; // 停止共享

@end

@implementation ScreenShareView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initSubviews];
        [self autoLayoutViews];
    }
    
    return self;
}

// 停止共享点击事件
- (void)stopBtnClick
{
    if (self.screenShareViewDelegate && [self.screenShareViewDelegate respondsToSelector:@selector(onClickStopShare)]) {
        [self.screenShareViewDelegate onClickStopShare];
    }
}

- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer
{
    if (self.screenShareViewDelegate && [self.screenShareViewDelegate respondsToSelector:@selector(shareViewSingleTapGesture)])
    {
        [self.screenShareViewDelegate shareViewSingleTapGesture];
    }
}

- (void)initSubviews
{
    self.backgroundColor = [UIColor whiteColor];
    
    _shareLableMsg = [[UILabel alloc] init];
    _shareLableMsg.text = @"You are sharing screen";
    _shareLableMsg.font = [UIFont systemFontOfSize:33.0];
    _shareLableMsg.textAlignment = NSTextAlignmentCenter;
    _shareLableMsg.adjustsFontSizeToFitWidth = YES;
    _shareLableMsg.textColor = UIColorFromHex(0x333333);
    _shareLableMsg.translatesAutoresizingMaskIntoConstraints = NO;
    
    _stopBtn = [[UIButton alloc] init];
    [_stopBtn setImage:[UIImage imageNamed:@"share_screen_stop"] forState:UIControlStateNormal];
    [_stopBtn setImage:[UIImage imageNamed:@"share_screen_stop"] forState:UIControlStateHighlighted];
    [_stopBtn addTarget:self action:@selector(stopBtnClick) forControlEvents:UIControlEventTouchUpInside];
    _stopBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [_stopBtn setTitle:@"stop share" forState:UIControlStateNormal];
    _stopBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
    _stopBtn.backgroundColor = [UIColor redColor];
    
    [self addSubview:_shareLableMsg];
    [self addSubview:_stopBtn];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    [self addGestureRecognizer:singleTap];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeOrientation) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeOrientation) name:ChangeScreenOrientationNotification object:nil];
}

- (void)autoLayoutViews
{
    //CGFloat width = [UIScreen mainScreen].bounds.size.width/375.0;
    CGFloat height = kMainScreenHeight/750.0;
    
    NSLayoutConstraint *constraint1 = [NSLayoutConstraint constraintWithItem:_shareLableMsg attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0];
    
    if (kMainScreenWidth > kMainScreenHeight) {
        NSLayoutConstraint *constraint2 = [NSLayoutConstraint constraintWithItem:_shareLableMsg attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:height * 240.0 * 0.5];
        NSLayoutConstraint *constraint3 = [NSLayoutConstraint constraintWithItem:_shareLableMsg attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeHeight multiplier:0.413 constant:0];
        NSLayoutConstraint *constraint4 = [NSLayoutConstraint constraintWithItem:_shareLableMsg attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:0.047 constant:0];
        [self addConstraints:@[constraint1, constraint2, constraint3, constraint4]];
    } else {
        NSLayoutConstraint *constraint2 = [NSLayoutConstraint constraintWithItem:_shareLableMsg attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:height * 240.0];
        NSLayoutConstraint *constraint3 = [NSLayoutConstraint constraintWithItem:_shareLableMsg attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:0.413 constant:0];
        NSLayoutConstraint *constraint4 = [NSLayoutConstraint constraintWithItem:_shareLableMsg attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeHeight multiplier:0.047 constant:0];
        [self addConstraints:@[constraint1, constraint2, constraint3, constraint4]];
    }
    
    NSLayoutConstraint *btnConstraint1 = [NSLayoutConstraint constraintWithItem:_stopBtn attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0];
    if (kMainScreenWidth > kMainScreenHeight) {
        NSLayoutConstraint *btnConstraint2 = [NSLayoutConstraint constraintWithItem:_stopBtn attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-238.0 * 0.5 * height];
        NSLayoutConstraint *btnConstraint3 = [NSLayoutConstraint constraintWithItem:_stopBtn attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeHeight multiplier:0.173 constant:0];
        NSLayoutConstraint *btnConstraint4 = [NSLayoutConstraint constraintWithItem:_stopBtn attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeHeight multiplier:0.173 constant:-10];
        [self addConstraints:@[btnConstraint1, btnConstraint2, btnConstraint3, btnConstraint4]];
    } else {
        NSLayoutConstraint *btnConstraint4 = [NSLayoutConstraint constraintWithItem:_stopBtn attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-238.0 * height];
        NSLayoutConstraint *btnConstraint2 = [NSLayoutConstraint constraintWithItem:_stopBtn attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:0.173 constant:0];
        NSLayoutConstraint *btnConstraint3 = [NSLayoutConstraint constraintWithItem:_stopBtn attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:0.173 constant:-10];
        [self addConstraints:@[btnConstraint1, btnConstraint2, btnConstraint3, btnConstraint4]];
        
    }
    
    [_stopBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, _stopBtn.frame.size.height-_stopBtn.imageView.frame.size.height, -_stopBtn.titleLabel.intrinsicContentSize.width)];
    [_stopBtn setTitleEdgeInsets:UIEdgeInsetsMake(_stopBtn.frame.size.height/2, -_stopBtn.currentImage.size.width, 0, 0)];
}

- (void)changeOrientation
{
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.frame = CGRectMake(0, 0, kMainScreenWidth, kMainScreenHeight);
    [self removeConstraints:self.constraints];
    [self autoLayoutViews];
}

@end





