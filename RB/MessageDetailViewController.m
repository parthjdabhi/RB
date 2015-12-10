//
//  MessageDetailViewController.m
//  R&B
//
//  Created by hjc on 15/11/28.
//  Copyright © 2015年 hjc. All rights reserved.
//

#import "MessageDetailViewController.h"

#define IS_IPHONE5 (568.0f==[UIScreen mainScreen].bounds.size.height)
#define IS_IOS7  ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
#define IS_UP_IOS6 ([[UIDevice currentDevice].systemVersion floatValue] >= 6.0)

//#import "MessageController.h"
#import "PictureViewController.h"
#import "IMClient.h"
#import "AppProfile.h"
#import "Message.h"
#import "IMDAO.h"
#import "IMImageStore.h"
#import "IMFileHelper.h"
#import "UIImage+ResizeMagick.h"
//#import "VoiceMessageCell.h"
#import <AudioToolbox/AudioServices.h>
#include <AudioToolbox/AudioToolbox.h>

#define VoiceMessageCellIdentifier @"VoiceMessageCellIdentifier"

//@interface MessageController()
//{
//    Connection *connection;
//}

//@end

@implementation MessageDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onReceivedMsgNotifycation:) name:ReceiveMessageNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(changeKeyBoard:) name:UIKeyboardWillChangeFrameNotification object:nil];
   
