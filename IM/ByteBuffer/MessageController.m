//
//  ViewController.m
//  ByteBuffer
//
//  Created by hjc on 14-6-1.
//  Copyright (c) 2014年 hjc. All rights reserved.
//

#define IS_IPHONE5 (568.0f==[UIScreen mainScreen].bounds.size.height)
#define IS_IOS7  ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
#define IS_UP_IOS6 ([[UIDevice currentDevice].systemVersion floatValue] >= 6.0)

#define ReceiveMessageNotification  @"ReceiveMessageNotification"

#import "MessageController.h"
#import "IMClient.h"
#import "WeiXinCell.h"
#import "Message.h"
#import "IMDAO.h"

@interface MessageController()
{
    Connection *connection;
}

@end

@implementation MessageController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onReceivedMsgNotifycation:) name:ReceiveMessageNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(changeKeyBoard:) name:UIKeyboardWillChangeFrameNotification object:nil];
    
    //注册收起键盘手势
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dissKeyBoard:)];
    //设置成NO表示当前控件响应后会传播到其他控件上，默认为YES。
    tapGestureRecognizer.cancelsTouchesInView = NO;
    //将触摸事件添加到当前view
    [self.view addGestureRecognizer:tapGestureRecognizer];
    
//    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"weixin",@"name",@"微信团队欢迎你。很高兴你开启了微信生活，期待能为你和朋友们带来愉快的沟通体检。",@"content", nil];
//    NSDictionary *dict1 = [NSDictionary dictionaryWithObjectsAndKeys:@"rhl",@"name",@"hello",@"content", nil];
//    NSDictionary *dict2 = [NSDictionary dictionaryWithObjectsAndKeys:@"rhl",@"name",@"0",@"content", nil];
//    NSDictionary *dict3 = [NSDictionary dictionaryWithObjectsAndKeys:@"weixin",@"name",@"谢谢反馈，已收录。",@"content", nil];
//    NSDictionary *dict4 = [NSDictionary dictionaryWithObjectsAndKeys:@"rhl",@"name",@"0",@"content", nil];
//    NSDictionary *dict5 = [NSDictionary dictionaryWithObjectsAndKeys:@"weixin",@"name",@"谢谢反馈，已收录。",@"content", nil];
//    NSDictionary *dict6 = [NSDictionary dictionaryWithObjectsAndKeys:@"rhl",@"name",@"大数据测试，长数据测试，大数据测试，长数据测试，大数据测试，长数据测试，大数据测试，长数据测试，大数据测试，长数据测试，大数据测试，长数据测试。",@"content", nil];
//    
//    _resultArray = [NSMutableArray arrayWithObjects:dict,dict1,dict2,dict3,dict4,dict5,dict6, nil];
    
    int uid = _uid;
    NSArray *msgs = [[IMDAO shareInstance] getMessageWithUid:uid];
    
    _resultArray = [[NSMutableArray alloc] init];
    for (Message *msg in msgs) {
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d",msg.from], @"name", msg.messageBody, @"content", msg.from == [User currentUser].uid ? @"1":@"0", @"mine", nil];
        [_resultArray addObject:dict];
    }
    
    if(_resultArray.count > 0) {
        [_tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:_resultArray.count-1 inSection:0] animated:false scrollPosition:UITableViewScrollPositionBottom];
    }
        
//    connection = [Connection shareInstace];
//    [connection connect];
}

//- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//{
//    self = [super initWithNibName:@"GOIMMsgDetailController" bundle:nibBundleOrNil];
//
//    return self;
//}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _resultArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dict = [_resultArray objectAtIndex:indexPath.row];
    UIFont *font = [UIFont systemFontOfSize:14];
	CGSize size = [[dict objectForKey:@"content"] sizeWithFont:font constrainedToSize:CGSizeMake(180.0f, 20000.0f) lineBreakMode:NSLineBreakByWordWrapping];
    
    return size.height+44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"WeiXinCell";
    WeiXinCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[WeiXinCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
    }
    
    NSMutableDictionary *dict = [_resultArray objectAtIndex:indexPath.row];
    [cell setContent:dict];
    
    return cell;
    
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
//    NSLog(@"%@", string);
    if ([string isEqualToString:@"\n"]) {
        [textField resignFirstResponder];
        return NO;
    }
    return YES;
}

-(void)changeKeyBoard:(NSNotification *)aNotifacation
{
    //    for (UIGestureRecognizer *g in self.mm_drawerController.view.gestureRecognizers)
    //    {
    //        g.delegate = self;
    //    }
    
    NSValue *keyboardEndBounds=[[aNotifacation userInfo]objectForKey:UIKeyboardFrameEndUserInfoKey];
    
    CGRect endRect=[keyboardEndBounds CGRectValue];
    
    
    [UIView animateWithDuration:[[aNotifacation.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue]
                          delay:0.0f
                        options:[[aNotifacation.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue]
                     animations:^
     {
         CGPoint Point = CGPointMake(160, endRect.origin.y - 22 );
         
         if (IS_IPHONE5) {
             CGPoint tablePoint =CGPointMake(160, 524/2.0-(568-endRect.origin.y));
             
             if(!IS_IOS7)
             {
                 _tableView.center = CGPointMake(160, 524/2.0-(568-endRect.origin.y)-15);
                 Point.y = Point.y-20;
             }
             else
                 _tableView.center = tablePoint;
         }
         else
         {
             CGPoint tablePoint =CGPointMake(160, 217.f-(480-endRect.origin.y));
             _tableView.center = tablePoint;
             if(!IS_IOS7)
             {
                 Point.y = Point.y -20;
             }
         }
         
         _inputBar.center = Point;
     }
        completion:^(BOOL finished)
     {
         
     }];
}


- (void)dissKeyBoard:(NSNotification *)note
{
    [_input resignFirstResponder];
}

- (IBAction)sendMessage:(id)sender {
    
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          [NSString stringWithFormat:@"%d", [User currentUser].uid], @"name",
                            _input.text, @"content", @"1", @"mine", nil];
    [_resultArray addObject:dict];
    [_tableView reloadData];
    [[IMClient shareInstace] sendMessageToUid:self.uid content:_input.text];
    [self refreshMessageList];
    _input.text = nil;
}

- (IBAction)switchInputType:(id)sender {
//    _voiceBtn.titleLabel.text = @"2";
}


-(void) onReceivedMsgNotifycation:(NSNotification *)aNotifacation
{
    Message *message = (Message *)[aNotifacation object];
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d",message.from], @"name", message.messageBody, @"content", @"0", @"mine", nil];
    dispatch_sync(dispatch_get_main_queue(), ^{
        [_resultArray addObject:dict];
        [_tableView reloadData];
        [self refreshMessageList];
    });
}

-(void) refreshMessageList
{
    if(_resultArray.count > 0)
    {
        [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_resultArray.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

@end
