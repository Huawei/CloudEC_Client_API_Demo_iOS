//
//  ECSErrorCode.h
//  eSpaceIOSSDK
//
//  Created by ZengyiWang on 15/12/3.
//  Copyright © 2015年 huawei. All rights reserved.
//

#import <Foundation/Foundation.h>

#define ECS_SPECIFIC_ERROR_CODE_BEIGN 1000 // 除了ECSCommonErrorCode以外的特定模块的错误码的最小值

#pragma mark - Error Domain

extern NSString * const ECSCommonErrorDomain; // 通用错误

extern NSString * const ECSLoginErrorDomain; // 登录
extern NSString * const ECSContactErrorDomain; // 联系人
extern NSString * const ECSGroupErrorDomain; // 群组
extern NSString * const ECSiPhoneContactErrorDomain; // 手机通讯录
extern NSString * const ECSInstantMessageErrorDomain; // IM消息
extern NSString * const ECSRecentSessionErrorDomain;// 最近对话
extern NSString * const ECSCallRecordErrorDomain; // 通话记录
extern NSString * const ECSCallErrorDomain; // 通话
extern NSString * const ECSUMErrorDomain; // UM
extern NSString * const ECSConferenceErrorDomain; // 会议
extern NSString * const ECSPublicAccountErrorDomain; // 公众号
extern NSString * const ECSLightAppErrorDomain; // 轻应用
extern NSString * const ECSCircleColleagueErrorDomain; // 同事圈
extern NSString * const ECSVoiceMailErrorDomain; // 语音留言
extern NSString * const ECSSettingErrorDomain; // 设置
extern NSString * const ECSSvnErrorDomain; // svn
extern NSString * const ECSDBUpdateErrorDomain; // 数据库升级
extern NSString * const ECSEventRecordErrorDomain; // 事件打点

//extern NSString * const ECSCloudDriveErrorDomain; // 直接对应 offlinefile_def.h 的枚举 tagOFFLINE_E_ERRORCODE 或者 TUP_RESULT
//extern NSString * const ECSUMServerErrorDomain; // 直接对应 httpapi.h 中的枚举 EN_HTTP_ERRORCODE

extern NSString * const ECSUMServerErrorDomain; // 富媒体服务器错误
extern NSString * const ECSCertificateDownloadErrorDomain; // 证书下载错误

//消息撤回
extern NSString * const ECSRecallMessageTimeOutErrorDomain;
extern NSString * const ECSRecallMessageTimeOutKey;
//
#pragma mark - Error userInfo
/*
 * 基本上只使用iOS自带的key值即可 [key, value]
 * NSLocalizedDescriptionKey 问题描述
 * NSLocalizedFailureReasonErrorKey 问题原因 （建议大家使用这个来写自己的具体问题）
 * NSLocalizedRecoverySuggestionErrorKey 针对问题给出的建议
 
 举例:
 NSDictionary *userInfo = 
 @{
    NSLocalizedDescriptionKey: ECSLocalizedString(@"Operation was unsuccessful.", nil),
    NSLocalizedFailureReasonErrorKey: ECSLocalizedString(@"The operation timed out.", nil),
    NSLocalizedRecoverySuggestionErrorKey: ECSLocalizedString(@"Have you tried turning it off and on again?", nil)
 };
 */



#pragma mark - Error Code
/*
 * 1: error code 是跟特定的error domain绑定的，所以原则上每个特定error domain下可以定义一样的错误码；
 ＊
 ＊ 2: 为了更易于区分错误，每个error domain下拥有自己单独的error code范围为1000
 ＊（不需要显示的进行赋值，为了以防以后ECSCommonErrorCode超过1000的情况）
 ＊
 ＊ 3: ECSCommonErrorCode 定义了一些通用的错误码，比如服务器响应超时，接口请求参数不正确等。可被所有的模块所使用
 ＊
 ＊ 4: ECS*ErrorCode 都是特定模块的错误码，只用于特定模块
 */