//        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"weixin",@"name",@"微信团队欢迎你。很高兴你开启了微信生活，期待能为你和朋友们带来愉快的沟通体检。",@"content", nil];
//        NSDictionary *dict1 = [NSDictionary dictionaryWithObjectsAndKeys:@"rhl",@"name",@"hello",@"content",@"1",@"mine", nil];
//        NSDictionary *dict2 = [NSDictionary dictionaryWithObjectsAndKeys:@"rhl",@"name",@"0",@"content", nil];
//        NSDictionary *dict3 = [NSDictionary dictionaryWithObjectsAndKeys:@"weixin",@"name",@"谢谢反馈，已收录。",@"content", nil];
//        NSDictionary *dict4 = [NSDictionary dictionaryWithObjectsAndKeys:@"rhl",@"name",@"0",@"content", nil];
//        NSDictionary *dict5 = [NSDictionary dictionaryWithObjectsAndKeys:@"weixin",@"name",@"谢谢反馈，已收录。",@"content", nil];
//        NSDictionary *dict6 = [NSDictionary dictionaryWithObjectsAndKeys:@"rhl",@"name",@"大数据测试，长数据测试，大数据测试，长数据测试，大数据测试，长数据测试，大数据测试，长数据测试，大数据测试，长数据测试，大数据测试，长数据测试。",@"content", nil];
//    
//        _resultArray = [NSMutableArray arrayWithObjects:dict,dict1,dict2,dict3,dict4,dict5,dict6, nil];
    
    int uid = _uid;
    NSArray *msgs = [[IMDAO shareInstance] getMessageWithUid:uid];
    int unreadCount = [[IMDAO shareInstance] getUnreadCountWithUid:uid];
    [[AppProfile shareInstace] incrUnreadCount:-unreadCount];
    
    [[IMDAO shareInstance] clearUnreadCountWithUid:uid];
    
    _resultArray = [[NSMutableArray alloc] init];
    _imageArray = [[NSMutableArray alloc] init];
    for (Message *msg in msgs) {
        NSDictionary *dict = nil;
        
        if (msg.contentType == 2) {
            VoiceMessage *voiceMsg = (VoiceMessage *) msg;
            dict = [NSDictionary dictionaryWithObjectsAndKeys:
                    [NSString stringWithFormat:@"%d", voiceMsg.from], @"name",
                    [NSString stringWithFormat:@"%d", voiceMsg.duration], @"duration",
                    @"2", @"type",
                    voiceMsg.url, @"url",
                    msg.from == [User currentUser].uid ? @"1":@"0", @"mine",
                    nil];
        } else if (msg.contentType == 3) {
            PictureMessage *messageMsg = (PictureMessage *) msg;
            dict = [NSDictionary dictionaryWithObjectsAndKeys:
                    [NSString stringWithFormat:@"%d", messageMsg.from], @"name",
                    @"3", @"type",
                    messageMsg.url, @"url",
                    msg.from == [User currentUser].uid ? @"1":@"0", @"mine",
                    [NSString stringWithFormat:@"%lu", (unsigned long)_imageArray.count], @"idx",
                    nil];
            
            [_imageArray addObject:dict];
        } else {
            dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d",msg.from], @"name", msg.messageContent, @"content", msg.from == [User currentUser].uid ? @"1":@"0", @"mine", nil];
        }
        [_resultArray addObject:dict];
    }
    
    if(_resultArray.count > 0) {
        [_tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:_resultArray.count-1 inSection:0] animated:false scrollPosition:UITableViewScrollPositionBottom];
    }
    
    UINavigationItem *navigationItem = [[self.navigationController.viewControllers firstObject] navigationItem];
    UIBarButtonItem *back = [[UIBarButtonItem alloc] initWithTitle:@"返回"
                                                             style:UIBarButtonItemStylePlain
                                                            target:nil
                                                            action:nil];
    navigationItem.backBarButtonItem = back;
    self.title = _target.nickname;
    
    _voiceInputBar = [VoiceInputBar instance];
    _voiceInputBar.frame = CGRectMake(0, 607, _voiceInputBar.frame.size.width, _voiceInputBar.frame.size.height);
    [_voiceInputBar.keyboardBtn addTarget:self action:@selector(switchInputBar) forControlEvents: UIControlEventTouchUpInside];
    [_voiceInputBar.voiceInputBtn addTarget:self action:@selector(startRecordVoice) forControlEvents: UIControlEventTouchDown];
    [_voiceInputBar.voiceInputBtn addTarget:self action:@selector(stopRecordVoice) forControlEvents: UIControlEventTouchUpInside];
    [_voiceInputBar.voiceInputBtn addTarget:self action:@selector(stopRecordVoice) forControlEvents: UIControlEventTouchUpOutside];
    [_voiceInputBar.faceBtn addTarget:self action:@selector(switchExtendInput) forControlEvents:UIControlEventTouchDown];
    
    [self.view addSubview: _voiceInputBar];
    
    _messageInputBar = [MessageInputBar instance];
    _messageInputBar.frame = CGRectMake(0, 607, _messageInputBar.frame.size.width, _messageInputBar.frame.size.height);
    [_messageInputBar.voiceBtn addTarget:self action:@selector(switchInputBar) forControlEvents: UIControlEventTouchUpInside];
    [_messageInputBar.msgTextField addTarget:self action:@selector(sendMessage:) forControlEvents:UIControlEventEditingDidEndOnExit];
    [_messageInputBar.faceBtn addTarget:self action:@selector(switchExtendInput) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview: _messageInputBar];
    
    //注册收起键盘手势
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dissKeyBoard:)];
    //设置成NO表示当前控件响应后会传播到其他控件上，默认为YES。
    tapGestureRecognizer.cancelsTouchesInView = NO;
    //将触摸事件添加到当前view
    [self.view addGestureRecognizer:tapGestureRecognizer];
    
//    [self.tableView registerClass:[VoiceMessageCell class] forCellReuseIdentifier:VoiceMessageCellIdentifier];
    // 启用估算行高
//    self.tableView.rowHeight = UITableViewAutomaticDimension;
//    self.tableView.estimatedRowHeight = 44.0; // 设置为一个接近“平均”行高的值

    [self setAudioSession];
    //    connection = [Connection shareInstace];
    //    [connection connect];
}

