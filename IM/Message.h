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

@property NSString* _id;
@property unsigned int from;
@property unsigned int to;
@property unsigned int target;
@property Byte messageType;
@property long long stamp;
@property NSString* messageBody;
@property unsigned int contentType;
@property NSString* messageContent;

-(id) initWithFrom:(unsigned int) from
                to:(unsigned int) to
            target:(unsigned int) target
              type:(Byte) messageType
             stamp:(long long) stamp
       contentType:(unsigned int) contentType
    messageContent:(NSString *) messageContent;


-(id) initWithId:(NSString *) _id
            from:(unsigned int) from
              to:(unsigned int) to
          target:(unsigned int) target
            type:(Byte) messageType
           stamp:(long long) stamp
     contentType:(unsigned int) contentType
  messageContent:(NSString *) messageContent;

-(BOOL) parseMessageBody;
@end