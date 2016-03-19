//
//  FriendListController.m
//  R&B
//
//  Created by hjc on 15/11/28.
//  Copyright © 2015年 hjc. All rights reserved.
//

#import "FriendListController.h"
#import "MFriend.h"
#import "FriendItemCell.h"
#import "DialogDetailController.h"
#import "SearchAccountController.h"
#import "UserInfoController.h"
#import "NewFriendListController.h"
#import "GroupListController.h"
#import "MDialog.h"
#import "IMDAO.h"
#import "NetWorkManager.h"
#import "AppProfile.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface FriendListController ()
{
    NSArray *_friends;
    NSArray *_friendNameKeys;
    NSDictionary *_friendDict;
}
@end

@implementation FriendListController

-(instancetype) init {
    self = [super init];
    if (self) {
        self.tabBarItem.title = @"好友";
        UIImage *i = [UIImage imageNamed:@"tabbarContact"];
        self.tabBarItem.image = i;
    }
    
    [[AppProfile instance] incrNoticeUnreadCount:[[IMDAO shareInstance] getNoticeUnreadCount]];
    _friends = [[IMDAO shareInstance] getFriendsWithUid: [MUser currentUser].uid];
    
    if (_friends.count == 0) {
        [[NetWorkManager sharedInstance] getFriendListWithUid:[MUser currentUser].uid
                                                      success:^(NSDictionary *responseObject) {
                                                          NSArray *list = [responseObject objectForKey:@"list"];
                                                          
                                                          for (NSDictionary *dict in list) {
                                                              MFriend *f = [[MFriend alloc] init];
                                                              f.uid = [[dict objectForKey:@"uid"] integerValue];
                                                              f.nickname = [dict objectForKey:@"nickname"];
                                                              f.avatarUrl = [dict objectForKey:@"avatar_url"];
                                                              f.avatarThumbUrl = [dict objectForKey:@"avatar_thumb"];
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
    [self.friendTableView registerNib:nib forCellReuseIdentifier:@"FriendItemCell"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateNoticeCount:) name:UpdateNoticeCountNotification object:nil];
    
    UINavigationItem *navigationItem = self.navigationItem;
    
    UIButton *addBuddy = [UIButton buttonWithType:UIButtonTypeCustom];
//    addBuddy.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:18];
    [addBuddy setTitle:@"+" forState:UIControlStateNormal];
    [addBuddy setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [addBuddy setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [addBuddy addTarget:self action:@selector(go2SearchAccountController)
       forControlEvents:UIControlEventTouchUpInside];
    [addBuddy sizeToFit];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithCustomView:addBuddy];
    navigationItem.rightBarButtonItem = rightItem;
    
    [navigationItem setTitle:@"好友"];
}

- (void)viewWillAppear:(BOOL)animated {
    _friends = [[IMDAO shareInstance] getFriendsWithUid: [MUser currentUser].uid];
    
    NSMutableSet *keys = [[NSMutableSet alloc] init];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    
    for (MFriend *f in _friends) {
    
        if (f.nickname) {
            NSString *key = [self firstCharactor:f.nickname];
            [keys addObject:key];
            
            if (!dict[key]) {
                dict[key] = [[NSMutableArray alloc] init];
            }
            [dict[key] addObject:f];
        }
    }
    
    _friendNameKeys = [[keys allObjects] sortedArrayUsingSelector:@selector(compare:)];
    _friendDict = dict;
    
    [self.friendTableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated {
//    UINavigationItem *navigationItem = [[self.navigationController.viewControllers firstObject] navigationItem];
//    navigationItem.rightBarButtonItem = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if(section == 0){
        return 10;
    }
    return 22;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _friendNameKeys.count + 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 2;
    } else {
        NSString *key = _friendNameKeys[section-1];
        NSArray *friends = _friendDict[key];
        return friends.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
//        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        FriendItemCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FriendItemCell" forIndexPath:indexPath];

        if (indexPath.row == 0) {
            cell.avatar.image = [UIImage imageNamed:[NSString stringWithFormat:@"new_friends.jpg"]];
            cell.title.text = @"新好友";
        } else if (indexPath.row == 1) {
            cell.avatar.image = [UIImage imageNamed:[NSString stringWithFormat:@"groups.jpg"]];
            cell.title.text = @"群组";
        }
        return cell;
    } else {
        FriendItemCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FriendItemCell" forIndexPath:indexPath];
        NSString *friendNameKey = _friendNameKeys[indexPath.section-1];
        MFriend *f = (MFriend *)[_friendDict[friendNameKey] objectAtIndex:[indexPath row]];
        cell.title.text = f.displayName;
        
        //        cell.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"avater_%d.jpg", f.uid]];
        NSURL *url = [NSURL URLWithString:f.avatarUrl];
        [cell.avatar sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"avater_default.png"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
//            NSLog(@"%@,%ld", f.avatarUrl, (long)cacheType);
        }];
        
        return cell;
    }
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            NewFriendListController *nflc = [[NewFriendListController alloc] init];
            nflc.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:nflc animated:YES];
        } else {
            GroupListController *glc = [[GroupListController alloc] init];
            glc.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:glc animated:YES];
        }
    } else {
//        DialogDetailController *mdvc = [[DialogDetailController alloc] init];
        NSString *key = _friendNameKeys[indexPath.section-1];
        MFriend *f = (MFriend *)[_friendDict[key] objectAtIndex:[indexPath row]];
//        mdvc.userId = f.uid;
//        mdvc.target = f;
        
        UserInfoController *uic = [[UserInfoController alloc] init];
        uic.uid = f.uid;
        uic.target = f;
        
        uic.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:uic animated:YES];
    }
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UILabel *label = [[UILabel alloc] init];
    [label setFrame:CGRectMake(12, 0, 100, [self tableView:self.friendTableView heightForHeaderInSection:section])];
    [label setBackgroundColor:[UIColor clearColor]];
    
    if (section > 0) {
        [label setText:_friendNameKeys[section-1]];
        [label setTextColor:[UIColor grayColor]];
    }
    
    UITableViewHeaderFooterView *headerView = [[UITableViewHeaderFooterView alloc] init];
    [headerView addSubview:label];
    
    return headerView;
}

