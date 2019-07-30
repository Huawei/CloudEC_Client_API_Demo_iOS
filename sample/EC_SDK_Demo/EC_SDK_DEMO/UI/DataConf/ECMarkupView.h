//
//  ECMarkupView.h
//  WeLink
//
//  Created by Eric on 2018/10/15.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, MarkupViewMode) {
    MarkupViewModeDrawing,
    MarkupViewModeEraser
};

@class ECMarkupView;

@protocol ECMarkupViewDelegate <NSObject>

@optional
- (void)touchBeganOnMarkupView:(ECMarkupView *)markupView atLocation:(CGPoint)location;
- (void)touchMovedOnMarkupView:(ECMarkupView *)markupView atLocation:(CGPoint)location;
- (void)touchEndedOnMarkupView:(ECMarkupView *)markupView atLocation:(CGPoint)location;
- (void)touchCanceledOnMarkupView:(ECMarkupView *)markupView atLocation:(CGPoint)location;

@end

@interface ECMarkupView : UIView

@property (nonatomic, assign) MarkupViewMode mode;
@property (nonatomic, weak) id <ECMarkupViewDelegate> delegate;

@end
