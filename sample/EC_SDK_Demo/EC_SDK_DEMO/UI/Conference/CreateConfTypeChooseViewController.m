//
//  CreateConfTypeChooseViewController.m
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

#import "CreateConfTypeChooseViewController.h"

@interface CreateConfTypeChooseViewController ()
{
    NSArray *confTypeDisplayArray; //会议类型数组
}
@property (nonatomic, assign)EC_CONF_MEDIATYPE selectedConfMediaType;      //当前选中的会议类型
@end

@implementation CreateConfTypeChooseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = NSLocalizedString(@"conference_type", @"会议类型");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (instancetype)initWithConfMediaType:(EC_CONF_MEDIATYPE)mediaType andIsSupportVideoConf:(BOOL)isSupportVideoConf {
    if (self = [super initWithStyle:UITableViewStyleGrouped]) {
        _selectedConfMediaType = mediaType;
        if (isSupportVideoConf)
        {
            confTypeDisplayArray = @[@(CONF_MEDIATYPE_VOICE),
                                     @(CONF_MEDIATYPE_VIDEO),
                                     @(CONF_MEDIATYPE_DATA),
                                     @(CONF_MEDIATYPE_VIDEO_DATA)];
        }
        else
        {
            confTypeDisplayArray = @[@(CONF_MEDIATYPE_VOICE),
                                     @(CONF_MEDIATYPE_DATA)];
        }
    }
    return self;
}

- (void)dealloc
{
    self.delegate = nil;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (NSString *)descriptionByConfMediaType:(EC_CONF_MEDIATYPE)mediaType
{
    NSString *description = @"";
    switch (mediaType) {
        case CONF_MEDIATYPE_VOICE:
//            description = NSLocalizedString(@"conference_call", @"语音会议");
            description = @"Voice confernece";
            break;
        case CONF_MEDIATYPE_DATA:
//            description = NSLocalizedString(@"conference_data_type", @"数据会议");
            description = @"Data conference";
            break;
        case CONF_MEDIATYPE_VIDEO:
//            description = NSLocalizedString(@"conference_video_type", @"视频会议");
            description = @"Video confernece";
            
            break;
        case CONF_MEDIATYPE_VIDEO_DATA:
//            description = NSLocalizedString(@"conference_data_video_type", @"视频+数据会议");
            description = @"Video+data conference";
            break;
        default:
            break;
    }
    return description;
}

#pragma mark -
#pragma mark UITableViewDataSource、UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return confTypeDisplayArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"confCreateConfTypeChooseTableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (nil == cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    EC_CONF_MEDIATYPE cellType = [[confTypeDisplayArray objectAtIndex:indexPath.row] intValue];
    BOOL isSelected = (self.selectedConfMediaType == cellType);
    NSString *title = [self descriptionByConfMediaType:cellType];
    cell.textLabel.text = title;
    cell.accessoryType = isSelected ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.selectedConfMediaType = [[confTypeDisplayArray objectAtIndex:indexPath.row] intValue];
    if ([_delegate respondsToSelector:@selector(confMediaTypeSelectedWithConfMediaType:)]) {
        [_delegate confMediaTypeSelectedWithConfMediaType:_selectedConfMediaType];
    }
    [self.navigationController popViewControllerAnimated:YES];
    
}

@end
