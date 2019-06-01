//
//  GroupFileEntity.h
//
//  Created on 7/31/15.
//  Copyright (c) 2017 Huawei Tech. Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
//#import "ESpaceUMResource.h"

@class GroupEntity, GroupFileEntity, EmployeeEntity;

@interface GroupFileEntity : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * info;
@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) NSNumber * userPriv;//当前用户权限,权限细化前不启用
@property (nonatomic, retain) NSNumber * transferStatus;
@property (nonatomic, retain) NSString * id;
//@property (nonatomic, retain) NSNumber * progress;//断点续传实现前不启用
@property (nonatomic, retain) NSNumber * size;
@property (nonatomic, retain) NSNumber * queuePriority;//下载优先级
@property (nonatomic, retain) NSDate * createAt;
@property (nonatomic, retain) EmployeeEntity * fileOwner;
@property (nonatomic, retain) GroupEntity *ownedByGroup;
@property (nonatomic, retain) GroupFileEntity *parent;
@property (nonatomic, retain) NSSet *membes;
@property (nonatomic, retain) NSNumber * needUpdate;

//@property (nonatomic, retain) ESpaceUMResource* umResource; //transent property

- (void)localDeleteSelf;

@end

@interface GroupFileEntity (CoreDataGeneratedAccessors)

- (void)addMembesObject:(GroupFileEntity *)value;
- (void)removeMembesObject:(GroupFileEntity *)value;
- (void)addMembes:(NSSet *)values;
- (void)removeMembes:(NSSet *)values;

@end
