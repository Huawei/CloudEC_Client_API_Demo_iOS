/**
 * @file ECSDefines.h
 *
 * Copyright 2012 Huawei Technologies Co., Ltd. All rights reserved. \n
 *
 * @brief [en]Description:enum value definition class head file.
 * [cn]描述：枚举值定义类头文件。 \n
 **/

#ifdef __cplusplus
#define ECS_EXTERN		extern "C"
#else
#define ECS_EXTERN		extern
#endif


#define CREATENONEXISTPATH(path) do{\
if ([[NSFileManager defaultManager] fileExistsAtPath:path] == NO)	\
{																	\
[[NSFileManager defaultManager] createDirectoryAtPath:path		\
withIntermediateDirectories:YES		\
attributes:nil		\
error:nil];		\
}}while(0)

/**
 * [en]This enum is about video operatin type.
 * [cn]视频通话操作类型
 */
typedef enum {
    ANSWER_VIDEO = 0,	/**< [en]Indicates answer video.
                         <br>[cn]被叫接听升级的邀请 */
    REJECT_VIDEO,		/**< [en]Indicates reject video.
                         <br>[cn]被叫拒绝升级的邀请 */
    CANCEL_VIDEO,		/**< [en]Indicates cancel video.
                         <br>[cn]主叫在没有收到被叫响应前取消邀请 */
    UNKNOW_ACTION
}VIDEO_ACTION;

/**
 * [en]This enum is about video control type.
 * [cn]视频控制类型
 */
typedef enum {
    OPEN_VIDEO = 1,     /**< [en]Indicates open video.
                         <br>[cn]打开视频 */
    CLOSE_VIDEO = 2,    /**< [en]Indicates close video.
                         <br>[cn]关闭视频 */
    START_VIDEO = 4,    /**< [en]Indicates start video.
                         <br>[cn]播放视频 */
    OPENORSTART = 5,    /**< [en]Indicates open or start.
                         <br>[cn]打开或者播放 */
    STOP_VIDEO = 8      /**< [en]Indicates stop video.
                         <br>[cn]停止播放视频 */
}VIDEO_CONTROL;

/**
 * [en]This enum is about video control module.
 * [cn]视频管理模式，取值：
 * [cn]显示远端窗口 0x01
 * [cn]摄相头       0x04
 * [cn]编码器       0x08
 * [cn]解码器       0x10
 */
typedef NS_ENUM(NSUInteger, VIDEO_CONTROL_MODULE) {
    VIDEO_CONTROL_MODULE_CAPTURE = 0x04,                            /**< [en]Indicates video control module capture.
                                                                     <br>[cn]视频控制单纯capture */
    VIDEO_CONTROL_MODULE_RENDER = 0x01 | 0x02,                      /**< [en]Indicates video control module render.
                                                                     <br>[cn]视频控制单纯render */
    VIDEO_CONTROL_MODULE_CAPTURE_AND_RENDER = 0x01 | 0x02 | 0x04    /**< [en]Indicates video control capture and render.
                                                                     <br>[cn]视频控制capture和render */
};

/**
 * [en]This enum is about server request result.
 * [cn]服务器请求结果
 */
typedef enum
{
    ServiceREQResultSuccess			= 0,	/**< [en]Indicates success.
                                             <br>[cn]成功 */
    ServiceREQResultFailure			= -1,	/**< [en]Indicates failure.
                                             <br>[cn]失败 */
    ServiceREQResultInvalidParam	= -2,	/**< [en]Indicates invalid param.
                                             <br>[cn]无效参数 */
    ServiceREQResultSendFailed		= -3	/**< [en]Indicates send failed.
                                             <br>[cn]发送失败 */
}ServiceREQResult;

/**
 * [en]This enum is about result code definition.
 * [cn]结果码定义
 */
typedef enum
{
    kECSSuccess				= 0,    /**< [en]Indicates success.
                                     <br>[cn]成功 */
    kECSFailure				= 1,    /**< [en]Indicates failure.
                                     <br>[cn]失败 */
    kECSTimeout				= 2,    /**< [en]Indicates timeout.
                                     <br>[cn]超时 */
    kECSResultCodeUnkown	= 100,  /**< [en]Indicates unkown.
                                     <br>[cn]未知结果 */
}ECSResultCode;

#define APNS_PRODUCT    @"APNS_PRODUCT"
#define APNS_DEV        @"APNS_DEV"
#define APNS_ENTERPRISE @"APNS_ENTERPRISE"

/**
 * [en]This enum is about apns server type.
 * [cn]APNS SERVER类型
 */
typedef enum{
    APNS_SERVER_TYPE_INVALID    = 0,    /**< [en]Indicates invalid.
                                         <br>[cn]无效 */
    APNS_SERVER_TYPE_PRODUCTION = 1,    /**< [en]Indicates production type.
                                         <br>[cn]生存模式下的消息推送 */
    APNS_SERVER_TYPE_DEVELOPE   = 2     /**< [en]Indicates develope type.
                                         <br>[cn]开发模式下的消息推送 */
} APNS_SERVER_TYPE;

#define HMETraceSwith 0
/**
 * [en]This enum is about hme mode.
 * [cn]hme录制模式
 */
typedef enum{
    HMETraceMode_Disable    = 0,        /**< [en]Indicates trace  close.
                                         <br>[cn]trace关闭 */
    HMETraceMode_RealTime   = 1,        /**< [en]Indicates real time, every 10 ms.
                                         <br>[cn]实时,每10ms写一次 */
    HMETraceMode_Prestore   = 2         /**< [en]Indicates prestore, trace last 30s.
                                         <br>[cn]预录，只trace最后30s */
} HMETraceMode;

/**
 * [en]This enum is about apns certificate type.
 * [cn]APNS证书类型
 */
typedef enum{
    APNS_CER_TYPE_INVALID       = 0,    /**< [en]Indicates invalid.
                                         <br>[cn]无效类型 */
    APNS_CER_TYPE_APPSTORE      = 1,    /**< [en]Indicates app store type.
                                         <br>[cn]苹果商店的APNS证书类型 */
    APNS_CER_TYPE_ENTERPRISE    = 2,    /**< [en]Indicates enterprise type.
                                         <br>[cn]企业发布模式下的APNS证书类型 */
    APNS_CER_TYPE_ENTERPRISE_HD = 3,    /**< [en]Indicates enterprise hd type.
                                         <br>[cn]企业HD发布模式APNS证书类型 */
    APNS_CER_TYPE_APPSTORE_HD   = 4     /**< [en]Indicates app store hd type.
                                         <br>[cn]苹果商店HD模式下的APNS证书类型 */
} APNS_CER_TYPE;

/**
 * [en]This enum is about jail break detect strategy.
 * [cn]越狱检测策略
 */
