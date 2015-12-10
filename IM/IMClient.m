//
//  IMClient.m
//  IM 客户端连接，配置获取 Connection
//
//  Created by hjc on 14-8-3.
//  Copyright (c) 2014年 hjc. All rights reserved.
//

#import "IMClient.h"
#import "IMDAO.h"
#import "ConnectionConfig.h"

@interface IMClient (){
    NSMutableArray *msgQueue;
}

@end

@implementation IMClient

static IMClient *sharedInstance;
static ConnectionConfig *config;

+(IMClient *) shareInstace
{
    static BOOL initialized = NO;
	if (!initialized)
	{
		initialized = YES;		
		sharedInstance = [[IMClient alloc] init];
	}
    
    return sharedInstance;
}

+(void) setConfig:(ConnectionConfig *) c
{
    config = c;
}

-(id) init
{
    if(config == nil) {
        NSLog(@"ERROR:initial IMClient without configuration!");
        return nil;
    }
    
    _connection = [[Connection alloc] initWithConfig: config];
    
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(updateConnectionStatus:)
                                                name:UpdateConnectionStatusNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(receiveMessage:)
                                                name:ReceiveMessageNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(receiveNotice:)
                                                name:ReceiveNoticeNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(conflict:)
                                                name:ReceiveConflictNotification object:nil];
    
    msgQueue = [[NSMutableArray alloc] init];
    
    [DDLog addLogger:[DDTTYLogger sharedInstance] withLevel:DDLogLevelInfo];
    
    return self;
}

-(void) connectWithUid:(int) uid accessToken:(NSString *) accessToken
{
    _uid = uid;
    [_connection connectWithUid:uid withAccessToken:accessToken stamp:0];
}

-(void) sendMessageToUid:(int) uid content:(NSString *) content
{
    Message *message = [[Message alloc] initWithFrom:_uid to:uid target:0 type:1 stamp:[[NSDate date] timeIntervalSince1970]*1000 contentType:1 messageContent:content];
    [[IMDAO shareInstance] saveSendMessage:message];
    [_connection send:message];
}

-(void) sendVoiceToUid:(int) uid path:(NSString *) path duration:(int) duration
{
    NSString *url = path;
    // to do
    VoiceMessage *message = [[VoiceMessage alloc] initWithFrom:_uid to:uid target:0 type:1 stamp:[[NSDate date] timeIntervalSince1970]*1000 duration: duration url: url];
    [[IMDAO shareInstance] saveSendMessage:message];
    [_connection send:message];
}

-(void) sendPictureToUid:(int) uid path:(NSString *) path {
    NSString *url = path;
    // to do
    PictureMessage *message = [[PictureMessage alloc] initWithFrom:_uid to:uid target:0 type:1 stamp:[[NSDate date] timeIntervalSince1970]*1000 url: url];
    [[IMDAO shareInstance] saveSendMessage:message];
    [_connection send:message];
}

-(void) sendGroupMessageToGid:(int) gid content:(NSString *) content
{
    Message *message = [[Message alloc] initWithFrom:_uid to:gid target:0 type:2 stamp:[[NSDate date] timeIntervalSince1970]*1000 contentType:1 messageContent:content];
    [_connection send:message];
}

#pragma handle notice
-(void) updateConnectionStatus:(NSNotification *)aNotifacation
{
    if (_connection.status == Connected) {
        [self persistMsgQueue];
    }
    
}

-(void) receiveMessage:(NSNotification *)aNotifacation
{
    Message *message = (Message *)[aNotifacation object];
    [message parseMessageBody];
    if (message.contentType == 2) {
        message = (VoiceMessage *) message;
    } else if (message.contentType == 3) {
        message = (PictureMessage *) message;
    }
    [message parseMessageBody];
    
    if (_connection.status == Binding) {
        //消息队列缓存
        [msgQueue addObject:message];
    } else if (_connection.status == Connected){
        [[IMDAO shareInstance] saveRecvMessage:message];
    }
}

-(void) receiveNotice:(NSNotification *)aNotifacation
{
    // TO DO    
}

-(void) conflict:(NSNotification *)aNotifacation
{
    // TO DO
}

#pragma database handle

-(void) persistMsgQueue
{
    [[IMDAO shareInstance] saveRecvMessages:msgQueue];
    [msgQueue removeAllObjects];
}

@end
