//
//  User.m
//  ByteBuffer
//
//  Created by hjc on 14-8-3.
//  Copyright (c) 2014年 hjc. All rights reserved.
//

#import "MUser.h"

@implementation MUser

__strong static MUser *_currentUser;

+(MUser *) currentUser
{
    static dispatch_once_t pred = 0;
    
    dispatch_once(&pred, ^{
        _currentUser = [[MUser alloc] init];
    });
    
    return _currentUser;
}

+(void) setCurrentUser:(MUser *) user {
    _currentUser = user;
}

-(instancetype) initWithId:(NSInteger) uid {
    _uid = uid;
    return self;
}

@end
