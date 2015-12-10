//
//  StreamParser.h
//  ByteBuffer
//
//  Created by hjc on 14-7-15.
//  Copyright (c) 2014年 hjc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Stanza.h"

@interface StreamParser : NSObject

-(id) initWithDelegate:(id) aDelegate delegateQueue:(id) aDelegateQueue;

-(void) parseData:(NSData *) data;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@protocol ParserDelegate
@optional

-(void) parserDidReadStanza:(Stanza *) stanza;

@end
