//
//  MPNavigationController.m
//  RB
//
//  Created by hjc on 16/3/10.
//  Copyright © 2016年 hjc. All rights reserved.
//

#import "MPNavigationController.h"

@interface MPNavigationController ()<MPNavigationViewDelegate>

@end

@implementation MPNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];

    if (!self.hideCustomNavView) {
        _navigationView = [[MPNavigationView alloc] initWithFrame:self.navigationBar.frame];
        _navigationView.delegate = self;
        [self.navigationBar addSubview:_navigationView];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    if (self.childViewControllers.count == 1 && !self.hideCustomNavView) {
        _navigationView.hidden = FALSE;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - override
- (void) pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [super pushViewController:viewController animated:animated];
    
    _navigationView.hidden = TRUE;
}

- (UIViewController *) popViewControllerAnimated:(BOOL)animated {
    UIViewController *vc = [super popViewControllerAnimated:animated];
    
    if (self.childViewControllers.count == 1 && !self.hideCustomNavView) {
        _navigationView.hidden = FALSE;
    }
    
    return vc;
}

- (nullable NSArray<__kindof UIViewController *> *)popToRootViewControllerAnimated:(BOOL) animated{
    NSArray<__kindof UIViewController *> *vcs = [super popToRootViewControllerAnimated:animated];
    
    if (self.childViewControllers.count == 1 && !self.hideCustomNavView) {
        _navigationView.hidden = FALSE;
    }
    
    return vcs;
}

- (void) setNavigationBarHidden:(BOOL)navigationBarHidden {
    
}

- (void) setNavigationBarHidden:(BOOL)hidden animated:(BOOL)animated {
    if (hidden) {
        [[UINavigationBar appearance] setTintColor:[UIColor blackColor]];
//        [[UINavigationBar appearance] setTitleTextAttributes:@{UITextAttributeTextColor : [UIColor whiteColor]}];
    } else {
        [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
//        [[UINavigationBar appearance] setTitleTextAttributes:@{UITextAttributeTextColor : [UIColor whiteColor]}];
    }
}

#pragma mark - MPNavigationViewDelegate mothed
- (void) iconFriendClick {
    UIViewController *vc = [[UIStoryboard storyboardWithName:@"MPFriendMain" bundle:[NSBundle mainBundle]] instantiateInitialViewController];
    vc.hidesBottomBarWhenPushed = TRUE;
    [self presentViewController:vc animated:TRUE completion:nil];
}

- (void) iconDiscoverClick {
    
}

- (void) iconAddClick {
    UIViewController *vc = [[UIStoryboard storyboardWithName:@"MPMoviePostAdd" bundle:[NSBundle mainBundle]] instantiateInitialViewController];
    vc.hidesBottomBarWhenPushed = TRUE;
    [self presentViewController:vc animated:TRUE completion:nil];
}

@end
