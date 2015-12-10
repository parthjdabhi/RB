//
//  StreamParser.m
//  ByteBuffer
//
//  Created by hjc on 14-7-15.
//  Copyright (c) 2014年 hjc. All rights reserved.
//

#import "StreamParser.h"

@interface StreamParser(){
    
    #if __has_feature(objc_arc_weak)
	__weak id delegate;
    #else
	__unsafe_unretained id delegate;
    #endif
    dispatch_queue_t delegateQueue;
    NSMutableData *byteParsed;
    short _minStanzaLength;
    short _type;
}
@end

@implementation StreamParser

-(id) initWithDelegate:(id) aDelegate delegateQueue:(id) aDelegateQueue
{
    delegate = aDelegate;
    delegateQueue = aDelegateQueue;
    byteParsed = [[NSMutableData alloc] init];
    _minStanzaLength = 4;
    _type = 0;
    return self;
}

-(void) parseData:(NSData *) data
{
    [byteParsed appendBytes:[data bytes] length:[data length]];
    while ([byteParsed length] >= _minStanzaLength) {
        if(_type == 0) {
            [byteParsed getBytes:&_type range:NSMakeRange (0, sizeof(_type))];
            [byteParsed getBytes:&_minStanzaLength range:NSMakeRange (sizeof(_type), sizeof(_minStanzaLength))];
            _type = NSSwapHostShortToBig(_type);
            _minStanzaLength = NSSwapHostShortToBig(_minStanzaLength);
            
            if(_type <= 0) {
                break;
            }
        }
        
        if (_type > 0) {
            if ([byteParsed length] < _minStanzaLength) {
                break;
            }
            
            NSData *content = [NSData alloc];
            short type = _type;
            content = [byteParsed subdataWithRange:NSMakeRange(4, _minStanzaLength)];
            //to do
            if (delegate && [delegate respondsToSelector:@selector(parserDidReadStanza:)]) {
				__strong id theDelegate = delegate;
				
				dispatch_async(delegateQueue, ^{ @autoreleasepool {
					
					[theDelegate parserDidReadStanza:[[Stanza alloc] initWithType:type Content:content]];
				}});
			}

//            NSLog(@"type:%hd, content:%@", _type, content);
            
            if ([byteParsed length] >= 4 + _minStanzaLength) {
                [byteParsed setData:[byteParsed subdataWithRange:NSMakeRange(4 + _minStanzaLength, [byteParsed length] - 4 -_minStanzaLength)]];
            }
            
            _minStanzaLength = 4;
            _type = 0;
        }
    }
    
}

@end
