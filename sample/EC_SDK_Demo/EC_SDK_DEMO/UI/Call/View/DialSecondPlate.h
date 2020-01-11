//
//  DialSecondPlate.h
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

#import <UIKit/UIKit.h>

@protocol DialSecondPlateDelegate <NSObject>

-(void)clickDialSecondPlate:(NSString *)string;

@end

@interface DialSecondPlate : UIView

@property (nonatomic, weak)id<DialSecondPlateDelegate> delegate;

+(instancetype)shareInstance;

-(BOOL)isShow;

-(void)showViewInSuperView:(UIView *)superView Delegate:(id)delegate;

-(void)hideView;
@end
