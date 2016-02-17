//
//  MessageInputBar.m
//  R&B
//
//  Created by hjc on 15/12/2.
//  Copyright © 2015年 hjc. All rights reserved.
//

#import "MessageInputBar.h"

@interface MessageInputBar ()

@end

@implementation MessageInputBar

+(MessageInputBar *)instance
{
    NSArray* nibView =  [[NSBundle mainBundle] loadNibNamed:@"MessageInputBar" owner:nil options:nil];
    
    MessageInputBar *miBar = [nibView objectAtIndex:0];
    miBar.voiceBtn.layer.cornerRadius = 4;
    miBar.voiceBtn.layer.borderWidth = 1;
    [miBar.voiceBtn setBackgroundImage:[UIImage imageNamed:@"iconfont-voice.png"] forState:UIControlStateNormal];
    [miBar.faceBtn setBackgroundImage:[UIImage imageNamed:@"iconfont-smile.png"] forState:UIControlStateNormal];
    
    miBar.msgTextField.returnKeyType = UIReturnKeyGo;
    
    return miBar;
}



@end
