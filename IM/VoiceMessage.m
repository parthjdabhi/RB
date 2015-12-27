//
//  VoiceMessage.m
//  R&B
//
//  Created by hjc on 15/12/2.
//  Copyright © 2015年 hjc. All rights reserved.
//

#import "VoiceMessage.h"
#import "ByteBuffer.h"

@implementation VoiceMessage

-(instancetype) initWithFrom:(unsigned int) from
                to:(unsigned int) to
            target:(unsigned int) target
              type:(Byte) messageType
             stamp:(long long) stamp
          duration:(unsigned int) duration
              url:(NSString *) url
{
    self.type = 0x0011;
    self._id = @"";
    self.from = from;
    self.to = to;
    self.target = target;
    self.stamp = stamp;
    self.messageType = messageType;
    self.contentType = 2;
    self.duration = duration;
    self.url = url;
    self.messageBody = [self packMessageBody];
    self.content = [[[[[[[[[[ByteBuffer alloc] init] string:@""] int32:from] int32:to] int32:target] byte:messageType] int64:stamp] string:self.messageBody] pack];
    return self;
    
}

-(instancetype) initWithId:(NSString *) _id
            from:(unsigned int) from
              to:(unsigned int) to
          target:(unsigned int) target
            type:(Byte) messageType
           stamp:(long long) stamp
        duration:(unsigned int) duration
            url:(NSString *) url;
{
    self.type = 0x0011;
    self._id = _id;
    self.from = from;
    self.to = to;
    self.target = target;
    self.stamp = stamp;
    self.messageType = messageType;
    self.contentType = 2;
    self.duration = duration;
    self.url = url;
    self.messageBody = [self packMessageBody];
    self.content = [[[[[[[[[[ByteBuffer alloc] init] string:_id] int32:from] int32:to] int32:target] byte:messageType] int64:stamp] string:self.messageBody] pack];
    return self;
}

+(instancetype) initWithMessage:(Message *) m {
    VoiceMessage *vm = [[VoiceMessage alloc] init];
    vm._id = m._id;
    vm.from = m.from;
    vm.to = m.to;
    vm.target = m.target;
    vm.stamp = m.stamp;
    vm.messageType = m.messageType;
    vm.messageBody = m.messageBody;
    vm.contentType = m.contentType;
    [vm parseMessageBody];
    return vm;
}

-(void) repack {
    self.messageBody = [self packMessageBody];
    self.content = [[[[[[[[[[ByteBuffer alloc] init] string:self._id] int32:self.from] int32:self.to] int32:self.target] byte:self.messageType] int64:self.stamp] string:self.messageBody] pack];
}

-(NSString *) packMessageBody {
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                                                    _url, @"url",
                                                    [NSString stringWithFormat:@"%d", _duration], @"duration",
                                                    [NSString stringWithFormat:@"%d", self.contentType], @"type", nil];
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict
                                                       options:NSJSONWritingPrettyPrinted error:&error];
    
    if ([jsonData length] > 0 && error == nil){
        return [[NSString alloc] initWithData:jsonData
                                     encoding:NSUTF8StringEncoding];
    }else{
        return nil;
    }
}

-(BOOL) parseMessageBody {
    NSError *error = nil;
    NSDictionary *contentDict = [NSJSONSerialization JSONObjectWithData:[self.messageBody dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:&error];
    
    if (!error) {
//        self.contentType = [[contentDict objectForKey:@"type"] intValue];
        
        if (self.contentType == 2) {
            _url = (NSString *)[contentDict objectForKey:@"url"];
            _duration = [[contentDict objectForKey:@"duration"] intValue];
        } else {
            return NO;
        }
        
        return YES;
    }
    
    return NO;
    
}

@end
