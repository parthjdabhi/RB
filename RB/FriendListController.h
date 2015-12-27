//
//  FriendListController.h
//  R&B
//
//  Created by hjc on 15/11/28.
//  Copyright © 2015年 hjc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FriendListController : UIViewController

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, retain) NSArray *friends;

@end
