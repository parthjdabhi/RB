//
//  WeiXinCell.m
//  WeixinDeom
//
//  Created by iHope on 13-12-31.
//  Copyright (c) 2013年 任海丽. All rights reserved.
//

#import "WeiXinCell.h"
#import "IMFileHelper.h"
#import <QuartzCore/QuartzCore.h>
#import <SDWebImage/UIImageView+WebCache.h>

@implementation WeiXinCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _bubbleView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 375, 0)];
        _bubbleView.backgroundColor = [UIColor clearColor];
        _photo = [[UIImageView alloc]initWithFrame:CGRectMake(10, 10, 40, 40)];
        [self.contentView addSubview:_bubbleView];
        [self.contentView addSubview:_photo];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) initWithImage:(UIImage *) image isHost:(BOOL) isHost data:(NSMutableDictionary *) dict {
    _photo.image = image;
    _photo.frame = CGRectMake((isHost)?375-50:10, 10, 40, 40);
    _dict = dict;
    _photo.userInteractionEnabled = YES;
    [_photo addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(avaterOnClick:)]];
    
    if ([[dict objectForKey:@"type"] isEqualToString:@"2"]) {
        [self yuyinView:[[dict objectForKey:@"duration"] intValue] from:isHost withPosition:55 withView:_bubbleView];
    } else if ([[dict objectForKey:@"type"] isEqualToString:@"3"]) {
//        NSString *url = [[IMFileHelper shareInstance] getThumbPathWithName:[dict objectForKey:@"url"]];
        [self pictureView:[dict objectForKey:@"thumb"] from:isHost withPosition:55 withView:_bubbleView];
//    } else if ([[dict objectForKey:@"type"] isEqualToString:@"99"]){
//        _timeLabel.text = [dict objectForKey:@"stamp"];
//        CGSize size = [_timeLabel.text sizeWithAttributes:
//                       @{NSFontAttributeName: [UIFont systemFontOfSize:13.0f]}];
//        _timeLabel.backgroundColor = [UIColor grayColor];
//        _timeLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:13];
//        _timeLabel.layer.cornerRadius = 3;
//        _timeLabel.clipsToBounds = YES;
//        _timeLabel.frame = CGRectMake(0, 0, size.width, size.height);
//        _timeLabel.center = self.contentView.center;
    } else {
        [self bubbleView:[dict objectForKey:@"content"] from:isHost withPosition:55 withView:_bubbleView];
    }
}

//泡泡文本
- (void)bubbleView:(NSString *)text from:(BOOL)isHost withPosition:(int)position withView:(UIView*)bulleView{
    for (UIView *subView in bulleView.subviews) {
        [subView removeFromSuperview];
    }
    
    //计算大小
    UIFont *font = [UIFont systemFontOfSize:14];
	CGSize size = [text sizeWithFont:font constrainedToSize:CGSizeMake(180.0f, 20000.0f) lineBreakMode:NSLineBreakByWordWrapping];
    
	// build single chat bubble cell with given text
	UIView *returnView = bulleView;
	returnView.backgroundColor = [UIColor clearColor];
	
    //背影图片
	UIImage *bubble = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:isHost?@"SenderAppNodeBkg_HL":@"ReceiverTextNodeBkg" ofType:@"png"]];
    
	UIImageView *bubbleImageView = [[UIImageView alloc] initWithImage:[bubble stretchableImageWithLeftCapWidth:floorf(bubble.size.width/2) topCapHeight:floorf(bubble.size.height/2)]];
//	NSLog(@"%f,%f",size.width,size.height);
	
    
    //添加文本信息
	UILabel *bubbleText = [[UILabel alloc] initWithFrame:CGRectMake(isHost?15.0f:22.0f, 15.0f, size.width+10, size.height+10)];
	bubbleText.backgroundColor = [UIColor clearColor];
	bubbleText.font = font;
	bubbleText.numberOfLines = 0;
	bubbleText.lineBreakMode = NSLineBreakByWordWrapping;
	bubbleText.text = text;
	
	bubbleImageView.frame = CGRectMake(0.0f, 10.0f, bubbleText.frame.size.width+30.0f, bubbleText.frame.size.height+20.0f);
    
	if(isHost)
		returnView.frame = CGRectMake(375-position-(bubbleText.frame.size.width+30.0f), 0.0f, bubbleText.frame.size.width+30.0f, bubbleText.frame.size.height+30.0f);
	else
		returnView.frame = CGRectMake(position, 0.0f, bubbleText.frame.size.width+30.0f, bubbleText.frame.size.height+30.0f);
	
//    [returnView setBackgroundColor:[UIColor redColor]];
//    NSLog(@"%f", returnView.frame.size.height);
	[returnView addSubview:bubbleImageView];
	[returnView addSubview:bubbleText];
    
}

