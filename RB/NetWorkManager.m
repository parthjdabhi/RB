//
//  NetWorkManager.m
//  RB
//
//  Created by hjc on 15/12/8.
//  Copyright © 2015年 hjc. All rights reserved.
//

#import "NetWorkManager.h"
#import "AFNetworking.h"

@implementation NetWorkManager


static NetWorkManager *sharedInstance;

+(instancetype) shareInstace
{
    static BOOL initialized = NO;
    if (!initialized)
    {
        initialized = YES;
        sharedInstance = [[NetWorkManager alloc] init];
    }
    
    return sharedInstance;
}

-(NSString *) uploadFile:(NSString *) path {
    return nil;
}

#pragma mark - JSON方式post提交数据
- (void)postJSONWithUrl:(NSString *)urlStr parameters:(id)parameters success:(void (^)(id responseObject))success fail:(void (^)())fail
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    // 设置请求格式
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    // 设置返回格式
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager POST:urlStr parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //查看返回数据
        //NSString *result = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
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

@end
