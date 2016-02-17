//
//  FriendSelectController.h
//  RB
//
//  Created by hjc on 15/12/23.
//  Copyright © 2015年 hjc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FriendSelectController : UIViewController

@property NSInteger groupId;
@property (nonatomic, retain) NSArray *friends;
@property (strong, nonatomic) IBOutlet UIView *selectedUsersView;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

- (instancetype) initWithSelectUsers:(NSArray *) users;
- (instancetype) initWithGid:(NSInteger) gid selectUsers:(NSArray *) users;

@end
