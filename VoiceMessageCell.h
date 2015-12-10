//
//  VoiceMessageCell.h
//  R&B
//
//  Created by hjc on 15/12/6.
//  Copyright © 2015年 hjc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VoiceMessageCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIImageView *avater;
@property (strong, nonatomic) IBOutlet UIButton *voiceBubble;
@property (strong, nonatomic) IBOutlet UILabel *durationLabel;

@property BOOL isHost;
@property float duration;
@property NSString *url;

@end
