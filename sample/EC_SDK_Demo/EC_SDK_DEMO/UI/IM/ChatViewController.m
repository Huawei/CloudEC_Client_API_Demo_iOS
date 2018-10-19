//
//  ChatViewController.m
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

#import "ChatViewController.h"
#import <CoreData/CoreData.h>
#import "ChatMessageCell.h"
#import "TextMessageCell.h"
#import "AudioMessageCell.h"
#import "ImageMessageCell.h"
#import "VideoMessageCell.h"
#import "FileMessageCell.h"
#import <TUPIMSDK/TUPIMSDK.h>
#import <AVFoundation/AVFoundation.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "PreviewUMViewController.h"
#import "PreviewFileViewController.h"
#import <TUPIOSSDK/GroupEntity.h>
#import <TUPIOSSDK/EmployeeEntity.h>
#import <TUPContactSDK/GroupEntity+ServiceObject.h>

@interface EmotionButton : UIButton

@property (nonatomic, strong) ESpaceEmotionItem* item;    // emotion item

@end

@implementation EmotionButton
@end

@interface ChatViewController ()<UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate, UITextFieldDelegate, ChatMessageUMDelegate>
@property (weak, nonatomic) IBOutlet UIView *bottomView;                       // bottom view
@property (nonatomic, weak)IBOutlet UITableView *chatTable;                    // current chat tableView
@property (nonatomic, strong)UIRefreshControl *refreshCtrl;                    // refresh controller
@property (nonatomic, strong)NSFetchedResultsController *fetchResultCtrl;      // fetchedResults controller
@property (nonatomic, weak)IBOutlet NSLayoutConstraint *toolBarBottomConst;    // layout constraint
@property (nonatomic, weak)IBOutlet UIButton *voiceBtn;                        // voice button
@property (nonatomic, weak)IBOutlet UITextField *inputField;                   // input textField
@property (weak, nonatomic) IBOutlet UIView *emotionBGView;                    // emotion view
@property (weak, nonatomic) IBOutlet UIScrollView *emotionContentScrollView;   // emotion scrollView

@end

@implementation ChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _chatTable.tableFooterView = [[UIView alloc] init];
    [_chatTable registerNib:[UINib nibWithNibName:@"TextMessageCell" bundle:nil] forCellReuseIdentifier:@"TextMessageCell"];
    [_chatTable registerNib:[UINib nibWithNibName:@"AudioMessageCell" bundle:nil] forCellReuseIdentifier:@"AudioMessageCell"];
    [_chatTable registerNib:[UINib nibWithNibName:@"ImageMessageCell" bundle:nil] forCellReuseIdentifier:@"ImageMessageCell"];
    [_chatTable registerNib:[UINib nibWithNibName:@"VideoMessageCell" bundle:nil] forCellReuseIdentifier:@"VideoMessageCell"];
    [_chatTable registerNib:[UINib nibWithNibName:@"FileMessageCell" bundle:nil] forCellReuseIdentifier:@"FileMessageCell"];
    
    _chatTable.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    _refreshCtrl = [[UIRefreshControl alloc] init];
    [_refreshCtrl addTarget:self action:@selector(loadMoreMessage) forControlEvents:UIControlEventValueChanged];
    [_chatTable addSubview:_refreshCtrl];
    
    self.title = self.session.target.uiDisplayName;

    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"session=%@ AND contentType BETWEEN {0,4}", self.session];
    NSSortDescriptor *timestampDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"receiveTimestamp" ascending:YES];
    
    NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:@"ChatMessageEntity"];
    [request setPredicate:predicate];
    [request setSortDescriptors:[NSArray arrayWithObjects:timestampDescriptor, nil]];
    
    _fetchResultCtrl = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:LOCAL_DATA_MANAGER.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    _fetchResultCtrl.delegate = self;
    [_fetchResultCtrl performFetch:nil];
    
    [_chatTable reloadData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWilHide:) name:UIKeyboardWillHideNotification object:nil];
    
    [_chatTable setContentOffset:CGPointMake(0, _chatTable.contentSize.height - CGRectGetHeight(_chatTable.frame))];
    
    [self configEmotionViewExpressions];
    
    [self queryGroupMember];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    ChatMessageEntity *latestMsg = (ChatMessageEntity *)self.session.latestMessage;
    if (latestMsg) {
        [[TupIMessageService sharedInstance] MarkReadMessageRequest:self.session message:latestMsg];
    }
    
    if (self.session.unreadCount.integerValue > 0) {
        [self.session localMarkReadAll:nil];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - private method
/**
 This method is used to query group members
 */
- (void)queryGroupMember
{
    if ([_session.target isKindOfClass:[GroupEntity class]]) {
        __weak typeof(self) weakSelf = self;
        [((GroupEntity *)_session.target) queryGroupMember:^(NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                BOOL selfInGroup = NO;
                for (EmployeeEntity *entity in [((GroupEntity *)(weakSelf.session.target)).members allObjects]) {
                    if ([entity.account isEqualToString:[ECSAppConfig sharedInstance].latestAccount]) {
                        selfInGroup = YES;
                    }
                }
                if (!selfInGroup) {
                    weakSelf.bottomView.userInteractionEnabled = NO;
                    weakSelf.inputField.backgroundColor = [UIColor lightGrayColor];
                    weakSelf.bottomView.backgroundColor = [UIColor lightGrayColor];
                }
            });
        }];
    }
}

