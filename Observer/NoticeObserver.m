//
//  NoticeObserver.m
//  RB
//
//  Created by hjc on 15/12/18.
//  Copyright © 2015年 hjc. All rights reserved.
//

#import "NoticeObserver.h"

#import "IMNotificationConstants.h"
#import "IMDAO.h"
#import "NetWorkManager.h"
#import "AppProfile.h"

@implementation NoticeObserver

static NoticeObserver *sharedInstance;

+(NoticeObserver *) instance
{
    static BOOL initialized = NO;
    if (!initialized)
    {
        initialized = YES;
        sharedInstance = [[NoticeObserver alloc] init];
    }
    
    return sharedInstance;
}

-(instancetype) init {
    self = [super init];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(receiveNotification:) name:ReceiveNoticeNotification object:nil];
    return self;
}

-(void)receiveNotification:(NSNotification *) aNotification {
    Message *msg = (Message *)[aNotification object];
    IMNotification *notice = [IMNotification initWithMessage:msg];
    [notice parseMessageBody];

    switch (notice.contentType) {
        case 0:
            break;
        case 1:
            [self sayHello:notice];
            break;
        case 2:
            [self becomeFriend:notice];
            break;
        case 3:
            [self breakFriendship:notice];
            break;
        default:
            break;
    }
}

// 打招呼，请求加好友
// 新的好友增加记录
-(void) sayHello:(IMNotification *) notice {
    int uid = notice.uid;
    
    MUser *user = [[IMDAO shareInstance] getUserWithUid:uid];
    if (user) {
        user.isFriend = NO;
        user.comment = notice.messageContent;
        [[IMDAO shareInstance] saveMakeFriendRecord:user];
        
        [[AppProfile instance] incrNoticeUnreadCount:1];
    } else {
        [[NetWorkManager sharedInstance] getUserInfoWithId:uid
                                                   success:^(NSDictionary *dict) {
                                                       MUser *user = [[MUser alloc] init];
                                                       user.uid = [[dict objectForKey:@"uid"] integerValue];
                                                       user.nickname = [dict objectForKey:@"nickname"];
                                                       user.signature = [dict objectForKey:@"signature"];
                                                       user.gender = [[dict objectForKey:@"gender"] integerValue];
                                                       user.avatarUrl = [dict objectForKey:@"avatar_url"];
                                                       user.avatarThumbUrl = [dict objectForKey:@"avatar_thumb"];
                                                       [[IMDAO shareInstance] saveUser:user];
                                                       
                                                       user.isFriend = NO;
                                                       user.comment = notice.messageContent;
                                                       [[IMDAO shareInstance] saveMakeFriendRecord:user];
                                                       
                                                       [[AppProfile instance] incrNoticeUnreadCount:1];
                                                   }
                                                      fail:^(NSError *error) {
                                                          
                                                      }];
    }
}

// 同意加好友
// 好友表增加记录，生成会话
-(void)becomeFriend:(IMNotification *) notice {
    int32_t uid = notice.uid;
    
    MUser *u = [[IMDAO shareInstance] getUserWithUid:uid];
    MFriend *f = [[MFriend alloc] init];
    f.uid = uid;
    f.nickname = u.nickname;
    [[IMDAO shareInstance] saveFriend:f];
    
    NSString *text = [NSString stringWithFormat:@"%@ 通过了你的好友请求，你们可以聊天了", u.nickname];
    IMNotification *n = [[IMNotification alloc] initWithFrom:uid to:@([MUser currentUser].uid).intValue target:0 type:3 stamp:[[NSDate date] timeIntervalSince1970] * 1000 contentType:2 messageContent:text uid:uid];
    [[IMDAO shareInstance] saveRecvNotification:n];
    [[AppProfile instance] incrMsgUnreadCount:1];
}

// 删除好友
// 好友表记录删除，相关会话删除
-(void)breakFriendship:(IMNotification *) notice {
    int uid = notice.uid;
    [[IMDAO shareInstance] delFriendWithId:uid];
    [[IMDAO shareInstance] deleteDialogWithId:uid];
    [[IMDAO shareInstance] delMakeFriendRecordWithId:uid];
    
    int unreadCount = [[IMDAO shareInstance] getUnreadCountWithUid:uid];
    [[AppProfile instance] incrMsgUnreadCount:-unreadCount];
}


@end
