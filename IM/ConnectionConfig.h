//
//  ConnectionConfig.h
//  ByteBuffer
//
//  Created by hjc on 15-3-30.
//  Copyright (c) 2015年 hjc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ConnectionConfig : NSObject

@property NSString* ip;
@property int port;
@property NSString* appVersion;

-(id) initWithIp:(NSString*) ip
             port:(int) port
       appVersion:(NSString*) appVersion;

@end
