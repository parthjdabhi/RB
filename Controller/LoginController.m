//
//  LoginController.m
//  R&B
//
//  Created by hjc on 15/11/29.
//  Copyright © 2015年 hjc. All rights reserved.
//

#import "LoginController.h"
#import "RegisterController.h"
#import "FriendListController.h"
#import "MessageListController.h"
#import "MeViewController.h"
#import "NetWorkManager.h"
#import "IMDAO.h"
#import "User.h"
#import "UIView+Toast.h"

@interface LoginController ()

@end

@implementation LoginController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)loginAct:(id)sender {
    NSString *un = _unTextField.text;
    NSString *pwd = _pwdTextField.text;
    if (!un.length || !pwd.length) {
        [self.view makeToast:@"请输入登录信息"];
        return;
    }
    
    [[NetWorkManager sharedInstance] loginWithUn:un
                                             pwd:pwd
                                         success:^(NSDictionary *responseObject) {
                                             NSDictionary *userDict = [responseObject objectForKey:@"info"];
                                             NSString *sk = [responseObject objectForKey:@"sk"];
                                             
                                             User *user = [[User alloc] init];
                                             user.uid = [[userDict objectForKey:@"uid"] integerValue];
                                             user.nickname = [userDict objectForKey:@"nickname"];
                                             user.accessToken = sk;
                                             [[IMDAO shareInstance] login:user];
                                             
                                             [User setCurrentUser:user];
                                             
                                             FriendListController *flc = [[FriendListController alloc] init];
                                             MessageListController *mlc = [[MessageListController alloc] init];
                                             MeViewController *mvc = [[MeViewController alloc] init];
                                             
                                             UITabBarController *tabBarController = [[UITabBarController alloc] init];
                                             tabBarController.viewControllers = @[mlc, flc, mvc];
                                             
                                             UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:tabBarController];
                                             [self presentViewController:navController animated:YES completion:nil];
                                         } fail:^(NSError *error) {
                                             [self.view makeToast:[NSString stringWithFormat:@"error:%ld", (long)error.code]];
                                         }];
}

- (IBAction)registerBtnClick:(id)sender {
    RegisterController *rc = [[RegisterController alloc] init];
    
    [self presentViewController:rc animated:YES completion:nil];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

@end
