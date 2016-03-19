//
//  DialogDetailController.m
//  RB
//
//  Created by hjc on 16/1/22.
//  Copyright © 2016年 hjc. All rights reserved.
//

#import "RBDialogDetailController.h"

#import "RBNotificationContants.h"
#import "IMDAO.h"
#import "IMClient.h"
#import "IMFileHelper.h"
#import "IMVoiceMediaItem.h"
#import "IMPhotoMediaItem.h"
#import "AppProfile.h"
#import "UIView+Toast.h"

#import "PictureViewController.h"
#import "RBUserInfoController.h"
#import "UserInfoOperationController.h"
#import "MessageListController.h"

#import "UIImage+ResizeMagick.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import "JSQMessage+IM.h"

@interface RBDialogDetailController() <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, strong) NSMutableArray *jsqMsgs;
@property JSQMessagesBubbleImage *outgoingBubbleImageData;
@property JSQMessagesBubbleImage *incomingBubbleImageData;
@property NSDictionary *avatars;

@property NSDictionary *users;

@property IMVoiceMediaItem *playingVoiceMediaItem;
@property(nonatomic) AVAudioPlayer *player;
@property(nonatomic) AVAudioRecorder *recorder;
@property BOOL recordCanceled;
@property (nonatomic, strong) NSString *kRecordAudioFile;

@property (nonatomic, strong) NSMutableArray *imageArray;

@end

@implementation RBDialogDetailController

#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.senderId = [@(self.sender.uid) stringValue];
    self.senderDisplayName = self.sender.nickname;
    
    self.users = [[NSMutableDictionary alloc] init];
    [self.users setValue:self.sender forKey:[@(self.sender.uid) stringValue]];
    if (_dialogType == DIALOG_TYPE_GROUP) {

    } else {
        [self.users setValue:self.target forKey:[@(self.target.uid) stringValue]];
    }
    
    NSArray *messages = nil;
    if (_dialogType == DIALOG_TYPE_GROUP) {
        messages = [[IMDAO shareInstance] getMessageWithGid:_groupId];
    } else {
        messages = [[IMDAO shareInstance] getMessageWithUid:_userId];
    }

    _jsqMsgs = [[NSMutableArray alloc] init];
    for (MMessage *message in messages) {
        JSQMessage *jsqMsg = [self getJSQMessageWith:message];
        if (jsqMsg != nil) {
            [_jsqMsgs addObject:jsqMsg];
        }
    }
  
    _imageArray = [[NSMutableArray alloc] init];
    for (MMessage *message in messages) {
        if (message.contentType == MESSAGE_CONTENT_IMAGE) {
            [_imageArray addObject:message.imageUrl];
        }
    }
    
    JSQMessagesBubbleImageFactory *bubbleFactory = [[JSQMessagesBubbleImageFactory alloc] init];
    self.incomingBubbleImageData =[bubbleFactory incomingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleLightGrayColor]];
    self.outgoingBubbleImageData = [bubbleFactory outgoingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleGreenColor]];
    
    [JSQMessagesCollectionViewCell registerMenuAction:@selector(delete:)];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveMsg:) name:ReceiveMessageNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotice:) name:ReceiveNoticeNotification object:nil];
    
    UINavigationItem *navigationItem = self.navigationItem;
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"消息" style:UIBarButtonItemStyleDone target:self action:@selector(go2MessageListController)];
    navigationItem.leftBarButtonItem = backButton;
    
    UIButton *rightButton = [[UIButton alloc] initWithFrame:CGRectMake(0,0,30,30)];
    [rightButton setImage:[UIImage imageNamed:_dialogType == DIALOG_TYPE_GROUP?@"users":@"user"]
                 forState:UIControlStateNormal];
    [rightButton addTarget:self
                    action:@selector(go2UserInfoOperationController)
          forControlEvents:UIControlEventTouchUpInside];
    navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    
    navigationItem.title = _target.nickname;
    
    [self scrollToBottomAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (_dialogType == DIALOG_TYPE_GROUP) {
        int unreadCount = [[IMDAO shareInstance] getUnreadCountWithGid:_groupId];
        [[AppProfile instance] incrMsgUnreadCount:-unreadCount];
        [[IMDAO shareInstance] clearUnreadCountWithGid:_groupId];
        
    } else {
        int unreadCount = [[IMDAO shareInstance] getUnreadCountWithUid:_userId];
        [[AppProfile instance] incrMsgUnreadCount:-unreadCount];
        [[IMDAO shareInstance] clearUnreadCountWithUid:_userId];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.automaticallyScrollsToMostRecentMessage = NO;
}

- (void)viewWillDisappear:(BOOL)animated
{
    if (_dialogType == DIALOG_TYPE_GROUP) {
        int unreadCount = [[IMDAO shareInstance] getUnreadCountWithGid:_groupId];
        [[AppProfile instance] incrMsgUnreadCount:-unreadCount];
        [[IMDAO shareInstance] clearUnreadCountWithGid:_groupId];
        
    } else {
        int unreadCount = [[IMDAO shareInstance] getUnreadCountWithUid:_userId];
        [[AppProfile instance] incrMsgUnreadCount:-unreadCount];
        [[IMDAO shareInstance] clearUnreadCountWithUid:_userId];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:BadgeValueChangeNotification object:self userInfo:@{@"index":@"0", @"value":@([[AppProfile instance] getMsgUnreadCount])}];
}

//#pragma mark - Actions
- (void)startRecord {
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryRecord error:nil];
    BOOL r = [session setActive:YES error:nil];
    if (!r) {
        NSLog(@"activate audio session fail");
        return;
    }
    NSLog(@"start record...");
    NSURL *outputFileURL = [self newSavePath];
    
    // Define the recorder setting
    NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] init];
    
    [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
    [recordSetting setValue:[NSNumber numberWithFloat:8000] forKey:AVSampleRateKey];
    [recordSetting setValue:[NSNumber numberWithInt:2] forKey:AVNumberOfChannelsKey];
    
    NSError *error = nil;
    self.recorder = [[AVAudioRecorder alloc] initWithURL:outputFileURL settings:recordSetting error:&error];
    self.recorder.delegate = self;
//    self.recorder.meteringEnabled = YES;
    if (![self.recorder prepareToRecord]) {
        NSLog(@"prepare record fail, error:%@", error.localizedDescription);
        return;
    }
    if (![self.recorder record]) {
        NSLog(@"start record fail, error:%@", error.localizedDescription);
        return;
    }
    
    self.recordCanceled = NO;
}

