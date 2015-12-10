//
//  AuthResp.h
//  ByteBuffer
//
//  Created by hjc on 14-7-16.
//  Copyright (c) 2014年 hjc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Stanza.h"

@interface AuthResp : Stanza

@property Byte code;

-(id) initWithStanza:(Stanza *) stanza;

@end
