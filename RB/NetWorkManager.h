//
//  NetWorkManager.h
//  RB
//
//  Created by hjc on 15/12/8.
//  Copyright © 2015年 hjc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h> 

@interface NetWorkManager : NSObject

+(instancetype) sharedInstance;

#pragma mark authentication
-(void) loginWithUn:(NSString *) un
                pwd:(NSString *) pwd
            success:(void (^)(NSDictionary *responseObject))success
               fail:(void (^)(NSError *error))fail;

-(void) registerWithUn:(NSString *) un
                   pwd:(NSString *) pwd
              nickname:(NSString *) nickname
               success:(void (^)(NSDictionary *responseObject))success
                  fail:(void (^)(NSError *error))fail;

-(void) checkUnWithUn:(NSString *) un
              success:(void (^)(NSDictionary *responseObject))success
                 fail:(void (^)(NSError *error))fail;

#pragma mark user relationship
-(void) getUserInfoWithId:(NSInteger) uid
                  success:(void (^)(NSDictionary *responseObject))success
                     fail:(void (^)(NSError *error))fail;

-(void) getFriendListWithUid:(NSInteger) uid
                     success:(void (^)(NSDictionary *responseObject))success
                        fail:(void (^)(NSError *error))fail;

-(void) sayHelloToUid:(NSInteger) uid
              content:(NSString *) content
              success:(void (^)(NSDictionary *responseObject))success
                 fail:(void (^)(NSError *error))fail;

-(void) passFriendVerifyToUid:(NSInteger) uid
                      success:(void (^)(NSDictionary *responseObject))success
                         fail:(void (^)(NSError *error))fail;

-(void) delFriendWithUid:(NSInteger) uid
                 success:(void (^)(NSDictionary *responseObject))success
                    fail:(void (^)(NSError *error))fail;

-(void) searchUserWithKeyword:(NSString *) keyword
                      success:(void (^)(NSArray *responseObject))success
                         fail:(void (^)(NSError *error))fail;

-(void) getGroupListSuccess:(void (^)(NSArray *responseObject))success
                       fail:(void (^)(NSError *error))fail;

-(void) createGroupWithUids:(NSArray *) uids
                    success:(void (^)(NSDictionary *responseObject))success
                       fail:(void (^)(NSError *error))fail;

-(void) addGroupMemberWithGid:(NSInteger) gid
                         Uids:(NSArray *) uids
                      success:(void (^)(NSDictionary *responseObject))success
                         fail:(void (^)(NSError *error))fail;

-(void) quitGroupWithGid:(NSInteger) gid
                    success:(void (^)(void))success
                       fail:(void (^)(NSError *error))fail;

-(void) delGroupWithGid:(NSInteger) gid
                 success:(void (^)(void))success
                    fail:(void (^)(NSError *error))fail;

#pragma mark upload file
-(void) uploadAvatarWithImage:(UIImage *) image
                          uid:(NSInteger) uid
                      success:(void (^)(NSDictionary *responseObject))success
                         fail:(void (^)(NSError *error))fail;

-(void) uploadWithImage:(UIImage *) image
                   name:(NSString *) filename
                   type:(int) type
                success:(void (^)(NSDictionary *responseObject))success
                   fail:(void (^)(NSError *error))fail;

-(void) uploadWithPath:(NSString *) path
                   type:(int) type
                success:(void (^)(NSDictionary *responseObject))success
                   fail:(void (^)(NSError *error))fail;


@end
