//
//  Defines.h
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

#import <Foundation/Foundation.h>
#import <sys/utsname.h>

#define RETURN_NO_IF_NIL(result)     if(result == nil || !result || result == NULL){return NO;}
#define RETURN_IF_NSSTRING_NIL(result)     if(result == nil || !result || result == NULL || [result isEqualToString:@""]){return;}
#define RETURN_NO_IF_NSSTRING_NIL(result)     if(result == nil || !result || result == NULL || [result isEqualToString:@""]){return NO;}
#define RETURN_IF_NIL(result)     if(result == nil || !result || result == NULL){return;}
#define RETURN_NO_IF_FAIL(result)  do { if (result == TUP_FAIL) { return NO; } } while(0)
#define SDK_CONFIG_RESULT(result)  (((TUP_SUCCESS) == result)?@"YES":[NSString stringWithFormat:@"NO error =%d",result])

///< 判断设备是否为iPhone X
#define KISIphoneX \
({\
struct utsname systemInfo;\
uname(&systemInfo);\
NSString *deviceTypeString = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];\
BOOL isIphone = ([deviceTypeString containsString:@"iPhone10,3"] || [deviceTypeString containsString:@"iPhone10,6"] || [deviceTypeString containsString:@"iPhone11,2"] || [deviceTypeString containsString:@"iPhone11,4"] || [deviceTypeString containsString:@"iPhone11,6"] || [deviceTypeString containsString:@"iPhone11,8"]);\
isIphone;\
})

#define EC_SET_CONF_MODE_NOTIFY  @"EC_SET_CONF_MODE_NOTIFY"

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
extern NSString *const CALL_STATISTIC_INFO;

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


extern NSString *const SERVER_CONFIG;
extern NSString *const USER_ACCOUNT;
extern NSString *const USER_PASSWORD;
extern NSString *const NEED_AUTO_LOGIN;

extern NSString *const LOGIN_GET_TEMP_USER_INFO_FAILD;
extern NSString *const LOGIN_AUTH_FAILED;

extern NSString *const CONF_QUITE_TO_CONFLISTVIEW;

/* [en]xxxx. [cn]点对点聊天消息通知 */
extern NSString* const TUP_RECEIVE_SINGLE_MESSAGE_NOTIFY;
/* [en]xxxx. [cn]群组聊天消息通知 */
extern NSString* const TUP_RECEIVE_GROUP_MESSAGE_NOTIFY;

extern NSString *const NTF_AUDIOROUTE_CHANGED; // audio route changed notification

extern NSString *const NTF_MULTI_MEDIA_CONF_SHOULD_HAS_ANNO;

extern NSString *const APP_START_SYSTEM_SHARE_VIEW;

extern NSString *const CONF_SHARE_REQUEST_ACTION;

extern NSString* const TSDK_COMING_CALL_NOTIFY;

extern NSString* const EC_COMING_CONF_NOTIFY;

extern NSString* const CONF_ATTENDEE_STATUS_UPDATE_NOTIFY;

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
    CALL_REFUSE_OPEN_VIDEO,
    CALL_EVT_STATISTIC_INFO
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
    OPEN_AND_START = 0x05,
    STOP  = 0x08,    //stop video
    CLOSE_AND_STOP = 0xa,
    PAUSE = 0x10,   //paused video
    RESUME = 0x20   // restarted video
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
    LOCAL_AND_CAPTURE = 0x06,
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
    LOGININ_EVENT,
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
    DATACONF_SHARE_SCREEN_DATA_STOP,
    CONF_E_SVC_WATCH_INFO_IND,
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

typedef NS_ENUM(NSUInteger, CreateGroupType)
{
    ADD_USER                =    0,                        //add user
    CREATE_GROUP            =    1,                        //create group
};

typedef NS_ENUM(NSInteger, GroupInfoModifyType)
{
    GroupInfoModifyTypeName,           // modify name
    GroupInfoModifyTypeAnnounce,       // modify announce
    GroupInfoModifyTypeIntroduction    // modify introduction
};