typedef NS_ENUM(NSInteger, ECSCommonErrorCode)
{
    ECSCommonSuccessCode = 0, // MAA响应成功的结果码
    
    // MAA 接口返回 -----Begin
    ECSCommonMaaUndefinedError = -1, // 通用错误，未加以定义的错误
    ECSCommonSessionExpiredError = -2, // session过期，客户端可选择使用此会话重登
    ECSCommonLoginFailedError = -3, // 登录失败; 此错误服务器会返回失败提示语
    ECSCommonRequestMessageError = -4, //客户端请求消息异常, 客户端的CDATA文件不符合XML规范, 缺少节点, 必填属性为空时返回
    ECSCommonClientInterfaceError = -5, // 与appServer, eServer交互时出现错误，包括无响应，返回消息解析出错
    ECSCommonSessionKickedOutError = -6, // 用户在其他地方登录，会话状态已改变
    ECSCommonRequestPageSizeError = -7, // 请求页数错误（页数不正确，包括请求的页数大于最大页数）
    ECSCommonMessageNotExistError = -8, // 模块消息处理未找到(业务层中未定义的消息接口)
    ECSCommonSessionNotExistError = -9, // session不存在或已超时被回收，当用户离线时间过长（默认配置1小时）
    ECSCommonClientNotEnableError = -10, //未开通手机客户端权限
    ECSCommonDeviceSerialNumberError = -11, // 设备序列号不正确
    ECSCommonQueryResultNotExistError = -12, // 查询结果不存在
    ECSCommonMediaXEnterConfFailedError = -20, // MediaX一键入会失败
    ECSCommonAppServerResponseError = -21, // AppServer返回信息错误， 会场已经锁定
    ECSCommonConfNotExist = -30, // 会议不存在
    ECSCommonAddConfParticipantFailedError = -31, // 与会人邀请失败（与会人正在呼叫或已经加入会议，再次邀请出现此错误）
    ECSCommonConfParticipantNotInConfError = -35, // 与会人不在会议中
    ECSCommonNoNeedChangeSpeakingRightError = -43, // 无需修改话语权
    ECSCommonMAAForwardAddressError = -50, // maa服务器重定向（非错误）
    ECSCommonLackOfResourceError = -100, // 资源不足，专用与升级响应
    ECSCommonAccessEachOtherForbiddenError = -101, //服务器因为安全策略不允许互相通信
    ECSCommonServerOverFlowError = -102, // 服务器过载
    ECSCommonBusinessConflictError = -106, // 业务冲突
    ECSCommonDeviceIDError = -201, // 表示push通道的deviceID过期，或者不可用
    ECSCommonRefressHeatBeatError = -412, // 表示PS容灾，必须重新刷新心跳（PS服务器异常之后，客户端发布状态会返回该错误码，需要发送第一次心跳触发MAA／ESG需要客户端到新的PS上重新注册／订阅）
    
    ECSCommonInvalidDataException = 1, // 消息不完整或者不符合xml规范而无法解析
    ECSCommonServiceNotFoundException = 2, // 消息服务不存在（不存在这样的MsgType时候，返回错误响应）
    ECSCommonReloginSuccessError = 4, // 客户端重新连接的返回结果
    // MAA 接口返回 －－－-End
    
    //消息撤回超时 ————————————————————————————————————————————
    ECSCommonRecallMessageTimeOutError = 38,
    
    ECSCommonMessageSizeError = 200, // maa消息大小不正确
    
    // http 请求错误 ——————————————————————————————————————————
    ECSCommonHttpRequestError = 400, // 请求错误
    ECSCommonHttpUnauthorizedError = 401, // 未授权
    ECSCommonHttpForbiddenError = 403, // 禁止访问
    ECSCommonHttpNotFoundError = 404, // URL错误,未找到
    ECSCommonHttpTimeoutError = 408, // 请求超时
     // http 请求错误 ——————————————————————————————————————————
    
    ECSCommonMAAConnectionFailedError = INT_MAX, // 2147483647
    ECSCommonMAACancelledError = INT_MAX - 1,
    ECSCommonMAATimeOutError = INT_MAX - 2,
    ECSCommonSocketCloseError = INT_MAX - 3,
    ECSCommonMAAResendFailedError = INT_MAX - 4,
    ECSCommonNetworkUnreachError = INT_MAX - 5,
    
    ECSCommonMAAInvalidArgsError = INT_MAX - 10,
    ECSCommonMAANoRightError = INT_MAX - 11,
    
    ECSCommonHTTPCancelledError = ECSCommonMAACancelledError
};

