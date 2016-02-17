//
//  MMessage.m
//  RB
//
//  Created by hjc on 16/2/9.
//  Copyright © 2016年 hjc. All rights reserved.
//

#import "MMessage.h"

@implementation MMessage

-(void) setRawContent:(NSString *)rawContent {
    _rawContent = [rawContent copy];
    
    const char *utf8 = [rawContent UTF8String];
    if (utf8 == nil) return;
    NSData *data = [NSData dataWithBytes:utf8 length:strlen(utf8)];
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
    
    _contentType = [[dict objectForKey:@"type"] intValue];
    if (_contentType == MESSAGE_CONTENT_TEXT) {
        _text = [dict objectForKey:@"text"];
    } else if (_contentType == MESSAGE_CONTENT_AUDIO) {
        _audioUrl = [dict objectForKey:@"url"];
        _duration = [[dict objectForKey:@"duration"] intValue];
    } else if (_contentType == MESSAGE_CONTENT_IMAGE) {
        _imageUrl = [dict objectForKey:@"url"];
        _thumbUrl = [dict objectForKey:@"thumb"];
    }
    
}

-(void) packRawContent {
    NSDictionary *dict = nil;
    if (_contentType == MESSAGE_CONTENT_TEXT) {
        dict = @{@"type":[@(_contentType) stringValue], @"text":_text};
    } else if (_contentType == MESSAGE_CONTENT_AUDIO) {
        dict = @{@"type":[@(_contentType) stringValue], @"url":_audioUrl, @"duration":[@(_duration) stringValue]};
    } else if (_contentType == MESSAGE_CONTENT_IMAGE) {
        dict = @{@"type":[@(_contentType) stringValue], @"url":_imageUrl, @"thumb":_thumbUrl};
    }

    if (dict == nil) {
        return;
    }
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&error];
    
    if (error) {
        return;
    }
    
    NSString *rawContent = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    _rawContent = rawContent;
}

@end
