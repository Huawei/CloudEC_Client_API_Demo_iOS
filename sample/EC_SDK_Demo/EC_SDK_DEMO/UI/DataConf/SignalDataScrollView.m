//
//  SignalDataScrollView.m
//  EC_SDK_DEMO
//
//  Created by huawei on 2019/8/27.
//  Copyright © 2019年 cWX160907. All rights reserved.
//

#import "SignalDataScrollView.h"
#import "AudioQualityTableViewCell.h"
#import "VideoAndDataQualityTableViewCell.h"
#import "DataShareQualityTableViewCel.h"

@interface SignalDataScrollView ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *audioQualityTableView;
@property (nonatomic, strong) UITableView *videoQualityTableView;
@property (nonatomic, strong) UITableView *dataQualityTableView;

@end

@implementation SignalDataScrollView

- (UITableView *)audioQualityTableView {
    if (nil == _audioQualityTableView) {
        CGRect frame = CGRectMake(5, 5, 700, 150);
        _audioQualityTableView = [[UITableView alloc]initWithFrame:frame];
        _audioQualityTableView.backgroundColor = [UIColor clearColor];
        _audioQualityTableView.delegate = self;
        _audioQualityTableView.dataSource = self;
        _audioQualityTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        _audioQualityTableView.layer.masksToBounds = YES;
        _audioQualityTableView.layer.cornerRadius = 5;
        _audioQualityTableView.tableFooterView = [[UIView alloc] init];
    }
    
    return _audioQualityTableView;
}

- (UITableView *)videoQualityTableView {
    if (nil == _videoQualityTableView) {
        CGRect frame = CGRectMake(5, 150, 950, 150);
        _videoQualityTableView = [[UITableView alloc]initWithFrame:frame];
        _videoQualityTableView.backgroundColor = [UIColor clearColor];
        _videoQualityTableView.delegate = self;
        _videoQualityTableView.dataSource = self;
        _videoQualityTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        _videoQualityTableView.layer.masksToBounds = YES;
        _videoQualityTableView.layer.cornerRadius = 5;
        _videoQualityTableView.tableFooterView = [[UIView alloc] init];
    }
    
    return _videoQualityTableView;
}

