//
//  CircleComment.h
//
//  Created on 15/6/4.
//  Copyright (c) 2017年 Huawei Tech. Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "MessageEntity.h"

typedef NS_ENUM(NSInteger, CircleCommentType) {
    CircleCommentReply = 0,
    CircleCommentFavor = 1
};

typedef NS_ENUM(NSInteger, CircleCommentStatus) {
    CircleCommentSended = 0,
    CircleCommentSendFailed = 0x10000
};

@interface CircleComment : MessageEntity

@property (nonatomic, retain) NSNumber * commentType;
@property (nonatomic, retain) NSNumber * meInvolved;
@property (nonatomic, retain) NSString * draft;

@end
