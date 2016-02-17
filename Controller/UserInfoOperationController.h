//
//  UserInfoOperationController.h
//  RB
//
//  Created by hjc on 15/12/23.
//  Copyright © 2015年 hjc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DialogMemberCell.h"
#import "MUser.h"
#import "MGroup.h"

@interface UserInfoOperationController : UIViewController<DialogMemberCellDelegate>

@property NSInteger userId;
@property NSInteger groupId;
@property (nonatomic, strong) MUser *user;
@property (nonatomic, strong) MGroup *group;
@property NSMutableArray *tableCells;

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end
