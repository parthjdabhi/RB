//
//  FriendListController.m
//  R&B
//
//  Created by hjc on 15/11/28.
//  Copyright © 2015年 hjc. All rights reserved.
//

#import "RBFriendMainController.h"

#import "RBGroupListController.h"
#import "RBNewFriendListController.h"
#import "SearchAccountController.h"
#import "RBUserInfoController.h"
#import "NewFriendListController.h"
#import "GroupListController.h"

#import "RBFriendItemCell.h"
#import "MDialog.h"
#import "IMDAO.h"
#import "NetWorkManager.h"
#import "AppProfile.h"

#import <SDWebImage/UIImageView+WebCache.h>

@interface RBFriendMainController ()
{
    NSArray *_friends;
    NSArray *_friendNameKeys;
    NSDictionary *_friendDict;
}
@end

@implementation RBFriendMainController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[AppProfile instance] incrNoticeUnreadCount:[[IMDAO shareInstance] getNoticeUnreadCount]];
    _friends = [[IMDAO shareInstance] getFriendsWithUid: [MUser currentUser].uid];
    
    void (^successBlock)(NSDictionary *) = ^(NSDictionary *responseObject) {
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
    };
    
    if (_friends.count == 0) {
        [[NetWorkManager sharedInstance] getFriendListWithUid:[MUser currentUser].uid
                                                      success:successBlock
                                                         fail:^(NSError *error) {
                                                             
                                                         }];
    }
    
    [self updateNoticeCount:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateNoticeCount:) name:UpdateNoticeCountNotification object:nil];
    
    UINavigationItem *navigationItem = self.navigationItem;
    
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
    
    [self.tableView reloadData];
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
    RBFriendItemCell *cell = nil;
    if (indexPath.section == 0) {

        if (indexPath.row == 0) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"NewFriendItemCell"];
            cell.avatar.image = [UIImage imageNamed:[NSString stringWithFormat:@"new_friends.jpg"]];
            cell.title.text = @"新好友";
        
        } else if (indexPath.row == 1) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"GroupItemCell"];
            cell.avatar.image = [UIImage imageNamed:[NSString stringWithFormat:@"groups.jpg"]];
            cell.title.text = @"群组";
        }
        
        return cell;
        
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"RBFriendItemCell"];
        NSString *friendNameKey = _friendNameKeys[indexPath.section-1];
        MFriend *f = (MFriend *)[_friendDict[friendNameKey] objectAtIndex:[indexPath row]];
        cell.title.text = f.displayName;

        NSURL *url = [NSURL URLWithString:f.avatarUrl];
        [cell.avatar sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"avater_default.png"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        }];
        
        return cell;
    }
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:[RBUserInfoController class]]) {
        RBUserInfoController *uic = segue.destinationViewController;
        
        NSIndexPath *indexPath = self.tableView.indexPathForSelectedRow;
        NSString *key = _friendNameKeys[indexPath.section-1];
        MFriend *f = (MFriend *)[_friendDict[key] objectAtIndex:[indexPath row]];
        uic.uid = f.uid;
        uic.target = f;
        
    } else if ([segue.destinationViewController isKindOfClass:[RBNewFriendListController class]] || [segue.destinationViewController isKindOfClass:[RBGroupListController class]] || [segue.destinationViewController isKindOfClass:[SearchAccountController class]]) {

    }
    
    segue.destinationViewController.hidesBottomBarWhenPushed = YES;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UILabel *label = [[UILabel alloc] init];
    [label setFrame:CGRectMake(12, 0, 100, [self tableView:self.tableView heightForHeaderInSection:section])];
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
