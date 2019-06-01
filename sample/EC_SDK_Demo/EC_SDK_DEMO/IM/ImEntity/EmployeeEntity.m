//
//  EmployeeEntity.m
//  eSpaceUI
//
//  Created by yemingxing on 3/16/15.
//  Copyright (c) 2015 www.huawei.com. All rights reserved.
//

#import "EmployeeEntity.h"
#import "CircleSessionEntity.h"
#import "EmployeeCategoryEntity.h"
#import "GroupEntity.h"
#import "NSString+Transform.h"
#import "ECSUtils.h"
#import "ECSAppConfig.h"
#import "eSpaceDBService.h"
//#import "TUPMediator_ContactService.h"

@implementation BasicRight

@synthesize imAllowed;
@synthesize presenceAllowed;
@synthesize showBindNoAllowed;

-(id)initWithFunid:(NSString*)funid
{
    if (self = [super init]) {
        if ([funid length]==2)
        {
            self.imAllowed = [[funid substringToIndex:1] isEqualToString:@"0"]?NO:YES;
            self.presenceAllowed = [[funid substringFromIndex:1] isEqualToString:@"0"]?NO:YES;
            self.showBindNoAllowed = YES;
        }
        //add on 2013.5.9,增加是否显示软终端号码位
        else if ([funid length]==3){
            self.imAllowed = [[funid substringToIndex:1] isEqualToString:@"0"]?NO:YES;
            self.presenceAllowed = [[funid substringWithRange:NSMakeRange(1, 1)] isEqualToString:@"0"]?NO:YES;
            self.showBindNoAllowed = [[funid substringFromIndex:2] isEqualToString:@"0"]?NO:YES;
        }
        //end add on 2013.5.9
        else {
            self.imAllowed = YES;
            self.presenceAllowed = YES;
            self.showBindNoAllowed = YES;
        }
    }
    
    return self;
    
}

-(id)init
{
    return [self initWithFunid:nil];
}

+(BasicRight*)basicRightWithFuncId:(NSString*)funcId
{
    BasicRight *tempRight = [[BasicRight alloc] initWithFunid:funcId];
    return tempRight;
}

@end


@implementation EmployeeStatus

@synthesize mainStatus;
@synthesize exchangeStatus;
@synthesize softClientStatus;
@synthesize softClientCameraShow;
@synthesize ipphoneStatus;
@synthesize softClientRight;
@synthesize ipphoneRight;
@synthesize ipphoneCameraShow;

-(id)init
{
    if (self = [super init]) {
        NSMutableDictionary *tempIpphoneState = [[NSMutableDictionary alloc] init];
        self.ipphoneStatus = tempIpphoneState;
        
        NSMutableDictionary *tempIpphoneRight = [[NSMutableDictionary alloc] init];
        self.ipphoneRight = tempIpphoneRight;
        
        NSMutableDictionary* tempIpphoneCameraShow = [[NSMutableDictionary alloc] init];
        self.ipphoneCameraShow = tempIpphoneCameraShow;
        
        self.softClientRight = [[BasicRight alloc] initWithFunid:nil];
        
        self.softClientCameraShow = NO;
        self.mainStatus = ECS_SHOW_AWAY;
    }
    return self;
}

-(void)clearStatus
{
    //清理状态
    self.mainStatus = ECS_SHOW_AWAY;
    self.exchangeStatus = nil;
    self.softClientStatus = nil;
    [self.ipphoneStatus removeAllObjects];
    //清理权限
    self.softClientRight = nil;
    [self.ipphoneRight removeAllObjects];
    //清理摄像头显示
    self.softClientCameraShow = NO;
    [self.ipphoneCameraShow removeAllObjects];
}

@end

#pragma mark -

@implementation EspaceUserOnlineStatus
@synthesize userStatus;

- (instancetype)init {
    if (self = [super init]) {
        _clientType = -1;
        userStatus = ESpaceUserStatusUnknown;
        _statusInfo = [[EmployeeStatus alloc] init];
    }
    return self;
}

