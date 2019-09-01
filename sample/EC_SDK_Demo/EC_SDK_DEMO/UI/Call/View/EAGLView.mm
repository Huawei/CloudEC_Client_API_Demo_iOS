//
//  EAGLView.mm
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

//#import <QuartzCore/QuartzCore.h>
#import "EAGLView.h"

#define REMOTE_OPENGL_VIEW_SIZE CGRectMake(215, 100, 594, 437)
#define PREVIEW_OPENGL_VIEW_SIZE CGRectMake(0, 44, 1024, 748)
#define LOCAL_OPENGL_VIEW_SIZE  CGRectMake(494, 364, 100, 73)//CGRectMake(494, 364, 100, 73)
#define BFCP_INITIATIVE_VIEW_SIZE CGRectMake(0, 0, 1024, 736)//CGRectMake(0, 0, 1024, 736)
#define BFCP_PASSIVE_VIEW_SIZE CGRectMake(0, 0, 1024, 736)


#define MAINWIDTH ([UIScreen mainScreen].bounds.size.height>[UIScreen mainScreen].bounds.size.width?[UIScreen mainScreen].bounds.size.height:[UIScreen mainScreen].bounds.size.width)
#define MAINHEIGHT ([UIScreen mainScreen].bounds.size.height<[UIScreen mainScreen].bounds.size.width?[UIScreen mainScreen].bounds.size.height:[UIScreen mainScreen].bounds.size.width)

#define BLACK_SUBLAYER_NAME  @"VIDEO_VIEW_BLACK_SUBLAYER"

static EAGLView *openGLPreviewView = nil;
static EAGLView *openGLRemoteView = nil;
static EAGLView *openGLLocalView = nil;

static EAGLView *openGLLocalBigView = nil;

static EAGLView *openGLFirstSVCView = nil;
static EAGLView *openGLSecondSVCView = nil;
static EAGLView *openGLThirdSVCView = nil;

static EAGLView *openGLTupBFCPView = nil;
static EAGLView *openGLDataConfView = nil;

static EAGLView *openGLDataLocalView = nil;
static EAGLView *openGLDataRemoteView = nil;

@implementation EAGLView


+ (EAGLView *)getDataLocalView
{
    if (openGLDataLocalView == nil)
    {
        openGLDataLocalView = [[self alloc] initWithFrame:CGRectZero];
        openGLDataLocalView.backgroundColor = [UIColor clearColor];
    }
    return openGLDataLocalView;
}

+ (EAGLView *)getDataRemoteView
{
    if (openGLDataRemoteView == nil)
    {
        openGLDataRemoteView = [[self alloc] initWithFrame:CGRectZero];
        openGLDataRemoteView.backgroundColor = [UIColor clearColor];
    }
    return openGLDataRemoteView;
}

+(EAGLView *)getPreviewView
{
	if (openGLPreviewView == nil)
    {
		openGLPreviewView = [[self alloc] initWithFrame:PREVIEW_OPENGL_VIEW_SIZE];
	}
	return openGLPreviewView;
}

+(EAGLView *)getRemoteView
{
    if (openGLRemoteView == nil)
    {
        openGLRemoteView = [[self alloc] initWithFrame:REMOTE_OPENGL_VIEW_SIZE];
        openGLRemoteView.backgroundColor = [UIColor blackColor];
    }
    
	return openGLRemoteView;
}


+(EAGLView *)getLocalView
{
	if (openGLLocalView == nil)
    {
        openGLLocalView = [[self alloc] initWithFrame:CGRectMake(0,
                                                                 0,
                                                                 78.5,
                                                                 105)];
        openGLLocalView.backgroundColor = [UIColor blackColor];
	}
	return openGLLocalView;
}

+(EAGLView *)getLocalBigView
{
    if (openGLLocalBigView == nil)
    {
        openGLLocalBigView = [[self alloc] initWithFrame:REMOTE_OPENGL_VIEW_SIZE];
        openGLLocalBigView.backgroundColor = [UIColor blackColor];
    }
    
    return openGLLocalBigView;
}

//tup
+ (EAGLView *)getTupBFCPView {
    if (nil == openGLTupBFCPView) {
        openGLTupBFCPView = [[EAGLView alloc]initWithFrame:CGRectMake(0,
                                                                      0,
                                                                      [UIScreen mainScreen].bounds.size.width,
                                                                      [UIScreen mainScreen].bounds.size.height)];
        openGLTupBFCPView.backgroundColor = [UIColor clearColor];
    }
    return openGLTupBFCPView;
}

//data conf
+ (EAGLView *)getDataConfBFCPView {
    if (nil == openGLDataConfView) {
        openGLDataConfView = [[EAGLView alloc]initWithFrame:CGRectMake(0,
                                                                      0,
                                                                      [UIScreen mainScreen].bounds.size.width,
                                                                      [UIScreen mainScreen].bounds.size.height)];
        openGLDataConfView.backgroundColor = [UIColor clearColor];
    }
    return openGLDataConfView;
}

