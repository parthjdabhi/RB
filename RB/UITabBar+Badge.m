//
//  Badge.m
//  R&B
//
//  Created by hjc on 15/11/30.
//  Copyright © 2015年 hjc. All rights reserved.
//

#import "UITabBar+Badge.h"
#define TabBarItemNums 2

@implementation UITabBar (Badge)

- (void) showBadgeOnItemIndex:(int) index {
    [self removeBadgeOnItemIndex:index];
    
    UIView *badgeView = [[UIView alloc] init];
    badgeView.tag = 888 + index;
    badgeView.layer.cornerRadius = 5;
    badgeView.backgroundColor = [UIColor redColor];
    CGRect tabFrame = self.frame;
    
    float percentX = (index + 0.6) / TabBarItemNums;
    CGFloat x= ceilf(percentX * tabFrame.size.width);
    CGFloat y= ceilf(0.1 * tabFrame.size.height);
    badgeView.frame = CGRectMake(x, y, 10, 10);
    [self addSubview:badgeView];
}
- (void) hideBadgeOnItemINdex:(int) index {
    [self removeBadgeOnItemIndex:index];
}

- (void) removeBadgeOnItemIndex:(int) index {
    for (UIView *subView in self.subviews) {
        if (subView.tag == 888 + index) {
            [subView removeFromSuperview];
        }
    }
}

@end
