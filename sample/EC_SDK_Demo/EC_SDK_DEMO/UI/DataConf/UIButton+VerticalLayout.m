//
//  UIButton+VerticalLayout.m
//  WeLink
//
//  Created by Eric on 2018/10/17.
//

#import "UIButton+VerticalLayout.h"

@implementation UIButton (VerticalLayout)

- (void)centerVertically {
    const CGFloat kDefaultPadding = 6.0f;
    [self centerVerticallyWithPadding:kDefaultPadding];
}


- (void)centerVerticallyWithPadding:(CGFloat)padding {
    CGSize imageSize = self.imageView.image.size;
    self.titleEdgeInsets = UIEdgeInsetsMake(0.0, -imageSize.width, -(imageSize.height + padding), 0.0);
    
    CGSize titleSize = [self.titleLabel.text sizeWithAttributes:@{ NSFontAttributeName : self.titleLabel.font }];
    self.imageEdgeInsets = UIEdgeInsetsMake(-(titleSize.height + padding), 0.0, 0.0, -titleSize.width);
    
    CGFloat edgeOffset = fabs(titleSize.height - imageSize.height) / 2.0;
    self.contentEdgeInsets = UIEdgeInsetsMake(edgeOffset, 0.0, edgeOffset, 0.0);
}

@end
