//
//  PreviewPersonHeadHDImageController.m
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

#import "PreviewPersonHeadHDImageController.h"
#import "HeadImageView.h"
#import "EmployeeEntity.h"

@interface PreviewPersonHeadHDImageController ()
@property (weak, nonatomic) IBOutlet HeadImageView *hdHeadImgV;             // HD head image view
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activity;     // activity view
@property (nonatomic, strong) EmployeeEntity *employee;                     // current employee
@end

@implementation PreviewPersonHeadHDImageController

- (IBAction)back:(id)sender {
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (instancetype)initWithEmployee:(EmployeeEntity *)employee
{
    self = [super init];
    if (self) {
        _employee = employee;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.hdHeadImgV setContactEntity:self.employee];
    
    [self.activity startAnimating];
//    [self.employee loadHDHeadImage:^(UIImage *imageData, NSError *error) {
//
//        dispatch_async(dispatch_get_main_queue(), ^{
//            if (!error) {
//                self.hdHeadImgV.image = imageData;
//            }
//            [self.activity stopAnimating];
//            self.activity.hidden = YES;
//        });
//    }];
    
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.hdHeadImgV.center = self.view.center;
    self.hdHeadImgV.bounds = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.width);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
