//
//  LocalContactEntity.m
//  eSpace
//
//  Created by heleiwu on 6/30/15.
//  Copyright (c) 2015 www.huawei.com. All rights reserved.
//

#import "LocalContactEntity.h"
#import "EmployeeEntity.h"
#import "NSString+Transform.h"
#import "ECSUtils.h"
#import "ECSAppConfig.h"
#import "PhoneticContacts.h"
//#import "TUPMediator_ContactService.h"

@implementation LocalContactProperty

- (instancetype)init {
    if (self = [super init]) {
        _values = [NSMutableArray arrayWithCapacity:0];
    }
    
    return self;
}

- (NSString *)valueWillDisplayed {
    NSMutableString *allValue = [NSMutableString stringWithCapacity:0];
    for (NSString *value in self.values) {
        [allValue appendFormat:allValue.length == 0 ? @"%@" : @"\n%@", value];
    }
    
    return allValue;
}

@end

@implementation LocalContactEntity

@dynamic abRecId;
@dynamic matchedEmpl;
@dynamic pinyinName;


- (void)updateIfNeed:(NSString *)name {
    if ([name isEqualToString:self.name]) {
        return;
    }
    
    self.name = name;
    NSArray *array = [PhoneticContacts pinyinAndSimplifiedPinyin:name];
    if ([array count] > 0 && [[array firstObject] length] > 0) {
        self.pinyinName = [array firstObject];
    } else {
        self.pinyinName = self.nameIndex;
    }
}

- (NSArray *)allPhoneNumbers {
    // Category implement detail logic;
    return nil;
}

- (NSArray<LocalContactProperty *> *)phoneNumbers {
    // Category implement detail logic;
    return nil;
}

- (NSArray<LocalContactProperty *> *)emails {
    // Category implement detail logic;
    return nil;
}

- (NSArray<LocalContactProperty *> *)addresses {
    // Category implement detail logic;
    return nil;
}

- (UIImage *)headImage{
    // Category implement detail logic;
    return nil;
}

/**
 *  Get a valid person name.
 *
 *  @param record ABRecordRef.
 *
 *  @return valid person name.
 */
- (NSString *)compositeLocalName {
    // Category implement detail logic;
    return nil;
}

- (NSString *)firstPhoneNumber {
    return [self allPhoneNumbers].firstObject;
}

- (NSArray*)ableMatchPhoneNum {
    NSMutableArray* matchPhoneNums = [NSMutableArray array];
    NSArray* phoneNums = [self allPhoneNumbers];
    for (NSString* number in phoneNums) {
        if (7 <= [number length] && 18 >= [number length]){//检查待查号码规范 暂时在7~18之间
            [matchPhoneNums addObject:number];
        }
    }
    
    return matchPhoneNums;
}

- (NSArray *)ableMatchPhoneNums:(NSArray *)phoneNums
{
    NSMutableArray* matchPhoneNums = [NSMutableArray array];
    for (NSString* number in phoneNums) {
        if (7 <= [number length] && 18 >= [number length]){//检查待查号码规范 暂时在7~18之间
            [matchPhoneNums addObject:number];
        }
    }
    
    return matchPhoneNums;
}

- (UIImage *)defaultHeadImage {
    return [[ESpaceContactHeadImageService sharedInstance] defaultLocalContactHeadImage];
}

- (NSArray*)phoneNumbersWithLabel {
    NSArray* localNumbers = [self phoneNumbers];
    NSMutableArray *outArr_ = [NSMutableArray array];
    for (LocalContactProperty *property in localNumbers) {
        NSString* temp_Key = [property label]; //号码类别
        NSString* temp_No = [property values].firstObject;//号码值
        
        CallNumberItem* item = [[CallNumberItem alloc] initWithType:ESpaceCallNumberObjectType_Local title:temp_Key number:temp_No displayTitle:YES hideLastNumber:NO];
        [outArr_ addObject:item];
    }
    return outArr_;
}

/**
 *  手机通讯录号码导入espace号码列表或手机拨打号码列表
 *
 *  @param array1 源数据
 *  @param array2 目的数据
 */
- (void)filteringAndAddElementFromArray:(NSArray*)array1 toArray:(NSMutableArray*)array2 {
    for (CallNumberItem* insertObj in array1) {
        NSString* number = insertObj.numberValue;
        BOOL isAbleInsert = YES;
        for (CallNumberItem* tempObj in array2) {
            NSString* tempNum = tempObj.numberValue;
            if ([number isEqualToString:tempNum]) {
                isAbleInsert = NO;
                break;
            }
        }
        if (isAbleInsert) {
            [array2 addObject:insertObj];
        }
    }
}

- (NSArray*)callNumsViaEspace {
    return [self callNumsViaEspaceWithShowLimit:NO];
}

- (NSArray *)callNumsViaEspaceWithShowLimit:(BOOL)isShowLimit
{
    NSArray* results = nil;
//    if (nil != self.matchedEmpl && MatchMobileStateEnable == [ECSAppConfig sharedInstance].currentUser.matchMobileState) {
//        NSMutableArray* espaceNums = [NSMutableArray arrayWithArray:(NSArray *)[TUPMediator_ContactService M_callNumsViaEspaceWithShowLimit:isShowLimit person:self.matchedEmpl]];
//        [self filteringAndAddElementFromArray:[self phoneNumbersWithLabel] toArray:espaceNums];
//        results = [NSArray arrayWithArray:espaceNums];
//    }
//    else{
//        results = [NSArray arrayWithArray:[self phoneNumbersWithLabel]];
//    }
    
    return results;
}

- (NSArray*)callNumsViaPhone {
    return [self callNumsViaPhoneWithShowLimit:NO];
}

- (NSArray *)callNumsViaPhoneWithShowLimit:(BOOL)isShowLimit
{
    NSArray* results = nil;
//    if (nil != self.matchedEmpl && MatchMobileStateEnable == [ECSAppConfig sharedInstance].currentUser.matchMobileState) {
//        NSMutableArray* phoneNums = [NSMutableArray arrayWithArray:(NSArray *)[TUPMediator_ContactService M_callNumsViaEspaceWithShowLimit:isShowLimit person:self.matchedEmpl]];
//        
//        [self filteringAndAddElementFromArray:[self phoneNumbersWithLabel] toArray:phoneNums];
//        results = [NSArray arrayWithArray:phoneNums];
//    }
//    else{
//        results = [NSArray arrayWithArray:[self phoneNumbersWithLabel]];
//    }
    
    return results;
}

- (BOOL)isEqualToContact:(LocalContactEntity *)c
{
    if (![c isKindOfClass:self.class]) {
        return NO;
    }
    
    if ([self.contactId isEqualToString:c.contactId]) {
        return YES;
    }
    
    return [super isEqualToContact:c];
}

@end
