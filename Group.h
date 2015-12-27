//
//  Group.h
//  RB
//
//  Created by hjc on 15/12/14.
//  Copyright © 2015年 hjc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

@interface Group : NSObject

@property int _id;
@property NSString *name;
@property NSMutableArray<User *> *members;
@property int masterId;
@property NSString *avaterUrl;
@property unsigned long long stamp;

@end
