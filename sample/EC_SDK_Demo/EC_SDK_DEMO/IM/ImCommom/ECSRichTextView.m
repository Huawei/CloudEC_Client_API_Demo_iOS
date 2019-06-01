//
//  ECSRichTextView.m
//  XCoreText
//
//  Created by yemingxing on 3/13/15.
//  Copyright (c) 2015 Dylan. All rights reserved.
//

#import "ECSRichTextView.h"
#import <CoreText/CoreText.h>

@interface ECSControl () {
@public
    NSRange range;
}
@property (nonatomic, weak) id target;
@property (nonatomic, assign) SEL action;
@end

@implementation ECSControl

- (void) addTarget:(id) target action:(SEL)action {
    self.target = target;
    self.action = action;
}

- (NSString *)description {
    if (self.text) {
        return self.text;
    } else {
        return @"";
    }
}
@end

@interface ECSTextLabel ()

@end

@implementation ECSTextLabel
#ifdef DEBUG
- (BOOL)isAccessibilityElement {
    return YES;
}

- (NSString*)accessibilityValue {
    return self.text;
}

#endif
@end

@interface ECSEmotion()
@property (nonatomic, assign) NSUInteger width;
@property (nonatomic, assign) NSUInteger height;
@property (nonatomic, assign) CGRect frame;
@end

@implementation ECSEmotion

@end

@interface ECSPlaceHolder () {
}

@property (nonatomic, assign) CGFloat position;
@property (nonatomic, strong) UIView* placeHolderView;
@property (nonatomic, assign) CGPoint origin;

@end

@implementation ECSPlaceHolder

- (UIView*) placeHolderView {
    if (!_placeHolderView) {
        _placeHolderView = [[UIView alloc] initWithFrame:CGRectZero];
        _placeHolderView.clipsToBounds = YES;
    }
    return _placeHolderView;
}

- (void)setView:(UIView *)view {
    if (_view == view) {
        return;
    }
    if (_view) {
        [_view removeFromSuperview];
    }
    _view = view;
    [self.placeHolderView addSubview:_view];
}

@end

static void deallocCallback(void* ref) {
    CFBridgingRelease(ref);
}

static CGFloat ascentCallback(void* ref) {
    ECSControl* control = (__bridge ECSControl *)(ref);
    if ([control isKindOfClass:[ECSEmotion class]]) {
        ECSEmotion* emotion = (ECSEmotion*) control;
        return emotion.height;
    } else if ([control isKindOfClass:[ECSPlaceHolder class]]) {
        ECSPlaceHolder* placeHolder = (ECSPlaceHolder*)control;
        return placeHolder.height;
    }
    return 0.0f;
}

static CGFloat descentCallback(void* ref) {
    return 0.0;
}

static CGFloat widthCallback(void* ref) {
    ECSControl* control = (__bridge ECSControl *)(ref);
    if ([control isKindOfClass:[ECSEmotion class]]) {
        ECSEmotion* emotion = (ECSEmotion*) control;
        return emotion.width;
    } else if ([control isKindOfClass:[ECSPlaceHolder class]]) {
        ECSPlaceHolder* placeHolder = (ECSPlaceHolder*)control;
        return placeHolder.width;
    }
    return 0.0f;
}

// typedef之后，Clang在ARC模式下就能把C指针对象，当成OC对象来处理了。
// 详见：http://clang.llvm.org/docs/AutomaticReferenceCounting.html#retainable-object-pointers
typedef __attribute__ ((NSObject)) CTFrameRef EspaceCTFrameRef;

@interface ECSRichTextView () <UIGestureRecognizerDelegate>{
    CGSize suggestedSize;
}

@property (nonatomic, strong) EspaceCTFrameRef frameRef ;
@property (nonatomic, strong) NSMutableAttributedString* attributeString;
@property (nonatomic, strong) NSArray* textLabels;
@property (nonatomic, strong) NSArray* emotions;
@property (nonatomic, strong) NSArray* placeHolders;
@property (nonatomic, weak) id defaultTarget;
@property (nonatomic, assign) SEL defaultAction;
@property (nonatomic, strong) UIColor* restoredBkgColor;
@end

