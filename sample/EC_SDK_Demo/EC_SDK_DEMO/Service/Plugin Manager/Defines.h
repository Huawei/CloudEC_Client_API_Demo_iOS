//
//  Defines.h
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

#import <Foundation/Foundation.h>

#define RETURN_NO_IF_NIL(result)     if(result == nil || !result || result == NULL){return NO;}
#define RETURN_IF_NSSTRING_NIL(result)     if(result == nil || !result || result == NULL || [result isEqualToString:@""]){return;}
#define RETURN_NO_IF_NSSTRING_NIL(result)     if(result == nil || !result || result == NULL || [result isEqualToString:@""]){return NO;}
#define RETURN_IF_NIL(result)     if(result == nil || !result || result == NULL){return;}
#define RETURN_NO_IF_FAIL(result)  do { if (result == TUP_FAIL) { return NO; } } while(0)
#define SDK_CONFIG_RESULT(result)  (((TUP_SUCCESS) == result)?@"YES":[NSString stringWithFormat:@"NO error =%d",result])

#define EC_SET_CONF_MODE_NOTIFY  @"EC_SET_CONF_MODE_NOTIFY"
#define EC_COMING_CONF_NOTIFY  @"EC_COMING_CONF_NOTIFY"
#pragma mark - Call

extern NSString *const SIP_STATUS_KEY;                  // current sip register status: CALL_E_REG_STATE
extern NSString *const CALL_ERROR_CODE;                 // value: NSInteger
extern NSString *const CALL_ID;                         // Current call id value: NSString
extern NSString *const CALL_TYPE;                       // Current call type value: ∂
extern NSString *const CALL_CLOSE_REASON;               // call end reason value: CALL_E_REASON_CODE
extern NSString *const CALL_COMMING_NUMBER;             // coming call number value: NSString
extern NSString *const CALL_VIDEO_OPERATION;            // call opreation type value: CALL_VIDEO_OPERATION_TYPE
extern NSString *const CALL_VIDEO_OPERATION_RESULT;     // call opreation result value: BOOL
extern NSString *const CALL_VIDEO_ORIENT_KEY;           // call video show orient
extern NSString *const TSDK_CALL_INFO_KEY;               // CallInfo
extern NSString *const TSDK_CALL_HOLD_RESULT_KEY;        // value: BOOL
extern NSString *const TSDK_CALL_UNHOLD_RESULT_KEY;      // value: BOOL
extern NSString *const TSDK_CALL_TRANSFER_RESULT_KEY;    // value: BOOL
extern NSString *const TUP_CALL_SET_IPT_RESULT_KEY;     // value: BOOL
extern NSString *const TUP_CALL_IPT_ENUN_KEY;           // value: enum
extern NSString *const TSDK_CALL_RINGBACK_KEY;           // value: BOOL , is play media
extern NSString *const TUP_CALL_SESSION_MODIFIED_KEY;   // value: NSString , confId
extern NSString *const AUDIO_ROUTE_KEY;                 // value: NSNumber
extern NSString *const TSDK_VIEW_REFRESH_KEY;                 // value: NSNumber
//CTD
extern NSString *const TSDK_CTD_CALL_RESULT_KEY;
extern NSString *const TSDK_CTD_CALL_STATE_KEY;
//conf id
extern NSString *const TUP_CALL_DATACONF_ID_KEY;

//tup video
extern NSString *const TUP_CALL_DECODE_SUCCESS_NOTIFY;
extern NSString *const TUP_CALL_REFRESH_VIEW_NOTIFY;

extern NSString *const TUP_CALL_REMOVE_CALL_VIEW_NOTIFY;

extern NSString *const TUP_CONF_INCOMING_KEY;

extern NSString *const LOGIN_UNREGISTERED_RESULT;
extern NSString *const SRTP_TRANSPORT_MODE;
/**
 * [en]This enumeration is used to describe the call type.
 * [cn]∫ÙΩ–¿‡–Õ
 */
