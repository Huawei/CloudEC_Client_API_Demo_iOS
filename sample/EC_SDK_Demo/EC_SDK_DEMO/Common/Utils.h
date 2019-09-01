#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

#define UIViewGetHeight(view)   CGRectGetHeight(view.bounds)
#define UIViewGetWidth(view)    CGRectGetWidth(view.bounds)
#define RGBACOLOR(r,g,b,a) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:(a)]

#undef kMainScreenHeight
#define kMainScreenHeight ([UIScreen mainScreen].bounds.size.height)

#undef kMainScreenWidth
#define kMainScreenWidth   ([UIScreen mainScreen].bounds.size.width)

#define UIColorFromHex(s) [UIColor colorWithRed:(((s & 0xFF0000) >> 16))/255.0 green:(((s & 0xFF00) >> 8))/255.0 blue:((s & 0xFF))/255.0  alpha:1.0]

#define UIColorFromHexR(s,r) [UIColor colorWithRed:(((s & 0xFF0000) >> 16))/255.0 green:(((s & 0xFF00) >> 8))/255.0 blue:((s & 0xFF))/255.0  alpha:r]


@interface Utils : NSObject

@end
