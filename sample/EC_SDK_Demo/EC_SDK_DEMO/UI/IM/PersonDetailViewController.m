//
//  PersonDetailViewController.m
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

#import "PersonHeaderViewCell.h"
#import "PersonDetailViewCell.h"
#import "PersonDetailViewController.h"
#import "UserSignatureSettingController.h"
#import "EmployeeEntity.h"

#import "ManagerService.h"
#import <AVFoundation/AVFoundation.h>

#import "eSpaceDBService.h"
#import "NSManagedObjectContext+Persistent.h"
#import "ContactService.h"
#import "ESpaceContactService.h"
#import "EmployeeCategoryEntity+ServiceObject.h"

@interface PersonDetailViewController ()<UITableViewDelegate, UITableViewDataSource, TUPContactServiceDelegate>

@property (nonatomic, strong) EmployeeEntity *employee;        // current employee entity
@property (weak, nonatomic) IBOutlet UITableView *tableView;   // current tableView
@property (nonatomic, strong) NSMutableArray *personInfos;     // peron infos
@property (nonatomic, strong) NSMutableArray *numberInfos;     // number infos
@property (nonatomic, strong) NSArray *groups;                 // person's contact groups
@property (nonatomic, assign) BOOL isSelf;                     // is self or not
@property (nonatomic, strong) UIView *bgSysIconView;           // icon preview view
@property (nonatomic, strong) UIBarButtonItem *addItem;        // add friend button
@property (nonatomic, strong) UIBarButtonItem *deleteItem;     // delete friend button

@end

@implementation PersonDetailViewController

- (instancetype)initWithPerson:(EmployeeEntity *)employee {
    self = [super init];
    if (self) {
        self.employee = employee;
        self.groups = [EmployeeCategoryEntity allCategoryEntities];
        self.personInfos = @[@DETAIL_SIGNATURE,
                             @DETAIL_SEX,
                             @DETAIL_DEPARTMENT,
                             @DETAIL_POSITION,
                             @DETAIL_ACCOUNT,
                             @DETAIL_FAX,
                             @DETAIL_MAIL,
                             @DETAIL_ZIPCODE,
                             @DETAIL_ADRESS].mutableCopy;
        self.numberInfos = @[@DETAIL_BIND_NUMBER,
                             @DETAIL_MOBILE,
                             @DETAIL_SHORT_NUMBER,
                             @DETAIL_HOME_PHONE,
                             @DETAIL_PHONE].mutableCopy;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [ManagerService contactService].delegate = self;
    if (_isSelf) {
        [self.tableView reloadData];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    NSMutableArray *accountArray = [[NSMutableArray alloc] init];
    [accountArray addObject:self.employee.account];
    [[ESpaceContactService sharedInstance] detectUserStatusWithAccountArray:accountArray];
    
    _deleteItem = [[UIBarButtonItem alloc] initWithTitle:@"Delete" style:UIBarButtonItemStylePlain target:self action:@selector(deleteFriend)];
    _addItem = [[UIBarButtonItem alloc] initWithTitle:@"Add" style:UIBarButtonItemStylePlain target:self action:@selector(addFriend)];
    
    self.title = self.employee.name;
    self.isSelf = [self.employee.account isEqualToString:LOCAL_DATA_MANAGER.currentUser.account];
    
    [self reloadRightBarButtonItem];
    self.tableView.tableFooterView = [[UIView alloc] init];
    [self.tableView registerNib:[UINib nibWithNibName:@"PersonHeaderViewCell" bundle:nil] forCellReuseIdentifier:@"PersonHeaderViewCell"];
    [self.tableView registerClass:[PersonInfoViewCell class] forCellReuseIdentifier:@"PersonInfoViewCell"];
    [self.tableView registerClass:[PersonNumberViewCell class] forCellReuseIdentifier:@"PersonNumberViewCell"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDelegate and UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (0 == section) {
        return 1;
    }else if(1 == section) {
        return self.personInfos.count;
    }else if(2 == section) {
        return self.numberInfos.count;
    }else {
        return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (0 == indexPath.section) {
        return 100.0f;
    }else {
        return 44.0f;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    if (0 == indexPath.section) {
        PersonHeaderViewCell *headCell = [tableView dequeueReusableCellWithIdentifier:@"PersonHeaderViewCell"];
        headCell.employee = self.employee;
        headCell.parentViewCtrl = self;
        cell = headCell;
    }else if(1 == indexPath.section) {
        PersonInfoViewCell *detailCell = [tableView dequeueReusableCellWithIdentifier:@"PersonInfoViewCell"];
        detailCell.index = self.personInfos[indexPath.row];
        detailCell.employee = self.employee;
        cell = detailCell;
    }else {
        PersonNumberViewCell *numberCell = [tableView dequeueReusableCellWithIdentifier:@"PersonNumberViewCell"];
        numberCell.index = self.numberInfos[indexPath.row];
        numberCell.employee = self.employee;
        cell = numberCell;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (_isSelf) {
        if (0 == indexPath.section) {
            [self modifyHeadImage];
        }else if (1 == indexPath.section) {
            PersonInfoViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            if ([cell.index isEqual:@DETAIL_SIGNATURE]) {
                [self setUserSignature];
            }
        }else {
            
        }
    }
}

#pragma mark - private method

/**
 This method is used to set signature
 */
- (void)setUserSignature {
    UserSignatureSettingController *signatureVC = [[UserSignatureSettingController alloc] init];
    [self.navigationController pushViewController:signatureVC animated:YES];
}


/**
 This method is used to modify head Image
 */
- (void)modifyHeadImage {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *choosePhone = [UIAlertAction actionWithTitle:@"Photos"
                                                          style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction *action)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setImageByPhotos];
        });
    }];
    [alertController addAction:choosePhone];
    
    UIAlertAction *takePhone = [UIAlertAction actionWithTitle:@"Camera"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setImageByCamera];
        });
    }];
    [alertController addAction:takePhone];
    
    UIAlertAction *recoverDefault = [UIAlertAction actionWithTitle:@"System"
                                                             style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction *action)
                                     {
                                         dispatch_async(dispatch_get_main_queue(), ^{
                                             [self showSystemImagesView];
                                         });
                                     }];
    [alertController addAction:recoverDefault];

    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel"
                                                     style:UIAlertActionStyleCancel
                                                   handler:nil];
    [alertController addAction:cancel];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)setImageByPhotos {
    UIImagePickerController *ipc = [[UIImagePickerController alloc] init];
    ipc.delegate = (id)self;
    ipc.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    if ([ipc respondsToSelector:@selector(setAllowsEditing:)]) {
        [ipc setAllowsEditing:YES];
    }
    [self presentViewController:ipc animated:YES completion:NULL];
}

