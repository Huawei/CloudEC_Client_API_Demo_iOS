/*
 * Copyright 2015 Huawei Technologies Co., Ltd. All rights reserved.
 * eSDK is licensed under the Apache License, Version 2.0 ^(the "License"^);
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *      http://www.apache.org/licenses/LICENSE-2.0
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import <UIKit/UIKit.h>
#import "TUPService.h"

typedef enum
{
    CONF_END_BUTTON,
    CONF_UPGRADE_BUTTON,
    CONF_MORE_BUTTON,
    CONF_DIAL_NUMBER_BUTTON,
    CONF_SITE_LIST_BUTTON,
    CONF_SHOW_SHARHIMG_BUTTON,
    CONF_SHOW_HIDEIMG_BUTTON,
}CONF_TOOLBAR_BUTTON_TYPE;



@protocol ConferenceViewDelegate<NSObject>
@optional
-(void)clickConferenceToolBarType:(CONF_TOOLBAR_BUTTON_TYPE)type;
@end

@interface ConferenceView : UIView
@property (nonatomic,assign)id<ConferenceViewDelegate> delegate;
@property (weak, nonatomic) IBOutlet UILabel *tipLabel;
@property (weak, nonatomic) IBOutlet UIButton *listButton;
@property (weak, nonatomic) IBOutlet UIView *moreMenuView;
@property (weak, nonatomic) IBOutlet UIView *toolbarView;
@property (weak, nonatomic) IBOutlet UIButton *upgradeButton;
@property (weak, nonatomic) IBOutlet UIButton *moreButton;
@property (nonatomic, weak) IBOutlet UIImageView *shareImageView;//share view
@property (weak, nonatomic) IBOutlet UILabel *speakerLabel;
@property (weak, nonatomic) IBOutlet UIButton *hideShareButton;
@property (assign, nonatomic) BOOL isEnterConf;
@property (assign, nonatomic) BOOL isDataConf;
-(void)showDesktopShareView:(UIImage *)shareData;

-(void)hideDesktopShareView;
@end
