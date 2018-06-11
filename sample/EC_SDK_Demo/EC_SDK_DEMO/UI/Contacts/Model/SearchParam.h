//
//  SearchParam.h
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

#import <Foundation/Foundation.h>

@interface SearchParam : NSObject

@property (nonatomic, copy) NSString *acSearchItem;    // search item
@property (nonatomic, copy) NSString *acDepId;         // search department Id
@property (nonatomic, assign) int ulPageIndex;         // page Index
@property (nonatomic, assign) int ulExactSearch;       // is exact search or not
@property (nonatomic, assign) int ulSeqNo;             // sequence number

@end