@implementation ECSRichTextView

@synthesize controls = _controls;

#ifdef DEBUG
- (BOOL)isAccessibilityElement{
    return YES;
}

- (NSString*)accessibilityLabel{
    return self.accessibilityTextLabel.length > 0 ? self.accessibilityTextLabel : @"ECSRichTextView";
}

- (NSString*)accessibilityValue {
    
    return self.text.length > 0 ? self.text : self.accessibilityTextValue;
}
#endif

- (UIFont *)font {
    if (!_font) {
        _font = [UIFont systemFontOfSize:16.0];
    }
    return _font;
}

- (id) initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
        _longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
        self.backgroundColor = [UIColor clearColor];
        self.userInteractionEnabled = YES;
        self.contentMode = UIViewContentModeRedraw;
        [self addGestureRecognizer:_longPressGestureRecognizer];
        [self addGestureRecognizer:_tapGestureRecognizer];
        _longPressGestureRecognizer.enabled = NO;
        [_tapGestureRecognizer requireGestureRecognizerToFail:_longPressGestureRecognizer];
        _maxLineCount = -1;
        _tapGestureRecognizer.delegate = self;
        _longPressGestureRecognizer.delegate = self;
        _textAlignment = NSTextAlignmentNatural;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(restoreBackgroundColor:) name:UIMenuControllerDidHideMenuNotification object:nil];
    }
    return self;
}

- (void)setAllowCopy:(BOOL)allowCopy {
    if (allowCopy) {
        _longPressGestureRecognizer.enabled = YES;
    } else {
        _longPressGestureRecognizer.enabled = NO;
    }
    _allowCopy = allowCopy;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if (gestureRecognizer == _tapGestureRecognizer) {
        return self.touchEnabled;
    } else if (gestureRecognizer == _longPressGestureRecognizer) {
        return self.allowCopy;
    } else {
        return YES;
    }
}

//- (void)setFrameRef:(CTFrameRef)frameRef {
//    if (_frameRef) {
//        CFRelease(_frameRef);
//    }
//    _frameRef = frameRef;
//}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.frameRef = NULL;
}

- (void)setText:(NSString *)content {
    if (content == _text) return;
    _text = [content copy];
    _attributeString = nil;
    self.controls = nil;
    self.frameRef = NULL;
    for (UIView* subView in self.subviews) {
        [subView removeFromSuperview];
    }
    
    for (ECSControl* control in self.controls) {
        if ([control isKindOfClass:[ECSPlaceHolder class]]) {
            ECSPlaceHolder* placeHolder = (ECSPlaceHolder*) control;
            [self addSubview:placeHolder.placeHolderView];
        }
    }
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
}

- (void)sizeToFit {
    self.frame = CGRectZero;
}

- (void) createFrameRefWithWidth:(CGFloat) width{
    self.frameRef = NULL;
    CTFramesetterRef frameSetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef) self.attributeString);
    CGSize restrictSize = CGSizeMake(width, CGFLOAT_MAX);
    CGSize coreTextSize = CTFramesetterSuggestFrameSizeWithConstraints(frameSetter, CFRangeMake(0, 0), NULL, restrictSize, NULL);
    
    coreTextSize = CGSizeMake(ceilf(coreTextSize.width), ceilf(coreTextSize.height));
    
    self->suggestedSize = coreTextSize;
    
    CGRect sizeFits = CGRectMake(0, 0, width, coreTextSize.height);
    
    CGPathRef path = CGPathCreateWithRect(sizeFits, &CGAffineTransformIdentity);
    CTFrameRef newFrameRef = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, self.attributeString.length), path, NULL);
    self.frameRef = newFrameRef;
    if (frameSetter) {
        CFRelease(frameSetter);
    }
    
    if (path) {
        CGPathRelease(path);
    }
    
    if (newFrameRef) {
        CFRelease(newFrameRef);
    }
    
    [self layoutPlaceHolder];
}