typedef NS_ENUM(NSInteger, ECSLoginErrorCode)
{
    ECSLoginErrorCodeBegin = 1000,
    ECSLoginServiceOverFlow = ECSCommonServerOverFlowError, // loginAck返回服务器过载
    ECSLoginWatingUIOperationError = 1001, // 登录流程中，需要等待UI的操作，返回此错误码。
    ECSLoginCancelByUIError = 1002, // 登录流程中，UI取消登录，返回此错误码。
    ECSLoginNeedToUpgradeError = 1003, // 登录流程中，checkVersion返回需要升级，返回此错误码
    ECSLoginKeyExchangeError = 1004, // 密钥交换中没有找到aesKey
    ECSLoginRequestToMAACancelError = 1005, // 自动取消
    ECSLoginRequestToMAASelfCancelError = 1006, // 自己主动取消
    ECSLoginLoginingError = 1007, // 已经处于登录状态
    ECSLoginUndefinedStatusMachineCommadError = 1008, // 状态码未找到
    ECSLoginGetMDMInfoFailed = 1009, // 从mdm获取登录帐号和密码失败
    ECSLoginHWUCSwitchLoginUserError = 1010, // hwuc单点登录，获取到的登录账号和当前已经登录的账号不同
    ECSLoginAnyofficeSwitchLoginUserError = 1011, // 基线anyoffice单点登录，获取到的登录信息和当前已经登录的账号信息不同
    ECSLoginUportalDetectFailed = 1012,  // 登录流程中, 向Uportal探测失败
    ECSLoginUportalConnectedFailed = 1013,  // EC6.0 Uportal不可达
    ECSLoginUportalAccountError = 1014,     // EC6.0 uPortal鉴权账号密码错误
    ECSLoginUportalTimeout = 1015,          // EC6.0 uPortal鉴权超时
    ECSLoginUportalAccountLockedError = 1016,    // EC6.0 uPortal账号被锁定
    ECSLoginUportalUnBussinessError = 1017,    // EC6.0 uPortal鉴权中，非业务错误
    ECSLoginTokenRefreshFailed = 1018,      //token刷新失败
    ECSLoginArgInvalidError = 1019, // 参数错误
    ECSLoginTokenValueEmptyError = 1020, // token值为空
    ECSLoginDestroySTGTunnelError = 1021, // 销毁隧道失败
    ECSLoginCreateSTGTunnelError = 1022, // 创建stg隧道失败
    ECSLoginFirewallDetectError = 1023, // 防火墙探测失败
    ECSLoginActionProcessingError = 1024, // 存在类似操作正在进行
    ECSLoginErrorCodeEnd = 1999
};

typedef NS_ENUM(NSInteger, ECSContactErrorCode)
{
    ECSContactErrorCodeBegin = 2000,
    
    ECSContactErrorArgsError = 2001, // 参数错误
    ECSContactSyncLocalContactError = 2002, // 没有权限导致同步本地联系人失败
    ECSContactQueryServerContactError = 2003, // 查询指定联系人失败
    ECSContactAddFriendTeamNotExistError = 2004, // 分组不存在错误

    ECSContactErrorCodeEnd = 2999
};

typedef NS_ENUM(NSInteger, ECSGroupErrorCode)
{
    ECSGroupErrorCodeBegin = 3000,
    
    ECSGroupGroupNameError = 3001, // 群组名称不合法
    
    ECSGroupErrorCodeEnd = 3999
};

