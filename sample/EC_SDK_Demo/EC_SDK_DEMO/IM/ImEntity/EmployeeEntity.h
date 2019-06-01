/**
 * @file EmployeeEntity.h
 *
 * Copyright (c) 2017 Huawei Tech. Co., Ltd. All rights reserved. \n
 *
 * @brief [en]Description:Dept employee basic service info class head file.
 * [cn]描述：部门职员基础业务信息类头文件。 \n
 **/

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "PersonEntity.h"
#import "Defines.h"


#define ESpacePersonStatusOnline     @"chat"
#define ESpacePersonStatusBusy       @"dnd"
#define ESpacePersonStatusLeave      @"xa"
#define ESpacePersonStatusStealth    @"hide"
#define ESpacePersonStatusNoDisturb  @"uninterruptable"
#define ESpacePersonStatusOffline    @"offline"


#define ECS_SHOW_CHAT				@"chat"				//在线
#define ECS_SHOW_AWAY				@"away"				//服务器未定义
#define ECS_SHOW_DND				@"dnd"				//忙碌
#define ECS_SHOW_XA                 @"xa"				//离开
#define ECS_SHOW_HIDE				@"hide"				//隐身
#define ECS_SHOW_UNINTERRUPTABLE		@"uninterruptable"	//免打扰

/**
 * [en]This enum is about exchange state.
 * [cn]exchange状态
 */
typedef NS_ENUM(NSInteger, ESpaceExchangeState) {
    ESpaceExchangeState_UNKNOWN	  = -1,     /**< [en]Indicates unknown.
                                             <br>[cn]未知 */
    ESpaceExchangeState_AVALIABLE = 1,      /**< [en]Indicates avaliable.
                                             <br>[cn]在线 */
    ESpaceExchangeState_BUSY	  = 2,      /**< [en]Indicates busy.
                                             <br>[cn]繁忙 */
    ESpaceExchangeState_AWAY	  = 3,      /**< [en]Indicates away.
                                             <br>[cn]离开 */
    ESpaceExchangeState_OFFLINE	  = 4       /**< [en]Indicates offline.
                                             <br>[cn]离线 */
};


@class CircleSessionEntity, EmployeeCategoryEntity, GroupEntity, LocalContactEntity, MessageEntity, GroupFileEntity;


/**
 * [en] This class is about ps right describe.
 * [cn] ps权限描述
 **/
@interface  BasicRight: NSObject
{
    BOOL imAllowed;
    BOOL presenceAllowed;
    BOOL showBindNoAllowed;  //add on 2013.5.9,若开启话机联动,则不显示终端号
}
@property (nonatomic,assign) BOOL imAllowed;
@property (nonatomic,assign) BOOL presenceAllowed;
@property (nonatomic,assign) BOOL showBindNoAllowed;

/**
 * @brief [en] This method is used to get state and IM right.
 *        <br>[cn] 获取状态与IM权限
 *
 * @param [in] NSString* funcId                   <b>:</b><br>[en] Indicates function id.
 *                                                        <br>[cn] 功能位
 * @retval BasicRight *                           <b>:</b><br>[en] Return BasicRight if success.
 *                                                        <br>[cn] 成功返回BasicRight
 * @attention [en] NA.
 *            <br>[cn] NA
 * @see NA
 **/
+(BasicRight*)basicRightWithFuncId:(NSString*)funcId;
@end

/**
 * [en] This class is about employee status.
 * [cn] 联系人状态信息
 **/
@interface EmployeeStatus : NSObject
{
    NSString *mainStatus;
    NSString *exchangeStatus;
    NSString *softClientStatus;
    BasicRight *softClientRight;
    BOOL      softClientCameraShow;
    NSMutableDictionary *ipphoneStatus;	 //key:ipphone num value:object of nsstring
    NSMutableDictionary *ipphoneRight;   //key:ipphone num value:object of basicright
    NSMutableDictionary *ipphoneCameraShow;//key:ipphone num value: object of boolValue
}
@property (nonatomic,retain) NSString* mainStatus;
@property (nonatomic,retain) NSString* exchangeStatus;
@property (nonatomic,retain) NSString* softClientStatus;
@property (nonatomic,assign) BOOL softClientCameraShow;
@property (nonatomic,retain) NSMutableDictionary* ipphoneStatus;
@property (nonatomic,retain) BasicRight *softClientRight;
@property (nonatomic,retain) NSMutableDictionary *ipphoneRight;
@property (nonatomic,retain) NSMutableDictionary *ipphoneCameraShow;

