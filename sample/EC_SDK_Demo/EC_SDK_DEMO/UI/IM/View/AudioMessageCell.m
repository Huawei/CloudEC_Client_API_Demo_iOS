//
//  AudioMessageCell.m
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

#import "AudioMessageCell.h"
#import <TUPIMSDK/TUPIMSDK.h>
#import <TUPIOSSDK/TUPIOSSDK.h>

#define AUDIO_MAX_WIDTH 200

@interface AudioMessageCell ()
@property (nonatomic, weak)IBOutlet UIButton *voicePlayBtn;        // voice play btn
@property (nonatomic, weak)IBOutlet UIImageView *audioUnreadImg;   // audio unread image
@property (nonatomic, strong)ESpaceUMAudioResource *umResource;    // umResource

@end

@implementation AudioMessageCell

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
    return 80;
}

- (void)setMessage:(ChatMessageEntity *)message
{
    [self.message removeObserver:self forKeyPath:@"readDetail"];
    [super setMessage:message];
    [self.message addObserver:self forKeyPath:@"readDetail" options:NSKeyValueObservingOptionNew context:NULL];
    
    [self.umResource removeObserver:self forKeyPath:@"playing"];
    [self.umResource removeObserver:self forKeyPath:@"umStatus"];
    
    self.umResource = [message umResources].lastObject;
    [self.umResource addObserver:self forKeyPath:@"playing" options:NSKeyValueObservingOptionNew context:NULL];
    [self.umResource addObserver:self forKeyPath:@"umStatus" options:NSKeyValueObservingOptionNew context:NULL];
    
    [self updateMessage];
    [self updateSpeakAnimation];
    [self updateIndicator];
}


- (void)updateMessage
{
    [_voicePlayBtn setHidden:NO];
    [_audioUnreadImg setHidden:self.message.readDetail.boolValue];
    self.textHeighConstraint.constant = 40;
    
    CGFloat width = _umResource.duration / 60.0 * AUDIO_MAX_WIDTH;
    width = width > AUDIO_MAX_WIDTH ? AUDIO_MAX_WIDTH : width;
    width = width < 80 ? 80 : width;
    self.textWidthConstraint.constant = width;
    [_voicePlayBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -width/2 + 30, 0, 0)];
    [_voicePlayBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, -width/2 + 50, 0, 0)];
    [_voicePlayBtn setTitle:[NSString stringWithFormat:@"%d''", _umResource.duration] forState:UIControlStateNormal];
}

- (void)updateSpeakAnimation {
    
    if (_umResource.playing) {
        self.voicePlayBtn.imageView.animationImages = [UIImage animatedImageNamed:@"left_voice_play" duration:1.0].images;
        self.voicePlayBtn.imageView.animationDuration = 1.0f;
        [self.voicePlayBtn.imageView startAnimating];
    } else {
        [self.voicePlayBtn.imageView stopAnimating];
        self.voicePlayBtn.imageView.animationImages = nil;
        self.voicePlayBtn.imageView.image = [UIImage imageNamed:@"left_voice_play3"];
    }
}

- (void)updateIndicator
{
    if (self.umResource.umStatus == ESpaceUMStatusDownloading) {
        self.activity.hidden = NO;
        [self.activity startAnimating];
    } else {
        self.activity.hidden = YES;
        [self.activity stopAnimating];
    }
}

- (IBAction)audioPlay:(id)sender
{
    if (_umResource.playing) {
        [_umResource stop];
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    if ([_umResource localExites]) {
        BOOL result = [_umResource play:^(BOOL force) {
        }];
        if (result) {
            [weakSelf.message markReadDetail];
        }
    }
    else {
        [_umResource download:^(NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (error) {
                    DDLogWarn(@"download audio failed.");
                }
                else {
                    BOOL result = [weakSelf.umResource play:^(BOOL force) {
                        [weakSelf updateSpeakAnimation];
                    }];
                    if (result) {
                        [weakSelf.message markReadDetail];
                    }
                }
            });
        }];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([keyPath isEqualToString:@"playing"]) {
            [weakSelf updateSpeakAnimation];
        }
        else if ([keyPath isEqualToString:@"umStatus"]) {
            [weakSelf updateIndicator];
        }
        else if ([keyPath isEqualToString:@"readDetail"]) {
            [_audioUnreadImg setHidden:self.message.readDetail.boolValue];
        }
    });
}

- (void)dealloc
{
    [self.message removeObserver:self forKeyPath:@"readDetail"];
    [self.umResource removeObserver:self forKeyPath:@"playing"];
    [self.umResource removeObserver:self forKeyPath:@"umStatus"];
}

@end
