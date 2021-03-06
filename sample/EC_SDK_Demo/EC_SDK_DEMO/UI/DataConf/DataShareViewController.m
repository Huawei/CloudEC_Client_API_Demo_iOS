//
//  DataShareViewController.m
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

#import "EAGLView.h"
#import "ManagerService.h"
#import "ChatMsg.h"
#import "DataShareViewController.h"
#import "VideoShareViewController.h"
#import "ConfChatViewController.h"
#include "ConfBaseInfo.h"
#import "ConfListViewController.h"
#import "CommonUtils.h"

#import "ECMarkupView.h"
#import "ECMarkupToolboxView.h"
#import "ECMarkupToolboxPopoverView.h"

#import "CallStatisticInfo.h"
#import "SignalDataScrollView.h"

#import "StatisticShowInfo.h"
#import "ImageViewBtn.h"

#define MAXSCALE 4.0
#define MINSCALE 1.0

#define CLM_SDK 1

#define GO_TO_VIDEO_SHARE_BTN_H_DIS_TO_RIGHT 5
#define GO_TO_VIDEO_SHARE_BTN_HEIGHT 28
#define GO_TO_VIDEO_SHARE_BTN_WIDTH 28

#define CONFOPERATION_VIEW_REAL_HEIGHT_LANDSCAPE 66        //实际高度(底部操作按钮视图,横屏)
#define CONFREMIND_LABLE_WIDTH 203 //滑动提示框的宽
#define CONFREMIND_LABLE_HEIGHT 20 //滑动提示框的高
#define CONFREMIND_LABLE_DISTANECE 20 //提示框距离底部视图的距离
#define CONFRENIND_LABLE_TEXTFOUNT 11.0 //提示框字体大小
#define CONFREMIND_HANDLE_DISTANCE 40 //提示图片到两边的距离
#define CONFPAGECTRL_DISTANCE  58// 页码提示到顶部的距离

#define SCREEN_SIZE [UIScreen mainScreen].bounds.size
#define kMainScreenWidth   ([UIScreen mainScreen].bounds.size.width)

#define ANNOTATION_COLOR_BLACK 0x333333FF
#define ANNOTATION_COLOR_RED 0xF34B4BFF
#define ANNOTATION_COLOR_GREEN 0x6ECE7EFF
#define ANNOTATION_COLOR_BLUE 0x0D94FFFF

#define SCREENHEIGHT    [UIScreen mainScreen].bounds.size.height
#define SCREENWIDTH    [UIScreen mainScreen].bounds.size.width
#define FINAL_WIDTH  ((SCREENHEIGHT > SCREENWIDTH)? SCREENWIDTH : SCREENHEIGHT)
#define FINAL_HEIGHT  ((SCREENHEIGHT > SCREENWIDTH)? SCREENHEIGHT : SCREENWIDTH)
#define FINALSVC_WIDTH  ((SCREENHEIGHT > SCREENWIDTH)? SCREENHEIGHT : SCREENWIDTH)
#define FINALSVC_HEIGHT  ((SCREENHEIGHT > SCREENWIDTH)? SCREENWIDTH : SCREENHEIGHT)

#define UIColorFromHexR(s,r) [UIColor colorWithRed:(((s & 0xFF0000) >> 16))/255.0 green:(((s & 0xFF00) >> 8))/255.0 blue:((s & 0xFF))/255.0  alpha:r]

@interface DataShareViewController ()<UIScrollViewDelegate, ConferenceServiceDelegate, ECMarkupToolboxViewDelegate, ECMarkupToolboxPopoverViewDelegate, ECMarkupViewDelegate>

@property (nonatomic,strong) UIImageView * shareImageView;
@property (nonatomic,strong) UIButton* videoShareBtn;
@property (nonatomic,strong) UIButton* chatBtn;
@property (nonatomic,strong) UIImageView *videoShareImageView;
@property (nonatomic,strong) UIScrollView *zoomViewImageShare;
@property (nonatomic, strong)UIView *defaultView;

@property (nonatomic, assign) BOOL shouldHasAnno;
@property (nonatomic, strong) UIButton *drawButton;

@property (nonatomic, strong) ECMarkupView *markupView;
@property (nonatomic, strong) ECMarkupToolboxView *toolboxView;
@property (nonatomic, strong) ECMarkupToolboxPopoverView *popoverView;
@property (nonatomic, assign, getter=isInMarkupMode) BOOL inMarkupMode;
@property (nonatomic, assign) BOOL isMarkup;
@property (nonatomic,assign) CGFloat scale;

@property (nonatomic, assign) VideoZoomingViewMarkupColor markupColor;
@property (nonatomic, assign) CGPoint eraserSegmentStartPoint;
@property (nonatomic, assign) CGPoint annotationStartPoint;

@property (nonatomic, strong) UIImage *dataImage;   //数据图片数据
@property (nonatomic, assign) CGFloat dataWidth;    //数据传入的宽度
@property (nonatomic, assign) CGFloat dataSVCWidth;    //数据传入的宽度



@end

@implementation DataShareViewController
{
    UIEdgeInsets screenPadding;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.shouldHasAnno = NO;
        self.markupColor = VideoZoomingViewMarkupColorRed;
        _inMarkupMode = NO;
        _eraserSegmentStartPoint = CGPointZero;
        _annotationStartPoint = CGPointZero;
        self.dataWidth = 0;
        self.dataSVCWidth = 0;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleReceiveScreenShareAction:)
                                                     name:RECEIVE_SCREEN_SHARE_DATA_NOTIFY
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleShouldHasAnnotation:)
                                                     name:NTF_MULTI_MEDIA_CONF_SHOULD_HAS_ANNO
                                                   object:nil];
        
    }
    return self;
}

