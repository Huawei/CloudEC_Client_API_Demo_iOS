//
//  AddressDetailViewController.m
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

#import "AddressDetailViewController.h"

#import "ManagerService.h"
#import "TupHeadViewCell.h"
#import "ContactInfo.h"

#define DETAIL_STAFF_ACCOUNT   1000
#define DETAIL_PERSON_NAME     1001
#define DETAIL_STAFF_NUMBER    1002
#define DETAIL_TERMINAL        1003
#define DETAIL_TERMINAL2       1004
#define DETAIL_DEPT_NAME       1005
#define DETAIL_TITLE           1006
#define DETAIL_MOBILE          1007
#define DETAIL_HOME_PHONE      1008
#define DETAIL_EMAIL           1009
#define DETAIL_OFFICE_PHONE    1010
#define DETAIL_OFFICE_PHONE2   1011
#define DETAIL_OFFICE_PHONE3   1012
#define DETAIL_OFFICE_PHONE4   1013
#define DETAIL_OFFICE_PHONE5   1014
#define DETAIL_OFFICE_PHONE6   1015
#define DETAIL_OTHER_PHONE     1016
#define DETAIL_OTHER_PHONE2    1017
#define DETAIL_ZIPCODE         1018
#define DETAIL_ADDRESS         1019
#define DETAIL_SIGNATURE       1020
#define DETAIL_GENDER          1021

@interface AddressDetailViewController ()<TUPContactServiceDelegate>

@property (nonatomic, strong) ContactInfo *tupContact;       // contact info
@property (nonatomic, strong) NSMutableArray *dataArr;       // data array use to save current tupContact data
@property (nonatomic, strong) UIImage *headImg;              // head image

@end

@implementation AddressDetailViewController

- (instancetype)initWithTupPerson:(ContactInfo *)tupContact {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.tupContact = tupContact;
        self.dataArr = @[@DETAIL_STAFF_ACCOUNT,
                          @DETAIL_PERSON_NAME,
                          @DETAIL_GENDER,
                          @DETAIL_STAFF_NUMBER,
                          @DETAIL_ZIPCODE,
                          @DETAIL_ADDRESS,
                          @DETAIL_SIGNATURE,
                          @DETAIL_TERMINAL,
                          @DETAIL_TERMINAL2,
                          @DETAIL_DEPT_NAME,
                          @DETAIL_TITLE,
                          @DETAIL_MOBILE,
                          @DETAIL_HOME_PHONE,
                          @DETAIL_EMAIL,
                          @DETAIL_OFFICE_PHONE,
                          @DETAIL_OFFICE_PHONE2,
                          @DETAIL_OFFICE_PHONE3,
                          @DETAIL_OFFICE_PHONE4,
                          @DETAIL_OFFICE_PHONE5,
                          @DETAIL_OFFICE_PHONE6,
                          @DETAIL_OTHER_PHONE,
                          @DETAIL_OTHER_PHONE2].mutableCopy;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = _tupContact.personName;
    [self.tableView registerNib:[UINib nibWithNibName:@"TupHeadViewCell" bundle:nil] forCellReuseIdentifier:@"TupHeadViewCell"];
    [self loadTupPersonHeadImage];
}

