//
//  NetWorkManager.h
//  RB
//
//  Created by hjc on 15/12/8.
//  Copyright © 2015年 hjc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NetWorkManager : NSObject

+(instancetype) sharedInstance;

-(NSString *) uploadFile:(NSString *) path
                    type:(int) type
                 success:(void (^)(NSDictionary *responseObject))success
                    fail:(void (^)(NSError *error))fail;

-(void) getUserInfoWithId:(int) uid
                  success:(void (^)(NSDictionary *responseObject))success
                     fail:(void (^)(NSError *error))fail;

-(void) getFriendListWithUid:(int) uid
                     success:(void (^)(NSDictionary *responseObject))success
                        fail:(void (^)(NSError *error))fail;

-(void) sayHelloToUid:(int) uid
              content:(NSString *) content
              success:(void (^)(NSDictionary *responseObject))success
                 fail:(void (^)(NSError *error))fail;

-(void) passFriendVerifyToUid:(int) uid
                      success:(void (^)(NSDictionary *responseObject))success
                         fail:(void (^)(NSError *error))fail;

-(void) delFriendWithUid:(int) uid
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

-(void) addGroupMemberWithGid:(int) gid
                         Uids:(NSArray *) uids
                      success:(void (^)(NSDictionary *responseObject))success
                         fail:(void (^)(NSError *error))fail;
@end
