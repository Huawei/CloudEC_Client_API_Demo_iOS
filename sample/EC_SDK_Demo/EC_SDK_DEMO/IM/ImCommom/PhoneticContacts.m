//
//  PhoneticContacts.m
//  eSpaceIOSSDK
//
//  Created by wangxiangyang on 3/25/16.
//  Copyright © 2016 HuaWei. All rights reserved.
//

#import "PhoneticContacts.h"
#import "ECSUtils.h"

@implementation PhoneticContacts

+ (NSDictionary*)mutiblePhoneticFamilyNamePinyin {
    static NSDictionary* mutiblePhoneticFamilyNameDic = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mutiblePhoneticFamilyNameDic = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                        @"bai",@"柏",
                                        @"bao",@"鲍",
                                        @"ben",@"贲",@"ben",@"賁",
                                        @"bi",@"秘",
                                        @"bo",@"薄",
                                        @"bu",@"卜",@"bu",@"蔔",
                                        @"cen",@"岑",
                                        @"chao",@"晁",
                                        @"chen",@"谌",
                                        @"chong",@"种",@"chong",@"種",
                                        @"chu",@"褚",
                                        @"chuai",@"啜",
                                        @"shan",@"单",@"shan",@"單",
                                        @"chi",@"郗",
                                        @"di",@"邸",
                                        @"du",@"都",
                                        @"miao",@"缪",
                                        @"mi",@"宓",
                                        @"fei",@"费",@"fei",@"費",
                                        @"fu",@"苻",
                                        @"sui",@"睢",
                                        @"ou",@"区",@"ou",@"區",
                                        @"hua",@"华",@"hua",@"華",
                                        @"pang",@"庞",@"pang",@"龐",
                                        @"zha",@"查",
                                        @"she",@"佘",
                                        @"qiu",@"仇",
                                        @"jin",@"靳",
                                        @"xie",@"解",
                                        @"po",@"繁",
                                        @"she",@"折",
                                        @"yun",@"员",@"yun",@"員",
                                        @"zhai",@"祭",
                                        @"rui",@"芮",
                                        @"tan",@"覃",
                                        @"mou",@"牟",
                                        @"pi",@"蕃",
                                        @"qi",@"戚",
                                        @"qu",@"瞿",
                                        @"xian",@"冼",
                                        @"xian",@"洗",
                                        @"xi",@"郤",
                                        @"tuo",@"庹",
                                        @"tong",@"彤",
                                        @"tong",@"佟",
                                        @"gui",@"妫",
                                        @"gou",@"句",
                                        @"hao",@"郝",
                                        @"zeng",@"曾",
                                        @"yue",@"乐",@"yue",@"樂",
                                        @"lin",@"蔺",
                                        @"juan",@"隽",
                                        @"zang",@"臧",
                                        @"yu",@"庾",
                                        @"zhan",@"詹",
                                        @"zhuo",@"禚",
                                        @"ze",@"迮",
                                        @"shen",@"沈",
                                        @"shen",@"沉",
                                        @"yuchi",@"尉迟",@"yuchi",@"尉遲",
                                        @"zhangsun",@"长孙",@"zhangsun",@"長孫",
                                        @"zhonghang",@"中行",
                                        @"moqi", @"万俟",@"moqi", @"萬俟",
                                        @"chanyu", @"单于",@"chanyu", @"單于",
                                        @"piao", @"朴",
                                        @"nie", @"乜",
                                        @"tantai", @"澹台",
                                        @"ge", @"盖",
                                        @"yao", @"么",
                                        nil];
    });
    
    return mutiblePhoneticFamilyNameDic;
}

/**
 *  判断是否姓氏是多音字，如果是返回多音字，否则返回nil
 *
 *  @param name 中文姓名
 *
 *  @return 多音字中文姓氏
 */
+ (NSString*)isMutiblePhoneticFamilyName:(NSString*)name {
    NSDictionary* mutiblePhoneticFamilyNameDic = [PhoneticContacts mutiblePhoneticFamilyNamePinyin];
    NSString* mutiblePhonetic = nil;
    
    for (NSString* tempFamilyName in [mutiblePhoneticFamilyNameDic allKeys]) {
        NSRange matchLocation = [name rangeOfString:tempFamilyName];
        if (0 != matchLocation.length && 0 == matchLocation.location) {
            //匹配到多音字姓氏
            mutiblePhonetic = [NSString stringWithString:tempFamilyName];
            break;
        }
    }
    
    return mutiblePhonetic;
}

/**
 *  返回中文姓名的拼音
 *
 *  @param name 中文姓名
 *
 *  @return 姓名拼音+简拼
 */
+ (NSString*)pingyinName:(NSString*)name {
    return [[PhoneticContacts pinyinAndSimplifiedPinyin:name] firstObject];
}

/**
 *  获取中文名称的拼音和简拼
 *
 *  @param name 中文姓名
 *
 *  @return 拼音和简拼
 */
+ (NSArray*)pinyinAndSimplifiedPinyin:(NSString*)name {
    if (0 == [name length] || NO == [ECSUtils IsContainChinese:name]) {
        return [NSArray arrayWithObjects:name, name, nil];
    }
    
    NSString* pinyinName = @"";
    NSString* simplifiedPinyin = @"";
    
    NSDictionary* familyNameDic = [PhoneticContacts mutiblePhoneticFamilyNamePinyin];
    NSString* familyName = [PhoneticContacts isMutiblePhoneticFamilyName:name];
    if ([familyName length]) {
        
        pinyinName = [familyNameDic objectForKey:familyName];
        simplifiedPinyin = [pinyinName substringWithRange:NSMakeRange(0, 1)];
        
        if ([name length] > 1) {//防止只有一个字
//            NSString* firstName = [name substringWithRange:NSMakeRange([name rangeOfString:familyName].location + [name rangeOfString:familyName].length, name.length - [name rangeOfString:familyName].length)];
            
//            NSArray*queryResult = [ECSUtils c:firstName];
//            NSString* pinyinOfFirstName = [queryResult firstObject];
//            
//            pinyinName = [pinyinName stringByAppendingString:pinyinOfFirstName];
//            simplifiedPinyin = [simplifiedPinyin stringByAppendingString:[queryResult objectAtIndex:1]];
        }
    }
    else {
//        NSArray* result = [ECSUtils getEnglishStr:name];
//        pinyinName = [result firstObject];
//        simplifiedPinyin = [result objectAtIndex:1];
    }
    
    return [NSArray arrayWithObjects:pinyinName, simplifiedPinyin, nil];
}




@end
