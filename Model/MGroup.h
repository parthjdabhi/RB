//
//  Group.h
//  RB
//
//  Created by hjc on 15/12/14.
//  Copyright © 2015年 hjc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MUser.h"

@interface MGroup : NSObject

@property NSInteger _id;
@property NSString *name;
@property NSMutableArray<MUser *> *members;
@property NSInteger masterId;
@property NSString *avatarUrl;
@property unsigned long long stamp;

@end
