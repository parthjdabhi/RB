//
//  Connection.m
//  IM 连接，封装协议内容。
//  处理通讯协议封包解包，建立、保持、重建连接，以 NSNotificationCenter 向上抛出新到 Message 和 Conflict 等通讯内容。
//
//  Created by hjc on 14-7-16.
//  Copyright (c) 2014年 hjc. All rights reserved.
//

#import "Connection.h"
#import "Stanza.h"
#import "ByteBuffer.h"
#import "StreamParser.h"
#import "Auth.h"
#import "AuthResp.h"
#import "Session.h"
#import "Message.h"
#import "Receipt.h"
#import "End.h"
#import "Ping.h"

@interface Connection() {
    dispatch_queue_t imQueue;
    GCDAsyncSocket *asyncSocket;
    StreamParser *parser;
    
    NSTimer *keepAliveTimer;
    
    int _uid;
    NSString *_accessToken;
    long long _sessionStamp;
    long long _activeStamp;
    int _connectFailure;
}
@end

@implementation Connection

#pragma mark public function

-(id) initWithConfig:(ConnectionConfig *) config
{
    _authenticate = false;
    _connectFailure = 0;
    _config = config;
    
    imQueue = dispatch_queue_create("imQueue", NULL);
    asyncSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:imQueue];
    parser = [[StreamParser alloc] initWithDelegate:self delegateQueue:imQueue];
    return self;
}

-(void) connectWithUid:(int) uid withAccessToken:(NSString *) accessToken stamp:(long long) stamp
{
    if (uid == 0 || accessToken == nil) {
        DDLogError(@"uid and accessToken cannot be null!");
    }
    
    DDLogInfo(@"开始连接 ip:%@ port:%d, stamp:%lld", _config.ip, _config.port, stamp);
    NSError *err = nil;
    if(![asyncSocket connectToHost:_config.ip onPort:_config.port error:&err]) {
        // If there was an error, it's likely something like "already connected" or "no delegate set"
        DDLogWarn(@"asyncSocket connect: %@", err);
        return;
    }
    
    _uid = uid;
    _accessToken = accessToken;
    _sessionStamp = stamp;
}

-(void) send:(Stanza *) stanza
{
    DDLogVerbose(@"send:%@", [stanza toBuffer]);
    [asyncSocket writeData:[stanza toBuffer] withTimeout:-1 tag:1];
    _activeStamp = [[NSDate date] timeIntervalSince1970];
}

-(void) disconnect
{
    if ([self isConnected]) {
        [self send:[[End alloc] init]];
    }
    [self end];
}

-(BOOL) isConnected
{
    return [asyncSocket isConnected] && _status == Connected;
}

#pragma mark private function

-(void)bind
{
    [self updateStatus:Binding];
//    NSTimeInterval time=[[NSDate date] timeIntervalSince1970]*1000;
//    _sessionStamp = 1234567891234;
    _connectFailure = 0;
    Session *session = [[Session alloc] initWithStep:1 stamp:_sessionStamp];
    [self send:session];
    DDLogInfo(@"接收离线消息");
    [asyncSocket readDataWithTimeout:-1 tag:0];
}

-(void) ping
{
    DDLogDebug(@"心跳探针");
    [self send:[[Ping alloc] init]];
}

-(void) keepAlive
{
    int activeInterval = 250; // 250s
    if (_activeStamp + activeInterval < [[NSDate date] timeIntervalSince1970]) {
        [self ping];
    }
    
    int timeout = 30; // 30s
    if (_activeStamp + activeInterval + timeout < [[NSDate date] timeIntervalSince1970]) {
        // reconnect
        [self disconnect];
        [self connectWithUid:_uid withAccessToken:_accessToken stamp:_sessionStamp];
    }
}

-(void) end
{
    [asyncSocket disconnect];
    if (keepAliveTimer != nil) {
        [keepAliveTimer invalidate];
    }
    [self updateStatus:Disconnected];
    _authenticate = false;
}

-(void) reconnect
{
    [self end];
    _connectFailure++;
    int sleepInterval = [self getSleepInterval];
    DDLogInfo(@"在 %d 秒后重连", sleepInterval);

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(sleepInterval * NSEC_PER_SEC)), imQueue, ^{
        [self connectWithUid:_uid withAccessToken:_accessToken stamp:_sessionStamp];
    });
}

-(int) getSleepInterval
{
    if (_connectFailure < 3) {
        return 1;
    } else if (_connectFailure < 5) {
        return 5;
    } else {
        return 30;
    }
}

