//
//  CameraInfoView.m
//  TUP_Mobile_DataConference_Demo
//
//  Created by lwx308413 on 16/12/19.
//  Copyright © 2016年 huawei. All rights reserved.
//

#import "CameraInfoView.h"
#import "ConfCameraInfo.h"

@interface CameraInfoView()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *cameraTabelView;
@end

@implementation CameraInfoView

+(instancetype)sharedInstance
{
    static CameraInfoView *_cameraInfo = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _cameraInfo = [[CameraInfoView alloc] init];
    });
    return _cameraInfo;
}

-(instancetype)init
{
    self = [super init];
    if (self) {
        NSArray *xibArray = [[NSBundle mainBundle] loadNibNamed:@"CameraInfoView" owner:self options:nil];
        self = xibArray[0];
        _cameraInfoArray = [[NSMutableArray alloc] init];
        _cameraTabelView.delegate = self;
        _cameraTabelView.dataSource = self;
        
        return self;
    }
    return nil;
}

-(void)showCameraInfoViewIn:(UIView *)superView delegate:(id)delegate
{
    [self removeFromSuperview];
    self.frame = CGRectMake(10, 10, [UIScreen mainScreen].bounds.size.width - 20, [UIScreen mainScreen].bounds.size.height - 20);
    [superView addSubview:self];
    self.delegate = delegate;
    NSLog(@"_cameraInfoArray----- :%@",_cameraInfoArray);
    [self.cameraTabelView reloadData];
}

- (IBAction)closeButtonAction:(id)sender
{
    [self removeFromSuperview];
}

-(void)setCamreaInfoArray:(NSMutableArray *)camreaInfoArray
{
    _cameraInfoArray = camreaInfoArray;
    [self.cameraTabelView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _cameraInfoArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CameraCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CamreaCell"];
    }
    ConfCameraInfo *camreaInfo = _cameraInfoArray[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%d",camreaInfo.userId];
    cell.textLabel.text = [NSString stringWithFormat:@"%@, device id :%d",camreaInfo.cameraName,camreaInfo.deviceId];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ConfCameraInfo *camreaInfo = _cameraInfoArray[indexPath.row];
    if ([self.delegate respondsToSelector:@selector(didSelectedCameraInfo:)])
    {
        [self.delegate didSelectedCameraInfo:camreaInfo];
    }
}
@end
