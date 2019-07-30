

#import <UIKit/UIKit.h>

@protocol ScreenShareViewDelegate <NSObject>

- (void)onClickStopShare;
- (void)shareViewSingleTapGesture;

@end

@interface ScreenShareView : UIView

@property (nonatomic, weak) id <ScreenShareViewDelegate> screenShareViewDelegate;

@end
