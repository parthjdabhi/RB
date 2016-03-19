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
#import "MUser.h"
#import "RBIMClient.h"
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
                                             
                                             MUser *user = [[MUser alloc] init];
                                             user.uid = [[userDict objectForKey:@"uid"] integerValue];
                                             user.nickname = [userDict objectForKey:@"nickname"];
                                             user.avatarUrl = [userDict objectForKey:@"avatar_url"];
                                             user.avatarThumbUrl = [userDict objectForKey:@"avatar_thumb"];
                                             user.accessToken = sk;
                                             
                                             [[IMDAO shareInstance] login:user];

                                             FriendListController *flc = [[FriendListController alloc] init];
                                             MessageListController *mlc = [[MessageListController alloc] init];
                                             MeViewController *mvc = [[MeViewController alloc] init];
                                             
                                             UINavigationController *n1 = [[UINavigationController alloc] initWithRootViewController:mlc];
                                             UINavigationController *n2 = [[UINavigationController alloc] initWithRootViewController:flc];
                                             UINavigationController *n3 = [[UINavigationController alloc] initWithRootViewController:mvc];
                                             
                                             UITabBarController *tabBarController = [[UITabBarController alloc] init];
                                             tabBarController.viewControllers = @[n1, n2, n3];
                                             
                                             [[UINavigationBar appearance] setBarStyle:UIBarStyleBlack];
                                             [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
                                             
                                             [self presentViewController:tabBarController animated:YES completion:nil];
                                             
                                             [[RBIMClient instance] connectIM];
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