-(void)longPress:(UIGestureRecognizer*)gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        self.backgroundColor = [UIColor lightGrayColor];
        [self becomeFirstResponder];
        [[UIMenuController sharedMenuController] setTargetRect:CGRectMake(0, 0, CGRectGetWidth(self.bounds), 0) inView:self];
        [[UIMenuController sharedMenuController] setMenuVisible:YES animated:YES];
    }
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    if (action == @selector(copy:)) {
        return YES;
    }
    return NO;
}

- (void) restoreBackgroundColor:(NSNotification*) notifi {
    self.backgroundColor = [UIColor clearColor];
}

- (BOOL) canBecomeFirstResponder {
    return self.allowCopy;
}

- (void) copy:(id) sender {
    UIPasteboard *pBoard = [UIPasteboard generalPasteboard];
    NSString* text = self.text;
    if (!text) {
        text = [self.controls componentsJoinedByString:@""];
    }
    if (text.length > 0) {
        pBoard.string = text;
    }
}

- (CGSize) sizeThatFits:(CGSize)size {
    [self createFrameRefWithWidth:size.width];
    return self->suggestedSize;
}

- (void) layoutSubviews {
    [super layoutSubviews];
    if (!_frameRef) {
        [self createFrameRefWithWidth:CGRectGetWidth(self.bounds)];
    }
}

- (void) layoutPlaceHolder {
//    if (self.placeHolders.count > 0) {
        NSArray* lines = (NSArray*)CTFrameGetLines(_frameRef);
        CGPoint lineOrigins[lines.count];
        
        CTFrameGetLineOrigins(_frameRef, CFRangeMake(0, 0), lineOrigins);
        
        for (int i=0; i<lines.count; ++i) {
            CTLineRef line = (__bridge CTLineRef)lines[i];
            [self layoutLine:line origin:lineOrigins[i]];
            if (i + 1 >= self.maxLineCount) {
                break;
            }
        }
//    }
}

- (void) layoutLine:(CTLineRef) line origin:(CGPoint) lineOrigin {
    if (self.placeHolders.count == 0 && self.emotions.count == 0) {
        return;
    }
    CGFloat width = 0.0f;
    CGFloat height = 0.0f;
    NSArray * runObjArray = (NSArray *)CTLineGetGlyphRuns(line);
    for (id runObj in runObjArray) {
        CTRunRef run = (__bridge CTRunRef)runObj;
        CTRunStatus runStatus = CTRunGetStatus(run);
        BOOL right2Left = runStatus == kCTRunStatusRightToLeft;
        NSDictionary * runAttributes = (NSDictionary *)CTRunGetAttributes(run);
        CTRunDelegateRef delegate = (__bridge CTRunDelegateRef)[runAttributes valueForKey:(id)kCTRunDelegateAttributeName];
        
        if (delegate == nil) {
            continue;
        }
        
        NSObject* obj = CTRunDelegateGetRefCon(delegate);
        if ([obj isKindOfClass:[ECSControl class]]) {
            ECSControl* control = (ECSControl*)obj;
            CGFloat xOffSetSec;
            CGFloat xOffSet = CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(run).location, &xOffSetSec);
            CGPathRef pathRef = CTFrameGetPath(_frameRef);
            CGRect colRect = CGPathGetBoundingBox(pathRef);
            
            if ([control isKindOfClass:[ECSPlaceHolder class]]) {
                CGRect runBounds = CGRectZero;
                CGFloat ascent;
                CGFloat descent;
                runBounds.size.width = CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &ascent, &descent, NULL);
                runBounds.size.height = ascent + descent;
                if (CGRectGetHeight(runBounds) > height) {
                    height = CGRectGetHeight(runBounds);
                }
                width += CGRectGetWidth(runBounds);
                
                runBounds.origin.x = lineOrigin.x + xOffSet;
                runBounds.origin.y = lineOrigin.y;
                //                runBounds.origin.y -= ascent + descent;
                
                CGRect controllRect = CGRectZero;
                CGRect controlFrame = CGRectOffset(runBounds, colRect.origin.x, colRect.origin.y);
                controllRect = [self viewRectForPostion:controlFrame withHeight:self->suggestedSize.height];
                ECSPlaceHolder* placeHolder = (ECSPlaceHolder*) control;
                placeHolder.placeHolderView.frame = controllRect;
                //                if (CGRectContainsRect(self.bounds, controllRect)) {
                //                    placeHolder.placeHolderView.hidden = NO;
                //                } else {
                //                    placeHolder.placeHolderView.hidden = YES;
                //                }
                
            } else if ([control isKindOfClass:[ECSEmotion class]]) {
                ECSEmotion* emotion = (ECSEmotion*) control;
                CGFloat offset = (int)(self.font.lineHeight + 0.5) - self.font.pointSize;
                CGRect runBounds = CGRectMake(lineOrigin.x + (right2Left ? MIN(xOffSet, xOffSetSec) : MAX(xOffSetSec, xOffSet)) - (right2Left ? emotion.width : 0),
                                              lineOrigin.y - offset,
                                              emotion.width,
                                              emotion.height);
                emotion.frame = runBounds;
            }
        }
    }
}


- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    CGContextTranslateCTM(context, 0, self->suggestedSize.height);
    CGContextScaleCTM(context, 1., -1.);
    
    NSArray* lines = (NSArray*)CTFrameGetLines(_frameRef);
    CGPoint lineOrigins[lines.count];
    
    CTFrameGetLineOrigins(_frameRef, CFRangeMake(0, 0), lineOrigins);
    
    for (int i=0; i<lines.count; ++i) {
        CTLineRef line = (__bridge CTLineRef)lines[i];
        CGPoint lineOrigin = lineOrigins[i];
        CGContextSetTextPosition(context, lineOrigin.x, lineOrigin.y);
//        if (self.singleLine) {
//            CTLineRef lineRef = CTLineCreateWithAttributedString((CFAttributedStringRef)self.attributeString);
//            if (lineRef) {
//                NSAttributedString* escapeString = [[NSAttributedString alloc] initWithString:@"\t"];
//                CTLineRef escapeLine = CTLineCreateWithAttributedString((CFAttributedStringRef)escapeString);
//                CTLineRef lastLine = CTLineCreateTruncatedLine(lineRef, self->suggestedSize.width, kCTLineTruncationEnd, escapeLine);
//                if (lastLine) {
//                    CTLineDraw(lastLine, context);
//                    CFRelease(lastLine);
//                } else {
//                    CTLineDraw(lineRef, context);
//                }
//                if (escapeLine) CFRelease(escapeLine);
//                CFRelease(lineRef);
//            } else {
//                CTLineDraw(line, context);
//            }
//            
//        } else {
            CTLineDraw(line, context);
//        }
        if (i + 1 >= self.maxLineCount) {
            break;
        }
    }
    
    for (ECSEmotion* emotion in self.emotions) {
        CGFloat offset = (int)(self.font.lineHeight + 0.5) - self.font.pointSize;
        CGRect rect = [self viewRectForPostion:emotion.frame withHeight:self->suggestedSize.height];
        rect = CGRectMake(rect.origin.x, rect.origin.y - offset, CGRectGetWidth(rect), CGRectGetHeight(rect));
        if (CGRectContainsRect(self.bounds, rect)) {
            if (emotion.emotionImage) {
                CGRect frame = CGRectMake(emotion.frame.origin.x,
                                          emotion.frame.origin.y,
                                          emotion.frame.size.width,
                                          emotion.frame.size.width);
                CGContextDrawImage(context, frame, emotion.emotionImage.CGImage);
            }
        }
    }
    CGContextRestoreGState(context);
}

- (CGRect) viewRectForPostion:(CGRect) position withHeight:(CGFloat) height{
    CGAffineTransform transform =  CGAffineTransformMakeTranslation(0, height);
    transform = CGAffineTransformScale(transform, 1.f, -1.f);
    return CGRectApplyAffineTransform(position, transform);
}

- (void)setDefaultTarget:(id)defTarget withAction:(SEL)action {
    self.defaultAction = action;
    self.defaultTarget = defTarget;
}

