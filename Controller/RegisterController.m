//
//  RegisterController.m
//  RB
//
//  Created by hjc on 15/12/28.
//  Copyright © 2015年 hjc. All rights reserved.
//

#import "RegisterController.h"
#import "LoginController.h"
#import "IMDAO.h"
#import "NetWorkManager.h"
#import "UIView+Toast.h"

@interface RegisterController ()

@end

@implementation RegisterController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)registerBtnClick:(id)sender {
    NSString *un = _unameTextField.text;
    NSString *pwd = _pwdTextField.text;
    NSString *pwd2 = _confirmPwdTextField.text;
    NSString *nickname = _nicknameTextField.text;
    if (!un.length || !pwd.length || !pwd.length || !nickname.length) {
        [self.view makeToast:@"请填写完整信息"];
        return;
    }
    
    if (![pwd isEqualToString:pwd2]) {
        [self.view makeToast:@"两次密码输入不一致"];
        return;
    }
    
    [[NetWorkManager sharedInstance] registerWithUn:un
                                                pwd:pwd nickname:nickname success:^(NSDictionary *responseObject) {
                                                    LoginController *loginController = [[LoginController alloc] init];
                                                    [self presentViewController:loginController animated:YES completion:nil];
                                                } fail:^(NSError *error) {
                                                    [self.view makeToast:[NSString stringWithFormat:@"error:%ld", (long)error.code]];
                                                }];
}
- (IBAction)loginBtnClick:(id)sender {
    LoginController *loginController = [[LoginController alloc] init];
    [self presentViewController:loginController animated:YES completion:nil];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

@end
