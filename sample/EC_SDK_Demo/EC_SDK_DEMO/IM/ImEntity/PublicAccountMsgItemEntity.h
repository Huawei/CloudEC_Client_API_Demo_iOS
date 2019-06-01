//
//  PublicAccountMsgItemEntity.h
//
//  Created on 15/7/27.
//  Copyright (c) 2017年 Huawei Tech. Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class PublicAccountMsgEntity;

@interface PublicAccountMsgItemEntity : NSManagedObject

@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * digest;
@property (nonatomic, retain) NSString * contentURL;
@property (nonatomic, retain) NSNumber * order;
@property (nonatomic, retain) NSString * author;
@property (nonatomic, retain) NSString * umLocalURL;
@property (nonatomic, retain) NSString * umRemoteURL;
@property (nonatomic, retain) NSString * sourceURL;
@property (nonatomic, retain) PublicAccountMsgEntity *belongPublicAccountMsg;

@end
