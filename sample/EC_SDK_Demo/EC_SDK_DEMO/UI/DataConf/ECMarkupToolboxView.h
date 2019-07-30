//
//  MarkupToolboxView.h
//  MarkupView
//
//  Created by Eric on 2018/10/16.
//  Copyright © 2018年 Eric. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, MarkupToolboxViewSelectedColor) {
    MarkupToolboxViewSelectedColorBlack,
    MarkupToolboxViewSelectedColorRed,
    MarkupToolboxViewSelectedColorGreen,
    MarkupToolboxViewSelectedColorBlue
};

@class ECMarkupToolboxView;

@protocol ECMarkupToolboxViewDelegate <NSObject>

- (void)didSelectCloseMarkupToolboxView:(ECMarkupToolboxView *)toolboxView;
- (void)didSelectColorSelectionOnMarkupToolboxView:(ECMarkupToolboxView *)toolboxView;
- (void)didSelectPencilToolOnMarkupToolboxView:(ECMarkupToolboxView *)toolboxView;
- (void)didSelectEraserToolOnMarkupToolboxView:(ECMarkupToolboxView *)toolboxView;
- (void)didSelectClearOnMarkupToolboxView:(ECMarkupToolboxView *)toolboxView;

@end

@interface ECMarkupToolboxView : UIView

@property (nonatomic, assign) MarkupToolboxViewSelectedColor selectedColor;
@property (nonatomic, weak) id <ECMarkupToolboxViewDelegate> delegate;


- (void)setSelectionOnButtonAtIndex:(NSInteger)index;

- (void)clearColorWithIndex:(NSInteger)index;

@end