-(void)ecConferenceEventCallback:(EC_CONF_E_TYPE)ecConfEvent result:(NSDictionary *)resultDictionary {
    
    switch (ecConfEvent)
    {
        case DATA_CONF_AS_ON_SCREEN_DATA:
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                DDLogInfo(@"UILOG: DATACONF_RECEIVE_SHARE_DATA");
                NSData *shareImage = resultDictionary[DATACONF_SHARE_DATA_KEY];
                UIImage *image = [[UIImage alloc] initWithData:shareImage];
                if (image == nil)
                {
                    DDLogInfo(@"share image from data fail!");
                    return;
                }

                [self showShareView:image];
                [self calculateDataViewFrameWith:shareImage];
            });
            break;
        }
        case DATACONF_SHARE_SCREEN_DATA_STOP:
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                DDLogInfo(@"UILOG: DATACONF_SHARE_SCREEN_DATA_STOP");
                [self removeShareView];
            });
            break;
        }
        default:
            break;
    }
}


-(void)showShareView:(UIImage *)shareImage {
    self.defaultView.hidden = YES;
    self.shareImageView.image = shareImage;
    
}

- (void)removeShareView {
    if ([ManagerService confService].isStartScreenSharing) {
        return;
    }
    self.defaultView.hidden = NO;
    self.shareImageView.image = nil;
    
    if(_toolboxView) {
        [self.popoverView removeFromSuperview];
        self.popoverView = nil;
        [self.toolboxView removeFromSuperview];
    }
    _drawButton.hidden = YES;
    self.zoomViewImageShare.pinchGestureRecognizer.enabled = NO;
    self.zoomViewImageShare.panGestureRecognizer.enabled = NO;
    self.baseTap.enabled = YES;
    self.barView.hidden = NO;
    self.bottomView.hidden = NO;
    [self.zoomViewImageShare setScrollEnabled:NO];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [ManagerService confService].delegate = self;
    [self updateShareImageData:[ManagerService confService].lastConfSharedData];
    [self updateDrawBtnStatus];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.defaultView = [self configDefaultTipViewWithImageName:@"shared_data_default" andTitle:@"Data sharing has not started."];
    [self.view addSubview:self.defaultView];
    
    [self.view addSubview:self.zoomViewImageShare];
    
//    UIView* contentView = self.zoomViewImageShare;
//    UIView* bottomView = self.bottomView;
//    id<UILayoutSupport> top    = self.topLayoutGuide;
//    id<UILayoutSupport> bottom = self.bottomLayoutGuide;
//    NSDictionary* views = NSDictionaryOfVariableBindings(contentView,bottomView, top, bottom);
//    NSArray* contentViewVconstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[top]-0-[contentView]-0-[bottom]"
//                                                                               options:0
//                                                                               metrics:nil
//                                                                                 views:views];
//
//    NSArray* contentViewHconstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[contentView]|"
//                                                                               options:0
//                                                                               metrics:nil
//                                                                                 views:views];
//
//    [self.view addConstraints:contentViewVconstraints];
//    [self.view addConstraints:contentViewHconstraints];
    
    [self.view bringSubviewToFront:self.bottomView];
    [self.view bringSubviewToFront:self.barView];
    
    if ([self isNeedAddVideoBtn]) {
        [self.barView addSubview:self.videoShareBtn];
    }
    
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *backImg = [UIImage imageNamed:@"dataconf_back"];
    [backBtn setImage:backImg forState:UIControlStateNormal];
    [backBtn setImage:[UIImage imageNamed:@"dataconf_back_highlight"] forState:UIControlStateHighlighted];
    
    backBtn.frame = CGRectMake(0, 12, 40, 40);
    [backBtn addTarget:self action:@selector(gotoVideoShareViewControllerBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.barView addSubview:backBtn];
    
    [self.view addSubview:self.signalBackView];
    [self.view addSubview:self.signalBtn];
    
    [self.barView addSubview:self.chatBtn];
    
    [self configBottomViewBtns];
    if (@available(iOS 11, *)) {
        screenPadding = [UIApplication sharedApplication].keyWindow.safeAreaInsets;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(quitToListViewCtrl) name:CONF_QUITE_TO_CONFLISTVIEW object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    
}

- (void)quitToListViewCtrl
{
    
    UIViewController *list = nil;
    for (UIViewController *vc in self.navigationController.viewControllers) {
        if ([vc isKindOfClass:[ConfListViewController class]]) {
            list = vc;
            break;
        }
    }
    
    if (list) {
        [self.navigationController popToViewController:list animated:YES];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (BOOL)isNeedAddVideoBtn {
    
    EC_CONF_MEDIATYPE confType = [ManagerService confService].currentConfBaseInfo.media_type;
    BOOL isVideoConf = (confType == CONF_MEDIATYPE_VIDEO_DATA);
    BOOL isVideoDataConf = (confType == CONF_MEDIATYPE_VIDEO_DATA);
    return isVideoConf || isVideoDataConf;
}

- (void)deviceOrientationDidChange
{
    [self configBottomViewBtns];
}

- (void)configBottomViewBtns {
    
    CGFloat width = 0;
    CGFloat hight = 0;
    
    width = SCREEN_HIGHT;
    hight = SCREEN_WIDTH;
    
    UIInterfaceOrientation interface2 = [UIApplication sharedApplication].statusBarOrientation;
    
    if (interface2 == UIInterfaceOrientationPortrait) {
        width = SCREEN_WIDTH;
        hight = SCREEN_HIGHT;
        self.signalBackView.frame = CGRectMake(0, 0, 365, 365);
        self.signalDataScrollView.frame = CGRectMake(0, 0, 365, 365);
        self.zoomViewImageShare.frame = CGRectMake(0.0, 0.0, width, hight);
         
    }
    else if (interface2 == UIInterfaceOrientationLandscapeLeft || interface2 == UIInterfaceOrientationLandscapeRight)
    {
        self.signalBackView.frame = CGRectMake(0, 0, 365+200, 365);
        self.signalDataScrollView.frame = CGRectMake(0, 0, 365+200, 365);
        self.zoomViewImageShare.frame = CGRectMake(0.0, 0.0, width, hight);
        
    }
    
    CGFloat x = width - GO_TO_VIDEO_SHARE_BTN_H_DIS_TO_RIGHT - GO_TO_VIDEO_SHARE_BTN_WIDTH;
    CGFloat tempBarHeight = self.barView.bounds.size.height == 0 ? 64 : self.barView.bounds.size.height;
    CGFloat y = (tempBarHeight-GO_TO_VIDEO_SHARE_BTN_HEIGHT)/2;
    _videoShareBtn.frame = CGRectMake(x, y, GO_TO_VIDEO_SHARE_BTN_WIDTH, GO_TO_VIDEO_SHARE_BTN_HEIGHT);
    
    CGFloat chatX = x - 54;
    CGFloat chatY = (tempBarHeight-44)/2;
    [_chatBtn setFrame:CGRectMake(chatX, chatY, 44, 44)];
    
    self.signalBackView.center = CGPointMake(width/2, hight/2);
    self.signalBtn.frame = CGRectMake(width - 50, 60, 30, 30);
    self.defaultView.center = self.view.center;
    _drawButton.frame = CGRectMake(10, hight / 2, 50, 50);
    _toolboxView.frame = [self toolboxViewFrame];
    
    
    _zoomViewImageShare.zoomScale = 1.0;
    NSData *imgData = [ManagerService confService].lastConfSharedData;
    [self calculateDataViewFrameWith:imgData];
    
    self.voiceBtn.frame = CGRectMake(width/2-50, 0, 100, 71);
    self.endBtn.frame = CGRectMake(20, 0, 100, 71);
    self.muteBtn.frame = CGRectMake(width - 120, 0, 100, 71);
    [self.bottomView addSubview:self.voiceBtn];
    [self.bottomView addSubview:self.endBtn];
    [self.bottomView addSubview:self.muteBtn];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIView *)configDefaultTipViewWithImageName:(NSString *)name andTitle:(NSString *)title {
    UIView * defaultTipView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, [self selfViewWidth], [self selfViewHeight])];
    defaultTipView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    defaultTipView.backgroundColor = [UIColor clearColor];
    defaultTipView.translatesAutoresizingMaskIntoConstraints = NO;
    
    CGFloat margin = 10.0f;
    CGFloat tipSize = 20.0f;
    
    UIImageView *defaultImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:name]];
    defaultImg.center = CGPointMake(defaultTipView.center.x, defaultTipView.center.y - margin) ;
    defaultImg.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    [defaultTipView addSubview:defaultImg];
    
    UILabel *defaultTip = [[UILabel alloc] initWithFrame:CGRectMake(-(defaultTipView.frame.size.width - defaultImg.frame.size.width)/2,
                                                                    defaultImg.frame.size.height+margin,
                                                                    defaultTipView.frame.size.width,
                                                                    tipSize)];
    
    defaultTip.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
    defaultTip.font = [UIFont systemFontOfSize:tipSize];
    defaultTip.textAlignment = NSTextAlignmentCenter;
    defaultTip.text = title;
    defaultTip.textColor = [UIColor lightGrayColor];
    defaultImg.clipsToBounds = NO;
    [defaultImg addSubview:defaultTip];
    
    return defaultTipView;
}

