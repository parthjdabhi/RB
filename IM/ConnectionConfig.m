//
//  ConnectionConfig.m
//  ByteBuffer
//
//  Created by hjc on 15-3-30.
//  Copyright (c) 2015年 hjc. All rights reserved.
//

#import "ConnectionConfig.h"

@implementation ConnectionConfig

-(id) initWithIp:(NSString*) ip
             port:(int) port
       appVersion:(NSString*) appVersion
{
    _ip = ip;
    _port = port;
    _appVersion = appVersion;
    return self;
}

@end
