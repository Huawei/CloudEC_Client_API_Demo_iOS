//
//  ConferenceInterface.h
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

#ifndef ConferenceInterface_h
#define ConferenceInterface_h

#import "Defines.h"
@class ChatMsg;
@class ConfBaseInfo;
extern NSString *const CONFERENCE_END_NOTIFY;
extern NSString *const CONFERENCE_CONNECT_NOTIFY;

@class TupCallNotifications,ConfMember,TUPConferenceNotifications;
@protocol ConferenceServiceDelegate <NSObject>
@required


/**
 * This method is used to deel Conference event callback
 * 会议事件回调
 *@param ecConfEvent           Indicates EC_CONF_E_TYPE enum value
 *                             会议事件类型
 *@param resultDictionary      result value
 *                             回调信息集
 */
-(void)ecConferenceEventCallback:(EC_CONF_E_TYPE)ecConfEvent result:(NSDictionary *)resultDictionary;

@end

@protocol DataConferenceChatMessageDelegate <NSObject>

/**
 * This method is used to deel with receiving chat message
 * 收到聊天信息，进行处理
 */
- (void)didReceiveChatMessage:(ChatMsg *)chatMessage;

@end

@protocol ConferenceInterface <NSObject>

/**
 *Indicates conference service delegate
 *会议业务代理
 */
@property (nonatomic ,weak)id<ConferenceServiceDelegate> delegate;

/**
 *Indicates data conference chat service delegate
 *数据会议中文字聊天业务代理
 */
@property (nonatomic, weak) id<DataConferenceChatMessageDelegate> chatDelegate;

/**
 *Indicates whether have joined data conf
 *判断是否加入数据会议
 */
@property (nonatomic, assign) BOOL isJoinDataConf;

/**
 *Indicates whether have video in conference
 *判断是否会议中带视频能力
 */
@property (nonatomic,assign) BOOL isVideoConfInvited;

/**
 *Indicates whether have joined attendee array
 *与会者列表数组
 */
@property (nonatomic, strong) NSMutableArray *haveJoinAttendeeArray;     //current conference'attendees

/**
 *Indicates current base confInfo
 *当前会议信息
 */
@property (nonatomic, strong) ConfBaseInfo *currentConfBaseInfo;

/**
 *Indicates conf type enum
 *会议类型枚举
 */
@property (nonatomic, assign) EC_CONF_TOPOLOGY_TYPE uPortalConfType;

/**
 *Indicates self join conf number
 *自己加入会议的号码
 */
@property (nonatomic, copy) NSString *selfJoinNumber;                    //self join Number in current conference

/**
 * This method is used to dealloc conference params
 * 销毁会议参数信息
 */
-(void)restoreConfParamsInitialValue;

/**
 * This method is used to create conference
 * 创会
 *@param attendeeArray one or more attendees
 *@param mediaType EC_CONF_MEDIATYPE value
 *@return YES or NO
 */
-(BOOL)createConferenceWithAttendee:(NSArray *)attendeeArray mediaType:(EC_CONF_MEDIATYPE)mediaType subject:(NSString *)subject startTime:(NSDate *)startTime confLen:(int)confLen;

/**
 * This method is used to join conference
 * 加入会议
 *@param confId conference id
 *@param accessNumber access number
 *@param confPassWord conf pass word
 *@param joinNumber join conference number
 *@param isVideoJoin is video join
 *@return YES or NO
 */
-(BOOL)joinConferenceWithConfId:(NSString *)confId AccessNumber:(NSString *)accessNumber confPassWord:(NSString *)confPassWord joinNumber:(NSString*)joinNumber isVideoJoin:(BOOL)isVideoJoin;

/**
 * This method is used to get conference detail info
 * 获取会议详细信息
 *@param confId conference id
 *@param pageIndex pageIndex default 1
 *@param pageSize pageSize default 10
 *@return YES or NO
 */
-(BOOL)obtainConferenceDetailInfoWithConfId:(NSString *)confId Page:(int)pageIndex pageSize:(int)pageSize;

/**
 * This method is used to get conference list
 * 获取会议列表
 *@param pageIndex pageIndex default 1
 *@param pageSize pageSize default 10
 *@return YES or NO
 */
-(BOOL)obtainConferenceListWithPageIndex:(int)pageIndex pageSize:(int)pageSize;

/**
 * This method is used to add attendee to conference
 * 添加与会者到会议中
 @param attendeeArray attendees
 @return YES or NO
 */
-(BOOL)confCtrlAddAttendeeToConfercene:(NSArray *)attendeeArray;

/**
 * This method is used to remove attendee
 * 移除与会者
 *@param attendeeNumber attendee number
 *@return YES or NO
 */
-(BOOL)confCtrlRemoveAttendee:(NSString *)attendeeNumber;

