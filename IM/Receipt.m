//
//  Receipt.m
//  ByteBuffer
//
//  Created by hjc on 15-3-27.
//  Copyright (c) 2015年 hjc. All rights reserved.
//

#import "Receipt.h"
#import "ByteBuffer.h"

@implementation Receipt

-(id) initWithId:(NSString*) _id
{
    self.type = 0x0012;
    __id = _id;
    self.content = [[[[ByteBuffer alloc] init] string:_id] pack];
    return self;
}


-(id) initWithStanza:(Stanza *) stanza
{
    NSArray *valueArray = [[[ByteBuffer alloc] initWithContent:stanza.content typeArray:[NSArray arrayWithObjects:@"string",nil]] unpack];
    self._id = (NSString *)[valueArray objectAtIndex:0];
    return self;
}

@end
