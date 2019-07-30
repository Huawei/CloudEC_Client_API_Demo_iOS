//
//  MarkupToolboxView.m
//  MarkupView
//
//  Created by Eric on 2018/10/16.
//  Copyright © 2018年 Eric. All rights reserved.
//

#import "ECMarkupToolboxView.h"
#import "UIButton+VerticalLayout.h"
#import "Utils.h"

#define TOOLBOX_BACKGROUND_COLOR [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5]
#define BUTTON_SELECTED_BACKGROUND_COLOR [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.1]

@interface ECMarkupToolboxView ()

@property (nonatomic, weak) UIButton *closeToolboxButton;
@property (nonatomic, weak) UIButton *colorSelectorButton;
@property (nonatomic, weak) UIButton *pencilButton;
@property (nonatomic, weak) UIButton *eraserButoon;
@property (nonatomic, weak) UIButton *clearButton;
@property (nonatomic, strong)UIView *containerView;

@end

@implementation ECMarkupToolboxView

#pragma mark - view's lifecycle methods
- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}


- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        _selectedColor = MarkupToolboxViewSelectedColorRed;
        
        CGFloat buttonWidth = CGRectGetWidth(frame) / 5;
        CGFloat frameHeight = CGRectGetHeight(frame);
        
        CGFloat toolboxViewWith=kMainScreenWidth>kMainScreenHeight? kMainScreenHeight:kMainScreenWidth;
        CGFloat scale=toolboxViewWith/375;
        self.backgroundColor = [UIColor clearColor];
        self.containerView=[[UIView alloc] initWithFrame:CGRectMake(10*scale, 0, buttonWidth*4, frameHeight)];
        self.containerView.backgroundColor=TOOLBOX_BACKGROUND_COLOR;
        self.containerView.layer.masksToBounds=YES;
        self.containerView.layer.cornerRadius=frameHeight/2;
        [self addSubview:self.containerView];
        
        UIImage *colorSelectorButtonImage = [UIImage imageNamed:@"float_anno_color_red"];
        UIButton *colorSelectorButton = [UIButton buttonWithType:UIButtonTypeCustom];
        colorSelectorButton.frame = CGRectMake(0.0, 0.0, buttonWidth, frameHeight);
        [colorSelectorButton addTarget:self action:@selector(didPressColorSelectionButton:) forControlEvents:UIControlEventTouchUpInside];
        [colorSelectorButton setImage:colorSelectorButtonImage forState:UIControlStateNormal];
        colorSelectorButton.adjustsImageWhenHighlighted = NO;
        [colorSelectorButton setTitle:@"Color" forState:UIControlStateNormal];
        colorSelectorButton.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:10];
        [colorSelectorButton centerVerticallyWithPadding:1.0];
        [self.containerView addSubview:colorSelectorButton];
        _colorSelectorButton = colorSelectorButton;
        
        UIImage *pencilButtonImage = [UIImage imageNamed:@"markup_pencil_red"];
        UIButton *pencilButton = [UIButton buttonWithType:UIButtonTypeCustom];
        pencilButton.frame = CGRectMake(buttonWidth, 0.0, buttonWidth, frameHeight);
        [pencilButton addTarget:self action:@selector(didPressPencilButton:) forControlEvents:UIControlEventTouchUpInside];
        pencilButton.backgroundColor = BUTTON_SELECTED_BACKGROUND_COLOR;
        [pencilButton setImage:pencilButtonImage forState:UIControlStateNormal];
        pencilButton.adjustsImageWhenHighlighted = NO;
        [pencilButton setTitle:@"Pen" forState:UIControlStateNormal];
        pencilButton.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:10];
        [pencilButton centerVerticallyWithPadding:1.0];
        [self.containerView addSubview:pencilButton];
        _pencilButton = pencilButton;
        
        UIImage *eraserButtonImage = [UIImage imageNamed:@"markup_eraser"];
        UIButton *eraserButton = [UIButton buttonWithType:UIButtonTypeCustom];
        eraserButton.frame = CGRectMake(buttonWidth * 2, 0.0, buttonWidth, frameHeight);
        [eraserButton addTarget:self action:@selector(didPressEraserButton:) forControlEvents:UIControlEventTouchUpInside];
        [eraserButton setImage:eraserButtonImage forState:UIControlStateNormal];
        [eraserButton setTitle:@"Erase" forState:UIControlStateNormal];
        eraserButton.adjustsImageWhenHighlighted = NO;
        eraserButton.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:10];
        [eraserButton centerVerticallyWithPadding:1.0];
        [self.containerView addSubview:eraserButton];
        _eraserButoon = eraserButton;
        
        UIImage *clearButtonImage = [UIImage imageNamed:@"markup_clear"];
        UIButton *clearButton = [UIButton buttonWithType:UIButtonTypeCustom];
        clearButton.frame = CGRectMake(buttonWidth * 3, 0.0, buttonWidth, frameHeight);
        [clearButton addTarget:self action:@selector(didPressClearButton:) forControlEvents:UIControlEventTouchUpInside];
        [clearButton setImage:clearButtonImage forState:UIControlStateNormal];
        eraserButton.adjustsImageWhenHighlighted = NO;
        [clearButton setTitle:@"Clear" forState:UIControlStateNormal];
        clearButton.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:10];
        [clearButton centerVerticallyWithPadding:1.0];
        [self.containerView addSubview:clearButton];
        _clearButton = clearButton;
        
        UIImage *closeButtonImage = [UIImage imageNamed:@"markup_close"];
        UIButton *closeToolboxButton = [UIButton buttonWithType:UIButtonTypeCustom];
        closeToolboxButton.frame = CGRectMake(buttonWidth * 4 + 17*scale, 0.0, frameHeight, frameHeight);
        [closeToolboxButton setBackgroundColor:TOOLBOX_BACKGROUND_COLOR];
        [closeToolboxButton addTarget:self action:@selector(closeToolbox:) forControlEvents:UIControlEventTouchUpInside];
        [closeToolboxButton setImage:closeButtonImage forState:UIControlStateNormal];
        closeToolboxButton.adjustsImageWhenHighlighted = NO;
        //closeToolboxButton setTitle:@"退出" forState:UIControlStateNormal];
        //closeToolboxButton.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:10];
        //[closeToolboxButton centerVerticallyWithPadding:1.0];
        closeToolboxButton.layer.masksToBounds=YES;
        closeToolboxButton.layer.cornerRadius=frameHeight/2;
        [self addSubview:closeToolboxButton];
        _closeToolboxButton = closeToolboxButton;
    }
    
    return self;
}

