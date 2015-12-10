//
//  PictureMessage.m
//  R&B
//
//  Created by hjc on 15/12/4.
//  Copyright © 2015年 hjc. All rights reserved.
//

#import "PictureMessage.h"
#import "ByteBuffer.h"

@implementation PictureMessage

-(instancetype) initWithFrom:(unsigned int) from
                          to:(unsigned int) to
                      target:(unsigned int) target
                        type:(Byte) messageType
                       stamp:(long long) stamp
                         url:(NSString *) url
{
    self.type = 0x0011;
    self._id = @"";
    self.from = from;
    self.to = to;
    self.target = target;
    self.stamp = stamp;
    self.messageType = messageType;
    self.contentType = 3;
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
    self.url = url;
    self.messageBody = [self packMessageBody];
    self.content = [[[[[[[[[[ByteBuffer alloc] init] string:_id] int32:from] int32:to] int32:target] byte:messageType] int64:stamp] string:self.messageBody] pack];
    return self;
}

+(instancetype) initWithMessage:(Message *) m {
    PictureMessage *vm = [[PictureMessage alloc] init];
    vm._id = m._id;
    vm.from = m.from;
    vm.to = m.to;
    vm.target = m.target;
    vm.type = m.type;
    vm.stamp = m.stamp;
    vm.messageBody = m.messageBody;
    vm.contentType = m.contentType;
    [vm parseMessageBody];
    return vm;
}

-(NSString *) packMessageBody {
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          _url, @"url",
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
        
        if (self.contentType == 3) {
            _url = (NSString *)[contentDict objectForKey:@"url"];
        } else {
            return NO;
        }
        
        return YES;
    }
    
    return NO;
    
}

@end
