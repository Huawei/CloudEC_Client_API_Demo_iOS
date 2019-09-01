//
//  DataShareQualityTableViewCel.m
//  EC_SDK_DEMO
//
//  Created by huawei on 2019/8/28.
//  Copyright © 2019年 cWX160907. All rights reserved.
//

#import "DataShareQualityTableViewCel.h"
@interface DataShareQualityTableViewCel()
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *bandWidthLabel;
@property (weak, nonatomic) IBOutlet UILabel *paketLossRateLabel;
@property (weak, nonatomic) IBOutlet UILabel *dalayLabel;
@property (weak, nonatomic) IBOutlet UILabel *jitterLabel;
@property (weak, nonatomic) IBOutlet UILabel *resolutionLabel;
@property (weak, nonatomic) IBOutlet UILabel *frameRateLabel;

@end

@implementation DataShareQualityTableViewCel

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
    _paketLossRateLabel.text =  [NSString stringWithFormat:@"%lld",_currentStatisticShowInfo.lossFraction];
    _dalayLabel.text = [NSString stringWithFormat:@"%lld",_currentStatisticShowInfo.delay];
    _jitterLabel.text = [NSString stringWithFormat:@"%lld",_currentStatisticShowInfo.jitter];
    _resolutionLabel.text = _currentStatisticShowInfo.frameSize;
    _frameRateLabel.text = [NSString stringWithFormat:@"%ld",_currentStatisticShowInfo.frameRate];
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
