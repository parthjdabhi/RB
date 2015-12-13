//
//  VoiceMessage.h
//  R&B
//
//  Created by hjc on 15/12/2.
//  Copyright © 2015年 hjc. All rights reserved.
//

#import "Message.h"

@interface VoiceMessage : Message

@property unsigned int duration;
@property NSString* url;

-(instancetype) initWithFrom:(unsigned int) from
                to:(unsigned int) to
            target:(unsigned int) target
              type:(Byte) messageType
             stamp:(long long) stamp
          duration:(unsigned int) duration
              url:(NSString *) url;


-(instancetype) initWithId:(NSString *) _id
            from:(unsigned int) from
              to:(unsigned int) to
          target:(unsigned int) target
            type:(Byte) messageType
           stamp:(long long) stamp
        duration:(unsigned int) duration
            url:(NSString *) url;

+(instancetype) initWithMessage:(Message *) message;

-(void) repack;

@end
