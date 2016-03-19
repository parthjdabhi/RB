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
#import "NetWorkManager.h"
#import "IMFileHelper.h"

@interface IMClient (){
    NSMutableArray *msgQueue;
}

@end

@implementation IMClient

static IMClient *sharedInstance;

+(IMClient *) instance
{
    static BOOL initialized = NO;
    
	if (!initialized) {
		initialized = YES;		
		sharedInstance = [[IMClient alloc] init];
	}
    
    return sharedInstance;
}

-(id) init
{
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(updateConnectionStatus:)
                                                name:UpdateConnectionStatusNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(receiveStanza:)
                                                name:ReceiveStanzaNotification object:nil];
//    [[NSNotificationCenter defaultCenter]addObserver:self
//                                            selector:@selector(receiveNotice:)
//                                                name:ReceiveNoticeNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(conflict:)
                                                name:ReceiveConflictNotification object:nil];
    
    msgQueue = [[NSMutableArray alloc] init];
    
    [DDLog addLogger:[DDTTYLogger sharedInstance] withLevel:DDLogLevelInfo];
    
    return self;
}

-(void) connect
{
    if(self.config == nil) {
        DDLogError(@"ERROR:IMClient initial without configuration!");
        return;
    }
    
    if(!self.config.uid || !self.config.token) {
        DDLogError(@"ERROR:IMClient connect without account info!");
        return;
    }
 
    _connection = [[Connection alloc] initWithConfig: self.config];
    [_connection connectWithUid:self.config.uid withAccessToken:self.config.token stamp:0];
}

-(void) connectWithUid:(NSInteger) uid accessToken:(NSString *) accessToken
{
    if(self.config == nil) {
        DDLogError(@"ERROR:initial IMClient without configuration!");
        return;
    }
    
    _connection = [[Connection alloc] initWithConfig: self.config];
    [_connection connectWithUid:uid withAccessToken:accessToken stamp:0];
}

-(void) sendMessageToUid:(NSInteger) uid content:(NSString *) content
{
    if (!_connection.isConnected) {
        return;
    }
    
    Message *message = [[Message alloc] initWithFrom:@(self.config.uid).intValue  to:@(uid).intValue target:0 type:1 stamp:[[NSDate date] timeIntervalSince1970]*1000 contentType:1 messageContent:content];
    [[IMDAO shareInstance] saveSendMessage:message];
    [_connection send:message];
}

-(void) sendMessageToGid:(NSInteger) gid content:(NSString *) content
{
    if (!_connection.isConnected) {
        return;
    }
    
    Message *message = [[Message alloc] initWithFrom:@(self.config.uid).intValue to:@(gid).intValue target:0 type:2 stamp:[[NSDate date] timeIntervalSince1970]*1000 contentType:1 messageContent:content];
    [[IMDAO shareInstance] saveSendMessage:message];
    [_connection send:message];
}

-(void) sendPictureToUid:(NSInteger) uid
                   image:(UIImage *) image
                 success:(void (^)(NSString *url, NSString *thumb))success
                    fail:(void (^)(NSError *))fail {
    if (!_connection.isConnected) {
        return;
    }
    
    void (^successBlock)(NSDictionary *) = ^(NSDictionary *responseObject) {
        NSString *url = [responseObject objectForKey:@"url"];
        NSString *thumbUrl = [responseObject objectForKey:@"thumb"];
        
        PictureMessage *message = [[PictureMessage alloc] initWithFrom:@(self.config.uid).intValue
                                                                    to:@(uid).intValue
                                                                target:0
                                                                  type:1
                                                                 stamp:[[NSDate date] timeIntervalSince1970]*1000
                                                                   url: url
                                                                 thumb:thumbUrl];
        [[IMDAO shareInstance] saveSendMessage:message];
        [_connection send:message];
        
        success(url, thumbUrl);
    };
    
    [[NetWorkManager sharedInstance] uploadWithImage:image
                                                name:@"file"
                                                type:1
                                             success:successBlock
                                                fail:^(NSError *error) {
                                                    fail(error);
                                                }];
};