/**
 * This method is used to hang up attendee
 * 挂断与会者
 *@param attendeeNumber attendee number
 *@return YES or NO
 */
-(BOOL)confCtrlHangUpAttendee:(NSString *)attendeeNumber;

/**
 * This method is used to recall attendee
 * 重呼与会者
 *@param attendeeNumber attendee number
 *@return YES or NO
 */
-(BOOL)confCtrlRecallAttendee:(NSString *)attendeeNumber;

/**
 * This method is used to leave conference
 * 离开会议
 *@return YES or NO
 */
-(BOOL)confCtrlLeaveConference;

/**
 * This method is used to accept conference call
 * 接听会议来电
 *@param isJoinVideoConf is join video conference
 *@return YES or NO
 */
- (BOOL)acceptConfCallIsJoinVideoConf:(BOOL)isJoinVideoConf;

/**
 * This method is used to reject conference call
 * 拒绝会议来电
 *@return YES or NO
 */
- (BOOL)rejectConfCall;

/**
 * This method is used to end conference (chairman)
 * 结束会议
 *@return YES or NO
 */
-(BOOL)confCtrlEndConference;

/**
 * This method is used to lock conference (chairman)
 * 主席锁定会场
 *@param isLock YES or NO
 *@return YES or NO
 */
-(BOOL)confCtrlLockConference:(BOOL)isLock;

/**
 * This method is used to mute conference (chairman)
 * 主席闭音会场
 *@param isMute YES or NO
 *@return YES or NO
 */
-(BOOL)confCtrlMuteConference:(BOOL)isMute;

/**
 * This method is used to mute attendee (chairman)
 * 主席闭音与会者
 *@param attendeeNumber attendee number
 *@param isMute YES or NO
 *@return YES or NO
 */
-(BOOL)confCtrlMuteAttendee:(NSString *)attendeeNumber isMute:(BOOL)isMute;

/**
 * This method is used to upgrade audio conference to data conference
 * 语音会议升级为数据会议
 *@param hasVideo whether the conference has video
 *@return YES or NO
 */
-(BOOL)confCtrlVoiceUpgradeToDataConference:(BOOL)hasVideo;

/**
 * This method is used to raise hand (Attendee)
 * 与会者举手
 *@param raise YES raise hand, NO cancel raise
 *@param attendeeNumber join conference number
 *@return YES or NO
 */
- (BOOL)confCtrlRaiseHand:(BOOL)raise attendeeNumber:(NSString *)attendeeNumber;

/**
 * This method is used to release chairman right (chairman)
 * 释放主席权限
 *@param chairNumber chairman number in conference
 *@return YES or NO
 */
- (BOOL)confCtrlReleaseChairman:(NSString *)chairNumber;

/**
 * This method is used to request chairman right (Attendee)
 * 申请主席权限
 *@param chairPwd chairman password
 *@param newChairNumber attendee's number in conference
 *@return YES or NO
 */
- (BOOL)confCtrlRequestChairman:(NSString *)chairPwd number:(NSString *)newChairNumber;

/**
 * This method is used to judge whether is uportal mediax conf
 * 判断是否为mediax下的会议
 */
- (BOOL)isUportalMediaXConf;

/**
 * This method is used to judge whether is uportal smc conf
 * 判断是否为smc下的会议
 */
- (BOOL)isUportalSMCConf;

/**
 * This method is used to set conf mode
 * 设置会议模式
 */
- (void)setConfMode:(EC_CONF_MODE)mode;

/**
 * This method is used to boardcast attendee
 * 广播与会者
 */
- (void)boardcastAttendee:(NSString *)attendeeNumber isBoardcast:(BOOL)isBoardcast;

/**
 * This method is used to boardcast attendee
 * 选看与会者
 */
-(void)watchAttendeeNumber:(NSString *)attendeeNumber;

/**
 * This method is used to set presenter (chairman)
 * 主席设置主讲人
 *@param number number
 *@return YES or NO
 */
-(BOOL)setPresenterNumber:(NSString *)number;

/**
 This method is used to send chat message in data conference.
 在数据会议中发送聊天信息
 *@param message chat message body.
 *@param username mine name in data conference
 *@param userId at p2p chat it represents receiver's user id, at public chat it's ignored
 *@return YES or NO. See call back didReceiveChatMessage:
 */
- (BOOL)chatSendMsg:(NSString *)message
       fromUsername:(NSString *)username
           toUserId:(unsigned int)userId;

- (BOOL)joinConferenceWithDisPlayName:(NSString *)disPlayName ConfId:(NSString *)confID PassWord:(NSString *)passWord ServerAdd:(NSString *)serverAdd ServerPort:(int)serverPort;

@end

#endif /* ConferenceInterface_h */


