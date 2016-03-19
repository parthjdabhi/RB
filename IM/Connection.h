//
//  Connection.h
//  ByteBuffer
//
//  Created by hjc on 14-7-16.
//  Copyright (c) 2014年 hjc. All rights reserved.
//

//#define Connecting 1
//#define Binding 2
//#define Connected 3
//#define Disconnected 4

enum ConnectStatus{
    Connecting,
    Binding,
    Connected,
    Disconnected
};

#import <Foundation/Foundation.h>

#import "IMNotificationConstants.h"
#import "ConnectionConfig.h"
#import "Stanza.h"

#import "GCDAsyncSocket.h"
#import <CocoaLumberjack/CocoaLumberjack.h>

#ifdef DEBUG
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelError;
#endif

@interface Connection : NSObject<GCDAsyncSocketDelegate>

@property BOOL authenticate;
@property enum ConnectStatus status;
@property ConnectionConfig *config;

-(id) initWithConfig:(ConnectionConfig *) config;

-(void) connectWithUid:(NSInteger) uid withAccessToken:(NSString *) accessToken stamp:(long long) stamp;

//-(void) sendMessageWithContent:(NSString *) content;

-(BOOL) isConnected;

-(void) send: (Stanza *) stanza;

-(void) disconnect;

@end
