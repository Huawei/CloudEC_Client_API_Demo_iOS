//
//  ParseConfXMLInfo.h
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

#import <Foundation/Foundation.h>
@interface multiConfUCV2 : NSObject
{
    NSString *token;		  //数据会议接入密码
    NSString *confID;         //数据会议资源ID
    NSString *confURL;        //数据会议接入服务器
    NSString *timestamp;	  //数据会议有效介入时间段
    NSString *siteID;		  //数据会议siteid
    NSString *attendeeNum;	  //数据会议入会号码
    NSString *hostRole;		  //数据会议主持人密码
    NSString *cmAddress;      //U1900地址
}
@property (nonatomic, copy)NSString *token;		  //数据会议接入密码
@property (nonatomic, copy)NSString *confID;         //数据会议资源ID
@property (nonatomic, copy)NSString *confURL;        //数据会议接入服务器
@property (nonatomic, copy)NSString *timestamp;	  //数据会议有效介入时间段
@property (nonatomic, copy)NSString *siteID;		  //数据会议siteid
@property (nonatomic, copy)NSString *attendeeNum;	  //数据会议入会号码
@property (nonatomic, copy)NSString *hostRole;		//数据会议主持人密码
@property (nonatomic, copy)NSString *cmAddress;     //U1900地址
@property (nonatomic, copy)NSString *userType;      //用户角色,仅在6.0环境中大参数下发使用
@property (nonatomic, copy)NSString *userM;
@property (nonatomic, copy)NSString *userT;
@property (nonatomic, copy)NSString *sbcServerIP;

@end



@interface ParseConfXMLInfo : NSObject<NSXMLParserDelegate> {
@private
	NSMutableString *currentStringValue;
	multiConfUCV2 *confParm;
}
-(multiConfUCV2*)parseUCV2ConfData:(NSString*)confData;
@end
