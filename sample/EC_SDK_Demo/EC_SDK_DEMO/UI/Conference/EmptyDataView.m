//
//  EmptyDataView.m
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

#import "EmptyDataView.h"
#import "NSString+SizeWithFont.h"
//#import "ESpaceUtile.h"
#import "UIImage+Stretchable.h"
//#import "UIImage+GIF.h"

#define ECS_ED_LBL_FONT             [UIFont systemFontOfSize:16.0]
#define ECS_ED_LBL_EDGE_PADDING     30.0
#define ECS_ED_IMG_LBL_PADDING      15.0
#define ECS_ED_LBL_BTN_PADDING      24.0
#define ECS_ED_BTN_HEIGHT           40.0
#define ECS_ED_BTN_WIDTH            240.0

#define UIViewGetWidth(view)    CGRectGetWidth(view.bounds)
#define UIViewGetHeight(view)   CGRectGetHeight(view.bounds)
#define UIViewGetMidX(view)     CGRectGetMidX(view.frame)
#define UIViewGetMidY(view)     CGRectGetMidY(view.frame)

#define UIViewGetMinX(view)     CGRectGetMinX(view.frame)
#define UIViewGetMinY(view)     CGRectGetMinY(view.frame)

#define UIViewGetMaxX(view)     CGRectGetMaxX(view.frame)
#define UIViewGetMaxY(view)     CGRectGetMaxY(view.frame)

@interface EmptyDataInfo : NSObject

@property (nonatomic, strong)   UIImage *icon;
@property (nonatomic, strong)   NSString *tips;
@property (nonatomic, strong)   NSString *title;
@property (nonatomic, weak)     id target;
@property (nonatomic, assign)   SEL selector;

@end

@implementation EmptyDataInfo

@end

@interface EmptyDataView ()

@property (nonatomic, assign) EmptyDataOption option;
@property (nonatomic, retain) UIImageView *noDataImgView;
@property (nonatomic, retain) UILabel *noDataLabel;
@property (nonatomic, retain) UIButton *actionBtn;

@end

@implementation EmptyDataView

- (instancetype)initWithOption:(EmptyDataOption)option {
	if (self = [super init]) {
		// Initialization code.
		self.backgroundColor = [UIColor clearColor];
        [self updateWithOption:option];
	}
	return self;
}

