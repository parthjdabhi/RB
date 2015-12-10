//
//  AppProfile.h
//  R&B
//
//  Created by hjc on 15/11/30.
//  Copyright © 2015年 hjc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppProfile : NSObject

@property int unreadCount;

+(AppProfile *) shareInstace;

-(int) getUnreadCount;
-(void) incrUnreadCount:(int) val;

@end
