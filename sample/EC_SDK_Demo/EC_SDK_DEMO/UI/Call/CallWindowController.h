//
//  CallWindowController.h
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CallWindowController : NSObject

+ (instancetype)shareInstance;

- (void)showStartCallView:(unsigned int)callId;

@end
