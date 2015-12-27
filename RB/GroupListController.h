//
//  GroupListController.h
//  RB
//
//  Created by hjc on 15/12/14.
//  Copyright © 2015年 hjc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GroupListController : UIViewController

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSArray *resultArray;

@end