- (UIScrollView *)zoomViewImageShare {
    if (nil == _zoomViewImageShare) {
        _shareImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, [self selfViewWidth], [self selfViewHeight])];
        _shareImageView.contentMode = UIViewContentModeScaleAspectFit;
        _shareImageView.userInteractionEnabled = YES;
        _shareImageView.backgroundColor = [UIColor clearColor];
        
        
        
        _zoomViewImageShare = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, 0.0, [self selfViewWidth], [self selfViewHeight])];
        _zoomViewImageShare.minimumZoomScale = 1;
        _zoomViewImageShare.maximumZoomScale = 4;
        _zoomViewImageShare.bouncesZoom = YES;

        _zoomViewImageShare.pinchGestureRecognizer.enabled = NO;
        _zoomViewImageShare.panGestureRecognizer.enabled = NO;
        [_zoomViewImageShare setScrollEnabled:NO];
        [_zoomViewImageShare addSubview:_shareImageView];
        [_zoomViewImageShare addSubview:self.markupView];
        _zoomViewImageShare.delegate = self;
        _zoomViewImageShare.showsHorizontalScrollIndicator = NO;
        _zoomViewImageShare.showsVerticalScrollIndicator = NO;
        
    }
    return _zoomViewImageShare;
}

- (UIButton *)videoShareBtn {
    if (nil == _videoShareBtn) {
        _videoShareImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"enter_videoshare"]
                                                 highlightedImage:[UIImage imageNamed:@"enter_videoshare_highlight"]];
        _videoShareImageView.animationImages = @[[UIImage imageNamed:@"enter_videoshare"],[UIImage imageNamed:@"enter_videoshare1"],
                                                 [UIImage imageNamed:@"enter_videoshare2"],[UIImage imageNamed:@"enter_videoshare3"]];
        _videoShareImageView.animationDuration = 2;
        
        
        CGFloat x = [self selfViewWidth] - GO_TO_VIDEO_SHARE_BTN_H_DIS_TO_RIGHT - GO_TO_VIDEO_SHARE_BTN_WIDTH;
        CGFloat tempBarHeight = self.barView.bounds.size.height == 0 ? 64 : self.barView.bounds.size.height;
        CGFloat y = (tempBarHeight-GO_TO_VIDEO_SHARE_BTN_HEIGHT)/2;
        _videoShareBtn = [[UIButton alloc]initWithFrame:CGRectMake(x,
                                                                   y,
                                                                   GO_TO_VIDEO_SHARE_BTN_WIDTH,
                                                                   GO_TO_VIDEO_SHARE_BTN_HEIGHT)];
        [_videoShareBtn addTarget:self
                           action:@selector(gotoVideoShareViewControllerBtnClicked:)
                 forControlEvents:UIControlEventTouchUpInside];
        [_videoShareBtn addSubview:_videoShareImageView];
    }
    return _videoShareBtn;
}

