//
//  NetWorkManager.m
//  RB
//
//  Created by hjc on 15/12/8.
//  Copyright © 2015年 hjc. All rights reserved.
//

#import "NetWorkManager.h"
#import "AFNetworking.h"
#import "IMFileHelper.h"
#import "MUser.h"

#if TARGET_OS_IPHONE

#define IM_SERVER_HOST @"http://ec2-54-88-205-144.compute-1.amazonaws.com/im"
#define FILE_SERVER_HOST @"http://ec2-54-88-205-144.compute-1.amazonaws.com/im"

#else

#define IM_SERVER_HOST @"http://192.168.0.121/im"
#define FILE_SERVER_HOST @"http://192.168.0.121/im"

#endif

@implementation NetWorkManager

static NetWorkManager *sharedInstance;

+(instancetype) sharedInstance
{
    static BOOL initialized = NO;
    if (!initialized)
    {
        initialized = YES;
        sharedInstance = [[NetWorkManager alloc] init];
    }
    
    return sharedInstance;
}

-(void) loginWithUn:(NSString *) un
                pwd:(NSString *) pwd
            success:(void (^)(NSDictionary *responseObject))success
               fail:(void (^)(NSError *error))fail
{
    NSDictionary *data = @{@"un": un, @"pwd":pwd};
    [self postJSONWithUrl:@"/?action=passport_service.login"
              parameters:data
                 success:^(id responseObject) {
                     if ([[responseObject objectForKey:@"code"] intValue] == 0) {
                         success([responseObject objectForKey:@"data"]);
                     } else {
                         fail([NSError errorWithDomain:@"response data error" code:[[responseObject objectForKey:@"code"] intValue] userInfo:responseObject]);
                     }
                 }
                    fail:^(NSError *error) {
                        fail(error);
                    }];
}

-(void) registerWithUn:(NSString *) un
                   pwd:(NSString *) pwd
              nickname:(NSString *) nickname
               success:(void (^)(NSDictionary *responseObject))success
                  fail:(void (^)(NSError *error))fail
{
    NSDictionary *data = @{@"un": un, @"pwd":pwd, @"nickname":nickname};
    [self postJSONWithUrl:@"/?action=passport_service.register"
               parameters:data
                  success:^(id responseObject) {
                      if ([[responseObject objectForKey:@"code"] intValue] == 0) {
                          success([responseObject objectForKey:@"data"]);
                      } else {
                          fail([NSError errorWithDomain:@"response data error" code:500 userInfo:responseObject]);
                      }
                  }
                     fail:^(NSError *error) {
                         fail(error);
                     }];
    
}

-(void) checkUnWithUn:(NSString *) un
              success:(void (^)(NSDictionary *responseObject))success
                 fail:(void (^)(NSError *error))fail
{
    NSDictionary *data = @{@"un": un};
    [self getJSONWithUrl:@"/?action=passport_service.before_register"
               parameters:data
                  success:^(id responseObject) {
                      if ([[responseObject objectForKey:@"code"] intValue] == 0) {
                          success([responseObject objectForKey:@"data"]);
                      } else {
                          fail([NSError errorWithDomain:@"response data error" code:500 userInfo:responseObject]);
                      }
                  }
                     fail:^(NSError *error) {
                         fail(error);
                     }];
    
}


-(void) getUserInfoWithId:(NSInteger) uid
                  success:(void (^)(NSDictionary *responseObject))success
                     fail:(void (^)(NSError *error))fail
{
    NSDictionary *data = @{@"uid": [NSNumber numberWithInteger:uid]};
    [self getJSONWithUrl:@"/?action=user_info_service.get"
              parameters:data
                 success:^(id responseObject) {

                     if ([[responseObject objectForKey:@"code"] intValue] == 0) {
                         success([responseObject objectForKey:@"data"]);
                     } else {
                         fail([NSError errorWithDomain:@"response data error" code:500 userInfo:responseObject]);
                     }
                 }
                    fail:^(NSError *error) {
                        fail(error);
                    }];
}