/**
 * @brief [en] This method is used to clear status.
 *        <br>[cn] 清空状态
 *
 * @attention [en] NA.
 *            <br>[cn] NA
 * @see NA
 **/
-(void)clearStatus;


@end


#pragma mark-

/**
 * [en]This enum is about client type.
 * [cn]客户端类型
 */
typedef NS_ENUM(NSInteger, ESpaceClientType) {
    ESpaceClientType_Unknown  = -1,         /**< [en]Indicates unknown.
                                             <br>[cn]未知类型 */
    ESpaceClientType_PC       = 0,          /**< [en]Indicates pc.
                                             <br>[cn]pc */
    ESpaceClientType_Mobile   = 1,          /**< [en]Indicates mobile.
                                             <br>[cn]mobile */
    ESpaceClientType_Web      = 2,          /**< [en]Indicates web.
                                             <br>[cn]web */
    ESpaceClientType_Pad      = 3,          /**< [en]Indicates pad.
                                             <br>[cn]pad */
    ESpaceClientType_IPPhone  = 4,          /**< [en]Indicates ipphone.
                                             <br>[cn]IPphone */
    ESpaceClientType_IMSS     = 5           /**< [en]Indicates IMSS.
                                             <br>[cn]IMss */
};

/**
 * [en] Indicates contact all status info.
 * [cn] 联系人所有状态信息
 **/
@interface EspaceUserOnlineStatus : NSObject
@property (nonatomic, assign) ESpaceUserStatus userStatus;
@property (nonatomic, copy) NSString* statusDescription;
@property (nonatomic, assign) NSInteger clientType;
@property (nonatomic, copy) NSString*clientDescription;
@property (nonatomic, copy) NSString* status;
@property (nonatomic, copy) NSString* account;
@property (nonatomic, strong)EmployeeStatus* statusInfo;
@property (nonatomic, copy) NSString* number1;
@property (nonatomic, copy) NSString* number2;
@property (nonatomic, copy) NSString* number3;
@property (nonatomic, copy) NSString* number4;
@property (nonatomic, copy) NSString* number5;
@property (nonatomic, copy) NSString* number6;
@property (nonatomic, copy) NSString* bindNumber;

/**
 * @brief [en] This method is used to judge whether is obline.
 *        <br>[cn] 判断是否是在线
 *
 * @retval BOOL *                   <b>:</b><br>[en] Return yes if true, or return no.
 *                                          <br>[cn] 是返回YES，否返回NO
 * @attention [en] NA.
 *            <br>[cn] NA
 * @see NA
 **/
- (BOOL)isOnline;

/**
 * @brief [en] This method is used to judge whether has IM right.
 *        <br>[cn] 判断是否有IM权限
 *
 * @retval BOOL *                   <b>:</b><br>[en] Return yes if true, or return no.
 *                                          <br>[cn] 是返回YES，否返回NO
 * @attention [en] NA.
 *            <br>[cn] NA
 * @see NA
 **/
- (BOOL)isImAllowed;

/**
 * @brief [en] This method is used to judge is presence allowed.
 *        <br>[cn] 判断是否有状态权限
 *
 * @retval BOOL *                   <b>:</b><br>[en] Return yes if true, or return no.
 *                                          <br>[cn] 是返回YES，否返回NO
 * @attention [en] NA.
 *            <br>[cn] NA
 * @see NA
 **/
- (BOOL)isPresenceAllowed;

