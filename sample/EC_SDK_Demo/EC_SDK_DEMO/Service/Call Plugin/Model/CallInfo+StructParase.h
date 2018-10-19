//
//  CallInfo+StructParase.h
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

#import "CallInfo.h"
//#import "call_def.h"
//#import "call_advanced_def.h"

#import "tsdk_call_def.h"

@interface CallInfo (StructParase)
+ (CallInfo *)transfromFromCallInfoStract:(TSDK_S_CALL_INFO *)callInfo;

@end
