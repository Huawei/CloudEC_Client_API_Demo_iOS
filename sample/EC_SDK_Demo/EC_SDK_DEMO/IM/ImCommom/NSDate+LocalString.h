//
//  NSDate+LocalString.h
//
//  Created on 3/13/15.
//  Copyright (c) 2017 Huawei Tech. Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

#define ONE_DAY 24 * 60 * 60

@interface NSDate (LocalString)

- (NSString*) toLocalString;
/**
 *  @author LG, 2015-10-19 16:10:58 
 *
 *  Description:
 *  只返回 小时分  如：14：32
 */
- (NSString*) toTimeString;
- (NSString*) tolocalDateString;
/**
 *  @author LG, 2015-11-23 09:10:58
 *
 *  Description:
 *  返回时间字符串格式： 如 1：今天14：32
 *                      2：昨天14：32
 *                      3：超过前天  只显示 日期
 */
- (NSString*) tolocalDateWithTimeString;
- (NSString*) toNumberString;
- (NSDate*) datePart;
- (NSDate*) dateWithNoSeconds;
- (BOOL) isYesterday;
- (BOOL) isToday;
- (NSString *) toTopicViewCellTime;
@end
