//
//  HeadImageView.m
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

#import "HeadImageView.h"
#import "GroupEntity.h"
#import "EmployeeEntity.h"
#import "EmployeeEntity+ServiceObject.h"
#import "ESpaceImageCache.h"

#import "ESpaceContactService.h"
#import "ManagerService.h"

@interface HeadImageView ()
@property (nonatomic, strong)ContactEntity *contact;   // current contact

@end

@implementation HeadImageView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)setDefualtImage
{
    if ([_contact isKindOfClass:[GroupEntity class]]) {
        self.image = [UIImage imageNamed:@"group_default_headImage"];
    }
    else {
        self.image = [UIImage imageNamed:@"default_head_image_0"];
    }
}

- (UIImage *)systemHeadImage:(NSString *)headId
{
    // headId between 1 and 9 means system head image
    if (headId.integerValue >= 0 && headId.integerValue <= 9) {
        NSString *imageName = [NSString stringWithFormat:@"default_head_image_%d", headId.intValue];
        return [UIImage imageNamed:imageName];
    }
    else {
        return nil;
    }
}

- (void)setContactEntity:(ContactEntity *)contact
{
    [_contact removeObserver:self forKeyPath:@"headId"];
    _contact = contact;
    [_contact addObserver:self forKeyPath:@"headId" options:NSKeyValueObservingOptionNew context:nil];
    
    [self reloadHeadImage];
}

- (void)reloadHeadImage
{
    if ([_contact isKindOfClass:[EmployeeEntity class]]) {
        [self reloadEmployeeHeadImage];
    }
    else if ([_contact isKindOfClass:[GroupEntity class]]) {
        [self reloadGroupHeadImage];
    }
}


/**
 This method is used to load employee head image
 */
- (void)reloadEmployeeHeadImage
{
    EmployeeEntity* employee = (EmployeeEntity*)self.contact;
    // if employee need update , reload detail while trigger KVO of 'headId'
//    if ([employee needReload]) {
//        [employee reloadDetail];
//    } else {
        UIImage* headImage = [self systemHeadImage:employee.headId];
        if (headImage) {
            self.image = headImage;
            return;
        }
    
//        NSString* key = [employee headImageKey];
//        UIImage* image = [[ESpaceImageCache sharedInstance] imageWithKey:key];
//        if (image) {
//            self.image = image;
//        } else {
//            [self setDefualtImage];
//            __weak typeof(self) weakSelf = self;
//            if ([[NSFileManager defaultManager] fileExistsAtPath:[employee headImageLocalPath]]) {
//                NSString *imagePath = [_contact headImageLocalPath];
//                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//                    NSData* data = [[NSFileManager defaultManager] contentsAtPath:imagePath];
//                    UIImage *image = [UIImage imageWithData:data];
//                    [[ESpaceImageCache sharedInstance] setImage:image forKey:key cost:data.length];
//                    if (image) {
//                        dispatch_async(dispatch_get_main_queue(), ^{
//                            weakSelf.image = image;
//                        });
//                    }
//                });
//
//            } else {
////                [[ManagerService contactService] loadPersonHeadIconWithAccount:employee.account];
//
////                // todo jl
////
////                [employee loadHeadImage:^(UIImage *imageData, NSError *error) {
////                    if (imageData) {
////                        dispatch_async(dispatch_get_main_queue(), ^{
////                            weakSelf.image = imageData;
////                        });
////                    }
////                }];
//
//            }
////        }
//    }
}


/**
 This method is used to load group head image view
 */
- (void)reloadGroupHeadImage
{
    GroupEntity* group = (GroupEntity*)self.contact;
    if ([group.headId length] == 0) {
        [self setDefualtImage];
        return;
    }
    
    NSString* key = [group headImageKey];
    if (!key) {
        [self setDefualtImage];
        return;
    }
    __weak typeof(self) weakSelf = self;
    UIImage* image = [[ESpaceImageCache sharedInstance] imageWithKey:key];
    if (image) {
        self.image = image;
    } else {
        NSString* imagePath = [group headImageLocalPath];

        if ([[NSFileManager defaultManager] fileExistsAtPath:imagePath]) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                UIImage* image = [[ESpaceImageCache sharedInstance] imageWithKey:key];
                if (!image) {
                    NSData* data = [[NSFileManager defaultManager] contentsAtPath:imagePath];
                    image = [UIImage imageWithData:data];
                    [[ESpaceImageCache sharedInstance] setImage:image forKey:key cost:data.length];
                    if (image) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            weakSelf.image = image;
                        });
                    }
                }
            });
        }
    }

    if (![[ESpaceContactService sharedInstance].validGroupHeadImages containsObject:key]) {
//        [group loadHeadImage:YES completion:^(UIImage *imageData, NSError *error) {
//            weakSelf.image = imageData;
//        }];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    __weak typeof(self) weakSelf = self;
    if ([keyPath isEqualToString:@"headId"] && object == _contact) {
        dispatch_async(dispatch_get_main_queue(), ^{
            //JL todo
//            [weakSelf reloadHeadImage];
        });
    }
}

-(void)dealloc
{
    [_contact removeObserver:self forKeyPath:@"headId"];
}



@end
