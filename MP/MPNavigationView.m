//
//  MPNavigationView.m
//  RB
//
//  Created by hjc on 16/3/10.
//  Copyright © 2016年 hjc. All rights reserved.
//

#define NAVIGATION_MARGIN_LEFT 10
#define NAVIGATION_MARGIN_TOP 6
#define NAVIGATION_CITY_VIEW_WIDTH 100
#define NAVIGATION_CITY_VIEW_HEIGHT 30
#define NAVIGATION_ICON_WIDTH 30
#define NAVIGATION_ICON_MARGIN 10

#import "MPNavigationView.h"

@implementation MPNavigationView

-(instancetype) initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    UIView *cityView = [[UIView alloc] initWithFrame:CGRectMake(NAVIGATION_MARGIN_LEFT, NAVIGATION_MARGIN_TOP, NAVIGATION_CITY_VIEW_WIDTH, NAVIGATION_CITY_VIEW_HEIGHT)];
    UIImageView *cityIconView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, NAVIGATION_ICON_WIDTH, NAVIGATION_ICON_WIDTH)];
    UILabel *cityNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(NAVIGATION_ICON_WIDTH + NAVIGATION_MARGIN_LEFT, 0, NAVIGATION_CITY_VIEW_WIDTH, NAVIGATION_CITY_VIEW_HEIGHT)];
    
    cityNameLabel.text = @"深圳";
    cityNameLabel.textColor = [UIColor whiteColor];
    cityIconView.image = [UIImage imageNamed:@"tabbarLoc"];
    
    [cityView addSubview:cityIconView];
    [cityView addSubview:cityNameLabel];
    [self addSubview:cityView];
    
    UIImageView *friendIconView = [[UIImageView alloc] initWithFrame:CGRectMake(frame.size.width-(NAVIGATION_ICON_WIDTH + NAVIGATION_ICON_MARGIN)*3, NAVIGATION_MARGIN_TOP, NAVIGATION_ICON_WIDTH, NAVIGATION_ICON_WIDTH)];
    friendIconView.image = [UIImage imageNamed:@"navbarFriend"];
    [self addTapGuestureToView:friendIconView withSEL:@selector(iconFriendClick)];
    [self addSubview:friendIconView];
    
    UIImageView *discoverIconView = [[UIImageView alloc] initWithFrame:CGRectMake(frame.size.width-(NAVIGATION_ICON_WIDTH + NAVIGATION_ICON_MARGIN)*2, NAVIGATION_MARGIN_TOP, NAVIGATION_ICON_WIDTH, NAVIGATION_ICON_WIDTH)];
    discoverIconView.image = [UIImage imageNamed:@"navbarDiscover"];
    [self addTapGuestureToView:discoverIconView withSEL:@selector(iconDiscoverClick)];
    [self addSubview:discoverIconView];
    
    UIImageView *addIconView = [[UIImageView alloc] initWithFrame:CGRectMake(frame.size.width-(NAVIGATION_ICON_WIDTH + NAVIGATION_ICON_MARGIN), NAVIGATION_MARGIN_TOP, NAVIGATION_ICON_WIDTH, NAVIGATION_ICON_WIDTH)];
    addIconView.image = [UIImage imageNamed:@"navbarAdd"];
    [self addTapGuestureToView:addIconView withSEL:@selector(iconAddClick)];
    [self addSubview:addIconView];
    
//    UIImageView *rightView = [[UIImageView alloc] initWithFrame:CGRectMake(frame.size.width-130, NAVIGATION_MARGIN_TOP, 130, NAVIGATION_ICON_WIDTH)];
//    rightView.image = [UIImage imageNamed:@"tabbarRight"];
//    [self addSubview:rightView];
    
    return self;
}

-(void) iconFriendClick {
    [self.delegate iconFriendClick];
}

-(void) iconDiscoverClick {
    [self.delegate iconDiscoverClick];
}

-(void) iconAddClick {
    [self.delegate iconAddClick];
}

-(void) addTapGuestureToView:(UIView *) view withSEL:(SEL) sel {
    UITapGestureRecognizer *myTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:sel];
    view.userInteractionEnabled = YES;
    [view addGestureRecognizer:myTapGesture];

}

@end
