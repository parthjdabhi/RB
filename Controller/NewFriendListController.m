//
//  NewFriendListController.m
//  RB
//
//  Created by hjc on 15/12/15.
//  Copyright © 2015年 hjc. All rights reserved.
//

#import "NewFriendListController.h"
#import "NewFriendCell.h"
#import "IMDAO.h"
#import "NetWorkManager.h"
#import "AppProfile.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface NewFriendListController ()

@end

@implementation NewFriendListController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _users = [[IMDAO shareInstance] getMakeFriendRecordsByUid:[MUser currentUser].uid];
    
    UINib *nib = [UINib nibWithNibName:@"NewFriendCell" bundle:nil];
    [_tableView registerNib:nib forCellReuseIdentifier:@"NewFriendCell"];
}

- (void)viewWillAppear:(BOOL)animated {    
    NSInteger noticeCount = [[AppProfile instance] getNoticeUnreadCount];
    
    if (noticeCount > 0) {
        [[AppProfile instance] incrNoticeUnreadCount:-noticeCount];
    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _users.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NewFriendCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NewFriendCell" forIndexPath:indexPath];
    cell.delegate = self;
    
    NSUInteger row = [indexPath row];
    MUser *u = (MUser *)[_users objectAtIndex:row];
    cell.uid = u.uid;
    cell.nameLabel.text = u.nickname;
    cell.commentLabel.text = u.comment;

    NSURL *url = [NSURL URLWithString:u.avatarUrl];
    [cell.avatarImageView sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"avater_default.png"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        
    }];
    
    cell.avatarImageView.contentMode = UIViewContentModeScaleAspectFit;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (u.isFriend) {
        [cell.handleBtn setTitle:@"已添加" forState:UIControlStateNormal];
        [cell.handleBtn setAdjustsImageWhenHighlighted:NO];
        cell.handleBtn.enabled = NO;
    }
    
    return cell;
}

#pragma mark - NewFriendCell delegate
- (void) btnOnClick:(NSDictionary *) dict {
    NSInteger uid = [[dict objectForKey:@"uid"] intValue];
    
    [[NetWorkManager sharedInstance] passFriendVerifyToUid:uid
                                                   success:^(NSDictionary *responseObject) {
                                                      
                                                       MFriend *user = [[MFriend alloc] init];
                                                       user.uid = uid;
                                                       user.isFriend = YES;
                                                       user.stamp = [[NSDate date] timeIntervalSince1970] * 1000;
                                                       
                                                       [[IMDAO shareInstance] updateMakeFriendRecord:user];
                                                       [[IMDAO shareInstance] saveFriend:user];
                                                       
                                                       _users = [[IMDAO shareInstance] getMakeFriendRecordsByUid:[MUser currentUser].uid];
                                                       [_tableView reloadData];
                                                       
                                                       IMNotification *n = [[IMNotification alloc] initWithFrom:0 to:0 target:0 type:3 stamp:[[NSDate date] timeIntervalSince1970] * 1000 contentType:2 messageContent:@"你们可以开始聊天了" uid:@(uid).intValue];
                                                       [[IMDAO shareInstance] saveRecvNotification:n];
                                                       
                                                   } fail:^(NSError *error) {
                                                       
                                                   }];
    
}

#pragma mark navigatorItem handle
- (void)go2PreViewController {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