typedef NS_ENUM(NSInteger, ECSiPhoneContactErrorCode)
{
    ECSiPhoneContactErrorCodeBegin = 4000,
    
    ECSiPhoneContactErrorCodeEnd = 4999
};

typedef NS_ENUM(NSInteger, ECSInstantMessageErrorCode)
{
    ECSInstantMessageErrorCodeBegin = 5000,
    
    ECSInstantMessageResourceUploadError = 5001, // UM上传失败
    ECSInstantMessageResourceUploadingError = 5002, // 正在上传UM
    
    ECSInstantMessageErrorCodeEnd = 5999
};

typedef NS_ENUM(NSInteger, ECSRecentSessionErrorCode)
{
    ECSRecentSessionErrorCodeBegin = 6000,
    
    ECSRecentSessionErrorCodeError = 6999
};

typedef NS_ENUM(NSInteger, ECSCallRecordErrorCode)
{
    ECSCallRecordErrorCodeBegin = 7000,
    
    ECSCallRecordErrorCodeError = 7999
};

typedef NS_ENUM(NSInteger, ECSCallErrorCode)
{
    ECSCallErrorCodeBegin = 8000,
    
    ECSCallErrorCodeEnd = 8999
};

typedef NS_ENUM(NSInteger, ECSUMErrorCode)
{
    ECSUMErrorCodeBegin = 9000,
    
    ECSUMFileNotFoundError = 9001, // 文件未找到
    ECSUMCreateEncrtypedError = 9002, // 创建加密文件夹失败
    ECSUMFileResourcePathError = 9003, // 文件路径错误
    ECSUMIdeskFileInputStreamError = 9004, // 加密文件输入流创建失败
    ECSUMDownloadLocalPathOrURLError = 9005, // 下载的文件服务器地址，或者本地存储路径不正确
    
    ECSUMErrorCodeEnd = 9999
};

typedef NS_ENUM(NSInteger, ECSConferenceErrorCode)
{
    ECSConferenceErrorCodeBegin = 10000,
    
    ECSConferenceJoinConferenceResultError = 10001, // 加入会议失败
    ECSConferenceConferenceIDIllegalError = 10002, // 会议ID不合法
    ECSConferenceEmptyUserNumError = 10003, // 用户帐号为空
    ECSConferenceInviteAttendeesEmptyError = 10004, // 邀请列表为空
    ECSConferenceAttendeeNotExistError = 10005, // 与会者不存在
    ECSConferenceAttendeeHaveLeaveError = 10006, // 与会者已经离开会议
    ECSConferenceBeenMultimediaAlreadyError = 10007, // 当前已经是多媒体会议
    ECSConferenceConferenceHaveCloseError = 10008, // 会议已经关闭
    ECSConferenceNeedShieldConfError = 10009, //会议需要屏蔽
    ECSConferenceBookConfError = 10010,  //预约会议失败
    ECSConferenceEndConfError = 10011,  //结束会议失败
    ECSConferenceUpgradeConfError = 10012, //升级会议失败
    ECSConferenceRequestMasterError = 10013, //申请会议主持人失败
    ECSConferenceReleaseMasterError = 10014, //释放会议主持人失败
    ECSConferenceLeaveConfError = 10015, // 退出会议失败
    ECSConferenceAddAttendeeError = 10016, // 添加与会者失败
    ECSConferenceRemoveAttendeeError = 10017, //删除与会者失败
    ECSConferenceMuteConfError = 10018, //闭音/取消闭音会场失败
    ECSConferenceMuteAttendeeError = 10019, //闭音/取消闭音与会者失败
    ECSConferenceHangupAttendeeError = 10020,  //挂断与会者失败
    ECSConferenceGetDataConfParamError = 10021, //获取数据会议大参数失败
    ECSConferenceUnopenError = 10022,  //会议未开始
    ECSConferenceGetConfListError = 10023,    //获取会议列表失败
    ECSConferenceGetConfInfoError = 10024,    //获取与会者列表失败
    ECSConferenceSetHandleError = 10025,      //创建confhandle失败
    ECSConferenceGEtConfBigParamError = 10026, //获取数据会议大参数失败
    ECSConferenceConfInProgressError = 10027, //当前有会议正在进行
    ECSConferenceRequestRepeatError = 10997,    // 同时存在多个相同请求错误
    ECSConferenceGetConfInfoConfNotExistOrEndedError = 200001, //请求会议信息的时候会议已结束或者不存在错误
    ECSConferenceAddAttendeeConfIsLocked = 200025,  //邀请与会人入会的时候会议被锁定(EC6.0组网下内置会议一键入会流程处理)
    ECSConferenceCommonError = 10998,   // 通用错误
    ECSConferenceErrorCodeEnd = 10999

    
};

