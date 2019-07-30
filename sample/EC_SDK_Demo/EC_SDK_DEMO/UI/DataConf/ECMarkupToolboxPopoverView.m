//
//  MarkupToolOptionsPopoverView.m
//  MarkupView
//
//  Created by Eric on 2018/10/16.
//  Copyright © 2018年 Eric. All rights reserved.
//

#import "ECMarkupToolboxPopoverView.h"
#import "Utils.h"
#define BACKGROUND_COLOR [UIColor colorWithRed:58.0/255 green:58.0/255 blue:58.0/255 alpha:1.0]

@interface ECMarkupToolboxPopoverView () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, copy) NSArray *data;
@property (nonatomic, copy) NSArray *images;
@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, strong) CAShapeLayer *arrowLayer;
@property (nonatomic,assign) NSUInteger count;
@property (nonatomic,assign) CGFloat scale;

@end

@implementation ECMarkupToolboxPopoverView

#pragma mark - view's lifecycle
- (instancetype)init {
    return [self initWithFrame:CGRectZero data:@[] images:@[] arrowType:ECMarkupToolboxPopoverViewArrowTypeDown];
}


- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame data:@[] images:@[] arrowType:ECMarkupToolboxPopoverViewArrowTypeDown];
}


- (instancetype)initWithFrame:(CGRect)frame data:(NSArray<NSString *> *)data images:(NSArray<UIImage *> *)images arrowType:(ECMarkupToolboxPopoverViewArrowType)arrowType {
    self = [super initWithFrame:frame];
    
    if (self) {
        if (images) {
            _images = [images copy];
            _count = images.count;
        }
        if (data) {
            _data = [data copy];
            _count = data.count;
        }
        
        CGFloat toolboxViewWith = kMainScreenWidth>kMainScreenHeight? kMainScreenHeight:kMainScreenWidth;
        _scale = toolboxViewWith/414;
        _arrowType = arrowType;
        self.backgroundColor = [UIColor clearColor];
        
        _arrowLayer = [CAShapeLayer layer];
        _arrowLayer.fillColor = BACKGROUND_COLOR.CGColor;
        [self.layer addSublayer:_arrowLayer];
        CGRect tableViewFrame;
        if (arrowType == ECMarkupToolboxPopoverViewArrowTypeUp) {
            tableViewFrame = CGRectMake(0, CGRectGetHeight(frame)*0.1, CGRectGetWidth(frame), CGRectGetHeight(frame) * 0.9);
        }else{
            tableViewFrame = CGRectMake(0, 0, CGRectGetWidth(frame), CGRectGetHeight(frame) * 0.9);
        }
        UITableView *tableView = [[UITableView alloc] initWithFrame:tableViewFrame];
        tableView.delegate = self;
        tableView.dataSource = self;
        [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
        tableView.scrollEnabled = NO;
        tableView.backgroundColor = [UIColor clearColor];
        if (_data) {
            tableView.separatorColor = [UIColor colorWithRed:97.0/255 green:97.0/255 blue:97.0/255 alpha:1.0];
        }else{
            tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        }
        [self addSubview:tableView];
        _tableView = tableView;
    }
    
    return self;
}


#pragma mark - drawing method
- (void)drawRect:(CGRect)rect {
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    
    if (self.arrowType==ECMarkupToolboxPopoverViewArrowTypeUp) {
        [bezierPath moveToPoint:CGPointMake(0, CGRectGetHeight(rect))]; //move to view's origin
        [bezierPath addLineToPoint:CGPointMake(0, CGRectGetHeight(rect) * 0.1)]; //top right corner
        [bezierPath addLineToPoint:CGPointMake(CGRectGetWidth(rect) * 0.3, CGRectGetHeight(rect) * 0.1)];
        [bezierPath addLineToPoint:CGPointMake(CGRectGetWidth(rect) * 0.5, CGRectGetHeight(rect) * 0.03)];
        [bezierPath addLineToPoint:CGPointMake(CGRectGetWidth(rect) * 0.7, CGRectGetHeight(rect) * 0.1)];
        [bezierPath addLineToPoint:CGPointMake(CGRectGetWidth(rect), CGRectGetHeight(rect) * 0.1)];
        [bezierPath addLineToPoint:CGPointMake(CGRectGetWidth(rect), CGRectGetHeight(rect))]; //lower left corner
        [bezierPath closePath];
    }else{
        [bezierPath moveToPoint:CGPointZero]; //move to view's origin
        [bezierPath addLineToPoint:CGPointMake(CGRectGetWidth(rect), 0)]; //top right corner
        [bezierPath addLineToPoint:CGPointMake(CGRectGetWidth(rect), CGRectGetHeight(rect) * 0.9)]; //lower right corner - arrow height (10% of height)
        [bezierPath addLineToPoint:CGPointMake(CGRectGetWidth(rect) * 0.7, CGRectGetHeight(rect) * 0.9)]; //+10% from bottom edge middle
        [bezierPath addLineToPoint:CGPointMake(CGRectGetWidth(rect) * 0.5, CGRectGetHeight(rect) * 0.97)]; //arrow vertex
        [bezierPath addLineToPoint:CGPointMake(CGRectGetWidth(rect) * 0.3, CGRectGetHeight(rect) * 0.9)]; //-10% from bottom edge middle
        [bezierPath addLineToPoint:CGPointMake(0, CGRectGetHeight(rect) * 0.9)]; //lower left corner
        [bezierPath closePath];
    }
    self.arrowLayer.path = bezierPath.CGPath;
}


#pragma mark - UITableView delegate and data source methods
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [[UIView alloc] initWithFrame:CGRectZero];
}


- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 1.0;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return CGRectGetHeight(tableView.frame) / self.count;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UIView *backgroundView = [[UIView alloc] init];
    backgroundView.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.1];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell" forIndexPath:indexPath];
    //cell.selectionStyle=UITableViewCellSelectionStyleGray;
    if (self.data && self.data.count>indexPath.row) {
        cell.textLabel.text = self.data[indexPath.row];
        cell.textLabel.textColor = [UIColor whiteColor];
    }
    if (self.images && self.images.count>indexPath.row) {
        UIImageView *imageView=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 16*_scale, 16*_scale)];
        imageView.image=self.images[indexPath.row];
        imageView.center=cell.contentView.center;
        [cell.contentView addSubview:imageView];
    }
    cell.backgroundColor = BACKGROUND_COLOR;
    cell.selectedBackgroundView = backgroundView;
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.delegate markupToolboxPopoverView:self didSelectOptionAtIndex:indexPath.row];
}

@end
