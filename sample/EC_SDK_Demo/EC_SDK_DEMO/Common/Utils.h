#import <UIKit/UIKit.h>
#import <sys/utsname.h>
#import <AVFoundation/AVFoundation.h>

#define UIViewGetHeight(view)   CGRectGetHeight(view.bounds)
#define UIViewGetWidth(view)    CGRectGetWidth(view.bounds)
#define RGBACOLOR(r,g,b,a) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:(a)]
///< 判断设备是否为iPhone X
#define KISIphoneX \
({\
struct utsname systemInfo;\
uname(&systemInfo);\
NSString *deviceTypeString = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];\
BOOL isIphone = ([deviceTypeString containsString:@"iPhone10,3"] || [deviceTypeString containsString:@"iPhone10,6"] || [deviceTypeString containsString:@"iPhone11,2"] || [deviceTypeString containsString:@"iPhone11,4"] || [deviceTypeString containsString:@"iPhone11,6"] || [deviceTypeString containsString:@"iPhone11,8"]);\
isIphone;\
})

#undef kMainScreenHeight
#define kMainScreenHeight ([UIScreen mainScreen].bounds.size.height)

#undef kMainScreenWidth
#define kMainScreenWidth   ([UIScreen mainScreen].bounds.size.width)

#define UIColorFromHex(s) [UIColor colorWithRed:(((s & 0xFF0000) >> 16))/255.0 green:(((s & 0xFF00) >> 8))/255.0 blue:((s & 0xFF))/255.0  alpha:1.0]

#define UIColorFromHexR(s,r) [UIColor colorWithRed:(((s & 0xFF0000) >> 16))/255.0 green:(((s & 0xFF00) >> 8))/255.0 blue:((s & 0xFF))/255.0  alpha:r]


@interface Utils : NSObject

@end
