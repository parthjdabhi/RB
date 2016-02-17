//
//  IMNotification.m
//  RB
//
//  Created by hjc on 15/12/17.
//  Copyright © 2015年 hjc. All rights reserved.
//

#import "IMNotification.h"

@implementation IMNotification

-(instancetype) initWithFrom:(unsigned int) from
                          to:(unsigned int) to
                      target:(unsigned int) target
                        type:(Byte) messageType
                       stamp:(long long) stamp
                 contentType:(unsigned int) contentType
              messageContent:(NSString *) messageContent
                         uid:(unsigned int)uid
{
    self.type = 0x0011;
    self._id = @"";
    self.from = from;
    self.to = to;
    self.target = target;
    self.stamp = stamp;
    self.messageType = messageType;
    self.contentType = contentType;
    self.messageContent = messageContent;
    self.uid = uid;
    self.messageBody = [self packMessageBody];
    self.content = [[[[[[[[[[ByteBuffer alloc] init] string:@""] int32:from] int32:to] int32:target] byte:messageType] int64:stamp] string:self.messageBody] pack];
    return self;
    
}

-(instancetype) initWithFrom:(unsigned int) from
                          to:(unsigned int) to
                      target:(unsigned int) target
                        type:(Byte) messageType
                       stamp:(long long) stamp
                 contentType:(unsigned int) contentType
              messageContent:(NSString *) messageContent
                         gid:(unsigned int)gid
{
    self.type = 0x0011;
    self._id = @"";
    self.from = from;
    self.to = to;
    self.target = target;
    self.stamp = stamp;
    self.messageType = messageType;
    self.contentType = contentType;
    self.messageContent = messageContent;
    self.gid = gid;
    self.messageBody = [self packMessageBody];
    self.content = [[[[[[[[[[ByteBuffer alloc] init] string:@""] int32:from] int32:to] int32:target] byte:messageType] int64:stamp] string:self.messageBody] pack];
    return self;
    
}

+(instancetype) initWithMessage:(Message *) m {
    IMNotification *obj = [[IMNotification alloc] init];
    obj._id = m._id;
    obj.from = m.from;
    obj.to = m.to;
    obj.target = m.target;
    obj.stamp = m.stamp;
    obj.messageType = m.messageType;
    obj.messageBody = m.messageBody;
    obj.contentType = m.contentType;
    [obj parseMessageBody];
    return obj;
}

-(NSString *) packMessageBody {
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                          self.messageContent, @"text",
                          [NSString stringWithFormat:@"%d", self.contentType], @"type", nil];
    if (_uid > 0) {
        [dict setObject:[NSString stringWithFormat:@"%d", _uid] forKey:@"uid"];
    }
    if (_gid > 0) {
        [dict setObject:[NSString stringWithFormat:@"%d", _gid] forKey:@"gid"];
    }
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
        
        if (self.contentType >= 10) {
            _gid = [[contentDict objectForKey:@"gid"] integerValue];
        } else {
            _uid = [[contentDict objectForKey:@"uid"] integerValue];
        }
        self.messageContent = [contentDict objectForKey:@"text"];
        
        return YES;
    }
    
    return NO;
    
}

@end
