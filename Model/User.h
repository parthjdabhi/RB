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
@property NSString *accessToken;

+(User *) currentUser;

@end
