//
//  EAGLView.h
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

#import <UIKit/UIKit.h>

#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

// This class wraps the CAEAGLLayer from CoreAnimation into a convenient UIView subclass.
// The view content is basically an EAGL surface you render your OpenGL scene into.
// Note that setting the view non-opaque will only work if the EAGL surface has an alpha channel.
@interface EAGLView : UIView

+(EAGLView *)getPreviewView;

+ (EAGLView *)getRemoteView;

+ (EAGLView *)getLocalView;

+ (EAGLView *)getDataLocalView;

+ (EAGLView *)getDataRemoteView;

//tup
+ (EAGLView *)getTupBFCPView;

//data conf
+ (EAGLView *)getDataConfBFCPView;

//+ (void)destoryTupBFCPView;
//
//+ (void)destoryDataConfBFCPView;

+ (EAGLView *)getRemoteCWView;

+ (EAGLView *)getLocalCWView;

+ (EAGLView *)getBFCPPassiveView;

+ (void)destroyPreviewView;

+ (void)destroyLocalView;

+ (void)destroyRemoteView;

+ (void)destroyBFCPView;

+ (void)hideDataRemoteView;

+ (void)showDataRemoteView;

+ (void)hideDataLocalView;

+ (void)showDataLocalView;

+ (void)hideRemoteView;

+ (void)showRemoteView;

+ (void)showLocalView;

+ (void)hideLocalView;

- (void)turnoffVideoView;

- (void)resetVideoView;

- (void)turnUpDownVideoView;

- (void)addBlackSublayer;

- (void)deleteBlackSublayer;

@end

