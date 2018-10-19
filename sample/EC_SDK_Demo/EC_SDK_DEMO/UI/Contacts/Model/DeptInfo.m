//
//  DeptInfo.m
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

#import "DeptInfo.h"

@implementation DeptInfo

+ (DeptInfo *)deptInfoTransformFrom:(TSDK_S_DEPARTMENT_INFO)deptInfo
{
    DeptInfo *info = [[DeptInfo alloc] init];
    info.deptId       = [NSString stringWithUTF8String:deptInfo.department_id];
    info.parentId     = [NSString stringWithUTF8String:deptInfo.parent_id];
    info.deptName     = [NSString stringWithUTF8String:deptInfo.department_name];
    
    return info;
}

@end
