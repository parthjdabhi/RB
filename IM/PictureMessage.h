//
//  PictureMessage.h
//  R&B
//
//  Created by hjc on 15/12/4.
//  Copyright © 2015年 hjc. All rights reserved.
//

#import "Message.h"

@interface PictureMessage : Message

@property NSString* url;
@property NSString* thumb;

-(instancetype) initWithFrom:(unsigned int) from
                          to:(unsigned int) to
                      target:(unsigned int) target
                        type:(Byte) messageType
                       stamp:(long long) stamp
                         url:(NSString *) url
                         thumb:(NSString *) thumb;


-(instancetype) initWithId:(NSString *) _id
                      from:(unsigned int) from
                        to:(unsigned int) to
                    target:(unsigned int) target
                      type:(Byte) messageType
                     stamp:(long long) stamp
                       url:(NSString *) url
                     thumb:(NSString *) thumb;

+(instancetype) initWithMessage:(Message *) message;

-(void) repack;

@end