-(NSArray *)sectionIndexTitlesForTableView:(UITableView *) tableView {
    return _friendNameKeys;
}

-(BOOL)tableView:(UITableView *) tableView canEditRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return NO;
    }
    return YES;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section > 0 && editingStyle == UITableViewCellEditingStyleDelete) {
        NSString *key = _friendNameKeys[indexPath.section-1];
        MFriend *friend = (MFriend *)[_friendDict[key] objectAtIndex:[indexPath row]];
        
        [[NetWorkManager sharedInstance] delFriendWithUid:friend.uid
                                                  success:^(NSDictionary *responseObject) {
                                                  } fail:^(NSError *error) {
                                                      
                                                  }];
        
        _friends = [[IMDAO shareInstance] getFriendsWithUid: [MUser currentUser].uid];
        
        [_friendDict[key] removeObject:friend];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                         withRowAnimation:UITableViewRowAnimationAutomatic];
        
        [[IMDAO shareInstance] delFriendWithId:friend.uid];
        [[IMDAO shareInstance] deleteDialogWithId:friend.uid];
        [[IMDAO shareInstance] delMakeFriendRecordWithId:friend.uid];
        
        int unreadCount = [[IMDAO shareInstance] getUnreadCountWithUid:friend.uid];
        [[AppProfile instance] incrMsgUnreadCount:-unreadCount];
    }
}

- (void) go2SearchAccountController {
    SearchAccountController *sac = [[SearchAccountController alloc] init];
    sac.hidesBottomBarWhenPushed = TRUE;
    [self.navigationController pushViewController:sac animated:YES];
//    [self presentViewController:sac animated:YES completion:nil];
}

//获取拼音首字母(传入汉字字符串, 返回大写拼音首字母)
- (NSString *)firstCharactor:(NSString *)aString
{
    if (!aString || [aString isEqualToString:@""]) {
        return @"";
    }
    
    //转成了可变字符串
    NSMutableString *str = [NSMutableString stringWithString:aString];
    //先转换为带声调的拼音
    CFStringTransform((CFMutableStringRef)str,NULL, kCFStringTransformMandarinLatin,NO);
    //再转换为不带声调的拼音
    CFStringTransform((CFMutableStringRef)str,NULL, kCFStringTransformStripDiacritics,NO);
    //转化为大写拼音
    NSString *pinYin = [str capitalizedString];
    //获取并返回首字母
    return [pinYin substringToIndex:1];
}

#pragma mark notification

-(void) updateNoticeCount:(NSNotification *)aNotification {
    NSInteger badgeValue = [[AppProfile instance] getNoticeUnreadCount];
    UITabBarItem *tabBarItem = [self.tabBarController.tabBar.items objectAtIndex:1];
    if (badgeValue > 0) {
        tabBarItem.badgeValue = [NSString stringWithFormat:@"%ld", (long)badgeValue];
    } else {
        tabBarItem.badgeValue = nil;
    }    
}


@end
