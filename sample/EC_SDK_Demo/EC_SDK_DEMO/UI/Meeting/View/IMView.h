//
//  IMView.h
//  TUP_Mobile_DataConference_Demo
//
//  Created by lwx308413 on 16/11/22.
//  Copyright © 2016年 huawei. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol IMViewDelegate <NSObject>

-(void)sendButtonAction:(NSString *)message;

@end

@interface IMView : UIView
@property (nonatomic, assign)id<IMViewDelegate> delegate;

+(instancetype)shareInstance;

-(void)showIMViewWithFrame:(CGRect )frame inSuperView:(UIView *)superView delegate:(id)delegate;

-(void)hideIMView;

-(void)refreshData;

-(void)configDataWithArray:(NSMutableArray *)dataArray;

-(void)cleanTextFileContent;
@end
