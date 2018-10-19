//
//  MemberCollectionViewCell.m
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

#import "MemberCollectionViewCell.h"
#import <TUPIOSSDK/PersonEntity.h>
#import "HeadImageView.h"

@interface MemberCollectionViewCell()
@property (weak, nonatomic) IBOutlet HeadImageView *headImageView;    // head image view
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;              // show name

@end

@implementation MemberCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

-(void)setPerson:(PersonEntity *)person
{
    _person = person;
    [_headImageView setContactEntity:person];
    _nameLabel.text = person.name;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    _headImageView.layer.cornerRadius = 25.0;
}

@end
