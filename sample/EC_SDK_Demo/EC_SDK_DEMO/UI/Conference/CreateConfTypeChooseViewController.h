//
//  CreateConfTypeChooseViewController.h
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

#import <UIKit/UIKit.h>
#import "Defines.h"
#import "ECBaseTableViewController.h"

@protocol CreateConfTypeChooseViewControllerDelegate <NSObject>
 @optional
- (void)confMediaTypeSelectedWithConfMediaType:(EC_CONF_MEDIATYPE)selectedMediaType;

@end

@interface CreateConfTypeChooseViewController : ECBaseTableViewController
@property (nonatomic, weak) id<CreateConfTypeChooseViewControllerDelegate> delegate;
- (instancetype)initWithConfMediaType:(EC_CONF_MEDIATYPE)mediaType andIsSupportVideoConf:(BOOL)isSupportVideoConf;
@end
