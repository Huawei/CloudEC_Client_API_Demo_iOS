//
//  TransferView.h
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

#import <UIKit/UIKit.h>


@interface TransferView : UIView
@property (weak, nonatomic) IBOutlet UITextField *numberTextField;

+(instancetype)shareInstanced;

-(void)showTransferView:(UIView *)inSuperView oKBlock:(void (^)(NSString *number))okBlock;

@end