- (UIButton *)chatBtn {
    if (nil == _chatBtn) {
        _chatBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        CGFloat tempBarHeight = self.barView.bounds.size.height == 0 ? 64 : self.barView.bounds.size.height;
        CGFloat x = [self selfViewWidth] - GO_TO_VIDEO_SHARE_BTN_H_DIS_TO_RIGHT - GO_TO_VIDEO_SHARE_BTN_WIDTH - 54;
        CGFloat y = (tempBarHeight-44)/2;
        [_chatBtn setFrame:CGRectMake(x, y, 44, 44)];
        [_chatBtn addTarget:self action:@selector(showChatView) forControlEvents:UIControlEventTouchUpInside];
        [_chatBtn setImage:[UIImage imageNamed:@"calldetail_chatbutton"] forState:UIControlStateNormal];
    }
    return _chatBtn;
}

- (void)gotoVideoShareViewControllerBtnClicked:(id)sender
{
    NSMutableArray *ary = [NSMutableArray arrayWithArray:[self.navigationController viewControllers]];
    if ([ary containsObject:self]) {
        [ary removeObject:self];
    }
    VideoShareViewController *videoShareCtrl = [[VideoShareViewController alloc] init];
    videoShareCtrl.hidesBottomBarWhenPushed = YES;
    [ary addObject:videoShareCtrl];
    
    [self.navigationController setViewControllers:ary animated:NO];
}

- (void)showChatView
{
    ConfChatViewController *chatCtrl = [[ConfChatViewController alloc] initWithNibName:@"ConfChatViewController" bundle:nil];
    chatCtrl.confAttendees = [ManagerService confService].haveJoinAttendeeArray;
    chatCtrl.selfInfo = self.selfConfInfo;
    [self.navigationController pushViewController:chatCtrl animated:YES];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)updateShareImageData:(NSData *)imgData
{
    if (imgData == nil) {
        [self removeShareView];
    }else{
        UIImage *image = [[UIImage alloc] initWithData:imgData];
        [self showShareView:image];
    }
}
- (UIImage *)imageCustomNamed:(NSString *)name {
#ifdef CLM_SDK
    if(!name)
    {
        return nil;
    }
    NSBundle *bundle = [NSBundle bundleWithPath:@"/Frameworks/CloudLink_Meeting.framework"];
    return [UIImage imageNamed:name inBundle:bundle compatibleWithTraitCollection:nil];
#else
    return [UIImage imageNamed:name];
#endif
    
}

- (void)handleShouldHasAnnotation:(NSNotification *)notification {
    BOOL annotationMode = [notification.userInfo[@"annotationMode"] boolValue];
    DDLogInfo(@"handleShouldHasAnnotation,annotationMode:%d",annotationMode);
    [self updateDrawBtnStatus];
}

- (void)updateDrawBtnStatus
{
    BOOL isBeginAnnotation = [ManagerService confService].isBeginAnnotation;
    if ([ManagerService confService].isStartScreenSharing) {
        self.zoomViewImageShare.pinchGestureRecognizer.enabled = YES;
        self.zoomViewImageShare.panGestureRecognizer.enabled = YES;
        [self.zoomViewImageShare setScrollEnabled:YES];
    }else{
        self.zoomViewImageShare.pinchGestureRecognizer.enabled = NO;
        self.zoomViewImageShare.panGestureRecognizer.enabled = NO;
        [self.zoomViewImageShare setScrollEnabled:NO];
    }
    
    if (self.shouldHasAnno != isBeginAnnotation) {
        self.shouldHasAnno = isBeginAnnotation;
        
        if (self.isInMarkupMode) {
            self.inMarkupMode = NO;
            //            self.tapGestureRecognizer.enabled = YES;
            //            [self.pageFlowView setScrollEnable:YES];
        }
        
        if (_zoomViewImageShare) {
            if (self.shouldHasAnno) {
                if (_drawButton == nil) {
                    [self.zoomViewImageShare.superview addSubview:self.drawButton];
                }
                _drawButton.hidden = NO;
                _toolboxView.hidden = YES;
                
            }else{
                _popoverView.hidden = YES;
                _toolboxView.hidden = YES;
                _drawButton.hidden = YES;

                self.baseTap.enabled = YES;
                self.barView.hidden = NO;
                self.bottomView.hidden = NO;
            }
        }
    }
}


- (CGRect)toolboxViewFrame {
    CGRect toolboxViewFrame;
    CGSize superVSize = SCREEN_SIZE;
    //    if (self.superview) {
    //        superVSize = self.superview.frame.size;
    //    }
    CGFloat toolboxViewWith=superVSize.width>superVSize.height? superVSize.height:superVSize.width;
    CGFloat scale=toolboxViewWith/375;
    _scale=scale;
    toolboxViewWith=scale*375;
    CGFloat toolboxViewHeight=scale*48;
    if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
        toolboxViewFrame = CGRectMake((superVSize.width-toolboxViewWith)/2,
                                      superVSize.height - toolboxViewHeight - 30,
                                      toolboxViewWith,
                                      toolboxViewHeight);
    } else {
        toolboxViewFrame = CGRectMake((superVSize.width-toolboxViewWith)/2, superVSize.height - toolboxViewHeight-30, toolboxViewWith, toolboxViewHeight);
    }
    
    return toolboxViewFrame;
}

