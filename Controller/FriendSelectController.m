//
//  FriendSelectController.m
//  RB
//
//  Created by hjc on 15/12/23.
//  Copyright © 2015年 hjc. All rights reserved.
//

#import "FriendSelectController.h"
#import "IMDAO.h"
#import "FriendItemCell.h"
#import "NetWorkManager.h"
#import "DialogDetailController.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface FriendSelectController ()
{
    NSMutableDictionary *selectedDict;
    NSMutableDictionary *selectedUids;
}
@end

@implementation FriendSelectController

- (instancetype) initWithSelectUsers:(NSArray *) users {
    if (!self) {
        self = [super init];
    }
    
    selectedUids = [[NSMutableDictionary alloc] init];
    selectedDict = [[NSMutableDictionary alloc] init];
    for (MUser *u in users) {
        NSString *key = [NSString stringWithFormat:@"%ld", (long)u.uid];
        [selectedUids setObject:key forKey:key];
        [selectedDict setObject:key forKey:key];
    }
    
    return self;
}

- (instancetype) initWithGid:(NSInteger) groupId selectUsers:(NSArray *) users {
    self = [self initWithSelectUsers:users];
    _groupId = groupId;
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UINib *nib = [UINib nibWithNibName:@"FriendItemCell" bundle:nil];
    [_tableView registerNib:nib forCellReuseIdentifier:@"FriendItemCell"];
}

- (void)viewWillAppear:(BOOL)animated {
    UIBarButtonItem *back = [[UIBarButtonItem alloc] initWithTitle:@"返回"
                                                             style:UIBarButtonItemStylePlain
                                                            target:self
                                                            action:@selector(go2PreViewController)];
    self.navigationItem.leftBarButtonItem = back;
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"确定"
                                                             style:UIBarButtonItemStylePlain
                                                            target:self
                                                            action:@selector(addMember2Group)];
    self.navigationItem.rightBarButtonItem = rightItem;
    self.title = @"选择联系人";
    
    _friends = [[IMDAO shareInstance] getFriendsWithUid: [MUser currentUser].uid];
    [_tableView reloadData];
    [self displayMembers];
}

- (void)viewDidAppear:(BOOL)animated {
    int index = 0;
    for (MUser *u in _friends) {
        if ([selectedUids objectForKey:[NSString stringWithFormat:@"%ld", (long)u.uid]]) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
            [_tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        }
        index++;
    }
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _friends.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FriendItemCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FriendItemCell"];
    NSUInteger row = [indexPath row];
    MFriend *f = (MFriend *)[_friends objectAtIndex:row];
    cell.title.text = f.nickname;
    //    NSLog(@"avater_%d.jpg", f.uid);
    
    //        cell.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"avater_%d.jpg", f.uid]];
    NSURL *url = [NSURL URLWithString:f.avatarUrl];
    [cell.avatar sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"avater_default.png"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
    }];
    
    if ([selectedUids objectForKey:[NSString stringWithFormat:@"%ld", (long)f.uid]]) {
        [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    } else {
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
    
    return cell;
}

//添加一项
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    MFriend *f = (MFriend *)[_friends objectAtIndex:indexPath.row];
    NSString *key = [NSString stringWithFormat:@"%ld", (long)f.uid];
    [selectedDict setObject:key forKey:key];
    [self displayMembers];
}

//取消一项
- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    MFriend *f = (MFriend *)[_friends objectAtIndex:indexPath.row];
    NSString *key = [NSString stringWithFormat:@"%ld", (long)f.uid];
    
    if ([selectedUids objectForKey:key]) {
        [_tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        return;
    }
    
    [selectedDict removeObjectForKey:key];
    [self displayMembers];
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 10;
}

#pragma mark navigatorItem handle
- (void)go2PreViewController {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark sumbit
- (void)addMember2Group {
    if (![self dataHasBeenChanged]) {
        return;
    }
    
    void (^successBlock)(NSDictionary *) = ^(NSDictionary *responseObject) {
        // 写入group记录
        MGroup *group = [[MGroup alloc] init];
        group._id = [[responseObject objectForKey:@"gid"] integerValue];
        group.name = [responseObject objectForKey:@"name"];
        group.avatarUrl = [responseObject objectForKey:@"avatar_url"];
        
        NSMutableArray *members = [[NSMutableArray alloc] init];
        [group.members addObject:[MUser currentUser]];
        for (NSString *memberUid in selectedDict.allKeys) {
            [members addObject:[[MUser alloc] initWithId:[memberUid intValue]]];
        }
        
        if (_groupId > 0) {
            [[IMDAO shareInstance] addMembers:members ToGid:group._id];
        } else {
            group.members = [[NSMutableArray alloc] init];
            [group.members addObjectsFromArray:members];
            [[IMDAO shareInstance] saveGroup:group];
        }
        
        // 生成dialog
        DialogDetailController *mdvc = [[DialogDetailController alloc] init];
        mdvc.title = group.name;
        mdvc.groupId = group._id;
        mdvc.sender = [MUser currentUser];
        [self.navigationController pushViewController:mdvc animated:YES];
    };
    
    void (^errorBlock)(NSError *) = ^(NSError *error) {
        
    };
    
    if (_groupId > 0) {
        [[NetWorkManager sharedInstance] addGroupMemberWithGid:_groupId
                                                          Uids:selectedDict.allKeys
                                                       success:successBlock
                                                          fail:errorBlock];
    } else {
        [[NetWorkManager sharedInstance] createGroupWithUids:selectedDict.allKeys
                                                     success:successBlock
                                                        fail:errorBlock];
    }
    
}

- (BOOL) dataHasBeenChanged
{
    if (selectedDict.allKeys.count == 0) {
        return false;
    }
    
    for (NSString *key in selectedDict.allKeys) {
        // 选中的用户如果不在初始化用户集合中，说明有新增用户
        if (![selectedUids objectForKey:key]) {
            return true;
        }
    }
    
    return false;
}

- (void)displayMembers {
    for (UIView *view in _selectedUsersView.subviews) {
        [view removeFromSuperview];
    }
    
    NSMutableArray *uids = [[NSMutableArray alloc] init];
    
    if (selectedDict.count > 0) {
        for (NSString *key in selectedDict.allKeys) {
            [uids addObject:key];
        }
    }
    
    int index = 0;
    for (long i=uids.count; i>0; i--) {
        if (index >= 6) {
            break;
        }
        
        int uid = [[uids objectAtIndex:(i-1)] intValue];
        MUser *user = [[IMDAO shareInstance] getUserWithUid:uid];
        UIImageView *photo = [[UIImageView alloc]initWithFrame:CGRectMake(10 + 60 * index, 5, 50, 50)];
        NSURL *url = [NSURL URLWithString:user.avatarUrl];
        [photo sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"avater_default.png"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            
        }];
        //        photo.image = [UIImage imageNamed:[NSString stringWithFormat:@"avater_%d.jpg", user.uid]];
        [_selectedUsersView addSubview:photo];
        
        index++;
    }
}

@end
