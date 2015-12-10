//
//  DialogItemCell.m
//  R&B
//
//  Created by hjc on 15/11/28.
//  Copyright © 2015年 hjc. All rights reserved.
//

#import "DialogItemCell.h"

@interface DialogItemCell ()

@end

@implementation DialogItemCell

-(instancetype) init {
    self = [super init];
    
    _unreadLabel.hidden = YES;
    
    return self;
}

-(void) setUnreadCount:(int) count {
    if (count > 0) {
        _unreadLabel.hidden = NO;
        _unreadLabel.layer.cornerRadius = 10;
        _unreadLabel.layer.masksToBounds = YES;
        _unreadLabel.text = [NSString stringWithFormat:@"%d", count];
    } else {
        _unreadLabel.hidden = YES;
    }
}

@end
