//
//  NewFriendListController.h
//  RB
//
//  Created by hjc on 15/12/15.
//  Copyright © 2015年 hjc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"

@interface NewFriendListController : UIViewController

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, retain) NSArray<User *> *users;

@end
