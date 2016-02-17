//
//  UserInfoController.h
//  RB
//
//  Created by hjc on 15/12/8.
//  Copyright © 2015年 hjc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"
#import "Friend.h"

@interface UserInfoController : UIViewController

@property NSInteger uid;
@property (nonatomic, strong) User *target;
@property (nonatomic, strong) Friend *friendInfo;

@property NSMutableArray *tableCells;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIButton *friendBtn;
@property (strong, nonatomic) IBOutlet UIButton *sendMsgBtn;
- (IBAction)friendBtnOnClick:(id)sender;
- (IBAction)sendMsgBtnOnClick:(id)sender;

@end