-(void)stopRecord {
    [self.recorder stop];
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    BOOL r = [audioSession setActive:NO error:nil];
    
    if (!r) {
        NSLog(@"deactivate audio session fail");
    }
}

- (void) getPhotoFromLibrary {
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePicker.delegate = self;
    
    [self presentViewController:imagePicker animated:YES completion:nil];
}

- (void) getPhotoFromCamera {
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    } else {
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    
    imagePicker.delegate = self;
    
    [self presentViewController:imagePicker animated:YES completion:nil];
}

- (void)go2UserInfoOperationController {
    UserInfoOperationController *uioc = [[UserInfoOperationController alloc] init];
    uioc.userId = _userId;
    uioc.user = _target;
    uioc.groupId = _groupId;
    
    [self.navigationController pushViewController:uioc animated:YES];
}

- (void)go2MessageListController {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - Collection view delegate

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    JSQMessage *msg = [self.jsqMsgs objectAtIndex:indexPath.item];
    if (msg.isMediaMessage && action == @selector(delete:)) {
        return YES;
    } else if (!msg.isMediaMessage && (action == @selector(copy:) || action == @selector(delete:))) {
        return YES;
    }
    
    return NO;
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    if (action == @selector(copy:)) {
        id<JSQMessageData> messageData = [collectionView.dataSource collectionView:collectionView messageDataForItemAtIndexPath:indexPath];
        [[UIPasteboard generalPasteboard] setString:[messageData text]];
    }
    else if (action == @selector(delete:)) {
        JSQMessage *msg = [self.jsqMsgs objectAtIndex:indexPath.item];
        MMessage *message = [[MMessage alloc] init];
        message.isOutput = TRUE;
        message.type = self.dialogType;
        
        if (self.dialogType == MESSAGE_TYPE_GROUP) {
            message.receiverId = self.groupId;
        
        } else {
            message.receiverId = self.userId;
        }
        
        message.stamp = msg.date.timeIntervalSince1970;
        [[IMDAO shareInstance] deleteMessage:message];
        
        [collectionView.dataSource collectionView:collectionView didDeleteMessageAtIndexPath:indexPath];
        
        [collectionView deleteItemsAtIndexPaths:@[indexPath]];
        [collectionView.collectionViewLayout invalidateLayout];
    }
}

