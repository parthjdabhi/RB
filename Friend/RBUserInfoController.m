//
//  UserInfoController.m
//  RB
//
//  Created by hjc on 15/12/8.
//  Copyright © 2015年 hjc. All rights reserved.
//

#import "RBUserInfoController.h"

#import "RBDialogDetailController.h"
#import "SayHiController.h"
#import "PictureViewController.h"
#import "IMDAO.h"
#import "RBUserInfoCell.h"

#import <SDWebImage/UIImageView+WebCache.h>

@interface RBUserInfoController ()

@end

@implementation RBUserInfoController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (!_friendInfo) {
        _friendInfo = [[IMDAO shareInstance] getFriendWithId:_uid];
    }
    
    [self initData];
}

- (void) viewWillAppear:(BOOL)animated {
    self.navigationItem.title = @"详细资料";
    
    [_button setTitle:_friendInfo != nil ? @"发信息" : @"加好友" forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark 加载数据
-(void)initData {
    _tableCells = [[NSMutableArray alloc] init];
    
    [_tableCells addObject:@{@"cells":@[@{@"title":@"用户信息"}]}];
    [_tableCells addObject:@{@"cells":@[@{@"title":@"设置备注"}]}];
    [_tableCells addObject:@{@"cells":@[@{@"title":@"地区", @"detail":@"深圳"}, @{@"title":@"更多"}]}];
}

#pragma mark - 数据源方法
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
//    NSLog(@"计算分组数 %lu", (unsigned long)_tableCells.count);
    return _tableCells.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSMutableDictionary *group = _tableCells[section];
    NSMutableArray * cells = (NSMutableArray *)[group objectForKey:@"cells"];
    return cells.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSMutableDictionary *group = _tableCells[indexPath.section];
    NSMutableArray *cells = (NSMutableArray *)[group objectForKey:@"cells"];
    NSMutableDictionary *contact = cells[indexPath.row];
    
    if (indexPath.section == 0 && indexPath.row == 0) {
        RBUserInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RBUserInfoCell" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        NSURL *url = [NSURL URLWithString:_target.avatarUrl];
        [cell.avatar sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"avater_default.png"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            
        }];
        
        [cell.avatar setUserInteractionEnabled:YES];
        [cell.avatar addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(avatarOnClick:)]];
        
        if (_friendInfo) {
            cell.displayNameLabel.text = _friendInfo.displayName;
            
            if (_friendInfo.commentName) {
                cell.nicknameLabel.text = [NSString stringWithFormat:@"昵称：%@", _friendInfo.nickname];
                cell.nicknameLabel.hidden = FALSE;
            } else {
                cell.nicknameLabel.hidden = TRUE;
            }
            
        } else {
            cell.displayNameLabel.text = _target.nickname;
            cell.nicknameLabel.hidden = TRUE;
        }


        return cell;
        
    } else if (indexPath.section == 2 && indexPath.row == 0) {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.text = [contact objectForKey:@"title"];
        cell.detailTextLabel.text = [contact objectForKey:@"detail"];
        
        return cell;
        
    } else {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        cell.textLabel.text = [contact objectForKey:@"title"];
        
        return cell;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    if (indexPath.section == 1 && indexPath.row == 0) {
        [self commentNameOnClick];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if(section == 0){
        return 10;
    }
    return 22;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 0 && indexPath.row == 0){
        return 83;
    }
    return 42;
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if (_friendInfo == nil) {
        SayHiController *shc = segue.destinationViewController;
        shc.uid = _uid;
    }
}

- (BOOL) shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if (_friendInfo == nil) {
        return TRUE;
    } else {
        return FALSE;
    }
}

- (IBAction)buttonOnClick:(id)sender {
    if (_friendInfo == nil) {
//        SayHiController *shc = [[SayHiController alloc] init];
//        shc.uid = _uid;
//
//        [self.navigationController pushViewController:shc animated:YES];
    } else {
        
        RBDialogDetailController *mdvc = [[UIStoryboard storyboardWithName:@"RBMessageMain" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"RBDialogDetailController"];
        mdvc.userId = _uid;
        mdvc.target = _target;
        mdvc.sender = [MUser currentUser];
        
        mdvc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:mdvc animated:YES];
    }
}

- (void)avatarOnClick:(NSNotification *)note {
    
    if (_target && _target.avatarUrl) {

        [self.navigationController setNavigationBarHidden:YES animated:NO];
        
        PictureViewController *pvc = [[PictureViewController alloc] init];
        pvc.imgArr = @[_target.avatarUrl];
        pvc.hidesBottomBarWhenPushed = TRUE;
        
        [self.navigationController pushViewController:pvc animated:YES];
    }
}

-(void)commentNameOnClick {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"请输入备注名称" message:nil delegate:self cancelButtonTitle:@"保存" otherButtonTitles:@"取消",nil];
    [alertView setAlertViewStyle:UIAlertViewStylePlainTextInput];
    
    if (self.friendInfo.commentName) {
        UITextField *tf = [alertView textFieldAtIndex:0];
        tf.text = self.friendInfo.commentName;
    }

//    [[dialog textFieldAtIndex:0] setKeyboardType:UIKeyboardTypeNumberPad];
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    UITextField *tf = [alertView textFieldAtIndex:0];
    
    if (buttonIndex == 0 && tf.text) {
        self.friendInfo.commentName = tf.text;
        [[IMDAO shareInstance] updateFriend:self.friendInfo];
        [self.tableView reloadData];
    }
}

@end