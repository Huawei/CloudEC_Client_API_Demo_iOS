//
//  ESpaceContactNotification.h
//  eSpaceContactSDK
//
//  Created by admin on 2017/1/16.
//  Copyright © 2017年 uc.huawei.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#ifdef __cplusplus
#define ECS_EXTERN		extern "C"
#else
#define ECS_EXTERN		extern
#endif


//获取群组后通知,包括创建群组
ECS_EXTERN NSString * const ECSGroupAddedNotify;

//更新群组后通知
ECS_EXTERN NSString * const ECSGroupUpdatedNotify;

//删除群组后通知
ECS_EXTERN NSString * const ECSGroupRemovedNofity;

/*
 收到通知后基础解析方法
 NSData *data = notification.object;
 NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
 
 //获取对应群组信息，value:NSArray   NSDictionary in Array
 //NSDictionary in Array
 {
 "room_name" : "",
 "room_icon" : "",
 "room_member_count" : "",
 "room_id" : "",
 "room_member" : [
 {
 "email" : "",
 "from_source" : "",
 "dept_min_en" : "",
 "pinyin_short" : "",
 "w3_account" : "",
 "mobile_phone1" : "",
 "name_zh" : "",
 "dept_max_zh" : "",
 "mobile_phone2" : "",
 "employee_id" : "",
 "dept_max_en" : "",
 "work_place" : "",
 "mobile_phone3" : "",
 "name_pinyin" : "",
 "name_en" : "",
 "dept_min_zh" : ""
 },
 {
 "email" : "",
 "from_source" : "",
 "dept_min_en" : "",
 "pinyin_short" : "",
 "w3_account" : "",
 "mobile_phone1" : "",
 "name_zh" : "",
 "dept_max_zh" : "",
 "mobile_phone2" : "",
 "employee_id" : "",
 "dept_max_en" : "",
 "work_place" : "",
 "mobile_phone3" : "",
 "name_pinyin" : "",
 "name_en" : "",
 "dept_min_zh" : ""
 },
 ]
 },
 
 */
