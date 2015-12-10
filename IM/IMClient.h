//
//  IMClient.h
//  ByteBuffer
//
//  Created by hjc on 14-8-3.
//  Copyright (c) 2014年 hjc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Connection.h"


@interface IMClient : NSObject

@property int uid;
@property (nonatomic, readonly) Connection *connection;

+(IMClient *) shareInstace;

+(void) setConfig:(ConnectionConfig *) config;

-(void) connectWithUid:(int) uid accessToken:(NSString *) accessToken;

-(void) sendMessageToUid:(int) uid content:(NSString *) content;

-(void) sendVoiceToUid:(int) uid path:(NSString *) path duration:(int) duration;

-(void) sendPictureToUid:(int) uid path:(NSString *) path;

-(void) sendGroupMessageToGid:(int) gid content:(NSString *) content;

@end
