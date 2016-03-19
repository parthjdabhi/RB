//
//  MainTabBarController.m
//  RB
//
//  Created by hjc on 16/2/23.
//  Copyright © 2016年 hjc. All rights reserved.
//

#import "MPMainTabBarController.h"

#import "RBMessageMainController.h"
#import "RBFriendMainController.h"
#import "MPMovieMainController.h"
#import "RBNotificationContants.h"
#import "AppProfile.h"

@interface MPMainTabBarController ()

@end

@implementation MPMainTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIView *bgView = [[UIView alloc] initWithFrame:self.tabBar.bounds];
    bgView.backgroundColor = [UIColor whiteColor];
    [self.tabBar insertSubview:bgView atIndex:0];
    self.tabBar.opaque = YES;
    
    UINavigationController *n1 = [[UIStoryboard storyboardWithName:@"MPMovieMain" bundle:[NSBundle mainBundle]] instantiateInitialViewController];
    UINavigationController *n2 = [[UIStoryboard storyboardWithName:@"MPDialogMain" bundle:[NSBundle mainBundle]] instantiateInitialViewController];
    UINavigationController *n3 = [[UIStoryboard storyboardWithName:@"MPDiscoverMain" bundle:[NSBundle mainBundle]] instantiateInitialViewController];
    UINavigationController *n4 = [[UIStoryboard storyboardWithName:@"MPMeMain" bundle:[NSBundle mainBundle]] instantiateInitialViewController];
    
    self.viewControllers = @[n1, n2, n3, n4];
    
    for (int i=0; i<self.viewControllers.count; i++) {
        UIViewController *vc = self.viewControllers[i];
        
        switch (i) {
            case 0:
                vc.tabBarItem = [self makeBarTitle:@"影派" imageName:@"tabbarMovie" imagselectedImageName:@"tabbarMovieHL"];
                break;
            case 1:
                vc.tabBarItem = [self makeBarTitle:@"朋友" imageName:@"tabbarFriend" imagselectedImageName:@"tabbarFriendHL"];
                break;
            case 2:
                vc.tabBarItem = [self makeBarTitle:@"发现" imageName:@"tabbarDiscover" imagselectedImageName:@"tabbarDiscoverHL"];
                break;
            case 3:
                vc.tabBarItem = [self makeBarTitle:@"我的" imageName:@"tabbarMe" imagselectedImageName:@"tabbarMeHL"];
                break;
            default:
                break;
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

-(UITabBarItem *) makeBarTitle:(NSString *) title imageName:(NSString *) imageName imagselectedImageName:(NSString *) selectedImageName {
    
    UIImage *image = [[UIImage imageNamed:imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIImage *selectedImage = [[UIImage imageNamed:selectedImageName] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    return [[UITabBarItem alloc] initWithTitle:title image:image selectedImage:selectedImage];
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
