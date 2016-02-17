//
//  User.h
//  ByteBuffer
//
//  Created by hjc on 14-8-3.
//  Copyright (c) 2014年 hjc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MUser : NSObject

@property NSInteger uid;
@property NSString *username;
@property NSString *nickname;
@property NSString *avatarUrl;
@property NSString *avatarThumbUrl;
@property NSString *accessToken;
@property NSInteger gender;
@property NSString *signature;

@property BOOL isFriend;
@property NSString *comment;
@property int source;

+(MUser *) currentUser;
+(void) setCurrentUser:(MUser *) user;

-(instancetype) initWithId:(NSInteger) uid;


@end