- (void)setInMarkupMode:(BOOL)inMarkupMode {
    self.markupView.userInteractionEnabled = inMarkupMode;
    self.zoomViewImageShare.delaysContentTouches = !inMarkupMode;
    self.zoomViewImageShare.panGestureRecognizer.minimumNumberOfTouches = (inMarkupMode) ? 2 : 1;
    _inMarkupMode = inMarkupMode;
}


- (ECMarkupView *)markupView {
    if (!_markupView) {
        _markupView = [[ECMarkupView alloc] initWithFrame:_zoomViewImageShare.frame];
        _markupView.userInteractionEnabled = NO;
        _markupView.delegate = self;
    }
    return _markupView;
}

- (ECMarkupToolboxView *)toolboxView {
    
    if (!_toolboxView) {
        _toolboxView = [[ECMarkupToolboxView alloc] initWithFrame:[self toolboxViewFrame]];
        _toolboxView.delegate = self;
        _toolboxView.hidden = YES;
        [_zoomViewImageShare.superview addSubview:_toolboxView];
        UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(draggedToolboxView:)];
        panGestureRecognizer.cancelsTouchesInView = YES;
        [_toolboxView addGestureRecognizer:panGestureRecognizer];
        
    }
    return _toolboxView;
    
}

- (UIButton *)drawButton {
    if (!_drawButton) {
        UIImage *buttonImage = [UIImage imageNamed:@"markup_draw"];
        CGFloat height = SCREEN_SIZE.height > SCREEN_SIZE.width ? SCREEN_SIZE.width : SCREEN_SIZE.height;
        CGRect buttonFrame = CGRectMake(10, height / 2, 50, 50);
        _drawButton = [[UIButton alloc] initWithFrame:buttonFrame];
        _drawButton.layer.masksToBounds = NO;
        _drawButton.layer.shadowColor = [UIColor whiteColor].CGColor;
        _drawButton.layer.shadowOpacity = 0.9;
        _drawButton.layer.shadowRadius = 15;
        _drawButton.layer.shadowOffset = CGSizeZero;
        //解决拖动事件和button点击事件冲突问题，原因是3DTouch出现后，需要很轻的点击才能实现拖动的同时不实现点击方法，故替换成手势点击事件。
        //[_drawButton addTarget:self action:@selector(toggleMarkupMode) forControlEvents:UIControlEventTouchDown];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleMarkupMode)];
        [_drawButton addGestureRecognizer:tap];
        
        [_drawButton setImage:buttonImage forState:UIControlStateNormal];
        UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(drawButtonWasDragged:)];
        panGestureRecognizer.cancelsTouchesInView = YES;
        [_drawButton addGestureRecognizer:panGestureRecognizer];
    }
    return _drawButton;
}

- (void)toggleMarkupMode {
    self.inMarkupMode = YES;
    //    [self.actionDelegate videoZoomingView:self didToggleMarkupMode:YES];
    [self didToggleMarkupMode:YES];
    
    self.drawButton.hidden = YES;
    self.toolboxView.hidden = NO;
    
    //disable gesture recognizers and reset the zoom scale when entering the markup mode
    self.zoomViewImageShare.pinchGestureRecognizer.enabled = NO;
    self.zoomViewImageShare.panGestureRecognizer.enabled = NO;
    [self.zoomViewImageShare setScrollEnabled:NO];
    self.isMarkup =  YES;
    
    self.baseTap.enabled = NO;
    self.barView.hidden = YES;
    self.bottomView.hidden = YES;
    
}

- (void)didToggleMarkupMode:(BOOL)inMarkupMode {
    //layoutSubviews: called on device orientation change. It sets scroll to YES, we do not want it if it's in markupmode before the rotation
    self.inMarkupMode = inMarkupMode; //used to set scroll correspondingly in layoutSubviews:
    
    if (inMarkupMode) {
        
        [self videoZoomingViewDidChangeMarkupColor];
    }
}

- (void)drawButtonWasDragged:(UIPanGestureRecognizer *)panGestureRecognizer {
    CGPoint translation = [panGestureRecognizer translationInView:self.zoomViewImageShare];
    CGRect buttonFrame = self.drawButton.frame;
    CGRect superViewFrame = self.drawButton.superview.frame;
    buttonFrame.origin = CGPointMake(buttonFrame.origin.x + translation.x, buttonFrame.origin.y + translation.y);
    
    //do not let the button to get out of the superview bounds
    if (CGRectGetMinX(buttonFrame) < 0.0) {
        buttonFrame.origin.x = 0.0;
    } else if (CGRectGetMaxX(buttonFrame) > superViewFrame.size.width) {
        buttonFrame.origin.x = superViewFrame.size.width - CGRectGetWidth(buttonFrame);
    }
    
    
    if (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation) && CGRectGetMinX(buttonFrame) < 44) {
        buttonFrame.origin.x = 44;
    }
    
    if (CGRectGetMinY(buttonFrame) < 0.0) {
        buttonFrame.origin.y = 0.0;
    } else if (CGRectGetMaxY(buttonFrame) > superViewFrame.size.height) {
        buttonFrame.origin.y = superViewFrame.size.height - CGRectGetHeight(buttonFrame);
    } else if (self.toolboxView && (CGRectGetMaxY(buttonFrame) > (superViewFrame.size.height - CGRectGetHeight(self.toolboxView.frame)))) {
        buttonFrame.origin.y = superViewFrame.size.height - CGRectGetHeight(self.toolboxView.frame) - CGRectGetHeight(buttonFrame);
    }
    
    self.drawButton.frame = buttonFrame;
    [panGestureRecognizer setTranslation:CGPointZero inView:self.zoomViewImageShare];
}


