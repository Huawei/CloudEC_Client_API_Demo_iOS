//
//  AddAttendeeViewController.h
//  TUP_Mobile_Conference_Demo
//
//  Created by lwx308413 on 17/1/12.
//  Copyright © 2017年 huawei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TUPService.h"

@interface AddAttendeeViewController : UIViewController
@property (nonatomic ,assign)BOOL isBookConf;// YES: book conference, NO: Immediately create conference
@property (nonatomic ,assign)EC_CONF_MEDIATYPE confMediaType;
@end
