//
//  ECSConfInfo+StructParase.h
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

#import "ECConfInfo.h"
#import "tsdk_conference_def.h"

@interface ECConfInfo (StructParase)
+(ECConfInfo *)returnECConfInfoWith:(TSDK_S_CONF_BASE_INFO)confListInfo;
@end