- (NSString*)stateDescribeForStateValue:(ESpaceUserStatus)personState{
    NSString *stateStr;
    switch (personState) {
        case ESpaceUserStatusAvailable:
            stateStr = ECSLocalizedString(@"online",@"在线");
            break;
        case ESpaceUserStatusBusy:
            stateStr = ECSLocalizedString(@"busy",@"忙碌");
            break;
        case ESpaceUserStatusAway:
            stateStr = ECSLocalizedString(@"away",@"离开");
            break;
        case ESpaceUserStatusUninteruptable:
            stateStr = ECSLocalizedString(@"un_interuptable",@"免打扰");
            break;
        case ESpaceUserStatusOffline:
        default:
            stateStr = ECSLocalizedString(@"offline",@"离线");
            break;
    }
    
    return stateStr;
}

- (ESpaceUserStatus)statusEnumValueOfStstusString:(NSString*)status {
    ESpaceUserStatus statusValue = ESpaceUserStatusUnknown;
    
    if ([status isEqualToString:ECS_SHOW_CHAT]) {
        statusValue = ESpaceUserStatusAvailable;
    }
    else if ([status isEqualToString:ECS_SHOW_AWAY]) {
        statusValue = ESpaceUserStatusUnknown;
    }
    else if ([status isEqualToString:ECS_SHOW_DND]) {
        statusValue = ESpaceUserStatusBusy;
    }
    else if ([status isEqualToString:ECS_SHOW_XA]) {
        statusValue = ESpaceUserStatusAway;
    }
    else if ([status isEqualToString:ECS_SHOW_HIDE]) {
        statusValue = ESpaceUserStatusUnknown;
    }
    else if ([status isEqualToString:ECS_SHOW_UNINTERRUPTABLE]) {
        statusValue = ESpaceUserStatusUninteruptable;
    }
    return statusValue;
}

-(BOOL)isIPPhoneContainStatus:(NSString*)state_
{
    BOOL shortPhoneRight = [[self.statusInfo.ipphoneRight objectForKey:self.number1] presenceAllowed];
    BOOL sp2Right = [[self.statusInfo.ipphoneRight objectForKey:self.number2] presenceAllowed];
    BOOL sp3Right = [[self.statusInfo.ipphoneRight objectForKey:self.number3] presenceAllowed];
    BOOL sp4Right = [[self.statusInfo.ipphoneRight objectForKey:self.number4] presenceAllowed];
    BOOL sp5Right = [[self.statusInfo.ipphoneRight objectForKey:self.number5] presenceAllowed];
    BOOL sp6Right = [[self.statusInfo.ipphoneRight objectForKey:self.number6] presenceAllowed];
    
    NSString *shortPhoneStatus = [self.statusInfo.ipphoneStatus objectForKey:self.number1];
    NSString *sp2Status = [self.statusInfo.ipphoneStatus objectForKey:self.number2];
    NSString *sp3Status = [self.statusInfo.ipphoneStatus objectForKey:self.number3];
    NSString *sp4Status = [self.statusInfo.ipphoneStatus objectForKey:self.number4];
    NSString *sp5Status = [self.statusInfo.ipphoneStatus objectForKey:self.number5];
    NSString *sp6Status = [self.statusInfo.ipphoneStatus objectForKey:self.number6];
    
    if ((shortPhoneRight && [shortPhoneStatus isEqualToString:state_])
        || (sp2Right && [sp2Status isEqualToString:state_])
        || (sp3Right && [sp3Status isEqualToString:state_])
        || (sp4Right && [sp4Status isEqualToString:state_])
        || (sp5Right && [sp5Status isEqualToString:state_])
        || (sp6Right && [sp6Status isEqualToString:state_])) {
        return YES;
    }
    
    return NO;
}


