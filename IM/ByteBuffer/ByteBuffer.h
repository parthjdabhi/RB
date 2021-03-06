//
//  ByteBuffer.h
//  ByteBuffer
//
//  Created by hjc on 14-6-1.
//  Copyright (c) 2014年 hjc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ByteBuffer : NSObject

- (id) init;

-(id) initWithContent:(NSData *) content typeArray:(NSArray *) typeArray;

-(ByteBuffer *) byte:(Byte) val;


-(ByteBuffer *) short:(int16_t) val;

-(ByteBuffer *) ushort:(int16_t) val;

-(ByteBuffer *) int32:(int32_t) val;

-(ByteBuffer *) uint32:(int32_t) val;

-(ByteBuffer *) string:(NSString *) val;

-(ByteBuffer *) int64:(int64_t) val;

-(ByteBuffer *) float:(float) val;

-(ByteBuffer *) double:(double) val;

-(NSData *) pack;

-(NSArray *) unpack;

@end