#pragma mark - JSQMessagesViewController method overrides

- (void)didPressSendButton:(UIButton *)button
           withMessageText:(NSString *)text
                  senderId:(NSString *)senderId
         senderDisplayName:(NSString *)senderDisplayName
                      date:(NSDate *)date
{
    [JSQSystemSoundPlayer jsq_playMessageSentSound];
    
    JSQMessage *message = [[JSQMessage alloc] initWithSenderId:senderId
                                             senderDisplayName:senderDisplayName
                                                          date:date
                                                          text:text];
    [self.jsqMsgs addObject:message];
    
    [self finishSendingMessageAnimated:YES];
}

#pragma mark handle notification

-(void) receiveMsg:(NSNotification *)aNotification {
    [JSQSystemSoundPlayer jsq_playMessageReceivedSound];
    
    Message *rawMessage = (Message *)[aNotification object];
    MMessage *message = [[MMessage alloc] init];
    message.senderId = rawMessage.from;
    message.receiverId = rawMessage.to;
    message.isOutput = FALSE;
    message.type = rawMessage.messageType;
    message.rawContent = rawMessage.messageBody;
    message.stamp = rawMessage.stamp / 1000;
    
    if (message.senderId != _userId) {
        return;
    }
    
    JSQMessage *jsqMsg = [self getJSQMessageWith:message];
    
    if (jsqMsg != nil) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.jsqMsgs addObject:jsqMsg];
            [self finishReceivingMessageAnimated:YES];
        });
    }
}

-(void) receiveNotice:(NSNotification *)aNotification {
    Message *msg = (Message *)[aNotification object];
    IMNotification *notice = [IMNotification initWithMessage:msg];
    
//    NSDictionary *dict = nil;
    [notice parseMessageBody];
    
    if ((_userId > 0 && _userId != notice.uid) || (_groupId > 0 && _groupId != notice.gid)) {
        return;
    }
    
//    dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d",notice.messageType], @"category", notice.messageContent, @"content", nil];
//    
//    [self add2ListTailWithDict:dict];
//    
//    if(self.isViewLoaded && self.view.window) {
//        dispatch_sync(dispatch_get_main_queue(), ^{
//            [self refreshMessageList];
//        });
//    }
}

- (JSQMessage *) getJSQMessageWith:(MMessage *) message {
    
    if (message.senderId == 0) {
        return nil;
    }
    
    JSQMessage *jsqMsg = nil;
    NSString *senderId = [@(message.senderId) stringValue];
    MUser *sender = [self.users valueForKey:senderId];
    NSString *senderDisplayName = sender.nickname;
    
    if (message.type == MESSAGE_TYPE_DIALOG || message.type == MESSAGE_TYPE_GROUP) {
        
        if (message.contentType == MESSAGE_CONTENT_AUDIO) {
            NSURL *url = [NSURL URLWithString:message.audioUrl];
            BOOL isUploading = message.status == MESSAGE_STATUS_ATTACH_UNUPLOAD;
            IMVoiceMediaItem *voiceMediaItem = [[IMVoiceMediaItem alloc] initWithFileURL:url
                                                                                duration:message.duration
                                                                             isUploading:isUploading];
            jsqMsg = [[JSQMessage alloc] initWithSenderId:senderId
                                        senderDisplayName:senderDisplayName
                                                     date:[NSDate dateWithTimeIntervalSince1970:message.stamp]
                                                    media:voiceMediaItem];
            
        } else if (message.contentType == MESSAGE_CONTENT_IMAGE) {
            NSURL *url = [NSURL URLWithString:message.thumbUrl];
            IMPhotoMediaItem *photoMediaItem = [[IMPhotoMediaItem alloc] initWithThumbURL:url];
            photoMediaItem.fileURL = [NSURL URLWithString:message.imageUrl];
            jsqMsg = [[JSQMessage alloc] initWithSenderId:senderId
                                        senderDisplayName:senderDisplayName
                                                     date:[NSDate dateWithTimeIntervalSince1970:message.stamp]
                                                    media:photoMediaItem];
//            [photoMediaItem mediaView];
            
        } else if (message.contentType == MESSAGE_CONTENT_TEXT) {
            jsqMsg = [[JSQMessage alloc] initWithSenderId:senderId
                                        senderDisplayName:senderDisplayName
                                                     date:[NSDate dateWithTimeIntervalSince1970:message.stamp]
                                                     text:message.text];
        }
        
    } else if (message.type == MESSAGE_TYPE_NOTICE) {
        jsqMsg = [[JSQMessage alloc] initWithSenderId:senderId
                                    senderDisplayName:senderDisplayName
                                                 date:[NSDate dateWithTimeIntervalSince1970:message.stamp]
                                                 text:message.text];
    }
    
    if (jsqMsg != nil && message.isOutput && message.status == MESSAGE_STATUS_OK) {
        jsqMsg.isSendOut = TRUE;
    }
    
    return jsqMsg;
}

