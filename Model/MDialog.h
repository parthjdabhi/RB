//
//  Dialog.h
//  ByteBuffer
//
//  Created by hjc on 14-8-3.
//  Copyright (c) 2014年 hjc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MDialog : NSObject

@property unsigned int uid;
@property unsigned int type;
@property NSString *name;
@property NSString *avatar;
@property NSString *desc;
@property unsigned long long stamp;
@property unsigned int unreadCount;

@end
