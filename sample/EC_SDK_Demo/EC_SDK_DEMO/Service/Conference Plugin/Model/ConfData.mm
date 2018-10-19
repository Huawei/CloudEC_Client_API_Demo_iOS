//
//  ConfData.m
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

#import "ConfData.h"

@implementation ConfData

/**
 *This method is used to init this class, init value of memberList
 *初始化该类，初始化数组
 
 */
- (instancetype)init
{
    if (self = [super init])
    {
        _memberList = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dealloc
{
    self.memberList = nil;
}

/**
 *This method is used to get conf member by call number
 *获取会议号码根据呼叫号码
 */
- (ConfMember*)getMemberWithNumber:(NSString*)callNumber
{
    for (ConfMember* member in self.memberList)
    {
        if ([member.number isEqualToString:callNumber])
        {
            return member;
        }
    }
    return nil;
}

@end

@implementation ConfMember

/**
 *This method is used to init this class
 *初始化该类
 */
- (instancetype)init
{
    if (self = [super init])
    {
        self.state = AttendeeStateBUTT;
        self.role = ConfRoleBUTT;
        self.speakRight = YES;
    }
    return self;
}

- (void)dealloc
{
    self.number = nil;
}

@end
