//
//  ChatMessageCell.m
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

#import "ChatMessageCell.h"
#import "ContactEntity.h"
#import "ChatMessageEntity.h"
#import "Defines.h"
#import "ESpaceContactService.h"
#import "ECSAppConfig.h"
#import "GroupEntity.h"

@interface ChatMessageCell()<UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIMenuController *menu;
@property (nonatomic, strong) UILongPressGestureRecognizer* longPressGesture;
@end

@implementation ChatMessageCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    _bubbleImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(_msgBottomView.frame), CGRectGetHeight(_msgBottomView.frame))];
    [_bubbleImageView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    UIImage *image = [UIImage imageNamed:@"bubbleother_normal"];
    image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    _bubbleImageView.image = image;
    [_msgBottomView addSubview:_bubbleImageView];
    [_msgBottomView sendSubviewToBack:_bubbleImageView];
    
    self.userInteractionEnabled = YES;
    _longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressAction:)];
    _longPressGesture.delegate = self;
    [self.msgBottomView addGestureRecognizer:_longPressGesture];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onMenuControllerDidHide) name:UIMenuControllerDidHideMenuNotification object:nil];
    
    _headImage.layer.cornerRadius = 20.f;
    _headImage.layer.masksToBounds = YES;
}

- (void)onMenuControllerDidHide {
    self.userInteractionEnabled = YES;
}

- (void)longPressAction:(UILongPressGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateBegan) {
        [self showMessageMenu];
    }
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    if (action == @selector(recallMsg:)) {
        return YES;
    }else if (action == @selector(deleteMsg:)){
        return YES;
    }
    return NO;
}
- (void)showMessageMenu {
    BOOL firstResp = [self becomeFirstResponder];
    if (firstResp) {
        UIView *targetView = _msgBottomView;
        _menu = [UIMenuController sharedMenuController];
        [_menu setTargetRect:targetView.bounds inView:targetView];
        
        UIMenuItem *moreItem = [[UIMenuItem alloc]initWithTitle:@"更多…" action:@selector(more:)];
        UIMenuItem *recallItem = [[UIMenuItem alloc] initWithTitle:@"撤回" action:@selector(recallMsg:)];
        UIMenuItem *deleteItem = [[UIMenuItem alloc] initWithTitle:@"删除" action:@selector(deleteMsg:)];
        [_menu setMenuItems:@[recallItem,deleteItem,moreItem]];
        
        [_menu setMenuVisible:YES animated:YES];
    }
}

- (void)recallMsg:(id)sender
{
    TsdkMsgWithDrawReqParam* withDrawReqParam = [[TsdkMsgWithDrawReqParam alloc] init];
    withDrawReqParam.origin = ((EmployeeEntity *)_message.from).account;
    withDrawReqParam.originname = ((EmployeeEntity *)_message.from).name;
    
    //jl todo
    if ([_message.to isKindOfClass:[EmployeeEntity class]]) {
        withDrawReqParam.withdrawMsgType = TSDK_E_CHAT_MSG_BASE_TYPE_P2P_MSG;
        withDrawReqParam.target = ((EmployeeEntity *)_message.to).account;
    }else{
        withDrawReqParam.withdrawMsgType = TSDK_E_CHAT_MSG_BASE_TYPE_GROUP_MSG;
        withDrawReqParam.target = ((GroupEntity *)_message.to).contactId;
        withDrawReqParam.groupName = ((GroupEntity *)_message.to).name;
    }
    
    withDrawReqParam.withdrawMsgCount = 1;
    withDrawReqParam.isIncludeLastMsg = NO;
    
    NSMutableArray *msgList = [[NSMutableArray alloc] init];
    TsdkMsgBaseInfo* baseInfo = [[TsdkMsgBaseInfo alloc] init];
    baseInfo.msgId = [_message.messageId longLongValue];
    [msgList addObject:baseInfo];
    withDrawReqParam.msgList = [NSArray arrayWithArray:msgList];
    
    [[ESpaceContactService sharedInstance] withDrawMessageParam:withDrawReqParam];
}

- (void)deleteMsg:(id)sender
{
    TsdkDeleteHistoryMsgParam * deleteParam = [[TsdkDeleteHistoryMsgParam alloc] init];
    
    deleteParam.opType = TSDK_E_DEl_HISTORY_CHAT_MSG_SINGLE;
    
    //jl todo
    if ([_message.to isKindOfClass:[EmployeeEntity class]]) {
        deleteParam.msgType = TSDK_E_CHAT_MSG_BASE_TYPE_P2P_MSG;
        NSString *currentAccount = [ECSAppConfig sharedInstance].currentUser.account;
        NSString *fromAccount = ((EmployeeEntity *)_message.from).account;
        NSString *toAccount = ((EmployeeEntity *)_message.to).account;
        NSString *deleteAccount = fromAccount;
        if ([fromAccount isEqualToString:currentAccount]) {
            deleteAccount = toAccount;
        }
        deleteParam.account = deleteAccount;
    }else{
        deleteParam.msgType = TSDK_E_CHAT_MSG_BASE_TYPE_GROUP_MSG;
        GroupEntity * group = (GroupEntity *)_message.to;
        deleteParam.account = group.contactId;
    }
    
    NSMutableArray *msgList = [[NSMutableArray alloc] init];
    TsdkMsgBaseInfo *baseInfo = [[TsdkMsgBaseInfo alloc] init];
    baseInfo.msgId = [_message.messageId longLongValue];;
    [msgList addObject:baseInfo];
    deleteParam.msgIdList = [NSArray arrayWithArray:msgList];
    deleteParam.count = msgList.count;
    
    [[ESpaceContactService sharedInstance] deleteHistoryMessageWithParam:deleteParam];
}

- (void)more:(id)sender
{
    
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (CGFloat)cellHeightForChatMessage:(ChatMessageEntity *)entity
{
    return 0;
}

- (void)setMessage:(ChatMessageEntity *)message
{
    [_message removeObserver:self forKeyPath:@"transferStatus"];
    _message = message;
    [_message addObserver:self forKeyPath:@"transferStatus" options:NSKeyValueObservingOptionNew context:nil];
    
    
    _nameLabel.text = message.from.uiDisplayName;
    [_headImage setContactEntity:message.from];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM-dd HH:mm"];
    NSString *dateStr = [formatter stringFromDate:message.receiveTimestamp];
    self.timeLabel.text = dateStr;
    
    [self updateTransferStatus];
}


/**
 This method is used to update activity view and status image view
 */
- (void)updateTransferStatus
{
    switch (_message.transferStatus.integerValue) {
        case ESpaceMsgStatusSending:
        {
            [_activity setHidden:NO];
            [_activity startAnimating];
            [_statusImg setHidden:YES];
            break;
        }
        case ESpaceMsgStatusSended:
        {
            [_activity setHidden:YES];
            [_statusImg setHidden:YES];
            break;
        }
        case ESpaceMsgStatusSendFailed:
        case ESpaceMsgStatusSendCancelled:
        {
            [_activity setHidden:YES];
            [_statusImg setHidden:NO];
            break;
        }
        default:
            [_activity setHidden:YES];
            [_statusImg setHidden:YES];
            break;
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    __weak typeof(self) weakSelf = self;
    if ([keyPath isEqualToString:@"transferStatus"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf updateTransferStatus];
        });
    }
}

- (void)dealloc
{
    [_message removeObserver:self forKeyPath:@"transferStatus"];
}

@end
