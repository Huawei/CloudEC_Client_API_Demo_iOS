//
//  PreviewFileViewController.m
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

#import "PreviewFileViewController.h"

@interface PreviewFileViewController ()<UIWebViewDelegate>

@property (nonatomic, copy) NSString *localFilePath;                         // kocal file path
@property (weak, nonatomic) IBOutlet UIWebView *webView;                     // webView
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityView;  // activity view

@end

@implementation PreviewFileViewController

- (instancetype)initWithFileLocalPath:(NSString *)localFilePath {
    self = [super init];
    if (self) {
        _localFilePath = localFilePath;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"Preview File";
    [self.activityView startAnimating];
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:_localFilePath]]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    self.activityView.hidden = YES;
    [self.activityView stopAnimating];
}

@end
