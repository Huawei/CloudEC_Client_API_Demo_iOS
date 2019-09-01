//
//  ECSDKProgressHud.h
//  EC_SDK_DEMO
//
//  Created by huawei on 2019/8/23.
//  Copyright © 2019年 cWX160907. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ProgressLabel : UILabel

- (void)setMessageText:(NSString *)text;

@end

@interface ECSDKProgressHud : NSObject{
    ProgressLabel *progressLabel;
    NSTimer *countTimer;
}

+ (instancetype)shareInstance;

- (void)makeProgressHUD:(NSString *)message duration:(CGFloat)duration;


@end

NS_ASSUME_NONNULL_END