- (CGRect)popoverViewFrame {
    
//    CGSize superVSize = SCREEN_SIZE;
//    if (self.zoomViewImageShare.superview) {
//        superVSize = self.zoomViewImageShare.superview.frame.size;
//    }
    //CGSize superVSize = SCREEN_SIZE;
    //CGFloat buttonMidX = superVSize.width * 0.3; //middle X coordinate of the 2nd button (the button over which the popover appears)
    CGRect popverViewFrame=CGRectZero;
    if (self.toolboxView.frame.origin.y < 145.0*_scale+screenPadding.top) {
        popverViewFrame=CGRectMake(self.toolboxView.frame.origin.x+(CGRectGetWidth(self.toolboxView.frame)/10+5-20)*_scale,
                                   CGRectGetMinY(self.toolboxView.frame)+CGRectGetHeight(self.toolboxView.frame),
                                   48*_scale,
                                   120*_scale);
    }else{
        popverViewFrame=CGRectMake(self.toolboxView.frame.origin.x+(CGRectGetWidth(self.toolboxView.frame)/10+5-20)*_scale,
                                   CGRectGetMinY(self.toolboxView.frame) - 120*_scale,
                                   48*_scale,
                                   120*_scale);
    }
    return popverViewFrame;
}

- (ECMarkupToolboxPopoverView *)popoverView {
    if(!_popoverView) {
        //NSArray *data = @[@"黑色", @"红色", @"绿色", @"蓝色"];
        NSArray *images = @[
                            [self imageCustomNamed:@"markup_color_menu_black"],
                            [self imageCustomNamed:@"markup_color_menu_red"],
                            [self imageCustomNamed:@"markup_color_menu_green"],
                            [self imageCustomNamed:@"markup_color_menu_blue"]
                            ];
        if (self.toolboxView.frame.origin.y < 145.0*_scale+screenPadding.top) {
            _popoverView = [[ECMarkupToolboxPopoverView alloc] initWithFrame:[self popoverViewFrame]
                                                                        data:nil
                                                                      images:images arrowType:ECMarkupToolboxPopoverViewArrowTypeUp];
        }else{
            _popoverView = [[ECMarkupToolboxPopoverView alloc] initWithFrame:[self popoverViewFrame]
                                                                        data:nil
                                                                      images:images arrowType:ECMarkupToolboxPopoverViewArrowTypeDown];
        }
        
        _popoverView.delegate = self;
    }
    return _popoverView;
    
}

- (void)clearPopoverView {
    if(_popoverView) {
        [self.popoverView removeFromSuperview];
        self.popoverView = nil;
        [self.toolboxView clearColorWithIndex:1];
        
    }
}

#pragma mark - ECMarkupToolboxView delegate methods
- (void)didSelectCloseMarkupToolboxView:(ECMarkupToolboxView *)toolboxView{
    self.inMarkupMode = NO;

    self.drawButton.hidden = NO;
    [self clearPopoverView];
    toolboxView.hidden = YES;
    //    self.markupColor = VideoZoomingViewMarkupColorNotSelected;
//    if ([self.actionDelegate respondsToSelector:@selector(videoZoomingView:didToggleMarkupMode:)]) {
//        [self.actionDelegate videoZoomingView:self didToggleMarkupMode:NO];
//    }

    //enable gestures when stopping annotating
    self.zoomViewImageShare.pinchGestureRecognizer.enabled = YES;
    self.zoomViewImageShare.panGestureRecognizer.enabled = YES;
    [self.zoomViewImageShare setScrollEnabled:YES];
    self.isMarkup = NO;
    
    self.baseTap.enabled = YES;
    self.barView.hidden = NO;
    self.bottomView.hidden = NO;
}


- (void)didSelectColorSelectionOnMarkupToolboxView:(ECMarkupToolboxView *)toolboxView{
    
    if(_popoverView && _popoverView.superview) {
        [self clearPopoverView];
    }else {
        [self.toolboxView.superview addSubview:self.popoverView];
    }
    
}


- (void)didSelectPencilToolOnMarkupToolboxView:(ECMarkupToolboxView *)toolboxView{
    [self clearPopoverView];
    self.markupView.mode = MarkupViewModeDrawing;
}


- (void)didSelectEraserToolOnMarkupToolboxView:(ECMarkupToolboxView *)toolboxView{
    [self clearPopoverView];
    self.markupView.mode = MarkupViewModeEraser;
}


- (void)didSelectClearOnMarkupToolboxView:(ECMarkupToolboxView *)toolboxView{
    [self clearPopoverView];
    
    [[ManagerService confService] conferenceEraseAllAnnotations];
    
}


#pragma mark - ECMarkupToolboxPopoverView delegate method
- (void)markupToolboxPopoverView:(ECMarkupToolboxPopoverView *)popoverView didSelectOptionAtIndex:(NSInteger)index {
    
    switch (index) {
        case 0:
            self.toolboxView.selectedColor = MarkupToolboxViewSelectedColorBlack;
            self.markupColor = VideoZoomingViewMarkupColorBlack;
            break;
        case 1:
            self.toolboxView.selectedColor = MarkupToolboxViewSelectedColorRed;
            self.markupColor = VideoZoomingViewMarkupColorRed;
            break;
        case 2:
            self.toolboxView.selectedColor = MarkupToolboxViewSelectedColorGreen;
            self.markupColor = VideoZoomingViewMarkupColorGreen;
            break;
        case 3:
            self.toolboxView.selectedColor = MarkupToolboxViewSelectedColorBlue;
            self.markupColor = VideoZoomingViewMarkupColorBlue;
            break;
        default:
            break;
    }

    if (self.markupView.mode != MarkupViewModeDrawing) {
        self.markupView.mode = MarkupViewModeDrawing;
        [self.toolboxView setSelectionOnButtonAtIndex:2];
    }

    [self clearPopoverView];
    
    [self videoZoomingViewDidChangeMarkupColor];
    
}

