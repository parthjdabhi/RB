//
//  Message.h
//  ByteBuffer
//
//  Created by hjc on 14-7-22.
//  Copyright (c) 2014年 hjc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Stanza.h"
#import "ByteBuffer.h"

@interface Message : Stanza

@property(nonatomic) NSString* _id;
@property(nonatomic, assign) int32_t from;
@property(nonatomic, assign) int32_t to;
@property(nonatomic, assign) int32_t target;
@property Byte messageType;
@property(nonatomic, assign) int64_t stamp;
@property(nonatomic) NSString* messageBody;
@property(nonatomic, assign) int32_t contentType;
@property(nonatomic) NSString* messageContent;

-(id) initWithFrom:(int32_t) from
                to:(int32_t) to
            target:(int32_t) target
              type:(Byte) messageType
             stamp:(int64_t) stamp
       contentType:(int32_t) contentType
    messageContent:(NSString *) messageContent;


-(id) initWithId:(NSString *) _id
            from:(int32_t) from
              to:(int32_t) to
          target:(int32_t) target
            type:(Byte) messageType
           stamp:(int64_t) stamp
     contentType:(int32_t) contentType
  messageContent:(NSString *) messageContent;

-(BOOL) parseMessageBody;
@end