/**
 This method is used to load more message
 */
- (void)loadMoreMessage
{
    ChatMessageEntity *topMessage = nil;
    if (_fetchResultCtrl.fetchedObjects.count != 0) {
        topMessage = _fetchResultCtrl.fetchedObjects[0];
    }
    [self.session queryRoamingMessageBasedId:topMessage.messageId readed:YES count:20 completion:^(NSError *error, NSInteger count, NSArray *msgLogIdList) {
        if (error) {
            DDLogInfo(@"query roaming message failed.");
        }
        else if (count == 0){
            DDLogInfo(@"query roaming message no more.");
        }
        [_refreshCtrl endRefreshing];
    }];
}

/**
 This method is used to deal voice button action

 @param sender sender
 */
- (IBAction)voiceKeybordSwitch:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    btn.selected = !btn.isSelected;
    [self.view endEditing:YES];
    if (btn.selected) {
        [_voiceBtn setHidden:NO];
        [_inputField setHidden:YES];
    }
    else {
        [_voiceBtn setHidden:YES];
        [_inputField setHidden:NO];
    }
}

/**
 This method is used to deal long press action

 @param sender UILongPressGestureRecognizer
 */
- (IBAction)longPressGesture:(UILongPressGestureRecognizer *)sender
{
    static NSURL *s_recordUrl = nil;
    switch (sender.state) {
        case UIGestureRecognizerStateBegan:
        {
            s_recordUrl = [NSURL exportURLInCacheDirecotry:@"wav" error:nil];
            [[ESpaceMediaService sharedInstance] prepareRecordNewAudio];
            [[ESpaceMediaService sharedInstance] startRecord:s_recordUrl.path];
            _voiceBtn.selected = YES;
            break;
        }
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        {
            _voiceBtn.selected = NO;
            NSTimeInterval duration;
            [[ESpaceMediaService sharedInstance] stopRecord:&duration];
            ESpaceUMAudioResource *audioResource = [s_recordUrl audioResource:duration];
            [self.session sendUMMessage:audioResource completionBlock:nil];
            break;
        }
        default:
            break;
    }
}

/**
 This method is used to config emotion view position
 */
