//
//  MessageListController.m
//  R&B
//
//  Created by hjc on 15/11/27.
//  Copyright © 2015年 hjc. All rights reserved.
//

#import "MessageListController.h"
#import "IMClient.h"
#import "AppProfile.h"
#import "ConnectionConfig.h"
#import "MUser.h"
#import "MDialog.h"
#import "MMessage.h"
#import "IMDAO.h"
#import "NoticeObserver.h"
#import "DialogItemCell.h"
#import "MessageDetailViewController.h"
#import "DialogDetailController.h"

#import <SDWebImage/UIImageView+WebCache.h>

#if TARGET_OS_IPHONE

#define IM_SERVER_IP @"54.88.205.144"

#else

#define IM_SERVER_IP @"192.168.0.121"

#endif


@interface MessageListController (){
    IMClient *client;
}

@end

@implementation MessageListController

-(instancetype) init {
    self = [super init];
    if (self) {
        self.tabBarItem.title = @"消息";
        UIImage *i = [UIImage imageNamed:@"tabbarMessage"];
        self.tabBarItem.image = i;        
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [[AppProfile instance] incrMsgUnreadCount:[[IMDAO shareInstance] getMsgUnreadCount]];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onReceivedMsgNotification:) name:ReceiveMessageNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onReceivedNoticeNotification:) name:ReceiveNoticeNotification object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateMsgCount) name:UpdateMsgCountNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onUpdateConnStatusNotification:) name:UpdateConnectionStatusNotification object:nil];
    
    UINib *nib = [UINib nibWithNibName:@"DialogItemCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"DialogItemCell"];
    [self.tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    
    _dialogs = [[IMDAO shareInstance] getDialogs];
    [self connectIM];
}

- (void) viewWillAppear:(BOOL)animated {
    _dialogs = [[IMDAO shareInstance] getDialogs];
    [self.tableView reloadData];
    
    [self updateMsgCount];
    [self displayNavItemTitle];
}

- (void) viewWillDisappear:(BOOL)animated {
//    UINavigationItem *item = [[self.navigationController.viewControllers firstObject] navigationItem];
//    item.title = nil;
}

- (void) connectIM {
    
    ConnectionConfig *config = [[ConnectionConfig alloc] initWithIp:IM_SERVER_IP port:10101 appVersion:@"golo/5.0"];
    [IMClient setConfig:config];
    client = [IMClient shareInstance];
    [client connectWithUid:[MUser currentUser].uid accessToken: [MUser currentUser].accessToken];
    [NoticeObserver shareInstance];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark tableview delegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DialogItemCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DialogItemCell" forIndexPath:indexPath];
    NSUInteger row = [indexPath row];
    MDialog *dialog = (MDialog *)[_dialogs objectAtIndex:row];
    cell.title.text = dialog.name;
    
    MUser *user = [[IMDAO shareInstance] getUserWithUid:dialog.uid];
    NSURL *url = [NSURL URLWithString:user.avatarUrl];
    [cell.avatar sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"avater_default.png"] completed:nil];
    cell.subTitle.text = dialog.desc;
    [cell setUnreadCount:dialog.unreadCount];
    
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm"];
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:dialog.stamp];
    NSCalendar *greCalendar = [[NSCalendar alloc] initWithCalendarIdentifier: NSCalendarIdentifierGregorian];
    NSCalendarUnit unit = NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear;
    NSDateComponents *cmps = [greCalendar components:unit fromDate:date toDate:[NSDate date] options:0];
    
    if (cmps.year == 0 && cmps.month == 0 && cmps.day == 1) {
        cell.time.text = [NSString stringWithFormat:@"昨天"];
    } else if (cmps.year == 0 && cmps.month == 0 && cmps.day == 0) {
        cell.time.text = [formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:dialog.stamp]];
    } else {
        [formatter setDateFormat:@"MM-dd"];
        cell.time.text = [formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:dialog.stamp]];
    }
    
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dialogs.count;
}

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    //    MessageController *messageController = [[MessageController alloc] initWithNibName:@"MessageController" bundle:nil];
//    //    [self.navigationController pushViewController:messageController animated:true];
//    [self performSegueWithIdentifier:@"showMessageController" sender:self];
//}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    MDialog *dialog = (MDialog *)[_dialogs objectAtIndex:indexPath.row];
    [[IMDAO shareInstance] deleteDialogWithId: dialog.uid];
    _dialogs = [[IMDAO shareInstance] getDialogs];
    [tableView reloadData];
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    MessageDetailViewController *mdvc = [[MessageDetailViewController alloc] init];
    DialogDetailController *mdvc = [[DialogDetailController alloc] init];
    MDialog *dialog = (MDialog *)[_dialogs objectAtIndex:indexPath.row];
    
    mdvc.sender = [MUser currentUser];
    if (dialog.type == 2) {
        mdvc.groupId = dialog.uid;
    } else {
        mdvc.userId = dialog.uid;
        mdvc.target = [[IMDAO shareInstance] getUserWithUid:dialog.uid];
    }

    mdvc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:mdvc animated:YES];
}

#pragma mark notification

-(void) onReceivedMsgNotification:(NSNotification *)aNotification {
    Message *rawMessage = (Message *)[aNotification object];
    
    MMessage *message = [[MMessage alloc] init];
    message.senderId = rawMessage.from;
    message.receiverId = rawMessage.to;
    message.isOutput = FALSE;
    message.type = rawMessage.messageType;
    message.rawContent = rawMessage.messageBody;
    message.stamp = rawMessage.stamp / 1000;
    [[IMDAO shareInstance] saveMessage:message];
    
    [[AppProfile instance] incrMsgUnreadCount:1];

    if(self.isViewLoaded && self.view.window) {
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self updateMsgCount];
            _dialogs = [[IMDAO shareInstance] getDialogs];
            [self.tableView reloadData];
        });
    }

}

-(void) updateMsgCount {
    int badgeValue = [[AppProfile instance] getMsgUnreadCount];
    UITabBarItem *tabBarItem = [self.tabBarController.tabBar.items objectAtIndex:0];
    if (badgeValue > 0) {
        tabBarItem.badgeValue = [NSString stringWithFormat:@"%d", badgeValue];
    } else {
        tabBarItem.badgeValue = nil;
    }
}

-(void) onReceivedNoticeNotification:(NSNotification *)aNotification {
    if(self.isViewLoaded && self.view.window) {
        _dialogs = [[IMDAO shareInstance] getDialogs];
        [self.tableView reloadData];
    }
}

-(void) onUpdateConnStatusNotification:(NSNotification *)aNotification {
    [self displayNavItemTitle];
}

-(void) displayNavItemTitle {
//    UINavigationItem *item = [[self.navigationController.viewControllers firstObject] navigationItem];
    UINavigationItem *item = self.navigationItem;
    if (self.isViewLoaded) {
        if ([IMClient shareInstance].connection.status == Connecting) {
//            self.title = @"消息（连接中）";
            [item setTitle: @"消息（连接中）"];
        } else if([IMClient shareInstance].connection.status == Binding) {
//            self.title = @"消息（收取中）";
            [item setTitle: @"消息（收取中）"];
        } else if([IMClient shareInstance].connection.status == Connected) {
//            self.title = @"消息（已连接）";
            [item setTitle: @"消息（已连接）" ];
        } else if([IMClient shareInstance].connection.status == Disconnected) {
//            self.title = @"消息（已断开）";
            [item setTitle: @"消息（已断开）" ];
        }
    }
    
//    self.tabBarItem.title = @"消息";
}

@end
