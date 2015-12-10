//
//  LoginController.m
//  R&B
//
//  Created by hjc on 15/11/29.
//  Copyright © 2015年 hjc. All rights reserved.
//

#import "LoginController.h"
#import "FriendListController.h"
#import "MessageListController.h"

#import "User.h"

@interface LoginController ()

@end

@implementation LoginController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)loginAct:(id)sender {
    [User currentUser].uid = [_textField.text intValue];
    [User currentUser].accessToken = @"MTAxADEwMQAxNjVCNkQ2QTU5QTJDNDY4QzU5MDdCNDBEREE5RkYzQmUzOWM";
    
    FriendListController *flc = [[FriendListController alloc] init];
    MessageListController *mlc = [[MessageListController alloc] init];
    
    UITabBarController *tabBarController = [[UITabBarController alloc] init];
    tabBarController.viewControllers = @[mlc, flc];
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:tabBarController];
    
    [self presentViewController:navController animated:YES completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