typedef enum{
    JAILBREAK_DETECT_NONE   = 0,        /**< [en]Indicates detect non.
                                         <br>[cn]不检测 */
    JAILBREAK_DETECT_TIP    = 1,        /**< [en]Indicates detect tip.
                                         <br>[cn]检测并提示 */
    JAILBREAK_DETECT_FORBID = 2         /**< [en]Indicates detect forbid.
                                         <br>[cn]检测并禁止登录 */
} JAILBREAK_DETECT;

/**
 * [en]This enum is about screen size.
 * [cn]屏幕尺寸
 */
typedef enum{
    SCREEN_SIZE_3_5     = 1,            /**< [en]Indicates 3.5.
                                         <br>[cn]3.5寸 */
    SCREEN_SIZE_4       = 2,            /**< [en]Indicates 4.
                                         <br>[cn]4寸 */
    SCREEN_SIZE_720P    = 3             /**< [en]Indicates 720 p.
                                         <br>[cn]720P */
} SCREEN_SIZE;

/**
 * [en]This enum is about client supported functions type.
 * [cn]客户端支持特性功能类型
 */
typedef enum
{
    /* 0..EN_LOGINACK_FUNCID_MAX_LEN 严格对应Login响应中funcid的位数 */
    EN_FUNC_SMS						= 0,	/**< [en]Indicates whether supported sms.
                                             <br>[cn]是否支持短信能力 checkversion & login */
    EN_FUNC_CTC						= 1,    /**< [en]Indicates whether supported ctc.
                                             <br>[cn]是否支持手机端即时会议能力  chreckversion & login */
    EN_FUNC_CTD						= 2,    /**< [en]Indicates wether supported ctd.
                                             <br>[cn]是否支持CTD checkversion & login */
    EN_FUNC_IM						= 3,    /**< [en]Indicates whether supported im.
                                             <br>[cn]是否支持IM即时消息 login */
    EN_FUNC_VOIP					= 4,	/**< [en]Indicates whether supported voip.
                                             <br>[cn]判断服务器是否支持Voip checkversion & login */
    EN_FUNC_VEDIO					= 9,	/**< [en]Indicates whether supported vedio.
                                             <br>[cn]是否支持视频 login */
    EN_FUNC_MULTIMEDIA				= 11,	/**< [en]Indicates whether supported multi media.
                                             <br>[cn]是否支持多媒体会议 login */
    EN_FUNC_FILE_TRANSPOTR			= 12,	/**< [en]Indicates whether supported transport.
                                             <br>[cn]是否支持文件传输 login */
    EN_FUNC_MEDIAX					= 14,   /**< [en]Indicates whether supported mediax.
                                             <br>[cn]是否支持显示和加入预约会议 login */
    EN_FUNC_NEWS					= 15,   /**< [en]Indicates whether supported news.
                                             <br>[cn]是否支持公告 login */
    EN_FUNC_COUNTRYCODE				= 16,	/**< [en]Indicates whether supported country code.
                                             <br>[cn]是否支持国家码 login */
    EN_FUNC_SEARCHMOBILE			= 17,	/**< [en]Indicates whether supported search mobile.
                                             <br>[cn]是否支持批量匹配号码 login */
    EN_FUNC_CREATE_SCHEDULE_MEETING	= 18,	/**< [en]Indicates whether supported create schedule meeting.
                                             <br>[cn]是否支持创建预约会议 login */
    EN_FUNC_TRANSFER				= 19,	/**< [en]Indicates whether supported transfer.
                                             <br>[cn]是否支持refer转接 控制2方通话中转到第三方和会议中转到第三方 login */
    EN_FUNC_FORWARD  			    = 20,	/**< [en]Indicates whether supported forward.
                                             <br>[cn]是否支持呼叫前转 login */
    EN_FUNC_VEDIOCALL				= 21,	/**< [en]Indicates whether supported vedio call.
                                             <br>[cn]是否支持H264点对点视频通话 login */
    EN_FUNC_TRANSFER_HWUC			= 22,	/**< [en]Indicates whether supported transfer hwuc.
                                             <br>[cn]是否支持HWUC会议中转移 login */
    EN_FUNC_DEPTMSG					= 23,	/**< [en]Indicates whether supported deptment message.
                                             <br>[cn]是否支持部门通知 login */
    EN_FUNC_FIXGROUP				= 24,	/**< [en]Indicates whether supported fix group.
                                             <br>[cn]是否支持固定群组 login */
    
    EN_FUN_CALL_HOLD				= 25,	/**< [en]Indicates hold.
                                             <br>[cn]呼叫保持，如果不开启，则灰化按键。对应datamodel中的memFuncFlag 中的取值,memFeatureFlag无此值。支持动态变更通知。login */
    EN_FUNC_PASSWORD_CALL_LIMIT		= 26,	/**< [en]Indicates password call limit.
                                             <br>[cn]密码限呼功能，功能位开的时候，显示一个提示，不能呼出。类型见callLimitType.
                                             <br>[cn]对应datamodel中的FuncFlag和featureFlag取”|”之后的值。支持动态变更通知。login */
    EN_FUNC_CALL_WAIT				= 27,	/**< [en]Indicates call wait.
                                             <br>[cn]呼叫等待, ，缺省为0 如果开启，应该在收到第二路呼叫时，回182并放提示音。否则，直接拒绝。
                                             <br>[cn]对应datamodel中的FuncFlag和featureFlag取”|”之后的值。支持动态变更通知。login */
    EN_FUNC_CALL_FORWARDING_UNCONDITIONAL = 28, /**< [en]Indicates forward unconditional.
                                                 <br>[cn]login */
    EN_FUNC_CALL_FORWORDING_ONBUSY	= 29,	/**< [en]Indicates forwaord onbusy.
                                             <br>[cn]login */
    EN_FUNC_CALL_FORWORDING_NOREPLY	= 30,	/**< [en]Indicates forword noreply.
                                             <br>[cn]login */
    EN_FUNC_CALL_FORWORDING_OFFLIEN = 31,	/**< [en]Indicates forword offline.
                                             <br>[cn]login */
    EN_FUNC_VOICE_MAIL				= 32,	/**< [en]Indicates voice mail function.
                                             <br>[cn]语音留言功能，缺省为0。login */
    EN_FUNC_PRESENCE				= 33,	/**< [en]Indicates whether has presence right.
                                             <br>[cn]是否具备presence权限，1为具备，0不具备。缺省为1具备。如果老的MAA没返回这个功能位，客户端理解为具备PRESENCE权限。login */
    
    EN_FUNC_PROMPT_FOR_USE_CTD_CTC	= 34,	/**< [en]Indicates prompt for use ctd ctc.
                                             <br>[cn]CTD是否需要增加告警提示 */
    EN_FUNC_PROMPT_FOR_USE_CTC		= 35,	/**< [en]Indicates prompt for use ctc.
                                             <br>[cn]CTC是否需要增加告警提示 */
    
    EN_FUNC_LBS						= 36,	/**< [en]Indicates lbs function.
                                             <br>[cn]LBS功能，缺省为0。1代表支持。0代表不支持。 */
    EN_FUNC_SNR						= 37,	/**< [en]Indicates snr funcion.
                                             <br>[cn]SNR功能。1代表支持，0代表不支持。缺省0 */
    EN_FUNC_VOIP_FOR_NO_WIFI		= 38,	/**< [en]Indicates voip for no wifi.
                                             <br>[cn]非WIFI环境下也支持VOIP呼叫控制位。
                                             <br>[cn]1代表“非WIFI下也支持VOIP”。0代表“非WIFI下不支持VOIP”。华为UC和老的UC2.0不返回时客户端默认为出厂值0。沙特石油版本要返回1。*/
    EN_FUNC_CALLLOG					= 39,	/**< [en]Indicates supported cloud save.
                                             <br>[cn]支持云存储。login */
    EN_FUNC_CREATE_GROUP			= 40,	/**< [en]Indicates create group when add user.
                                             <br>[cn]支持在加人时创建新分组。1支持，0不支持。login */
    EN_FUNC_UNINTERRUPT				= 41,	/**< [en]Indicates uninterrupt.
                                             <br>[cn]免打扰功能位，1支持，0不支持。login */
    EN_FUNC_UM						= 42,	/**< [en]Indicates um.
                                             <br>[cn]指示终端可使用UM特性，在body体中发送图文混排内容 */
    EN_FUNC_MSGLOG					= 43,	/**< [en]Indicates server indicate client supported imlog.
                                             <br>[cn]1由服务器指示客户端支持IMLOG的获取。0不支持。 */
    EN_FUNC_DYNAMIC_LABEL_CONFIG	= 44,	/**< [en]Indicates dynamic label config.
                                             <br>[cn]动态标签特性 功能位，作用是：终端可以根据MAA下发的标签进行动态修改界面的显示。 */
    EN_FUNC_AUTO_ANSWER             = 45,   /**< [en]Indicates auto answer.
                                             <br>[cn]为1时，所有来电自动接听，以满足临时的展厅需求。默认为0。不按自动接听处理。（不可控制）*/
    EN_FUNC_AUTO_CONF_ANSWER        = 46,   /**< [en]Indicates auto conf answer.
                                             <br>[cn]用于指定客户端是否在收到pushmail一键入会请求时，根据来电匹配列表情况自动接听，1表示自动接听，0表示手动接听。
                                             <br>[cn]仅华为UC下使用，且仅针对华为Media Pad使用。对于UC2.0，该功能位默认填0。 */
    EN_FUNC_VISUAL_VOICE_MAIL       = 47,   /**< [en]Indicates visual voice mail.
                                             <br>[cn]是否启用可视化语音留言功能，0不启用，1启用，对应AA登录接口funcId功能位第112位。*/
    EN_FUNC_QOS_REPORT              = 48,   /**< [en]Indicates qos report.
                                             <br>[cn]QoS上报开关，MAA从AA的sEntControlFlag字段对应bit位获取而来：具体对应sEntControlFlag[9]
                                             <br>[cn]（注，sEntControlFlag比特功能位从0开始计算，因此此处是sEntControlFlag[9]）。0 关，1开。
                                             <br>[cn]注意：第[49] QoS上报开关来源是企业顶级配置，是登录时生效一次的。在0x041a中该功能位不生效，MAA在0x041a中对应[49]位默认填0，终端应忽略。 */
    EN_FUNC_VOIP_REACHABLE          = 49,   /**< [en]Indicates voip reachable.
                                             <br>[cn]VOIP号码可达性查询(功能命令码:0x02 11)功能位，如果打开，则终端可使用0x0211，如果关闭，终端不能使用0x0211。1打开，0关闭。
                                             <br>[cn]仅华为UC使用，UC2.0不使用。 */
    EN_FUNC_DISCUSSION_GROUP        = 50,   /**< [en]Indicates discussion group.
                                             <br>[cn]是否支持讨论组,仅华为UC使用，UC2.0不使用 */
    EN_FUNC_ANTI_COPY               = 51,   /**< [en]Indicates anti copy.
                                             <br>[cn]MDM防拷贝功能，开启后支持清除剪切板 */
    EN_FUNC_TLS_SRTP_FORCE_DISABLED = 52,   /**< [en]Indicates srtp force disabled.
                                             <br>[cn]TLS/SRTP加密是否强制关闭，YES：强制关闭忽略插件参数配置，NO：非强制关闭读取插件参数配置 */
    EN_FUNC_SERVER_MASK_GROUP_MSG   = 53,   /**< [en]Indicates server mask group msg.
                                             <br>[cn]群组消息屏蔽是否上报服务器功能位 */
    EN_FUNC_AGC                     = 54,   /**< [en]Indicates agc.
                                             <br>[cn]AGC降噪功能位 */
    EN_FUNC_PUSHSWICH               = 55,   /**< [en]Indicates push swich.
                                             <br>[cn]push消息开关设置功能位 */
    EN_FUNC_CALLREPORT              = 56,   /**< [en]Indicates call report.
                                             <br>[cn]voip语音质量上报功能位 */
    EN_FUNC_HISTORY_VERSION_RECORD  = 57,   /**< [en]Indicates history version record.
                                             <br>[cn]支持服务器查询版本历史更新 */
    EN_FUNC_FRIEND_CIRCLE           = 58,   /**< [en]Indicates friend circle.
                                             <br>[cn]支持朋友圈 */
    EN_FUNC_PUBLIC_ACCOUNT          = 59,   /**< [en]Indicates public account.
                                             <br>[cn]支持公众号 */
    EN_FUNC_ROAMING_MESSAGE         = 60,   /**< [en]Indicates roaming message.
                                             <br>[cn]支持IM聊天记录漫游 */
    EN_FUNC_TRANSFER_INCOMING_CALL  = 61,   /**< [en]Indicates transfer incoming call .
                                             <br>[cn]支持通话前呼叫偏转 */
    EN_FUNC_EVENTREPORT             = 62,   /**< [en]Indicates event report.
                                             <br>[cn]终端时间上报 */
    EN_FUNC_UMTRANSPORT_ENCRYPT     = 63,   /**< [en]Indicates um transport emcrypt.
                                             <br>[cn]终端与UM交互协议 0 http 1 https */
    EN_FUNC_RECENT_SESSIONS_ROAMING = 64,   /**< [en]Indicates recent session roaming.
                                             <br>[cn]最近会话漫游 0 不支持; 1 支持 */
    EN_FUNC_MULTITERMINAL           = 65,   /**< [en]Indicates multi terminal.
                                             <br>[cn]多终端登录，用户级功能位。默认为0，0 不支持多终端登录 1 支持多终端登录 */
    EN_FUNC_GROUP_ZONE              = 66,   /**< [en]Indicates group zone.
                                             <br>[cn]群空间，用户级功能位。默认为0，0 不支持群空间共享 1 支持群空间共享 */
    EN_FUNC_MAIL_REMIND             = 67,   /**< [en]Indicates mail remind.
                                             <br>[cn]邮件提醒，用户级功能。默认为0，0 不支持 1 支持 */
    EN_FUNC_FILE_TRANSMISSION       = 68,   /**< [en]Indicates file transmission.
                                             <br>[cn]文件传输（点对点，群组文件传输），用户级功能。默认为1，0 不支持 1 支持 */
    
    EN_LOGINACK_FUNCID_MAX_LEN,				/**< [en]Indicates login ack funid max length.
                                             <br>[cn]登录响应中funcid最大有效位数 */
    
    EN_FUNC_DATACONF				= 99,	/**< [en]Indicates data conf.
                                             <br>[cn]是否支持数据会议 checkversion & login（区分手机和pad） */
    
    EN_FUNC_ADDDOMAIN				= 100,	/**< [en]Indicates add domain.
                                             <br>[cn]voip鉴权时username是否添加域名 checkversion */
    EN_FUNC_TRANSPHONE				= 101,  /**< [en]Indicates transphone
                                             <br>[cn]是否支持来电转接能力 checkversion */
    EN_FUNC_CALLFORWARD				= 102,	/**< [en]Indicates call forward.
                                             <br>[cn]是否支持给予状态路由查询与设置 checkversion */
    EN_FUNC_MANAGECONF				= 103,	/**< [en]Indicates mange conf.
                                             <br>[cn]是否支持会议控制 checkversion */
    EN_FUNC_ENCRYPT					= 104,	/**< [en]Indicates encrypt.
                                             <br>[cn]是否支持aes加密 checkversion */
    EN_FUNC_SENSITIVE_WORDS			= 105,  /**< [en]Indicates sensitive words.
                                             <br>[cn]是否支持敏感词 checkversion */
    EN_FUNC_ALLOWPHONECALL			= 106,  /**< [en]Indicates allow phone call.
                                             <br>[cn]是否允许本地phone呼叫实现CTD checkversion */
    EN_FUNC_3GLOGIN					= 107,	/**< [en]Indicates 3g login.
                                             <br>[cn]0-表示不允许3G登录，1－表示允许3G登录，为了解决C01版本的兼容性问题，C02及以上版本必须是1。当UC2.0解决同时3GLogin标志位为0时，采用不允许3G登录的流程。checkversion */
    EN_FUNC_SUBSCRIBE_NON_FRIEND    = 108,  /**< [en]Indicates subscribe non friend.
                                             <br>[cn]是否支持非好友状态订阅 checkversion */
    EN_FUNC_ROOTFOBID               = 109,  /**< [en]Indicates root forbid.
                                             <br>[cn]是否允许root设备登录 checkversion C10版本申明废弃 */
    EN_FUNC_BATTERYSAVING_MODE      = 110,  /**< [en]Indicates battery saving mode.
                                             <br>[cn]是否允许设置省电模式 checkversion */
    
    EN_FUNC_TEMPGRP					= 200,	/**< [en]Indicates temp group.
                                             <br>[cn]是否支持临时群 */
    EN_FUNC_HEAD_IMAGE				= 201,	/**< [en]Indicates head image.
                                             <br>[cn]是否支持联系人头像 */
    EN_FUNC_CONTACT_SIMPLIFY		= 202,	/**< [en]Indicates contact simplify.
                                             <br>[cn]是否支持通讯录精简模式 */
    EN_FUNC_IM_VIA_DATACONF_SERVER	= 203,  /**< [en]Indicates im via data conf server.
                                             <br>[cn]是否支持通过数据会议服务器的IM */
    EN_FUNC_TRANSFER_IN_CALL        = 204,  /**< [en]Indicates transfer in call.
                                             <br>[cn]是否支持点对点通话中的转移 */
    EN_FUNC_TRANSFER_IN_CONF        = 205,  /**< [en]Indicates transfer in conf.
                                             <br>[cn]是否支持会议中的转移 */
    EN_FUNC_VOIP_TO_AUDIO_CONF		= 206,	/**< [en]Indicates voip to audio conf.
                                             <br>[cn]是否支持普通通话转多人语音会议 */
    EN_FUNC_SHIELDCONF              = 207,  /**< [en]Indicates shield conf.
                                             <br>[cn]是否屏蔽会议功能 */
    EN_FUNC_BUTT
}SUPPORT_FUNC_TYPE;

