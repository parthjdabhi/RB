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

//@property(nonatomic) NSInteger uid;
@property(nonatomic) ConnectionConfig *config;
@property(nonatomic, readonly) Connection *connection;

+(IMClient *) instance;

-(void) connect;
-(void) connectWithUid:(NSInteger) uid accessToken:(NSString *) accessToken;

-(void) sendMessageToUid:(NSInteger) uid content:(NSString *) content;
-(void) sendMessageToGid:(NSInteger) gid content:(NSString *) content;

-(void) sendPictureToUid:(NSInteger) uid
                   image:(UIImage *)image
                 success:(void (^)(NSString *url, NSString *thumb))success
                    fail:(void (^)(NSError *error))fail;
-(void) sendPictureToGid:(NSInteger) gid
                   image:(UIImage *)image
                 success:(void (^)(NSString *url, NSString *thumb))success
                    fail:(void (^)(NSError *error))fail;

-(void) sendVoiceToUid:(NSInteger) uid
                   url:(NSString *) path
              duration:(int) duration
               success:(void (^)(NSString *url))success
                  fail:(void (^)(NSError *error))fail;
-(void) sendVoiceToGid:(NSInteger) gid
                  url:(NSString *) path
              duration:(int) duration
               success:(void (^)(NSString *url))success
                  fail:(void (^)(NSError *error))fail;
@end