- (void)configEmotionViewExpressions {
    NSArray* emotions = [ESpaceEmotions sharedInstance].emotionItems;
    
    // per page: 4*7   space 上下4 左右
    CGFloat verSpace = 4.0f;
    CGFloat horSpace = ([[UIScreen mainScreen] bounds].size.width-7*40)/8.0;
    
    NSInteger emotionCount = emotions.count;
    NSInteger totalRow = emotionCount%7>0 ? emotionCount/7+1 : emotionCount/7;
    [self.emotionContentScrollView setContentSize:CGSizeMake([[UIScreen mainScreen] bounds].size.width, verSpace+totalRow*(40+verSpace))];
    
    for (NSInteger i = 0; i<emotions.count; ++i) {
        NSInteger pageIndex = i/7;
        ESpaceEmotionItem *item = emotions[i];
        EmotionButton *button = [EmotionButton buttonWithType:UIButtonTypeCustom];
        button.item = item;
        [button setFrame:CGRectMake(horSpace+i%7*(40+horSpace), verSpace+pageIndex*(40+verSpace), 40, 40)];
        [button setImage:item.image forState:UIControlStateNormal];
        [button addTarget:self action:@selector(selectEmotionItems:) forControlEvents:UIControlEventTouchUpInside];
        [self.emotionContentScrollView addSubview:button];
    }
}

/**
 This method is used to selected emotion deal

 @param sender EmotionButton
 */
- (void)selectEmotionItems:(EmotionButton *)sender {
    _inputField.text = [NSString stringWithFormat:@"%@%@", _inputField.text, sender.item.escapeString];
}

/**
 This method is used to show emtion view

 @param sender sender
 */
- (IBAction)showEmotionViewClick:(id)sender {
    
    [self.view endEditing:YES];
    [self performSelector:@selector(showEmotionViewDelay) withObject:nil afterDelay:0.30];
}

- (void)showEmotionViewDelay {
    _emotionBGView.hidden = NO;
    _toolBarBottomConst.constant = 220;
}

/**
 This method is used to hide emotion view
 
 @param sender sender
 */
- (IBAction)endEdit:(id)sender
{
    [self.view endEditing:YES];
    self.emotionBGView.hidden = YES;
    _toolBarBottomConst.constant = 0;
}

/**
 This method is used to send emotion deal

 @param sender sender
 */
- (IBAction)sendEmotionClick:(id)sender {
    [self textFieldShouldReturn:_inputField];
}

#pragma mark - Iamge Pick Deal
/**
 This method is used to deal image pick action

 @param sender sender
 */
- (IBAction)showUMTypesAlert:(id)sender {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Select The Message Type"
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *photos = [UIAlertAction actionWithTitle:@"Photos"
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction *action)
                             {
                                 [self selectImageByPhotos];
                             }];
    UIAlertAction *camera = [UIAlertAction actionWithTitle:@"Camera"
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction *action)
                             {
                                 [self selectImageByCamera];
                             }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel"
                                                     style:UIAlertActionStyleCancel
                                                   handler:nil];
    [alertController addAction:photos];
    [alertController addAction:camera];
    [alertController addAction:cancel];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)selectImageByPhotos {
    UIImagePickerController *ipc = [[UIImagePickerController alloc] init];
    ipc.delegate = (id)self;
    ipc.mediaTypes = @[(NSString *)kUTTypeImage, (NSString *)kUTTypeMovie];
    ipc.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    if ([ipc respondsToSelector:@selector(setAllowsEditing:)]) {
        [ipc setAllowsEditing:YES];
    }
    [self presentViewController:ipc animated:YES completion:NULL];
}

- (void)selectImageByCamera {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (granted) {
                    [self startCamera];
                } else {
                    [self showMessage:@"Choose Settings > Privacy > Camera on your iPhone and allow eSpace to access your camera."];
                }
            });
        }];
        
    }
}