- (UITableView *)dataQualityTableView {
    if (nil == _dataQualityTableView) {
        CGRect frame = CGRectMake(5, 305, 950, 150);
        _dataQualityTableView = [[UITableView alloc]initWithFrame:frame];
        _dataQualityTableView.backgroundColor = [UIColor clearColor];
        _dataQualityTableView.delegate = self;
        _dataQualityTableView.dataSource = self;
        _dataQualityTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        _dataQualityTableView.layer.masksToBounds = YES;
        _dataQualityTableView.layer.cornerRadius = 5;
        _dataQualityTableView.tableFooterView = [[UIView alloc] init];
    }
    
    return _dataQualityTableView;
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.scrollEnabled = YES;
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        self.alwaysBounceVertical = YES;
        self.alwaysBounceHorizontal = YES;
        //        self.userInteractionEnabled = YES;
        //        self.multipleTouchEnabled = NO;
        //        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        //        self.pagingEnabled = YES;
        self.backgroundColor = [UIColor clearColor];
        [self setContentSize:CGSizeMake(950, 500)];
        
        [self.audioQualityTableView registerNib:[UINib nibWithNibName:@"AudioQualityTableViewCell" bundle:nil] forCellReuseIdentifier:@"AudioQualityTableViewCell"];
        [self.videoQualityTableView registerNib:[UINib nibWithNibName:@"VideoAndDataQualityTableViewCell" bundle:nil] forCellReuseIdentifier:@"VideoAndDataQualityTableViewCell"];
        [self.dataQualityTableView registerNib:[UINib nibWithNibName:@"DataShareQualityTableViewCel" bundle:nil] forCellReuseIdentifier:@"DataShareQualityTableViewCel"];
        
        [self addSubview:self.audioQualityTableView];
        self.audioQualityTableView.tableHeaderView = [[UIView alloc] init];
        UILabel *headlabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, 35)];
        headlabel.text = @"Audio Quality";
        
        UIView *audioView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 650, 70)];
        audioView.backgroundColor = [UIColor whiteColor];
        UILabel *label_11 = [[UILabel alloc] initWithFrame:CGRectMake(150, 40, 110, 25)];
        label_11.text = @"bandwidth(kbps)";
        label_11.font = [UIFont systemFontOfSize:12.0];
        label_11.textAlignment = NSTextAlignmentCenter;
        UILabel *label_22 = [[UILabel alloc] initWithFrame:CGRectMake(270, 40, 110, 25)];
        label_22.text = @"packet loss rate(%)";
        label_22.font = [UIFont systemFontOfSize:12.0];
        label_22.textAlignment = NSTextAlignmentCenter;
        UILabel *label_33 = [[UILabel alloc] initWithFrame:CGRectMake(390, 40, 100, 25)];
        label_33.text = @"delay(ms)";
        label_33.font = [UIFont systemFontOfSize:12.0];
        label_33.textAlignment = NSTextAlignmentCenter;
        UILabel *label_44 = [[UILabel alloc] initWithFrame:CGRectMake(500, 40, 100, 25)];
        label_44.text = @"jitter(ms)";
        label_44.font = [UIFont systemFontOfSize:12.0];
        label_44.textAlignment = NSTextAlignmentCenter;
        [audioView addSubview:headlabel];
        [audioView addSubview:label_11];
        [audioView addSubview:label_22];
        [audioView addSubview:label_33];
        [audioView addSubview:label_44];

        self.audioQualityTableView.tableHeaderView = audioView;

        [self addSubview:self.videoQualityTableView];
        self.videoQualityTableView.tableHeaderView = [[UIView alloc] init];
        UILabel *videoHeadlabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, 35)];
        videoHeadlabel.text = @"Video Quality";
        UIView *videoView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 900, 70)];
        videoView.backgroundColor = [UIColor whiteColor];
        
        UILabel *label_1 = [[UILabel alloc] initWithFrame:CGRectMake(150, 40, 110, 25)];
        label_1.text = @"bandwidth(kbps)";
        label_1.font = [UIFont systemFontOfSize:12.0];
        label_1.textAlignment = NSTextAlignmentCenter;
        UILabel *label_2 = [[UILabel alloc] initWithFrame:CGRectMake(270, 40, 110, 25)];
        label_2.text = @"packet loss rate(%)";
        label_2.font = [UIFont systemFontOfSize:12.0];
        label_2.textAlignment = NSTextAlignmentCenter;
        UILabel *label_3 = [[UILabel alloc] initWithFrame:CGRectMake(390, 40, 100, 25)];
        label_3.text = @"delay(ms)";
        label_3.font = [UIFont systemFontOfSize:12.0];
        label_3.textAlignment = NSTextAlignmentCenter;
        UILabel *label_4 = [[UILabel alloc] initWithFrame:CGRectMake(500, 40, 100, 25)];
        label_4.text = @"jitter(ms)";
        label_4.font = [UIFont systemFontOfSize:12.0];
        label_4.textAlignment = NSTextAlignmentCenter;
        UILabel *label_5 = [[UILabel alloc] initWithFrame:CGRectMake(610, 40, 100, 25)];
        label_5.text = @"resolution";
        label_5.font = [UIFont systemFontOfSize:12.0];
        label_5.textAlignment = NSTextAlignmentCenter;
        UILabel *label_6 = [[UILabel alloc] initWithFrame:CGRectMake(720, 40, 100, 25)];
        label_6.text = @"frame rate(fps)";
        label_6.font = [UIFont systemFontOfSize:12.0];
        label_5.textAlignment = NSTextAlignmentCenter;
        [videoView addSubview:videoHeadlabel];
        [videoView addSubview:label_1];
        [videoView addSubview:label_2];
        [videoView addSubview:label_3];
        [videoView addSubview:label_4];
        [videoView addSubview:label_5];
        [videoView addSubview:label_6];
        
        self.videoQualityTableView.tableHeaderView = videoView;
        
        [self addSubview:self.dataQualityTableView];
        UILabel *dataHeadlabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, 35)];
        dataHeadlabel.text = @"data Quality";
        UIView *dataView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 900, 70)];
        dataView.backgroundColor = [UIColor whiteColor];
        UILabel *label_111 = [[UILabel alloc] initWithFrame:CGRectMake(150, 40, 110, 25)];
        label_111.text = @"bandwidth(kbps)";
        label_111.font = [UIFont systemFontOfSize:12.0];
        label_111.textAlignment = NSTextAlignmentCenter;
        UILabel *label_222 = [[UILabel alloc] initWithFrame:CGRectMake(270, 40, 110, 25)];
        label_222.text = @"packet loss rate(%)";
        label_222.font = [UIFont systemFontOfSize:12.0];
        label_222.textAlignment = NSTextAlignmentCenter;
        UILabel *label_333 = [[UILabel alloc] initWithFrame:CGRectMake(390, 40, 100, 25)];
        label_333.text = @"delay(ms)";
        label_333.font = [UIFont systemFontOfSize:12.0];
        label_333.textAlignment = NSTextAlignmentCenter;
        UILabel *label_444 = [[UILabel alloc] initWithFrame:CGRectMake(500, 40, 100, 25)];
        label_444.text = @"jitter(ms)";
        label_444.font = [UIFont systemFontOfSize:12.0];
        label_444.textAlignment = NSTextAlignmentCenter;
        UILabel *label_555 = [[UILabel alloc] initWithFrame:CGRectMake(610, 40, 100, 25)];
        label_555.text = @"resolution";
        label_555.font = [UIFont systemFontOfSize:12.0];
        label_555.textAlignment = NSTextAlignmentCenter;
        UILabel *label_666 = [[UILabel alloc] initWithFrame:CGRectMake(720, 40, 100, 25)];
        label_666.text = @"frame rate(fps)";
        label_666.font = [UIFont systemFontOfSize:12.0];
        label_666.textAlignment = NSTextAlignmentCenter;
        
        [dataView addSubview:dataHeadlabel];
        [dataView addSubview:label_111];
        [dataView addSubview:label_222];
        [dataView addSubview:label_333];
        [dataView addSubview:label_444];
        [dataView addSubview:label_555];
        [dataView addSubview:label_666];
        self.dataQualityTableView.tableHeaderView = dataView;
        
    }
    return self;
}

