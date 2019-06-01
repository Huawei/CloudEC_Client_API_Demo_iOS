//
//  BulletinEntity.h
//
//  Created on 15/8/17.
//  Copyright (c) 2017年 Huawei Tech. Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface BulletinEntity : NSManagedObject

@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSDate * timestamp;
@property (nonatomic, retain) NSString * desc;
@property (nonatomic, retain) NSString * body;
@property (nonatomic, retain) NSNumber * readed;

@end
