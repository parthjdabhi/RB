//
//  Session.h
//  ByteBuffer
//
//  Created by hjc on 14-7-16.
//  Copyright (c) 2014年 hjc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Stanza.h"

@interface Session : Stanza

@property Byte step;
@property unsigned long long stamp;

-(id) initWithStep:(Byte) byte stamp:(unsigned long long) stamp;

@end