typedef enum tagTSDK_CALL_E_CALL_TYPE
{
    TSDK_CALL_E_CALL_TYPE_IPAUDIO,        /**< [en]Indicates IP audio call
                                      <br>[cn]IP”Ô“Ù∫ÙΩ– */
    TSDK_CALL_E_CALL_TYPE_IPVIDEO,        /**< [en]Indicates IP video call
                                      <br>[cn]IP ”∆µ∫ÙΩ– */
    TSDK_CALL_E_CALL_TYPE_BUTT            /**< [en]Indicates invalid type call
                                      <br>[cn]Œﬁ–ß¿‡–Õ∫ÙΩ– */
} TSDK_CALL_E_CALL_TYPE;

/**
 *This enum is about call enum
 *呼叫事件枚举
 */
typedef enum
{
    CALL_SIP_REGISTER_STATUS,
    CALL_CREATE_RESULT,
    CALL_CONNECT,                   /**<call have benn connect event，CALL_ID、CALL_TYPE*/
    CALL_INCOMMING,                 /**<incoming call event，CALL_ID、CALL_COMMING_NUMBER*/
    CALL_RINGBACK,
    CALL_VIEW_REFRESH,              /**<video view refresh event，nil*/
    CALL_DECDOE_SUCCESS,            /**<video swimming decode success event，nil*/
    CALL_MODIFY_VIDEO_RESULT,       /**<conversion between audio and video call (the calling party receive)，CALL_ID、CALL_VIDEO_OPERATION、CALL_VIDEO_OPERATION_RESULT*/
    CALL_UPGRADE_VIDEO_PASSIVE,     /**<upgrade to video call(the called party receive)，CALL_ID*/
    CALL_DOWNGRADE_VIDEO_PASSIVE,   /**<downgrage to audio call (the called party receive)，CALL_ID*/
    CALL_CLOSE,                      /**<call end，CALL_ID、CALL_CLOSE_REASON*/
    CALL_DESTROY,
    CALL_HOLD_RESULT,                      /**<call hold result*/
    CALL_UNHOLD_RESULT,                      /**<call unhold result*/
    CALL_TRANSFER_RESULT,
    CALL_DIVERT_FAILED,
    CALL_SET_IPT_RESULT,
    CALL_CW_INCOMMING,
    CALL_SESSION_MODIFIED,
    CALL_REFER_NOTIFY,
    CALL_OUTGOING,
    CALL_REFUSE_OPEN_VIDEO
}TUP_CALL_EVENT_TYPE;

/**
 *This enum is about ctd event type
 *ctd事件枚举
 */
typedef enum
{
    CTD_CALL_RESULT,
    CTD_CALL_END_RESULT,
    CTD_CALL_STATE
}TUP_CTD_EVENT_TYPE;

/**
 *This enum is about ipt service type
 *ipt类型枚举
 */
typedef NS_ENUM(NSUInteger, CALL_SERVICE_TYPE) {
    CALL_SERVICE_TYPE_BEGIN,
    CALL_SERVICE_TYPE_DND,
    CALL_SERVICE_TYPE_CALL_WAIT,
    CALL_SERVICE_TYPE_CFU,
    CALL_SERVICE_TYPE_CFB,
    CALL_SERVICE_TYPE_CFN,
    CALL_SERVICE_TYPE_CFO,
    CALL_SERVICE_TYPE_CFU_TO_VM,
    CALL_SERVICE_TYPE_CFB_TO_VM,
    CALL_SERVICE_TYPE_CFN_TO_VM,
    CALL_SERVICE_TYPE_CFO_TO_VM,
    CALL_SERVICE_TYPE_CALL_ALTERT,
    CALL_SERVICE_TYPE_BUTT
};

/**
 *This enum is about speaker route type
 *耳机类型
 */
typedef NS_ENUM(NSUInteger, ROUTE_TYPE) {
    ROUTE_DEFAULT_TYPE = 0,         // 默认语音设备， 优先级顺序: 蓝牙耳机>有线耳机>听筒
    ROUTE_LOUDSPEAKER_TYPE = 1,
    ROUTE_BLUETOOTH_TYPE = 2,
    ROUTE_EARPIECE_TYPE = 3,
    ROUTE_HEADSET_TYPE = 4,
};

