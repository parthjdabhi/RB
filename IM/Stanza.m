//
//  Stanza.m
//  ByteBuffer
//
//  Created by hjc on 14-7-14.
//  Copyright (c) 2014年 hjc. All rights reserved.
//

#import "Stanza.h"

@interface Stanza(){
}

@end

@implementation Stanza

-(id) initWithType:(short) type Content:(NSData *) content
{
    _content = content;
    _type = type;
    return self;
}

-(BOOL) is:(NSString *) type
{
    switch (self.type) {
        case 0x0001:
            return [type isEqualToString:@"Auth"];
        case 0x0002:
            return [type isEqualToString:@"AuthResp"];
        case 0x0003:
            return [type isEqualToString:@"Session"];
        case 0x0011:
            return [type isEqualToString:@"Message"];
        case 0x0012:
            return [type isEqualToString:@"Receipt"];
        case 0x0022:
            return [type isEqualToString:@"Presence"];
        case 0x0033:
            return [type isEqualToString:@"Ping"];
        case 0x0034:
            return [type isEqualToString:@"Conflict"];
        case 0x0035:
            return [type isEqualToString:@"Overload"];
        case 0x0041:
            return [type isEqualToString:@"End"];            
        default:
            return false;
    }
}

-(id) initWithStanza:(Stanza *)stanza
{
    return self;
}

-(NSData *) toBuffer
{
    NSMutableData *data = [[NSMutableData alloc] init];
    short length = _content.length;
    short t = NSSwapHostShortToBig(_type);
    short l = NSSwapHostShortToBig(length);
    [data appendBytes:&t length:sizeof(_type)];
    [data appendBytes:&l length:sizeof(length)];
    [data appendData:_content];
    return data;
}

@end