/**
 * @brief [en] This method is used to state describe according to user state.
 *        <br>[cn] 根据用户状态获取状态描述
 *
 * @param [in] ESpaceUserStatus personState       <b>:</b><br>[en] Indicates user state.
 *                                                        <br>[cn] 用户状态
 * @retval NSString *                             <b>:</b><br>[en] Return user state describe if true, or return no.
 *                                                        <br>[cn] 成功返回用户状态描述，失败返回nil
 * @attention [en] NA
 *            <br>[cn] NA
 * @see NA
 **/
- (NSString*)stateDescribeForStateValue:(ESpaceUserStatus)personState;

/**
 * @brief [en] This method is used to get status enum by status describe.
 *        <br>[cn] 根据状态描述获取状态枚举
 *
 * @param [in] NSString* status                   <b>:</b><br>[en] Indicates user staus describe.
 *                                                        <br>[cn] 用户状态描述
 * @retval ESpaceUserStatus                       <b>:</b><br>[en] Return user status if true, or return ESpaceUserStatusUnknown.
 *                                                        <br>[cn] 成功返回用户状态，失败返回ESpaceUserStatusUnknown
 * @attention [en] NA
 *            <br>[cn] NA
 * @see NA
 **/
- (ESpaceUserStatus)statusEnumValueOfStstusString:(NSString*)status;
@end

#pragma mark-

/**
 * [en]This enum is about call number type.
 * [cn]呼叫号码类型
 */
typedef NS_ENUM(NSInteger, ESpaceCallNumberObjectType) {
    ESpaceCallNumberObjectType_Softclient = 0,      /**< [en]Indicates soft client number.
                                                     <br>[cn]软终端号码 */
    ESpaceCallNumberObjectType_Mobile = 1,          /**< [en]Indicates mobile call.
                                                     <br>[cn]移动电话 */
    ESpaceCallNumberObjectType_Office = 2,          /**< [en]Indicates office call.
                                                     <br>[cn]办公电话 */
    ESpaceCallNumberObjectType_Home = 3,            /**< [en]Indicates home.
                                                     <br>[cn]家庭电话 */
    ESpaceCallNumberObjectType_Other = 4,           /**< [en]Indicates other.
                                                     <br>[cn]其他号码 */
    ESpaceCallNumberObjectType_Local = 5,           /**< [en]Indicates local.
                                                     <br>[cn]来自本地 */
    ESpaceCallNumberObjectType_Custome = 6,         /**< [en]Indicates custome.
                                                     <br>[cn]自定义 */
    ESpaceCallNumberObjectType_Voice = 7            /**< [en]Indicates voice.
                                                     <br>[cn]语音留言 */
};

/**
 * [en] This class is about call number item.
 * [cn] 单条号码信息
 **/
@interface CallNumberItem : NSObject

@property (nonatomic, assign, readonly)ESpaceCallNumberObjectType numberType;
@property (nonatomic, retain, readonly)NSString *title;
@property (nonatomic, retain, readonly)NSString *numberValue;
@property (nonatomic, assign, readonly)BOOL isDisplayTitle;
@property (nonatomic, assign, readonly)BOOL hideLastNumber;

/**
 * @brief [en] This method is used to init.
 *        <br>[cn] 初始化
 *
 * @param [in] ESpaceCallNumberObjectType type    <b>:</b><br>[en] Indicates number object type.
 *                                                        <br>[cn] 号码类别
 * @param [in] NSString* aTitle                   <b>:</b><br>[en] Indicates title.
 *                                                        <br>[cn] 标签名称
 * @param [in] NSString* aNumber                  <b>:</b><br>[en] Indicates number.
 *                                                        <br>[cn] 号码
 * @param [in] BOOL bIsDisplayTitle               <b>:</b><br>[en] Indicates is display number.
 *                                                        <br>[cn] 是否显示标签
 * @param [in] BOOL bHideLastNumber               <b>:</b><br>[en] Indicates is hide last number.
 *                                                        <br>[cn] 是否加密显示
 * @retval instancetype                           <b>:</b><br>[en] Return an instance type.
 *                                                        <br>[cn] 返回一个对象
 * @attention [en] NA.
 *            <br>[cn] NA
 * @see NA
 **/