#pragma mark - JSQMessages CollectionView DataSource

- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.jsqMsgs objectAtIndex:indexPath.item];
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didDeleteMessageAtIndexPath:(NSIndexPath *)indexPath
{
    [self.jsqMsgs removeObjectAtIndex:indexPath.item];
}

- (id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *message = [self.jsqMsgs objectAtIndex:indexPath.item];
    
    if ([message.senderId isEqualToString:self.senderId]) {
        return self.outgoingBubbleImageData;
    }
    
    return self.incomingBubbleImageData;
}

- (id<JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *message = [self.jsqMsgs objectAtIndex:indexPath.item];
    
    if (!self.avatars) {
        self.avatars = [[NSMutableDictionary alloc] init];
    }
    
    if (![self.avatars objectForKey:message.senderId]) {
        MUser *user = (MUser *)[self.users objectForKey:message.senderId];
        NSString *avatarUrl = user.avatarUrl;
        
        UIImage *image = nil;
        
//        if (!avatarUrl || [avatarUrl isEqualToString:@""]) {
//            image = [UIImage imageNamed:@"photo.png"];
//            
//        } else {
//            NSString *downloadPath = [[IMFileHelper shareInstance] getPathWithURL:avatarUrl];
//            
//            if (![[NSFileManager defaultManager] fileExistsAtPath:downloadPath]) {
//                [IMFileHelper downloadFile:avatarUrl path:downloadPath];
//            }
//            image = [UIImage imageWithContentsOfFile:downloadPath];
//        }
        
        image = [[SDImageCache sharedImageCache] imageFromMemoryCacheForKey:avatarUrl];
        
        if (image == nil) {
            image = [UIImage imageNamed:@"photo.png"];
        }
        
        JSQMessagesAvatarImage *avatarImage = [JSQMessagesAvatarImageFactory avatarImageWithImage:image
                                                                                         diameter:kJSQMessagesCollectionViewAvatarSizeDefault];
        [self.avatars setValue:avatarImage forKey:message.senderId];
    }
    
    return [self.avatars valueForKey:message.senderId];
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *currentMessage = [self.jsqMsgs objectAtIndex:indexPath.item];
    JSQMessage *previousMessage;
    
    if (indexPath.item - 1 > 0) {
        previousMessage = [self.jsqMsgs objectAtIndex:indexPath.item - 1];
    }
    
    if (previousMessage == nil || [currentMessage.date timeIntervalSince1970] - [previousMessage.date timeIntervalSince1970] > 60 * 3) {

        return [[JSQMessagesTimestampFormatter sharedFormatter] attributedTimestampForDate:currentMessage.date];
    }
    
    return nil;
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *message = [self.jsqMsgs objectAtIndex:indexPath.item];
    
    /**
     *  iOS7-style sender name labels
     */
    if ([message.senderId isEqualToString:self.senderId]) {
        return nil;
    }
    
    if (indexPath.item - 1 > 0) {
        JSQMessage *previousMessage = [self.jsqMsgs objectAtIndex:indexPath.item - 1];
        if ([[previousMessage senderId] isEqualToString:message.senderId]) {
            return nil;
        }
    }
    
    /**
     *  Don't specify attributes to use the defaults.
     */
    return [[NSAttributedString alloc] initWithString:message.senderDisplayName];
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

#pragma mark - UICollectionView DataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.jsqMsgs count];
}

