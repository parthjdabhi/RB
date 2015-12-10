//
//  Stanza.h
//  ByteBuffer
//
//  Created by hjc on 14-7-14.
//  Copyright (c) 2014年 hjc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Stanza : NSObject

@property NSData *content;
@property short type;

-(id) initWithType:(short) type Content:(NSData *) content;

-(id) initWithStanza:(Stanza *) stanza;

-(BOOL) is:(NSString *) type;

-(NSData *) toBuffer;

@end