- (void)videoZoomingViewDidChangeMarkupColor{
    NSUInteger colorValue;
    
    switch (self.markupColor) {
        case VideoZoomingViewMarkupColorBlack:
            colorValue = ANNOTATION_COLOR_BLACK;
            break;
        case VideoZoomingViewMarkupColorRed:
            colorValue = ANNOTATION_COLOR_RED;
            break;
        case VideoZoomingViewMarkupColorBlue:
            colorValue = ANNOTATION_COLOR_BLUE;
            break;
        case VideoZoomingViewMarkupColorGreen:
            colorValue = ANNOTATION_COLOR_GREEN;
            break;
        case VideoZoomingViewMarkupColorNotSelected:
            return;
    }
    
    [self setAnnotationColor:colorValue lineWidth:50];
}

#pragma mark - WLMarkupView delegate methods
- (void)touchBeganOnMarkupView:(ECMarkupView *)markupView atLocation:(CGPoint)location {
    [self clearPopoverView];
    [self createAnnotationWithStartPoint:location eraser:(markupView.mode == MarkupViewModeEraser)];

}


- (void)touchMovedOnMarkupView:(ECMarkupView *)markupView atLocation:(CGPoint)location {
    
    [self updateAnnotationWithPoint:location eraser:(markupView.mode == MarkupViewModeEraser)];
    
}


- (void)touchEndedOnMarkupView:(ECMarkupView *)markupView atLocation:(CGPoint)location {
    
    [self finishAnnotationAtLocation:location Eraser:(markupView.mode == MarkupViewModeEraser)];

}


- (void)touchCanceledOnMarkupView:(ECMarkupView *)markupView atLocation:(CGPoint)location {
    [self cancelAnnotationEraser:(markupView.mode == MarkupViewModeEraser) gestureRecognizerTriggered:(self.zoomViewImageShare.pinchGestureRecognizer.state != 0) atLocation:location];
}

//拖拽移动toolboxView；
-(void)draggedToolboxView:(UIPanGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateChanged ||
        sender.state == UIGestureRecognizerStateEnded) {
        //注意，这里取得的参照坐标系是该对象的上层View的坐标。
        CGPoint offset = [sender translationInView:self.toolboxView];
        
        //通过计算偏移量来设定draggableObj的新坐标
        [self PanGestureView:self.toolboxView withPoint:offset];
        [sender setTranslation:CGPointMake(0, 0) inView:self.toolboxView];
        
    }
}

-(void)PanGestureView:(UIView *)panView withPoint:(CGPoint)offset{
    
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.2 animations:^{
        //x轴左右极限坐标
        CGFloat x=offset.x;
        //x 向右滑动
        if (offset.x>0.0 && weakSelf.toolboxView.center.x + offset.x + screenPadding.right*2.4 > (kMainScreenWidth -weakSelf.toolboxView.frame.size.width/2))
        {
            x = 0.0;
        }else if (offset.x<0.0 && weakSelf.toolboxView.center.x+ offset.x - screenPadding.left < weakSelf.toolboxView.frame.size.width/2){
            x=0.0;
        }

        //y轴上下极限坐标
        CGFloat y=offset.y;
        //y向下滑动
        if (offset.y>0.0 && weakSelf.toolboxView.center.y + offset.y + screenPadding.bottom > (weakSelf.toolboxView.superview.frame.size.height-weakSelf.toolboxView.frame.size.height/2))
        {
            y = 0.0;
        }else if(offset.y<0.0 && panView.center.y + offset.y - screenPadding.top <= panView.frame.size.height/2){
            y = 0.0;
        }
        if (x!=0.0||y!=0.0) {
            weakSelf.popoverView.hidden=YES;
            [weakSelf clearPopoverView];
        }
        [weakSelf.toolboxView setCenter:CGPointMake(weakSelf.toolboxView.center.x + x, weakSelf.toolboxView.center.y + y)];
        [weakSelf.popoverView setCenter:CGPointMake(weakSelf.popoverView.center.x+x, weakSelf.popoverView.center.y+y)];
    }];
    
}


/**
 设置标注颜色和线宽
 
 @param color 色值
 @param lineWidth 线宽
 */
- (void)setAnnotationColor:(unsigned int)color lineWidth:(int)lineWidth {
    [[ManagerService confService] annotationSetPenAndAnnotationColor:color lineWidth:lineWidth];
}


- (void)createAnnotationWithStartPoint:(CGPoint)point eraser:(BOOL)eraser {
    [[ManagerService confService] conferenceShareGetParam];
    
    if (eraser) {
        self.eraserSegmentStartPoint = point;
        return;
    }

    _annotationStartPoint = point;
    [[ManagerService confService] conferenceCreateAnnotationWithStartPointx:point.x Pointy:point.y];

}


- (void)updateAnnotationWithPoint:(CGPoint)point eraser:(BOOL)eraser {
    if (eraser) {
        [self eraseAnnotationsIntersectedBySegmentWithStartPoint:self.eraserSegmentStartPoint
                                                                                     endPoint:point];
        self.eraserSegmentStartPoint = point;; //update the eraser segment start point before the next move
    } else {
        [[ManagerService confService] conferenceUpdateAnnotationWithPointx:point.x Pointy:point.y];
    }
    
}