//泡泡语音
- (void)yuyinView:(NSInteger)duration from:(BOOL)isHost withPosition:(int)position withView:(UIView *)parentView{
    
    for (UIView *subView in parentView.subviews) {
        [subView removeFromSuperview];
    }
    UIView *returnView = parentView;
    
    //根据语音长度
    int minwidth = 66;
    int width = minwidth;
    if (duration < 3) {
    } else if (duration < 7) {
        width += (duration-3)*20;
    } else if (duration < 15) {
        width += 3*20 + (duration-6)*10;
    } else {
        width += 3*20 + 90;
    }
    
    int height = 50;
    
    _voiceBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_voiceBtn addTarget:self action:@selector(playOrStopVoice) forControlEvents:UIControlEventTouchUpInside];
 
    _voiceBtn.frame = CGRectMake(0, 0, width, height);

    //image偏移量
    UIEdgeInsets imageInsert;
    imageInsert.top = -10;
    imageInsert.left = isHost ? _voiceBtn.frame.size.width - minwidth*2/3 : minwidth*2/3 - _voiceBtn.frame.size.width;
    _voiceBtn.imageEdgeInsets = imageInsert;
    
    [_voiceBtn setImage:[UIImage imageNamed:isHost?@"SenderVoiceNodePlaying":@"ReceiverVoiceNodePlaying"] forState:UIControlStateNormal];
    UIImage *backgroundImage = [UIImage imageNamed:isHost?@"SenderVoiceNodeDownloading":@"ReceiverVoiceNodeDownloading"];
    backgroundImage = [backgroundImage stretchableImageWithLeftCapWidth:20 topCapHeight: height/2];
    [_voiceBtn setBackgroundImage:backgroundImage forState:UIControlStateNormal];
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(isHost?-30:_voiceBtn.frame.size.width, 0, 30, _voiceBtn.frame.size.height)];
    label.text = [NSString stringWithFormat:@"%d''", (int)duration];
    label.textColor = [UIColor grayColor];
    label.font = [UIFont systemFontOfSize:13];
    label.textAlignment = NSTextAlignmentCenter;
    label.backgroundColor = [UIColor clearColor];
    
    returnView.frame = isHost?CGRectMake(375-position-width, 10.0f, width, height + 6):CGRectMake(position, 12, width, height + 6);
    
//    NSLog(@"%f", yuyinView.frame.size.height);
//    [returnView setBackgroundColor:[UIColor blueColor]];
//    [button addSubview:label];
    [returnView addSubview:label];
    [returnView addSubview:_voiceBtn];
}

- (void) pictureView:(NSString *)path
                from:(BOOL)isHost
        withPosition:(int)position
            withView:(UIView *) parentView {
    for (UIView *subView in parentView.subviews) {
        [subView removeFromSuperview];
    }
    
    UIView *returnView = parentView;
    returnView.backgroundColor = [UIColor clearColor];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[[[UIImage alloc] init] stretchableImageWithLeftCapWidth:10 topCapHeight:10]];

    NSURL *url = [NSURL URLWithString:path];
    [imageView sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"avater_default.png"]
                        completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
//                            NSLog(@"cacheType:%ld", (long)cacheType);
//                            NSLog(@"imageURL:%@", imageURL);
                            
                            int witdh = image.size.width;
                            int height = image.size.height;
                            
                            if (image.size.height > 160) {
                                height = 160;
                                witdh = height / image.size.height * image.size.width;
                            }
                            
                            if (image.size.width > 100) {
                                witdh = 100;
                                height = witdh / image.size.width * image.size.height;
                            }
                            
                            imageView.frame = CGRectMake(0.0f, 10.0f, witdh, height);
                            
                            if (isHost)
                                returnView.frame = CGRectMake(375-position-(imageView.frame.size.width), 0.0f, imageView.frame.size.width, imageView.frame.size.height);
                            else
                                returnView.frame = CGRectMake(position, 0.0f, imageView.frame.size.width, imageView.frame.size.height);
                            
                            [returnView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(photoOnClick:)]];
                            [returnView addSubview:imageView];
                        }];
}

- (void) playOrStopVoice {
    if (!_isPlaying) {
        [_voiceBtn.layer addAnimation:[self opacityForever_Animation:0.5] forKey:nil];
        _isPlaying = YES;
    } else {
        [_voiceBtn.layer removeAllAnimations];
        _isPlaying = NO;
    }
    
    [_delegate voiceCellOnClick:_dict cell:self];
}

- (void) stopPlayVoice {
    _isPlaying = NO;
    [_voiceBtn.layer removeAllAnimations];
}

- (void) photoOnClick:(NSNotification *)note {
    [_delegate pictureCellOnClick:_dict];
}

- (void) avaterOnClick:(NSNotification *)note {
    [_delegate avaterImageOnClick:_dict];
}

#pragma mark === 永久闪烁的动画 ======
-(CABasicAnimation *)opacityForever_Animation:(float)time
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];//必须写opacity才行。
    animation.fromValue = [NSNumber numberWithFloat:1.0f];
    animation.toValue = [NSNumber numberWithFloat:0.0f];//这是透明度。
    animation.autoreverses = YES;
    animation.duration = time;
    animation.repeatCount = MAXFLOAT;
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    animation.timingFunction=[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];///没有的话是均匀的动画。
    return animation;
}

@end
