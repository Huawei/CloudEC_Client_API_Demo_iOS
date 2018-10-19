//
//  TransferView.m
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

#import "TransferView.h"

typedef void(^TransferButtonBlock)(NSString *number);
@interface TransferView()
@property (nonatomic ,copy) NSString *currentNumber;
@property (nonatomic, copy)TransferButtonBlock transferBlock;
@end

@implementation TransferView

+(instancetype)shareInstanced
{
    static TransferView *_transferView = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _transferView = [[TransferView alloc] init];
    });
    return _transferView;
}

-(instancetype)init
{
    self = [super init];
    if (self) {
        NSArray *xibArray = [[NSBundle mainBundle] loadNibNamed:@"TransferView" owner:self options:nil];
        self = [xibArray firstObject];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(numberTextFieldChangeNotify:) name:UITextFieldTextDidChangeNotification object:nil];
        return self;
    }
    return nil;
}

-(void)showTransferView:(UIView *)inSuperView oKBlock:(void (^)(NSString *number))okBlock
{
    self.center = CGPointMake(inSuperView.frame.size.width/2, inSuperView.frame.size.height/2);
    self.bounds = CGRectMake(0, 0, 320, 160);
    [inSuperView addSubview:self];
    _transferBlock = okBlock;
}

- (IBAction)onOkButtonPress:(id)sender
{
    _transferBlock(_currentNumber);
    _currentNumber = @"";
    _numberTextField.text = @"";
    [self removeFromSuperview];
}

- (IBAction)onCancelButtonPress:(id)sender
{
    [self removeFromSuperview];
}

-(void)numberTextFieldChangeNotify:(NSNotification *)notify
{
    UITextField *tempTextFiled = [notify object];
    _currentNumber = tempTextFiled.text;
}

-(void)dealloc
{
    _transferBlock = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