- (void) viewWillDisappear:(BOOL)animated {
    int unreadCount = [[IMDAO shareInstance] getUnreadCountWithUid:_uid];
    [[AppProfile shareInstace] incrUnreadCount:-unreadCount];
    [[IMDAO shareInstance] clearUnreadCountWithUid:_uid];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark tableview delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _resultArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dict = [_resultArray objectAtIndex:indexPath.row];
    
    if ([[dict objectForKey:@"type"] isEqualToString:@"2"]) {
        return 60;
    } else if ([[dict objectForKey:@"type"] isEqualToString:@"3"]) {
        NSString *path = [[IMFileHelper shareInstance] getPathWithName:[dict objectForKey:@"url"]];
        UIImage *image = [UIImage imageWithContentsOfFile:path];
        if (!image) {
            return 60;
        }
        
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

        if (height + 10 > 60) {
            return height + 10 ;
        }
        return 60;
    } else {
        UIFont *font = [UIFont systemFontOfSize:14];
        CGSize size = [[dict objectForKey:@"content"] sizeWithFont:font constrainedToSize:CGSizeMake(180.0f, 20000.0f) lineBreakMode:NSLineBreakByWordWrapping];
        
        return size.height+44;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    NSMutableDictionary *dict = [_resultArray objectAtIndex:indexPath.row];
//    UITableViewCell *cell = nil;
//    if ([[dict objectForKey:@"type"] isEqualToString:@"2"]) {
//        VoiceMessageCell *vmc = [tableView dequeueReusableCellWithIdentifier:VoiceMessageCellIdentifier];
//        BOOL isHost = [[dict objectForKey:@"mine"] isEqualToString:@"1"];
//        UIImage *avater = nil;
//        avater = [UIImage imageNamed:[NSString stringWithFormat:@"avater_%d.jpg", isHost? [[User currentUser] uid]:_uid]];
//        if (!avater) {
//            avater = [UIImage imageNamed:@"photo.png"];
//        }
//        vmc.avater.image = avater;
//        vmc.duration = [[dict objectForKey:@"duration"] floatValue];
//        vmc.url = [dict objectForKey:@"url"];
//        
//        cell = vmc;
//    }
//    return cell;
    static NSString *CellIdentifier = @"WeiXinCell";
    WeiXinCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[WeiXinCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    NSMutableDictionary *dict = [_resultArray objectAtIndex:indexPath.row];
    UIImage *image = nil;
    BOOL isHost = [[dict objectForKey:@"mine"] isEqualToString:@"1"];
    image = [UIImage imageNamed:[NSString stringWithFormat:@"avater_%d.jpg", isHost? [[User currentUser] uid]:_uid]];
    if (!image) {
        image = [UIImage imageNamed:@"photo.png"];
    }
    
//    if ([[dict objectForKey:@"type"] isEqualToString:@"3"]) {
//        NSString *url = [[IMFileHelper shareInstance] getPathWithName:[dict objectForKey:@"url"] prefix:@"png"];
//        [dict removeObjectForKey:@"url"];
//        [dict setObject:url forKey:@"url"];
//    }
    
    cell.delegate = self;
    [cell initWithImage:image isHost:isHost data:dict];
    
    [cell setNeedsUpdateConstraints];
    [cell updateConstraintsIfNeeded];
    
    if (indexPath.row == _resultArray.count - 1) {
        [_tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
    
    return cell;
}

//- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    NSDictionary *dict = [_resultArray objectAtIndex:indexPath.row];
//    if ([[dict objectForKey:@"type"] isEqualToString:@"2"]) {
//        if (!_audioPlayer.isPlaying) {
//            NSURL *audioUrl  = [NSURL fileURLWithPath:[[IMFileHelper shareInstance] getPathWithName:[dict objectForKey:@"url"]]];
//            _audioPlayer = [self audioPlayer:audioUrl];
//            [_audioPlayer play];
//        } else {
//            [_audioPlayer stop];
//        }
//    }
//    
//}

#pragma mark imagepicker delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    
    NSString *key = [[[NSUUID alloc] init] UUIDString];
    [[IMImageStore shareStore] setImage:image forKey:key];

    key = [NSString stringWithFormat:@"%@.png", key];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *path = [[IMFileHelper shareInstance] getPathWithName:key];
    [fileManager createFileAtPath:path contents:[self getNSDataFromImage:image] attributes:nil];
    
    UIImage *thumb = [image resizedImageWithMaximumSize:CGSizeMake(320, 320)];
    NSString *thumbPath = [[IMFileHelper shareInstance] getThumbPathWithName:key];
    [fileManager createFileAtPath:thumbPath contents:[self getNSDataFromThumb:thumb] attributes:nil];
    
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          [NSString stringWithFormat:@"%d", [User currentUser].uid], @"name",
                          key, @"url",
                          @"3", @"type",
                          @"1", @"mine",
                          [NSString stringWithFormat:@"%lu", (unsigned long)_imageArray.count], @"idx",
                          nil];
    
    [_imageArray addObject:dict];
    [_resultArray addObject:dict];
    [[IMClient shareInstace] sendPictureToUid:self.uid path: key];
    [self refreshMessageList];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

-(NSData *) getNSDataFromImage:(UIImage *) image {
    NSData *data = UIImagePNGRepresentation(image);
    if (data == nil) {
        data = UIImageJPEGRepresentation(image, 1);
    }
    return data;
}

-(NSData *) getNSDataFromThumb:(UIImage *) image {
    NSData *data = data = UIImageJPEGRepresentation(image, 0.1);
    if (data == nil) {
        UIImagePNGRepresentation(image);
    }
    return data;
}

#pragma mark cell delegate

- (void) voiceCellClick:(NSDictionary *)dict cell:(WeiXinCell *)cell {
    if ([[dict objectForKey:@"type"] isEqualToString:@"2"]) {
        if (cell == _playingCell) {
            if (!_audioPlayer.isPlaying) {
                NSURL *audioUrl = [NSURL fileURLWithPath:[[IMFileHelper shareInstance] getPathWithName:[dict objectForKey:@"url"]]];
                _audioPlayer = [self audioPlayer:audioUrl];
                [_audioPlayer play];
                _playingCell = cell;
            } else {
                [_audioPlayer stop];
                [_playingCell stopPlayVoice];
                _playingCell = nil;
            }
        } else {
            [_playingCell stopPlayVoice];
            NSURL *audioUrl = [NSURL fileURLWithPath:[[IMFileHelper shareInstance] getPathWithName:[dict objectForKey:@"url"]]];
            _audioPlayer = [self audioPlayer:audioUrl];
            [_audioPlayer play];
            _playingCell = cell;
        }
       
    }
    
}

- (void) pictureCellOnClick:(NSDictionary *) dict {
    if ([[dict objectForKey:@"type"] isEqualToString:@"3"]) {
        
        PictureViewController *pvc = [[PictureViewController alloc] initWithImages:_imageArray index:[[dict objectForKey:@"idx"] integerValue]];
//        NSString *url = [[IMFileHelper shareInstance] getPathWithName:[dict objectForKey:@"url"]];
        //        [pvc.imageView setImage: [UIImage imageWithContentsOfFile:url]];
//        pvc.imageUrl = url;
//        pvc.imgArr = _imageArray;
//        pvc.currentIndex = [_imageArray indexOfObject:dict];
        [self.navigationController pushViewController:pvc animated:YES];
    }
}

#pragma mark handle delegate

-(void)changeKeyBoard:(NSNotification *)aNotifacation
{
    NSValue *keyboardBeginBounds=[[aNotifacation userInfo]objectForKey:UIKeyboardFrameBeginUserInfoKey];
    NSValue *keyboardEndBounds=[[aNotifacation userInfo]objectForKey:UIKeyboardFrameEndUserInfoKey];
    
    CGRect beginRect=[keyboardBeginBounds CGRectValue];
    CGRect endRect=[keyboardEndBounds CGRectValue];
    
    [UIView animateWithDuration:[[aNotifacation.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue]
                          delay:0.0f
                        options:[[aNotifacation.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue]
                     animations:^
     {
         if (endRect.origin.y < beginRect.origin.y) {
//             NSLog(@"endRect.origin.y:%f", endRect.origin.y);
//             NSLog(@"_tableView.center.y:%f", _tableView.center.y - endRect.size.height);
             _tableView.center = CGPointMake(_tableView.center.x, _tableView.center.y - beginRect.origin.y + endRect.origin.y);
             _messageInputBar.center = CGPointMake(_messageInputBar.center.x, _messageInputBar.center.y - beginRect.origin.y + endRect.origin.y);
         } else {
             _tableView.center = CGPointMake(_tableView.center.x, _tableView.center.y + _voiceInputBar.center.y - _messageInputBar.center.y);
             _messageInputBar.center = _voiceInputBar.center;
         }
     }
                     completion:^(BOOL finished)
     {
         
     }];
}
//
//
- (void) dissKeyBoard:(NSNotification *)note
{
    [_messageInputBar.msgTextField resignFirstResponder];
}

- (void) switchInputBar {
    if (_messageInputBar.hidden) {
        _messageInputBar.hidden = NO;
    } else {
        _messageInputBar.hidden = YES;
    }
//    [self.view exchangeSubviewAtIndex:0 withSubviewAtIndex:1];
}

- (void) switchExtendInput {
    if (!_extendInputBar) {
        _extendInputBar = [[UIView alloc]initWithFrame:CGRectMake(0, 517, 375, 90)];
        _extendInputBar.userInteractionEnabled = YES;
        //    extendInput.backgroundColor = [UIColor clearColor];
        
        // 图片
        UIImage *pic = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"iconfont-tupian" ofType:@"png"]];
        // 拍照
        UIImage *photo = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"iconfont-paizhao" ofType:@"png"]];
        
        UIImageView *picView = [[UIImageView alloc] initWithImage:pic];
        picView.userInteractionEnabled = YES;
        picView.frame = CGRectMake(10, 10, 64, 64);
        [picView addGestureRecognizer: [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(getPhotoFromLibrary:)]];

        UIImageView *photoView = [[UIImageView alloc] initWithImage:photo];
        [photoView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(getPhotoFromCamera:)]];
        photoView.userInteractionEnabled = YES;
        photoView.frame = CGRectMake(70, 10, 64, 64);
        
        [_extendInputBar addSubview:picView];
        [_extendInputBar addSubview:photoView];
        
        [self.view addSubview:_extendInputBar];
    } else {
        if (_extendInputBar.isHidden) {
            _extendInputBar.hidden = NO;
        } else {
            _extendInputBar.hidden = YES;
        }
    }
}

