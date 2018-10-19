//
//  ECSConfInfo+StructParase.m
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

#import "ECConfInfo+StructParase.h"
#import "CommonUtils.h"

@implementation ECConfInfo (StructParase)

/**
 *This method is used to parse C struct CONFCTRL_S_CONF_LIST_INFO to instance of class ECConfInfo
 *将头文件的结构体CONFCTRL_S_CONF_LIST_INFO转换为类ECConfInfo的实例
 */
+(ECConfInfo *)returnECConfInfoWith:(TSDK_S_CONF_BASE_INFO)confListInfo
{
    ECConfInfo *ecConfInfo = [[ECConfInfo alloc] init];
    ecConfInfo.conf_id = [NSString stringWithUTF8String:confListInfo.conf_id];
    ecConfInfo.conf_subject = [NSString stringWithUTF8String:confListInfo.subject];
    ecConfInfo.access_number = [NSString stringWithUTF8String:confListInfo.access_number];
    ecConfInfo.chairman_pwd = [NSString stringWithUTF8String:confListInfo.chairman_pwd];
    ecConfInfo.general_pwd = [NSString stringWithUTF8String:confListInfo.guest_pwd];
    NSString *utcDataStartString = [NSString stringWithUTF8String:confListInfo.start_time];
    ecConfInfo.start_time = [CommonUtils getLocalDateFormateUTCDate:utcDataStartString];
    NSString *utcDataEndString = [NSString stringWithUTF8String:confListInfo.end_time];
    ecConfInfo.end_time = [CommonUtils getLocalDateFormateUTCDate:utcDataEndString];
    ecConfInfo.scheduser_number = [NSString stringWithUTF8String:confListInfo.scheduser_account];
    ecConfInfo.scheduser_name = [NSString stringWithUTF8String:confListInfo.scheduser_name];
    ecConfInfo.media_type = (EC_CONF_MEDIATYPE)confListInfo.conf_media_type;
    ecConfInfo.conf_state = (CONF_E_CONF_STATE)confListInfo.conf_state;
    ecConfInfo.isHdConf = confListInfo.is_hd_conf;
    ecConfInfo.token = [NSString stringWithUTF8String:confListInfo.token];
    ecConfInfo.chairJoinUri = [NSString stringWithUTF8String:confListInfo.chair_join_uri];
    ecConfInfo.guestJoinUri = [NSString stringWithUTF8String:confListInfo.guest_join_uri];
    return ecConfInfo;
}
@end
