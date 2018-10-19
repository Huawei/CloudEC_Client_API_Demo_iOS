//
//  VideoMessageCell.m
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

#import "VideoMessageCell.h"
#import "CommonUtils.h"
#import <TUPIMSDK/TUPIMSDK.h>

#define VIDEO_MAX_WIDTH 150

@interface VideoMessageCell ()
@property (nonatomic, weak)IBOutlet UIImageView *thumbImage;       // thumb image view
@property (nonatomic, weak)IBOutlet UILabel *durationLabel;        // duration label
@property (nonatomic, strong)ESpaceUMVideoResource *umResource;    // umResource

@end

@implementation VideoMessageCell

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
    ESpaceUMVideoResource *umResource = entity.umResources.lastObject;
    UIImage *image = nil;
    if ([[ESpaceImageCache sharedInstance] imageWithKey:[umResource localThumbFilePath]]) {
        //thumb image in cache
        image = [CommonUtils attachImageFile:[umResource localThumbFilePath]];
    }else if ([umResource hasThumbnail]){
        //thumb image in disk
        image = [CommonUtils attachImageFile:[umResource localThumbFilePath]];
    }
    else{
        image = [UIImage imageNamed:@"um_video_default"];
    }
    
    if (image) {
        CGFloat height = image.size.height;
        CGFloat width = image.size.width;
        if (width > VIDEO_MAX_WIDTH) {
            height = height / (width / VIDEO_MAX_WIDTH);
//            width = VIDEO_MAX_WIDTH;
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
    self.umResource = message.umResources.lastObject;
    [self.umResource addObserver:self forKeyPath:@"umStatus" options:NSKeyValueObservingOptionNew context:nil];
    
    _durationLabel.text = [NSString stringWithFormat:@"%.2d:%.2d", _umResource.duration/60, _umResource.duration%60];
    UIImage *image = nil;
    if (_umResource) {
        image = [CommonUtils attachImageFile:[_umResource localThumbFilePath]];

        if (image == nil) {
            image = [UIImage imageNamed:@"um_video_default"];
        }
        [self adjustContentWithImage:image];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"umStatus"] && object == _umResource) {
        dispatch_async(dispatch_get_main_queue(), ^{
            UIImage *image = nil;
            image = [CommonUtils attachImageFile:[_umResource localThumbFilePath]];
            if (_umResource.umStatus == ESpaceUMStatusDownloadFailed
                && _umResource.thumbnailStatus != ESpaceThumbnailStatusDownloaded) {
                image = [UIImage imageNamed:@"um_video_default"];
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
    self.thumbImage.image = image;
    
    CGFloat height = image.size.height;
    CGFloat width = image.size.width;
    if (width > VIDEO_MAX_WIDTH) {
        height = image.size.height / (image.size.width / VIDEO_MAX_WIDTH);
        width = VIDEO_MAX_WIDTH;
    }
    self.textWidthConstraint.constant = width;
    self.textHeighConstraint.constant = height;
}

- (IBAction)previewVideo:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(clickToPreviewUM:)]) {
        [self.delegate clickToPreviewUM:self.message];
    }
}

- (void)dealloc
{
    [self.umResource removeObserver:self forKeyPath:@"umStatus"];
}


@end