- (void) viewTapped:(UITapGestureRecognizer*) gesture {
    if (!_frameRef) return;
    CGPoint point = [gesture locationInView:self];
    ECSControl* target = nil;
    CFIndex idx = -1;
    
    CFArrayRef linesRef = CTFrameGetLines(_frameRef);
    if (!linesRef) return;
    CFIndex count = CFArrayGetCount(linesRef);
    CGPoint origins[count];
    CTFrameGetLineOrigins(_frameRef, CFRangeMake(0,0), origins);
        
    for (int i=0 ; i<count; ++i) {
        CGPoint lineOrigin = origins[i];
        CTLineRef lineRef = CFArrayGetValueAtIndex(linesRef, i);
        idx = [self getStringIndexForLine:lineRef atPoint:point lineOrigin:lineOrigin];
        if (idx >= 0 || i + 1 >= self.maxLineCount) {
            break;
        }
    }
    
    target = [self controlAtIndex:idx point:point];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    if (target.target && [target.target respondsToSelector:target.action]) {
        target.parentView = self;
        [target.target performSelector:target.action withObject:target];
    } else if (self.defaultTarget
               && [self.defaultTarget respondsToSelector:self.defaultAction]) {
        [self.defaultTarget performSelector:self.defaultAction withObject:self];
    }
#pragma clang diagnostic pop
}

- (CFIndex) getStringIndexForLine:(CTLineRef) lineRef
                          atPoint:(CGPoint) point
                       lineOrigin:(CGPoint) lineOrigin {
    CFIndex idx = -1;
    CGFloat ascent = 0.0f;
    CGFloat descent = 0.0f;
    CGFloat leading = 0.0f;
    
    CGFloat width = (CGFloat)CTLineGetTypographicBounds(lineRef, &ascent, &descent, &leading);
    CGFloat height = ascent + descent;
    
    CGRect rect = [self viewRectForPostion:CGRectMake(lineOrigin.x, lineOrigin.y - descent, width, height) withHeight:CGRectGetHeight(self.bounds)];
    if (CGRectContainsPoint(rect, point)) {
        CGPoint relativePoint = CGPointMake(point.x-CGRectGetMinX(rect),
                                            point.y-CGRectGetMinY(rect));
        idx = CTLineGetStringIndexForPosition(lineRef, relativePoint);
    }
    return idx;
}

- (ECSControl*) controlAtIndex:(CFIndex) idx point:(CGPoint)point{
    ECSControl* target = nil;
    if (idx >= 0) {
        for (ECSControl* control in self.controls) {
            if (NSLocationInRange(idx, control->range)) {
                target = control;
            }
            if ([control isKindOfClass:[ECSPlaceHolder class]]) {
                ECSPlaceHolder* placeHolder = (ECSPlaceHolder*) control;
                if (CGRectContainsPoint(placeHolder.placeHolderView.frame, point)) {
                    target = placeHolder;
                    break;
                }
            }
        }
    }
    return target;
}

+ (NSDictionary *)attributedForTextLabel:(ECSTextLabel*) label
                        defaultTextColor:(UIColor*) _textColor
                              defaulFont:(UIFont*) _font{
    NSMutableDictionary* dic = [[NSMutableDictionary alloc] init];
    UIColor* textColor = label.textColor ? label.textColor : _textColor;
    UIFont* font = label.font ? label.font : _font;
    if (font) {
        [dic setObject:font forKey:NSFontAttributeName];
    }
    
    if (textColor) {
        [dic setObject:(__bridge id)textColor.CGColor forKey:NSForegroundColorAttributeName];
    }
    
    if (label.underlineColor) {
        [dic setObject:(__bridge id)(label.underlineColor.CGColor) forKey:NSUnderlineColorAttributeName];
    }
    if (label.underlineStyle) {
        [dic setObject:[NSNumber numberWithInteger:label.underlineStyle] forKey:NSUnderlineStyleAttributeName];
    }
    return dic;
}

