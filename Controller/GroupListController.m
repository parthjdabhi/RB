//
//  GroupListController.m
//  RB
//
//  Created by hjc on 15/12/14.
//  Copyright © 2015年 hjc. All rights reserved.
//

#import "GroupListController.h"
#import "FriendItemCell.h"
#import "DialogDetailController.h"
#import "IMDAO.h"
#import "NetWorkManager.h"

@interface GroupListController ()

@end

@implementation GroupListController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"群组";
    UINib *nib = [UINib nibWithNibName:@"FriendItemCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"FriendItemCell"];
    
    _resultArray = [[IMDAO shareInstance] getGroupsWithUid:[MUser currentUser].uid];
    if (_resultArray.count == 0) {
        
        void (^successBlock)(NSArray *) = ^(NSArray *responseObject) {
            for (NSDictionary *groupObj in responseObject) {
                NSDictionary *groupInfo = [groupObj objectForKey:@"info"];
                NSArray *groupMembers = [groupObj objectForKey:@"members"];
                
                MGroup *group = [[MGroup alloc] init];
                group._id = [[groupInfo objectForKey:@"gid"] integerValue];
                group.name = [groupInfo objectForKey:@"name"];
                group.masterId = [[groupInfo objectForKey:@"master_id"] integerValue];
                group.avatarUrl = [groupInfo objectForKey:@"avatar_url"];
                
                NSMutableArray *members = [[NSMutableArray alloc] init];
                for (NSDictionary *userObj in groupMembers) {
                    
                    MUser *user = [[MUser alloc] init];
                    user.uid = [[userObj objectForKey:@"uid"] integerValue];
                    user.nickname = [userObj objectForKey:@"nickname"];
                    user.avatarUrl = [userObj objectForKey:@"avatar_url"];
                    user.signature = [userObj objectForKey:@"signature"];
                    user.gender = [[userObj objectForKey:@"gender"] integerValue];
                    [members addObject:user];
                    
                    [[IMDAO shareInstance] saveUser:user];
                }
                
                group.members = members;
                [[IMDAO shareInstance] saveGroup:group];
            }
        };
        
        [[NetWorkManager sharedInstance] getGroupListSuccess:successBlock
                                                        fail:^(NSError *error) {
                                                        }];
    }
    
}

- (void)viewWillAppear:(BOOL)animated {
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark tableview delegate

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _resultArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MGroup *g = (MGroup *)[_resultArray objectAtIndex:[indexPath row]];

    FriendItemCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FriendItemCell" forIndexPath:indexPath];
    cell.avatar.image = [UIImage imageNamed:@"photo.png"];
    cell.title.text = g.name;
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DialogDetailController *mdvc = [[DialogDetailController alloc] init];
    
    MGroup *g = (MGroup *)[_resultArray objectAtIndex:[indexPath row]];
    mdvc.groupId = g._id;
    mdvc.sender = [MUser currentUser];
    mdvc.title = g.name;
    
    [self.navigationController pushViewController:mdvc animated:YES];
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        MGroup *g = (MGroup *)[_resultArray objectAtIndex:[indexPath row]];
        [[IMDAO shareInstance] deleteGroupWithId:g._id];
        
        _resultArray = [[IMDAO shareInstance] getGroupsWithUid:[MUser currentUser].uid];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                         withRowAnimation:UITableViewRowAnimationAutomatic];
        
        [[NetWorkManager sharedInstance] delGroupWithGid:g._id success:nil fail:nil];
    }
}


#pragma mark navigatorItem handle
- (void)go2PreViewController {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
