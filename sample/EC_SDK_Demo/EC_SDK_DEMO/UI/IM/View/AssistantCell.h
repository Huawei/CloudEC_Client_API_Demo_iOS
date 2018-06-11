//
//  AssistantCell.h
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

#import <UIKit/UIKit.h>
@class AssistantMessageEntity;
@interface AssistantCell : UITableViewCell
@property (nonatomic, strong)AssistantMessageEntity *messageEntity;    // current assistant message entity

@end