- (NSMutableAttributedString *)attributeString {
    if ([self.controls count] == 0) {
        return nil;
    }
    if (!_attributeString) {
        _attributeString = [[NSMutableAttributedString alloc] init];
        NSMutableArray* textLabels = [NSMutableArray array];
        NSMutableArray* emotions = [NSMutableArray array];
        NSMutableArray* placeHolders = [NSMutableArray array];
        
        for (ECSControl* control in self.controls) {
            NSUInteger len = [_attributeString length];
            if ([control isKindOfClass:[ECSTextLabel class]]) {
                ECSTextLabel* label = (ECSTextLabel*) control;
                if (!label.text) {
                    continue;
                }
                [_attributeString appendAttributedString:[[NSAttributedString alloc] initWithString:label.text attributes:[ECSRichTextView attributedForTextLabel:label defaultTextColor:self.textColor defaulFont:self.font]]];
                [textLabels addObject:control];
            } else if ([control isKindOfClass:[ECSEmotion class]]) {
                ECSEmotion* emotion = (ECSEmotion*) control;
                emotion.width = (NSInteger)(self.font.lineHeight + 0.5);
                emotion.height = self.font.pointSize;;
                [_attributeString appendAttributedString:[ECSRichTextView attributedStringForEmotion:emotion]];
                [emotions addObject:control];
            } else if ([control isKindOfClass:[ECSPlaceHolder class]]) {
                [_attributeString appendAttributedString:[ECSRichTextView attributedStringForPlaceHolder:(ECSPlaceHolder*)control]];
                [placeHolders addObject:control];
            }
            control->range = NSMakeRange(len, [_attributeString length] - len);
        }
        
        [ECSRichTextView configParagraphAttribute:_attributeString lineSpace:self.lineSpace lineBreakMode:self.lineBreakMode textAlignment:self.textAlignment];
        _textLabels = textLabels;
        _emotions = emotions;
        _placeHolders = placeHolders;
    }
    return _attributeString;
}

- (NSArray*) controls {
    if (!_controls) {
        _controls = [self.parser parseContent:_text];
    }
    return _controls;
}

- (void)setControls:(NSArray *)controls {
    _controls = controls;
    _attributeString = nil;
    self.frameRef = NULL;
    for (UIView* subView in self.subviews) {
        [subView removeFromSuperview];
    }
    
    for (ECSControl* control in _controls) {
        if ([control isKindOfClass:[ECSPlaceHolder class]]) {
            ECSPlaceHolder* placeHolder = (ECSPlaceHolder*) control;
            [self addSubview:placeHolder.placeHolderView];
        }
    }

}

+ (NSMutableAttributedString*) attributeStringForSuggestSize:(NSArray*) _controls
                                                    maxWidth:(CGFloat) width
                                                        font:(UIFont*) font
                                                   lineSpace:(CGFloat) lineSpace
                                               lineBreakMode:(NSLineBreakMode) breakMode{
    if (!_controls) {
        return nil;
    }
    
    UIFont *safeFont = font ? font : [UIFont systemFontOfSize:[UIFont systemFontSize]];
    NSMutableAttributedString* attributedString = [[NSMutableAttributedString alloc] init];
    for (ECSControl* control in _controls) {
        if ([control isKindOfClass:[ECSTextLabel class]]) {
            ECSTextLabel* label = (ECSTextLabel*) control;
            if (!label.text) {
                continue;
            }
            [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:label.text attributes:[ECSRichTextView attributedForTextLabel:label defaultTextColor:nil defaulFont:safeFont]]];
        } else if ([control isKindOfClass:[ECSEmotion class]]) {
            ECSEmotion* emotion = (ECSEmotion*) control;
            emotion.width = (NSInteger)(safeFont.lineHeight + 0.5);
            emotion.height = safeFont.pointSize;;
            [attributedString appendAttributedString:[ECSRichTextView attributedStringForEmotion:emotion]];
        } else if ([control isKindOfClass:[ECSPlaceHolder class]]) {
            [attributedString appendAttributedString:[ECSRichTextView attributedStringForPlaceHolder:(ECSPlaceHolder*)control]];
        }
    }

    [ECSRichTextView configParagraphAttribute:attributedString lineSpace:lineSpace lineBreakMode:breakMode textAlignment: NSTextAlignmentLeft];
    return attributedString;
}

