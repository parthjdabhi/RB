//
//  FriendSelectController.h
//  RB
//
//  Created by hjc on 15/12/23.
//  Copyright © 2015年 hjc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FriendSelectController : UIViewController

@property int gid;
@property (nonatomic, retain) NSArray *friends;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

- (instancetype) initWithSelectUsers:(NSArray *) users;
- (instancetype) initWithGid:(int) gid selectUsers:(NSArray *) users;

@end
