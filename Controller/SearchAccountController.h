//
//  SearchAccountController.h
//  RB
//
//  Created by hjc on 15/12/13.
//  Copyright © 2015年 hjc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchAccountController : UIViewController

@property (strong, nonatomic) IBOutlet UITextField *searchTextField;
@property (strong, nonatomic) IBOutlet UITableView *resultTableView;
@property (strong, nonatomic) IBOutlet UIButton *cancelBtn;

@property (nonatomic, strong) NSMutableArray *resultArray;
- (IBAction)cancelBtnClick:(id)sender;

@end
