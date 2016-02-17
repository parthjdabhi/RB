//
//  UserInfoOperationController.m
//  RB
//
//  Created by hjc on 15/12/23.
//  Copyright © 2015年 hjc. All rights reserved.
//

#import "UserInfoOperationController.h"
#import "IMDAO.h"
#import "FriendSelectController.h"

@interface UserInfoOperationController ()

@end

@implementation UserInfoOperationController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self initData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    UIBarButtonItem *back = [[UIBarButtonItem alloc] initWithTitle:@"返回"
                                                             style:UIBarButtonItemStylePlain
                                                            target:self
                                                            action:@selector(go2PreViewController)];
    self.navigationItem.leftBarButtonItem = back;
}

- (void) viewWillDisappear:(BOOL)animated {
    //    UINavigationItem *navigationItem = [[self.navigationController.viewControllers firstObject] navigationItem];
    //    navigationItem.backBarButtonItem = nil;
}


#pragma mark 加载数据
-(void)initData {
    _tableCells = [[NSMutableArray alloc] init];
    
    
    NSMutableArray *cs = [NSMutableArray arrayWithObjects: [NSMutableDictionary dictionaryWithObjectsAndKeys: @"1", @"name",nil], nil];
    [_tableCells addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:cs, @"cells", nil]];
    
//    NSMutableDictionary *cell1 = [NSMutableDictionary dictionaryWithObjectsAndKeys: @"设置备注", @"title", nil];
//    //    NSMutableDictionary *cell2 = [NSMutableDictionary dictionaryWithObjectsAndKeys: @"2", @"title",nil];
//    NSMutableDictionary *group1 = [NSMutableDictionary dictionaryWithObjectsAndKeys: [NSMutableArray arrayWithObjects:cell1, nil], @"cells", nil];
//    [_tableCells addObject:group1];
//    
//    NSMutableDictionary *cell3 = [NSMutableDictionary dictionaryWithObjectsAndKeys: @"地区", @"title", @"深圳", @"detail", nil];
//    NSMutableDictionary *cell4 = [NSMutableDictionary dictionaryWithObjectsAndKeys: @"更多", @"title",nil];
//    NSMutableDictionary *group2 = [NSMutableDictionary dictionaryWithObjectsAndKeys: [NSMutableArray arrayWithObjects:cell3, cell4, nil], @"cells", nil];
//    [_tableCells addObject:group2];
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
        static NSString *CellIdentifier = @"DialogMemberCell";
        DialogMemberCell *cell = [[DialogMemberCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
        if (_gid > 0) {
            _group = [[IMDAO shareInstance] getGroupWithId:_gid];
            NSArray *groupMembers = _group.members;
            if (_group.members) {
                [cell setMember:groupMembers];
            }
        } else {
            [cell setMember:@[_user]];
        }

        cell.delegate = self;
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

#pragma mark GroupMemberCell delegate
- (void)go2FriendSelectController {
    FriendSelectController *fsc = nil;
    if (_gid > 0) {
        fsc = [[FriendSelectController alloc] initWithSelectUsers:_group.members];
        fsc.gid = _gid;
    } else {
        fsc = [[FriendSelectController alloc] initWithSelectUsers:@[_user]];
    }

    [self.navigationController pushViewController:fsc animated:YES];
}

#pragma mark navigatorItem handle
- (void)go2PreViewController {
    [self.navigationController popViewControllerAnimated:YES];
}


@end
