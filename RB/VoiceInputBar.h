//
//  VoiceInputBar.h
//  R&B
//
//  Created by hjc on 15/12/2.
//  Copyright © 2015年 hjc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VoiceInputBar : UIView

@property (strong, nonatomic) IBOutlet UIButton *keyboardBtn;
@property (strong, nonatomic) IBOutlet UIButton *voiceInputBtn;
@property (strong, nonatomic) IBOutlet UIButton *faceBtn;

+(VoiceInputBar *)instance;

@end
