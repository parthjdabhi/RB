//
//  VoiceInputBar.m
//  R&B
//
//  Created by hjc on 15/12/2.
//  Copyright © 2015年 hjc. All rights reserved.
//

#import "VoiceInputBar.h"

@interface VoiceInputBar ()

@end

@implementation VoiceInputBar

+(VoiceInputBar *)instance
{
    NSArray* nibView =  [[NSBundle mainBundle] loadNibNamed:@"VoiceInputBar" owner:nil options:nil];
    
    VoiceInputBar *viBar = [nibView objectAtIndex:0];
    [viBar.keyboardBtn setBackgroundImage:[UIImage imageNamed:@"iconfont-jianpan.png"] forState:UIControlStateNormal];
    [viBar.faceBtn setBackgroundImage:[UIImage imageNamed:@"iconfont-smile.png"] forState:UIControlStateNormal];
    return viBar;
}

@end
