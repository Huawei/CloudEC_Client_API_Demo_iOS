//
//  CallSessionModifyInfo.h
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//
#import <Foundation/Foundation.h>
//#import "call_advanced_def.h"

typedef enum
{
    CALL_REINVITE_PNOTIFICATION_NONE,
    CALL_REINVITE_PNOTIFICATION_HOLD,
    CALL_REINVITE_PNOTIFICATION_UNHOLD,
    CALL_REINVITE_PNOTIFICATION_BUTT
} CALL_REINVITE_TYPE;

typedef enum
{
    CALL_MEDIA_SENDMODE_INACTIVE = 0x00,  /**< [en]Indicates neither send nor receive */
    CALL_MEDIA_SENDMODE_SENDONLY = 0x01,  /**< [en]Indicates send-only*/
    CALL_MEDIA_SENDMODE_RECVONLY = 0x02,  /**< [en]Indicates receive-only */
    CALL_MEDIA_SENDMODE_SENDRECV = 0x04,  /**< [en]Indicates both send and receive*/
    CALL_MEDIA_SENDMODE_INVALID  = 0x08   /**< [en]Indicates invalid*/
}CALL_MEDIA_SENDMODE;

typedef enum
{
    CALL_CONF_MEDIA_AUDIO = 0x01, /**< [en]Indicates audio conference*/
    CALL_CONF_MEDIA_VIDEO = 0x02, /**< [en]Indicates video conference*/
    CALL_CONF_MEDIA_DATA  = 0x04, /**< [en]Indicates data conference*/
    CALL_CONF_MEDIA_AUX   = 0x08  /**< [en]Indicates video auxiliary data conference*/
}CALL_CONF_MEDIA_TYPE;

typedef enum
{
    CALL_CONF_TOPOLOGY_UC,        /**< [en]Indicates UC*/
    CALL_CONF_TOPOLOGY_SMC,       /**< [en]Indicates SMC*/
    CALL_CONF_TOPOLOGY_MEDIAX,    /**< [en]Indicates MEDIAX*/
    CALL_CONF_TOPOLOGY_BUTT
}CALL_CONF_TOPOLOGY_TYPE;

@interface CallSessionModifyInfo : NSObject
@property (nonatomic, assign)int callId;
@property (nonatomic, assign)BOOL isFocus;
@property (nonatomic, assign)NSString *serverConfType;
@property (nonatomic, copy)NSString *serverConfID;
@property (nonatomic, assign)int orientType;
@property (nonatomic, copy)NSString *localAddress;
@property (nonatomic, copy)NSString *remoteAddress;
@property (nonatomic, assign)CALL_REINVITE_TYPE holdType;
@property (nonatomic, assign)CALL_MEDIA_SENDMODE audioSendMode;
@property (nonatomic, assign)CALL_MEDIA_SENDMODE videoSendMode;
@property (nonatomic, assign)CALL_MEDIA_SENDMODE dataSendMode;
@property (nonatomic, assign)BOOL isLowBWSwitchToAudio;
@property (nonatomic, assign)CALL_CONF_MEDIA_TYPE confMediaType;
@property (nonatomic, assign)CALL_CONF_TOPOLOGY_TYPE confTopology;
@property (nonatomic, assign)BOOL isSvcCall;
@property (nonatomic, assign)NSString *svcLablecount;
@property (nonatomic, assign)int aulSvcLable;

//+(instancetype)initWithCallSessionModified:(CALL_S_SESSION_MODIFIED *)sessionModify;

@end
