//
//  AppProfile.m
//  R&B
//
//  Created by hjc on 15/11/30.
//  Copyright © 2015年 hjc. All rights reserved.
//

#import "AppProfile.h"
#import "IMDAO.h"

@implementation AppProfile

static AppProfile *sharedInstance;

+(AppProfile *) shareInstace
{
    static BOOL initialized = NO;
    if (!initialized)
    {
        initialized = YES;        
        sharedInstance = [[AppProfile alloc] init];
        
        sharedInstance.unreadCount = 0;
    }
    
    return sharedInstance;  
}

-(int) getUnreadCount {
    return _unreadCount;
}

-(void) incrUnreadCount:(int) val {
    if (val != 0) {        
        _unreadCount += val;
        [[IMDAO shareInstance] setUnreadCount: _unreadCount];
    }
}

@end
