//
//  ChatMessageCell.h
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

#import <UIKit/UIKit.h>
#import "HeadImageView.h"
#import <TUPIOSSDK/TUPIOSSDK.h>

@protocol ChatMessageUMDelegate <NSObject>

@optional


/**
 This method is used to show image when finish load

 @param message ChatMessageEntity
 */
- (void)messageUmResourceDidFinishLoad:(ChatMessageEntity *)message;

/**
 This method is used to preview image

 @param message ChatMessageEntity
 */
- (void)clickToPreviewUM:(ChatMessageEntity *)message;


/**
 This method is used to preview file

 @param localPath localPath
 */
- (void)clickToPreviewFileWithPath:(NSString *)localPath;

@end

@interface ChatMessageCell : UITableViewCell

@property (nonatomic, weak)IBOutlet UILabel *nameLabel;                      // show name
@property (nonatomic, strong)UIImageView *bubbleImageView;                   // show bubbke image
@property (nonatomic, weak)IBOutlet UIView *msgBottomView;                   // show bottom view
@property (nonatomic, weak)IBOutlet UIActivityIndicatorView *activity;       // activity view
@property (nonatomic, weak)IBOutlet UIImageView *statusImg;                  // show status image
@property (nonatomic, weak)IBOutlet HeadImageView *headImage;                // show head image view
@property (nonatomic, weak)IBOutlet UILabel *timeLabel;                      // show time
@property (nonatomic, weak)IBOutlet NSLayoutConstraint *textWidthConstraint;
@property (nonatomic, weak)IBOutlet NSLayoutConstraint *textHeighConstraint;
@property (nonatomic, weak)id<ChatMessageUMDelegate> delegate;

@property (nonatomic, strong)ChatMessageEntity *message;


/**
 This method is used to set chat message cell height

 @param entity ChatMessageEntity
 @return height of cell
 */
+ (CGFloat)cellHeightForChatMessage:(ChatMessageEntity *)entity;

@end
