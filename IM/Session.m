//
//  Session.m
//  ByteBuffer
//
//  Created by hjc on 14-7-16.
//  Copyright (c) 2014年 hjc. All rights reserved.
//

#import "Session.h"
#import "ByteBuffer.h"

@implementation Session

-(id) initWithStep:(Byte) step stamp:(unsigned long long) stamp
{
    self.type = 0x0003;
    _step = step;
    _stamp = stamp;
    self.content = [[[[[ByteBuffer alloc] init] byte:step] int64:stamp] pack];
    return self;
}

-(id) initWithStanza:(Stanza *) stanza
{
    NSArray *valueArray = [[[ByteBuffer alloc] initWithContent:stanza.content typeArray:[NSArray arrayWithObjects:@"byte", @"long",nil]] unpack];
    NSData *byteVal = [valueArray objectAtIndex:0];
    [byteVal getBytes:&_step length:1];    
    NSNumber *stamp = [valueArray objectAtIndex:1];
    _stamp = [stamp doubleValue];
    return self;
}

@end
