//
//  User.h
//  ByteBuffer
//
//  Created by hjc on 14-8-3.
//  Copyright (c) 2014年 hjc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MUser : NSObject

@property(nonatomic) NSInteger uid;
@property(nonatomic) NSString *username;
@property(nonatomic) NSString *nickname;
@property(nonatomic) NSString *displayName;
@property(nonatomic) NSString *avatarUrl;
@property(nonatomic) NSString *avatarThumbUrl;
@property(nonatomic) NSString *accessToken;
@property(nonatomic) NSInteger gender;
@property(nonatomic) NSString *signature;

@property BOOL isFriend;
@property(nonatomic) NSString *comment;
@property int source;

+(MUser *) currentUser;
+(void) setCurrentUser:(MUser *) user;

-(instancetype) initWithId:(NSInteger) uid;


@end