- (instancetype)initWithType:(ESpaceCallNumberObjectType)type
                       title:(NSString *)aTitle
                      number:(NSString *)aNumber
                displayTitle:(BOOL)bIsDisplayTitle
              hideLastNumber:(BOOL)bHideLastNumber;


/**
 * @brief [en] This method is used to display title.
 *        <br>[cn] 标题显示的内容
 *
 * @retval NSString *               <b>:</b><br>[en] Return title if success, or return nil.
 *                                          <br>[cn] 成功返回标题，失败返回nil
 * @attention [en] NA
 *            <br>[cn] NA
 * @see NA
 **/
- (NSString *)displayTitle;


/**
 * @brief [en] This method is used to display number.
 *        <br>[cn] 显示的号码
 *
 * @retval NSString *               <b>:</b><br>[en] Return number if success, or return nil.
 *                                          <br>[cn] 成功返回号码，失败返回nil
 * @attention [en] NA
 *            <br>[cn] NA
 * @see NA
 **/
- (NSString *)displayNumber;

@end

#pragma mark-

/**
 * [en] This class is about dept employee basic service info.
 * [cn] 部门职员基础业务信息类
 **/
@interface EmployeeEntity : PersonEntity

@property (nonatomic, retain) NSString * account;

@property (nonatomic, retain) NSSet *memberOf;
@property (nonatomic, retain) NSSet *ownerOf;
@property (nonatomic, retain) NSSet *topics;
@property (nonatomic, retain) NSSet *macthedByLocal;
@property (nonatomic, retain) NSSet *atBy;
@property (nonatomic, retain) NSSet *fileOwnerOf;
@property (nonatomic, retain) NSSet *matchPersonOf;

@property (nonatomic, retain) NSNumber * circleRelation;
@property (nonatomic, retain) NSNumber * circleWatch;
@property (nonatomic, retain) NSNumber * circleWatched;
@property (nonatomic, retain) NSNumber * circleInvoved;//是否有同事圈关系 0无关1有感2被隐藏
@property (nonatomic, retain) NSDate * circleInviteUpdateTime;//圈邀请更新时间
@property (nonatomic, retain) NSString * circleBgImageUrl;
@property (nonatomic, retain) NSNumber * isBindnoShow;


/**
 * @brief [en] This method is used to judge whether is equal to contact.
 *        <br>[cn] 判断是否是同一个联系人
 *
 * @param [in] EmployeeEntity* c    <b>:</b><br>[en] Indicates the contact.
 *                                          <br>[cn] 待对比的联系人
 * @retval BOOL *                   <b>:</b><br>[en] Return yes if true, or return no.
 *                                          <br>[cn] 是返回YES，否返回NO
 * @attention [en] NA.
 *            <br>[cn] NA
 * @see NA
 **/
- (BOOL)isEqualToContact:(EmployeeEntity *)c;
@end

/**
 * [en] This class is about dept employee basic service info.
 * [cn] 部门职员基础业务信息类
 **/
@interface EmployeeEntity (CoreDataGeneratedAccessors)

/**
 * @brief [en] This method is used to add member to group.
 *        <br>[cn] 向群组中添加成员
 *
 * @param [in] GroupEntity* value                   <b>:</b><br>[en] Indicates group member.
 *                                                          <br>[cn] 成员对象
 * @attention [en] NA.
 *            <br>[cn] NA
 * @see NA
 **/
- (void)addMemberOfObject:(GroupEntity *)value;

/**
 * @brief [en] This method is used to remove member from group.
 *        <br>[cn] 从群组中删除成员
 *
 * @param [in] GroupEntity* value                   <b>:</b><br>[en] Indicates group member.
 *                                                          <br>[cn] 成员对象
 * @attention [en] NA.
 *            <br>[cn] NA
 * @see NA
 **/
- (void)removeMemberOfObject:(GroupEntity *)value;

