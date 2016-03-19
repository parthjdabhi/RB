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
    
    NSArray *_friends;
    NSArray *_friendNameKeys;
    NSDictionary *_friendDict;
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
    
    [_tableView reloadData];
    [self displaySelectedPanel];
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

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 22;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _friendNameKeys.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSString *key = _friendNameKeys[section];
    NSArray *friends = _friendDict[key];
    return friends.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FriendItemCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FriendItemCell"];

    NSString *friendNameKey = _friendNameKeys[indexPath.section];
    MFriend *f = (MFriend *)[_friendDict[friendNameKey] objectAtIndex:[indexPath row]];
    cell.title.text = f.displayName;

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

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UILabel *label = [[UILabel alloc] init];
    [label setFrame:CGRectMake(12, 0, 100, [self tableView:self.tableView heightForHeaderInSection:section])];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setText:_friendNameKeys[section]];
    [label setTextColor:[UIColor grayColor]];

    UITableViewHeaderFooterView *headerView = [[UITableViewHeaderFooterView alloc] init];
    [headerView addSubview:label];
    
    return headerView;
}

//添加一项
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *friendNameKey = _friendNameKeys[indexPath.section];
    MFriend *f = (MFriend *)[_friendDict[friendNameKey] objectAtIndex:[indexPath row]];
    
    NSString *key = [NSString stringWithFormat:@"%ld", (long)f.uid];
    [selectedDict setObject:key forKey:key];
    [self displaySelectedPanel];
}

//取消一项
- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *friendNameKey = _friendNameKeys[indexPath.section];
    MFriend *f = (MFriend *)[_friendDict[friendNameKey] objectAtIndex:[indexPath row]];
    
    NSString *key = [NSString stringWithFormat:@"%ld", (long)f.uid];
    
    if ([selectedUids objectForKey:key]) {
        [_tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        return;
    }
    
    [selectedDict removeObjectForKey:key];
    [self displaySelectedPanel];
}

-(NSArray *)sectionIndexTitlesForTableView:(UITableView *) tableView {
    return _friendNameKeys;
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

- (void)displaySelectedPanel {
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
        
        [_selectedUsersView addSubview:photo];
        
        index++;
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

@end