/**
 * [en]This emnu is about attendee conf state.
 * [cn]与会者加入会议状态
 */
typedef enum {
    ATTENDEE_CONF_STATE_INVITING		= 1,	/**< [en]Indicates inviting.
                                                 <br>[cn]正在邀请 */
    ATTENDEE_CONF_STATE_INVITE_SUCCESS	= 2,	/**< [en]Indicates invite success.
                                                 <br>[cn]邀请成功 */
    ATTENDEE_CONF_STATE_INVITE_FAILED	= 3,	/**< [en]Indicates invite failed.
                                                 <br>[cn]邀请失败 */
    ATTENDEE_CONF_STATE_HANG_UP			= 4,	/**< [en]Indicates hang up.
                                                 <br>[cn]挂断 */
    ATTENDEE_CONF_STATE_JOIN_SUCCESS	= 5,	/**< [en]Indicates join success.
                                                 <br>[cn]加入成功 */
    ATTENDEE_CONF_STATE_QUIT			= 6,	/**< [en]Indicates quit.
                                                 <br>[cn]退出 */
    ATTENDEE_CONF_STATE_HOLD			= 7		/**< [en]Indicates hold.
                                                 <br>[cn]保持 */
}EN_ATTENDEE_CONF_STATE;

/**
 * [en]This enum is about attendee audio right.
 * [cn]与会者发言权限
 */
