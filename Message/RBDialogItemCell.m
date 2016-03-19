//
//  DialogItemCell.m
//  R&B
//
//  Created by hjc on 15/11/28.
//  Copyright © 2015年 hjc. All rights reserved.
//

#import "RBDialogItemCell.h"

@interface RBDialogItemCell ()

@end

@implementation RBDialogItemCell

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

        NSMutableParagraphStyle *paragraphStyle = NSMutableParagraphStyle.new;
        paragraphStyle.alignment = NSTextAlignmentCenter;
        _unreadLabel.attributedText = [NSAttributedString.alloc initWithString:@(count).stringValue
                                                          attributes:@{NSParagraphStyleAttributeName:paragraphStyle}];
    } else {
        _unreadLabel.hidden = YES;
    }
}

@end
