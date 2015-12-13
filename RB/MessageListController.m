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
#import "User.h"
#import "Dialog.h"
#import "IMDAO.h"
#import "DialogItemCell.h"
#import "MessageDetailViewController.h"

@interface MessageListController (){
    IMClient *client;
}

@end

@implementation MessageListController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onReceivedMsgNotifycation:) name:ReceiveMessageNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onUpdateConnStatusNotifycation:) name:UpdateConnectionStatusNotification object:nil];
    
    UINib *nib = [UINib nibWithNibName:@"DialogItemCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"DialogItemCell"];
    
    _dialogs = [[IMDAO shareInstance] getDialogs];
    [self connectIM];
}

-(instancetype) init {
    self = [super init];
    if (self) {
        self.tabBarItem.title = @"消息";
        UIImage *i = [UIImage imageNamed:@"iconfont-message.png"];
        self.tabBarItem.image = i;
        
        [[AppProfile shareInstace] incrUnreadCount:[[IMDAO shareInstance] getUnreadCount]];
    }
    
    return self;
}

- (void) viewWillAppear:(BOOL)animated {
    _dialogs = [[IMDAO shareInstance] getDialogs];
    [self.tableView reloadData];
    
    UITabBarItem *tabBarItem = [self.tabBarController.tabBar.items objectAtIndex:0];
    int badgeValue = [[AppProfile shareInstace] getUnreadCount];
    if (badgeValue > 0) {
        tabBarItem.badgeValue = [NSString stringWithFormat:@"%d", [[AppProfile shareInstace] getUnreadCount]];
    } else {
        tabBarItem = nil;
    }
    
    [self displayNavItemTitle];
}

- (void) connectIM {
    
    ConnectionConfig *config = [[ConnectionConfig alloc] initWithIp:@"192.168.0.103" port:10101 appVersion:@"golo/5.0"];
    [IMClient setConfig:config];
    client = [IMClient shareInstace];
    [client connectWithUid:[User currentUser].uid accessToken: [User currentUser].accessToken];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DialogItemCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DialogItemCell" forIndexPath:indexPath];
    NSUInteger row = [indexPath row];
    Dialog *dialog = (Dialog *)[_dialogs objectAtIndex:row];
    cell.title.text = dialog.name;
    //    avater.image = [UIImage imageNamed:dialog.avater];
    
    cell.avater.image = [UIImage imageNamed:[NSString stringWithFormat:@"avater_%d.jpg", dialog.uid]];
    if (!cell.avater.image) {
        cell.avater.image = [UIImage imageNamed:@"photo.png"];
    }
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
        [formatter setDateFormat:@"yyyy-MM-dd"];
        cell.time.text = [formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:dialog.stamp]];
    }
    
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dialogs.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    //    MessageController *messageController = [[MessageController alloc] initWithNibName:@"MessageController" bundle:nil];
//    //    [self.navigationController pushViewController:messageController animated:true];
//    [self performSegueWithIdentifier:@"showMessageController" sender:self];
//}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    Dialog *dialog = (Dialog *)[_dialogs objectAtIndex:indexPath.row];
    [[IMDAO shareInstance] deleteDialogWithId: dialog.uid];
    _dialogs = [[IMDAO shareInstance] getDialogs];
    [tableView reloadData];
}

//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    if ([segue.identifier isEqualToString:@"showMessageController"]) {
//        NSIndexPath *indexPath = [[self.view.subviews objectAtIndex:0] indexPathForCell:sender];
//        Dialog *dialog = (Dialog *)[_dialogs objectAtIndex:indexPath.row];
//        MessageDetailViewController *messageController = segue.destinationViewController;
////        messageController.uid = dialog.uid;
////        NSLog(@"push MessageController dialog with:%d", dialog.uid);
//    }
//}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    MessageDetailViewController *mdvc = [[MessageDetailViewController alloc] init];
    Dialog *dialog = (Dialog *)[_dialogs objectAtIndex:indexPath.row];
    mdvc.uid = dialog.uid;
    mdvc.target = [[IMDAO shareInstance] getUserWithUid:dialog.uid];

    [self.navigationController pushViewController:mdvc animated:YES];
}

-(void) onReceivedMsgNotifycation:(NSNotification *)aNotifacation
{
    dispatch_sync(dispatch_get_main_queue(), ^{
        [[AppProfile shareInstace] incrUnreadCount:1];
        int unreadCount = [[AppProfile shareInstace] getUnreadCount];
        UITabBarItem *tabBarItem = [self.tabBarController.tabBar.items objectAtIndex:0];
        if (unreadCount > 0) {
            tabBarItem.badgeValue = [NSString stringWithFormat:@"%d", unreadCount];
        } else {
            tabBarItem.badgeValue = nil;
        }

        if(self.isViewLoaded && self.view.window) {
            _dialogs = [[IMDAO shareInstance] getDialogs];
            [self.tableView reloadData];
        }
    });
}

-(void) onUpdateConnStatusNotifycation:(NSNotification *)aNotifacation {
    [self displayNavItemTitle];
}

-(void) displayNavItemTitle {
    UINavigationItem *item = [[self.navigationController.viewControllers firstObject] navigationItem];
    if ([IMClient shareInstace].connection.status == Connecting) {
        [item setTitle: @"连接中"];
    } else if([IMClient shareInstace].connection.status == Binding) {
        [item setTitle: @"收取中"];
    } else if([IMClient shareInstace].connection.status == Connected) {
        [item setTitle: @"已连接" ];
    } else if([IMClient shareInstace].connection.status == Disconnected) {
        [item setTitle: @"已断开" ];
    }
}

@end
