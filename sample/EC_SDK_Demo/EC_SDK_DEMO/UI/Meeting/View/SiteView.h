//
//  SiteView.h
//  TUP_Mobile_Conference_Demo
//
//  Created by lwx308413 on 16/8/12.
//  Copyright © 2016年 huawei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class TupSite,ConfMember,ConfAttendeeInConf;
typedef enum : NSUInteger
{
    REQUEST_CHAIRMAN_ACTION,
    LOCK_CONFERENCE_ACTION,
    MUTE_ALLCONFERENCE_ACTION,
    POSTPONE_CONF_ACTION,
    ADD_ATTENDEE_ACTION,
    CLOSE_ACTION,
    SEND_MSG_ACTION,
    WATCH_ACTION,
    CLOSE_CAMERA_ACTION
} SITEVIEW_TOP_ACTION_TYPE;

typedef enum : NSUInteger
{
    MUTE_ATTENDEE_ACTION,
    HANG_UP_ATTENDEE_ACTION,
    CALL_ATTENDEE_ACTION,
    REMOVE_ATTENDEE_ACTION,
    END_CONF_ACTION,
    BROADCAST_ATTENDEE_ACTION
} SITEVIEW_DETAIL_ACTION_TYPE;

@protocol SiteViewDelegate<NSObject>

@optional
-(void)clickSiteViewTopButtonAction:(SITEVIEW_TOP_ACTION_TYPE)type;

-(void)selectTupSiteInTableView:(TupSite *)site;

-(void)selectUCConferenceMemberInTableView:(ConfMember *)member;


-(void)selectECConferenceMemberInTableView:(ConfAttendeeInConf *)member;

@end

@interface SiteView : UIView

@property (nonatomic,assign)id<SiteViewDelegate> delegate;
@property (nonatomic,strong)NSArray *attendeeArray;
@property (nonatomic)TupSite *selfSite;
@property (nonatomic, assign)BOOL isAllConferenceMute;
@property (nonatomic, assign)BOOL isLockConference;
@property (nonatomic, assign)BOOL isCloseCamera;
@property (nonatomic, copy) NSString *hostNumber;
@property (nonatomic, copy) NSString *presentNumber;

+(instancetype)shareInstance;

-(void)showSiteViewInSuperView:(UIView *)superView Delegate:(id)delegate;

-(void)hideSiteView;

@end