typedef enum
{
    TRANSFER_CALL,
    AUDIO_ANSWER_COMMING_CALL,
    VIDEO_ANSWER_COMMING_CALL,
    REFUSE_COMMING_CALL
}COMMING_VIEW_BTNACTION_TYPE;

typedef enum
{
    JOIN_CALL_BUTTON,
    CLOSE_CALL_BUTTON,
    CHANGE_SOUND_ROUTE_BUTTON,
    DIAL_NUMBER_BUTTON,
    CHANGE_CALL_TYPE_BUTTON,
    CLOSE_CAMERA_BUTTON,
    SWITCH_CAMERA_BUTTON,
    ROUTE_BUTTON,
    TRANSFER_BUTTON,
    HOLD_BUTTON,
    MUTE_MIC_BUTTON,
    SITE_LIST_BUTTON,
    DATA_CONFERENCE_BUTTON
}CALL_TOOLBAR_BUTTON_TYPE;

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

/**
 * [en]This enum is about user status.
 * [cn]用户状态
 */
typedef NS_ENUM(NSInteger, ESpaceUserStatus) {
    ESpaceUserStatusUnknown = -1,       /**< [en]Indicates unknown.
                                             <br>[cn] 未知*/
    ESpaceUserStatusOffline = 0,        /**< [en]Indicates offlilne.
                                             <br>[cn] 离线 */
    ESpaceUserStatusAvailable,          /**< [en]Indicates available.
                                             <br>[cn] 在线 */
    ESpaceUserStatusHiddeen,            /**< [en]Indicates hidden (no supported)
                                             <br>[cn]隐身 (暂不支持) */
    ESpaceUserStatusBusy,               /**< [en]Indicates status busy.
                                             <br>[cn] 繁忙 */
    ESpaceUserStatusAway,               /**< [en]Indicates status away.
                                             <br>[cn] 离开 */
    ESpaceUserStatusUninteruptable,     /**< [en]Indicates uninteruptable.
                                             <br>[cn] 请勿打扰 */
    ESpaceUserStatusButt
};

///**
// * [en]This enum is about im message status.
// * [cn]IM消息状态
// */
//typedef NS_ENUM(NSUInteger, ESpaceMessageStatus) {
//    ESpaceMsgStatusReceived = 0,                                        /**< [en]Indicates received.
//                                                                         <br>[cn] 接收成功 */
//    ESpaceMsgStatusSended = ESpaceMsgStatusReceived,                    /**< [en]Indicates sended.
//                                                                         <br>[cn] 发送成功 */
//    ESpaceMsgStatusDraft = 0x10000,                                     /**< [en]Indicates drafy.
//                                                                         <br>[cn] 草稿 */
//    ESpaceMsgStatusSending = 0x20000,                                   /**< [en]Indicates sending.
//                                                                         <br>[cn] 发送中 */
//    ESpaceMsgStatusReceiving = ESpaceMsgStatusSending,                  /**< [en]Indicates receiving.
//                                                                         <br>[cn] 接收中 */
//
//    ESpaceMsgStatusSendFailed = 0x40000,                                /**< [en]Indicates send failed.
//                                                                         <br>[cn] 发送失败 */
//    ESpaceMsgStatusReceiveFaied = ESpaceMsgStatusSendFailed,            /**< [en]Indicates receive faied.
//                                                                         <br>[cn] 接收失败 */
//
//    ESpaceMsgStatusSendCancelled = 0x80000,                             /**< [en]Indicates send cancelled.
//                                                                         <br>[cn] 取消发送 */
//    ESpaceMsgStatusReceiveCancelled = ESpaceMsgStatusSendCancelled      /**< [en]Indicates receive cancelled.
//                                                                         <br>[cn] 取消接收 */
//};
//
///**
// * [en]This enum is about message type.
// * [cn]消息类型
// */
//typedef NS_ENUM(NSInteger, ESpaceContentType) {
//    ESpaceUnknowContentType = -1,       /**< [en]Indicates unknow type.
//                                         <br>[cn]类型未知 */
//    ESpaceTextContentType = 0,          /**< [en]Indicates text.
//                                         <br>[cn]文本 */
//    ESpaceAudioContentType = 1,         /**< [en]Indicates audio .
//                                         <br>[cn]语音 */
//    ESpaceVideoContentType = 2,         /**< [en]Indicates video.
//                                         <br>[cn]视频 */
//    ESpaceImageContentType = 3,         /**< [en]Indicates picture.
//                                         <br>[cn]图片 */
//    ESpaceFileContentType = 4,          /**< [en]Indicates file.
//                                         <br>[cn]文件 */
//    ESpacePublicAccountContentType = 5, /**< [en]Indicates public account forward message.
//                                         <br>[cn]公众号转发消息 */
//    ESpaceShareLinkContentType = 7,     /**< [en]Indicates picture link.
//                                         <br>[cn]图文链接 */
//    ESpaceMixContentType = 8,           /**< [en]Indicates picture mix.
//                                         <br>[cn]图文混排 */
//    ESpaceEmailContentType = 9,         /**< [en]Indicates email.
//                                         <br>[cn]email */
//    ESpaceCardMsgSharedType = 10,       /**< [en]Indicates shared type.
//                                         <br>[cn]分享类 */
//    ESpaceCardMsgRecordType = 12,       /**< [en]Indicates record type.
//                                         <br>[cn]记录类 */
//    ESpacePaImageTextContentType = -2,  /**< [en]Indicates image text content.
//                                         <br>[cn]公众号多图文消息 */
//    ESpaceLightAppPaContentType = -3,   /**< [en]Indicates light app content.
//                                         <br>[cn]轻应用公众号消息 */
//    ESpaceCardMsgOrderType = 11
//};