-(void) getFriendListWithUid:(NSInteger) uid
                     success:(void (^)(NSDictionary *responseObject))success
                        fail:(void (^)(NSError *error))fail;
{
    NSDictionary *data = @{@"uid": [NSNumber numberWithInteger:uid]};
    [self getJSONWithUrl:@"/?action=friend_service.my_list"
              parameters:data
                 success:^(id responseObject) {
                     
                     if ([[responseObject objectForKey:@"code"] intValue] == 0) {
                         success([responseObject objectForKey:@"data"]);
                     } else {
                         fail([NSError errorWithDomain:@"response data error" code:500 userInfo:responseObject]);
                     }
                 }
                    fail:^(NSError *error) {
                        fail(error);
                    }];
}

-(void) sayHelloToUid:(NSInteger) uid
              content:(NSString *) content
              success:(void (^)(NSDictionary *responseObject))success
                 fail:(void (^)(NSError *error))fail
{
    NSDictionary *data = @{@"uid": [NSNumber numberWithInteger:[MUser currentUser].uid], @"target": [NSNumber numberWithInteger:uid], @"conntent": content};
    [self getJSONWithUrl:@"/?action=friend_service.say_hello"
              parameters:data
                 success:^(id responseObject) {
                     
                     if ([[responseObject objectForKey:@"code"] intValue] == 0) {
                         success([responseObject objectForKey:@"data"]);
                     } else {
                         fail([NSError errorWithDomain:@"response data error" code:500 userInfo:responseObject]);
                     }
                 }
                    fail:^(NSError *error) {
                        fail(error);
                    }];
}

-(void) passFriendVerifyToUid:(NSInteger) uid
                      success:(void (^)(NSDictionary *responseObject))success
                         fail:(void (^)(NSError *error))fail
{
    NSDictionary *data = @{@"uid": [NSNumber numberWithInteger:[MUser currentUser].uid], @"pass_uid": [NSNumber numberWithInteger:uid]};
    [self getJSONWithUrl:@"/?action=friend_service.request_pass"
              parameters:data
                 success:^(id responseObject) {
                     
                     if ([[responseObject objectForKey:@"code"] intValue] == 0) {
                         success([responseObject objectForKey:@"data"]);
                     } else {
                         fail([NSError errorWithDomain:@"response data error" code:500 userInfo:responseObject]);
                     }
                 }
                    fail:^(NSError *error) {
                        fail(error);
                    }];
}

-(void) delFriendWithUid:(NSInteger) uid
                 success:(void (^)(NSDictionary *responseObject))success
                    fail:(void (^)(NSError *error))fail
{
    NSDictionary *data = @{@"uid": [NSNumber numberWithInteger:[MUser currentUser].uid], @"del_uid": [NSNumber numberWithInteger:uid]};
    [self getJSONWithUrl:@"/?action=friend_service.del"
              parameters:data
                 success:^(id responseObject) {
                     
                     if ([[responseObject objectForKey:@"code"] intValue] == 0) {
                         success([responseObject objectForKey:@"data"]);
                     } else {
                         fail([NSError errorWithDomain:@"response data error" code:500 userInfo:responseObject]);
                     }
                 }
                    fail:^(NSError *error) {
                        fail(error);
                    }];
}

-(void) searchUserWithKeyword:(NSString *) keyword
                      success:(void (^)(NSArray *responseObject))success
                         fail:(void (^)(NSError *error))fail
{
    NSDictionary *data = @{@"kw": keyword};
    [self getJSONWithUrl:@"/?action=user_info_service.search"
              parameters:data
                 success:^(id responseObject) {
                     if ([[responseObject objectForKey:@"code"] intValue] == 0) {
                         success([responseObject objectForKey:@"data"]);
                     } else {
                         fail([NSError errorWithDomain:@"response data error" code:500 userInfo:responseObject]);
                     }
                 }
                    fail:^(NSError *error) {
                        fail(error);
                    }];
}

-(void) getGroupListSuccess:(void (^)(NSArray *responseObject))success
                       fail:(void (^)(NSError *error))fail
{
    NSDictionary *data = @{@"uid":[NSNumber numberWithInteger:[MUser currentUser].uid]};
    [self getJSONWithUrl:@"/?action=group_service.list"
              parameters:data
                 success:^(id responseObject) {
                     if ([[responseObject objectForKey:@"code"] intValue] == 0) {
                         success([responseObject objectForKey:@"data"]);
                     } else {
                         fail([NSError errorWithDomain:@"response data error" code:500 userInfo:responseObject]);
                     }
                 }
                    fail:^(NSError *error) {
                        fail(error);
                    }];
}

