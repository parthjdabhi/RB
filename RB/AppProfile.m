//
//  AppProfile.m
//  R&B
//
//  Created by hjc on 15/11/30.
//  Copyright © 2015年 hjc. All rights reserved.
//

#import "AppProfile.h"
#import "IMDAO.h"

@implementation AppProfile

static AppProfile *sharedInstance;

+(AppProfile *) instance
{
    static BOOL initialized = NO;
    if (!initialized)
    {
        initialized = YES;        
        sharedInstance = [[AppProfile alloc] init];
        
        sharedInstance.msgUnreadCount = [[IMDAO shareInstance] getMsgUnreadCount];
        sharedInstance.noticeUnreadCount = [[IMDAO shareInstance] getNoticeUnreadCount];
    }
    
    return sharedInstance;  
}

-(NSInteger) getMsgUnreadCount {
    return _msgUnreadCount;
}

-(void) incrMsgUnreadCount:(NSInteger) val {
    if (val != 0) {        
        _msgUnreadCount += val;
        [[IMDAO shareInstance] setMsgUnreadCount: _msgUnreadCount];
//        [[NSNotificationCenter defaultCenter] postNotificationName:UpdateMsgCountNotification object:nil];
    }
}

-(NSInteger) getNoticeUnreadCount {
    return _noticeUnreadCount;
}

-(void) incrNoticeUnreadCount:(NSInteger) val {
    if (val != 0) {
        _noticeUnreadCount += val;
        [[IMDAO shareInstance] setNoticeUnreadCount: _noticeUnreadCount];
//        [[NSNotificationCenter defaultCenter] postNotificationName:UpdateNoticeCountNotification object:nil];
    }
}

@end
