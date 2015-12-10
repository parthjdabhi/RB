//
//  ViewController.h
//  ByteBuffer
//
//  Created by hjc on 14-6-1.
//  Copyright (c) 2014年 hjc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MessageController : UIViewController
@property (nonatomic, strong) NSMutableArray *resultArray;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIView *inputBar;
@property (strong, nonatomic) IBOutlet UITextField *input;
@property (strong, nonatomic) IBOutlet UIButton *button;
@property (strong, nonatomic) IBOutlet UIButton *voiceBtn;

@property int uid;

@end