- (UICollectionViewCell *)collectionView:(JSQMessagesCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell *)[super collectionView:collectionView cellForItemAtIndexPath:indexPath];
   
    JSQMessage *msg = [self.jsqMsgs objectAtIndex:indexPath.item];
    
    if (!msg.isMediaMessage) {
        
        if ([msg.senderId isEqualToString:self.senderId]) {
            cell.textView.textColor = [UIColor whiteColor];
        }
        else {
            cell.textView.textColor = [UIColor blackColor];
        }
        
        cell.textView.linkTextAttributes = @{ NSForegroundColorAttributeName : cell.textView.textColor,
                                              NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle | NSUnderlinePatternSolid) };
    } else {
        JSQMediaItem<JSQMessageMediaData> *messageMedia = (JSQMediaItem *)[msg media];
        
        if ([msg.senderId isEqualToString:self.senderId]) {
            messageMedia.appliesMediaViewMaskAsOutgoing = YES;
            
        } else {
            messageMedia.appliesMediaViewMaskAsOutgoing = NO;
        }
        
        if ([messageMedia isKindOfClass:[JSQPhotoMediaItem class]]) {
            cell.mediaView = [messageMedia mediaView]?: [messageMedia mediaPlaceholderView];
            
        } else {
            cell.mediaView = [messageMedia mediaView]?: [messageMedia mediaPlaceholderView];
        }

        NSParameterAssert(cell.mediaView != nil);
    }
    
    return cell;
}


#pragma mark imagepicker delegate

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    [picker dismissViewControllerAnimated:YES completion:nil];

    [JSQSystemSoundPlayer jsq_playMessageSentSound];
    
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    
    MMessage *message = [[MMessage alloc] init];
    message.senderId = self.sender.uid;
    message.receiverId = self.target.uid;
    message.isOutput = TRUE;
    message.type = _dialogType;
    message.contentType = MESSAGE_CONTENT_IMAGE;
    message.status = MESSAGE_STATUS_ATTACH_UNUPLOAD;
    message.stamp = [[NSDate date] timeIntervalSince1970];
    
    NSString *key = [[[NSUUID alloc] init] UUIDString];
    NSString *imagePath = [NSString stringWithFormat:@"%@.image", key];
//    NSString *thumbPath = [NSString stringWithFormat:@"%@.thumb", key];
    
    message.imageUrl = imagePath;
    message.thumbUrl = imagePath;
    [[SDImageCache sharedImageCache] storeImage:image forKey:imagePath];
//    [[SDImageCache sharedImageCache] storeImage:thumbImage forKey:thumbPath];
    [[IMDAO shareInstance] saveMessage:message];
    
    IMPhotoMediaItem *photoMediaItem = [[IMPhotoMediaItem alloc] initWithImage:image isUploading:YES];
    photoMediaItem.fileURL = [NSURL URLWithString:message.imageUrl];
    photoMediaItem.appliesMediaViewMaskAsOutgoing = YES;
    JSQMessage *jsqMessage = [[JSQMessage alloc] initWithSenderId:self.senderId
                                                senderDisplayName:self.senderDisplayName
                                                             date:[NSDate date]
                                                            media:photoMediaItem];
    [self.jsqMsgs addObject:jsqMessage];
    
    [_imageArray addObject:message.imageUrl];
    
    [self finishSendingMessageAnimated:YES];
    
    
    double delayInSeconds = 1.0;
    __block RBDialogDetailController* bself = self;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [photoMediaItem didFinishUpload];
        
        message.status = MESSAGE_STATUS_OK;
        [[IMDAO shareInstance] updateMessage:message];
        
        [bself finishSendingMessageAnimated:YES];
    });
    
//    void (^successBlock)(NSString *, NSString *) = ^(NSString *url, NSString *thumbUrl) {
//        [photoMediaItem didFinishUpload];
//        
//        message.status = MESSAGE_STATUS_OK;
//        [[IMDAO shareInstance] updateMessage:message];
//        
//        [self finishSendingMessageAnimated:YES];
//    };
//    
//    if (_dialogType == DIALOG_TYPE_GROUP) {
//        [[IMClient instance] sendPictureToGid:_groupId
//                                        image:image
//                                      success:successBlock
//                                         fail:^(NSError *error) {
//                                             
//                                         }];
//    } else {
//        [[IMClient instance] sendPictureToUid:_userId
//                                        image:image
//                                      success:successBlock
//                                         fail:^(NSError *error) {
//                                             
//                                         }];
//    }
    
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

