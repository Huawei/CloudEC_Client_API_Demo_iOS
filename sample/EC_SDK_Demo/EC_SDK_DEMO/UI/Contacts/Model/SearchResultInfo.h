//
//  SearchResultInfo.h
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

#import <Foundation/Foundation.h>
#import "tsdk_eaddr_def.h"

@interface SearchResultInfo : NSObject

@property (assign, nonatomic) int ulItemNum;              // item number
@property (copy, nonatomic) NSString *acSearchDepId;      // searching department id


/**
 This method is used to transform TSDK_S_SEARCH_DEPARTMENT_RESULT data to SearchResultInfo data

 @param result TSDK_S_SEARCH_DEPARTMENT_RESULT
 @return SearchResultInfo
 */
+ (SearchResultInfo *)resultInfoTransformFrom:(TSDK_S_SEARCH_DEPARTMENT_RESULT *)result;

@end