/**
 * @brief [en] This method is used to add member to groups set.
 *        <br>[cn] 向群组集合添加成员
 *
 * @param [in] NSSet* values                        <b>:</b><br>[en] Indicates group member set.
 *                                                          <br>[cn] 成员对象(GroupEntity *)集合
 * @attention [en] NA.
 *            <br>[cn] NA
 * @see NA
 **/
- (void)addMemberOf:(NSSet *)values;

/**
 * @brief [en] This method is used to remove member from group set.
 *        <br>[cn] 从群组集合删除成员
 *
 * @param [in] NSSet* values                        <b>:</b><br>[en] Indicates group member set.
 *                                                          <br>[cn] 成员对象(GroupEntity *)集合
 * @attention [en] NA.
 *            <br>[cn] NA
 * @see NA
 **/
- (void)removeMemberOf:(NSSet *)values;

/**
 * @brief [en] This method is used to add owner to group.
 *        <br>[cn] 向群组中添加管理员
 *
 * @param [in] GroupEntity* value                   <b>:</b><br>[en] Indicates member object.
 *                                                          <br>[cn] 成员对象
 * @attention [en] NA.
 *            <br>[cn] NA
 * @see NA
 **/
- (void)addOwnerOfObject:(GroupEntity *)value;

/**
 * @brief [en] This method is used to remove owner from group.
 *        <br>[cn] 从群组中删除管理员
 *
 * @param [in] GroupEntity* value                   <b>:</b><br>[en] Indicates member object.
 *                                                          <br>[cn] 成员对象
 * @attention [en] NA.
 *            <br>[cn] NA
 * @see NA
 **/
- (void)removeOwnerOfObject:(GroupEntity *)value;

/**
 * @brief [en] This method is used to add owner to group set.
 *        <br>[cn] 向群组集合中添加管理员
 *
 * @param [in] NSSet* values                        <b>:</b><br>[en] Indicates member object set.
 *                                                          <br>[cn] 成员对象(GroupEntity *)集合
 * @attention [en] NA.
 *            <br>[cn] NA
 * @see NA
 **/
- (void)addOwnerOf:(NSSet *)values;

/**
 * @brief [en] This method is used to remove owner from group set.
 *        <br>[cn] 从群组集合中删除管理员
 *
 * @param [in] NSSet* values                        <b>:</b><br>[en] Indicates member object set.
 *                                                          <br>[cn] 成员对象(GroupEntity *)集合
 * @attention [en] NA.
 *            <br>[cn] NA
 * @see NA
 **/
- (void)removeOwnerOf:(NSSet *)values;

/**
 * @brief [en] This method is used to add topics to circle object.
 *        <br>[cn] 向同事圈对象添加topic
 *
 * @param [in] CircleSessionEntity* value           <b>:</b><br>[en] Indicates circle object.
 *                                                          <br>[cn] 同事圈对象
 * @attention [en] NA.
 *            <br>[cn] NA
 * @see NA
 **/
- (void)addTopicsObject:(CircleSessionEntity *)value;

/**
 * @brief [en] This method is used to remove topics from circle object.
 *        <br>[cn] 从同事圈对象中删除topic
 *
 * @param [in] CircleSessionEntity* value           <b>:</b><br>[en] Indicates circle object.
 *                                                          <br>[cn] 同事圈对象
 * @attention [en] NA.
 *            <br>[cn] NA
 * @see NA
 **/
- (void)removeTopicsObject:(CircleSessionEntity *)value;

/**
 * @brief [en] This method is used to add topics to circle object.
 *        <br>[cn] 向同事圈对象添加topic集合
 *
 * @param [in] NSSet* values                        <b>:</b><br>[en] Indicates topic set.
 *                                                          <br>[cn] topic集合
 * @attention [en] NA.
 *            <br>[cn] NA
 * @see NA
 **/
- (void)addTopics:(NSSet *)values;

