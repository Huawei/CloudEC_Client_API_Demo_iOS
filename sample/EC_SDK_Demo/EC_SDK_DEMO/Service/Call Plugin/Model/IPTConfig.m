//
//  IPTConfig.m
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//


#import "IPTConfig.h"

@implementation IPTConfig

+(instancetype)sharedInstance
{
    static IPTConfig *tupIptConfig = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        tupIptConfig = [[IPTConfig alloc] init];
    });
    return tupIptConfig;
}

-(instancetype)init
{
    self = [super init];
    if (self)
    {
        return self;
    }
    return nil;
}

/**
 *This method is used to encode object, this is a part of kvc, after that the instance of this class can be saved to local
 *将该类对象按key编码，这是kvc机制，通过这种方式可将该类实序列化储存
 */
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.cfuNumber forKey:@"cfuNumber"];
    [aCoder encodeObject:self.cfbNumber forKey:@"cfbNumber"];
    [aCoder encodeObject:self.cfnaNumber forKey:@"cfnaNumber"];
    [aCoder encodeObject:self.cfnrNumber forKey:@"cfnrNumber"];
    
    [aCoder encodeObject:[NSNumber numberWithBool:self.hasDNDRight] forKey:@"hasDNDRight"];
    [aCoder encodeObject:[NSNumber numberWithBool:self.isDNDRegister] forKey:@"isDNDRegister"];
    [aCoder encodeObject:[NSNumber numberWithBool:self.hasCWRight] forKey:@"hasCWRight"];
    [aCoder encodeObject:[NSNumber numberWithBool:self.isCWRegister] forKey:@"isCWRegister"];
    [aCoder encodeObject:[NSNumber numberWithBool:self.hasCFURight] forKey:@"hasCFURight"];
    [aCoder encodeObject:[NSNumber numberWithBool:self.isCFURegister] forKey:@"isCFURegister"];
    [aCoder encodeObject:[NSNumber numberWithBool:self.hasCFBRight] forKey:@"hasCFBRight"];
    [aCoder encodeObject:[NSNumber numberWithBool:self.isCFBRegister] forKey:@"isCFBRegister"];
    [aCoder encodeObject:[NSNumber numberWithBool:self.hasCFNARight] forKey:@"hasCFNARight"];
    [aCoder encodeObject:[NSNumber numberWithBool:self.isCFNARegister] forKey:@"isCFNARegister"];
    [aCoder encodeObject:[NSNumber numberWithBool:self.hasCFNRRight] forKey:@"hasCFNRRight"];
    [aCoder encodeObject:[NSNumber numberWithBool:self.isCFNRRegister] forKey:@"isCFNRRegister"];
}

/**
 *This method is used to encode object, this is a part of kvc, after that the instance of this class can be saved to local
 *将该类对象按key编码，这是kvc机制，通过这种方式可将该类实序列化储存
 */
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self)
    {
        self.cfuNumber = [aDecoder decodeObjectForKey:@"cfuNumber"];
        self.cfbNumber = [aDecoder decodeObjectForKey:@"cfbNumber"];
        self.cfnaNumber = [aDecoder decodeObjectForKey:@"cfnaNumber"];
        self.cfnrNumber = [aDecoder decodeObjectForKey:@"cfnrNumber"];
        
        self.hasDNDRight = [[aDecoder decodeObjectForKey:@"hasDNDRight"] boolValue];
        self.isDNDRegister = [[aDecoder decodeObjectForKey:@"isDNDRegister"] boolValue];
        self.hasCWRight = [[aDecoder decodeObjectForKey:@"hasCWRight"] boolValue];
        self.isCWRegister = [[aDecoder decodeObjectForKey:@"isCWRegister"] boolValue];
        self.hasCFURight = [[aDecoder decodeObjectForKey:@"hasCFURight"] boolValue];
        self.isCFURegister = [[aDecoder decodeObjectForKey:@"isCFURegister"] boolValue];
        self.hasCFBRight = [[aDecoder decodeObjectForKey:@"hasCFBRight"] boolValue];
        self.isCFBRegister = [[aDecoder decodeObjectForKey:@"isCFBRegister"] boolValue];
        self.hasCFNARight = [[aDecoder decodeObjectForKey:@"hasCFNARight"] boolValue];
        self.isCFNARegister = [[aDecoder decodeObjectForKey:@"isCFNARegister"] boolValue];
        self.hasCFNRRight = [[aDecoder decodeObjectForKey:@"hasCFNRRight"] boolValue];
        self.isCFNRRegister = [[aDecoder decodeObjectForKey:@"isCFNRRegister"] boolValue];
        
        
    }
    return self;
}

@end
