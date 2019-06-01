//
//  GroupListCell.m
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

#import "GroupListCell.h"
#import "HeadImageView.h"
#import "GroupEntity.h"
#import "Defines.h"

@interface GroupListCell ()
@property (weak, nonatomic) IBOutlet HeadImageView *headImageView;   // head image view
@property (weak, nonatomic) IBOutlet UILabel *groupNameLabel;        // show group name
@property (weak, nonatomic) IBOutlet UIImageView *groupTypeImage;    // show groupType image view

@end

@implementation GroupListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setGruopEntity:(GroupEntity *)gruopEntity
{
    _gruopEntity = gruopEntity;
    _groupNameLabel.text = gruopEntity.name;
    [_headImageView  setContactEntity:gruopEntity];
    _groupTypeImage.image = [gruopEntity.groupType integerValue] == ECSFixGroup ? [UIImage imageNamed:@"icon_group_lock"] : nil;
    
}

@end