- (void) getPhotoFromLibrary:(id)sender {
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePicker.delegate = self;
    [self presentViewController:imagePicker animated:YES completion:nil];
}

- (void) getPhotoFromCamera:(id)sender {
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    } else {
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }

    imagePicker.delegate = self;
    [self presentViewController:imagePicker animated:YES completion:nil];
}

- (void) startRecordVoice {
    NSLog(@"start");
    _recordingVoiceImg = [[UIImageView alloc] initWithFrame:CGRectMake(150, 300, 64, 64)];
    [_recordingVoiceImg setImage: [UIImage imageNamed:@"iconfont-record.png"]];

    [self.view addSubview:_recordingVoiceImg];
    
    if (![self.audioRecorder isRecording]) {
        [self.audioRecorder record];//首次使用应用时如果调用record方法会询问用户是否允许使用麦克风
//        self.timer.fireDate=[NSDate distantPast];
    }
}

- (void) stopRecordVoice {
    NSLog(@"stop");
    _recordingVoiceImg.hidden = YES;
    
    [self.audioRecorder stop];
//    self.timer.fireDate=[NSDate distantFuture];
//    self.audioPower.progress=0.0;
    
    NSString *voicePath = _kRecordAudioFile;
    _kRecordAudioFile = nil;
    AVURLAsset* audioAsset = [AVURLAsset URLAssetWithURL:[self getSavePath:voicePath] options:nil];
    float audioDurationSeconds = CMTimeGetSeconds(audioAsset.duration);
    
    if (audioDurationSeconds < 1) {
        return;
    }
    
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
            [NSString stringWithFormat:@"%d", [User currentUser].uid], @"name",
            [NSString stringWithFormat:@"%f", audioDurationSeconds], @"duration",
            voicePath, @"url",
            @"2", @"type",
            @"1", @"mine",
            nil];

    [_resultArray addObject:dict];
    [[IMClient shareInstace] sendVoiceToUid:self.uid path: voicePath duration:audioDurationSeconds];
    [self refreshMessageList];
}

