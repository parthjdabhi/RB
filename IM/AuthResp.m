//
//  AuthResp.m
//  ByteBuffer
//
//  Created by hjc on 14-7-16.
//  Copyright (c) 2014年 hjc. All rights reserved.
//

#import "AuthResp.h"
#import "ByteBuffer.h"

@implementation AuthResp

-(id) initWithStanza:(Stanza *) stanza
{
    NSArray *valueArray = [[[ByteBuffer alloc] initWithContent:stanza.content typeArray:[NSArray arrayWithObjects:@"byte",nil]] unpack];
    NSData *byteVal = [valueArray objectAtIndex:0];
    [byteVal getBytes:&_code length:1];
    return self;
}

@end
