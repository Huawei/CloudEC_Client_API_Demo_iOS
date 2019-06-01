//
//  ExtendAppMsgEntity.h
//
//  Created on 5/28/16.
//  Copyright © 2017 Huawei Tech. Co., Ltd. All rights reserved.
//

#import "ChatMessageEntity.h"

@interface ExtendAppMsgEntity : ChatMessageEntity

@property (nonatomic, retain) NSString * chatID;
@property (nonatomic, retain) NSDate * createTime;

@end