typedef enum {
    ATTENDEE_AUDIO_RIGHT_ENABLE			= 0,	/**< [en]Indicates enable.
                                                 <br>[cn]有语音发言权 */
    ATTENDEE_AUDIO_RIGHT_DISABLE		= 1,	/**< [en]Indicates disable.
                                                 <br>[cn]没有语音发言权 */
    ATTENDEE_AUDIO_RIGHT_APPLYING		= 2		/**< [en]Indicates applying.
                                                 <br>[cn]正在申请发言权 */
}ATTENDEE_AUDIO_RIGHT;

/**
 * [en]This enum is about call trans type.
 * [cn]通话转接类型
 */
typedef enum
{
    EN_TRANS_CALL_TO_CALL,      /**< [en]Indicates call to call.
                                 <br>[cn]音视频呼叫互转 */
    EN_TRANS_CALL_TO_CONF,      /**< [en]Indicates call to conf.
                                 <br>[cn]呼叫转会议 */
    EN_TRANS_CONF_TO_CALL,      /**< [en]Indicates conf to call.
                                 <br>[cn]会议转呼叫 */
    EN_TRANS_CALL_TO_SNR,       /**< [en]Indicates call to snr.
                                 <br>[cn]ATS业务：一键转接 */
    EN_TRANSFER_BUTT,
}EN_TRANSFER_TYPE;

/**
 * [en]This enum is about conf talking right.
 * [cn]会议讨论权限
 */