-(void) receiveSession:(long long) stamp
{
    [self updateStatus:Connected];
    DDLogInfo(@"已连接 stamp:%lld", stamp);
    keepAliveTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(keepAlive) userInfo:nil repeats:YES];
}

-(void) receiveMessage:(Message *) message
{
    if (message.messageType == 1) {
        [[NSNotificationCenter defaultCenter] postNotificationName:ReceiveMessageNotification object:message];
        _sessionStamp = message.stamp;
        [self send:[[Receipt alloc] initWithId:message._id]];
    } else if (message.messageType == 2) {
        [[NSNotificationCenter defaultCenter] postNotificationName:ReceiveMessageNotification object:message];
        _sessionStamp = message.stamp;
        [self send:[[Receipt alloc] initWithId:message._id]];
    } else if (message.messageType == 3) {
        [[NSNotificationCenter defaultCenter] postNotificationName:ReceiveNoticeNotification object:message];
    }
    
    _activeStamp = [[NSDate date] timeIntervalSince1970];
}

-(void) updateStatus:(enum ConnectStatus) status
{
    _status = status;
    [[NSNotificationCenter defaultCenter] postNotificationName:UpdateConnectionStatusNotification object:[NSNumber numberWithInt:_status]];
}

-(void) receivePing
{
    _activeStamp = [[NSDate date] timeIntervalSince1970];
}

-(void) receiveConflict
{
    [self end];
    [[NSNotificationCenter defaultCenter] postNotificationName:ReceiveConflictNotification object:nil];
    DDLogWarn(@"账号冲突！");
}

-(void) receiveEnd
{
    [self end];
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark AsyncSocket Delegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/**
 * Called when a socket connects and is ready for reading and writing. "host" will be an IP address, not a DNS name.
 **/
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
    DDLogInfo(@"连接中 ip:%@ port:%d", host, port);
    [self updateStatus:Connecting];
    Auth *auth = [[Auth alloc] initWithProtocalVersion:1
                                                   uid:_uid
                                              resource:1
                                                  auth:_accessToken
                                            appVersion:_config.appVersion
                                             osVersion:@"iOS/9.0"];
    //
    //    Auth *auth = [[Auth alloc] initWithProtocalVersion:1
    //                                                   uid:uid
    //                                              resource:1
    //                                                  auth:accessToken
    //                                            appVersion:_config.appVersion
    //                                             osVersion:[NSString stringWithFormat:@"iOS/%@", [[UIDevice currentDevice]systemVersion]]];
    [self send:auth];
    [asyncSocket readDataWithTimeout:-1 tag:0];
}

- (void)socketDidSecure:(GCDAsyncSocket *)sock
{
}

/**
 * Called when a socket has completed reading the requested data. Not called if there is an error.
 **/
- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
//    NSLog(@"read%lu", (unsigned long)[data length]);
    DDLogVerbose(@"receive: %@", data);
    [parser parseData:data];
    if (_authenticate) {
        [asyncSocket readDataWithTimeout:-1 tag:1];
    }
}

/**
 * Called after data with the given tag has been successfully sent.
 **/
- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
//    NSLog(@"write%lu", tag);
}

/**
 * Called when a socket disconnects with or without error.
 **/
- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    DDLogWarn(@"断开连接: %@", err);
    [self reconnect];
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark StreamParser Delegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

-(void) parserDidReadStanza:(Stanza *) stanza
{
    if (!_authenticate) {
        if([stanza is:@"AuthResp"])
        {
            AuthResp *authResp = [[AuthResp alloc] initWithStanza:stanza];
            if (authResp.code == 0) {
                _authenticate = true;
                [self bind];
            } else {
                //login error
            }
        }
    }
    if (_status == Binding) {        
        if([stanza is:@"Session"]) {
            Session *session = [[Session alloc] initWithStanza:stanza];
            if (session.step == 2) {
                [self receiveSession: session.stamp];
            }
        }
    }
    
    if (_authenticate) {
        if([stanza is:@"Message"]) {
            Message *message = [[Message alloc] initWithStanza:stanza];
            [self receiveMessage:message];
        }
        
        if([stanza is:@"Conflict"]) {
            [self receiveConflict];
        }
        
        if([stanza is:@"End"]) {
            [self receiveEnd];
        }
        
        if([stanza is:@"Ping"]) {
            [self receivePing];
        }
    }
}

@end
