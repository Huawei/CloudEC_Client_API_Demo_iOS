//
//  ECCurrentConfInfo.h
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

#import <Foundation/Foundation.h>

@class ECConfInfo,ConfAttendee;
@interface ECCurrentConfInfo : NSObject
@property (nonatomic, strong)ECConfInfo *confDetailInfo; //会议详情
@property (nonatomic, strong)NSArray *attendeeArray; //与会者列表
@end