/**
 *This enum is about device type
 *设备类型
 */
typedef NS_ENUM(NSUInteger, DEVICE_TYPE) {
    DEVICE_TYPE_MIC,
    DEVICE_TYPE_SPEAK,
    DEVICE_TYPE_VIDEO,
};

/**
 *This enum is about media pt
 *媒体pt
 */
typedef enum : NSInteger
{
    PT_105 = 105,
    PT_106,
    PT_107,
    PT_108,
} enMediaPt;

/**
 *This enum is about media pt packet mode
 *媒体pt模式
 */
typedef enum : NSInteger
{
    PACKET_MODE_SINGLE = 0,
    PACKET_MODE_NON_INTERLEAVED,
    PACKET_MODE_INTERLEAVED,
} enMediaPtPacketMode;

/**
 *This enum is about media level mode
 *媒体级别
 */
typedef enum : NSInteger
{
    SYMMETRY_LEVEL = 0,
    NOSYMMETRY_LEVEL,
} enMediaLevelMode;

/**
 *This enum is about media band width
 *媒体带宽
 */
typedef enum
{
    EN_CALL_MEDIA_BANDWIDTH_0    = 0,
    EN_CALL_MEDIA_BANDWIDTH_8    = 8,
    EN_CALL_MEDIA_BANDWIDTH_64   = 64,
    EN_CALL_MEDIA_BANDWIDTH_128  = 128,
    EN_CALL_MEDIA_BANDWIDTH_192  = 192,
    EN_CALL_MEDIA_BANDWIDTH_212  = 212,
    EN_CALL_MEDIA_BANDWIDTH_256  = 256,
    EN_CALL_MEDIA_BANDWIDTH_300  = 300,
    EN_CALL_MEDIA_BANDWIDTH_384  = 384,
    EN_CALL_MEDIA_BANDWIDTH_468  = 468,
    EN_CALL_MEDIA_BANDWIDTH_512  = 512,
    EN_CALL_MEDIA_BANDWIDTH_768  = 768,
    EN_CALL_MEDIA_BANDWIDTH_1024 = 1024,
    EN_CALL_MEDIA_BANDWIDTH_1536 = 1536,
    EN_CALL_MEDIA_BANDWIDTH_1792 = 1792,
    EN_CALL_MEDIA_BANDWIDTH_1920 = 1920,
    EN_CALL_MEDIA_BANDWIDTH_2560 = 2560,
    EN_CALL_MEDIA_BANDWIDTH_NULL
}EN_CALL_MEDIA_BANDWIDTH;

/**
 *This enum is about video rotate
 *视频方向
 */
typedef NS_ENUM(NSInteger, VIDEO_ROTATE)
{
    ROTATE_DEFAULT = 0,//no rotation
    ROTATE_90 = 90,//anticlockwise rotation 90°
    ROTATE_180 = 180,//anticlockwise rotation 180°
    ROTATE_270 = 270//anticlockwise rotation 270°
};

/**
 *This enum is about video operation type
 *通话类型转换
 */
typedef enum
{
    CALL_VIDEO_OPERATION_TYPE_NOCONTROL = 0, //no control
    CALL_VIDEO_OPERATION_TYPE_UPGRADE = 1,   //upgrade to video call
    CALL_VIDEO_OPERATION_TYPE_DOWNGRADE = 2, //downgrade to audio call
}CALL_VIDEO_OPERATION_TYPE;

/**
 *This enum is about camera operation type
 *摄像头操作
 */
typedef enum
{
    OPEN  = 0x01,   //open camera
    CLOSE = 0x02,   //close camera
    START = 0x04,   //start video
    OPEN_AND_START = 0x05, //open camera and start video
    STOP  = 0x08    //stop video
}EN_VIDEO_OPERATION;

/**
 *This enum is about video operation module
 *摄像头操作
 */
