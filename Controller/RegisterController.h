//
//  RegisterController.h
//  RB
//
//  Created by hjc on 15/12/28.
//  Copyright © 2015年 hjc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RegisterController : UIViewController
@property (strong, nonatomic) IBOutlet UITextField *unameTextField;
@property (strong, nonatomic) IBOutlet UITextField *confirmPwdTextField;
@property (strong, nonatomic) IBOutlet UITextField *pwdTextField;
@property (strong, nonatomic) IBOutlet UITextField *nicknameTextField;
@property (strong, nonatomic) IBOutlet UIButton *registerBtn;
@property (strong, nonatomic) IBOutlet UIButton *loginBtn;

@end
