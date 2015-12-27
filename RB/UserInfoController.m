//
//  UserInfoController.m
//  RB
//
//  Created by hjc on 15/12/8.
//  Copyright © 2015年 hjc. All rights reserved.
//

#import "UserInfoController.h"
#import "MessageDetailViewController.h"
#import "SayHiController.h"
#import "PictureViewController.h"
#import "IMDAO.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface UserInfoController ()

@end

@implementation UserInfoController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (!_friendInfo) {
        _friendInfo = [[IMDAO shareInstance] getFriendWithId:_uid];
    }
    if (!_friendInfo) {
        [_sendMsgBtn setHidden:YES];
        [_friendBtn setHidden:NO];
    } else {
        [_sendMsgBtn setHidden:NO];
        [_friendBtn setHidden:YES];
    }
    
    [self initData];
}

- (void) viewWillAppear:(BOOL)animated {
    UINavigationItem *navigationItem = [[self.navigationController.viewControllers firstObject] navigationItem];
    UIBarButtonItem *back = [[UIBarButtonItem alloc] initWithTitle:@"返回"
                                                             style:UIBarButtonItemStylePlain
                                                            target:self
                                                            action:nil];
    navigationItem.backBarButtonItem = back;
//    self.title = _target.nickname;
}

- (void) viewWillDisappear:(BOOL)animated {
//    UINavigationItem *navigationItem = [[self.navigationController.viewControllers firstObject] navigationItem];
//    navigationItem.backBarButtonItem = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark 加载数据
-(void)initData {
    _tableCells = [[NSMutableArray alloc] init];

    
    NSMutableArray *cs = [NSMutableArray arrayWithObjects: [NSMutableDictionary dictionaryWithObjectsAndKeys: @"1", @"name",nil], nil];
    [_tableCells addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:cs, @"cells", nil]];
    
    NSMutableDictionary *cell1 = [NSMutableDictionary dictionaryWithObjectsAndKeys: @"设置备注", @"title", nil];
//    NSMutableDictionary *cell2 = [NSMutableDictionary dictionaryWithObjectsAndKeys: @"2", @"title",nil];
    NSMutableDictionary *group1 = [NSMutableDictionary dictionaryWithObjectsAndKeys: [NSMutableArray arrayWithObjects:cell1, nil], @"cells", nil];
    [_tableCells addObject:group1];

    NSMutableDictionary *cell3 = [NSMutableDictionary dictionaryWithObjectsAndKeys: @"地区", @"title", @"深圳", @"detail", nil];
    NSMutableDictionary *cell4 = [NSMutableDictionary dictionaryWithObjectsAndKeys: @"更多", @"title",nil];
    NSMutableDictionary *group2 = [NSMutableDictionary dictionaryWithObjectsAndKeys: [NSMutableArray arrayWithObjects:cell3, cell4, nil], @"cells", nil];
    [_tableCells addObject:group2];
}

#pragma mark - 数据源方法
#pragma mark 返回分组数
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
//    NSLog(@"计算分组数 %lu", (unsigned long)_tableCells.count);
    return _tableCells.count;
}

#pragma mark 返回每组行数
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
//    NSLog(@"计算每组(组%li)行数",(long)section);
    NSMutableDictionary *group = _tableCells[section];
    NSMutableArray * cells = (NSMutableArray *)[group objectForKey:@"cells"];
    return cells.count;
}

#pragma mark返回每行的单元格
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    //NSIndexPath是一个结构体，记录了组和行信息
//    NSLog(@"生成单元格(组：%li,行%li)",(long)indexPath.section,(long)indexPath.row);
    NSMutableDictionary *group = _tableCells[indexPath.section];
    NSMutableArray *cells = (NSMutableArray *)[group objectForKey:@"cells"];
    NSMutableDictionary *contact = cells[indexPath.row];
    
    if (indexPath.section == 0 && indexPath.row == 0) {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        NSURL *url = [NSURL URLWithString:_target.avaterUrl];
        [cell.imageView sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"avater_default.png"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            
        }];
        [cell.imageView setUserInteractionEnabled:YES];
        [cell.imageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(avaterOnClick:)]];
        
        cell.textLabel.text = _target.nickname;
        return cell;
    } else if (indexPath.section == 2 && indexPath.row == 0) {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
//        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
        cell.textLabel.text = [contact objectForKey:@"title"];
        cell.detailTextLabel.text = [contact objectForKey:@"detail"];
        return cell;
    } else {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        cell.textLabel.text = [contact objectForKey:@"title"];
        return cell;
    }
}

#pragma mark 返回每组头标题名称
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
//    NSLog(@"生成组（组%li）名称",(long)section);
//    NSMutableDictionary *group= _tableCells[indexPath.section];
    return nil;
}

#pragma mark 返回每组尾部说明
//-(NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section{
//    NSLog(@"生成尾部（组%li）详情",(long)section);
////    KCContactGroup *group=_contacts[section];
//    return @" ";
//}

#pragma mark 设置分组标题内容高度
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if(section == 0){
        return 10;
    }
    return 10;
}

#pragma mark 设置每行高度（每行高度可以不一样）
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 0 && indexPath.row == 0){
        return 60;
    }
    return 45;
}

#pragma mark 设置尾部说明内容高度
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0;
}

- (IBAction)friendBtnOnClick:(id)sender {
    SayHiController *shc = [[SayHiController alloc] init];
    shc.uid = _uid;
//    [shc setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
    [self.navigationController pushViewController:shc animated:YES];
}

- (IBAction)sendMsgBtnOnClick:(id)sender {
    MessageDetailViewController *mdvc = [[MessageDetailViewController alloc] init];
    mdvc.uid = _uid;
    mdvc.target = _target;

    [self.navigationController pushViewController:mdvc animated:YES];
}

- (void)avaterOnClick:(NSNotification *)note {
    if (_target && _target.avaterUrl) {        
        PictureViewController *pvc = [[PictureViewController alloc] init];
        pvc.imgArr = [[NSMutableArray alloc] init];
        [pvc.imgArr addObject: @{@"url":_target.avaterUrl}];
        [self.navigationController pushViewController:pvc animated:YES];
    }
}

@end
