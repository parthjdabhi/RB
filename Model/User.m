//
//  User.m
//  ByteBuffer
//
//  Created by hjc on 14-8-3.
//  Copyright (c) 2014年 hjc. All rights reserved.
//

#import "User.h"

@implementation User

+(User *) currentUser
{
    static dispatch_once_t pred = 0;
    __strong static id _currentUser = nil;
    
    dispatch_once(&pred, ^{
        _currentUser = [[User alloc] init];
    });
    
    return _currentUser;
}

-(instancetype) initWithId:(int) uid {
    _uid = uid;
    return self;
}

@end