-(void) createGroupWithUids:(NSArray *) uids
                    success:(void (^)(NSDictionary *responseObject))success
                       fail:(void (^)(NSError *error))fail
{
    NSDictionary *data = @{@"ids":[uids componentsJoinedByString:@","], @"uid":[NSNumber numberWithInteger:[MUser currentUser].uid]};
    [self getJSONWithUrl:@"/?action=group_service.add_member"
              parameters:data
                 success:^(id responseObject) {
                     if ([[responseObject objectForKey:@"code"] intValue] == 0) {
                         success([responseObject objectForKey:@"data"]);
                     } else {
                         fail([NSError errorWithDomain:@"response data error" code:500 userInfo:responseObject]);
                     }
                 }
                    fail:^(NSError *error) {
                        fail(error);
                    }];
}

-(void) addGroupMemberWithGid:(NSInteger) gid
                         Uids:(NSArray *) uids
                      success:(void (^)(NSDictionary *responseObject))success
                         fail:(void (^)(NSError *error))fail
{
    NSDictionary *data = @{@"gid":[NSString stringWithFormat:@"%ld", (long)gid], @"ids": [uids componentsJoinedByString:@","], @"uid":[NSNumber numberWithInteger:[MUser currentUser].uid]};
    [self getJSONWithUrl:@"/?action=group_service.add_member"
              parameters:data
                 success:^(id responseObject) {
                     if ([[responseObject objectForKey:@"code"] intValue] == 0) {
                         success([responseObject objectForKey:@"data"]);
                     } else {
                         fail([NSError errorWithDomain:@"response data error" code:500 userInfo:responseObject]);
                     }
                 }
                    fail:^(NSError *error) {
                        fail(error);
                    }];
}

-(void) quitGroupWithGid:(NSInteger) gid
                 success:(void (^)(void))success
                    fail:(void (^)(NSError *error))fail {
    NSDictionary *data = @{@"uid":@([MUser currentUser].uid), @"gid":@(gid)};
    [self getJSONWithUrl:@"/?action=group_service.quit"
              parameters:data
                 success:^(id responseObject) {
                     if ([[responseObject objectForKey:@"code"] intValue] == 0) {
                         success();
                     } else {
                         fail([NSError errorWithDomain:@"response data error" code:500 userInfo:responseObject]);
                     }
                 }
                    fail:^(NSError *error) {
                        fail(error);
                    }];
}

-(void) delGroupWithGid:(NSInteger) gid
                success:(void (^)(void))success
                   fail:(void (^)(NSError *error))fail {
    NSDictionary *data = @{@"uid":@([MUser currentUser].uid), @"gid":@(gid)};
    [self getJSONWithUrl:@"/?action=group_service.delete"
              parameters:data
                 success:^(id responseObject) {
                     if ([[responseObject objectForKey:@"code"] intValue] == 0) {
                         success();
                     } else {
                         fail([NSError errorWithDomain:@"response data error" code:500 userInfo:responseObject]);
                     }
                 }
                    fail:^(NSError *error) {
                        fail(error);
                    }];
}


#pragma mark - JSON方式post提交数据
- (void) postJSONWithUrl:(NSString *)urlStr parameters:(id)parameters success:(void (^)(id responseObject))success fail:(void (^)())fail
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    // 设置请求格式
//    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    // 设置返回格式
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:[NSString stringWithFormat:@"%@%@", IM_SERVER_HOST, urlStr]
       parameters:parameters
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              //查看返回数据
              //NSString *result = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
              if (success) {
                success(responseObject);
            }
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              NSLog(@"%@", error);
              if (fail) {
                  fail();
              }
          }];
}

- (void) getJSONWithUrl:(NSString *)urlStr
             parameters:(id)parameters
                success:(void (^)(id responseObject))success
                   fail:(void (^)())fail
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    // 设置请求格式
//    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    // 设置返回格式
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager GET:[NSString stringWithFormat:@"%@%@", IM_SERVER_HOST, urlStr] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //查看返回数据
//        NSString *result = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
//        NSLog(@"%@", result);
        if (success) {
            success(responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
        if (fail) {
            fail();
        }
    }];
}

