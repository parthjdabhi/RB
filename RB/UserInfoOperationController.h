//
//  UserInfoOperationController.h
//  RB
//
//  Created by hjc on 15/12/23.
//  Copyright © 2015年 hjc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DialogMemberCell.h"
#import "User.h"
#import "Group.h"

@interface UserInfoOperationController : UIViewController<DialogMemberCellDelegate>

@property int uid;
@property int gid;
@property (nonatomic, strong) User *user;
@property (nonatomic, strong) Group *group;
@property NSMutableArray *tableCells;

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end