typedef enum
{
    REMOTE = 0x01,  //Remote screen operation
    LOCAL  = 0x02,  //local screen operation
    LOCAL_AND_REMOTE = 0x03, //remote and local screen opration
    CAPTURE = 0x04, //camera operation
    ENCODER = 0x08, //encoder
    DECODER = 0x10, //decoder
    RESTARTCAPTUREANDENCODER = 0x0C //restart capture and encoder
}EN_VIDEO_OPERATION_MODULE;

/**
 *This enum is about point at remote video show mode
 *远端视频显示模式
 */
typedef NS_ENUM(NSUInteger, VIDEO_SHOWMODE)
{
    TILE_MODE = 0,//Video is full of windows
    SCALE_MODE = 1,//According to the proportion of video display, the empty part of the black fill
    SLIM_MODE = 2//Clipping by window size
};

/**
 *This enum is about param table type
 *视频清晰与流畅度选项
 */
typedef enum : NSInteger
{
    PARAM_TABLE_VIDEO_DEFINITION = 0,	//clear
    PARAM_TABLE_VIDEO_SMOOTHER ,		//Fluent
} PARAM_TABLE_TYPE;

//************* UC***************
/**
 *This enum is about camera index
 *前后摄像头序号
 */
typedef NS_ENUM(NSInteger, CameraIndex)
{
    CameraIndexBack,
    CameraIndexFront
};

#pragma mark - Login
extern NSString *const UPORTAL_LOGIN_EVT_RESULT_KEY;
extern NSString *const LOGIN_FIREWALL_DETECT_RESULT;     // value: BOOL
extern NSString *const LOGIN_FIREWALL_MODE_KEY;          // value: TUP_FIREWALL_MODE
extern NSString *const LOGIN_STG_TUNNEL_CREATE_RESULT_KEY; // value: BOOL

typedef NS_ENUM(NSUInteger, TUP_LOGIN_EVENT_TYPE)
{
    LOGINOUT_EVENT,
};

/**
 *This enum is about login status type
 *登陆状态类型
 */
typedef enum
{
    LOGIN_STATUS_ONLINE,
    LOGIN_STATUS_OFFLINE,
    LOGIN_STATUS_BUTT
}LOGIN_STATUS_TYPE;

/**
 *This enum is about login result type
 *登陆结果类型
 */
typedef NS_ENUM(NSUInteger, TUPSERVICE_LOGIN_RESULT_TYPE)
{
    LOGIN_TYPE_SUCCESS,
    LOGIN_TYPE_ERROR_ACCOUNT_ISNIL,
    LOGIN_TYPE_ERROR_PASSWORD_ISNIL,
    LOGIN_TYPE_ERROR_PORT_ISNOTALLNUMBER,
    LOGIN_TYPE_ERROR_ADDRESS,
    LOGIN_TYPE_FAIL
};

/**
 *This enum is about firewall mode
 *防火墙模式
 */
typedef NS_ENUM(NSUInteger, TUP_FIREWALL_MODE) {
    TUP_FIREWALL_MODE_ONLY_HTTP,
    TUP_FIREWALL_MODE_HTTPANDSVN,
    TUP_FIREWALL_MODE_NONE,
};

/**
 *This enum is about audio record status
 *音频录制状态
 */
typedef enum
{
    AudioRecordStatus_NotStart = 1,
    AudioRecordStatus_Recording = 2,
    AudioRecordStatus_NearTimerEnd = 3,
    AudioRecordStatus_TimerEndedGood = 4,
    AudioRecordStatus_TimerEndedBad = 5,
    AudioRecordStatus_Cancelled = 6,
    AudioRecordStatus_LongPressUpCauseEnded = AudioRecordStatus_NotStart,
    AudioRecordStatus_Interrupted = AudioRecordStatus_NotStart,
} AudioRecordStatus;

/**
 *This enum is about audio record action
 *音频录制动作
 */
