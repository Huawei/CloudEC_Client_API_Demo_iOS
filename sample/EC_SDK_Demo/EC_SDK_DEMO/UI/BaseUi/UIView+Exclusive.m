//
//  UIView+Exclusive.m
//  eSpace
//
//  Created by heleiwu on 15/12/10.
//  Copyright © 2015年 www.huawei.com. All rights reserved.
//

#import "UIView+Exclusive.h"

@implementation UIView (Exclusive)

- (void)exclusiveAllSubButtons {
    for (UIView *subView in self.subviews) {
        if ([subView isKindOfClass:[UIButton class]]) {
            [subView setExclusiveTouch:YES];
        }
        [subView exclusiveAllSubButtons];
    }
}

@end