+(EAGLView *)getFirstSVCView
{
    if (openGLFirstSVCView == nil)
    {
        openGLFirstSVCView = [[self alloc] initWithFrame:CGRectMake(0,
                                                                    0,
                                                                    78.5,
                                                                    105)];
        openGLFirstSVCView.backgroundColor = [UIColor blackColor];
    }
    
    return openGLFirstSVCView;
}


+(EAGLView *)getSecondSVCView
{
    if (openGLSecondSVCView == nil)
    {
        openGLSecondSVCView = [[self alloc] initWithFrame:CGRectMake(0,
                                                                     0,
                                                                     78.5,
                                                                     105)];
        openGLSecondSVCView.backgroundColor = [UIColor blackColor];
    }
    return openGLSecondSVCView;
}

+ (EAGLView *)getThirdSVCView
{
    if (openGLThirdSVCView == nil)
    {
        openGLThirdSVCView = [[self alloc] initWithFrame:CGRectMake(0,
                                                                    0,
                                                                    78.5,
                                                                    105)];
        openGLThirdSVCView.backgroundColor = [UIColor blackColor];
    }
    return openGLThirdSVCView;
}


+ (void)destroyPreviewView
{
    if (openGLPreviewView)
    {
        [openGLPreviewView removeFromSuperview];
        openGLPreviewView = nil;
    }
}

+ (void)destroyLocalView
{
    if (openGLLocalView)
    {
        [openGLLocalView removeFromSuperview];
        openGLLocalView = nil;
    }
}

+ (void)destroyLocalBigView
{
    if (openGLLocalBigView)
    {
        [openGLLocalBigView removeFromSuperview];
        openGLLocalBigView = nil;
    }
}

+ (void)destroyRemoteView
{
    if (!openGLRemoteView)
    {
        return;
    }
    
    [openGLRemoteView removeFromSuperview];
    openGLRemoteView = nil;
}

+ (void)hideDataRemoteView
{
    [openGLDataRemoteView addBlackSublayer];
}

+ (void)showDataRemoteView
{
    [openGLDataRemoteView deleteBlackSublayer];
}

+ (void)hideDataLocalView
{
    [openGLDataLocalView addBlackSublayer];
}

+ (void)showDataLocalView
{
    [openGLDataLocalView deleteBlackSublayer];
}

+ (void)hideRemoteView
{
    [openGLRemoteView addBlackSublayer];
}

+ (void)showRemoteView
{
    [openGLRemoteView deleteBlackSublayer];
}

+ (void)hideLocalView
{
    [openGLLocalView addBlackSublayer];
}

+ (void)showLocalView
{
    [openGLLocalView deleteBlackSublayer];
}

+ (void)hideFirstSVCView
{
    [openGLFirstSVCView addBlackSublayer];
}

+ (void)showFirstSVCView
{
    [openGLFirstSVCView deleteBlackSublayer];
}

+ (void)hideSecondSVCView
{
    [openGLSecondSVCView addBlackSublayer];
}

+ (void)showSecondSVCView
{
    [openGLSecondSVCView deleteBlackSublayer];
}

+ (void)hideThirdSVCView
{
    [openGLThirdSVCView addBlackSublayer];
}

+ (void)showThirdSVCView
{
    [openGLThirdSVCView deleteBlackSublayer];
}

+ (void)destroyFirstSVCView
{
    if (openGLFirstSVCView)
    {
        [openGLFirstSVCView removeFromSuperview];
        openGLFirstSVCView = nil;
    }
}

+ (void)destroySecondSVCView
{
    if (openGLSecondSVCView)
    {
        [openGLSecondSVCView removeFromSuperview];
        openGLSecondSVCView = nil;
    }
}

+ (void)destroyThirdSVCView
{
    if (openGLThirdSVCView)
    {
        [openGLThirdSVCView removeFromSuperview];
        openGLThirdSVCView = nil;
    }
}

// You must implement this method
+ (Class)layerClass
{
    return [CAEAGLLayer class];
}


- (void)dealloc
{
}


- (void)layoutSubviews
{
    // The framebuffer will be re-created at the beginning of the next setFramebuffer method call.
}

- (void)turnoffVideoView
{
    self.layer.transform = CATransform3DMakeScale(-1, 1, 1);
}

- (void)turnUpDownVideoView
{
    self.layer.transform = CATransform3DMakeScale(1, -1, 1);
}

- (void)resetVideoView
{
	self.layer.transform = CATransform3DMakeScale(1, 1, 1);
}

- (void)addBlackSublayer
{
    [self deleteBlackSublayer];
    self.layer.masksToBounds = YES;
	CALayer *subLayer = [CALayer layer];
	subLayer.name = BLACK_SUBLAYER_NAME;
	subLayer.backgroundColor = [UIColor blackColor].CGColor;
    subLayer.frame = CGRectMake(0, 0, MAINWIDTH, MAINHEIGHT);
	[self.layer addSublayer:subLayer];
	
}

- (void)deleteBlackSublayer
{
	for (CALayer *sublayer in [self.layer sublayers])
    {
		if ([sublayer.name isEqualToString:BLACK_SUBLAYER_NAME])
        {
			[sublayer removeFromSuperlayer];
            self.layer.masksToBounds = NO;
			break;
		}
	}
	self.layer.doubleSided = TRUE;
}


@end