typedef enum
{
    AudioRecordAction_StartCounting = -1,
    AudioRecordAction_TimerEndRecord = -2,
    AudioRecordAction_Touch = 1,
    AudioRecordAction_Up = 2,
    AudioRecordAction_Interrupted = 3,
    AudioRecordAction_Cancelled = 4
}AudioRecordAction;

extern NSString *const UCCONF_CONFDATA_KEY;                 //  value: ConfData
extern NSString *const UCCONF_END_KEY;                      //  value: bool
extern NSString *const UCCONF_INCOMMING_KEY;                //  value: NSString
extern NSString *const UCCONF_RESULT_KEY;                   //  value: BOOL

extern NSString *const UCCONF_SET_PERSENTER_RESULT_KEY;     //  value: BOOL
extern NSString *const UCCONF_SET_HOST_RESULT_KEY;          //  value: BOOL
extern NSString *const UCCONF_OLDPERSENTER_KEY;             //  value: nsnumber
extern NSString *const UCCONF_OLDHOST_KEY;                  //  value: nsnumber
extern NSString *const UCCONF_NEWPERSENTER_KEY;             //  value: nsnumber
extern NSString *const UCCONF_NEWHOST_KEY;                  //  value: nsnumber

/**
 *This enum is about meeting event type
 *会议事件类型
 */
typedef enum
{
    MEETING_CREATE_RESULT,
    MEETING_CONNECT,
    MEETING_ATTENDEE_UPDATE_INFO,
    MEETING_CREATE_HANDLE,
    MEETING_DESTROY_HANDLE,
    MEETING_WATCH_SITE_RESULT = 5,
    MEETING_REQUEST_CHAIRMAN_RESULT,
    MEETING_RELEASE_CHAIRMAN_RESULT,
    MEETING_BROADCAST_SITE_RESULT,
    MEETING_LOCAL_BROADCAST_STATUS_CHANGE,
    MEETING_POSTPONE_SITE_RESULT = 10,
    MEETING_FORCE_RELEASE_CHAIRMAN_NOTIFY,
    MEETING_EXISTS_CHAIRMAN_NOTIFY,
    MEETING_CURRENT_WATCH_SITE,
    MEETING_TIME_RENMENT,
    MEETING_NEED_PASSWORD_TO_BE_CHAIRMAN,
}MEETING_EVENT_TYPE;



#pragma mark - TE BFCP
/**
 *This enum is about bfcp event type
 *bfcp 事件类型
 */
typedef NS_ENUM(NSUInteger, BFCP_EVNET_TYPE)
{
    BFCP_RECVING_EVENT,
    BFCP_DECODE_SUCCESS_EVENT,
    BFCP_STOPPED_EVENT,
    BFCP_START_FAILURE_EVENT,
};

/**
 *This enum is about log level
 *日志级别
 */
typedef NS_ENUM(NSInteger, LOG_LEVEL)
{
    LOG_ERROR   = 0,
    LOG_WARNING = 1,
    LOG_INFO    = 2,
    LOG_DEBUG   = 3,
    LOG_NONE    = 9
};

#pragma mark - UC Conference
/**
 *This enum is about conference event type
 *会议事件类型
 */
typedef enum
{
    CONFERENCE_CREATE_RESULT,
    CONFERENCE_CONNECT,
    CONFERENCE_ATTENDEE_UPDATE_INFO,
    CONFERENCE_END,
    CONFERENCE_ADD_ATTENDEE,
    CONFERENCE_DELETE_ATTENDEE,
    CONFERENCE_INCOMMING,
    CONFERENCE_MODIFYATTENDEE_RESULT,
    CONFERENCE_ATTENDEE_JOIN_SUCCESS,
    CONFERENCE_ATTENDEE_JOIN_FAILED,
    CONFERENCE_LOCK_STATUS_CHANGE,
}TUP_CONFERENCE_EVENT_TYPE;

/**
 *This enum is about data conference event type
 *数据会议事件类型
 */
