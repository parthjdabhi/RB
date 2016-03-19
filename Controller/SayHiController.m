//
//  SayHiController.m
//  RB
//
//  Created by hjc on 15/12/15.
//  Copyright © 2015年 hjc. All rights reserved.
//

#import "SayHiController.h"
#import "NetWorkManager.h"

@interface SayHiController ()

@end

@implementation SayHiController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {

    UINavigationItem *navigationItem = self.navigationItem;
    UIBarButtonItem *submit = [[UIBarButtonItem alloc] initWithTitle:@"发送"
                                                             style:UIBarButtonItemStylePlain
                                                            target:self
                                                            action:@selector(sendMsg)];
    navigationItem.rightBarButtonItem = submit;
}

- (void)viewWillDisappear:(BOOL)animated {
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) sendMsg {
    NSString *content = [_textField text];
    
    [[NetWorkManager sharedInstance] sayHelloToUid:_uid
                                           content:content
                                           success:^(NSDictionary *responseObject) {
                                               [self.navigationController popViewControllerAnimated:YES];
                                           } fail:^(NSError *error) {
        
                                           }];
}

@end
