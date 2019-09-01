//
//  ImageViewBtn.m
//  EC_SDK_DEMO
//
//  Created by huawei on 2019/8/15.
//  Copyright © 2019年 cWX160907. All rights reserved.
//

#import "ImageViewBtn.h"

@implementation ImageViewBtn

-(CGRect)imageRectForContentRect:(CGRect)contentRect
{
    return CGRectMake(0.0, 0.0, self.bounds.size.width, self.bounds.size.height);
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