- (ESpaceUserStatus)userStatus {
    
    if([self.account compare:[LOCAL_DATA_MANAGER userAccount]] == NSOrderedSame) {
        return [self statusEnumValueOfStstusString:self.statusInfo.mainStatus];
    }
    
    NSString *state = ECS_SHOW_AWAY;
    
    /*
     modify for IR.MOBILE.UC.003 终端状态一致：优先显示免打扰和忙碌状态
     1、优先显示免打扰和忙碌状态
     原有流程：
     1、首先判断是否有绑定号且同时有PRECENCE权限，有，直接用主状态
     2、否则判断为ip电话状态，首先判断ip电话1的状态，如果没有则判断ip电话2的状态
     3、都不符合依然返回主状态
     */
    BOOL softClientRight = self.statusInfo.softClientRight.presenceAllowed;
    NSString *softClientStatus = self.statusInfo.mainStatus;
    
    
    //优先显示免打扰和忙碌状态
    if ((softClientRight && [softClientStatus isEqualToString:ECS_SHOW_UNINTERRUPTABLE])
        || [self isIPPhoneContainStatus:ECS_SHOW_UNINTERRUPTABLE]) {
        return [self statusEnumValueOfStstusString:ECS_SHOW_UNINTERRUPTABLE];
    }
    
    
    if ((softClientRight && [softClientStatus isEqualToString:ECS_SHOW_DND])
        || [self isIPPhoneContainStatus:ECS_SHOW_DND]) {
        return [self statusEnumValueOfStstusString:ECS_SHOW_DND];
    }
    //优先显示免打扰和忙碌状态 end
    
    if ([self.bindNumber length]>0 && softClientRight) {
        state = softClientStatus;
    }else {
        /*
         在没有软终端号码、有多个硬终端号码的情况下，做如下约束：
         1、由于忙碌和DND优先级较高，如果有此两种状态则优先显示，已无异议；
         2、融合规则优先级为空闲>离开，其中有一个硬终端状态有状态A，则融合状态就为该状态A
         */
        if ([self isIPPhoneContainStatus:ECS_SHOW_CHAT]) {
            state = ECS_SHOW_CHAT;
        }
        else if ([self isIPPhoneContainStatus:ECS_SHOW_XA]) {
            state = ECS_SHOW_XA;
        }
        else if ([self isIPPhoneContainStatus:ECS_SHOW_AWAY]){
            state = ECS_SHOW_AWAY;
        }
        else{
            //没有任何号码状态，还是采用推送过来的软状态
            state = softClientStatus;
        }
    }
    return [self statusEnumValueOfStstusString:state];
}

- (void)setUserStatus:(ESpaceUserStatus)userStatus_{
    userStatus = userStatus_;
    switch (userStatus) {
        case ESpaceUserStatusAvailable:{
            self.statusInfo.mainStatus = ECS_SHOW_CHAT;
            break;
        }
        case ESpaceUserStatusBusy:{
            self.statusInfo.mainStatus = ECS_SHOW_DND;
            break;
        }
        case ESpaceUserStatusAway:{
            self.statusInfo.mainStatus = ECS_SHOW_XA;
            break;
        }
        case ESpaceUserStatusUninteruptable:{
            self.statusInfo.mainStatus = ECS_SHOW_UNINTERRUPTABLE;
            break;
        }
        case ESpaceUserStatusOffline:{
            self.statusInfo.mainStatus = ECS_SHOW_AWAY;
            break;
        }
        default:
            self.statusInfo.mainStatus = ECS_SHOW_AWAY;
            break;
    }
}


- (BOOL)isOnline {
    return (self.userStatus == ESpaceUserStatusAvailable
            || self.userStatus == ESpaceUserStatusBusy
            || self.userStatus == ESpaceUserStatusAway
            || self.userStatus == ESpaceUserStatusUninteruptable);
}

- (BOOL)isImAllowed {
    BOOL allow = NO;
    if ([self.bindNumber length] > 0
        ||[self.number1 length] > 0
        ||[self.number2 length] > 0
        ||[self.number3 length] > 0
        ||[self.number4 length] > 0
        ||[self.number5 length] > 0
        ||[self.number6 length] > 0) {
        if ([self.bindNumber length] && nil != self.statusInfo.softClientRight){
            allow = allow|self.statusInfo.softClientRight.imAllowed;
        }
        if ([self.number1 length] && nil != [self.statusInfo.ipphoneRight objectForKey:self.number1]){
            allow = allow|[[self.statusInfo.ipphoneRight objectForKey:self.number1] imAllowed];
        }
        if ([self.number2 length] && nil != [self.statusInfo.ipphoneRight objectForKey:self.number2]){
            allow = allow|[[self.statusInfo.ipphoneRight objectForKey:self.number2] imAllowed];
        }
        if ([self.number3 length] && nil != [self.statusInfo.ipphoneRight objectForKey:self.number3]){
            allow = allow|[[self.statusInfo.ipphoneRight objectForKey:self.number3] imAllowed];
        }
        if ([self.number4 length] && nil != [self.statusInfo.ipphoneRight objectForKey:self.number4]){
            allow = allow|[[self.statusInfo.ipphoneRight objectForKey:self.number4] imAllowed];
        }
        if ([self.number5 length] && nil != [self.statusInfo.ipphoneRight objectForKey:self.number5])
        {
            allow = allow|[[self.statusInfo.ipphoneRight objectForKey:self.number5] imAllowed];
        }
        if ([self.number6 length] && nil != [self.statusInfo.ipphoneRight objectForKey:self.number6]){
            allow = allow|[[self.statusInfo.ipphoneRight objectForKey:self.number6] imAllowed];
        }
    }
    else{
        allow = YES;
    }
    
    return allow;
}

