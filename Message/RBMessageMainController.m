//
//  MessageListController.m
//  R&B
//
//  Created by hjc on 15/11/27.
//  Copyright © 2015年 hjc. All rights reserved.
//

#import "RBMessageMainController.h"

#import "IMClient.h"

#import "AppProfile.h"
#import "RBNotificationContants.h"
#import "MUser.h"
#import "MDialog.h"
#import "MMessage.h"
#import "IMDAO.h"

#import "RBMessageObserver.h"
#import "NoticeObserver.h"
#import "RBDialogItemCell.h"
#import "RBDialogDetailController.h"

#import <SDWebImage/UIImageView+WebCache.h>

@implementation RBMessageMainController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadDialogData:)
                                                 name:ReloadDialogDataNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadDialogData:)
                                                 name:ReceiveNoticeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onUpdateConnStatusNotification:)
                                                 name:UpdateConnectionStatusNotification object:nil];
    
    [self.tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    
    _dialogs = [[IMDAO shareInstance] getDialogs];
    [self.tableView reloadData];
    
    [self displayNavItemTitle];
}

- (void) viewWillAppear:(BOOL)animated {
//    _dialogs = [[IMDAO shareInstance] getDialogs];
//    [self.tableView reloadData];
//    
//    [self displayNavItemTitle];
//    NSLog(@"viewWillAppear");
}

- (void) viewDidAppear:(BOOL)animated {
    _dialogs = [[IMDAO shareInstance] getDialogs];
    [self.tableView reloadData];
    
    [self displayNavItemTitle];
}

- (void) viewWillDisappear:(BOOL)animated {
//    NSLog(@"viewWillDisappear");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark tableview delegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RBDialogItemCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RBDialogItemCell"];
    
    MDialog *dialog = (MDialog *)[_dialogs objectAtIndex:[indexPath row]];
    cell.subTitle.text = dialog.desc;
    cell.time.text = [self formatDisplayDate:[NSDate dateWithTimeIntervalSince1970:dialog.stamp]];
    [cell setUnreadCount:dialog.unreadCount];
    
    MFriend *friend = [[IMDAO shareInstance] getFriendWithId:dialog.uid];
    cell.title.text = friend.displayName;
    
    NSURL *url = [NSURL URLWithString:friend.avatarUrl];
    [cell.avatar sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"avater_default.png"]];
    
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dialogs.count;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    MDialog *dialog = (MDialog *)[_dialogs objectAtIndex:indexPath.row];
    [[IMDAO shareInstance] deleteDialogWithId: dialog.uid];
    
    _dialogs = [[IMDAO shareInstance] getDialogs];
    [tableView reloadData];
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:[RBDialogDetailController class]]) {
        RBDialogDetailController *mdvc = segue.destinationViewController;
        NSInteger row = self.tableView.indexPathForSelectedRow.row;
        MDialog *dialog = (MDialog *)[_dialogs objectAtIndex:row];
        
        mdvc.sender = [MUser currentUser];
        
        if (dialog.type == 2) {
            mdvc.groupId = dialog.uid;
            
        } else {
            mdvc.userId = dialog.uid;
            mdvc.target = [[IMDAO shareInstance] getUserWithUid:dialog.uid];
        }
        
        mdvc.hidesBottomBarWhenPushed = YES;
    }
}

#pragma mark - handle notification

-(void) reloadDialogData:(NSNotification *)aNotification {
    
    if(self.isViewLoaded && self.view.window) {
        dispatch_async(dispatch_get_main_queue(), ^{
            _dialogs = [[IMDAO shareInstance] getDialogs];
            [self.tableView reloadData];
        });
    }
}

-(void) onUpdateConnStatusNotification:(NSNotification *)aNotification {
    [self displayNavItemTitle];
}

-(void) displayNavItemTitle {
    UINavigationItem *item = self.navigationItem;
    if (self.isViewLoaded) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([IMClient instance].connection.status == Connecting) {
                [item setTitle: @"消息（连接中）"];
            } else if([IMClient instance].connection.status == Binding) {
                [item setTitle: @"消息（收取中）"];
            } else if([IMClient instance].connection.status == Connected) {
                [item setTitle: @"消息（已连接）" ];
            } else if([IMClient instance].connection.status == Disconnected) {
                [item setTitle: @"消息（已断开）" ];
            }
        });
    }

}

-(NSString *) formatDisplayDate:(NSDate *) date {
    NSCalendar *greCalendar = [[NSCalendar alloc] initWithCalendarIdentifier: NSCalendarIdentifierGregorian];
    NSCalendarUnit unit = NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear;
    NSDateComponents *cmps = [greCalendar components:unit fromDate:date toDate:[NSDate date] options:0];
    
    if (cmps.year == 0 && cmps.month == 0 && cmps.day == 1) {
        return [NSString stringWithFormat:@"昨天"];
        
    } else if (cmps.year == 0 && cmps.month == 0 && cmps.day == 0) {
        NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"HH:mm"];
        return [formatter stringFromDate:date];
        
    } else {
        NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MM-dd"];
        return [formatter stringFromDate:date];
    }
}

@end
