//
//  User.h
//  ByteBuffer
//
//  Created by hjc on 14-8-3.
//  Copyright (c) 2014年 hjc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject

@property int uid;
@property NSString *username;
@property NSString *nickname;
@property NSString *avaterUrl;
@property NSString *accessToken;
@property int gender;
@property NSString *signature;

@property BOOL isFriend;
@property NSString *comment;
@property int source;

+(User *) currentUser;
-(instancetype) initWithId:(int) uid;

@end