- (void)setImageByCamera {
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

- (UIView *)bgSysIconView {
    if (!_bgSysIconView) {
        _bgSysIconView = [[UIView alloc] init];
        _bgSysIconView.backgroundColor = [UIColor lightGrayColor];
        _bgSysIconView.clipsToBounds = YES;
        _bgSysIconView.layer.cornerRadius = 15.0f;
        _bgSysIconView.center = self.view.center;
        _bgSysIconView.bounds = CGRectMake(0, 0, 290, 220);
        for (int i = 0; i < 10; i++) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.frame = CGRectMake(10+i%4*(60+10), 10+i/4*(60+10), 60, 60);
            [button setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"default_head_image_%d", i]] forState:UIControlStateNormal];
            button.tag = i;
            button.clipsToBounds = YES;
            button.layer.cornerRadius = 15.0f;
            [button addTarget:self action:@selector(systemIconButtonClick:) forControlEvents:UIControlEventTouchUpInside];
            [_bgSysIconView addSubview:button];
        }
    }
    return _bgSysIconView;
}

/**
 This method is used to show icon preview view
 */
- (void)showSystemImagesView {
    
    [self.view addSubview:self.bgSysIconView];
}

/**
 This method is used to remove icon preview view

 @param sender sender
 */
- (void)systemIconButtonClick:(UIButton *)sender {
    [self setSelectedSystemImage:(int)sender.tag];
    [self.bgSysIconView removeFromSuperview];
}

- (void)setSelectedSystemImage:(int)sysIconID {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[ManagerService contactService] setSystemHead:sysIconID withCmpletion:^(BOOL result) {
            if (!result) {
//                [[ManagerService contactService] loadPersonHeadIconWithAccount:self.employee.account];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self showMessage:@"Set Default Head Failed!"];
                });
            }
        }];
    });
}

