//
//  ContactListCell.m
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

#import "ContactListCell.h"
#import <TUPIOSSDK/PersonEntity.h>
#import <TUPIOSSDK/EmployeeEntity.h>
#import <TUPContactSDK/EmployeeEntity+ServiceObject.h>
#import "HeadImageView.h"

@interface ContactListCell ()

@property (weak, nonatomic) IBOutlet HeadImageView *headImg;      // head image view
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;          // show person's name
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;        // show person's signature

@end

@implementation ContactListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setPerson:(PersonEntity *)person {
    _person = person;
    self.nameLabel.text = person.name;
    self.detailLabel.text = person.signature;
    [self.headImg setContactEntity:person];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.headImg.layer.cornerRadius = 20.0f;
}

@end