/**
 * [en]This enum is about server login status.
 * [cn]服务器登录状态
 */
typedef NS_ENUM(NSUInteger, ECSLoginServiceStatus) {
    ECServiceOffline = 0,                   /**< [en]Indicates offline.
                                             <br>[cn]网络问题断线 */
    ECServiceSigning = 1,                   /**< [en]Indicates signing.
                                             <br>[cn]正在登录 */
    ECServiceLogin = 2,                     /**< [en]Indicates login success.
                                             <br>[cn]登录成功 */
    ECServiceKickOff = 3,                   /**< [en]Indicates kick off.
                                             <br>[cn]被踢 */
    ECServiceLogout = 4,                    /**< [en]Indicates logout active.
                                             <br>[cn]主动登出 */
    ECServiceInvalidAccountOrPassword = 5,  /**< [en]Indicates invalid account or password.
                                             <br>[cn]账号被锁或者无效、密码错误等错误 */
    ECServiceReconnecting = 6               /**< [en]Indicates reconnecting.
                                             <br>[cn]正在重新链接 */
};

typedef NS_ENUM(NSInteger, ECSGroupType) {
    ECSFixGroup = 0,
    ECSChatGroup = 1
};

typedef NS_ENUM(NSInteger, VideoZoomingViewMarkupColor) {
    VideoZoomingViewMarkupColorBlack,
    VideoZoomingViewMarkupColorRed,
    VideoZoomingViewMarkupColorGreen,
    VideoZoomingViewMarkupColorBlue,
    VideoZoomingViewMarkupColorNotSelected
};

/**
 * [en]This enumeration is used to describe the video window type.
 * [cn]视频窗口类型
 */
typedef NS_ENUM(NSInteger, TsdkVideoWindowType) {
    TsdkVideoWindowRemote = 0,                /**< [en]Indicates remote video window
                                                 [cn]通话远端窗口 */
    TsdkVideoWindowlacal,                     /**< [en]Indicates local video window
                                                 [cn]通话本地窗口 */
    TsdkVideoWindowPreview,                   /**< [en]Indicates preview window
                                                 [cn]预览窗口 */
    TsdkVideoWindowData,                  /**< [en]Indicates auxiliary data window
                                                 [cn]辅流窗口 */
};


@interface Defines : NSObject

@end
