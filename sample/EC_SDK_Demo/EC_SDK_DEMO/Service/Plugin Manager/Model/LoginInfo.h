//
//  LoginInfo.h
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

#import <Foundation/Foundation.h>

@interface LoginInfo : NSObject
@property(nonatomic, copy)NSString* account; //鉴权登陆账号
@property(nonatomic, copy)NSString* password; //鉴权密码
@property(nonatomic, copy)NSString* regServerAddress; //注册服务器
@property(nonatomic, copy)NSString* regServerPort; //端口
@property(nonatomic, copy)NSString* authToken; //鉴权凭证
@property (nonatomic,copy)NSString *msParam; //鉴权结果返回的数据会议服务器
@property (nonatomic,copy) NSString *eServerIp;
@property (nonatomic,copy) NSString *eServerPort;

@end