- (void)setAudioInfoArray:(NSArray *)audioInfoArray
{
    _audioInfoArray = audioInfoArray;
    if (_audioInfoArray != nil) {
        [self.audioQualityTableView reloadData];
    }
}

-(void)setVideoInfoArray:(NSArray *)videoInfoArray
{
    _videoInfoArray = videoInfoArray;
    if (_videoInfoArray != nil) {
        [self.videoQualityTableView reloadData];
    }
}

- (void)setDataInfoArray:(NSArray *)dataInfoArray
{
    _dataInfoArray = dataInfoArray;
    if (_dataInfoArray != nil) {
        [self.dataQualityTableView reloadData];
    }
}

-(void)setSingleStream:(VideoStreamInfo *)singleStream
{
    
}

-(void)setMutiStreamArray:(NSArray *)mutiStreamArray
{
    
}

- (void)setAudioStreamInfo:(AudioStreamInfo *)audioStreamInfo
{
    
}

#pragma mark - drawing method
//- (void)drawRect:(CGRect)rect {
//    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
//
//    if (self.arrowType==ECMarkupToolboxPopoverViewArrowTypeUp) {
//        [bezierPath moveToPoint:CGPointMake(0, CGRectGetHeight(rect))]; //move to view's origin
//        [bezierPath addLineToPoint:CGPointMake(0, CGRectGetHeight(rect) * 0.1)]; //top right corner
//        [bezierPath addLineToPoint:CGPointMake(CGRectGetWidth(rect) * 0.3, CGRectGetHeight(rect) * 0.1)];
//        [bezierPath addLineToPoint:CGPointMake(CGRectGetWidth(rect) * 0.5, CGRectGetHeight(rect) * 0.03)];
//        [bezierPath addLineToPoint:CGPointMake(CGRectGetWidth(rect) * 0.7, CGRectGetHeight(rect) * 0.1)];
//        [bezierPath addLineToPoint:CGPointMake(CGRectGetWidth(rect), CGRectGetHeight(rect) * 0.1)];
//        [bezierPath addLineToPoint:CGPointMake(CGRectGetWidth(rect), CGRectGetHeight(rect))]; //lower left corner
//        [bezierPath closePath];
//    }else{
//        [bezierPath moveToPoint:CGPointZero]; //move to view's origin
//        [bezierPath addLineToPoint:CGPointMake(CGRectGetWidth(rect), 0)]; //top right corner
//        [bezierPath addLineToPoint:CGPointMake(CGRectGetWidth(rect), CGRectGetHeight(rect) * 0.9)]; //lower right corner - arrow height (10% of height)
//        [bezierPath addLineToPoint:CGPointMake(CGRectGetWidth(rect) * 0.7, CGRectGetHeight(rect) * 0.9)]; //+10% from bottom edge middle
//        [bezierPath addLineToPoint:CGPointMake(CGRectGetWidth(rect) * 0.5, CGRectGetHeight(rect) * 0.97)]; //arrow vertex
//        [bezierPath addLineToPoint:CGPointMake(CGRectGetWidth(rect) * 0.3, CGRectGetHeight(rect) * 0.9)]; //-10% from bottom edge middle
//        [bezierPath addLineToPoint:CGPointMake(0, CGRectGetHeight(rect) * 0.9)]; //lower left corner
//        [bezierPath closePath];
//    }
//    self.arrowLayer.path = bezierPath.CGPath;
//}


