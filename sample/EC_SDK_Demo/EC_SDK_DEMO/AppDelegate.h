//
//  AppDelegate.h
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

#import <UIKit/UIKit.h>
#import "Utils.h"
@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
//@property (nonatomic, strong) ESpaceLocalDataManager* localDataManager;

/**
 *This method is used to switch to the conf running page
 *切换到正在召开的会议页面
 */
+(void)goConference;

+(void)appConfShareRequestAction;

+ (void)startAutoLogin;

+ (void)gotoRecentChatSessionView;

@end

