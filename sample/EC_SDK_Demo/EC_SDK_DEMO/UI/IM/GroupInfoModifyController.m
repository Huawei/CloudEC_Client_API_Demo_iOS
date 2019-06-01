//
//  GroupInfoModifyController.m
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

#import "GroupInfoModifyController.h"
#import "GroupEntity.h"
#import "ECSAppConfig.h"

#import "GroupEntity+ServiceObject.h"

@interface GroupInfoModifyController ()<UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UITextView *modifyTextView;   // modify text view

@end

@implementation GroupInfoModifyController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.automaticallyAdjustsScrollViewInsets =  NO;
    
    [self configSubViews];
}

/**
 This method is used to config subViews
 */
- (void)configSubViews{
    _modifyTextView.text = [self propertyBeforeChanged];
    _modifyTextView.font = [UIFont systemFontOfSize:16.0];
    _modifyTextView.keyboardType = UIKeyboardTypeDefault;
    _modifyTextView.returnKeyType = UIReturnKeyDone;
    _modifyTextView.translatesAutoresizingMaskIntoConstraints = NO;
    _modifyTextView.delegate = self;
    _modifyTextView.userInteractionEnabled = YES;
    [_modifyTextView setEditable:[self isGroupManager]];
    
    UIBarButtonItem *rightBtn = [[UIBarButtonItem alloc]initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(saveGroupName:)];
    self.navigationItem.rightBarButtonItem = rightBtn;
    [rightBtn setEnabled:[self isGroupManager]];
    
    self.title = [self configTitle];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSString *)propertyBeforeChanged {
    switch (_modifyType) {
        case GroupInfoModifyTypeName:
            return _group.name;
            
        case GroupInfoModifyTypeAnnounce:
            return _group.announce;
            
        case GroupInfoModifyTypeIntroduction:
            return _group.intro;
            
        default:
            return nil;
    }
}

- (NSString *)configTitle{
    switch (_modifyType) {
        case GroupInfoModifyTypeName:
            return @"groupName";
            
        case GroupInfoModifyTypeAnnounce:
            return @"Bulletin";
            
        case GroupInfoModifyTypeIntroduction:
            return @"Desc.";
            
        default:
            return nil;
    }
}


/**
 This method is used to judge is self is group manage or not

 @return is group manage or not
 */
-(BOOL)isGroupManager
{
    return [[ECSAppConfig sharedInstance].latestAccount isEqualToString:_group.ownerId];
    return YES;
}

/**
 This method is used to modify message

 @param saveBtn save message
 */
- (void)saveGroupName:(UIBarButtonItem *)saveBtn {

    [self.view endEditing:YES];

    NSString *groupName = _modifyType == GroupInfoModifyTypeName ? _modifyTextView.text : _group.name;
    NSString *groupAnnounce = _modifyType == GroupInfoModifyTypeAnnounce ? _modifyTextView.text : _group.announce;
    NSString *groupIntro = _modifyType == GroupInfoModifyTypeIntroduction ? _modifyTextView.text : _group.intro;
    NSString *groupEnName = _modifyType == GroupInfoModifyTypeName ? groupName : _group.enName;
    
    [_group updateGroupWithName:groupName  enName:groupEnName joinCondition:[_group.joinFlag intValue] announce:groupAnnounce intro:groupIntro completion:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!error) {
                [self.navigationController popViewControllerAnimated:YES];
            }
        });
    }];
}


@end