#pragma mark - UITableView delegate and data source methods
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 70.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [[UIView alloc] initWithFrame:CGRectZero];
}


- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 1.0;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 35.0;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger count = 2;
    if (tableView == _audioQualityTableView) {
        count = _audioInfoArray.count;
    }
    if (tableView == _videoQualityTableView) {
        count = _videoInfoArray.count;
    }
    if (tableView == _dataQualityTableView) {
        count = _dataInfoArray.count;
    }
    return count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UITableViewCell class])];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:NSStringFromClass([UITableViewCell class])];
    }
    
    if (tableView == _audioQualityTableView) {
        AudioQualityTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AudioQualityTableViewCell"];
        StatisticShowInfo *statisticShowInfo = _audioInfoArray[indexPath.row];
        cell.currentStatisticShowInfo = statisticShowInfo;
        return cell;
    }
    if (tableView == _videoQualityTableView) {
        VideoAndDataQualityTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"VideoAndDataQualityTableViewCell"];
        StatisticShowInfo *statisticShowInfo = _videoInfoArray[indexPath.row];
        cell.currentStatisticShowInfo = statisticShowInfo;
        return cell;
    }
    if (tableView == _dataQualityTableView) {
        DataShareQualityTableViewCel *cell = [tableView dequeueReusableCellWithIdentifier:@"DataShareQualityTableViewCel"];
        StatisticShowInfo *statisticShowInfo = _dataInfoArray[indexPath.row];
        cell.currentStatisticShowInfo = statisticShowInfo;
        return cell;
    }
    

    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//    [self.delegate markupToolboxPopoverView:self didSelectOptionAtIndex:indexPath.row];
}




@end
