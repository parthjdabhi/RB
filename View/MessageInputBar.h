//
//  MessageInputBar.h
//  R&B
//
//  Created by hjc on 15/12/2.
//  Copyright © 2015年 hjc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MessageInputBar : UIView
@property (strong, nonatomic) IBOutlet UIButton *voiceBtn;
@property (strong, nonatomic) IBOutlet UITextField *msgTextField;
@property (strong, nonatomic) IBOutlet UIButton *faceBtn;

+(MessageInputBar *)instance;

@end