typedef enum
{
    EN_CONF_NO_RIGHT,           /**< [en]Indicates no right.
                                 <br>[cn]没有权限 */
    EN_CONF_TALKING,            /**< [en]Indicates have right.
                                 <br>[cn]有权限 */
    
    EN_CONF_TALK_RIGHT_BUTT,
}EN_CONF_TALK_RIGHT;

/**
 * [en]This enum is about chat message send mode.
 * [cn]聊天消息发送模式
 */
typedef enum
{
    kSendMsgViaMaa = 0,			    /**< [en]Indicates send by MAA server.
                                     <br>[cn]通过MAA服务器发送 */
    kSendMsgViaConfComponent = 1	/**< [en]Indicates send by via conf component.
                                     <br>[cn]通过多媒体会议组件发送(UC1.0开多媒体会议时使用) */
}ChatMsgSendMode;

/**
 * [en]This enum is about temp group create mode.
 * [cn]临时群创建模式
 */
typedef enum
{
    kCreateTempGroup = 0,				                    /**< [en]Indicates create temp group direct.
                                                             <br>[cn]直接创建临时群 */
    kSingleChatChangedToTempGroup = 1,	                    /**< [en]Indicates single chat changed to temp group.
                                                             <br>[cn]从单聊转成临时群 */
    kSingleChatChangedToTempGroupWhenCallProcessing = 2,    /**< [en]Indicates single chat changed to temp group during call processing.
                                                             <br>[cn]在通话过程中，从单聊转成临时群 */
}TempGroupCreatedMode;

/**
 * [en]This enum is about login status.
 * [cn]登录状态
 */
typedef enum {
    EN_STATE_LOGIN_IDLE			= 0,    /**< [en]Indicates idle.
                                         <br>[cn]空闲状态 */
    EN_STATE_LOGIN_PROCESS		= 1,    /**< [en]Indicates login process.
                                         <br>[cn]准备状态 */
    EN_STATE_LOGIN_NORMAL		= 2     /**< [en]Indicates login normal.
                                         <br>[cn]登录成功状态 */
}LOGIN_STATE;

/**
 * [en]This enum is about audio state type.
 * [cn]语音状态类型
 */
typedef enum
{
    AUDIO_STATE_CALLING = 0,		    /**< [en]Indicates calling.
                                         <br>[cn]多人语音成员入会状态 */
    AUDIO_STATE_TALKING,			    /**< [en]Indicates talking.
                                         <br>[cn]多人语音成员会议中状态 */
    AUDIO_STATE_CALLOVER,			    /**< [en]Indicates call over.
                                         <br>[cn]多人语音成员离会状态 */
    AUDIO_STATE_INIT,				    /**< [en]Indicates unuse at present.
                                         <br>[cn]unuse暂未使用 */
    AUDIO_STATE_FORBID,				    /**< [en]Indicates forbid.
                                         <br>[cn]多人语音成员静音状态 */
    AUDIO_STATE_DELETE,				    /**< [en]Indicates unuse at present.
                                         <br>[cn]unuse暂未使用 */
    
    AUDIO_STATE_BUTT				//unuse
}EN_AUDIO_STATE;

/**
 * [en]This enum is about account kick off type.
 * [cn]账号被踢类型
 */
typedef  enum
{
    enForbidden,        /**< [en]Indicates forbidden.
                         <br>[cn]账号被禁用 */
    enExpired,          /**< [en]Indicates expired.
                         <br>[cn]账号到期 */
    enLoginedByOther    /**< [en]Indicates logined by other.
                         <br>[cn]别处登录 */
}KICKOFF_TYPE;

/**
 * [en]This enum is about add friend result.
 * [cn]添加好友结果
 */
typedef  enum
{
    enAgreed,           /**< [en]Indicates agree.
                         <br>[cn]对方同意 */
    enWaiting,          /**< [en]Indicates waiting.
                         <br>[cn]等待 */
    enRejected          /**< [en]Indicates reject.
                         <br>[cn]被对方拒绝 */
}ADD_FRIEND_RSP;



//UC2.0_DEV
#define   UCV2_REFER_ACCEPT         @"202"
#define   UCV2_NOTIFY_200           @"200"
#define   UCV2_CONF_ATTENDEE_SPLIT  @"|1|,"
#define   UCV2_SIP_HEADER                       @"sip:"
#define   UCV2_REPORT_TERMINAL_TIMER_LEN 3 //延迟上报终端类型定时器时长

/**
 * [en]This enum is about media type.
 * [cn]媒体类型
 */
typedef enum
{
    EN_MEDIA_TYPE_AUDIO = 1,        /**< [en]Indicates audio.
                                     <br>[cn]音频 */
    EN_MEDIA_TYPE_MULTIMEDIA = 2,   /**< [en]Indicates multi media.
                                     <br>[cn]富媒体 */
    EN_MEDIA_TYPE_BUTT
}MEDIA_TYPE;

/**
 * [en]This enum is about data conf operation type.
 * [cn]数据会议操作类型
 */
typedef enum
{
    EN_OPT_ADD = 0,         /**< [en]Indicates add.
                             <br>[cn]添加 */
    EN_OPT_MODIFY = 1,      /**< [en]Indicates modify.
                             <br>[cn]修改 */
    EN_OPT_REMOVE = 3,      /**< [en]Indicates remove.
                             <br>[cn]删除 */
    EN_OPT_BUTT,
}DATA_OPT_TYPE;

/* 预定会议默认提醒时间，单位second */
#define SCHEDULE_CONF_DEFAULT_REMIND_TIMELEN		(600)


// transfer subscriptionState
#define SUBSCRIPTION_STATE_ACTIVE			@"active"
#define SUBSCRIPTION_STATE_PENDING			@"pending"
#define SUBSCRIPTION_STATE_TERMINATED		@"terminated"

/**
 * [en]This enum is about call typ.
 * [cn]呼叫类型
 */
typedef enum voip_call_tpye
{
    VOIP_CALL_AUDIO = 0 ,   /**< [en]Indicates audio call.
                             <br>[cn]音频呼叫 */
    VOIP_CALL_VIDEO         /**< [en]Indicates video call.
                             <br>[cn]视频呼叫 */
}EN_CALL_TYPE;

/**
 * [en]This enum is about media type.
 * [cn]媒体类型
 */
typedef enum {
    CallMediaTypeAudioOnly = 0,     /**< [en]Indicates audio only.
                                     <br>[cn]只有音频 */
    CallMediaTypeVideoOnly = 1,     /**< [en]Indicates video only.
                                     <br>[cn]只有视频 */
    CallMediaTypeAudioAndVideo = 2  /**< [en]Indicates audio and video.
                                     <br>[cn]音频和视频 */
}CallMediaType;

/**
 * [en]This enum is about answer call type.
 * [cn]应答呼叫类型
 */
typedef enum answer_call_type
{
    ANSWER_CALL_AUDIO = 1,  /**< [en]Indicates audio call.
                             <br>[cn]音频呼叫 */
    ANSWER_CALL_VIDEO       /**< [en]Indicates video call.
                             <br>[cn]视频呼叫 */
}ANSWER_CALL_TYPE;