- (void)startCamera {
    UIImagePickerController *ipc = [[UIImagePickerController alloc] init];
    ipc.delegate = (id)self;
    ipc.videoQuality = UIImagePickerControllerQualityTypeHigh;
    ipc.mediaTypes = @[(NSString *)kUTTypeImage, (NSString *)kUTTypeMovie];
    ipc.sourceType = UIImagePickerControllerSourceTypeCamera;
    if ([ipc respondsToSelector:@selector(setAllowsEditing:)]) {
        [ipc setAllowsEditing:YES];
    }
    [self presentViewController:ipc animated:YES completion:NULL];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    if ([[UIApplication sharedApplication] isStatusBarHidden]) {
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
    }
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
    ESpaceUMResource *umResource = nil;
    NSURL *umResourceURL = nil;
    NSError *error = nil;
    NSData *data = nil;
    if ([mediaType isEqualToString:@"public.image"]) {
        UIImage *sourceImage = [info objectForKey:UIImagePickerControllerEditedImage];
        DDLogInfo(@"image");
        data = UIImagePNGRepresentation(sourceImage);
        umResource = [[ESpaceUMImgResource alloc] init];
        umResourceURL = [NSURL exportURLInCacheDirecotry:@"png" error:&error];
        umResource.umType = ESpaceUMTypeImage;
        umResource.width = sourceImage.size.width;
        umResource.height = sourceImage.size.height;
        
        BOOL isSuccess = NO;
        if (umResourceURL)
        {
            isSuccess = [data writeToURL:umResourceURL options:NSDataWritingAtomic error:&error];
        }
        if (isSuccess)
        {
            umResource.name = umResourceURL.lastPathComponent;
            umResource.resourcePath = umResourceURL.absoluteString;
            umResource.localDirectory = [umResourceURL URLByDeletingLastPathComponent].path;
            umResource.size = data.length;
        }else {
            DDLogInfo(@"Write failed!");
        }
        
        [self.session sendUMMessage:umResource completionBlock:^(NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!error) {
                    DDLogInfo(@"Success!");
                }else {
                    [self showMessage:@"Error!"];
                }
            });
        }];
    }
    
    if ([mediaType isEqualToString:@"public.movie"]) {
        NSURL *sourceURL = [info valueForKey:UIImagePickerControllerMediaURL];
        
        [sourceURL export2TmpDir:^(NSError *error ,ESpaceUMResource *umResource) {
            umResource.name = umResource.name;
            umResource.resourcePath = umResource.resourcePath;
            umResource.localDirectory = umResource.localDirectory;
            umResource.umType = umResource.umType;
            umResource.size = umResource.size;
            umResource.duration = umResource.duration;
            umResource.width = umResource.width;
            umResource.height = umResource.height;
            
            [self.session sendUMMessage:umResource completionBlock:^(NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (!error) {
                        DDLogInfo(@"Success!");
                    }else {
                        [self showMessage:@"Error!"];
                    }
                });
            }];
        }];
    }
    
    if ([[UIApplication sharedApplication] isStatusBarHidden]) {
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
    }
    
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (0 == textField.text.length) {
        return NO;
    }
    
    [self.session sendMessage:textField.text completionBlock:nil];
    textField.text = @"";
    return YES;
}

#pragma mark - ChatMessageUMDelegate
- (void)messageUmResourceDidFinishLoad:(ChatMessageEntity *)message
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.fetchResultCtrl.fetchedObjects indexOfObject:message] inSection:0];
    [self.chatTable reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)clickToPreviewUM:(ChatMessageEntity *)message
{
    PreviewUMViewController *previewCtrl = [[PreviewUMViewController alloc] initWithNibName:@"PreviewUMViewController" bundle:nil];
    previewCtrl.message = message;
    [self presentViewController:previewCtrl animated:YES completion:nil];
}

- (void)clickToPreviewFileWithPath:(NSString *)localPath {
    PreviewFileViewController *previewCtrl = [[PreviewFileViewController alloc] initWithFileLocalPath:localPath];
    [self.navigationController pushViewController:previewCtrl animated:YES];
}