- (void)startCamera {
    UIImagePickerController *ipc = [[UIImagePickerController alloc] init];
    ipc.delegate = (id)self;
    ipc.sourceType = UIImagePickerControllerSourceTypeCamera;
    if ([ipc respondsToSelector:@selector(setAllowsEditing:)]) {
        [ipc setAllowsEditing:YES];
    }
    [self presentViewController:ipc animated:YES completion:NULL];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    /* 拍照的时候状态栏可能会被隐藏，强制显示 */
    if ([[UIApplication sharedApplication] isStatusBarHidden]) {
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];//
    }
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    UIImage *imageSelected = [UIImage imageWithCGImage:image.CGImage];
    
    if ([[UIApplication sharedApplication] isStatusBarHidden]) {
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
    }
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[ManagerService contactService] setHeadImage:imageSelected completion:^(BOOL result, NSString *headID) {
            if (!result) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self showMessage:@"Set Head Failed!"];
                });
            }
        }];
    });
    
}


/**
 This method is used to add friend
 */
- (void)addFriend {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Select The Group"
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];
    for (EmployeeCategoryEntity *group in self.groups) {
        UIAlertAction *action = [UIAlertAction actionWithTitle:group.name
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * _Nonnull action)
        {
            EmployeeEntity *emp = [[ESpaceContactService sharedInstance] employeeFromCopyMemoryUser:(EmployeeEntity *)self.employee];
            [[ESpaceContactService sharedInstance] addFriend:emp
                                            toExistedTeam:group
                                                   notify:YES
                                               completion:^(NSError *error)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (!error) {
                        [self showMessage:@"Add Success."];
                        ESpaceLocalDataManager * localManager = LOCAL_DATA_MANAGER;
                        NSManagedObjectContext* bgCtx = [localManager backgroundObjectContext];
                        NSManagedObjectID* oldPersonId = self.employee.objectID;
                        
                        self.employee = (EmployeeEntity*)[bgCtx objectWithID:oldPersonId];
                        
                        [self reloadRightBarButtonItem];
                    }else {
                        [self showMessage:@"Add Failed."];
                    }
                });
            }];
        }];
        [alertController addAction:action];
    }
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel"
                                                     style:UIAlertActionStyleDefault
                                                   handler:nil];
    [alertController addAction:cancel];
    [self.navigationController presentViewController:alertController
                                            animated:YES
                                          completion:nil];
}

/**
 this method is used to load rightBarButtonItem
 */
- (void)reloadRightBarButtonItem {
    if (_isSelf) {
        return;
    }
    self.navigationItem.rightBarButtonItem = nil;
    if ([self.employee.isFriend boolValue]) {
        if ([ESpaceContactService sharedInstance].currentContactGroupId != nil) {
            self.navigationItem.rightBarButtonItem = _deleteItem;
        }
    }else {
        self.navigationItem.rightBarButtonItem = _addItem;
    }
}

/**
 This method is used to delete friend
 */
- (void)deleteFriend {
    __weak typeof(self) weakSelf = self;
    UIAlertController *alertCOntroller = [UIAlertController alertControllerWithTitle:@"Info"
                                                                             message:@"Delete the contact from all contact groups?"
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"Sure"
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * _Nonnull action) {
                                                           [[ESpaceContactService sharedInstance] deleteFriend:weakSelf.employee completion:^(NSError *error) {
                                                               dispatch_async(dispatch_get_main_queue(), ^{
                                                                   if (!error) {
                                                                       [weakSelf showMessage:@"Delete Success."];
                                                                       [weakSelf reloadRightBarButtonItem];
                                                                   }else {
                                                                       [weakSelf showMessage:@"Delete Failed."];
                                                                   }
                                                               });

                                                           }];
                                                       }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleDefault
                                                         handler:nil];
    [alertCOntroller addAction:sureAction];
    [alertCOntroller addAction:cancelAction];
    [self.navigationController presentViewController:alertCOntroller animated:YES completion:nil];
}


- (void)contactEventCallback:(TUP_CONTACT_EVENT_TYPE)contactEvent result:(NSDictionary *)resultDictionary {
    switch (contactEvent) {
        case CONTACT_E_SEARCH_GET_ICON_RESULT: {
            // todo sysIconId == nil
//            NSString *sysIconId = resultDictionary[TUP_SYS_ICON_ID_KEY];
//            NSString *filePath = resultDictionary[TUP_ICON_FILE_KEY];
//            UIImage *image = [UIImage imageWithContentsOfFile:filePath];
//            if (nil != image) {
////                _headImg = image;
//            }else {
//                if (sysIconId.integerValue >= 0 && sysIconId.integerValue <= 9) {
//                    NSString *imageName = [NSString stringWithFormat:@"default_head_image_%d", sysIconId.intValue];
////                    _headImg = [UIImage imageNamed:imageName];
//                }
//            }
//            [self.tableView reloadData];
        }
            break;
            
        default:
            break;
    }
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
