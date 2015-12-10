//
//  VoiceMessageCell.m
//  R&B
//
//  Created by hjc on 15/12/6.
//  Copyright © 2015年 hjc. All rights reserved.
//

#import "VoiceMessageCell.h"

@implementation VoiceMessageCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        //根据语音长度
        int minwidth = 66;
        int width = minwidth;
        if (_duration < 3) {
        } else if (_duration < 7) {
            width += (_duration-3)*20;
        } else if (_duration < 15) {
            width += 3*20 + (_duration-6)*10;
        } else {
            width += 3*20 + 90;
        }
        
        int height = 50;
        
//        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
//        _voiceBubble.buttonType = UIButtonTypeCustom;
        _voiceBubble.frame = CGRectMake(0, 0, width, height);
        
        //image偏移量
        UIEdgeInsets imageInsert;
        imageInsert.top = -10;
        imageInsert.left = _isHost ? _voiceBubble.frame.size.width - minwidth*2/3 : minwidth*2/3 - _voiceBubble.frame.size.width;
        _voiceBubble.imageEdgeInsets = imageInsert;
        
        [_voiceBubble setImage:[UIImage imageNamed:_isHost?@"SenderVoiceNodePlaying":@"ReceiverVoiceNodePlaying"] forState:UIControlStateNormal];
        UIImage *backgroundImage = [UIImage imageNamed:_isHost?@"SenderVoiceNodeDownloading":@"ReceiverVoiceNodeDownloading"];
        backgroundImage = [backgroundImage stretchableImageWithLeftCapWidth:20 topCapHeight: height/2];
        [_voiceBubble setBackgroundImage:backgroundImage forState:UIControlStateNormal];
        
        _durationLabel.frame = CGRectMake(_isHost?-30:_voiceBubble.frame.size.width, 0, 30, _voiceBubble.frame.size.height);
        _durationLabel.text = [NSString stringWithFormat:@"%f''", _duration];
        _durationLabel.textColor = [UIColor grayColor];
        _durationLabel.font = [UIFont systemFontOfSize:13];
        _durationLabel.textAlignment = NSTextAlignmentCenter;
        _durationLabel.backgroundColor = [UIColor clearColor];
        
        self.contentView.frame = _isHost?CGRectMake(375-60-width, 14, width, height + 6):CGRectMake(0, 14, width, height + 6);
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
