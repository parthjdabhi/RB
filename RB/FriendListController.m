//
//  FriendListController.m
//  R&B
//
//  Created by hjc on 15/11/28.
//  Copyright © 2015年 hjc. All rights reserved.
//

#import "FriendListController.h"
#import "Friend.h"
#import "FriendItemCell.h"
#import "MessageDetailViewController.h"
#import "SearchAccountController.h"
#import "UserInfoController.h"
#import "NewFriendListController.h"
#import "GroupListController.h"
#import "Dialog.h"
#import "IMDAO.h"
#import "NetWorkManager.h"
#import "AppProfile.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface FriendListController ()

@end

@implementation FriendListController

-(instancetype) init {
    self = [super init];
    if (self) {
        self.tabBarItem.title = @"好友";
        UIImage *i = [UIImage imageNamed:@"iconfont-lianxiren.png"];
        self.tabBarItem.image = i;
    }
    
    [[AppProfile shareInstace] incrNoticeUnreadCount:[[IMDAO shareInstance] getNoticeUnreadCount]];
    _friends = [[IMDAO shareInstance] getFriendsWithUid: [User currentUser].uid];
    
    if (_friends.count == 0) {
//        Friend *f = [[Friend alloc] init];
//        f.nickname = @"Tom";
//        f.uid = 101;
//        
//        Friend *f2 = [[Friend alloc] init];
//        f2.nickname = @"Jim";
//        f2.uid = 102;
//        
//        Friend *f3 = [[Friend alloc] init];
//        f3.nickname = @"Tony";
//        f3.uid = 103;
//        
//        User *u = [[User alloc] init];
//        u.uid = 104;
//        u.nickname = @"Lucy";
//        
//        [[IMDAO shareInstance] saveUsers: @[f, f2, f3, u]];
//        [[IMDAO shareInstance] saveFriends: @[f, f2, f3]];
//        _friends = [[IMDAO shareInstance] getFriendsWithUid: [User currentUser].uid];
        
        [[NetWorkManager sharedInstance] getFriendListWithUid:[User currentUser].uid
                                                      success:^(NSDictionary *responseObject) {
                                                          NSArray *list = [responseObject objectForKey:@"list"];
                                                          
                                                          for (NSDictionary *dict in list) {
                                                              Friend *f = [[Friend alloc] init];
                                                              f.uid = [[dict objectForKey:@"uid"] integerValue];
                                                              f.nickname = [dict objectForKey:@"nickname"];
                                                              f.avaterUrl = [dict objectForKey:@"avater_url"];
                                                              f.signature = [dict objectForKey:@"signature"];
                                                              f.gender = [[dict objectForKey:@"gender"] integerValue];
                                                              [[IMDAO shareInstance] saveUser:f];
                                                              [[IMDAO shareInstance] saveFriend:f];
                                                          }
                                                      }
                                                         fail:^(NSError *error) {
            
                                                         }];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self updateNoticeCount:nil];
    
    UINib *nib = [UINib nibWithNibName:@"FriendItemCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"FriendItemCell"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateNoticeCount:) name:UpdateNoticeCountNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    UINavigationItem *navigationItem = [[self.navigationController.viewControllers firstObject] navigationItem];
    UIButton *rightButton = [[UIButton alloc] initWithFrame:CGRectMake(0,0,30,30)];
    rightButton.titleLabel.text = @"+";
    [rightButton setImage:[UIImage imageNamed:@"iconfont-plus.png"] forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(go2SearchAccountController) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    navigationItem.rightBarButtonItem = rightItem;
    
    _friends = [[IMDAO shareInstance] getFriendsWithUid: [User currentUser].uid];
    [self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated {
    UINavigationItem *navigationItem = [[self.navigationController.viewControllers firstObject] navigationItem];
    navigationItem.rightBarButtonItem = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 2;
    }
    return _friends.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
//        cell.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"avater_%d.jpg", _uid]];
        if (indexPath.row == 0) {
            cell.textLabel.text = @"新好友";
        } else if (indexPath.row == 1) {
            cell.textLabel.text = @"群组";
        }
        return cell;
    } else {
        FriendItemCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FriendItemCell" forIndexPath:indexPath];
        NSUInteger row = [indexPath row];
        Friend *f = (Friend *)[_friends objectAtIndex:row];
        cell.title.text = f.nickname;
        //    NSLog(@"avater_%d.jpg", f.uid);
        
//        cell.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"avater_%d.jpg", f.uid]];
        NSURL *url = [NSURL URLWithString:f.avaterUrl];
        [cell.imageView sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"avater_default.png"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            
        }];
        
        return cell;
    }
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            NewFriendListController *nflc = [[NewFriendListController alloc] init];
            [self.navigationController pushViewController:nflc animated:YES];
        } else {
            GroupListController *glc = [[GroupListController alloc] init];
            [self.navigationController pushViewController:glc animated:YES];
        }
    } else {
        MessageDetailViewController *mdvc = [[MessageDetailViewController alloc] init];
        Friend *f = (Friend *)[_friends objectAtIndex:[indexPath row]];
        mdvc.uid = f.uid;
        mdvc.target = f;
        
        UserInfoController *uic = [[UserInfoController alloc] init];
        uic.uid = f.uid;
        uic.target = f;
        
        [self.navigationController pushViewController:uic animated:YES];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if(section == 0){
        return 10;
    }
    return 10;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    Friend *friend = (Friend *)[_friends objectAtIndex:indexPath.row];
    
    [[NetWorkManager sharedInstance] delFriendWithUid:friend.uid
                                              success:^(NSDictionary *responseObject) {
                                                  [[IMDAO shareInstance] delFriendWithId: friend.uid];
                                                  _friends = [[IMDAO shareInstance] getFriendsWithUid: [User currentUser].uid];
                                                  [tableView reloadData];
                                              } fail:^(NSError *error) {
                                                  
                                              }];
}

- (void) go2SearchAccountController {
    SearchAccountController *sac = [[SearchAccountController alloc] init];
    [self.navigationController pushViewController:sac animated:YES];
//    [self presentViewController:sac animated:YES completion:nil];
}

#pragma mark notification

-(void) updateNoticeCount:(NSNotification *)aNotification {
    int badgeValue = [[AppProfile shareInstace] getNoticeUnreadCount];
    UITabBarItem *tabBarItem = [self.tabBarController.tabBar.items objectAtIndex:1];
    if (badgeValue > 0) {
        tabBarItem.badgeValue = [NSString stringWithFormat:@"%d", badgeValue];
    } else {
        tabBarItem.badgeValue = nil;
    }    
}


@end
