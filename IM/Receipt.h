//
//  Receipt.h
//  ByteBuffer
//
//  Created by hjc on 15-3-27.
//  Copyright (c) 2015年 hjc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Stanza.h"

@interface Receipt : Stanza

@property NSString* _id;

-(id) initWithId:(NSString*) _id;

@end