- (void) sendMessage:(UITextField *)textField {
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          [NSString stringWithFormat:@"%d", [User currentUser].uid], @"name",
                          _messageInputBar.msgTextField.text, @"content", @"1", @"mine", nil];
    [_resultArray addObject:dict];
    [[IMClient shareInstace] sendMessageToUid:self.uid content:_messageInputBar.msgTextField.text];
    [self refreshMessageList];
    _messageInputBar.msgTextField.text = nil;
}

-(void) onReceivedMsgNotifycation:(NSNotification *)aNotifacation
{
    Message *msg = (Message *)[aNotifacation object];

    NSDictionary *dict = nil;
    [msg parseMessageBody];
    
    if (msg.from != _uid) {
        return;
    }
    
    if (msg.contentType == 2) {
        VoiceMessage *voiceMsg = [VoiceMessage initWithMessage:msg];
        dict = [NSDictionary dictionaryWithObjectsAndKeys:
                [NSString stringWithFormat:@"%d", voiceMsg.from], @"name",
                [NSString stringWithFormat:@"%d", voiceMsg.duration], @"duration",
                @"2", @"type",
                voiceMsg.url, @"url",
                msg.from == [User currentUser].uid ? @"1":@"0", @"mine",
                nil];
    } else if (msg.contentType == 3) {
        PictureMessage *pictureMsg = [PictureMessage initWithMessage:msg];
        dict = [NSDictionary dictionaryWithObjectsAndKeys:
                [NSString stringWithFormat:@"%d", pictureMsg.from], @"name",
                @"3", @"type",
                pictureMsg.url, @"url",
                msg.from == [User currentUser].uid ? @"1":@"0", @"mine",
                nil];
    } else {
        dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d",msg.from], @"name", msg.messageContent, @"content", msg.from == [User currentUser].uid ? @"1":@"0", @"mine", nil];
    }
    
    [_resultArray addObject:dict];

    if(self.isViewLoaded && self.view.window) {
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self refreshMessageList];
        });
    }
}