#pragma mark upload file
-(void) uploadAvatarWithImage:(UIImage *) image
                          uid:(NSInteger) uid
                      success:(void (^)(NSDictionary *responseObject))success
                         fail:(void (^)(NSError *error))fail {
    NSData *data = UIImagePNGRepresentation(image);
    if (data == nil) {
        data = UIImageJPEGRepresentation(image, 1);
    }
    [self uploadFileWithUrl:[NSString stringWithFormat:@"/?action=me_service.upload_avatar&uid=%ld", (long)uid]
                       data:data
                    success:^(id responseObject) {
                        if ([[responseObject objectForKey:@"code"] intValue] == 0) {
                            success([responseObject objectForKey:@"data"]);
                        }
                        
                    }
                    failure:^(NSError *error) {
                        fail(error);
                    }];
}


-(void) uploadWithImage:(UIImage *) image
                   name:(NSString *) filename
                   type:(int) type
                success:(void (^)(NSDictionary *responseObject))success
                   fail:(void (^)(NSError *error))fail {
    NSData *data = UIImagePNGRepresentation(image);
    if (data == nil) {
        data = UIImageJPEGRepresentation(image, 1);
    }
    [self uploadFileWithUrl:@"/?action=file_service.upload"
                       data:data
                   fileName:filename
                       type:type
                    success:^(id responseObject) {
                        if ([[responseObject objectForKey:@"code"] intValue] == 0) {
                            success([responseObject objectForKey:@"data"]);
                        }
                        
                    }
                    failure:^(NSError *error) {
                        fail(error);
                    }];
}

-(void) uploadWithPath:(NSString *) path
                  type:(int) type
               success:(void (^)(NSDictionary *responseObject))success
                  fail:(void (^)(NSError *error))fail {
    NSData *data = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:path]];
    NSString *filename = [[path componentsSeparatedByString:@"/"] lastObject];

    [self uploadFileWithUrl:@"/?action=file_service.upload"
                       data:data
                   fileName:filename
                       type:type
                    success:^(id responseObject) {
                        if ([[responseObject objectForKey:@"code"] intValue] == 0) {
                            success([responseObject objectForKey:@"data"]);
                        }
                    }
                    failure:^(NSError *error) {
                        fail(error);
                    }];
}

- (void) uploadFileWithUrl:(NSString *) urlStr
                      data:(NSData *) data
                  fileName:filename
                      type:(int) type
                   success:(void (^)(id responseObject))success
                   failure:(void (^)(NSError *error))failure {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    filename = filename?:@"file";
    NSString *contentType = [[IMFileHelper shareInstance] contentTypeForImageData:data];
    
    [manager POST:[NSString stringWithFormat:@"%@%@", FILE_SERVER_HOST, urlStr] parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:data
                                    name:@"file"
                                fileName:filename
                                mimeType:contentType];
        
        if (type > 0) {
            [formData appendPartWithFormData:[[NSString stringWithFormat:@"%d", type] dataUsingEncoding:NSUTF8StringEncoding] name:@"type"];
        }

    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Response: %@", responseObject);
        success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        failure(error);
    }];
}

- (void) uploadFileWithUrl:(NSString *) urlStr
                      data:(NSData *) data
                   success:(void (^)(id responseObject))success
                   failure:(void (^)(NSError *error))failure {
    [self uploadFileWithUrl:urlStr data:data fileName:nil type:0 success:success failure:failure];
}

#pragma mark 判断网络状况
//-(BOOL) isConnectionAvailable{
//    
//    BOOL isExistenceNetwork = YES;
//    Reachability *reach = [Reachability reachabilityWithHostName:@"www.baidu.com"];
//    switch ([reach currentReachabilityStatus]) {
//        case NotReachable:
//            isExistenceNetwork = NO;
//            //NSLog(@"notReachable");
//            break;
//        case ReachableViaWiFi:
//            isExistenceNetwork = YES;
//            //NSLog(@"WIFI");
//            break;
//        case ReachableViaWWAN:
//            isExistenceNetwork = YES;
//            //NSLog(@"3G");
//            break;
//    }
//    
//    if (!isExistenceNetwork) {
//        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];//<span style="font-family: Arial, Helvetica, sans-serif;">MBProgressHUD为第三方库，不需要可以省略或使用AlertView</span>
//        hud.removeFromSuperViewOnHide =YES;
//        hud.mode = MBProgressHUDModeText;
//        hud.labelText = NSLocalizedString(INFO_NetNoReachable, nil);
//        hud.minSize = CGSizeMake(132.f, 108.0f);
//        [hud hide:YES afterDelay:3];
//        return NO;
//    }
//    
//    return isExistenceNetwork;
//}

@end
