//
//  SearchAccountController.h
//  RB
//
//  Created by hjc on 15/12/13.
//  Copyright © 2015年 hjc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchAccountController : UIViewController<UISearchBarDelegate>

@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) IBOutlet UITableView *resultTableView;

@property (nonatomic, strong) NSMutableArray *resultArray;

@end
