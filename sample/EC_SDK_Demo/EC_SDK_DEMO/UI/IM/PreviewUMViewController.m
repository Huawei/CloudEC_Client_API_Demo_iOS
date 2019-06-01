//
//  PreviewUMViewController.m
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

#import "PreviewUMViewController.h"
#import "CommonUtils.h"
#import <AVFoundation/AVFoundation.h>

@interface PreviewUMViewController ()
//@property (nonatomic, strong)ESpaceUMResource *umResource;                    // umResource
@property (nonatomic, weak)IBOutlet UIImageView *preview;                     // preview image view
@property (nonatomic, weak)IBOutlet UIActivityIndicatorView *indicatorView;   // activity view

@end

@implementation PreviewUMViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [_preview setContentMode:UIViewContentModeScaleAspectFit];
    [self.view setBackgroundColor:[UIColor blackColor]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    self.umResource = _message.umResources.lastObject;
//    [self.umResource addObserver:self forKeyPath:@"umStatus" options:NSKeyValueObservingOptionNew context:nil];
//    [self.umResource addObserver:self forKeyPath:@"progress.fractionCompleted" options:NSKeyValueObservingOptionNew context:nil];
    if (self.message.contentType.integerValue == ESpaceImageContentType) {
        [self loadImage];
    }
    else {
        [self loadVideo];
    }
}

/**
 This method is used to load preview image view
 */
- (void)loadImage
{
    UIImage *image = nil;
//    ESpaceUMImgResource *imgResource = (ESpaceUMImgResource*)_umResource;
//    if (imgResource) {
//        if ([imgResource isGif]) {
//            if ([imgResource needDownload]) {
//                [imgResource downloadIfNeeded];
//            } else {
//                image = [CommonUtils attachImageFile:[imgResource localFilePath]];
//            }
//        } else {
//            if ([[ESpaceImageCache sharedInstance] imageWithKey:[imgResource localFilePath]]){
//                //original image in cache
//                image = [CommonUtils attachImageFile:[imgResource localFilePath]];
//            }else if ([imgResource localExites] && [imgResource isLocalFileReady]){
//                //original image in disk
//                image = [CommonUtils attachImageFile:[imgResource localFilePath]];
//            }
//
//            if (image == nil) {
//                if ([[ESpaceImageCache sharedInstance] imageWithKey:[imgResource localThumbFilePath]]) {
//                    //thumb image in cache
//                    image = [CommonUtils attachImageFile:[imgResource localThumbFilePath]];
//                }else if ([imgResource thumbExites] && [imgResource isThumbnailReady]){
//                    //thumb image in disk
//                    image = [CommonUtils attachImageFile:[imgResource localThumbFilePath]];
//                }
//                else if (imgResource.thumbnailStatus == ESpaceThumbnailStatusDownloadFailed){
//                    image = [UIImage imageNamed:@"um_failed_load_picture"];
//                }
//                else {
//                    image = [UIImage imageNamed:@"um_image_default"];
//                }
//                [imgResource downloadIfNeeded];
//                _indicatorView.hidden = NO;
//                [_indicatorView startAnimating];
//            }
//            else {
//                _indicatorView.hidden = YES;
//            }
//        }
        _preview.image = image;
//    }
}

/**
 This method is used to load video
 */
- (void)loadVideo
{
//    ESpaceUMVideoResource *videoResource = (ESpaceUMVideoResource *)_umResource;
//    UIImage *image = [UIImage imageWithContentsOfFile:videoResource.localThumbFilePath];
//    if (!image) {
//        image = [UIImage imageNamed:@"um_video_default"];
//    }
//    _preview.image = image;
//
//    switch (videoResource.umStatus) {
//        case ESpaceUMStatusUploading:
//        case ESpaceUMStatusUploaded:
//        case ESpaceUMStatusDownloaded:
//        case ESpaceUMStatusUploadFailed: {
//            self.indicatorView.hidden = YES;
//            [self playVideo:[NSURL fileURLWithPath:videoResource.localFilePath]];
//            _preview.hidden = YES;
//        }
//            break;
//
//        case ESpaceUMStatusDownloading:{
//            self.indicatorView.hidden = NO;
//            [self.indicatorView startAnimating];
//        }
//            break;
//
//        case ESpaceUMStatusDownloadFailed:
//        default: {
//            self.indicatorView.hidden = NO;
//            [self.indicatorView startAnimating];
//            [videoResource downloadIfNeeded];
//        }
//            break;
//    }
    
}

/**
 This method is used to play video

 @param url NSURL
 */
- (void)playVideo:(NSURL *)url
{
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:url];
    AVPlayer *player = [AVPlayer playerWithPlayerItem:playerItem];
    AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:player];
    playerLayer.frame = [UIScreen mainScreen].bounds;
    playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    [player play];
    [self.view.layer addSublayer:playerLayer];
}

/**
 This method is used to hide preview view

 @param sender sender
 */
- (IBAction)tapEndPreview:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([keyPath isEqualToString:@"umStatus"]) {
//            if (_umResource.umStatus == ESpaceUMStatusDownloading
//                || _umResource.umStatus == ESpaceUMStatusUploading
//                || _umResource.umStatus == ESpaceUMStatusUploaded
//                || _umResource.umStatus == ESpaceUMStatusUploadFailed) {
//                return ;
//            }
//            if (_message.contentType.integerValue == ESpaceImageContentType) {
//                UIImage *image = nil;
//                image = [CommonUtils attachImageFile:[_umResource localFilePath]];
//
//                if (image == nil && _umResource.umStatus == ESpaceUMStatusDownloadFailed) {
//                    image = [UIImage imageNamed:@"um_failed_load_picture"];
//                }
//                _preview.image = image;
//            }
//            else {
//                if (_umResource.umStatus == ESpaceUMStatusDownloaded) {
//                    [self playVideo:[NSURL fileURLWithPath:_umResource.localFilePath]];
//                    _preview.hidden = YES;
//                }
//                else {
//                    _preview.image = [UIImage imageNamed:@"um_failed_load_picture"];
//                }
//            }
            _indicatorView.hidden = YES;
        }
        else if ([keyPath isEqualToString:@"progress.fractionCompleted"]) {
            // download progress
        }
    });
}

- (void)dealloc
{
//    [self.umResource removeObserver:self forKeyPath:@"umStatus"];
//    [self.umResource removeObserver:self forKeyPath:@"progress.fractionCompleted"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