typedef enum : NSUInteger {
    DATA_CONFERENCE_JOIN_RESULT,
    DATA_CONFERENCE_END,
    DATA_CONFERENCE_LEAVE,
    DATACONF_VEDIO_ON_SWITCH,
    DATACONF_VEDIO_ON_NOTIFY,
    DATACONF_RECEIVE_SHARE_DATA,
    DATACONF_SHARE_STOP,
    DATACONF_USER_ENTER,
    DATACONF_USER_LEAVE,
    DATACONF_REMOTE_CAMETAINFO,
    // user role
    DATACONF_PERSENTER_CHANGE,
    DATACONF_HOST_CHANGE,
    DATACONF_SET_HOST_RESULT,
    DATACONF_SET_PERSENTER_RESULT,
    DATACONF_GET_HOST,
    DATACONF_GET_PERSENT,
    DATACONF_BFCP_SHARE,
} TUP_DATA_CONFERENCE_EVENT_TYPE;

extern NSString *const DATACONF_SHARE_DATA_KEY;
extern NSString *const DATACONF_FINISH_SHARE_KEY;
extern NSString *const DATACONF_VIDEO_ON_SWITCH_KEY ;
extern NSString *const DATACONF_VIDEO_ON_SWITCH_USERID_KEY;
extern NSString *const DATACONF_VIDEO_ON_NOTIFY_KEY;
extern NSString *const DATACONF_USER_LEAVE_KEY;
extern NSString *const DATACONF_USER_ENTER_KEY;
extern NSString *const DATACONF_CHAT_MSG_KEY;
extern NSString *const DATACONF_REMOTE_CAMERA_KEY;

typedef NS_ENUM(NSUInteger, ConfType) {
    AudioConfType = 1,
    DataConfType = 3
};

#pragma mark - EC6.0 conference
extern NSString *const ECCONF_RESULT_KEY;
extern NSString *const ECCONF_LIST_KEY;
extern NSString *const ECCONF_CURRENTCONF_DETAIL_KEY ;
extern NSString *const ECCONF_BOOK_CONF_INFO_KEY;
extern NSString *const ECCONF_ATTENDEE_UPDATE_KEY ;
extern NSString *const ECCONF_MUTE_KEY ;
extern NSString *const ECCONF_SPEAKERLIST_KEY ;

extern NSString *const ECCONF_DATA_CONF_BFCP_KEY;

/**
 *This enum is about data conf user role type
 *数据会议用户类型
 */
typedef NS_ENUM(NSUInteger, DATACONF_USER_ROLE_TYPE)
{
    DATACONF_USER_ROLE_HOST = 0x0001,
    DATACONF_USER_ROLE_PRESENTER = 0x0002,
    DATACONF_USER_ROLE_GENERAL = 0x0008,
};

/**
 *This enum is about data conf attendee media state
 *与会者角色
 */
typedef NS_ENUM(NSInteger, DataConfAttendeeMediaState){
    DataConfAttendeeMediaStateLeave   = 0,    //不在多媒体会议中
    DataConfAttendeeMediaStateIn      = 1,    //在多媒体会议中,为普通与会者
    DataConfAttendeeMediaStatePresent = 2     //在多媒体会议中，且为主讲人
};

/**
 *This enum is about uportal data conf param getting type
 *数据会议大参数获取类型
 */
typedef NS_ENUM(NSInteger, UportalDataConfParamGetType)
{
    UportalDataConfParamGetTypePassCode = 1,
    UportalDataConfParamGetTypeConfIdPassWord = 2,
    UportalDataConfParamGetTypeConfIdPassWordRandom = 3
};

/**
 *This enum is about conf event type
 *会议事件类型
 */
