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

- (void)viewDidAppear:(BOOL)animated {
    [self adjustHeightOfTableview];
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
    
    NSMutableDictionary *cell1 = [NSMutableDictionary dictionaryWithObjectsAndKeys: @"消息免打扰", @"title", nil];
    NSMutableDictionary *group1 = [NSMutableDictionary dictionaryWithObjectsAndKeys: [NSMutableArray arrayWithObjects:cell1, nil], @"cells", nil];
    [_tableCells addObject:group1];
    
    NSMutableDictionary *cell3 = [NSMutableDictionary dictionaryWithObjectsAndKeys: @"设置聊天背景", @"title", nil];
    NSMutableDictionary *group2 = [NSMutableDictionary dictionaryWithObjectsAndKeys: [NSMutableArray arrayWithObjects:cell3, nil], @"cells", nil];
    [_tableCells addObject:group2];
}

#pragma mark - 数据源方法
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
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
        static NSString *CellIdentifier = @"DialogMemberCell";
        DialogMemberCell *cell = [[DialogMemberCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
        if (_groupId > 0) {
            _group = [[IMDAO shareInstance] getGroupWithId:_groupId];
            NSArray *groupMembers = _group.members;
            if (_group.members) {
                [cell setMember:groupMembers];
            }
        } else {
            [cell setMember:@[_user]];
        }

        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.delegate = self;
        return cell;
    } else if (indexPath.section == 1 && indexPath.row == 0) {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];

        cell.textLabel.text = [contact objectForKey:@"title"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        UISwitch *switchview = [[UISwitch alloc] initWithFrame:CGRectZero];
        cell.accessoryView = switchview;
        return cell;
    } else {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        cell.textLabel.text = [contact objectForKey:@"title"];
        return cell;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if(section == 0){
        return 10;
    }
    return 20;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 0 && indexPath.row == 0){
        return 60;
    }
    return 45;
}

- (void)adjustHeightOfTableview
{
    CGFloat height = self.tableView.contentSize.height;
    CGFloat maxHeight = self.tableView.superview.frame.size.height - self.tableView.frame.origin.y;
    
    // if the height of the content is greater than the maxHeight of
    // total space on the screen, limit the height to the size of the
    // superview.
    
    if (height > maxHeight)
        height = maxHeight;
    
    // now set the frame accordingly
    
    [UIView animateWithDuration:0.25 animations:^{
        CGRect frame = self.tableView.frame;
        frame.size.height = height;
        self.tableView.frame = frame;
        
        // if you have other controls that should be resized/moved to accommodate
        // the resized tableview, do that here, too
    }];
}

#pragma mark GroupMemberCell delegate
- (void)go2FriendSelectController {
    FriendSelectController *fsc = nil;
    if (_groupId > 0) {
        fsc = [[FriendSelectController alloc] initWithSelectUsers:_group.members];
        fsc.groupId = _groupId;
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
