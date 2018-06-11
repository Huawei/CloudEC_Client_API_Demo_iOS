//
//  CameraInfoView.h
//  TUP_Mobile_DataConference_Demo
//
//  Created by lwx308413 on 16/12/19.
//  Copyright © 2016年 huawei. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ConfCameraInfo;
@protocol CamreaInfoViewDelegate <NSObject>
-(void)didSelectedCameraInfo:(ConfCameraInfo *)cameraInfo;
@end


@interface CameraInfoView : UIView
@property (nonatomic,strong)NSMutableArray *cameraInfoArray;
@property (nonatomic,assign)id<CamreaInfoViewDelegate> delegate;
+(instancetype)sharedInstance;
-(void)showCameraInfoViewIn:(UIView *)superView delegate:(id)delegate;
@end
