//
//  GroupListController.m
//  RB
//
//  Created by hjc on 15/12/14.
//  Copyright © 2015年 hjc. All rights reserved.
//

#import "GroupListController.h"
#import "MessageDetailViewController.h"
#import "IMDAO.h"
#import "NetWorkManager.h"

@interface GroupListController ()

@end

@implementation GroupListController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _resultArray = [[IMDAO shareInstance] getGroupsWithUid:[User currentUser].uid];
    if (_resultArray.count == 0) {
//        Group *group = [[Group alloc] init];
//        group._id = 1;
//        group.name = @"gogogo1";
//        
//        User *u1 = [[User alloc] init];
//        u1.uid = 101;
//        User *u2 = [[User alloc] init];
//        u2.uid = 102;
//        User *u3 = [[User alloc] init];
//        u3.uid = 103;
//        
//        group.members = [[NSMutableArray alloc] initWithObjects:u1, u2, u3, nil];
//        group.stamp = [[NSDate date] timeIntervalSince1970] * 1000;
//        [[IMDAO shareInstance] saveGroup:group];
//        
//        group._id = 2;
//        group.name = @"gogogo2";
//        
//        User *u4 = [[User alloc] init];
//        u4.uid = 104;
//        
//        group.members = [[NSMutableArray alloc] initWithObjects:u1, u2, u3, u4, nil];
//        group.stamp = [[NSDate date] timeIntervalSince1970] * 1000;
//        [[IMDAO shareInstance] saveGroup:group];
        
        [[NetWorkManager sharedInstance] getGroupListSuccess:^(NSArray *responseObject) {
            for (NSDictionary *groupObj in responseObject) {
                NSDictionary *groupInfo = [groupObj objectForKey:@"info"];
                NSArray *groupMembers = [groupObj objectForKey:@"members"];
                
                Group *group = [[Group alloc] init];
                group._id = [[groupInfo objectForKey:@"gid"] integerValue];
                group.name = [groupInfo objectForKey:@"name"];
                group.masterId = [[groupInfo objectForKey:@"master_id"] integerValue];
                group.avaterUrl = [groupInfo objectForKey:@"avater_url"];
                
                NSMutableArray *members = [[NSMutableArray alloc] init];
                for (NSDictionary *userObj in groupMembers) {
                    User *user = [[User alloc] init];
                    user.uid = [[userObj objectForKey:@"uid"] integerValue];
                    user.nickname = [userObj objectForKey:@"nickname"];
                    user.avaterUrl = [userObj objectForKey:@"avater_url"];
                    user.signature = [userObj objectForKey:@"signature"];
                    user.gender = [[userObj objectForKey:@"gender"] integerValue];
                    [members addObject:user];
                    
                    [[IMDAO shareInstance] saveUser:user];
                }
                
                group.members = members;
                [[IMDAO shareInstance] saveGroup:group];
            }
        }
                                                        fail:^(NSError *error) {
                                                        }];
    }
    
}

- (void)viewWillAppear:(BOOL)animated {
    UIBarButtonItem *back = [[UIBarButtonItem alloc] initWithTitle:@"返回"
                                                             style:UIBarButtonItemStylePlain
                                                            target:self
                                                            action:@selector(go2PreViewController)];
    self.navigationItem.leftBarButtonItem = back;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark tableview delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _resultArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    Group *g = (Group *)[_resultArray objectAtIndex:[indexPath row]];
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    cell.imageView.image = [UIImage imageNamed:@"photo.png"];
    cell.textLabel.text = g.name;
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    MessageDetailViewController *mdvc = [[MessageDetailViewController alloc] init];
    Group *g = (Group *)[_resultArray objectAtIndex:[indexPath row]];
    mdvc.gid = g._id;
    mdvc.title = g.name;
    [self.navigationController pushViewController:mdvc animated:YES];
}

#pragma mark navigatorItem handle
- (void)go2PreViewController {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
