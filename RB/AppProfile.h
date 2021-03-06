//
//  AppProfile.h
//  R&B
//
//  Created by hjc on 15/11/30.
//  Copyright © 2015年 hjc. All rights reserved.
//

#import <Foundation/Foundation.h>

#define UpdateNoticeCountNotification  @"UpdateNoticeCountNotification"
//#define UpdateMsgCountNotification  @"UpdateMsgCountNotification"

@interface AppProfile : NSObject

@property int msgUnreadCount;
@property int noticeUnreadCount;

+(AppProfile *) instance;

-(NSInteger) getMsgUnreadCount;
-(void) incrMsgUnreadCount:(NSInteger) val;

-(NSInteger) getNoticeUnreadCount;
-(void) incrNoticeUnreadCount:(NSInteger) val;

@end
