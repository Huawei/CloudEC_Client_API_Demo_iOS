//
//  EmptyDataView.h
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, EmptyDataOption) {
    ESpaceEDONoChatHistory = 1,
    ESpaceEDONoCallHistory,
    ESpaceEDONoContact,
    ESpaceEDONoGroup,
    ESpaceEDONoABPremission,
    ESpaceEDONoLocalContact,
    ESpaceEDONoSearchResult,
    ESpaceEDONoConference,
    ESpaceEDONoPublicAccount,
    ESpaceEDONoPAChatHistory,
    ESPaceEDONoVoiceMail,
    ESPaceEDONoAddedContact,
    ESpaceEDONoDeptData
};

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
