//
//  PhoneticContacts.h
//
//  Created on 3/25/16.
//  Copyright © 2017 Huawei Tech. Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PhoneticContacts : NSObject

/**
 *  返回中文姓名的拼音
 *
 *  @param name 中文姓名
 *
 *  @return 姓名拼音
 */
+ (NSString*)pingyinName:(NSString*)name;


/**
 *  获取中文名称的拼音和简拼
 *
 *  @param name 中文姓名
 *
 *  @return 拼音和简拼
 */
+ (NSArray*)pinyinAndSimplifiedPinyin:(NSString*)name;
@end