+ (void) configParagraphAttribute:(NSMutableAttributedString*) attributedString
                        lineSpace:(CGFloat) lineSpace
                    lineBreakMode:(NSLineBreakMode) linebreakMode
                    textAlignment:(NSTextAlignment) textAlignment{
    if (!attributedString) {
        return;
    }
    
    CTParagraphStyleSetting lineSpaceStyle;
    lineSpaceStyle.spec =  kCTParagraphStyleSpecifierLineSpacing;
    lineSpaceStyle.valueSize = sizeof(CGFloat);
    lineSpaceStyle.value = (const void *)&lineSpace;
    
    //换行模式
    const CTLineBreakMode lineBreak = (CTLineBreakMode)linebreakMode;
    CTParagraphStyleSetting lineBreakStyle;
    lineBreakStyle.spec = kCTParagraphStyleSpecifierLineBreakMode;
    lineBreakStyle.valueSize = sizeof(CTLineBreakMode);
    lineBreakStyle.value = (const void *)&lineBreak;
    
    //换行对齐方式
    const CTTextAlignment alignment = (CTTextAlignment)textAlignment;
    CTParagraphStyleSetting alignmentStyle;
    alignmentStyle.spec = kCTParagraphStyleSpecifierAlignment;
    alignmentStyle.valueSize = sizeof(CTTextAlignment);
    alignmentStyle.value =  (const void *)&alignment;
    
    const CTParagraphStyleSetting paragraphStyles[3] = {lineSpaceStyle,lineBreakStyle, alignmentStyle};
    CTParagraphStyleRef paragraphStyle = CTParagraphStyleCreate(paragraphStyles, 3);
    if (paragraphStyle) {
        [attributedString addAttribute:NSParagraphStyleAttributeName
                                 value:(__bridge id)paragraphStyle
                                 range:NSMakeRange(0, [[attributedString string] length])];
        CFRelease(paragraphStyle);
    }
}

+ (void) setAttributedForLabel:(ECSTextLabel*) label inAttributedString:(NSMutableAttributedString*) attributedString{
    if (!attributedString || !label || label->range.location == NSNotFound) {
        return;
    }
    NSMutableDictionary* attributes = [NSMutableDictionary dictionary];
    if (label.textColor) {
        [attributes setObject:(id)label.textColor forKey:NSForegroundColorAttributeName];
    }
    if (label.underlineColor) {
        [attributes setObject:(id)label.underlineColor forKey:NSUnderlineColorAttributeName];
    }
    [attributes setObject:[NSNumber numberWithInteger:label.underlineStyle] forKey:NSUnderlineStyleAttributeName];
    [attributedString setAttributes:attributes range:label->range];
}

+ (NSAttributedString*) attributedStringForEmotion:(ECSEmotion*) emotion {
    return [self attributedStringForSizedControl:emotion];
}

+ (NSAttributedString*) attributedStringForPlaceHolder:(ECSPlaceHolder*) placeHolder {
    return [self attributedStringForSizedControl:placeHolder];
}

+ (NSAttributedString*) attributedStringForSizedControl:(ECSControl*) control {
    CTRunDelegateCallbacks callback;
    //memset(&callback, 0, sizeof(CTRunDelegateCallbacks));
    memset_s(&callback, sizeof(CTRunDelegateCallbacks), 0, sizeof(CTRunDelegateCallbacks));
    callback.version = kCTRunDelegateCurrentVersion;
    callback.getAscent = ascentCallback;
    callback.getDescent = descentCallback;
    callback.getWidth = widthCallback;
    callback.dealloc = deallocCallback;
    CTRunDelegateRef delegate = CTRunDelegateCreate(&callback, (void*)CFBridgingRetain(control));
    
    unichar objectReplacementChar = 0xFFFC;
    NSString* replacement = [NSString stringWithCharacters:&objectReplacementChar length:1];
    if (nil == replacement) {
        replacement = @"";
    }
    NSMutableAttributedString* attributedString = [[NSMutableAttributedString alloc] initWithString:replacement];
    CFAttributedStringSetAttribute((CFMutableAttributedStringRef)attributedString, CFRangeMake(0, 1), kCTRunDelegateAttributeName, delegate);
    CFRelease(delegate);
    return attributedString;
}


@end
