//
//  MarkupToolOptionsPopoverView.h
//  MarkupView
//
//  Created by Eric on 2018/10/16.
//  Copyright © 2018年 Eric. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,ECMarkupToolboxPopoverViewArrowType) {
    ECMarkupToolboxPopoverViewArrowTypeUp,
    ECMarkupToolboxPopoverViewArrowTypeDown
};

@class ECMarkupToolboxPopoverView;

@protocol ECMarkupToolboxPopoverViewDelegate <NSObject>

- (void)markupToolboxPopoverView:(ECMarkupToolboxPopoverView *)popoverView didSelectOptionAtIndex:(NSInteger)index;

@end

@interface ECMarkupToolboxPopoverView : UIView

@property (nonatomic, weak) id <ECMarkupToolboxPopoverViewDelegate> delegate;
@property (nonatomic,assign)ECMarkupToolboxPopoverViewArrowType arrowType;
- (instancetype)initWithFrame:(CGRect)frame data:(NSArray<NSString *> *)data images:(NSArray<UIImage *> *)images arrowType:(ECMarkupToolboxPopoverViewArrowType)arrowType;

@end
