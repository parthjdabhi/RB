//
//  RBMessageObserver.m
//  RB
//
//  Created by hjc on 16/2/24.
//  Copyright © 2016年 hjc. All rights reserved.
//

#import "RBMessageObserver.h"

#import "RBNotificationContants.h"
#import "Message.h"
#import "MMessage.h"
#import "IMDAO.h"
#import "AppProfile.h"

@implementation RBMessageObserver

static RBMessageObserver* sharedInstance;

+(RBMessageObserver *) instance
{
    static BOOL initialized = NO;
    if (!initialized)
    {
        initialized = YES;
        sharedInstance = [[RBMessageObserver alloc] init];
    }
    
    return sharedInstance;
}

-(instancetype) init {
    self = [super init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveMessage:) name:ReceiveMessageNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveMessages:) name:ReceiveMessagesNotification object:nil];
    return self;
}


-(void) receiveMessage:(NSNotification *)aNotification {
    Message *rawMessage = (Message *)[aNotification object];
    
    MMessage *message = [[MMessage alloc] init];
    message.senderId = rawMessage.from;
    message.receiverId = rawMessage.to;
    message.isOutput = FALSE;
    message.type = rawMessage.messageType;
    message.rawContent = rawMessage.messageBody;
    message.stamp = rawMessage.stamp / 1000;
    [[IMDAO shareInstance] saveMessage:message];
    
    [[AppProfile instance] incrMsgUnreadCount:1];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:BadgeValueChangeNotification object:self userInfo:@{@"index":@"0", @"value":@([[AppProfile instance] getMsgUnreadCount])}];
    [[NSNotificationCenter defaultCenter] postNotificationName:ReloadDialogDataNotification object:nil];
}

-(void) receiveMessages:(NSNotification *)aNotification {
    NSArray *messages = (NSArray *)[aNotification object];
    
    for (Message *rawMessage in messages) {
        MMessage *message = [[MMessage alloc] init];
        message.senderId = rawMessage.from;
        message.receiverId = rawMessage.to;
        message.isOutput = FALSE;
        message.type = rawMessage.messageType;
        message.rawContent = rawMessage.messageBody;
        message.stamp = rawMessage.stamp / 1000;
        [[IMDAO shareInstance] saveMessage:message];
    }
    
    [[AppProfile instance] incrMsgUnreadCount:messages.count];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:BadgeValueChangeNotification object:self userInfo:@{@"index":@"0", @"value":@([[AppProfile instance] getMsgUnreadCount])}];
    [[NSNotificationCenter defaultCenter] postNotificationName:ReloadDialogDataNotification object:nil];
}


@end
