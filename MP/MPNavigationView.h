//
//  MPNavigationView.h
//  RB
//
//  Created by hjc on 16/3/10.
//  Copyright © 2016年 hjc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MPNavigationViewDelegate;

@interface MPNavigationView : UIView

@property(nonatomic, strong) id<MPNavigationViewDelegate> delegate;

@end

@protocol MPNavigationViewDelegate

@required

- (void) iconFriendClick;
- (void) iconDiscoverClick;
- (void) iconAddClick;

@end
