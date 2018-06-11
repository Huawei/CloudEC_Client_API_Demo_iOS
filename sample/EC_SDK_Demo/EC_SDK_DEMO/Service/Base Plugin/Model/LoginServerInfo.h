//
//  TUPLoginAccessServer.h
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

#import <Foundation/Foundation.h>
//#import "login_def.h"

@interface LoginServerInfo : NSObject

// auth info
@property (nonatomic, copy)NSString *userName;                     // the username
@property (nonatomic, copy)NSString *userNameForThirdParty;        // the real account in third-party authentication
@property (nonatomic, copy)NSString *authServer;                   // the server address
@property (nonatomic, assign)NSUInteger authServerPort;            // the server port
@property (nonatomic, copy)NSString *token;                        // the token value
@property (nonatomic, copy)NSString *sipPwd;                       // the sip password.
@property (nonatomic, assign)NSUInteger passwordType;              // the password type

// access info
@property (nonatomic, copy)NSString *sipDomain;                     // the sip domain name
@property (nonatomic, copy)NSString *serverName;                    // the access server name
@property (nonatomic, copy)NSString *sipUri;                        // the SIP URI
@property (nonatomic, copy)NSString *svnUri;                        // the SVN proxy server address
@property (nonatomic, copy)NSString *httpsproxyUri;                 // the Https proxy server address
@property (nonatomic, copy)NSString *eserverUri;                    // the eServer address
@property (nonatomic, copy)NSString *confUri;                       // the conference uri
@property (nonatomic, copy)NSString *maaUri;                        // the MAA server address
@property (nonatomic, copy)NSString *msParamUri;                    // the MS conference parameter gets the server address
@property (nonatomic, copy)NSString *msParamPathUri;                // the MS conference parameter gets the server path
@property (nonatomic, copy)NSString *eabUri;                        // the enterprise address The server address
@property (nonatomic, copy)NSString *prophotoUri;                   // the avatar server address
@property (nonatomic, copy)NSArray *msUri;                          // the MS conferencing server
@property (nonatomic, copy)NSString *sipAccount;                    // the impi number.


// stg info
@property (nonatomic, copy)NSString *stgAccount;                    // the account. Required for external network access
@property (nonatomic, copy)NSString *stgPwd;                        // the password. Required for external network access
@property (nonatomic, copy)NSString *stgUri;                        // the STG URI. Required for external network access
@property (nonatomic, copy)NSString *sipStgUri;                     // the sip STG URI. Proxy intranet address, required for external network access
@property (nonatomic, copy)NSString *maaStgUri;                     // the internal network MAA address accessed through the STG

//@property (nonatomic, assign) LOGIN_E_DEPLOY_MODE deployMode;       // the deployment mode (uportal会议类型)
@end