/**
 * [en]This enum is about video orientation.
 * [cn]视频方向的枚举定义
 */
typedef enum VideoOrientation_ {
    kVideoOrientationLandscape = 0,     /**< [en]Indicates landscape.
                                         <br>[cn]横向视频 */
    kVideoOrientationPortrait = 1,      /**< [en]Indicates portrait.
                                         <br>[cn]纵向视频 */
}VideoOrientation;

#define  ADD_CONTACT_BUTTON							@"ADD_CONTACT_BUTTON"
#define  VOICE_CONF_BUTTON							@"VOICE_CONF_BUTTON"
#define  DATA_CONF_BUTTON							@"DATA_CONF_BUTTON"

// 语音会议与会成员号码分隔符
#define AUDIO_CONF_ATTENDEE_NUMBER_SPLIT		@"#"

/**
 * [en]This enum is about sync contact operatin.
 * [cn]同步通讯录操作枚举值
 */
typedef enum
{
    EN_NOT_DOWNLOAD_CONTACTS = 0,			/**< [en]Indicates not download contact.
                                             <br>[cn]不同步通讯录 */
    EN_PARTITIAL_DOWNLOAD_CONTACTS = 1,		/**< [en]Indicates partitial download contact.
                                             <br>[cn]部分同步通讯录 */
    EN_FULL_DOWNLOAD_CONTACTS = 2			/**< [en]Indicates full download contact.
                                             <br>[cn]完全同步通讯录 */
}EN_DOWNLOAD_CONTACTS_TYPE;

/**
 * [en]This enum is about conf parse type.
 * [cn]会议解析类型
 */
typedef enum
{
    CONF_LIST_PARSE     = 1,	        /**< [en]Indicates conf list parse.
                                         <br>[cn]会议列表解析 */
    CONF_INFO_PARSE     = 2,	        /**< [en]Indicates single conf info parse.
                                         <br>[cn]单个会议信息解析 */
    
    CONF_SEND_INVITE    = 100,          /**< [en]Indicates send email invite during conf.
                                         <br>[cn]会议中发送email邀请 */
    CONF_QUERY_MEMBERS  = 200,          /**< [en]Indicates query member info.
                                         <br>[cn]查询会议成员消息 */
    CONF_REDIRECT_PARAMS_PARSE = 300,   /**< [en]Indicates redirect params parse.
                                         <br>[cn]重定向参数信息解析 */
    
    CONF_TYPE_NULL
}PARSE_TYPE;

/**
 * [en]This enum is about audio route definition.
 * [cn]音频路由枚举定义
 */
typedef enum
{
    AUDIO_ROUTE_TYPE_HEADPHONES = 0,    /**< [en]Indicates headphone.
                                         <br>[cn]听筒（蓝牙、有线、听筒自动切换；优先级：蓝牙>有线>听筒） */
    AUDIO_ROUTE_TYPE_REPRODUCER = 1     /**< [en]Indicates reproducer.
                                         <br>[cn]扬声器 */
}AUDIO_ROUTE_TYPE;

/**
 * [en]This enum is about delete call log type operation.
 * [cn]删除通话记录操作类型枚举定义
 */
typedef enum
{
    ECSCallLogOptType_deleteOne = 0,	/**< [en]Indicates delete one.
                                         <br>[cn]按条删除 */
    ECSCallLogOptType_deleteAll = 1,	/**< [en]Indicates delete all.
                                         <br>[cn]删除所有记录 */
    ECSCallLogOptType_deleteByUser = 2	/**< [en]Indicates delete by user.
                                         <br>[cn]按用户删除 */
}ECSCallLogOptType;

/**
 * [en]This enum is about video format.
 * [cn]视频格式
 */
typedef enum
{
    VIDEO_SQCIF     = 1,
    VIDEO_QCIF      = 2,
    VIDEO_CIF       = 3,
    VIDEO_4CIF      = 4,
    VIDEO_16CIF     = 5,
    VIDEO_QQVGA     = 6,
    VIDEO_QVGA      = 7,
    VIDEO_VGA       = 8,
    VIDEO_720P      = 9,
    VIDEO_MAX
}VIDEO_SOLUTION;

/**
 * [en]This enum is about ios version.
 * [cn]ios版本
 */
typedef enum{
    IOS_MAINVERSION_4 = 4,
    IOS_MAINVERSION_5 = 5,
    IOS_MAINVERSION_6 = 6,
    IOS_MAINVERSION_7 = 7,
    IOS_MAINVERSION_8 = 8,
    IOS_MAINVERSION_9 = 9,
    IOS_MAINVERSION_UNKNOW = 999
} IOS_MAINVERSION;

/**
 * [en]This enum is about backgroud offline time.
 * [cn]后台离线时间
 */
typedef enum{
    BKGOFFLINE_TIME_NEVER       = 0,    /**< [en]Indicates none.
                                         <br>[cn]未离线 */
    BKGOFFLINE_TIME_TENMINS     = 10,   /**< [en]Indicates 10 minutes.
                                         <br>[cn]10分钟 */
    BKGOFFLINE_TIME_THIRTYMINS  = 30,   /**< [en]Indicates 30 minutes.
                                         <br>[cn]30分钟 */
    BKGOFFLINE_TIME_SIXTYMINS   = 60,   /**< [en]Indicates 60 minutes.
                                         <br>[cn]60分钟 */
    BKGOFFLINE_TIME_FOREVER     = -1    /**< [en]Indicates forever.
                                         <br>[cn]永久离线 */
} BKGOFFLINE_TIME;

/**
 * [en]This enum is about battery mode.
 * [cn]省电模式
 */
typedef enum {
    BATTERY_MODE_STANDARD   = 0,    /**< [en]Indicates standard mode, not open battery mode.
                                     <br>[cn]标准模式，不开启省电状态 */
    BATTERY_MODE_NORMAL     = 1,    /**< [en]Indicates normal battery mode.
                                     <br>[cn]普通省电模式，屏蔽状态 */
    BATTERY_MODE_EXTREM     = 2     /**< [en]Indicates extrem battery mode.
                                     <br>[cn]极限省电模式，屏蔽voip注册，ios暂未使用 */
} BATTERY_MODE;

/**
 * [en]This enum is about AES mode.
 * [cn]AES密钥模式
 */
typedef enum{
    AESKEY_MODE_UNKNOW = -1,    /**< [en]Indicates unknow.
                                 <br>[cn]未知模式 */
    AESKEY_MODE_STATIC = 0,     /**< [en]Indicates static mode.
                                 <br>[cn]固定模式 */
    AESKEY_MODE_DYNAMIC = 1     /**< [en]Indicates dynamic mode.
                                 <br>[cn]动态模式 */
}AESKEY_MODE;

/**
 * [en]This enum is about password protect mode.
 * [cn]密码保护模式
 */
