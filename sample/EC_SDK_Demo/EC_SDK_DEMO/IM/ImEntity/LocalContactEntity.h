//
//  LocalContactEntity.h
//
//  Created on 6/30/15.
//  Copyright (c) 2017 Huawei Tech. Co., Ltd. All rights reserved.
//

#import <AddressBook/AddressBook.h>
#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "ContactEntity.h"

@class EmployeeEntity;

@interface LocalContactProperty : NSObject

@property (nonatomic, copy) NSString *label;
@property (nonatomic, strong) NSMutableArray *values;
@property (nonatomic, assign) BOOL autoWrap;

- (NSString *)valueWillDisplayed;

@end

@interface LocalContactEntity : ContactEntity

@property (nonatomic, retain) NSNumber * abRecId;
@property (nonatomic, retain) EmployeeEntity *matchedEmpl;
@property (nonatomic, retain) NSString *pinyinName;

- (void)updateIfNeed:(NSString *)name;
- (NSString *)firstPhoneNumber;
- (NSString *)compositeLocalName;
- (NSArray *)allPhoneNumbers;
/**
 *  支持进行通讯录匹配的手机号码
 *
 *  @return 手机号码数组
 */
- (NSArray *)ableMatchPhoneNum;
- (NSArray *)ableMatchPhoneNums:(NSArray *)phoneNums;
- (UIImage *)headImage;
- (NSArray<LocalContactProperty *> *)phoneNumbers;
- (NSArray<LocalContactProperty *> *)emails;
- (NSArray<LocalContactProperty *> *)addresses;

/**
 *  获取本地联系人的号码，支持标签(CallNumberItem)
 *
 *  @return 号码列表CallNumberItem
 */
- (NSArray*)phoneNumbersWithLabel;

/**
 *  获取通过eSpace呼叫的号码
 *
 *  @return 号码列表CallNumberItem
 */
- (NSArray*)callNumsViaEspace;

/**
 *  获取通过eSpace呼叫的号码
 *
 *  @param isShowLimit 是否需要做显示限制
 *
 *  @return 满足条件的号码列表CallNumberItem
 */
- (NSArray *)callNumsViaEspaceWithShowLimit:(BOOL)isShowLimit;

/**
 *  获取通过手机拨打的号码
 *
 *  @return 号码列表CallNumberItem
 */
- (NSArray*)callNumsViaPhone;

/**
 *  获取通过手机拨打的号码
 *
 *  @param isShowLimit 是否需要做显示限制
 *
 *  @return 满足条件的号码列表CallNumberItem
 */
- (NSArray *)callNumsViaPhoneWithShowLimit:(BOOL)isShowLimit;

@end