-(void) refreshMessageList
{
    if(_resultArray.count > 0)
    {
        [_tableView reloadData];
        [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_resultArray.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

#pragma mark - audio
/**
 *  设置音频会话
 */
- (void) setAudioSession {
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    //设置为播放和录音状态，以便可以在录制完之后播放录音
    [audioSession setCategory:AVAudioSessionCategoryRecord error:nil];
//    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [audioSession setActive:YES error:nil];
}

/**
 *  取得录音文件保存路径
 *
 *  @return 录音文件路径
 */
- (NSURL *) newSavePath {
    NSString *key = [[[NSUUID alloc] init] UUIDString];
    _kRecordAudioFile = [NSString stringWithFormat:@"%d-%@.aac", self.uid, key];
    NSString *urlStr = [[IMFileHelper shareInstance] getPathWithName:_kRecordAudioFile];
    NSLog(@"newSavePath file path:%@", urlStr);
    NSURL *url = [NSURL fileURLWithPath:urlStr];
    return url;
}

- (NSURL *) getSavePath {
    NSString *urlStr = [[IMFileHelper shareInstance] getPathWithName:_kRecordAudioFile];
    NSLog(@"getSavePath file path:%@", urlStr);
    NSURL *url = [NSURL fileURLWithPath:urlStr];
    return url;
}

- (NSURL *) getSavePath:(NSString *) title {
    NSString *urlStr = [[IMFileHelper shareInstance] getPathWithName:title];
    NSLog(@"getSavePath file path:%@", urlStr);
    NSURL *url = [NSURL fileURLWithPath:urlStr];
    return url;
}

/**
 *  取得录音文件设置
 *
 *  @return 录音设置
 */
- (NSDictionary *) getAudioSetting {
    NSMutableDictionary *dicM = [NSMutableDictionary dictionary];
    //设置录音格式
    [dicM setObject:@(kAudioFormatMPEG4AAC) forKey:AVFormatIDKey];
    //设置录音采样率，8000是电话采样率，对于一般录音已经够了
    [dicM setObject:@(8000) forKey:AVSampleRateKey];
    //设置通道,这里采用单声道
    [dicM setObject:@(2) forKey:AVNumberOfChannelsKey];
//    //每个采样点位数,分为8、16、24、32
//    [dicM setObject:@(8) forKey:AVLinearPCMBitDepthKey];
//    //是否使用浮点数采样
//    [dicM setObject:@(YES) forKey:AVLinearPCMIsFloatKey];
    //....其他设置等
//    return dicM;
    
    NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                          [NSNumber numberWithInt:kAudioFormatMPEG4AAC], AVFormatIDKey,
                                          [NSNumber numberWithFloat:8000], AVSampleRateKey,
                                          [NSNumber numberWithInt: 2], AVNumberOfChannelsKey,nil];
    return recordSetting;
}

/**
 *  获得录音机对象
 *
 *  @return 录音机对象
 */
- (AVAudioRecorder *) audioRecorder {
    if (!_kRecordAudioFile) {
        NSError *error = nil;
        //创建录音格式设置
        NSDictionary *setting = [self getAudioSetting];
        //创建录音机
        _audioRecorder = [[AVAudioRecorder alloc] initWithURL:[self newSavePath] settings:setting error:&error];
        _audioRecorder.delegate = self;
        _audioRecorder.meteringEnabled = YES;//如果要监控声波则必须设置为YES
        if (error) {
            NSLog(@"创建录音机对象时发生错误，错误信息：%@",error.localizedDescription);
            return nil;
        }
    }
    return _audioRecorder;
}

/**
 *  创建播放器
 *
 *  @return 播放器
 */
- (AVAudioPlayer *) audioPlayer {
    NSURL *url = [self getSavePath];
    NSError *error = nil;
    
    _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
//    _audioPlayer.numberOfLoops=0;
    [_audioPlayer prepareToPlay];
    
    if (error) {
        NSLog(@"创建播放器过程中发生错误，错误信息：%@",error.localizedDescription);
        return nil;
    }
    return _audioPlayer;
}

- (AVAudioPlayer *) audioPlayer:(NSURL *) url {
    NSError *error = nil;
    NSData *voiceData = [NSData dataWithContentsOfURL:url];
    _audioPlayer = [[AVAudioPlayer alloc] initWithData:voiceData error:&error];

//    _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    _audioPlayer.delegate = self;
//    _audioPlayer.volume=0.8;
    _audioPlayer.numberOfLoops=-1;
    [_audioPlayer prepareToPlay];
    if (error) {
        NSLog(@"创建播放器过程中发生错误，错误信息：%@",error.localizedDescription);
        return nil;
    }
    return _audioPlayer;
}

///**
// *  录音声波监控定制器
// *
// *  @return 定时器
// */
//-(NSTimer *)timer{
//    if (!_timer) {
//        _timer=[NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(audioPowerChange) userInfo:nil repeats:YES];
//    }
//    return _timer;
//}
//
///**
// *  录音声波状态设置
// */
//-(void)audioPowerChange{
//    [self.audioRecorder updateMeters];//更新测量值
//    float power= [self.audioRecorder averagePowerForChannel:0];//取得第一个通道的音频，注意音频强度范围时-160到0
//    CGFloat progress=(1.0/160.0)*(power+160.0);
//    [self.audioPower setProgress:progress];
//}


#pragma mark - 录音机代理方法
/**
 *  录音完成，录音完成后播放录音
 *
 *  @param recorder 录音机对象
 *  @param flag     是否成功
 */
-(void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag {
//    if (![self.audioPlayer isPlaying]) {
//        [self.audioPlayer play];
//    }
    NSLog(@"录音结果：%d", flag);
}


#pragma mark - audio player delegate
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    NSLog(@"播放结果：%d", flag);
    [_playingCell stopPlayVoice];
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer*)player error:(NSError *)error{
    NSLog(@"播放结果：%@", error);
}

@end
