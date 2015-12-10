//
//  FriendListController.m
//  R&B
//
//  Created by hjc on 15/11/28.
//  Copyright © 2015年 hjc. All rights reserved.
//

#import "FriendListController.h"
#import "Friend.h"
#import "FriendItemCell.h"
#import "MessageDetailViewController.h"
#import "Dialog.h"
#import "IMDAO.h"

@interface FriendListController ()

@end

@implementation FriendListController

-(instancetype) init {
    self = [super init];
    if (self) {
        self.tabBarItem.title = @"好友";
        UIImage *i = [UIImage imageNamed:@"iconfont-contact.png"];
        self.tabBarItem.image = i;
    }
    
    _friends = [[IMDAO shareInstance] getFriendsWithUid: [User currentUser].uid];
    
    if (_friends.count == 0) {
        Friend *f = [[Friend alloc] init];
        f.nickname = @"Tom";
        f.uid = 101;
        
        Friend *f2 = [[Friend alloc] init];
        f2.nickname = @"Jim";
        f2.uid = 102;
        
        Friend *f3 = [[Friend alloc] init];
        f3.nickname = @"Tony";
        f3.uid = 103;
        
        [[IMDAO shareInstance] saveUsers: @[f, f2, f3]];
        [[IMDAO shareInstance] saveFriends: @[f, f2, f3]];
        _friends = [[IMDAO shareInstance] getFriendsWithUid: [User currentUser].uid];
    }
    
    UINib *nib = [UINib nibWithNibName:@"FriendItemCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"FriendItemCell"];
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
    cell.avater.image = [UIImage imageNamed:[NSString stringWithFormat:@"avater_%d.jpg", f.uid]];
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    MessageDetailViewController *mdvc = [[MessageDetailViewController alloc] init];
    Friend *f = (Friend *)[_friends objectAtIndex:[indexPath row]];
    mdvc.uid = f.uid;
    mdvc.target = f;
    
    [self.navigationController pushViewController:mdvc animated:YES];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here, for example:
    // Create the next view controller.
    <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:<#@"Nib name"#> bundle:nil];
    
    // Pass the selected object to the new view controller.
    
    // Push the view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
