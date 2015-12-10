//
//  WeiXinCell.h
//  WeixinDeom
//
//  Created by iHope on 13-12-31.
//  Copyright (c) 2013年 任海丽. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WeiXinCell : UITableViewCell

@property (nonatomic, strong) UIView *bubbleView;
@property (nonatomic, strong) UIImageView *photo;
@property (nonatomic, strong) UIButton *voiceBtn;
@property (nonatomic, strong) NSMutableDictionary *dict;
@property (assign, nonatomic) id delegate;
@property BOOL isPlaying;

- (void) initWithImage:(UIImage *) image isHost:(BOOL) isHost data:(NSMutableDictionary *) dict;
- (void) stopPlayVoice;

@end

@protocol WeiXinCellDelegate <NSObject>

- (void) voiceCellClick:(NSDictionary *) dict cell:(WeiXinCell *) cell;
- (void) pictureCellOnClick:(NSDictionary *) dict;

@end