- (void)finishAnnotationAtLocation:(CGPoint)location Eraser:(BOOL)eraser{
    
    if (eraser) {
        self.eraserSegmentStartPoint = CGPointZero;
        CGFloat startPointX = self.annotationStartPoint.x;
        CGFloat startPointY = self.annotationStartPoint.y;
        CGFloat d = sqrt((location.x - startPointX) * (location.x - startPointX) + (location.y - startPointY) * (location.y - startPointY));

        if (d <= 5) {
            [[ManagerService confService] conferenceCancelAnnotation];
            [[ManagerService confService] conferenceEraseAnnotationAtLocation:location];
        }
        
    } else {
        [[ManagerService confService] conferenceFinishAnnotation];
    }
    
}


- (void)cancelAnnotationEraser:(BOOL)eraser
    gestureRecognizerTriggered:(BOOL)gestureRecognizerTriggered
                    atLocation:(CGPoint)location{
    
    if (eraser) {
        self.eraserSegmentStartPoint = CGPointZero;
    }
    
    if (gestureRecognizerTriggered) {
         [[ManagerService confService] conferenceCancelAnnotation];
    } else {
        if (eraser) {
            self.eraserSegmentStartPoint = CGPointZero;
                    CGFloat startPointX = self.annotationStartPoint.x;
                    CGFloat startPointY = self.annotationStartPoint.y;
                    CGFloat d = sqrt((location.x - startPointX) * (location.x - startPointX) + (location.y - startPointY) * (location.y - startPointY));
            
                    if (d <= 5) {
                        [[ManagerService confService] conferenceCancelAnnotation];
                        [[ManagerService confService] conferenceEraseAnnotationAtLocation:location];
                    }
            
        } else {
            [[ManagerService confService] conferenceFinishAnnotation];
        }
    }
}


/**
 擦除线
 先通过线选选中需要删除的线，再调用删除接口进行删除
 
 @param startPoint 起始点
 @param endPoint 终止点
 */
- (void)eraseAnnotationsIntersectedBySegmentWithStartPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint {
    
    [[ManagerService confService] conferenceEraseAnnotationsIntersectedBySegmentWithStartPoint:startPoint endPoint:endPoint];
}


- (void)calculateDataViewFrameWith:(NSData *)data {
    
    UIImage *dataImage = [[UIImage alloc] initWithData:data];
    
    CGImageRef cgImage = dataImage.CGImage;
    float pWidth =  CGImageGetWidth(cgImage);
    float pHeight = CGImageGetHeight(cgImage);
    
    if (SCREENHEIGHT > SCREENWIDTH) {
        float widthScale = pWidth / FINALSVC_HEIGHT;
        float heightScale = pHeight / FINALSVC_WIDTH;
        
        //根据数据获取的图像长宽比例设置在iPhone上的显示frame
        if (pWidth != 0 && pHeight != 0 && self.dataSVCWidth != pWidth) {
            self.dataSVCWidth = pWidth;
            self.dataWidth = 0;
            
            if (widthScale > heightScale) {
                float finalWidth = FINALSVC_HEIGHT;
                float finalHeight = FINALSVC_HEIGHT * pHeight / pWidth;
                self.shareImageView.frame = CGRectMake(0, (FINALSVC_WIDTH - finalHeight) / 2, finalWidth, finalHeight);
            } else {
                float finalWidth = pWidth / pHeight * FINALSVC_WIDTH;
                float finalHeight = FINALSVC_WIDTH;
                self.shareImageView.frame = CGRectMake((FINALSVC_HEIGHT - finalWidth) / 2, 0, finalWidth, finalHeight);
            }
        }
//        DDLogInfo(@"manageDataViewFrameWith pwidth:%f,pHeight:%f,datawidth:%f",pWidth,pHeight,self.dataWidth);
    } else {
        float widthScale = pWidth / FINAL_HEIGHT;
        float heightScale = pHeight / FINAL_WIDTH;
        
        //根据数据获取的图像长宽比例设置在iPhone上的显示frame
        if (pWidth != 0 && pHeight != 0 && self.dataWidth != pWidth) {
            self.dataWidth = pWidth;
            self.dataSVCWidth = 0;
            
            if (widthScale > heightScale) {
                float finalWidth = FINAL_HEIGHT;
                float finalHeight = FINAL_HEIGHT * pHeight / pWidth;
                self.shareImageView.frame = CGRectMake(0, (FINAL_WIDTH - finalHeight) / 2, finalWidth, finalHeight);
            } else {
                float finalWidth = pWidth / pHeight * FINAL_WIDTH;
                float finalHeight = FINAL_WIDTH;
                self.shareImageView.frame = CGRectMake((FINAL_HEIGHT - finalWidth) / 2, 0, finalWidth, finalHeight);
            }
        }
//        DDLogInfo(@"manageDataViewFrameWith start pwidth:%f,pHeight:%f,datawidth:%f",pWidth,pHeight,self.dataWidth);
    }
    self.markupView.frame = self.shareImageView.frame;
    CGFloat scale = pWidth / (self.shareImageView.frame.size.width * [UIScreen mainScreen].scale);
    [ManagerService confService].imageScale = scale;
    
    _zoomViewImageShare.contentSize = CGSizeMake(_shareImageView.frame.size.width, _shareImageView.frame.size.height);
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    self.shareImageView.userInteractionEnabled = YES;
    return _shareImageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width)?
    (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height)?
    (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
    self.shareImageView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX,
                                            scrollView.contentSize.height * 0.5 + offsetY);
    self.markupView.center = self.shareImageView.center;
    
}

- (void)handleReceiveScreenShareAction:(NSNotification *)notification {
    NSData *imgData = notification.object;

    [self updateShareImageData:imgData];

    [self calculateDataViewFrameWith:imgData];
}

@end
