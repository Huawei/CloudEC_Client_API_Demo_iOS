//
//  EmptyDataView.h
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

#import <UIKit/UIKit.h>
#import "Defines.h"

@class EmptyDataView;

@protocol EmptyDataViewDelegate <NSObject>

- (void)eSpaceEmptyDataViewOnActionButtonPress:(EmptyDataView *)emptyDataView;

@end

@interface EmptyDataView : UIView

@property (nonatomic, weak) id<EmptyDataViewDelegate>delegate;

- (instancetype)initWithOption:(EmptyDataOption)option;
- (void)updateWithOption:(EmptyDataOption)option;
- (void)actionBtnHide:(BOOL)yesOrNO;

@end
