//
//  SiteViewTableViewDataSouce.h
//  TUP_Mobile_Conference_Demo
//
//  Created by lwx308413 on 16/8/12.
//  Copyright © 2016年 huawei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface SiteViewTableViewDataSouce : NSObject<UITableViewDataSource>

@property (nonatomic)NSArray *siteListMutArray;
@property (nonatomic, copy) NSString *hostNumber;
@property (nonatomic, copy) NSString *presentNumber;
@end