-(void) sendPictureToGid:(NSInteger) gid
                   image:(UIImage *) image
                 success:(void (^)(NSString *url, NSString *thumb))success
                    fail:(void (^)(NSError *))fail {
    if (!_connection.isConnected) {
        return;
    }
    
    void (^successBlock)(NSDictionary *) = ^(NSDictionary *responseObject) {
        NSString *url = [responseObject objectForKey:@"url"];
        NSString *thumbUrl = [responseObject objectForKey:@"thumb"];
        
        PictureMessage *message = [[PictureMessage alloc] initWithFrom:@(self.config.uid).intValue
                                                                    to:@(gid).intValue
                                                                target:0
                                                                  type:2
                                                                 stamp:[[NSDate date] timeIntervalSince1970]*1000
                                                                   url: url
                                                                 thumb:thumbUrl];
        [[IMDAO shareInstance] saveSendMessage:message];
        [_connection send:message];
        
        success(url, thumbUrl);
    };
    
    [[NetWorkManager sharedInstance] uploadWithImage:image
                                                name:@"file"
                                                type:1
                                             success:successBlock
                                                fail:^(NSError *error) {
                                                    fail(error);
                                                }];
};

-(void) sendVoiceToUid:(NSInteger) uid
                   url:(NSString *) path
              duration:(int) duration
               success:(void (^)(NSString *url))success
                  fail:(void (^)(NSError *error))fail {
    void (^successBlock)(NSDictionary *) = ^(NSDictionary *responseObject) {
        if (!_connection.isConnected) {
            return;
        }
        
        NSString *url = [responseObject objectForKey:@"url"];
        
        VoiceMessage *message = [[VoiceMessage alloc] initWithFrom:@(self.config.uid).intValue
                                                                to:@(uid).intValue
                                                            target:0
                                                              type:1
                                                             stamp:[[NSDate date] timeIntervalSince1970]*1000
                                                          duration: duration
                                                               url: url];
        [[IMDAO shareInstance] saveSendMessage:message];
        [_connection send:message];
        
        success(url);
    };
    [[NetWorkManager sharedInstance] uploadWithPath:path
                                               type:1
                                            success:successBlock
                                               fail:^(NSError *error) {
                                                   fail(error);
                                               }];
}

-(void) sendVoiceToGid:(NSInteger) gid
                  url:(NSString *) path
              duration:(int) duration
               success:(void (^)(NSString *url))success
                  fail:(void (^)(NSError *error))fail {
    if (!_connection.isConnected) {
        return;
    }
    
    void (^successBlock)(NSDictionary *) = ^(NSDictionary *responseObject) {
        NSString *url = [responseObject objectForKey:@"url"];
        
        VoiceMessage *message = [[VoiceMessage alloc] initWithFrom:@(self.config.uid).intValue
                                                                to:@(gid).intValue
                                                            target:0
                                                              type:2
                                                             stamp:[[NSDate date] timeIntervalSince1970]*1000
                                                          duration: duration
                                                               url: url];
        [[IMDAO shareInstance] saveSendMessage:message];
        [_connection send:message];
        
        success(url);
    };
    
    [[NetWorkManager sharedInstance] uploadWithPath:path
                                               type:1
                                            success:successBlock
                                               fail:^(NSError *error) {
                                                   fail(error);
                                               }];
}

#pragma mark handle notice
-(void) updateConnectionStatus:(NSNotification *)aNotifacation
{
    if (_connection.status == Connected && msgQueue.count > 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:ReceiveMessagesNotification object:msgQueue];
        [self persistMsgQueue];
    }
    
}

-(void) receiveStanza:(NSNotification *)aNotification
{
    Message *message = (Message *)[aNotification object];
    
    if (message.messageType <= 2) {
        [self receiveMessage:message];
        [[NSNotificationCenter defaultCenter] postNotificationName:ReceiveMessageNotification object:message];
        
    } else if (message.messageType == 3){
        [self receiveNotice:message];
        [[NSNotificationCenter defaultCenter] postNotificationName:ReceiveNoticeNotification object:message];
    }
}

-(void) receiveMessage:(Message *)message
{
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

-(void) receiveNotice:(Message *)msg
{
    IMNotification *notice = [IMNotification initWithMessage:msg];
    [notice parseMessageBody];
    
    if (_connection.status == Binding) {
        //消息队列缓存
        [msgQueue addObject:notice];
        
    } else if (_connection.status == Connected){
        [[IMDAO shareInstance] saveRecvNotification:notice];
    }
}

-(void) conflict:(NSNotification *)aNotifacation
{
//    [[NSNotificationCenter defaultCenter] postNotificationName:ReceiveConflictNotification object:nil];
}

#pragma database handle

-(void) persistMsgQueue
{
    [[IMDAO shareInstance] saveRecvMessages:msgQueue];
    [msgQueue removeAllObjects];
}

@end