#pragma mark - Adjusting cell label heights

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *currentMessage = [self.jsqMsgs objectAtIndex:indexPath.item];
    JSQMessage *previousMessage;
    
    if (indexPath.item - 1 > 0) {
        previousMessage = [self.jsqMsgs objectAtIndex:indexPath.item - 1];
    }
    
    if (previousMessage == nil || [currentMessage.date timeIntervalSince1970] - [previousMessage.date timeIntervalSince1970] > 60 * 3) {
        
        return kJSQMessagesCollectionViewCellLabelHeightDefault;
    }
    
    return 0.0f;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *currentMessage = [self.jsqMsgs objectAtIndex:indexPath.item];
    if ([[currentMessage senderId] isEqualToString:self.senderId]) {
        return 0.0f;
    }
    
    if (indexPath.item - 1 > 0) {
        JSQMessage *previousMessage = [self.jsqMsgs objectAtIndex:indexPath.item - 1];
        
        if ([[previousMessage senderId] isEqualToString:[currentMessage senderId]]) {
            return 0.0f;
        }
    }
    
    return kJSQMessagesCollectionViewCellLabelHeightDefault;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return 0.0f;
}

#pragma mark - Responding to collection view tap events

- (void)collectionView:(JSQMessagesCollectionView *)collectionView
                header:(JSQMessagesLoadEarlierHeaderView *)headerView didTapLoadEarlierMessagesButton:(UIButton *)sender
{
    NSLog(@"Load earlier messages!");
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapAvatarImageView:(UIImageView *)avatarImageView atIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *currentMessage = [self.jsqMsgs objectAtIndex:indexPath.item];
    
    RBUserInfoController *uic = [[UIStoryboard storyboardWithName:@"RBFriendMain" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"RBUserInfoController"];
    uic.uid = [currentMessage.senderId integerValue];
    uic.target = [[IMDAO shareInstance] getUserWithUid:uic.uid];
    
    [self.navigationController pushViewController:uic animated:YES];
    NSLog(@"Tapped avatar!");
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapMessageBubbleAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *currentMessage = [self.jsqMsgs objectAtIndex:indexPath.item];
    
    if ([currentMessage.media isKindOfClass:[IMVoiceMediaItem class]]) {
        IMVoiceMediaItem *voiceMediaItem = (IMVoiceMediaItem *)(currentMessage.media);
        
        if (voiceMediaItem.isPlaying) {
            [voiceMediaItem stopPlay];
            [self stopPlayer];
            
        } else {
            
            if (self.playingVoiceMediaItem) {
                [self.playingVoiceMediaItem stopPlay];
                [self stopPlayer];
            }
            [voiceMediaItem play];
            
            NSString *path = voiceMediaItem.fileURL.absoluteString;
            
            if ([path hasPrefix:@"http"]) {
                NSString *downloadPath = [[IMFileHelper shareInstance] getPathWithURL:path];
            
                if (![[NSFileManager defaultManager] fileExistsAtPath:downloadPath]) {
                    [IMFileHelper downloadFile:path path:downloadPath];
                }
                path = downloadPath;
            }
            [self playVoiceWithUrl:[NSURL URLWithString:path]];
            self.playingVoiceMediaItem = voiceMediaItem;
        }
        
    } else if ([currentMessage.media isKindOfClass:[IMPhotoMediaItem class]]) {
        IMPhotoMediaItem *photoMediaItem = (IMPhotoMediaItem *)(currentMessage.media);
        NSInteger index = [_imageArray indexOfObject:photoMediaItem.fileURL.absoluteString];
        
        NSLog(@"%@", photoMediaItem.fileURL.absoluteString);
        PictureViewController *pvc = [[PictureViewController alloc] initWithImages:_imageArray index:index];
        [self.navigationController pushViewController:pvc animated:YES];
    }
    NSLog(@"Tapped message bubble!");
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapCellAtIndexPath:(NSIndexPath *)indexPath touchLocation:(CGPoint)touchLocation
{
    [super collectionView:collectionView didTapCellAtIndexPath:indexPath touchLocation:touchLocation];
    NSLog(@"Tapped cell at %@!", NSStringFromCGPoint(touchLocation));
}

+ (BOOL) isHeadphone {
    AVAudioSessionRouteDescription* route = [[AVAudioSession sharedInstance] currentRoute];

    for (AVAudioSessionPortDescription* desc in [route outputs]) {
    
        if ([[desc portType] isEqualToString:AVAudioSessionPortHeadphones])
            return YES;
    }
    return NO;
}

//#pragma mark - JSQMessagesComposerTextViewPasteDelegate methods


//- (BOOL)composerTextView:(JSQMessagesComposerTextView *)textView shouldPasteWithSender:(id)sender
//{
//    if ([UIPasteboard generalPasteboard].image) {
//        // If there's an image in the pasteboard, construct a media item with that image and `send` it.
//        JSQPhotoMediaItem *item = [[JSQPhotoMediaItem alloc] initWithImage:[UIPasteboard generalPasteboard].image];
//        JSQMessage *message = [[JSQMessage alloc] initWithSenderId:self.senderId
//                                                 senderDisplayName:self.senderDisplayName
//                                                              date:[NSDate date]
//                                                             media:item];
//        [self.demoData.messages addObject:message];
//        [self finishSendingMessage];
//        return NO;
//    }
//    return YES;
//}

#pragma mark - AVAudioPlayerDelegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    NSLog(@"player finished");
    [self.playingVoiceMediaItem stopPlay];
    self.playingVoiceMediaItem = nil;
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error {
    NSLog(@"player decode error");
    [self.playingVoiceMediaItem stopPlay];
    self.playingVoiceMediaItem = nil;
}

#pragma mark - AVAudioRecorderDelegate
- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag {
    NSLog(@"record finish:%d", flag);
    
    if (!flag) {
        return;
    }
    if (self.recordCanceled) {
        return;
    }
    
    NSString *voicePath = _kRecordAudioFile;
    _kRecordAudioFile = nil;
    AVURLAsset* audioAsset = [AVURLAsset URLAssetWithURL:[self getSavePath:voicePath] options:nil];
    float audioDurationSeconds = CMTimeGetSeconds(audioAsset.duration);
    
    if (audioDurationSeconds < 1) {
        [self.view makeToast:@"录音时间太短了" duration:0.7 position:@"bottom"];
        return;
    }
    
    [JSQSystemSoundPlayer jsq_playMessageSentSound];
    
    IMVoiceMediaItem *voiceMediaItem = [[IMVoiceMediaItem alloc] initWithFileURL:recorder.url
                                                                        duration:audioDurationSeconds
                                                                     isUploading:TRUE];
    voiceMediaItem.appliesMediaViewMaskAsOutgoing = YES;
    JSQMessage *jsqMessage = [[JSQMessage alloc] initWithSenderId:self.senderId
                                                senderDisplayName:self.senderDisplayName
                                                             date:[NSDate date]
                                                            media:voiceMediaItem];
    [self.jsqMsgs addObject:jsqMessage];
    
    [self finishSendingMessageAnimated:YES];
    
    MMessage *message = [[MMessage alloc] init];
    message.senderId = self.sender.uid;
    message.receiverId = self.target.uid;
    message.isOutput = TRUE;
    message.type = _dialogType;
    message.contentType = MESSAGE_CONTENT_AUDIO;
    message.status = MESSAGE_STATUS_ATTACH_UNUPLOAD;
    message.stamp = [[NSDate date] timeIntervalSince1970];
    message.audioUrl = recorder.url.absoluteString;
    message.duration = audioDurationSeconds;
    [[IMDAO shareInstance] saveMessage:message];
    
    void (^successBlock)(NSString *) = ^(NSString *url) {
        [voiceMediaItem didFinishUpload];
        
        message.status = MESSAGE_STATUS_OK;
        [[IMDAO shareInstance] updateMessage:message];
        
        [self finishSendingMessageAnimated:YES];
    };
    
    if (_dialogType == DIALOG_TYPE_GROUP) {
        [[IMClient instance] sendVoiceToUid:_groupId
                                        url:recorder.url.path
                                   duration:audioDurationSeconds
                                    success:successBlock
                                       fail:^(NSError *error) {
                                           
                                       }];
    } else {
        [[IMClient instance] sendVoiceToUid:_userId
                                        url:recorder.url.path
                                   duration:audioDurationSeconds
                                    success:successBlock
                                       fail:^(NSError *error) {
                                           
                                       }];
    }
}

- (void)stopPlayer {
    if (self.player && [self.player isPlaying]) {
        [self.player stop];
    }
}

/**
 *  取得录音文件保存路径
 *
 *  @return 录音文件路径
 */
- (NSURL *) newSavePath {
    NSString *key = [[[NSUUID alloc] init] UUIDString];
    _kRecordAudioFile = [NSString stringWithFormat:@"%ld-%@.aac", (long)self.userId, key];
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

- (void) playVoiceWithUrl:(NSURL *) voiceUrl {
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    
    if (![[self class] isHeadphone]) {
        //打开外放
        [session overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker
                                   error:nil];        
    }

    NSError *error = nil;
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:voiceUrl error:&error];
    
    if (error) {
        NSLog(@"audio play error:%@", error.localizedDescription);
    }
    
    [self.player setDelegate:self];
    [self.player play];
}

#pragma mark - MessageInputRecordDelegate

- (void)recordStart {
    if (self.recorder.recording) {
        return;
    }
    
    [self stopPlayer];
    
    [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
        if (granted) {
            [self startRecord];
        } else {
            [self.view makeToast:@"无法录音,请到设置-隐私-麦克风,允许程序访问"];
        }
    }];
}

- (void)recordCancel {
    NSLog(@"touch cancel");
    
    if (self.recorder.recording) {
        NSLog(@"cancel record...");
        self.recordCanceled = YES;
        [self stopRecord];
    }
}

- (void)recordCancel:(CGFloat)xMove {
    [self recordCancel];
}

-(void)recordEnd {
    if (self.recorder.recording) {
        NSLog(@"stop record...");
        self.recordCanceled = NO;
        [self stopRecord];
    }
}

#pragma mark - EMChatToolbarDelegate

- (void)didSendText:(NSString *)text {
    [JSQSystemSoundPlayer jsq_playMessageSentSound];
    
    JSQMessage *jsqMessage = [[JSQMessage alloc] initWithSenderId:self.senderId
                                             senderDisplayName:self.senderDisplayName
                                                          date:[NSDate date]
                                                          text:text];
    
    [self.jsqMsgs addObject:jsqMessage];
    [self finishSendingMessageAnimated:YES];
    
    MMessage *message = [[MMessage alloc] init];
    message.senderId = self.sender.uid;
    message.receiverId = self.target.uid;
    message.isOutput = TRUE;
    message.type = self.dialogType;
    message.contentType = MESSAGE_CONTENT_TEXT;
//    message.status = MESSAGE_STATUS_UNSEND`;
    message.stamp = [[NSDate date] timeIntervalSince1970];
    message.text = text;
    [[IMDAO shareInstance] saveMessage:message];
    
    if (_dialogType == DIALOG_TYPE_GROUP) {
        [[IMClient instance] sendMessageToGid:_groupId content:text];
        
    } else {
        [[IMClient instance] sendMessageToUid:_userId content:text];
    }
    
    [self randomReceivMessage];

}

-(void) randomReceivMessage {
    NSArray *messageTexts = @[@"hello", @"你长得那么好看说什么都对", @"你长得那么好看说什么都对", @"恩", @"哈哈", @"???", @"???", @"哦", @"都是什么乱挤八糟的", @"在干嘛", @"😊😊", @"😃😃", @"😋😋", @"😳😳", @"😉😮😎😡😬", @"😐😖😆😱😱", @"给我唱首歌吧", @"给我唱首歌吧"];
    
    if (arc4random_uniform(100) > 50) {
        int index = arc4random_uniform(messageTexts.count);
        __block NSString *text = messageTexts[index];
        
        double delayInSeconds = 1;
        __block RBDialogDetailController* bself = self;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){

            Message *message = [[Message alloc] initWithFrom:@(bself.target.uid).intValue to:@(self.sender.uid).intValue target:0 type:1 stamp:[[NSDate date] timeIntervalSince1970]*1000 contentType:1 messageContent:text];
            [[NSNotificationCenter defaultCenter] postNotificationName:ReceiveMessageNotification object:message];
        });

    }
    

}

- (BOOL)_canRecord
{
    __block BOOL bCanRecord = YES;
    
    if ([[[UIDevice currentDevice] systemVersion] compare:@"7.0"] != NSOrderedAscending) {
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        
        if ([audioSession respondsToSelector:@selector(requestRecordPermission:)]) {
            [audioSession performSelector:@selector(requestRecordPermission:) withObject:^(BOOL granted) {
                bCanRecord = granted;
            }];
        }
    }
    
    return bCanRecord;
}

#pragma mark - getter && setter

- (void)setUserId:(NSInteger)userId {

    if (userId > 0) {
        _dialogType = MESSAGE_TYPE_DIALOG;
        _userId = userId;
    }
}

- (void) setGroupId:(NSInteger)groupId {

    if (groupId > 0) {
        _dialogType = MESSAGE_TYPE_GROUP;
        _groupId = groupId;
    }
}

@end
