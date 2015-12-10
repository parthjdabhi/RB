//
//  ByteBuffer.m
//  ByteBuffer
//
//  Created by hjc on 14-6-1.
//  Copyright (c) 2014年 hjc. All rights reserved.
//

#import "ByteBuffer.h"

typedef enum {
    
    Type_Byte=1,         //1
    Type_Short,          //2
    Type_UShort,         //3
    Type_Int32,          //4
    Type_UInt32,         //5
    Type_String,         //6 变长字符串，前两个字节表示长度
    Type_VString,        //7 定长字符串
    Type_Int64,          //8
    Type_Float,          //9
    Type_Double,         //10
    Type_ByteArray       //11
    
} ByteBufferType;

@interface ByteBuffer()
{
    NSMutableData *org_buf;
    NSMutableArray *list;
//    NSInteger *offset;
    
    NSData *_content;
    NSArray *_typeArray;
}
@end

@implementation ByteBuffer

- (id) init
{
    org_buf = [[NSMutableData alloc] init];
    list = [[NSMutableArray alloc] init];
//    offset = 0;
    return self;
}

-(id) initWithContent:(NSData *) content typeArray:(NSArray *) typeArray
{
    _content = content;
    _typeArray = typeArray;
    return self;
}

-(ByteBuffer *) byte:(Byte) val
{
    [org_buf appendBytes:&val length:sizeof(val)];
    return self;
}


-(ByteBuffer *) short:(short) val
{
    [list addObject:[[NSDictionary alloc] initWithObjectsAndKeys:@"short", @"type", val, @"value", 2, @"length", nil]];
    return self;
}

-(ByteBuffer *) ushort:(short) val
{
    [list addObject:[[NSDictionary alloc] initWithObjectsAndKeys:@"ushort", @"type", val, @"value", 2, @"length", nil]];
    return self;
}

-(ByteBuffer *) int32:(int) val
{
    val = NSSwapHostIntToBig(val);
    [org_buf appendBytes:&val length:4];
    return self;
}

-(ByteBuffer *) uint32:(int) val
{
    val = NSSwapHostIntToBig(val);
    [org_buf appendBytes:&val length:4];
    return self;
}

-(ByteBuffer *) string:(NSString *) val
{
    short length = NSSwapHostShortToBig([val lengthOfBytesUsingEncoding:NSUTF8StringEncoding]);
    [org_buf appendBytes:&length length:sizeof(short)];
    [org_buf appendData: [val dataUsingEncoding:NSUTF8StringEncoding]];
    return self;
}

-(ByteBuffer *) int64:(long long) val
{
    val = NSSwapHostDoubleToBig(val).v;
    [org_buf appendBytes:&val length:sizeof(val)];
    return self;
}

-(ByteBuffer *) float:(float) val
{
    [list addObject:[[NSDictionary alloc] initWithObjectsAndKeys:@"float", @"type", val, @"value", 4, @"length", nil]];
    return self;
}

-(ByteBuffer *) double:(double) val
{
    [list addObject:[[NSDictionary alloc] initWithObjectsAndKeys:@"double", @"type", val, @"value", 8, @"length", nil]];
    return self;
}

-(NSData *) pack
{
    return [NSData dataWithData:org_buf];
}

-(NSArray *) unpack
{
    NSMutableArray *data = [[NSMutableArray alloc] init];
    int offset = 0;
    for (NSString *type in _typeArray) {
        if ([type isEqual: @"byte"]) {
            [data addObject:[_content subdataWithRange:NSMakeRange(offset, 1)]];
            offset += 1;
        }
        if ([type isEqualToString:@"short"]) {
            short val;
            [_content getBytes:&val range:NSMakeRange(offset, sizeof(val))];
            [data addObject:[NSNumber numberWithInt:NSSwapHostShortToBig(val)]];
            offset += sizeof(val);
        }
        if ([type isEqualToString:@"int"]) {
            int val;
            [_content getBytes:&val range:NSMakeRange(offset, sizeof(val))];
            [data addObject:[NSNumber numberWithInt:NSSwapHostIntToBig(val)]];
            offset += sizeof(val);
        }
        if ([type isEqualToString:@"long"]) {
            long long val;
            [_content getBytes:&val range:NSMakeRange(offset, sizeof(val))];
            
            NSSwappedDouble d;
            d.v = val;
            [data addObject:[NSNumber numberWithDouble:NSSwapBigDoubleToHost(d)]];
            offset += sizeof(val);
        }
        if ([type isEqualToString:@"string"]) {
            short length;
            [_content getBytes:&length range:NSMakeRange(offset, sizeof(length))];
            length = NSSwapHostShortToBig(length);
            NSString *val = [[NSString alloc] initWithData:[_content subdataWithRange:NSMakeRange(offset + sizeof(length), length)] encoding:NSUTF8StringEncoding];
            [data addObject:val];
            offset += sizeof(short) + length;
        }
    }
    return [NSArray arrayWithArray:data];
}




@end
