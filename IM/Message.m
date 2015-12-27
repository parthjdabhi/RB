//
//  Message.m
//  ByteBuffer
//
//  Created by hjc on 14-7-22.
//  Copyright (c) 2014年 hjc. All rights reserved.
//

#import "Message.h"

@implementation Message

-(id) initWithFrom:(unsigned int) from
                to:(unsigned int) to
            target:(unsigned int) target
              type:(Byte) messageType
             stamp:(long long) stamp
       contentType:(unsigned int) contentType
    messageContent:(NSString *) messageContent;
{
    self.type = 0x0011;
    __id = @"";
    _from = from;
    _to = to;
    _target = target;
    _stamp = stamp;
    _messageType = messageType;
    _contentType = contentType;
    _messageContent = messageContent;
    _messageBody = [self packMessageBody];
    self.content = [[[[[[[[[[ByteBuffer alloc] init] string:__id] int32:from] int32:to] int32:target] byte:messageType] int64:stamp] string:_messageBody] pack];
    return self;
    
}

-(id) initWithId:(NSString *) _id
            from:(unsigned int) from
              to:(unsigned int) to
          target:(unsigned int) target
            type:(Byte) messageType
           stamp:(long long) stamp
     contentType:(unsigned int) contentType
  messageContent:(NSString *) messageContent;
{
    self.type = 0x0011;
    __id = _id;
    _from = from;
    _to = to;
    _target = target;
    _stamp = stamp;
    _messageType = messageType;
    _contentType = contentType;
    _messageContent = messageContent;
    _messageBody = [self packMessageBody];
    self.content = [[[[[[[[[[ByteBuffer alloc] init] string:_id] int32:from] int32:to] int32:target] byte:messageType] int64:stamp] string:_messageBody] pack];
    return self;
}

-(id) initWithStanza:(Stanza *) stanza
{
    NSArray *valueArray = [[[ByteBuffer alloc] initWithContent:stanza.content
                                                     typeArray:[NSArray arrayWithObjects:@"string", @"int", @"int", @"int", @"byte", @"long", @"string",nil]] unpack];
    int idx = 0;
    self._id = (NSString *)[valueArray objectAtIndex:idx++];
    _from = [[valueArray objectAtIndex:idx++] intValue];
    _to = [[valueArray objectAtIndex:idx++] intValue];
    _target = [[valueArray objectAtIndex:idx++] intValue];
    NSData *byteVal = [valueArray objectAtIndex:idx++];
    [byteVal getBytes:&_messageType length:1];
    NSNumber *stamp = [valueArray objectAtIndex:idx++];
    _stamp = [stamp doubleValue];
    _messageBody = (NSString *)[valueArray objectAtIndex:idx++];
    
    if (![self parseMessageBody]) {
        return nil;
    };
    
    return self;
}

-(NSString *) packMessageBody {
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          _messageContent, @"text",
                          [NSString stringWithFormat:@"%d", _contentType], @"type", nil];
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    
    if ([jsonData length] > 0 && error == nil){
        return [[NSString alloc] initWithData:jsonData
                                     encoding:NSUTF8StringEncoding];
    }else{
        return nil;
    }
}

-(BOOL) parseMessageBody {
    NSError *error = nil;
    NSDictionary *contentDict = [NSJSONSerialization JSONObjectWithData:[_messageBody dataUsingEncoding:NSUTF8StringEncoding]
                                                                options:NSJSONReadingMutableLeaves
                                                                  error:&error];
    
    if (!error) {
        _contentType = [[contentDict objectForKey:@"type"] intValue];

        if (_messageType == 3) {
            _messageContent = (NSString *)[contentDict objectForKey:@"text"];
        } else {            
            if (_contentType == 1) {
                _messageContent = (NSString *)[contentDict objectForKey:@"text"];
            } else {
                _messageContent = _messageBody;
            }
        }
        
        return YES;
    }
    
    return NO;
    
}

@end
