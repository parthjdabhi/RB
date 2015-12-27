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
#import "User.h"

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

-(NSString *) uploadFile:(NSString *) path type:(int) type success:(void (^)(NSDictionary *responseObject))success fail:(void (^)(NSError *error))fail {
    NSData *data = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:path]];
    NSString *contentType = [[IMFileHelper shareInstance] contentTypeForImageData:data];
    NSString *filename = [[path componentsSeparatedByString:@"/"] lastObject];
    [self uploadFileWithUrl:@"http://localhost/lk/?action=file_service.upload"
                       data:data
                   fileName:filename
                contentType:contentType
                       type:type
                    success:^(id responseObject) {
                        if ([[responseObject objectForKey:@"type"] intValue] == 0) {
                            success([responseObject objectForKey:@"data"]);
                        }

                    }
                    failure:^(NSError *error) {
                        fail(error);
                    }];
    return nil;
}

-(void) getUserInfoWithId:(int) uid
                  success:(void (^)(NSDictionary *responseObject))success
                     fail:(void (^)(NSError *error))fail
{
    NSDictionary *data = @{@"uid": [NSNumber numberWithInt:uid]};
    [self getJSONWithUrl:@"http://localhost/im/?action=user_info_service.get"
              parameters:data
                 success:^(id responseObject) {

                     if ([[responseObject objectForKey:@"type"] intValue] == 0) {
                         success([responseObject objectForKey:@"data"]);
                     } else {
                         fail([NSError errorWithDomain:@"response data error" code:500 userInfo:responseObject]);
                     }
                 }
                    fail:^(NSError *error) {
                        fail(error);
                    }];
}

-(void) getFriendListWithUid:(int) uid
                     success:(void (^)(NSDictionary *responseObject))success
                        fail:(void (^)(NSError *error))fail;
{
    NSDictionary *data = @{@"uid": [NSNumber numberWithInt:uid]};
    [self getJSONWithUrl:@"http://localhost/im/?action=friend_service.my_list"
              parameters:data
                 success:^(id responseObject) {
                     
                     if ([[responseObject objectForKey:@"type"] intValue] == 0) {
                         success([responseObject objectForKey:@"data"]);
                     } else {
                         fail([NSError errorWithDomain:@"response data error" code:500 userInfo:responseObject]);
                     }
                 }
                    fail:^(NSError *error) {
                        fail(error);
                    }];
}

-(void) sayHelloToUid:(int) uid
              content:(NSString *) content
              success:(void (^)(NSDictionary *responseObject))success
                 fail:(void (^)(NSError *error))fail
{
    NSDictionary *data = @{@"uid": [NSNumber numberWithInt:[User currentUser].uid], @"target": [NSNumber numberWithInt:uid], @"conntent": content};
    [self getJSONWithUrl:@"http://localhost/im/?action=friend_service.say_hello"
              parameters:data
                 success:^(id responseObject) {
                     
                     if ([[responseObject objectForKey:@"type"] intValue] == 0) {
                         success([responseObject objectForKey:@"data"]);
                     } else {
                         fail([NSError errorWithDomain:@"response data error" code:500 userInfo:responseObject]);
                     }
                 }
                    fail:^(NSError *error) {
                        fail(error);
                    }];
}

-(void) passFriendVerifyToUid:(int) uid
                      success:(void (^)(NSDictionary *responseObject))success
                         fail:(void (^)(NSError *error))fail
{
    NSDictionary *data = @{@"uid": [NSNumber numberWithInt:[User currentUser].uid], @"pass_uid": [NSNumber numberWithInt:uid]};
    [self getJSONWithUrl:@"http://localhost/im/?action=friend_service.request_pass"
              parameters:data
                 success:^(id responseObject) {
                     
                     if ([[responseObject objectForKey:@"type"] intValue] == 0) {
                         success([responseObject objectForKey:@"data"]);
                     } else {
                         fail([NSError errorWithDomain:@"response data error" code:500 userInfo:responseObject]);
                     }
                 }
                    fail:^(NSError *error) {
                        fail(error);
                    }];
}

-(void) delFriendWithUid:(int) uid
                 success:(void (^)(NSDictionary *responseObject))success
                    fail:(void (^)(NSError *error))fail
{
    NSDictionary *data = @{@"uid": [NSNumber numberWithInt:[User currentUser].uid], @"del_uid": [NSNumber numberWithInt:uid]};
    [self getJSONWithUrl:@"http://localhost/im/?action=friend_service.del"
              parameters:data
                 success:^(id responseObject) {
                     
                     if ([[responseObject objectForKey:@"type"] intValue] == 0) {
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
    [self getJSONWithUrl:@"http://localhost/im/?action=user_info_service.search"
              parameters:data
                 success:^(id responseObject) {
                     if ([[responseObject objectForKey:@"type"] intValue] == 0) {
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
    NSDictionary *data = @{@"uid":[NSNumber numberWithInt:[User currentUser].uid]};
    [self getJSONWithUrl:@"http://localhost/im/?action=group_service.list"
              parameters:data
                 success:^(id responseObject) {
                     if ([[responseObject objectForKey:@"type"] intValue] == 0) {
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
    NSDictionary *data = @{@"ids":[uids componentsJoinedByString:@","], @"uid":[NSNumber numberWithInt:[User currentUser].uid]};
    [self getJSONWithUrl:@"http://localhost/im/?action=group_service.add_member"
              parameters:data
                 success:^(id responseObject) {
                     if ([[responseObject objectForKey:@"type"] intValue] == 0) {
                         success([responseObject objectForKey:@"data"]);
                     } else {
                         fail([NSError errorWithDomain:@"response data error" code:500 userInfo:responseObject]);
                     }
                 }
                    fail:^(NSError *error) {
                        fail(error);
                    }];
}

-(void) addGroupMemberWithGid:(int) gid
                         Uids:(NSArray *) uids
                      success:(void (^)(NSDictionary *responseObject))success
                         fail:(void (^)(NSError *error))fail
{
    NSDictionary *data = @{@"gid":[NSString stringWithFormat:@"%d", gid], @"ids": [uids componentsJoinedByString:@","], @"uid":[NSNumber numberWithInt:[User currentUser].uid]};
    [self getJSONWithUrl:@"http://localhost/im/?action=group_service.add_member"
              parameters:data
                 success:^(id responseObject) {
                     if ([[responseObject objectForKey:@"type"] intValue] == 0) {
                         success([responseObject objectForKey:@"data"]);
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
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    // 设置返回格式
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:urlStr
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

- (void) getJSONWithUrl:(NSString *)urlStr parameters:(id)parameters success:(void (^)(id responseObject))success fail:(void (^)())fail
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    // 设置请求格式
//    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    // 设置返回格式
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager GET:urlStr parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
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

- (void) uploadFileWithUrl:(NSString *) urlStr
                      data:(NSData *) data
                  fileName:filename
               contentType:(NSString *) contentType
                      type:(int) type
                   success:(void (^)(id responseObject))success
                   failure:(void (^)(NSError *error))failure {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    [manager POST:urlStr parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:data
                                    name:@"file"
                                fileName:filename
                                mimeType:contentType];
//        [formData appendPartWithFormData:data name:@"file"];
        [formData appendPartWithFormData:[[NSString stringWithFormat:@"%d", type] dataUsingEncoding:NSUTF8StringEncoding] name:@"type"];
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Response: %@", responseObject);
        success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        failure(error);
    }];
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
