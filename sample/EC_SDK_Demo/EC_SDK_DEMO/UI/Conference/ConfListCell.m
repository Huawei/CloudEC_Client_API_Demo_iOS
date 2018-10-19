//
//  ConfListCell.m
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

#import "ConfListCell.h"
//#import "ESpaceUtile.h"

#define CONFLISTCELL_BGCOLOR     [UIColor whiteColor]

#define CONFRUNNING_TITLECOLOR  RGBACOLOR(0x35,0xae,0x00,1)
#define CONFRUNNING_DETAILCOLOR (CONFRUNNING_TITLECOLOR)
#define CONFUNOPEN_TITLECOLOR   RGBACOLOR(0x66,0x66,0x66,1)
#define CONFUNOPEN_DETAILCOLOR  RGBACOLOR(0x99,0x99,0x99,1)
#define CONFCLOSE_TITLECOLOR    RGBACOLOR(0x99,0x99,0x99,1)
#define CONFCLOSE_DETAILCOLOR   RGBACOLOR(0x99,0x99,0x99,1)

#define RGBACOLOR(r,g,b,a) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:(a)]

#define TITLESIZE   17
#define DETAILSIZE  14

#define CELL_H 60
#define LOGO_SIZE 40
#define LOGO_X  12
#define TITLE_LOGO_MARGIN 12

#define TITLE_Y 12
#define TITLE_X (LOGO_X + LOGO_SIZE + TITLE_LOGO_MARGIN)

#define TITLE_DETAIL_MARGIN 7

#define DETAIL_X (TITLE_X)
#define DETAIL_Y (TITLE_Y+TITLESIZE+TITLE_DETAIL_MARGIN)


@interface ConfListCell ()
@property (nonatomic,strong) UILabel *titleLabel;
@property (nonatomic,strong) UILabel *detailLabel;
@property (nonatomic,strong) UIImageView *logo;
@end

@implementation ConfListCell


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(UILabel*)titleLabel{
    if (_titleLabel == nil) {
        _titleLabel = [[UILabel alloc] init];
        [self addSubview:_titleLabel];
    }
    return _titleLabel;
}

-(UILabel*)detailLabel{
    if (_detailLabel == nil) {
        _detailLabel = [[UILabel alloc] init];
        [self addSubview:_detailLabel];
    }
    return _detailLabel;
}

-(UIImageView*)logo{
    if (_logo == nil) {
        _logo = [[UIImageView alloc] init];
        [self addSubview:_logo];
    }
    return _logo;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    
    CGRect bounds = self.bounds;
    
    CGFloat titleW = CGRectGetWidth(bounds) - TITLE_X - LOGO_X;
    if (self.titleLabel) {
        _titleLabel.frame = CGRectMake(TITLE_X, TITLE_Y, titleW, TITLESIZE);
    }
    if (self.detailLabel) {
        _detailLabel.frame = CGRectMake(DETAIL_X, DETAIL_Y, titleW, DETAILSIZE);
    }
    if (self.logo) {
        _logo.frame = CGRectMake(LOGO_X, (CGRectGetHeight(bounds)-LOGO_SIZE)/2, LOGO_SIZE, LOGO_SIZE);
    }
    
}

-(void)setConf:(ConfBaseInfo *)conf{
    _conf = conf;
    self.titleLabel.text = conf.conf_subject;
    self.titleLabel.font = [UIFont systemFontOfSize:TITLESIZE-2];
    
    
    NSString *displayName = conf.scheduser_name;
    NSString *displayMaster = @"";
    if ([displayName length] > 0) {
        displayMaster = [NSString stringWithFormat:@"emcee:%@",displayName];
    }
    
    self.detailLabel.text = [NSString stringWithFormat:@"%@    %@",conf.start_time,displayMaster];
    self.detailLabel.font = [UIFont systemFontOfSize:DETAILSIZE-2];
    
    self.backgroundColor = CONFLISTCELL_BGCOLOR;
    
    NSString *iconName = nil;
    switch (conf.conf_state) {
        case CONF_E_STATE_GOING:
            self.titleLabel.textColor = CONFRUNNING_TITLECOLOR;
            self.detailLabel.textColor = CONFRUNNING_DETAILCOLOR;
            iconName = @"bookconf_running";
            break;
        case CONF_E_STATE_SCHEDULE:
            self.titleLabel.textColor = CONFUNOPEN_TITLECOLOR;
            self.detailLabel.textColor = CONFUNOPEN_DETAILCOLOR;
            iconName = @"bookconf_unopen";
            break;
        case CONF_E_STATE_DESTROYED:
        default:
            self.titleLabel.textColor = CONFCLOSE_TITLECOLOR;
            self.detailLabel.textColor = CONFCLOSE_DETAILCOLOR;
            iconName = @"bookconf_close";
            break;
    }
    
    if ([iconName length] > 0) {
        self.logo.image = [UIImage imageNamed:iconName];
    }
}

-(void)prepareForReuse{
    [super prepareForReuse];
    self.conf = nil;
}

@end
