//
//  AttendeeListCell.m
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

#import "AttendeeListCell.h"
//#import "AttendeeEntity+ServiceObject.h"
//#import "EmployeeEntity+ServiceObject.h"
//#import "ConferenceService.h"
#import "ManagerService.h"
#import "ConfAttendeeInConf.h"

#define USER_HEAD_IMAGE_WIDTH 40
#define USER_HEAD_IMAGE_HEIGHT 40
#define RGBACOLOR(r,g,b,a) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:(a)]
#define dispatch_async_main_safe(block) \
if ([NSThread isMainThread]) {\
block();\
} else {\
dispatch_async(dispatch_get_main_queue(), block);\
}

@interface AttendeeListCell ()
@property (nonatomic, strong) IBOutlet UIImageView          *roleIconView;
@property (nonatomic, strong) IBOutlet UILabel              *topLabel;
@property (nonatomic, strong) IBOutlet UILabel              *bottomLabel;
@property (nonatomic, strong) IBOutlet UIImageView          *voiceStatusView;
@property (nonatomic, strong) IBOutlet UIImageView          *dataConfStatusView;
@property (nonatomic, strong) IBOutlet UIImageView          *presenterIconView;
@property (nonatomic, strong) IBOutlet UIImageView          *handUpView;
@property (weak, nonatomic) IBOutlet UIImageView *speakReportView;
@end

@implementation AttendeeListCell

- (void)removeFromSuperview
{
    [self stopInvitingAnimation];
    [super removeFromSuperview];
}

- (void)dealloc
{
    [self stopInvitingAnimation];
    self.attendee = nil;
}

- (BOOL)isSelf
{
    NSString *sipAccount = [ManagerService callService].sipAccount;
    NSArray *array = [sipAccount componentsSeparatedByString:@"@"];
    NSString *selfNumber = array[0];
    if ([ManagerService confService].selfJoinNumber) {
        selfNumber = [ManagerService confService].selfJoinNumber;
    }
    return [selfNumber isEqualToString:self.attendee.number];
}

- (void)updateMediaStatus
{
    if (self.attendee.isJoinDataconf) {
        [self.dataConfStatusView setHidden:NO];
    }
    else {
        [self.dataConfStatusView setHidden:YES];
    }
    
}

- (void)updateName
{
    NSString *strName = [self.attendee name].length == 0 ? self.attendee.number : self.attendee.name;
    self.topLabel.text = [self isSelf] ? [NSString stringWithFormat:@"%@(%@)", strName, NSLocalizedString(@"me", @"我")] : strName;
    self.bottomLabel.text = self.attendee.number;
}


- (void)updateStatus
{
    self.handUpView.hidden = !self.attendee.hand_state;
    
    NSString *strImageName = nil;
    switch (self.attendee.state) {
        case ATTENDEE_STATUS_CALLING:
        case ATTENDEE_STATUS_JOINING:{
            [self startInvitingAnimation];
            return;
        }
        case ATTENDEE_STATUS_IN_CONF: {
            strImageName = @"attendee_in";
            break;
        }
        case ATTENDEE_STATUS_BUSY:
        case ATTENDEE_STATUS_REJECT:
        case ATTENDEE_STATUS_CALL_FAILED:
        case ATTENDEE_STATUS_NO_ANSWER:
        case ATTENDEE_STATUS_NO_EXIST:
        case ATTENDEE_STATUS_LEAVED: {
            strImageName = @"attendee_leave";
            break;
        }
        default:
            break;
    }
    [self stopInvitingAnimation];
    
    if(self.attendee.is_mute && ![strImageName isEqualToString:@"attendee_leave"]){
        strImageName = @"attendee_mute";
    }
    
    if (nil == strImageName) {
        return;
    }
    self.voiceStatusView.image = [UIImage imageNamed:strImageName];
}

- (void)updateRole
{
    BOOL isPresent = self.attendee.isPresent;
    self.presenterIconView.hidden = !isPresent;
    
    BOOL isChairman = self.attendee.role == CONF_ROLE_CHAIRMAN;
    self.roleIconView.hidden = !isChairman;
}


- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    
    if ((ATTENDEE_STATUS_JOINING == self.attendee.state || ATTENDEE_STATUS_CALLING == self.attendee.state)
        && !self.voiceStatusView.isAnimating){
        [self.voiceStatusView startAnimating];
    }
}

- (void)stopInvitingAnimation
{
    if (self.voiceStatusView.isAnimating) {
        [self.voiceStatusView stopAnimating];
    }
}

- (void)startInvitingAnimation
{
    [self stopInvitingAnimation];
    
    NSMutableArray *images = [NSMutableArray array];
    for (int i=1; i<=3; i++) {
        NSString *strImageName = [NSString stringWithFormat:@"attendee_inviting%02d", i];
        UIImage *image = [UIImage imageNamed:strImageName];
        if (nil == image) {
            continue;
        }
        [images addObject:image];
    }
    self.voiceStatusView.highlighted = NO;
    self.voiceStatusView.image = [UIImage imageNamed:@"attendee_inviting01"];
    self.voiceStatusView.animationImages = images;
    self.voiceStatusView.highlightedAnimationImages = images;
    self.voiceStatusView.animationDuration = 2.25;
    [self.voiceStatusView startAnimating];
}

- (void)updateDisplayInfo
{
    [self updateName];
    [self updateStatus];
    [self updateMediaStatus];
    [self updateRole];
}

-(void)setAttendee:(ConfAttendeeInConf *)attendee
{
    _attendee = attendee;
    if (nil != _attendee) {
        [self updateDisplayInfo];
        [self setNeedsUpdateConstraints];
    }
    
}

- (void)setIsSpeaking:(BOOL)isSpeaking
{
    _isSpeaking = isSpeaking;
    self.speakReportView.hidden = !isSpeaking;
}

- (void)prepareForReuse{
    [super prepareForReuse];
    self.attendee = nil;
    [self stopInvitingAnimation];
    self.topLabel.text = self.bottomLabel.text = nil;
}

@end
