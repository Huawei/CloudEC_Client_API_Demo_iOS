//
//  ChatSessionCell.m
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

#import "ChatSessionCell.h"
#import "HeadImageView.h"
#import "EmployeeEntity.h"
#import "MessageEntity.h"
#import "Defines.h"

#import "EmployeeEntity+ServiceObject.h"
#import "MessageEntity+ServiceObject.h"
#import "ESpaceDetailMessagParser.h"

@interface ChatSessionCell ()
@property (nonatomic, weak)IBOutlet HeadImageView *headImage;      // head image view
@property (nonatomic, weak)IBOutlet UILabel *nameLabel;            // show name
@property (nonatomic, weak)IBOutlet UILabel *timeLabel;            // show chat time
@property (nonatomic, weak)IBOutlet UILabel *chatMessageLabel;     // show chat message
@property (nonatomic, weak)IBOutlet UILabel *unreadLabel;          // show unread message number
@property (nonatomic ,strong)ChatSessionEntity *session;           // current chat session

@end

@implementation ChatSessionCell

- (void)awakeFromNib {
    [super awakeFromNib];
    _unreadLabel.layer.cornerRadius = 10;
    _unreadLabel.layer.masksToBounds = YES;
    _headImage.layer.cornerRadius = 20;
    _headImage.layer.masksToBounds = YES;
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setChatSession:(ChatSessionEntity *)session
{
    if (session == self.session) {
        return;
    }
    
    [_session removeObserver:self forKeyPath:@"unreadCount"];
    [_session removeObserver:self forKeyPath:@"target.uiDisplayName"];
    [_session removeObserver:self forKeyPath:@"latestMessage"];
    [_session removeObserver:self forKeyPath:@"timestamp"];
    
    self.session = session;
    
    [_session addObserver:self forKeyPath:@"unreadCount" options:NSKeyValueObservingOptionNew context:nil];
    [_session addObserver:self forKeyPath:@"target.uiDisplayName" options:NSKeyValueObservingOptionNew context:nil];
    [_session addObserver:self forKeyPath:@"latestMessage" options:NSKeyValueObservingOptionNew context:nil];
    [_session addObserver:self forKeyPath:@"timestamp" options:NSKeyValueObservingOptionNew context:nil];
    
    if ([self.session.target isKindOfClass:[EmployeeEntity class]]) {
        EmployeeEntity *employee = (EmployeeEntity *)_session.target;
        if ([employee needReload]) {
            [employee reloadDetail];
        }
    }
    
    [self.headImage setContactEntity:_session.target];
    self.nameLabel.text = _session.target.uiDisplayName;
    [self updateUnreadLabel];
    [self updateChatMessage];
    [self updateTimeLabel];
}

- (void)updateUnreadLabel
{
    [_unreadLabel setHidden:(_session.unreadCount.integerValue == 0)];
    self.unreadLabel.text = [NSString stringWithFormat:@"%ld", (long)_session.unreadCount.integerValue];
}

- (void)updateTimeLabel
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM-dd HH:mm"];
    NSString *dateStr = [formatter stringFromDate:_session.timestamp];
    self.timeLabel.text = dateStr;
}

- (void)updateChatMessage
{
    MessageEntity* latestMessage = _session.latestMessage;
    ChatSessionEntity* chatSession = (ChatSessionEntity*)self.session;
    if ([chatSession.draft length]) {
        NSString* draftString = [NSString stringWithFormat:@"%@%@", @"Draft:", chatSession.draft];
        NSMutableAttributedString* attText = [[NSMutableAttributedString alloc] initWithString:draftString];
        [attText addAttribute:NSForegroundColorAttributeName
                        value:[UIColor redColor]
                        range:[draftString rangeOfString:@"Draft:"]];
        self.chatMessageLabel.attributedText = [[NSAttributedString alloc] initWithAttributedString:attText];
    }
    else if (latestMessage){
        if ([chatSession.target isGroupEntity]) {
            if ([latestMessage fromSelf]) {
                self.chatMessageLabel.text = [NSString stringWithFormat:@"Me:%@", [self titleForMessage:latestMessage]];
            } else {
                EmployeeEntity *temp = (EmployeeEntity *)latestMessage.from;
                if (temp) {
                    if (ESpaceMessageFlagRecalled == [(ChatMessageEntity *)latestMessage flag].integerValue) {
                        self.chatMessageLabel.text = [self titleForMessage:latestMessage];
                    }
                    else{
                        self.chatMessageLabel.text = [NSString stringWithFormat:@"%@:%@", [temp uiDisplayName], [self titleForMessage:latestMessage]];
                    }
                }
                if ([temp needReload]) {
                    [temp reloadDetail];
                }
            }
        }
        else {
            self.chatMessageLabel.text = [self titleForMessage:latestMessage];
        }
    }
    else{
        self.chatMessageLabel.text = nil;
    }
}

- (NSString*) titleForMessage:(MessageEntity*) message {
    __block NSString* string = message.body;
    NSInteger contentType = message.contentType.unsignedIntegerValue;
    if (contentType == ESpaceTextContentType) {
        if (!string) {
            return nil;
        }
        NSString* emotion = @"[Emoticon]";
        NSArray* emotionMatches = [[ESpaceDetailMessagParser sharedInstance] emotionMatches:string];

        [emotionMatches enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSTextCheckingResult* result = obj;
            string = [string stringByReplacingCharactersInRange:result.range withString:emotion];
        }];
    } else if (contentType == ESpaceAudioContentType) {
        string = @"[Audio]";
    } else if (contentType == ESpaceVideoContentType) {
        string = @"[Video]";
    } else if (contentType == ESpaceImageContentType) {
        string = @"[Picture]";
    } else if (contentType == ESpaceFileContentType) {
        string = @"[File]";
    }
    else {
        string = NSLocalizedString(@"unsupported_message_type", @"未知消息类型，您当前版本不支持，请您升级为最新版本");
    }
    
    return string;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([keyPath isEqualToString:@"unreadCount"]) {
            [self updateUnreadLabel];
        }
        else if ([keyPath isEqualToString:@"target.uiDisplayName"]) {
            self.nameLabel.text = _session.target.uiDisplayName;
        }
        else if ([keyPath isEqualToString:@"latestMessage"]) {
            [self updateChatMessage];
        }
        else if ([keyPath isEqualToString:@"timestamp"]) {
            [self updateTimeLabel];
        }
    });
    
}

- (void)dealloc
{
    [_session removeObserver:self forKeyPath:@"unreadCount"];
    [_session removeObserver:self forKeyPath:@"target.uiDisplayName"];
    [_session removeObserver:self forKeyPath:@"latestMessage"];
    [_session removeObserver:self forKeyPath:@"timestamp"];
}

@end