- (void)updateWithOption:(EmptyDataOption)option {
    if (_option == option) {
        return;
    }
    _option = option;
    
    EmptyDataInfo *info = [self emptyDataInfoWithOption:option];
    // Empty data icon.
    if (info.icon) {
        if (!_noDataImgView) {
            _noDataImgView  = [[UIImageView alloc] initWithFrame:CGRectZero];
            [self addSubview:_noDataImgView];
        }
        _noDataImgView.image = info.icon;
    } else {
        [_noDataImgView removeFromSuperview];
        _noDataImgView = nil;
    }
    
    // Empty data tips.
    if (info.tips.length != 0) {
        if (!_noDataLabel) {
            _noDataLabel = [[UILabel alloc] initWithFrame:CGRectZero];
            _noDataLabel.numberOfLines = 0;
            _noDataLabel.font = ECS_ED_LBL_FONT;
            _noDataLabel.textColor = [UIColor colorWithRed:153.0 / 255 green:153.0 / 255 blue:153.0 / 255 alpha:1];
            _noDataLabel.textAlignment = NSTextAlignmentCenter;
            [self addSubview:_noDataLabel];
        }
        _noDataLabel.text = info.tips;
    } else {
        [_noDataLabel removeFromSuperview];
        _noDataLabel = nil;
    }
    
    // Action button.
    //		if (title != nil && target != nil && selector != nil) {
    if (info.title.length != 0) {
        if (!_actionBtn) {
            _actionBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [_actionBtn setFrame: CGRectMake(0, 0, ECS_ED_BTN_WIDTH, ECS_ED_BTN_HEIGHT)];
            [_actionBtn setBackgroundImage:UIStretchableImage(@"detial_apply_normal") forState:UIControlStateNormal];
            [_actionBtn setBackgroundImage:UIStretchableImage(@"detial_apply_click") forState:UIControlStateHighlighted];
            [_actionBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            _actionBtn.titleLabel.font = [UIFont systemFontOfSize:18];
            [self addSubview:_actionBtn];
        }
        [_actionBtn setTitle:info.title forState:UIControlStateNormal];
        if (info.target && info.selector) {
            [_actionBtn addTarget:info.target action:info.selector forControlEvents:UIControlEventTouchUpInside];
        }
        
    } else {
        [_actionBtn removeFromSuperview];
        _actionBtn = nil;
    }
    
    [self setNeedsLayout];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    UIView *parent = [self superview];
    if (parent) {
        [self adjustSizeToFitWidth:UIViewGetWidth(parent)];
        if (_noDataImgView) {
            [_noDataImgView sizeToFit];
            CGFloat scale = [UIScreen mainScreen].scale;
            if (scale == 2) {
                _noDataImgView.bounds = CGRectMake(0, 0, 175.0, 175.0);
            }
            
            _noDataImgView.center = CGPointMake(UIViewGetWidth(self) / 2.0,
                                                UIViewGetHeight(_noDataImgView) / 2.0);
            
        }
        if (_noDataLabel) {
            CGFloat maxY = _noDataImgView ? (UIViewGetMaxY(_noDataImgView) + ECS_ED_IMG_LBL_PADDING) : 0;
            _noDataLabel.center = CGPointMake(UIViewGetWidth(self) / 2.0,
                                              maxY + UIViewGetHeight(_noDataLabel) / 2.0);
        }
        
        if (_actionBtn) {
            _actionBtn.center = CGPointMake(UIViewGetWidth(self) / 2.0,
                                            UIViewGetMaxY(_noDataLabel) + ECS_ED_LBL_BTN_PADDING + UIViewGetHeight(_actionBtn) / 2.0);
        }
    }
}

- (void)updateNoDataIcon:(UIImage *)icon andTip:(NSString *)tip {
	self.noDataImgView.image = icon;
	self.noDataLabel.text = tip;
}

- (void)actionBtnHide:(BOOL)yesOrNO {
	self.actionBtn.hidden = yesOrNO;
}

- (void)adjustSizeToFitWidth:(CGFloat)width {
    CGFloat estimateHeight = 0;
    if (_noDataImgView) {
        CGFloat iconHeight =  _noDataImgView.image.size.height;
        estimateHeight += iconHeight;
    }
    
    if (_noDataLabel) {
        CGFloat tipWidth = width - ECS_ED_LBL_EDGE_PADDING * 2;
        CGFloat tipHight = [_noDataLabel.text sizeWithMyFont:[UIFont systemFontOfSize:17.0]
                                           constrainedToSize:CGSizeMake(tipWidth - ECS_ED_LBL_EDGE_PADDING * 2, MAXFLOAT)
                                               lineBreakMode:NSLineBreakByWordWrapping].height;
        _noDataLabel.bounds = CGRectMake(0, 0, tipWidth, tipHight);
        estimateHeight += (_noDataImgView ? ECS_ED_IMG_LBL_PADDING + tipHight : tipHight);
    }
    
    if (_actionBtn) {
        CGFloat actionBtnHeight = ECS_ED_BTN_HEIGHT;
        estimateHeight += (_noDataLabel ? ECS_ED_LBL_BTN_PADDING + actionBtnHeight : actionBtnHeight);
    }
    
    self.bounds = CGRectMake(0, 0, width, estimateHeight);
}

- (EmptyDataInfo *)emptyDataInfoWithOption:(EmptyDataOption)option {
    EmptyDataInfo *info = [[EmptyDataInfo alloc] init];
    switch (option) {
        case ESpaceEDONoConference:
            info.icon = [UIImage imageNamed:@"bg_no_conference"];
            info.tips = @"You do not have any meetings. Add some now";
            info.title = @"Create Meeting";
            info.target = self;
            info.selector = @selector(onEDVActionButtonPress:);
            break;
        default:
            break;
    }
    return info;
}

- (void)onEDVActionButtonPress:(id)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(eSpaceEmptyDataViewOnActionButtonPress:)]) {
        [_delegate eSpaceEmptyDataViewOnActionButtonPress:self];
    }
}

@end