- (BOOL)isPresenceAllowed {
    BOOL allow = NO;
    if ([self.bindNumber length] > 0
        ||[self.number1 length] > 0
        ||[self.number2 length] > 0
        ||[self.number3 length] > 0
        ||[self.number4 length] > 0
        ||[self.number5 length] > 0
        ||[self.number6 length] > 0) {
        if ([self.bindNumber length] && nil != self.statusInfo.softClientRight){
            allow = allow|self.statusInfo.softClientRight.presenceAllowed;
        }
        if ([self.number1 length] && nil != [self.statusInfo.ipphoneRight objectForKey:self.number1]){
            allow = allow|[[self.statusInfo.ipphoneRight objectForKey:self.number1] presenceAllowed];
        }
        if ([self.number2 length] && nil != [self.statusInfo.ipphoneRight objectForKey:self.number2]){
            allow = allow|[[self.statusInfo.ipphoneRight objectForKey:self.number2] presenceAllowed];
        }
        if ([self.number3 length] && nil != [self.statusInfo.ipphoneRight objectForKey:self.number3]){
            allow = allow|[[self.statusInfo.ipphoneRight objectForKey:self.number3] presenceAllowed];
        }
        if ([self.number4 length] && nil != [self.statusInfo.ipphoneRight objectForKey:self.number4]){
            allow = allow|[[self.statusInfo.ipphoneRight objectForKey:self.number4] presenceAllowed];
        }
        if ([self.number5 length] && nil != [self.statusInfo.ipphoneRight objectForKey:self.number5])
        {
            allow = allow|[[self.statusInfo.ipphoneRight objectForKey:self.number5] presenceAllowed];
        }
        if ([self.number6 length] && nil != [self.statusInfo.ipphoneRight objectForKey:self.number6]){
            allow = allow|[[self.statusInfo.ipphoneRight objectForKey:self.number6] presenceAllowed];
        }
    }
    else{
        allow = YES;
    }
    
    return allow;
}

@end

#pragma mark-

@implementation CallNumberItem

- (instancetype)initWithType:(ESpaceCallNumberObjectType)type
                       title:(NSString *)aTitle
                      number:(NSString *)aNumber
                displayTitle:(BOOL)bIsDisplayTitle
              hideLastNumber:(BOOL)bHideLastNumber {
    if (self = [super init]) {
        _numberType = type;
        _title = aTitle;
        _numberValue = aNumber;
        _isDisplayTitle = bIsDisplayTitle;
        _hideLastNumber = bHideLastNumber;
    }
    
    return self;
}

- (NSString *)displayTitle {
    if (_isDisplayTitle) {
        return _title;
    }
    return @" ";
}

- (NSString *)displayNumber {
    if (_numberType == ESpaceCallNumberObjectType_Mobile && _hideLastNumber) {
        return [ECSUtils hideMobileNumber:_numberValue];
    }
    return _numberValue;
}

@end

#pragma mark-

@interface EmployeeEntity() {
    NSString* _nameIndexStr;
}
@end

@implementation EmployeeEntity

@dynamic account;
@dynamic memberOf;
@dynamic ownerOf;
@dynamic topics;
@dynamic circleRelation;
@dynamic circleWatch;
@dynamic circleWatched;
@dynamic circleInvoved;
@dynamic circleInviteUpdateTime;
@dynamic circleBgImageUrl;
@dynamic macthedByLocal;
@dynamic atBy;
@dynamic isBindnoShow;
@dynamic fileOwnerOf;
@dynamic matchPersonOf;

