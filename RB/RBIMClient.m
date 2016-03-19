//
//  RBIMClient.m
//  RB
//
//  Created by hjc on 16/3/17.
//  Copyright © 2016年 hjc. All rights reserved.
//

#import "RBIMClient.h"

#import "IMClient.h"
#import "ConnectionConfig.h"
#import "MUser.h"

#import "RBMessageObserver.h"
#import "NoticeObserver.h"

#if TARGET_OS_IPHONE

#define IM_SERVER_IP @"54.88.205.144"

#else

#define IM_SERVER_IP @"192.168.0.121"

#endif


@implementation RBIMClient : NSObject

static RBIMClient *sharedInstance;

+(RBIMClient *) instance {
    static BOOL initialized = NO;
    
    if (!initialized) {
        initialized = YES;
        sharedInstance = [[RBIMClient alloc] init];
    }
    
    return sharedInstance;
}

- (void) connectIM {
    ConnectionConfig *config = [[ConnectionConfig alloc] initWithIp:IM_SERVER_IP port:10101 appVersion:@"golo/5.0"];
    config.ip = IM_SERVER_IP;
    config.port = 10101;
    config.appVersion = @"RB/1.0";
    config.uid = [MUser currentUser].uid;
    config.token = [MUser currentUser].accessToken;
    
    [[IMClient instance] setConfig:config];
    [[IMClient instance] connect];
    
    [NoticeObserver instance];
    [RBMessageObserver instance];
}

@end
