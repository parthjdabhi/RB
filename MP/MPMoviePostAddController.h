//
//  MPMoviePostAddController.h
//  RB
//
//  Created by hjc on 16/3/14.
//  Copyright © 2016年 hjc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MPMovie.h"

@interface MPMoviePostAddController : UIViewController

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewHeightConstraint;

@property MPMovie *movie;

@end
