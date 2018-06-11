//
//  IMView.m
//  TUP_Mobile_DataConference_Demo
//
//  Created by lwx308413 on 16/11/22.
//  Copyright © 2016年 huawei. All rights reserved.
//

#import "IMView.h"
#import "TUPChatMsg.h"
#import "TUPLoginInfo.h"
#import "TUPService.h"

@interface IMView ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITextField *messageTextField;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;
@property (weak, nonatomic) IBOutlet UITableView *msgTableView;
@property (strong, nonatomic) NSMutableArray *dataArray;
@property (strong, nonatomic) UITableViewCell *dataCell;
@end

@implementation IMView

+(instancetype)shareInstance
{
    static IMView *_iMView = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _iMView = [[IMView alloc] init];
    });
    return _iMView;
    
}

-(instancetype)init
{
    self = [super init];
    if (!self)
    {
        return nil;
    }
    _dataArray = [[NSMutableArray alloc] init];
    self.msgTableView.delegate = self;
    self.msgTableView.dataSource = self;
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"IMView" owner:self options:nil];
    self = [nib objectAtIndex:0];
    return self;
}

-(void)showIMViewWithFrame:(CGRect)frame inSuperView:(UIView *)superView delegate:(id)delegate
{
    self.frame = frame;
    [superView addSubview:self];
    self.delegate = delegate;
}

-(void)hideIMView
{
    [self removeFromSuperview];
}

- (IBAction)onSendButtonPress:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(sendButtonAction:)])
    {
        [self.delegate sendButtonAction:self.messageTextField.text];
    }
}

-(void)refreshData
{
    [self.msgTableView reloadData];
}

-(void)configDataWithArray:(NSMutableArray *)dataArray
{
    self.dataArray = dataArray;
    [self.msgTableView reloadData];
    [self scrollTableToFoot:YES];
}

- (IBAction)onCloseButtonPress:(id)sender
{
    [self removeFromSuperview];
}

-(void)cleanTextFileContent
{
    self.messageTextField.text = @"";
}

#pragma mark - TableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.dataCell = [tableView dequeueReusableCellWithIdentifier:@"dataCell"];
    if (!_dataCell) {
        _dataCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"dataCell"];
    }
    TUPChatMsg *chatMsg = self.dataArray[indexPath.row];
//    NSString *message = [self filterHTML:chatMsg.lpMsg];
//    self.dataCell.textLabel.text = ;
    self.dataCell.textLabel.attributedText = [self decodeHtmlStr:[NSString stringWithFormat:@"【%@】: %@",chatMsg.fromUserName,chatMsg.lpMsg]];
    return self.dataCell;
}

-(NSAttributedString *)decodeHtmlStr:(NSString *)htmlStr
{
    if( htmlStr.length == 0 )
    {
        return nil;
    }
    NSAttributedString * attrStr = [[NSAttributedString alloc] initWithData:[htmlStr dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
    return attrStr;
}

-(NSString *)filterHTML:(NSString *)html
{
    NSLog(@"orginal html : %@",html);
    if (![html containsString:@"<"])
    {
        return html;
    }
    NSScanner * scanner = [NSScanner scannerWithString:html];
    NSString * text = nil;
    while([scanner isAtEnd]==NO)
    {
        [scanner scanUpToString:@"<" intoString:nil];
        [scanner scanUpToString:@">" intoString:&text];
        html = [html stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@>",text] withString:@""];
    }
    NSLog(@"after html : %@",html);
    return html;
}

- (void)scrollTableToFoot:(BOOL)animated
{
    NSInteger s = [self.msgTableView numberOfSections];
    if (s<1) return;
    NSInteger r = [self.msgTableView numberOfRowsInSection:s-1];
    if (r<1) return;
    NSIndexPath *ip = [NSIndexPath indexPathForRow:r-1 inSection:s-1];
    [self.msgTableView scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionBottom animated:animated];
}

@end