typedef enum {
    PSW_PROTECT_NONE        = 0,    /**< [en]Indicates none.
                                     <br>[cn]无保护 */
    PSW_PROTECT_SALT        = 1     /**< [en]Indicates salt protect.
                                     <br>[cn]盐值保护 */
} PSW_PROTECT_TYPE;

#pragma mark -
#pragma mark UM
/**
 * [en]This enum is about file format.
 * [cn]文件格式枚举
 */
typedef enum  FILE_TYPE_{
    FILE_TYPE_JPEG = 1,
    FILE_TYPE_PNG = 2,
    FILE_TYPE_MP4 = 3,
    FILE_TYPE_WAV = 4,
    FILE_TYPE_AMR = 5,
    FILE_TYPE_UNKNOW = 100
}FILE_TYPE;

#pragma mark -
#pragma mark ATS业务

/**
 * [en]This enum is about video operation type.
 * [cn]视频呼叫操作类型
 */
typedef enum
{
    ECSCallVideoOperationType_NoControl = 0,    /**< [en]Indicates no control.
                                                 <br>[cn]对视频无操作 */
    ECSCallVideoOperationType_Update = 1,       /**< [en]Indicates update.
                                                 <br>[cn]升级视频 */
    ECSCallVideoOperationType_Remove = 2,       /**< [en]Indicates remove.
                                                 <br>[cn]移除视频 */
}ECSCallVideoOperationType;

/*incoming call info key*/
#define CALL_FROMNUMBER		@"CALL_FROMNUMBER"	//value:来电from头域uri解析的号码，NSString*
#define CALL_FROMNAME		@"CALL_FROMNAME"	//value:来电from头域uri解析的姓名，NSString*
#define CALL_PAINUMBER		@"CALL_PAINUMBER"	//value:来电pai头域uri号码，NSString*
#define CALL_PAITELNUMBER	@"CALL_PAITELNUMBER" //value:来电pai头域tel-uri号码，NSString* (tel:1395464;phone-context=+9663)
#define CALL_PAITELCONTEXT	@"CALL_PAITELCONTEXT" //value:来电pai头域tel-uri中phone-context=后的内容，NSString* (tel:1395464;phone-context=+9663)
#define CALL_LOCAL_ADDR     @"CALL_LOCAL_ADDR"  //value:本地IP
#define CALL_REMOTE_ADDR    @"CALL_REMOTE_ADDR" //value:远端IP
#define CALL_TONUMBER       @"CALL_TONUMBER"  //value:来电to头域uri解析的号码，NSString*

#define CALL_PAINAME		@"CALL_PAINAME"		//value:来电pai头域uri解析的姓名，NSString*
#define CALL_SDPINFO		@"CALL_SDPINFO"		//value:来电sdp信息，NSNumber of bool
#define CALL_CONTROLTYPE	@"CALL_CONTROLTYPE"	//value:来电呼叫控制，NSNumber of ECSCallControllType
#define CALL_HISTORYINFO	@"CALL_HISTORYINFO" //value:来电转接历史uri，NSMutableArray with NSString

/*answer call info key*/
#define CALL_ANSWER_SENDMODE   @"CALL_ANSWER_SENDMODE" //value:应答的媒体方向，NSNumber of int
#define CALL_ANSWER_AUDIOONLY  @"CALL_ANSWER_AUDIOONLY" //value:应答的媒体类型，NSNumber of bool

#define SESSION_MODIFY_CALLID @"SESSION_MODIFY_CALLID"  //修改会话操作时的callID

// 2012.12.14 k00228462 语音留言
#define VOICE_MAIL_MAILBOXNUM_KEY @"VOICE_MAIL_MAILBOXNUM_KEY"	//value:用户的语音邮箱号码
#define VOICE_MAIL_SHORTCODE_KEY @"VOICE_MAIL_SHORTCODE_KEY"	//value:该条留言的UMS请求短号


//语音转会议
#define VOICE_CONFERENCE_ID_KEY				@"conferenceID"		//会议ID
#define VOICE_CONFERENCE_MEDIATYPE_KEY			@"conferenceType"	//会议type
#define VOICE_CALL_ID_SDK_KEY               @"callID"

//心跳正常通知
#define ECS_HEART_BEAT_RESPOND_SUCCESS @"ECS_HEART_BEAT_RESPOND_SUCCESS"

/**
 * [en]This enum is about play voice mail.
 * [cn]播放语音留言
 */
typedef enum
{
    VoiceMailPlayRewind		= 1,    /**< [en]Indicates rewind.
                                     <br>[cn]重新播放 */
    VoiceMailPlayPause		= 2,    /**< [en]Indicates pause.
                                     <br>[cn]暂停播放 */
    VoiceMailPlayForward	= 3,    /**< [en]Indicates forward.
                                     <br>[cn]快进播放 */
}VoiceMailPlayControlMode;

// 2012.12.14 k00228462 语音留言 end

/*transfer key*/
#define TRANSFER_TARGET_KEY @"TRANSFER_TARGET_KEY" //value:转接目标号码，NSString*
#define TRANSFER_TYPE_KEY   @"TRANSFER_TYPE_KEY"   //value:转接类型，NSNumber of EN_TRANSFER_TYPE

/**
 * [en]This enum is about other client login type.
 * [cn]其他客户端登录的客户端类型
 */
typedef NS_ENUM(NSInteger, OtherLoginType)
{
    OtherLoginTypeUnknown = -1,     /**< [en]Indicates unknow.
                                     <br>[cn]类型未知或客户端没有登录 */
    OtherLoginTypePC = 0,			/**< [en]Indicates pc.
                                     <br>[cn]客户端已经登录且类型为PC */
    OtherLoginTypeMobile = 1,		/**< [en]Indicates mobile.
                                     <br>[cn]客户端已经登录且类型为手机 */
    OtherLoginTypeWeb = 2,          /**< [en]Indicates web.
                                     <br>[cn]客户端已经登录且类型为web */
    OtherLoginTypePad = 3,			/**< [en]Indicates pad.
                                     <br>[cn]客户端已经登录且类型为Pad */
    OtherLoginTypeIPPhone = 4,		/**< [en]Indicates ip phone.
                                     <br>[cn]客户端已经登录且类型为IP话机 */
    OtherLoginTypeIMSS = 5,         /**< [en]Indicates imss.
                                     <br>[cn]客户端已经登录且类型为IMSS */
    OtherLoginTypeNewPC = 6         /**< [en]Indicates new pc.
                                     <br>[cn]客户端已经登录且类型为新版PC */
};

/**
 * [en]This enum is about im message or fixed group message status.
 * [cn]即时消息或固定群消息的状态枚举
 */
typedef enum
{
    ChatMsgStatusRead = 0,	    /**< [en]Indicates read.
                                 <br>[cn]消息已读 */
    ChatMsgStatusUnread = 1     /**< [en]Indicates unread.
                                 <br>[cn]消息未读 */
}ChatMsgStatusType;


/**
 * [en]This enum is about record type.
 * [cn]录音的类型
 */
