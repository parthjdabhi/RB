//
//  MPMeMainController.h
//  RB
//
//  Created by hjc on 16/3/15.
//  Copyright © 2016年 hjc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MPMeMainController : UIViewController

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewHeightConstraint;

@end