//@synthesize nameIndex = _nameIndex;
@synthesize uiDisplayName = _uiDisplayName;

+(NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
    if ([key isEqualToString:@"uiDisplayName"]) {
        return [NSSet setWithObjects:@"nativeName", @"name", @"nickname", @"remarkName", nil];
    } else {
        return [super keyPathsForValuesAffectingValueForKey:key];
    }
}

//- (NSString *)getUIDisplayName {
//    return [self plainNameShowId:NO];
//}

- (void)setHeadId:(NSString *)headId {
    NSString * primaryHeadId = self.headId;
    [super setHeadId:headId];
    if (headId && ![primaryHeadId isEqualToString:headId]) {
        for (GroupEntity * group in self.memberOf.allObjects) {
            NSString * headImgKey = [group headImageKey];
            if (headImgKey) {
//                [[TUPMediator_ContactService M_validGroupHeadImages] removeObject:headImgKey];
            }
            NSManagedObjectID *newGroupObjID = group.objectID;
            
            NSManagedObjectContext *mainMoc = LOCAL_DATA_MANAGER.managedObjectContext;
            dispatch_async(dispatch_get_main_queue(), ^{
                [mainMoc performBlockAndWait:^{
                    GroupEntity *mainGroup = [mainMoc existingObjectWithID:newGroupObjID error:nil];
                    if (mainGroup && mainGroup.managedObjectContext && !mainGroup.isDeleted) {
                        mainGroup.headId = mainGroup.headId;
                    }
                }];
            });
        }
    }
}

- (NSString *)uiDisplayName {
    [self willAccessValueForKey:@"uiDisplayName"];
    
    BOOL needNickName = [ECSAppConfig sharedInstance].functionConfig.supportContactNickName;
    BOOL needRemarkName = [ECSAppConfig sharedInstance].functionConfig.supportContactRemarkName;
    _uiDisplayName = [self plainNameShowId:NO needNickName:needNickName needRemarkName:needRemarkName];
    
    [self didAccessValueForKey:@"uiDisplayName"];
    
    return _uiDisplayName;
}

- (void)setUiDisplayName:(NSString *)uiDisplayName {
    [self willChangeValueForKey:@"uiDisplayName"];
    _uiDisplayName = uiDisplayName;
    [self didChangeValueForKey:@"uiDisplayName"];
}

-(void)setName:(NSString *)name{
    [self willChangeValueForKey:@"name"];
//    NSString* nameVal = [ECSUtils databaseDataEncrypt:name];
    NSString* nameVal = name;
    [self setPrimitiveValue:nameVal forKey:@"name"];
    [self didChangeValueForKey:@"name"];
    
//    if (0 == [name length]) {
//        self.nameIndex = @"[";
//    }
//    else{
        self.nameIndex = [self.uiDisplayName nameIndex];
//    }
}

- (UIImage*) defaultHeadImage {
    return [[ESpaceContactHeadImageService sharedInstance] defaultEmpolyeeHeadImageWithHeadId:@"0"];
}

+ (NSString*) firstLetter:(NSString*) fname {
    CFRange range = CFRangeMake(0, 1);
    NSMutableString* mutableString = [fname mutableCopy];
    if (!fname) {
        return @"#";
    }
    BOOL bSuccess = CFStringTransform((__bridge CFMutableStringRef)mutableString, &range, kCFStringTransformToLatin, NO);
    if (bSuccess) {
        bSuccess = CFStringTransform((__bridge CFMutableStringRef)mutableString, &range, kCFStringTransformStripCombiningMarks, NO);
        
    }
    NSString* firstLetter = nil;
    if (bSuccess && range.length > 0) {
        NSRange nsRange = NSMakeRange(range.location, 1);
        firstLetter = [[mutableString substringWithRange:nsRange] uppercaseString];
    }
    if (firstLetter && ([firstLetter compare:@"A"] < 0 || [firstLetter compare:@"Z"] > 0)) {
        firstLetter = nil;
    }
    return firstLetter ? firstLetter : @"#";
}

