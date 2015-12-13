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

#pragma mark - JSON方式post提交数据
- (void) postJSONWithUrl:(NSString *)urlStr parameters:(id)parameters success:(void (^)(id responseObject))success fail:(void (^)())fail
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

@end
