//
//  Auth.h
//  ByteBuffer
//
//  Created by hjc on 15-3-27.
//  Copyright (c) 2015年 hjc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Stanza.h"

@interface Auth : Stanza

@property Byte protocalVersion;
@property unsigned int uid;
@property Byte resource;
@property NSString* auth;
@property NSString* appVersion;
@property NSString* osVersion;

-(id) initWithProtocalVersion:(Byte) pv
                          uid:(unsigned int) uid
                     resource:(Byte) resource
                         auth:(NSString*) auth
                   appVersion:(NSString*) av
                    osVersion:(NSString*) ov;


@end