#pragma mark - setters
- (void)setSelectedColor:(MarkupToolboxViewSelectedColor)selectedColor {
    _selectedColor = selectedColor;
    
    UIImage *colorSelectorButtonImage;
    UIImage *pencilButtonImage;
    
    switch (selectedColor) {
        case MarkupToolboxViewSelectedColorBlack:
            colorSelectorButtonImage = [UIImage imageNamed:@"float_anno_color_black"];
            pencilButtonImage = [UIImage imageNamed:@"markup_pencil_black"];
            break;
        case MarkupToolboxViewSelectedColorRed:
            colorSelectorButtonImage = [UIImage imageNamed:@"float_anno_color_red"];
            pencilButtonImage = [UIImage imageNamed:@"markup_pencil_red"];
            break;
        case MarkupToolboxViewSelectedColorGreen:
            colorSelectorButtonImage = [UIImage imageNamed:@"float_anno_color_green"];
            pencilButtonImage = [UIImage imageNamed:@"markup_pencil_green"];
            break;
        case MarkupToolboxViewSelectedColorBlue:
            colorSelectorButtonImage = [UIImage imageNamed:@"float_anno_color_blue"];
            pencilButtonImage = [UIImage imageNamed:@"markup_pencil_blue"];
            break;
    }
    
    [self.colorSelectorButton setImage:colorSelectorButtonImage forState:UIControlStateNormal];
    [self.pencilButton setImage:pencilButtonImage forState:UIControlStateNormal];
}


- (void)setButtonBackgroundColorWithIndex:(NSInteger)index color:(UIColor *)color{
    switch (index) {
        case 1:
            self.colorSelectorButton.backgroundColor = color;
            break;
        case 2:
            self.pencilButton.backgroundColor = color;
            break;
        case 3:
            self.eraserButoon.backgroundColor = color;
            break;
        default:
            break;
    }
    
}

#pragma mark - action methods
- (void)closeToolbox:(id)sender {
   
    if ([self.delegate respondsToSelector:@selector(didSelectCloseMarkupToolboxView:)]) {
        [self.delegate didSelectCloseMarkupToolboxView:self];
    }
}


- (void)didPressColorSelectionButton:(id)sender {
    if ([self.delegate respondsToSelector:@selector(didSelectColorSelectionOnMarkupToolboxView:)]) {
        self.colorSelectorButton.backgroundColor = BUTTON_SELECTED_BACKGROUND_COLOR;
        [self.delegate didSelectColorSelectionOnMarkupToolboxView:self];
    }
    
}


- (void)didPressPencilButton:(id)sender {
    if ([self.delegate respondsToSelector:@selector(didSelectPencilToolOnMarkupToolboxView:)]) {
       [self.delegate didSelectPencilToolOnMarkupToolboxView:self];
        self.pencilButton.backgroundColor = BUTTON_SELECTED_BACKGROUND_COLOR;
        self.eraserButoon.backgroundColor = [UIColor clearColor];
        self.colorSelectorButton.backgroundColor = [UIColor clearColor];
    }
}


- (void)didPressEraserButton:(id)sender {
    
    if ([self.delegate respondsToSelector:@selector(didSelectEraserToolOnMarkupToolboxView:)]) {
       [self.delegate didSelectEraserToolOnMarkupToolboxView:self];
        self.eraserButoon.backgroundColor = BUTTON_SELECTED_BACKGROUND_COLOR;
        self.pencilButton.backgroundColor = [UIColor clearColor];
        self.colorSelectorButton.backgroundColor = [UIColor clearColor];
    }
    

}


- (void)didPressClearButton:(id)sender {
    if ([self.delegate respondsToSelector:@selector(didSelectClearOnMarkupToolboxView:)]) {
        [self.delegate didSelectClearOnMarkupToolboxView:self];
    }
}



#pragma mark - member methods



- (void)setSelectionOnButtonAtIndex:(NSInteger)index {
    self.colorSelectorButton.backgroundColor = [UIColor clearColor];
    self.pencilButton.backgroundColor = [UIColor clearColor];
    self.eraserButoon.backgroundColor = [UIColor clearColor];
    [self setButtonBackgroundColorWithIndex:index color:BUTTON_SELECTED_BACKGROUND_COLOR];
}


- (void)clearColorWithIndex:(NSInteger)index {
    [self setButtonBackgroundColorWithIndex:index color:[UIColor clearColor]];
}

@end