/**
 * @brief [en] This method is used to remove topics to circle object.
 *        <br>[cn] 从同事圈对象中删除topic集合
 *
 * @param [in] NSSet* values                        <b>:</b><br>[en] Indicates topic set.
 *                                                          <br>[cn] topic集合
 * @attention [en] NA.
 *            <br>[cn] NA
 * @see NA
 **/
- (void)removeTopics:(NSSet *)values;

/**
 * @brief [en] This method is used to add match to local object.
 *        <br>[cn] 添加匹配到的本地联系人
 *
 * @param [in] LocalContactEntity* value            <b>:</b><br>[en] Indicates local contact object.
 *                                                          <br>[cn] 本地联系人对象
 * @attention [en] NA.
 *            <br>[cn] NA
 * @see NA
 **/
- (void)addMacthedByLocalObject:(LocalContactEntity *)value;

/**
 * @brief [en] This method is used to remove matched by local contact.
 *        <br>[cn] 删除匹配到的本地联系人
 *
 * @param [in] LocalContactEntity* value            <b>:</b><br>[en] Indicates local contact object.
 *                                                          <br>[cn] 本地联系人对象
 * @attention [en] NA.
 *            <br>[cn] NA
 * @see NA
 **/
- (void)removeMacthedByLocalObject:(LocalContactEntity *)value;

/**
 * @brief [en] This method is used to add matched by local contact set.
 *        <br>[cn] 添加匹配到的本地联系人集合
 *
 * @param [in] NSSet* values                        <b>:</b><br>[en] Indicates local contact set.
 *                                                          <br>[cn] 本地联系人(LocalContactEntity *)集合
 * @attention [en] NA.
 *            <br>[cn] NA
 * @see NA
 **/
- (void)addMacthedByLocal:(NSSet *)values;

/**
 * @brief [en] This method is used to remove matched by local contact set.
 *        <br>[cn] 删除匹配到的本地联系人集合
 *
 * @param [in] NSSet* values                        <b>:</b><br>[en] Indicates local contact set.
 *                                                          <br>[cn] 本地联系人(LocalContactEntity *)集合
 * @attention [en] NA.
 *            <br>[cn] NA
 * @see NA
 **/
- (void)removeMacthedByLocal:(NSSet *)values;

/**
 * @brief [en] This method is used to add at object by message.
 *        <br>[cn] 根据消息添加@对象
 *
 * @param [in] MessageEntity* value                 <b>:</b><br>[en] Indicates message object.
 *                                                          <br>[cn] 消息对象
 * @attention [en] NA.
 *            <br>[cn] NA
 * @see NA
 **/
- (void)addAtByObject:(MessageEntity*)value;

/**
 * @brief [en] This method is used to remove at object by message.
 *        <br>[cn] 根据消息删除@对象
 *
 * @param [in] MessageEntity* value                 <b>:</b><br>[en] Indicates message object.
 *                                                          <br>[cn] 消息对象
 * @attention [en] NA.
 *            <br>[cn] NA
 * @see NA
 **/
- (void)removeAtByObject:(MessageEntity*)value;

/**
 * @brief [en] This method is used to add at object set by message.
 *        <br>[cn] 根据消息添加@对象集合
 *
 * @param [in] NSSet* values                        <b>:</b><br>[en] Indicates at obj set.
 *                                                          <br>[cn] @对象()集合
 * @attention [en] NA.
 *            <br>[cn] NA
 * @see NA
 **/
- (void)addAtBy:(NSSet*)values;

/**
 * @brief [en] This method is used to remove at object set by message.
 *        <br>[cn] 根据消息删除@对象集合
 *
 * @param [in] NSSet* values                        <b>:</b><br>[en] Indicates at obj set.
 *                                                          <br>[cn] @对象()集合
 * @attention [en] NA.
 *            <br>[cn] NA
 * @see NA
 **/
- (void)removeAtBy:(NSSet*)values;

/**
 * @brief [en] This method is used to add file owner by file.
 *        <br>[cn] 根据文件添加文件管理员
 *
 * @param [in] GroupFileEntity* value               <b>:</b><br>[en] Indicates file owner object.
 *                                                          <br>[cn] 文件管理员对象
 * @attention [en] NA.
 *            <br>[cn] NA
 * @see NA
 **/
