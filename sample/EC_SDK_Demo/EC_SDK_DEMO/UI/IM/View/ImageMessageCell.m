//
//  ImageMessageCell.m
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

#import "ImageMessageCell.h"
#import <TUPIMSDK/TUPIMSDK.h>
#import "CommonUtils.h"

#define MAX_THUMB_WIDTH 100.f

@interface ImageMessageCell ()
@property (nonatomic, weak)IBOutlet UIButton *imageBtn;          // image button
@property (nonatomic, strong)ESpaceUMImgResource *umResource;    // umResource

@end

@implementation ImageMessageCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (CGFloat)cellHeightForChatMessage:(ChatMessageEntity *)entity
{
    ESpaceUMImgResource *umResource = entity.umResources.lastObject;
    UIImage *image = nil;
    if ([[ESpaceImageCache sharedInstance] imageWithKey:[umResource localThumbFilePath]]) {
        //thumb image in cache
        image = [CommonUtils attachImageFile:[umResource localThumbFilePath]];
    }else if ([umResource thumbExites] && [umResource isThumbnailReady]){
        //thumb image in disk
        image = [CommonUtils attachImageFile:[umResource localThumbFilePath]];
    }else if ([[ESpaceImageCache sharedInstance] imageWithKey:[umResource localFilePath]]){
        //original image in cache
        image = [CommonUtils attachImageFile:[umResource localFilePath]];
    }else if ([umResource localExites] && [umResource isLocalFileReady]){
        //original image in disk
        image = [CommonUtils attachImageFile:[umResource localFilePath]];
    }
    else if (umResource.thumbnailStatus == ESpaceThumbnailStatusDownloadFailed){
        image = [UIImage imageNamed:@"um_failed_load_picture"];
    }
    else {
        image = [UIImage imageNamed:@"um_image_default"];
    }
    
    if (image) {
        CGFloat height = image.size.height;
        CGFloat width = image.size.width;
        if (width > MAX_THUMB_WIDTH) {
            height = height / (width / MAX_THUMB_WIDTH);
//            width = MAX_THUMB_WIDTH;
        }
        return height + 40;
    }
    else {
        return 140;
    }
}



- (void)setMessage:(ChatMessageEntity *)message
{
    [super setMessage:message];
    [self.umResource removeObserver:self forKeyPath:@"umStatus"];
    [self.umResource removeObserver:self forKeyPath:@"thumbnailStatus"];
    self.umResource = message.umResources.lastObject;
    [self.umResource addObserver:self forKeyPath:@"umStatus" options:NSKeyValueObservingOptionNew context:nil];
    [self.umResource addObserver:self forKeyPath:@"thumbnailStatus" options:NSKeyValueObservingOptionNew context:nil];
    
    UIImage *image = nil;
    if (_umResource) {
        if ([_umResource isGif]) {
            if ([_umResource needDownload]) {
                [_umResource downloadIfNeeded];
            } else {
                image = [CommonUtils attachImageFile:[_umResource localFilePath]];
            }
        } else {
            if ([[ESpaceImageCache sharedInstance] imageWithKey:[_umResource localThumbFilePath]]) {
                //thumb image in cache
                image = [CommonUtils attachImageFile:[_umResource localThumbFilePath]];
            }else if ([_umResource thumbExites] && [_umResource isThumbnailReady]){
                //thumb image in disk
                image = [CommonUtils attachImageFile:[_umResource localThumbFilePath]];
            }else if ([[ESpaceImageCache sharedInstance] imageWithKey:[_umResource localFilePath]]){
                //original image in cache
                image = [CommonUtils attachImageFile:[_umResource localFilePath]];
            }else if ([_umResource localExites] && [_umResource isLocalFileReady]){
                //original image in disk
                image = [CommonUtils attachImageFile:[_umResource localFilePath]];
            }
            
            if (image == nil) {
                if (_umResource.thumbnailStatus == ESpaceThumbnailStatusDownloadFailed){
                    image = [UIImage imageNamed:@"um_failed_load_picture"];
                }
                else {
                    image = [UIImage imageNamed:@"um_image_default"];
                    
                    if ([_umResource supportThumbnailDownload]){
                        [_umResource downloadThumbnailIfNeeded];
                    }else{
                        [_umResource downloadIfNeeded];
                    }
                }
            }
        }
        [self adjustContentWithImage:image];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"thumbnailStatus"] && object == _umResource) {
        dispatch_async(dispatch_get_main_queue(), ^{
            BOOL thumbnaiDownloadReady = _umResource.thumbnailStatus == ESpaceThumbnailStatusDownloaded;
            UIImage *image = nil;
            if (thumbnaiDownloadReady && [[ESpaceImageCache sharedInstance] imageWithKey:[_umResource localThumbFilePath]]) {
                image = [CommonUtils attachImageFile:[_umResource localThumbFilePath]];
            }else if (thumbnaiDownloadReady && [_umResource thumbExites]){
                image = [CommonUtils attachImageFile:[_umResource localThumbFilePath]];
            }else if (_umResource.thumbnailStatus == ESpaceThumbnailStatusDownloadFailed) {
                image = [UIImage imageNamed:@"um_failed_load_picture"];
            }
            
            [self adjustContentWithImage:image];
            
            if ([self.delegate respondsToSelector:@selector(messageUmResourceDidFinishLoad:)]) {
                [self.delegate messageUmResourceDidFinishLoad:self.message];
            }
        });
    } else if ([keyPath isEqualToString:@"umStatus"] && object == _umResource) {
        dispatch_async(dispatch_get_main_queue(), ^{
            UIImage *image = nil;
            if ([[ESpaceImageCache sharedInstance] imageWithKey:[_umResource localThumbFilePath]]) {
                image = [CommonUtils attachImageFile:[_umResource localThumbFilePath]];
            }else if ([_umResource thumbExites]){
                image = [CommonUtils attachImageFile:[_umResource localThumbFilePath]];
            }else if ([[ESpaceImageCache sharedInstance] imageWithKey:[_umResource localFilePath]]){
                image = [CommonUtils attachImageFile:[_umResource localFilePath]];
            }else if ([_umResource localExites] && [_umResource isLocalFileReady]){
                image = [CommonUtils attachImageFile:[_umResource localFilePath]];
            }
            if (_umResource.umStatus == ESpaceUMStatusDownloadFailed
                && _umResource.thumbnailStatus != ESpaceThumbnailStatusDownloaded) {
                image = [UIImage imageNamed:@"um_failed_load_picture"];
            }
            [self adjustContentWithImage:image];
            
            if ([self.delegate respondsToSelector:@selector(messageUmResourceDidFinishLoad:)]) {
                [self.delegate messageUmResourceDidFinishLoad:self.message];
            }
            
        });
    }
}

- (void)adjustContentWithImage:(UIImage *)image
{
    [self.imageBtn setImage:image forState:UIControlStateNormal];
    
    CGFloat height = image.size.height;
    CGFloat width = image.size.width;
    if (width > MAX_THUMB_WIDTH) {
        height = image.size.height / (image.size.width / MAX_THUMB_WIDTH);
        width = MAX_THUMB_WIDTH;
    }
    self.textWidthConstraint.constant = width;
    self.textHeighConstraint.constant = height;
}

- (IBAction)previewImage:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(clickToPreviewUM:)]) {
        [self.delegate clickToPreviewUM:self.message];
    }
}

- (void)dealloc
{
    [self.umResource removeObserver:self forKeyPath:@"umStatus"];
    [self.umResource removeObserver:self forKeyPath:@"thumbnailStatus"];
}

@end
