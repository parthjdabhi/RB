//
//  MainTabBarController.m
//  RB
//
//  Created by hjc on 16/2/23.
//  Copyright © 2016年 hjc. All rights reserved.
//

#import "MainTabBarController.h"

#import "RBMessageMainController.h"
#import "RBFriendMainController.h"
#import "MeViewController.h"
#import "RBNotificationContants.h"
#import "AppProfile.h"

@interface MainTabBarController ()

@end

@implementation MainTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];

//    MeViewController *mvc = [[MeViewController alloc] init];
    
    UINavigationController *n1 = [[UIStoryboard storyboardWithName:@"RBMessageMain" bundle:[NSBundle mainBundle]] instantiateInitialViewController];
    UINavigationController *n2 = [[UIStoryboard storyboardWithName:@"RBFriendMain" bundle:[NSBundle mainBundle]] instantiateInitialViewController];
//    UINavigationController *n3 = [[UINavigationController alloc] initWithRootViewController:mvc];

//    UINavigationController *n3 = [[UIStoryboard storyboardWithName:@"RBPostMain" bundle:[NSBundle mainBundle]] instantiateInitialViewController];
    
    self.viewControllers = @[n1, n2];
    
    for (int i=0; i<self.viewControllers.count; i++) {
        UIViewController *vc = self.viewControllers[i];
        
        if (i == 0) {
            vc.tabBarItem.title = @"消息";
            vc.tabBarItem.image = [UIImage imageNamed:@"tabbarMessage"];
        } else if (i == 1) {
            vc.tabBarItem.title = @"好友";
            vc.tabBarItem.image = [UIImage imageNamed:@"tabbarContact"];
        }
    }

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveBadgeValueChangeNotification:) name:BadgeValueChangeNotification object:nil];
    
    [self setBadgeValueWithIndex:0 value:[[AppProfile instance] getMsgUnreadCount]];
}

-(void)viewDidAppear:(BOOL)animated {
    // get a frame calculation ready
//    CGFloat height = self.tabBar.frame.size.height;
//    CGFloat offsetY = height;
//    
//    // zero duration means no animation
//    CGFloat duration = 1;
    
//    [self.tabBar addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];
    
//    [UIView animateWithDuration:duration animations:^{
//        self.tabBar.frame = CGRectOffset(self.tabBar.frame, 0, offsetY);
//    } completion:^(BOOL finished) {
//        [UIView animateWithDuration:duration animations:^{
//            self.tabBar.frame = CGRectOffset(self.tabBar.frame, 0, -offsetY);
//        } completion:nil];
//    }];
    
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"frame"]) {
        NSLog(@"%@", NSStringFromCGRect(self.tabBar.frame));
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) receiveBadgeValueChangeNotification:(NSNotification *)aNotification {
    NSInteger index = [[aNotification.userInfo objectForKey:@"index"] integerValue];
    NSInteger value = [[aNotification.userInfo objectForKey:@"value"] integerValue];
    [self setBadgeValueWithIndex:index value:value];
}

-(void) setBadgeValueWithIndex:(NSInteger) index value:(NSInteger) badgeValue{
    dispatch_async(dispatch_get_main_queue(), ^{
        UITabBarItem *tabBarItem = self.viewControllers[index].tabBarItem;
        
        if (badgeValue > 0) {
            tabBarItem.badgeValue = @(badgeValue).stringValue;
            
        } else {
            tabBarItem.badgeValue = nil;
        }
    });
}
@end
