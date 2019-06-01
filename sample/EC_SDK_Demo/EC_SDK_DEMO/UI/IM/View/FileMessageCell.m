//
//  FileMessageCell.m
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

#import "FileMessageCell.h"

@interface FileMessageCell ()

@property (weak, nonatomic) IBOutlet UILabel *fileNameLabel;    // show file name
//@property (nonatomic, strong)ESpaceUMResource *umResource;      // umResource

@end

@implementation FileMessageCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap:)];
    [self.msgBottomView addGestureRecognizer:tap];
}

- (void)onTap:(UITapGestureRecognizer *)tap {
//    DDLogInfo(@"Select file name: %@", self.umResource.name);
//    if (ESpaceUMStatusDownloaded != self.umResource.umStatus ) {
//        self.activity.hidden = NO;
//        [self.activity startAnimating];
//        [self.umResource download:^(NSError *error) {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                if (!error) {
//                    [self goToPreviewViewController];
//                }else {
//                    [[[UIAlertView alloc] initWithTitle:nil message:@"Download error!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
//                }
//                self.activity.hidden = YES;
//                [self.activity stopAnimating];
//            });
//        }];
//    }else {
        [self goToPreviewViewController];
//    }
    
}

/**
 This method is used to jump to preview view
 */
- (void)goToPreviewViewController {
//    NSString *fileType = [[self.umResource.name componentsSeparatedByString:@"."] lastObject];
//    if ([fileType isEqualToString:@"xlsx"]
//        || [fileType isEqualToString:@"png"]
//        || [fileType isEqualToString:@"jpg"]
//        || [fileType isEqualToString:@"jpeg"]
//        || [fileType isEqualToString:@"doc"]
//        || [fileType isEqualToString:@"docx"]
//        || [fileType isEqualToString:@"ppt"]
//        || [fileType isEqualToString:@"pptx"]
//        || [fileType isEqualToString:@"xls"])
//    {
//        if (self.delegate && [self.delegate respondsToSelector:@selector(clickToPreviewFileWithPath:)]) {
//            [self.delegate clickToPreviewFileWithPath:self.umResource.localFilePath];
//        }
//    }else {
//        [[[UIAlertView alloc] initWithTitle:nil message:@"Sorry, you can open the file on your PC." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
//    }
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (CGFloat)cellHeightForChatMessage:(ChatMessageEntity *)entity
{
    return 110.0f;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _fileNameLabel.lineBreakMode = NSLineBreakByCharWrapping;
    _fileNameLabel.numberOfLines = 2;
}

- (void)setMessage:(ChatMessageEntity *)message {
    [super setMessage:message];
    
//    self.umResource = [message.umResources lastObject];
//    self.fileNameLabel.text = self.umResource.name;
    CGSize size = [self.fileNameLabel sizeThatFits:CGSizeMake(169, 46)];
    self.textWidthConstraint.constant = size.width + 60;
    self.textHeighConstraint.constant = 66;
}

@end
