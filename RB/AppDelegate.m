//
//  AppDelegate.m
//  R&B
//
//  Created by hjc on 15/11/27.
//  Copyright © 2015年 hjc. All rights reserved.
//

#import "AppDelegate.h"
#import "FriendListController.h"
#import "MessageListController.h"
#import "MeViewController.h"
#import "LoginController.h"
#import "NetWorkManager.h"
#import "IMDAO.h"
#import "MUser.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
//    if (![User currentUser].uid) {
//        [User currentUser].uid = 104;
//        [User currentUser].accessToken = @"MTAxADEwMQAxNjVCNkQ2QTU5QTJDNDY4QzU5MDdCNDBEREE5RkYzQmUzOWM";
//        [[NetWorkManager sharedInstance] getUserInfoWithId:[User currentUser].uid
//                                                   success:^(NSDictionary *dict) {
//                                                       [User currentUser].uid = [[dict objectForKey:@"uid"] integerValue];
//                                                       [User currentUser].nickname = [dict objectForKey:@"nickname"];
//                                                       [User currentUser].signature = [dict objectForKey:@"signature"];
//                                                       [User currentUser].gender = [[dict objectForKey:@"gender"] integerValue];
//                                                   } fail:^(NSError *error) {
//                                                       
//                                                   }];
//    }
    
    MUser *user = [[IMDAO shareInstance] getLoginUser];
    
    if (user) {        
        FriendListController *flc = [[FriendListController alloc] init];
        MessageListController *mlc = [[MessageListController alloc] init];
        MeViewController *mvc = [[MeViewController alloc] init];

        UINavigationController *n1 = [[UINavigationController alloc] initWithRootViewController:mlc];
        UINavigationController *n2 = [[UINavigationController alloc] initWithRootViewController:flc];
        UINavigationController *n3 = [[UINavigationController alloc] initWithRootViewController:mvc];

        UITabBarController *tabBarController = [[UITabBarController alloc] init];
        tabBarController.viewControllers = @[n1, n2, n3];
        
//        [[UINavigationBar appearance] setBarStyle:UIBarStyleBlack];
//        [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];        
        [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:125.0/255 green:194.0/255 blue:52.0/255 alpha:1]];
        [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
        [[UINavigationBar appearance] setTitleTextAttributes:@{UITextAttributeTextColor : [UIColor whiteColor]}];
        
        self.window.rootViewController = tabBarController;
    } else {
        
        LoginController *loginController = [[LoginController alloc] init];
        self.window.rootViewController = loginController;
    }
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
//    [self saveContext];
}

#pragma mark - Core Data stack
//
//@synthesize managedObjectContext = _managedObjectContext;
//@synthesize managedObjectModel = _managedObjectModel;
//@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
//
//- (NSURL *)applicationDocumentsDirectory {
//    // The directory the application uses to store the Core Data store file. This code uses a directory named "hjc.R_B" in the application's documents directory.
//    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
//}
//
//- (NSManagedObjectModel *)managedObjectModel {
//    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
//    if (_managedObjectModel != nil) {
//        return _managedObjectModel;
//    }
//    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"R_B" withExtension:@"momd"];
//    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
//    return _managedObjectModel;
//}
//
//- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
//    // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it.
//    if (_persistentStoreCoordinator != nil) {
//        return _persistentStoreCoordinator;
//    }
//    
//    // Create the coordinator and store
//    
//    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
//    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"R_B.sqlite"];
//    NSError *error = nil;
//    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
//    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
//        // Report any error we got.
//        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
//        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
//        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
//        dict[NSUnderlyingErrorKey] = error;
//        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
//        // Replace this with code to handle the error appropriately.
//        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
//        abort();
//    }
//    
//    return _persistentStoreCoordinator;
//}
//
//
//- (NSManagedObjectContext *)managedObjectContext {
//    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
//    if (_managedObjectContext != nil) {
//        return _managedObjectContext;
//    }
//    
//    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
//    if (!coordinator) {
//        return nil;
//    }
//    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
//    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
//    return _managedObjectContext;
//}

#pragma mark - Core Data Saving support

//- (void)saveContext {
//    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
//    if (managedObjectContext != nil) {
//        NSError *error = nil;
//        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
//            // Replace this implementation with code to handle the error appropriately.
//            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
//            abort();
//        }
//    }
//}

@end
