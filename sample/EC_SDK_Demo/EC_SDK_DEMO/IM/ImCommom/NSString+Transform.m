//
//  NSString+Transform.m
//  eSpace
//
//  Created by heleiwu on 7/1/15.
//  Copyright (c) 2015 www.huawei.com. All rights reserved.
//

#import "NSString+Transform.h"
#import "EmployeeEntity.h"
#import "PhoneticContacts.h"
//#import "ECSUtils.h"

@implementation NSString (Transform)

/**
 *  Get the first letter of receiver, one of A-Z, #
 *
 *  @return first letter.
 */
- (NSString*)firstLetter {
    NSString *trimmedStr = [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (trimmedStr.length > 0) {
        NSRange range = {0, 1};
        trimmedStr = [trimmedStr substringWithRange:range];
        if (trimmedStr && ([trimmedStr compare:@"A"] < 0 || [trimmedStr compare:@"Z"] > 0)) {
            trimmedStr = @"#";
        }
        
        return trimmedStr;
    } else {
        return @"#";
    }
}


/**
 *  Parse sub-char not in 'A'-'Z' and '#' to '['
 *
 *  @return pased transformed string.
 */
- (NSString *)nameIndex {
    NSString *transformedStr = [[self transformedString] uppercaseString];
    NSString *trimmedStr = [transformedStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (trimmedStr.length > 0) {
        NSRange range = {(unsigned int)'A', 26};
        NSMutableCharacterSet *charSet = [NSMutableCharacterSet characterSetWithRange:range]; // From 'A' to 'Z'
        [charSet addCharactersInString:@" "]; // Add the space.
        [charSet invert];
        NSRange searchRange = {0, trimmedStr.length};
        NSRange resultRange;
//        do {
//            resultRange = [trimmedStr rangeOfCharacterFromSet:charSet options:NSCaseInsensitiveSearch range:searchRange];
//            if (resultRange.location != NSNotFound) {
//                trimmedStr = [trimmedStr stringByReplacingCharactersInRange:resultRange withString:LAST_SECTION_INDEX];
//                NSInteger maxRang = resultRange.location + LAST_SECTION_INDEX.length;
//                searchRange.location = maxRang;
//                searchRange.length = trimmedStr.length - maxRang;
//            }
//        } while (resultRange.location != NSNotFound);
        resultRange = [trimmedStr rangeOfCharacterFromSet:charSet options:NSCaseInsensitiveSearch range:searchRange];
        if (resultRange.location != NSNotFound && resultRange.location == 0) {
            trimmedStr = [NSString stringWithFormat:@"[%@",trimmedStr];
        }

        return trimmedStr;
    } else {
        return LAST_SECTION_INDEX;
    }
}

/**
 *  Get the spell string.
 *
 *  @return Spelled string, such as Chinese Pinyin.
 */
- (NSString *)transformedString {
    
    if (self.length <= 0) {
        return self;
    }
    
//    if ([ECSUtils IsContainChinese:self]) {//名字中含有中文时，使用特殊的转拼音方法
//        return [PhoneticContacts pingyinName:self];
//    }

    NSMutableString *mutableString = [self mutableCopy];
    BOOL bSuccess = CFStringTransform((__bridge CFMutableStringRef)mutableString, NULL, kCFStringTransformToLatin, NO);
    if (bSuccess) {
        bSuccess = CFStringTransform((__bridge CFMutableStringRef)mutableString, NULL, kCFStringTransformStripCombiningMarks, NO);
    }
    return bSuccess ? mutableString : nil;
}

- (NSArray*)matchResultWithRegularExpression:(NSString*)regularExpression
{
    if ([self length] == 0) {
        return nil;
    }
    
    //设置匹配规则
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regularExpression
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:nil];
    
    //匹配结果
    NSUInteger numberOfMatches = [regex numberOfMatchesInString:self
                                                        options:NSMatchingWithoutAnchoringBounds
                                                          range:NSMakeRange(0, [self length])];
    if (numberOfMatches == 0) {
        return nil;
    }
    NSArray *matches = [regex matchesInString:self
                                      options:NSMatchingReportCompletion
                                        range:NSMakeRange(0, [self length])];
    return matches;
}

/**
 *  生成特殊空格
 *
 *  @return 特殊空格,群组@某人后需要带上
 */
+ (NSString *)createAtSpace{
    char cString[] = "\u2005";
    NSData *data = [[NSData alloc]initWithBytes:cString length:strlen(cString)];
    NSString *atSpace = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    
    return atSpace;
}

/**
 *  获取字符串中@到的人
 *
 *  @param group @某人所在的群组
 *  @param text  输入框中的文本
 *
 *  @return 返回被@到的人
 */
- (NSArray *)atPersonListWithGroup:(GroupEntity *)group inText:(NSString *)text{
    NSMutableArray *personList = [NSMutableArray array];
    NSRange spaceRange = [text rangeOfString:[NSString createAtSpace]];
    
    if (spaceRange.length > 0) {
        NSRange relativeAtRange = [[text substringToIndex:spaceRange.location] rangeOfString:@"@" options:NSBackwardsSearch];
        if (relativeAtRange.length > 0) {
            NSString* nameStr = [text substringWithRange:NSMakeRange(relativeAtRange.location+1,
                                                                     spaceRange.location-relativeAtRange.location-1)];
            NSArray *personAry = [self personWithName:nameStr inGroup:group];
            if ([personAry count] > 0) {
                [personList addObjectsFromArray:personAry];
            }
            
        }
        
        if ([text length] > spaceRange.location+1) {
            NSString *subStr = [text substringFromIndex:spaceRange.location+1];
            NSArray *personAry = [self atPersonListWithGroup:group inText:subStr];
            if ([personAry count] > 0) {
                [personList addObjectsFromArray:personAry];
            }
        }
        
    }
    return personList;
}

/**
 *  匹配@到的人
 *
 *  @param name  需要匹配的名字
 *  @param group @某人的群组
 *
 *  @return 返回匹配到的账号
 */
-(NSArray*)personWithName:(NSString*)name inGroup:(GroupEntity*)group{
    
    if ([name length] == 0) {
        return nil;
    }
    
    NSMutableArray *personList = [NSMutableArray array];
//    for(EmployeeEntity * member in [group.members allObjects]){
//        NSString* personName = [member plainNameShowId:NO needNickName:NO needRemarkName:NO];
//        if ([name isEqualToString:personName]) {
//            [personList addObject:member.account];
//        }
//    }
    
    return personList;
}

- (NSArray*)analysisStringWithRegularExpression:(NSString*)regularExpression
{
    NSMutableArray* messageItems = [NSMutableArray array];
    // 分解图文混排消息为多条消息
    NSArray* matchArray = [self matchResultWithRegularExpression:regularExpression];
    if ([matchArray count] == 0) {
        NSString* textContent = [NSString stringWithString:self];
        [messageItems addObject:textContent];
    }
    else {
        
        NSInteger location = 0;    // 记录chatContent.content字符读取位置
        NSInteger index = 0;
        for (NSTextCheckingResult* result in matchArray) {
            NSRange umRange = [result range];
            if (umRange.location != location) {    // 说明两个UM之前存在文本内容
                NSRange textRange = NSMakeRange(location, umRange.location - location);
                NSString* textContent = [self substringWithRange:textRange];
                [messageItems addObject:textContent];
            }
            
            NSString* umContent = [self substringWithRange:umRange];
            
            [messageItems addObject:umContent];
            location = umRange.location + umRange.length;
            index++;
        }
        
        // 最后一段UM后是否还存在文本内容
        if (location < self.length) {
            NSRange textRange = NSMakeRange(location, self.length - location);
            NSString* textContent = [self substringWithRange:textRange];
            
            [messageItems addObject:textContent];
        }
    }
    return messageItems;
}

- (BOOL) isNumberic {
    NSNumberFormatter* numberFormatter = [[NSNumberFormatter alloc] init];
    NSNumber* number = [numberFormatter numberFromString:self];
    return number != nil;
}

+ (NSString *)fileSizeString:(long long)llSize {
    double size = llSize / 1024.0;
    if (size > 1024) {
        size = size / 1024.0;
        return [NSString stringWithFormat:@"%0.2fM",size];
    }if (size > 1) {
        return [NSString stringWithFormat:@"%0.2fK",size];
    }else{
        return [NSString stringWithFormat:@"%lldB",llSize];
    }
}

@end
