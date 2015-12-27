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
#import "MessageDetailViewController.h"
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
    for (User *u in users) {
        NSString *key = [NSString stringWithFormat:@"%d", u.uid];
        [selectedUids setObject:key forKey:key];
    }
    
    return self;
}

- (instancetype) initWithGid:(int) gid selectUsers:(NSArray *) users {
    self = [self initWithSelectUsers:users];
    _gid = gid;
    
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
    
    _friends = [[IMDAO shareInstance] getFriendsWithUid: [User currentUser].uid];
    [_tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated {
    int index = 0;
    for (User *u in _friends) {
        if ([selectedUids objectForKey:[NSString stringWithFormat:@"%d", u.uid]]) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
//            [self tableView:_tableView didSelectRowAtIndexPath:indexPath];
            [[_tableView cellForRowAtIndexPath:indexPath] setSelected:YES animated:YES];
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
    FriendItemCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FriendItemCell" forIndexPath:indexPath];
    NSUInteger row = [indexPath row];
    Friend *f = (Friend *)[_friends objectAtIndex:row];
    cell.title.text = f.nickname;
    //    NSLog(@"avater_%d.jpg", f.uid);
    
    //        cell.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"avater_%d.jpg", f.uid]];
    NSURL *url = [NSURL URLWithString:f.avaterUrl];
    [cell.imageView sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"avater_default.png"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
    }];
    
    if ([selectedUids objectForKey:[NSString stringWithFormat:@"%d", f.uid]]) {
        [cell setSelected:YES];
    } else {
        [cell setSelected:NO];
    }
    
    return cell;
}

//添加一项
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (!selectedDict) {
        selectedDict = [[NSMutableDictionary alloc] init];
    }
    
    Friend *f = (Friend *)[_friends objectAtIndex:indexPath.row];
    NSString *key = [NSString stringWithFormat:@"%d", f.uid];
    [selectedDict setObject:key forKey:key];
}

//取消一项
- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    Friend *f = (Friend *)[_friends objectAtIndex:indexPath.row];
    NSString *key = [NSString stringWithFormat:@"%d", f.uid];
    [selectedDict removeObjectForKey:key];
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
    NSLog(@"%@", selectedDict);
    NSLog(@"%lu", (unsigned long)selectedDict.count);
    
    if (![self dataHasBeenChanged]) {
        return;
    }
    
    void (^successBlock)(NSDictionary *) = ^(NSDictionary *responseObject) {
        // 写入group记录
        Group *group = [[Group alloc] init];
        group._id = [[responseObject objectForKey:@"gid"] integerValue];
        group.name = [responseObject objectForKey:@"name"];
        group.avaterUrl = [responseObject objectForKey:@"avater_url"];
        
        NSMutableArray *members = [[NSMutableArray alloc] init];
        for (NSString *memberUid in selectedDict.allKeys) {
            [members addObject:[[User alloc] initWithId:(int) memberUid]];
        }
        group.members = members;
        
        if (_gid > 0) {
            [[IMDAO shareInstance] addMembers:group.members ToGid:group._id];
        } else {
            [[IMDAO shareInstance] saveGroup:group];
        }
        
        // 生成dialog
        
        MessageDetailViewController *mdvc = [[MessageDetailViewController alloc] init];
        mdvc.title = group.name;
        mdvc.gid = _gid;
        [self.navigationController pushViewController:mdvc animated:YES];
    };
    
    void (^errorBlock)(NSError *) = ^(NSError *error) {
        
    };
    
    if (_gid > 0) {
        [[NetWorkManager sharedInstance] addGroupMemberWithGid:_gid
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

@end