- (void)addFileOwnerOfObject:(GroupFileEntity*)value;

/**
 * @brief [en] This method is used to remove file owner by file.
 *        <br>[cn] 根据文件删除文件管理员
 *
 * @param [in] GroupFileEntity* value               <b>:</b><br>[en] Indicates file owner object.
 *                                                          <br>[cn] 文件管理员对象
 * @attention [en] NA.
 *            <br>[cn] NA
 * @see NA
 **/
- (void)removeFileOwnerOfObject:(GroupFileEntity*)value;

/**
 * @brief [en] This method is used to add file owner by file set.
 *        <br>[cn] 根据文件集合添加文件管理员
 *
 * @param [in] NSSet* values                        <b>:</b><br>[en] Indicates file set.
 *                                                          <br>[cn] 文件集合
 * @attention [en] NA.
 *            <br>[cn] NA
 * @see NA
 **/
- (void)addFileOwnerOf:(NSSet*)values;

/**
 * @brief [en] This method is used to remove file owner by file set.
 *        <br>[cn] 根据文件集合删除文件管理员
 *
 * @param [in] NSSet* values                        <b>:</b><br>[en] Indicates file set.
 *                                                          <br>[cn] 文件集合
 * @attention [en] NA.
 *            <br>[cn] NA
 * @see NA
 **/
- (void)removeFileOwnerOf:(NSSet*)values;

@end

/**
 * [en] Indicates contact related info.
 * [cn] 联系人相关信息
 **/
@interface EmployeeInfo : NSObject
@property (nonatomic, strong)NSString *account;                     //账号
@property (nonatomic, strong)NSString *staffNum;                    //工号
@property (nonatomic, strong)NSString *zhName;
@property (nonatomic, strong)NSString *enName;
@property (nonatomic, strong)NSString *pinyinName;
@property (nonatomic, strong)NSString *pinyinShort;                 //拼音简写
@property (nonatomic, strong)NSString *mobilePhone1;
@property (nonatomic, strong)NSString *mobilePhone2;
@property (nonatomic, strong)NSString *mobilePhone3;
@property (nonatomic, strong)NSString *zhMinDept;                   //最小中文部门
@property (nonatomic, strong)NSString *enMinDept;                   //最小英文部门
@property (nonatomic, strong)NSString *zhMaxDept;                   //最大中文部门
@property (nonatomic, strong)NSString *enMaxDept;                   //最大英文部门
@property (nonatomic, strong)NSString *seat;                        //座位
@property (nonatomic, strong)NSString *email;
@property (nonatomic, strong)NSString *fromSource;                  //数据来源，1：公司联系人  0：外部联系人
@property (nonatomic, strong)NSString *seatNum;                     //座位号
@property (nonatomic, strong)NSString *isAdmin;                     //是否为主管
@property (nonatomic, strong)NSString *level;                       //级别
@property (nonatomic, strong)NSString *doctor;                      //是否为专家

/**
 * @brief [en] This method is used to init with employee entity.
 *        <br>[cn] 初始化
 *
 * @param [in] EmployeeEntity* entity             <b>:</b><br>[en] Indicates employee entity.
 *                                                        <br>[cn] 联系人对象
 * @retval instancetype                           <b>:</b><br>[en] Return an instance type.
 *                                                        <br>[cn] 返回一个单例对象
 * @attention [en] NA.
 *            <br>[cn] NA
 * @see NA
 **/
- (instancetype)initWithEmployeeEntity:(EmployeeEntity *)entity;

/**
 * @brief [en] This method is used to dictionary employee info.
 *        <br>[cn] 联系人信息
 *
 * @retval NSMutableDictionary *    <b>:</b><br>[en] Return contact info.
 *                                          <br>[cn] 联系人信息
 * @attention [en] NA
 *            <br>[cn] NA
 * @see NA
 **/
- (NSMutableDictionary *)dirForEmployeeInfo;
@end
