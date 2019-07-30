//
//  ECMarkupView.m
//  WeLink
//
//  Created by Eric on 2018/10/15.
//

#import "ECMarkupView.h"

@implementation ECMarkupView

#pragma mark - view's lifecycle
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        _mode = MarkupViewModeDrawing;
    }
    
    return self;
}


#pragma mark - touch methods
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:self];
    
    if ([self.delegate respondsToSelector:@selector(touchBeganOnMarkupView:atLocation:)]) {
        [self.delegate touchBeganOnMarkupView:self atLocation:location];
    }
}


- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:self];
    
    if ([self.delegate respondsToSelector:@selector(touchMovedOnMarkupView:atLocation:)]) {
        [self.delegate touchMovedOnMarkupView:self atLocation:location];
    }
}


- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:self];
    
    if ([self.delegate respondsToSelector:@selector(touchEndedOnMarkupView:atLocation:)]) {
        [self.delegate touchEndedOnMarkupView:self atLocation:location];
    }
}


- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:self];
    
    if ([self.delegate respondsToSelector:@selector(touchCanceledOnMarkupView:atLocation:)]) {
        [self.delegate touchCanceledOnMarkupView:self atLocation:location];
    }
}

@end

