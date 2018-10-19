//
//  SiteViewTableViewDataSouce.m
//  TUP_Mobile_Conference_Demo
//
//  Created by lwx308413 on 16/8/12.
//  Copyright © 2016年 huawei. All rights reserved.
//

#import "SiteViewTableViewDataSouce.h"
//#import "TupSite.h"
#import "ConfData.h"
#import "CommonUtils.h"
#import "ConfAttendee.h"
#import "TUPLoginInfo.h"
#import "TUPService.h"
#import "ConfAttendeeInConf.h"

@interface SiteViewTableViewDataSouce()


@end

@implementation SiteViewTableViewDataSouce

-(instancetype)init
{
    if (self = [super init])
    {
        _siteListMutArray = [[NSMutableArray alloc] init];
    }
    return self;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _siteListMutArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"siteCell"];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"siteCell"];
    }
    ConfAttendeeInConf *attendee = _siteListMutArray[indexPath.row];
    TUPLOG(@"attendee.number------:%@",attendee.number);
    NSString *muteState = attendee.is_mute ? @"YES" : @"NO";
    NSString *sipAccount = [TUPService callService].sipAccount;
    NSArray *array = [sipAccount componentsSeparatedByString:@"@"];
    NSString *shortSipNum = array[0];
    UILOG(@"_hostNumber:%@,_presentNumber:%@",_hostNumber,_presentNumber);
    if ([attendee.number isEqualToString:sipAccount] || [attendee.number isEqualToString:shortSipNum])
    {
        NSString *cellTextStr = [NSString stringWithFormat:@"%@(Me),mute:%@",attendee.number,muteState];
        if ([_presentNumber isEqualToString:shortSipNum])
        {
            cellTextStr = [cellTextStr stringByAppendingString:@",persenter:YES"];
        }
        if ([_hostNumber isEqualToString:shortSipNum])
        {
            cellTextStr = [cellTextStr stringByAppendingString:@",chair:YES"];
        }
        cell.textLabel.text = cellTextStr;
    }
    else
    {
        NSString *cellTextStr = [NSString stringWithFormat:@"%@,mute:%@",attendee.number,muteState];
        if ([_presentNumber isEqualToString:attendee.number])
        {
            cellTextStr = [cellTextStr stringByAppendingString:@",persenter:YES"];
        }
        if ([_hostNumber isEqualToString:attendee.number])
        {
            cellTextStr = [cellTextStr stringByAppendingString:@",chair:YES"];
        }
        cell.textLabel.text = cellTextStr;
    }
    if (attendee.state == ATTENDEE_STATUS_IN_CONF)
    {
        cell.textLabel.textColor = [UIColor blackColor];
    }
    else
    {
        cell.textLabel.textColor = [UIColor grayColor];
    }
    return cell;
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Participants List:";
}
@end