- (void)contactEventCallback:(TUP_CONTACT_EVENT_TYPE)contactEvent result:(NSDictionary *)resultDictionary {
    switch (contactEvent) {
        case CONTACT_E_SEARCH_GET_ICON_RESULT: {
            NSString *sysIconId = resultDictionary[TUP_SYS_ICON_ID_KEY];
            NSString *filePath = resultDictionary[TUP_ICON_FILE_KEY];
            UIImage *image = [UIImage imageWithContentsOfFile:filePath];
            if (nil != image) {
                _headImg = image;
            }else {
                if (sysIconId.integerValue >= 0 && sysIconId.integerValue <= 9) {
                    NSString *imageName = [NSString stringWithFormat:@"default_head_image_%d", sysIconId.intValue];
                    _headImg = [UIImage imageNamed:imageName];
                }
            }
            [self.tableView reloadData];
        }
            break;
            
        default:
            break;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [ManagerService contactService].delegate = self;
}

/**
 This method is used to query person head image
 */
- (void)loadTupPersonHeadImage {
    [[ManagerService contactService] loadPersonHeadIconWithAccount:_tupContact.staffAccount];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (0 == indexPath.section) {
        return 100.0f;
    }
    return 44.0f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (0 == section) {
        return 1;
    }
    return _dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    if (0 == indexPath.section) {
        TupHeadViewCell *headCell = [tableView dequeueReusableCellWithIdentifier:@"TupHeadViewCell"];
        if (nil != _headImg) {
            headCell.headImg.image = _headImg;
        }
        cell = headCell;
    }else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
            cell.textLabel.font = [UIFont systemFontOfSize:15];
            cell.textLabel.textColor = [UIColor darkGrayColor];
            cell.detailTextLabel.font = [UIFont systemFontOfSize:13];
        }
        
        NSInteger index = [_dataArr[indexPath.row] integerValue];
        NSString *title;
        NSString *detail;
        switch (index) {
            case DETAIL_STAFF_ACCOUNT:
                title = @"Account";
                detail = _tupContact.staffAccount;
                break;
            case DETAIL_PERSON_NAME:
                title = @"Name";
                detail = _tupContact.personName;
                break;
            case DETAIL_STAFF_NUMBER:
                title = @"Staff Number";
                detail = _tupContact.staffno;
                break;
            case DETAIL_TERMINAL:
                title = @"Terminal";
                detail = _tupContact.terminal;
                break;
            case DETAIL_TERMINAL2:
                title = @"Terminal2";
                detail = _tupContact.terminal2;
                break;
            case DETAIL_DEPT_NAME:
                title = @"Department Name";
                detail = _tupContact.deptName;
                break;
            case DETAIL_TITLE:
                title = @"Title";
                detail = _tupContact.title;
                break;
            case DETAIL_MOBILE:
                title = @"Mobile";
                detail = _tupContact.mobile;
                break;
            case DETAIL_HOME_PHONE:
                title = @"Home Phone";
                detail = _tupContact.homephone;
                break;
            case DETAIL_EMAIL:
                title = @"Email";
                detail = _tupContact.email;
                break;
            case DETAIL_OFFICE_PHONE:
                title = @"Office Phone";
                detail = _tupContact.officePhone;
                break;
            case DETAIL_OFFICE_PHONE2:
                title = @"Office Phone2";
                detail = _tupContact.officePhone2;
                break;
            case DETAIL_OFFICE_PHONE3:
                title = @"Office Phone3";
                detail = _tupContact.officePhone3;
                break;
            case DETAIL_OFFICE_PHONE4:
                title = @"Office Phone4";
                detail = _tupContact.officePhone4;
                break;
            case DETAIL_OFFICE_PHONE5:
                title = @"Office Phone5";
                detail = _tupContact.officePhone5;
                break;
            case DETAIL_OFFICE_PHONE6:
                title = @"Office Phone6";
                detail = _tupContact.officePhone6;
                break;
            case DETAIL_OTHER_PHONE:
                title = @"Other Phone";
                detail = _tupContact.otherphone;
                break;
            case DETAIL_OTHER_PHONE2:
                title = @"Other Phone2";
                detail = _tupContact.otherphone2;
                break;
            case DETAIL_ZIPCODE:
                title = @"Zip Code";
                detail = _tupContact.zipCode;
                break;
            case DETAIL_ADDRESS:
                title = @"Adress";
                detail = _tupContact.address;
                break;
            case DETAIL_SIGNATURE:
                title = @"Signature";
                detail = _tupContact.signature;
                break;
            case DETAIL_GENDER:
                title = @"Gender";
                detail = _tupContact.gender;
                break;
                
            default:
                break;
        }
        cell.textLabel.text = title;
        cell.detailTextLabel.text = detail;
    }
    
    return cell;
}

@end
