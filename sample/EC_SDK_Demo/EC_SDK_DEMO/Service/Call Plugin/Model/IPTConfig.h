//
//  IPTConfig.h
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

#import <Foundation/Foundation.h>

@interface IPTConfig : NSObject

//dnd has right?
@property (nonatomic, assign)BOOL hasDNDRight;
//unconditional has right?
@property (nonatomic, assign)BOOL hasCFURight;
//onbusy has right?
@property (nonatomic, assign)BOOL hasCFBRight;
//no reply has right?
@property (nonatomic, assign)BOOL hasCFNARight;
//offline has right?
@property (nonatomic, assign)BOOL hasCFNRRight;
//call wait has right?
@property (nonatomic, assign)BOOL hasCWRight;
//don't disturb or not
@property (nonatomic, assign)BOOL isDNDRegister;
//unconditional forward turn or not
@property (nonatomic, assign)BOOL isCFURegister;
//busy forward turn or not
@property (nonatomic, assign)BOOL isCFBRegister;
//no response forward or not
@property (nonatomic, assign)BOOL isCFNARegister;
//offline forward or not
@property (nonatomic, assign)BOOL isCFNRRegister;
//call wait or not
@property (nonatomic, assign)BOOL isCWRegister;

//register not disturb code
@property (nonatomic, strong)NSString *dndActive;
//unregister not disturb code
@property (nonatomic, strong)NSString *dndDeactive;

//register unconditional forward turn code
@property (nonatomic, strong)NSString *cfuActive;
//unregister unconditional forward turn code
@property (nonatomic, strong)NSString *cfuDeactive;
//unconditional forward turn number
@property (nonatomic, strong)NSString *cfuNumber;

//register busy forward turn code
@property (nonatomic, strong)NSString *cfbActive;
//unregister busy forward turn code
@property (nonatomic, strong)NSString *cfbDeactive;
//busy forward turn number
@property (nonatomic, strong)NSString *cfbNumber;

//register no response forward code
@property (nonatomic, strong)NSString *cfnaActive;
//unregister no response forward code
@property (nonatomic, strong)NSString *cfnaDeactive;
//no response forward number
@property (nonatomic, strong)NSString *cfnaNumber;

//register offline forward code
@property (nonatomic, strong)NSString *cfnrActive;
//unregister offline forward code
@property (nonatomic, strong)NSString *cfnrDeactive;
//offline forward number
@property (nonatomic, strong)NSString *cfnrNumber;

//register call wait code
@property (nonatomic, strong)NSString *cwActive;
//unregister call wait code
@property (nonatomic, strong)NSString *cwDeactive;
//call wait number
@property (nonatomic, strong)NSString *cwNumber;

+(instancetype)sharedInstance;

@end
