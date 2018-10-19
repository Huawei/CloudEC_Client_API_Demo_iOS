//
//  SearchResultInfo.m
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

#import "SearchResultInfo.h"

@implementation SearchResultInfo

+ (SearchResultInfo *)resultInfoTransformFrom:(TSDK_S_SEARCH_DEPARTMENT_RESULT *)result
{
    SearchResultInfo *info = [[SearchResultInfo alloc] init];
    info.ulItemNum            = result->item_num;
    info.acSearchDepId        = [NSString stringWithUTF8String:result->department_id];
    
    return info;
}

@end