typedef NS_ENUM(NSInteger, ECSPublicAccountErrorCode)
{
    ECSPublicAccountErrorCodeBegin = 11000,
    
    ECSPublicAccountHistorySessionParamError = 11001, // 公众号历史消息session错误
    ECSPublicAccountQueryConditionError = 11002, // 向服务器查询公众号的条件不正确
    ECSPublicAccountSubscribeExistError = 11003, // 订阅已经存在的公众号
    ECSPublicAccountDownloadHDIconError = 11004, // 下载公众号高清头像错误
    ECSPublicAccountSubscribePaError = 11005, // 订阅公众号错误，公众号为空
    
    ECSPublicAccountErrorCodeEnd = 11999
};

typedef NS_ENUM(NSInteger, ECSLightAppErrorCode)
{
    ECSLightAppErrorCodeBegin = 12000,
    
    ECSLightAppErrorCodeEnd = 12999
};

typedef NS_ENUM(NSInteger, ECSCircleColleagueErrorCode)
{
    ECSCircleColleagueErrorCodeBegin = 13000,
    
    ECSCircleColleagueUMUploadingError = 13001, // 正在上传UM
    ECSCircleColleagueUMUploadFailedError = 13002, // UM上传失败
    
    ECSCircleColleagueErrorCodeEnd = 13999
};

typedef NS_ENUM(NSInteger, ECSVoiceMailErrorCode)
{
    ECSVoiceMailErrorCodeBegin = 14000,
    
    ECSVoiceMailErrorCodeEnd = 14999
};

typedef NS_ENUM(NSInteger, ECSSettingErrorCode)
{
    ECSSettingErrorCodeBegin = 15000,
    
    ECSSettingSelfStatusMapError = 15001,
    
    ECSSettingDefHeadImageError = 15002,
    
    ECSSettingSysHeadImageError = 15003,
    
    ECSSettingErrorCodeError = 15999
};

typedef NS_ENUM (NSInteger, ECSSvnErrorCode)
{
    ECSSvnAccountLockedError = -16, // 安全网关帐号已被锁定，请稍候再试或联系管理员
    ECSSvnAccountOrPasswordError = -5, // 安全网关帐号或密码错误
    ECSSvnNoResponseError = -4, // 安全网关无响应
// 以上是svn库返回的错误类型

    ECSSvnErrorCodeBegin = 16000,
    
    ECSSvnUnknowError = 16001, // 未知错误
    ECSSvnConnectedFailedError = 16002, // svn 连接失败
    
    ECSSvnErrorCodeEnd = 16999
};

typedef NS_ENUM(NSInteger, ECSDBUpdateErrorCode)
{
    ECSDBUpdateErrorCodeBegin = 17000,
    
    ECSDBUpdateOldConfigNotExistError = 17001, // 旧版本 UserConfig 不存在
    
    ECSDBUpdateErrorCodeEnd = 17999
};

typedef NS_ENUM(NSInteger, ECSEventRecordErrorCode)
{
    ECSEventRecordErrorCodeBegin = 18000,
    
    ECSEventRecordNoRecodeToReportError = 18001, // 没有需要报告的数据
    
    ECSEventRecordErrorCodeEnd = 18999
};