#pragma mark - UITableViewDelegate and UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _fetchResultCtrl.fetchedObjects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    ChatMessageEntity *message = _fetchResultCtrl.fetchedObjects[indexPath.row];
    if (message.contentType.integerValue == ESpaceTextContentType) {
        TextMessageCell *textCell = [tableView dequeueReusableCellWithIdentifier:@"TextMessageCell"];
        textCell.message = message;
        cell = textCell;
    }
    else if (message.contentType.integerValue == ESpaceAudioContentType) {
        AudioMessageCell *audioCell = [tableView dequeueReusableCellWithIdentifier:@"AudioMessageCell"];
        audioCell.message = message;
        cell = audioCell;
    }
    else if (message.contentType.integerValue == ESpaceImageContentType) {
        ImageMessageCell *imageCell = [tableView dequeueReusableCellWithIdentifier:@"ImageMessageCell"];
        imageCell.message = message;
        imageCell.delegate = self;
        cell = imageCell;
    }
    else if (message.contentType.integerValue == ESpaceVideoContentType) {
        VideoMessageCell *videoCell = [tableView dequeueReusableCellWithIdentifier:@"VideoMessageCell"];
        videoCell.message = message;
        videoCell.delegate = self;
        cell = videoCell;
    }else if (message.contentType.integerValue == ESpaceFileContentType) {
        FileMessageCell *fileCell = [tableView dequeueReusableCellWithIdentifier:@"FileMessageCell"];
        fileCell.message = message;
        fileCell.delegate = self;
        cell = fileCell;
    }
    else {
        cell = [[UITableViewCell alloc] init];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ChatMessageEntity *message = _fetchResultCtrl.fetchedObjects[indexPath.row];
    if (message.contentType.integerValue == ESpaceTextContentType) {
        return [TextMessageCell cellHeightForChatMessage:message];
    }
    else if (message.contentType.integerValue == ESpaceAudioContentType) {
        return [AudioMessageCell cellHeightForChatMessage:message];
    }
    else if (message.contentType.integerValue == ESpaceImageContentType){
        return [ImageMessageCell cellHeightForChatMessage:message];
    }
    else if (message.contentType.integerValue == ESpaceVideoContentType) {
        return [VideoMessageCell cellHeightForChatMessage:message];
    }else if (message.contentType.integerValue == ESpaceFileContentType) {
        return [FileMessageCell cellHeightForChatMessage:message];
    }
    else {
        return [ChatMessageCell cellHeightForChatMessage:message];
    }
    
}

#pragma mark - NSFetchedResultsControllerDelegate
- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(nullable NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(nullable NSIndexPath *)newIndexPath
{
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf.chatTable reloadData];
        
        ChatMessageEntity *latestMsg = (ChatMessageEntity *)self.session.latestMessage;
        if (latestMsg) {
            [[TupIMessageService sharedInstance] MarkReadMessageRequest:self.session message:latestMsg];
        }
        
        if (self.session.unreadCount.integerValue > 0) {
            [self.session localMarkReadAll:nil];
        }
        
    });
}

#pragma mark - Key Bord Deal
- (void)keyboardWillShow:(NSNotification *)notification
{
    NSValue * value = [notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    NSNumber *duration = [notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    CGRect keyboardRect = [value CGRectValue];
    _emotionBGView.hidden = YES;
    [UIView animateWithDuration:duration.doubleValue animations:^{
        _toolBarBottomConst.constant = CGRectGetHeight(keyboardRect);
        [self.view layoutIfNeeded];
    }];
}

- (void)keyboardWilHide:(NSNotification *)notification
{
    NSNumber *duration = [notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    [UIView animateWithDuration:duration.doubleValue animations:^{
        _toolBarBottomConst.constant = 0;
        [self.view layoutIfNeeded];
    }];
}

#pragma mark
#pragma mark --- AlertShow ---
-(void)showMessage:(NSString *)msg {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                   message:msg
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [self presentViewController:alert animated:NO completion:nil];
    [NSTimer scheduledTimerWithTimeInterval:1
                                     target:self
                                   selector:@selector(creatAlert:)
                                   userInfo:alert
                                    repeats:NO];
}

- (void)creatAlert:(NSTimer *)timer {
    UIAlertController *alert = [timer userInfo];
    [alert dismissViewControllerAnimated:YES completion:nil];
    alert = nil;
}

@end
