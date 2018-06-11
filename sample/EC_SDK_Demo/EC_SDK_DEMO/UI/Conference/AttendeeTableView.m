//
//  AttendeeTableView.m
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

#import "AttendeeTableView.h"

@implementation AttendeeTableView

-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.frame = frame;
        _attendees = [[NSArray alloc]init];
        self.rowHeight = 25;
    }
    return self;
}
-(void)setAttendees:(NSArray *)attendees
{
    _attendees = attendees;
}

-(NSInteger)numberOfRowsInSection:(NSInteger)section{
    return _attendees.count;
}

-(UITableViewCell *)cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [self dequeueReusableCellWithIdentifier:@"cell"];
    if (nil == cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    cell.textLabel.text = _attendees[indexPath.row];
    return cell;
}

@end