typedef enum
{
    AudioRecordTypeLocalWhileNotCalling = 0,	/**< [en]Indicates record local audio while not calling.
                                                 <br>[cn]非通话状态下，录制本地声音。 */
    AudioRecordTypeLocalWhileCalling = 1,		/**< [en]Indicates record local audio while calling.
                                                 <br>[cn]通话状态下，录制本地的声音。 */
    AudioRecordTypeRemoteWhileCalling = 2,		/**< [en]Indicates record remote audio while calling.
                                                 <br>[cn]通话状态下，录制远端的声音。 */
    AudioRecordTypeBothWhileCalling = 3,		/**< [en]Indicates record both audio while calling.
                                                 <br>[cn]通话状态下，录制双向的声音。 */
}AudioRecordType;

#define SERVICE_NAME_FOR_LPOE @"LPOE" // 表示产权局定制版本

/**
 * [en]This enum is about core net deploy model.
 * [cn]核心网部署模式
 */
typedef enum
{
    CoreNetDeployModel_Unknown = 0,     /**< [en]Indicates unknow.
                                         <br>[cn]未知模式 */
    CoreNetDeployModel_UAP = 1,         /**< [en]Indicates uap model.
                                         <br>[cn]UAP模式 */
    CoreNetDeployModel_ATS = 2,         /**< [en]Indicates ats model.
                                         <br>[cn]ATS模式 */
}CoreNetDeployModel;

/**
 * [en]This enum is about device type .
 * [cn]设备型号枚举
 */
typedef enum
{
    UIDeviceMode_Iphone3G = 1,
    UIDeviceMode_Iphone3GS,
    UIDeviceMode_Iphone4,
    UIDeviceMode_Iphone4S,
    UIDeviceMode_Iphone5,
    UIDeviceMode_Iphone5C,
    UIDeviceMode_Iphone5S,
    UIDeviceMode_Ipad2,
    UIDeviceMode_Ipad3,
    UIDeviceMode_IpadMini,
    UIDeviceMode_Ipad4,
    UIDeviceMode_Ipad5,
    UIDeviceMode_IpadMini2,
    UIDeviceMode_Iphone6,
    UIDeviceMode_Iphone6_Plus,
    UIDeviceMode_Iphone6S,
    UIDeviceMode_Iphone6S_Plus,
    UIDeviceMode_Ipad6,
    UIDeviceMode_IpadMini3,
    UIDeviceMode_Unknown= 100,
}UIDeviceMode;

/**
 * [en]This enum is about DN operatin type
 * [cn]DND操作类型
 */
typedef NS_ENUM(NSInteger, DND_ACTION_TYPE) {
    DND_ACTION_TYPE_NONE = 0,   /**< [en]Indicates none operatin.
                                 <br>无操作*/
    DND_ACTION_TYPE_SET = 1,    /**< [en]Indicates set.
                                 <br>设置 */
    DND_ACTION_TYPE_RESET = 2,  /**< [en]Indicates reset.
                                 <br>重置 */
};

/**
 * [en]This enum is about dnd config.
 * [cn]DND配置
 */
typedef NS_ENUM(NSInteger, DND_CONFIG)  {
    DND_CONFIG_REFUSE = 0,      /**< [en]Indicates refuse(ats will auto forward call to audio mail).
                                 <br>[cn]拒接模式（ATS会自动将呼叫前转到语音邮箱） */
    DND_CONFIG_MUTE = 1,        /**< [en]Indicates mute(ats will let call terminal, mute terminal).
                                 <br>[cn]静音模式（ATS会放行呼叫到终端，终端自己静音） */
};

/**
 * [en]This enum is about dnd status.
 * [cn]dndStatus枚举
 */
typedef NS_ENUM(NSInteger, DND_STATUS){
    DND_STATUS_DEACTIVE = 0,    /**< [en]Indicates dnd service deactive.
                                 <br>[cn]DND业务已取消 */
    DND_STATUS_ACTIVE = 1       /**< [en]Indicates dnd active.
                                 <br>[cn]DND业务已激活 */
};

/**
 * [en]This enum is about certificate recheck.
 * [cn]证书校验
 */
typedef NS_ENUM(NSInteger, ECSCertsState) {
    ECSCertsStateUnKnow = 0,            /**< [en]Indicates unknow.
                                         <br>[cn]证书未校验 */
    ECSCertsStateValid = 1,             /**< [en]Indicates valid.
                                         <br>[cn]证书有效且有效期超过一个月 */
    ECSCertsStateLessThanOneMonth = 2,  /**< [en]Indicates less than one month.
                                         <br>[cn]证书有效期不足一个月 */
    ECSCertsStateOverdue = 3,           /**< [en]Indicates over due.
                                         <br>[cn]证书已过期 */
    ECSCertsStateInValid = 4            /**< [en]Indicates invalid.
                                         <br>[cn]证书无效 */
};

/**
 * [en]This enum is about net detect enviroment type.
 * [cn]组网探测环境类型
 */
typedef NS_ENUM(NSUInteger, ECSServerEnvironment) {
    ECSServerEnvironmentUnknow = 0,     /**< [en]Indicates unknow.
                                         <br>[cn]未知模式 */
    ECSServerEnvironmentEC30,           /**< [en]Indicates EC3.0.
                                         <br>[cn]EC3.0 */
    ECSServerEnvironmentEC60,           /**< [en]Indicates EC 6.0.
                                         <br>[cn]EC6.0 */
};

/**
 * [en]This enum is about uportal conf type.
 * [cn]uportal会议类型
 */
typedef NS_ENUM(NSUInteger, ECSUPortalConfType)
{
    ECSUPortalConfTypeUSMConf,          /**< [en]Indicates usm conf.
                                         <br>[cn]LOGIN_E_DEPLOY_ENTERPRISE_IPT 内置会议 */
    ECSUPortalConfTypeSMCConf,          /**< [en]Indicates smc conf.
                                         <br>[cn]LOGIN_E_DEPLOY_ENTERPRISE_CC SMC会议 */
    ECSUPortalConfTypeMediaXConf,       /**< [en]Indicates mediax conf.
                                         <br>[cn]LOGIN_E_DEPLOY_SPHOSTED_CC、LOGIN_E_DEPLOY_SPHOSTED_CONF、LOGIN_E_DEPLOY_IMSHOSTED_CC MediaX会议 */
    ECSUPortalConfTypeSPHostedConf,     /**< [en]Indicates hosted sp conf.
                                         <br>[cn]LOGIN_E_DEPLOY_SPHOSTED_IPT 没有会议功能 */
    ECSUPortalConfTypeImsHostedIpt      /**< [en]Indicates im hosted ipt.
                                         <br>[cn]LOGIN_E_DEPLOY_IMSHOSTED_IPT 没有会议功能 */
};

/* define of log level enum */
typedef enum
{
    kECSLogDebug    = 0,
    kECSLogInfo        = 1,
    kECSLogError    = 2,
    kECSLogVerbose    = 3,
    kECSLogUnknown    = -1,
}ECSLogLevel;

