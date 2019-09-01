//
//  SignalScrollView.m
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

#import "SignalScrollView.h"

@implementation SignalScrollView

-(instancetype)init
{
    if (self = [super init])
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"SignalScrollView" owner:self options:nil];
        self = [nib objectAtIndex:0];
        self.scrollEnabled = YES;
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        self.alwaysBounceVertical = YES;
        self.alwaysBounceHorizontal = YES;
//        self.userInteractionEnabled = YES;
//        self.multipleTouchEnabled = NO;
//        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//        self.pagingEnabled = YES;
        self.backgroundColor = [UIColor clearColor];
        [self setContentSize:CGSizeMake(950, 365)];
    }
    return self;
}

@end
