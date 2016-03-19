//
//  Friend.m
//  R&B
//
//  Created by hjc on 15/11/28.
//  Copyright © 2015年 hjc. All rights reserved.
//

#import "MFriend.h"

@implementation MFriend

-(void) setNickname:(NSString *)nickname {
    super.nickname = nickname;
    
    if (!self.commentName) {
        self.displayName = nickname;
    }
}

-(void) setCommentName:(NSString *)commentName {
    _commentName = commentName;
    
    if (commentName) {
        self.displayName = commentName;
    }
}
@end
