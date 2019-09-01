//
//  AudioQualityTableViewCell.m
//  EC_SDK_DEMO
//
//  Created by huawei on 2019/8/27.
//  Copyright © 2019年 cWX160907. All rights reserved.
//

#import "AudioQualityTableViewCell.h"
@interface AudioQualityTableViewCell()
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *bandWidthLabel;
@property (weak, nonatomic) IBOutlet UILabel *packetLossRateLabel;
@property (weak, nonatomic) IBOutlet UILabel *delayLabel;
@property (weak, nonatomic) IBOutlet UILabel *jitterLabel;

@end

@implementation AudioQualityTableViewCell

- (void)setCurrentStatisticShowInfo:(StatisticShowInfo *)currentStatisticShowInfo
{
    _currentStatisticShowInfo = currentStatisticShowInfo;
    if (nil != _currentStatisticShowInfo) {
        [self updateStatisticInfo];
        [self setNeedsUpdateConstraints];
    }
}

- (void)updateStatisticInfo
{
    _nameLabel.text = _currentStatisticShowInfo.name;
    _bandWidthLabel.text = [NSString stringWithFormat:@"%ld",_currentStatisticShowInfo.bandWidth];
    _packetLossRateLabel.text =  [NSString stringWithFormat:@"%lld",_currentStatisticShowInfo.lossFraction];
    _delayLabel.text = [NSString stringWithFormat:@"%lld",_currentStatisticShowInfo.delay];
    _jitterLabel.text = [NSString stringWithFormat:@"%lld",_currentStatisticShowInfo.jitter];;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
