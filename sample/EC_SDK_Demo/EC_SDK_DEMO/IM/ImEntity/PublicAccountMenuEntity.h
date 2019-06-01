//
//  PublicAccountMenuEntity.h
//
//  Created on 15/7/9.
//  Copyright (c) 2017年 Huawei Tech. Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class PublicAccountEntity;

@interface PublicAccountMenuEntity : NSManagedObject

@property (nonatomic, retain) NSString * cmdContent;
@property (nonatomic, retain) NSNumber * cmdType;
@property (nonatomic, retain) NSString * materialId;
@property (nonatomic, retain) NSNumber * materialType;
@property (nonatomic, retain) NSString * menuId;
@property (nonatomic, retain) NSNumber * menuLevel;
@property (nonatomic, retain) NSString * menuName;
@property (nonatomic, retain) NSNumber * menuOrder;
@property (nonatomic, retain) NSString * parentMenuId;
@property (nonatomic, retain) NSString * publicAccountId;//可以删除
@property (nonatomic, retain) PublicAccountEntity *belongAccount;

@end
