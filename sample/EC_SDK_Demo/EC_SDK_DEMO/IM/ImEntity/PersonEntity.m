//
//  EmployeeEntity.m
//  
//
//  Created by yemingxing on 8/3/15.
//
//

#import "EmployeeEntity.h"
#import "EmployeeCategoryEntity.h"
#import "LocalContactEntity.h"
#import "ECSUtils.h"
#import "ECSAppConfig.h"

@implementation PersonEntity

@dynamic userStatus;
@dynamic bdHideFlag;
@dynamic groupId;
@dynamic isFriend;
@dynamic sendCircleMsg;
@dynamic recvCircleMsg;
@dynamic category;
@dynamic personId;

//ECSEntryptCoreDataStringProp(address, Address)
//ECSEntryptCoreDataStringProp(assistantList, AssistantList)
//ECSEntryptCoreDataStringProp(bindNumber, BindNumber)
//ECSEntryptCoreDataStringProp(contact, Contact)
//ECSEntryptCoreDataStringProp(deptDesc, DeptDesc)
//ECSEntryptCoreDataStringProp(deptDescEnglish, DeptDescEnglish)
//ECSEntryptCoreDataStringProp(deptName, DeptName)
//ECSEntryptCoreDataStringProp(displayName, DisplayName)
//ECSEntryptCoreDataStringProp(domain, Domain)
//ECSEntryptCoreDataStringProp(email, Email)
//ECSEntryptCoreDataStringProp(fax, Fax)
//ECSEntryptCoreDataStringProp(faxList, FaxList)
//ECSEntryptCoreDataStringProp(foreignName, ForeignName)
//ECSEntryptCoreDataStringProp(homePage, HomePage)
//ECSEntryptCoreDataStringProp(homePhone, HomePhone)
//ECSEntryptCoreDataStringProp(interPhoneList, InterPhoneList)
//ECSEntryptCoreDataStringProp(m2, M2)
//ECSEntryptCoreDataStringProp(mobile, Mobile)
//ECSEntryptCoreDataStringProp(mobileList, MobileList)
//ECSEntryptCoreDataStringProp(nativeName, NativeName)
//ECSEntryptCoreDataStringProp(nickname, Nickname)
//ECSEntryptCoreDataStringProp(notesMail, NotesMail)
//ECSEntryptCoreDataStringProp(officePhone, OfficePhone)
//ECSEntryptCoreDataStringProp(originMobile, OriginMobile)
//ECSEntryptCoreDataStringProp(originOffice, OriginOffice)
//ECSEntryptCoreDataStringProp(otherInfo, OtherInfo)
//ECSEntryptCoreDataStringProp(phone, Phone)
//ECSEntryptCoreDataStringProp(phoneList, PhoneList)
//ECSEntryptCoreDataStringProp(pinyinName, PinyinName)
//ECSEntryptCoreDataStringProp(position, Position)
//ECSEntryptCoreDataStringProp(postalCode, PostalCode)
//ECSEntryptCoreDataStringProp(room, Room)
//ECSEntryptCoreDataStringProp(sex, Sex)
//ECSEntryptCoreDataStringProp(shortNumber, ShortNumber)
//ECSEntryptCoreDataStringProp(signature, Signature)
//ECSEntryptCoreDataStringProp(simplifiedPinyin, SimplifiedPinyin)
//ECSEntryptCoreDataStringProp(softClientExtPhone, SoftClientExtPhone)
//ECSEntryptCoreDataStringProp(softClientExtPhoneDomain, SoftClientExtPhoneDomain)
//ECSEntryptCoreDataStringProp(sp2, Sp2)
//ECSEntryptCoreDataStringProp(sp2Domain, Sp2Domain)
//ECSEntryptCoreDataStringProp(sp3, Sp3)
//ECSEntryptCoreDataStringProp(sp3Domain, Sp3Domain)
//ECSEntryptCoreDataStringProp(sp4, Sp4)
//ECSEntryptCoreDataStringProp(sp4Domain, Sp4Domain)
//ECSEntryptCoreDataStringProp(sp5, Sp5)
//ECSEntryptCoreDataStringProp(sp5Domain, Sp5Domain)
//ECSEntryptCoreDataStringProp(sp6, Sp6)
//ECSEntryptCoreDataStringProp(sp6Domain, Sp6Domain)
//ECSEntryptCoreDataStringProp(spDomain, SpDomain)
//ECSEntryptCoreDataStringProp(staffNo, StaffNo)
//ECSEntryptCoreDataStringProp(timezone, Timezone)
//ECSEntryptCoreDataStringProp(timezoneValue, TimezoneValue)
//ECSEntryptCoreDataStringProp(voip, Voip)
//ECSEntryptCoreDataStringProp(voip2, Voip2)
//ECSEntryptCoreDataStringProp(voip2Domain, Voip2Domain)
//ECSEntryptCoreDataStringProp(voip3, Voip3)
//ECSEntryptCoreDataStringProp(voip4, Voip4)
//ECSEntryptCoreDataStringProp(voip5, Voip5)
//ECSEntryptCoreDataStringProp(voip6, Voip6)
//ECSEntryptCoreDataStringProp(voipDomain, VoipDomain)
//ECSEntryptCoreDataStringProp(voipList, VoipList)

