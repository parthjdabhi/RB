//
//  UserInfoController.h
//  RB
//
//  Created by hjc on 15/12/8.
//  Copyright © 2015年 hjc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MUser.h"
#import "MFriend.h"

@interface UserInfoController : UIViewController<UIAlertViewDelegate>

@property NSInteger uid;
@property (nonatomic, strong) MUser *target;
@property (nonatomic, strong) MFriend *friendInfo;

@property NSMutableArray *tableCells;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIButton *friendBtn;
@property (strong, nonatomic) IBOutlet UIButton *sendMsgBtn;
- (IBAction)friendBtnOnClick:(id)sender;
- (IBAction)sendMsgBtnOnClick:(id)sender;

@end