typedef enum
{
    CONF_E_CONNECT,
    CONF_E_INCOMMING,
    CONF_E_CREATE_RESULT,
    CONF_E_END_RESULT,
    CONF_E_CURRENTCONF_DETAIL,
    CONF_E_GET_CONFLIST,
    CONF_E_ATTENDEE_UPDATE_INFO,
    CONF_E_ADD_ATTENDEE_RESULT,
    CONF_E_MUTE_RESULT,
    CONF_E_DELETE_ATTENDEE_RESULT,
    CONF_E_HANGUP_ATTENDEE_RESULT,
    CONF_E_CANLISTEN_ATTENDEE_RESULT,
    CONF_E_RAISEHAND_ATTENDEE_RESULT,
    CONF_E_HANDUP_ATTENDEE_RESULT,
    CONF_E_MUTE_ATTENDEE_RESULT,
    CONF_E_RELEASE_CHAIRMAN_RESULT,
    CONF_E_REQUEST_CHAIRMAN_RESULT,
    CONF_E_LOCK_STATUS_CHANGE,
    CONF_E_SPEAKER_LIST,
    CONF_E_UPGRADE_RESULT,
    DATA_CONF_JOIN_RESOULT,
    DATA_CONF_AS_ON_SCREEN_DATA,
    DATACONF_SHARE_SCREEN_DATA_STOP
}EC_CONF_E_TYPE;

/**
 *This enum is about conf media type
 *会议媒体类型
 */
typedef enum
{
    CONF_MEDIATYPE_VOICE,
    CONF_MEDIATYPE_VIDEO,
    CONF_MEDIATYPE_DATA ,
    CONF_MEDIATYPE_VIDEO_DATA,  //视频+多媒体会议(uPortal组网下)
    CONF_MEDIATYPE_DESKTOPSHARING
}EC_CONF_MEDIATYPE;

/**
 *This enum is about conf mode
 *会议模式
 */
typedef enum
{
    EC_CONF_MODE_FIXED,
    EC_CONF_MODE_VAS,
    EC_CONF_MODE_FREE
} EC_CONF_MODE;

/**
 *This enum is about conf attendee role type
 *与会者角色类型
 */
typedef NS_ENUM(NSUInteger, CONFCTRL_CONF_ROLE) {
    CONF_ROLE_ATTENDEE,
    CONF_ROLE_CHAIRMAN,
    CONF_ROLE_BUTT
};

/**
 *This enum is about attendee status type
 *与会者状态类型
 */
typedef enum
{
    ATTENDEE_STATUS_IN_CONF = 0,
    ATTENDEE_STATUS_CALLING,
    ATTENDEE_STATUS_JOINING,
    ATTENDEE_STATUS_LEAVED,
    ATTENDEE_STATUS_NO_EXIST,
    ATTENDEE_STATUS_BUSY,
    ATTENDEE_STATUS_NO_ANSWER,
    ATTENDEE_STATUS_REJECT,
    ATTENDEE_STATUS_CALL_FAILED
} ATTENDEE_STATUS_TYPE;

/**
 *This enum is about network type
 *组网类型
 */
typedef enum
{
    CONF_TOPOLOGY_UC,
    CONF_TOPOLOGY_SMC,
    CONF_TOPOLOGY_MEDIAX,
    CONF_TOPOLOGY_BUTT
} EC_CONF_TOPOLOGY_TYPE;

/**
 *This enum is about srtp mode
 *srtp模式
 */
typedef enum{
    SRTP_MODE_OPTION = 0,
    SRTP_MODE_DISABLE,
    SRTP_MODE_FORCE
}SRTP_MODE;

/**
 *This enum is about transport mode
 *信令传输模式
 */
typedef enum{
    TRANSPORT_MODE_UDP = 0,
    TRANSPORT_MODE_TLS,
    TRANSPORT_MODE_TCP
}TRANSPORT_MODE;

/**
 *This enum is about security tunnel use mode
 *安全隧道使用模式
 */
typedef enum{
    TUNNEL_MODE_DEFAULT = 0,
    TUNNEL_MODE_DISABLE,
    TUNNEL_MODE_FORCE
}TUNNEL_MODE;

/**
 *This enum is about config priority type
 *采用配置的优先级
 */
typedef enum{
    CONFIG_PRIORITY_TYPE_SYSTEM = 0,
    CONFIG_PRIORITY_TYPE_APP
}CONFIG_PRIORITY_TYPE;

@interface Defines : NSObject

@end