- (NSString *)plainNameShowId:(BOOL)show needNickName:(BOOL)need needRemarkName:(BOOL)needRemark{
    NSString *preName = [self displayNameNeedNickName:need needRemarkName:needRemark];
    
    if (0 == [preName length]) {
        return @"";
    }
    
    NSString * fixName = preName;
    NSString *lastWord = [fixName substringWithRange:NSMakeRange([fixName length] - 1, 1)];
    
    //优化去除工号的逻辑方案，仅在名字最后一个字符是数字时才进行裁剪
    if (0 != [@"0123456789" rangeOfString:lastWord].length) {
        NSRange range = [preName rangeOfString:@" " options:NSBackwardsSearch];
        if (range.location != NSNotFound && range.location != 0) {
            fixName = [preName substringToIndex:range.location];
        }
    }
    
    if (![[[ECSAppConfig sharedInstance] currentUser] isHWUC]) {
        show = YES;   //非华为UC无工号,所以需要完整显示
    }
    
    NSString *name = @"";
    if (show) {
        name = preName;
    }else{
        name = fixName;
    }
    
    if (needRemark && [self.remarkName length]) {
        name = [NSString stringWithFormat:@"%@(%@)", name, self.remarkName];
    }
    
    return name;
}

- (NSString *)plainNameShowId:(BOOL)show needNickName:(BOOL)need {
    return [self plainNameShowId:show needNickName:need needRemarkName:NO];
}

- (NSString *)phoneNumSuportsSMS {
    NSString *number;
    if ([self.originMobile length] > 0) {
        number = self.originMobile;
    } else if ([self.mobile length] > 0) {
        number = self.mobile;
    } else if ([self.m2 length] > 0) {
        number = self.m2;
    }
    
    return number;
}

- (NSString *)displayNameNeedNickName:(BOOL)need needRemarkName:(BOOL)needRemark{
    /*
     联系人显示名字需求:
     1 若联系人nickName(昵称)不为空,优先显示(群组@时不取昵称)
     2.1 在中文环境下,nativeName不为空,其次显示
     2.2 在非中文环境下，优先显示foreignName（不为空）
     3 联系人name不为空,最后显示
     4 上述名字都为空时,返回帐号(espaceNumber)
     5 帐号没有的,返回nil
     */
    NSString *name = nil;
    
    if (need && 0 == [name length]) {
        //先看昵称
        if ([self.isFriend boolValue]  && 0 < [self.nickname length]) {//espace联系人且为好友优先显示昵称
            name = [self.nickname stringByAppendingString:@" "];
        }
    }
    
    //根据语言确定取nativename或foreignName
    if ([name length] == 0 )
    {
        //中文环境，nativename非空，取nativename；非中文环境，foreignName非空，取foreignName
        if ([@"zh" isEqualToString:ECSLocalizedString(@"lang",@"语言环境")]) {
            if ([self.nativeName length] > 0) {
                name = self.nativeName;
            }
        }else{
            if ([self.foreignName length] > 0) {
                name = self.foreignName;
            }
        }
        
    }
    
    //最后名字
    if ([name length] == 0 && 0 < [self.name length]) {//再显示姓名
        name = self.name;
    }
    
    
    return name;
}

- (NSString *)displayNameNeedNickName:(BOOL)need {
    return  [self displayNameNeedNickName:need needRemarkName:NO];
}

- (NSString *)enNamewithOutAccount{
    if (self.name.length > 0) {
        NSString *preName = self.name;
        NSString * fixName = preName;
        NSString *lastWord = [fixName substringWithRange:NSMakeRange([fixName length] - 1, 1)];
        
        //优化去除工号的逻辑方案，仅在名字最后一个字符是数字时才进行裁剪
        if (0 != [@"0123456789" rangeOfString:lastWord].length) {
            NSRange range = [preName rangeOfString:@" " options:NSBackwardsSearch];
            if (range.location != NSNotFound && range.location != 0) {
                fixName = [preName substringToIndex:range.location];
            }
        }
        return fixName;
    }
    return @"";
}

@end
