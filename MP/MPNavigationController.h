//
//  MPNavigationController.h
//  RB
//
//  Created by hjc on 16/3/10.
//  Copyright © 2016年 hjc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MPNavigationView.h"

@interface MPNavigationController : UINavigationController

@property MPNavigationView *navigationView;
@property (nonatomic) BOOL hideCustomNavView;

@end
