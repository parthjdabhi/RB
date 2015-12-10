//
//  MessageDetailViewController.h
//  R&B
//
//  Created by hjc on 15/11/28.
//  Copyright © 2015年 hjc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WeiXinCell.h"
#import "User.h"
#import "MessageInputBar.h"
#import "VoiceInputBar.h"

#import <AVFoundation/AVFoundation.h>

@interface MessageDetailViewController : UIViewController<AVAudioRecorderDelegate, AVAudioPlayerDelegate,
    UINavigationControllerDelegate, UIImagePickerControllerDelegate, WeiXinCellDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIView *inputBar;
@property (strong, nonatomic) IBOutlet UIView *extendInputBar;
@property (strong, nonatomic) IBOutlet MessageInputBar *messageInputBar;
@property (strong, nonatomic) IBOutlet VoiceInputBar *voiceInputBar;

//@property (strong, nonatomic) IBOutlet UIView *inputBar;
//@property (strong, nonatomic) IBOutlet UIButton *voiceBtn;
//@property (strong, nonatomic) IBOutlet UITextField *textField;
//@property (strong, nonatomic) IBOutlet UIButton *submitBtn;

@property int uid;
@property (nonatomic, strong) User *target;
@property (nonatomic, strong) NSMutableArray *resultArray;
@property (nonatomic, strong) UIImageView *recordingVoiceImg;
@property (nonatomic, strong) NSString *kRecordAudioFile;
@property (nonatomic, strong) WeiXinCell *playingCell;
@property (nonatomic, strong) NSMutableArray *imageArray;

@property (nonatomic,strong) AVAudioRecorder *audioRecorder;//音频录音机
@property (nonatomic,strong) AVAudioPlayer *audioPlayer;//音频播放器，用于播放录音文件

@end
