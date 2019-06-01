//
//  GroupCell.m
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

#import "GroupCell.h"
#import "EmployeeCategoryEntity.h"

@interface GroupCell ()

@property (weak, nonatomic) IBOutlet UIImageView *groupKindImg;        // kind of group image
@property (weak, nonatomic) IBOutlet UILabel *groupKindLabel;          // show group name
@property (weak, nonatomic) IBOutlet UILabel *currentContactGroup;     // current contact group

@end

@implementation GroupCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setIndex:(NSInteger)index {
    _index = index;
    switch (index) {
        case GROUP_KIND_CHAT:
            self.groupKindLabel.text = @"Chat Groups";
            self.groupKindImg.image = [UIImage imageNamed:@"chat_groups"];
            break;
        case GROUP_KIND_CONTACT:
            self.groupKindLabel.text = @"Contact Groups";
            self.groupKindImg.image = [UIImage imageNamed:@"contact_groups"];
            break;
        case E_ASSISTANT:
            self.groupKindLabel.text = @"E Assistant";
            self.groupKindImg.image = [UIImage imageNamed:@"e_assistant"];
            break;
            
        default:
            break;
    }
}

- (void)setCategory:(EmployeeCategoryEntity *)category {
    if (_index == GROUP_KIND_CONTACT) {
        _category = category;
        self.currentContactGroup.text = category.name;
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.groupKindImg.layer.cornerRadius = 20.0f;
}

@end
