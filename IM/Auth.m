//
//  Auth.m
//  ByteBuffer
//
//  Created by hjc on 15-3-27.
//  Copyright (c) 2015年 hjc. All rights reserved.
//

#import "Auth.h"
#import "ByteBuffer.h"

@implementation Auth

-(id) initWithProtocalVersion:(Byte) pv
                          uid:(unsigned int) uid
                     resource:(Byte) resource
                         auth:(NSString*) auth
                   appVersion:(NSString*) av
                    osVersion:(NSString*) ov
{
    self.type = 0x0001;
    _protocalVersion = pv;
    _uid = uid;
    _resource = resource;
    _auth = auth;
    _appVersion = av;
    _osVersion = ov;
    self.content = [[[[[[[[[ByteBuffer alloc] init] byte:pv] int32:uid] byte:resource] string:auth] string:av] string:ov] pack];
    return self;
}

@end