- (NSString *)displayNameNeedNickName:(BOOL)need {
    return [self displayNameNeedNickName:need needRemarkName:NO];
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
    NSString *name = [super displayNameNeedNickName:need needRemarkName:needRemark];
    //再显示espace帐号
    if ([name length] == 0 && 0 < [self.account length]) {
        name = self.account;
    }
    
    return name;
}

- (BOOL)isEqualToContact:(EmployeeEntity *)c
{
    if ([super isEqualToContact:c]) {
        return YES;
    }
    
    if (![c isKindOfClass:self.class]) {
        return NO;
    }
    
    if (self.account.length != 0
        && [self.account compare:c.account] == NSOrderedSame) {
        return YES;
    }
    return NO;
}

@end

@implementation EmployeeInfo

- (NSMutableDictionary *)dirForEmployeeInfo{
    NSMutableDictionary *dic = [NSMutableDictionary new];
    [dic setObject:self.account forKey:@"w3_account"];
    [dic setObject:self.staffNum forKey:@"employee_id"];
    [dic setObject:self.zhName forKey:@"name_zh"];
    [dic setObject:self.enName forKey:@"name_en"];
    [dic setObject:self.pinyinName forKey:@"name_pinyin"];
    [dic setObject:self.pinyinShort forKey:@"pinyin_short"];
    [dic setObject:self.mobilePhone1 forKey:@"mobile_phone1"];
    [dic setObject:self.mobilePhone2 forKey:@"mobile_phone2"];
    [dic setObject:self.mobilePhone3 forKey:@"mobile_phone3"];
    [dic setObject:self.zhMinDept forKey:@"dept_min_zh"];
    [dic setObject:self.zhMaxDept forKey:@"dept_max_zh"];
    [dic setObject:self.enMinDept forKey:@"dept_min_en"];
    [dic setObject:self.enMaxDept forKey:@"dept_max_en"];
    [dic setObject:self.seat forKey:@"work_place"];
    [dic setObject:self.email forKey:@"email"];
    [dic setObject:self.fromSource forKey:@"from_source"];
    [dic setObject:self.seatNum forKey:@"work_room"];
    [dic setObject:self.isAdmin forKey:@"isAdmin"];
    [dic setObject:self.level forKey:@"level"];
    [dic setObject:self.doctor forKey:@"doctor"];
    return dic;
}

- (instancetype)initWithEmployeeEntity:(EmployeeEntity *)entity{
    if (self = [super init]) {
        if (nil != entity) {
            self.account = entity.account;
            self.staffNum = [entity.staffNo length] > 0 ? entity.staffNo : entity.account;
            
            NSString *tempZhName = [entity.nativeName length] > 0 ? entity.nativeName : @"";
            
            
            NSRange rangeZh = [tempZhName rangeOfString:@" " options:NSBackwardsSearch];
            if (rangeZh.location != NSNotFound && rangeZh.location != 0) {
                self.zhName = [tempZhName substringToIndex:rangeZh.location];
            }
            else{
                self.zhName = tempZhName;
            }
            
            NSString *tempEnName = [entity.name length] > 0 ? entity.name : @"";
            NSRange rangeEn = [tempEnName rangeOfString:@" " options:NSBackwardsSearch];
            if (rangeEn.location != NSNotFound && rangeEn.location != 0) {
                self.enName = [tempEnName substringToIndex:rangeEn.location];
            }
            else{
                self.enName = tempEnName;
            }
            
            self.pinyinName = [entity.pinyinName length] > 0 ? entity.pinyinName : @"";
            self.pinyinShort = [entity.simplifiedPinyin length] > 0 ? entity.simplifiedPinyin : @"";
            self.mobilePhone1 = [entity.originMobile length] > 0 ? entity.originMobile : @"";
            self.email = [entity.email length] > 0 ? entity.email : @"";
            self.mobilePhone2 = @"";
            self.mobilePhone3 = @"";
            self.zhMinDept = @"";
            self.enMinDept = @"";
            self.zhMaxDept = @"";
            self.enMaxDept = @"";
            self.seat = @"";
            self.fromSource = @"";
            self.seatNum = @"";
            self.isAdmin = @"";
            self.level = @"";
            self.doctor = @"";
        }
    }
    return self;
}

@end
