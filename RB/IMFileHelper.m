//
//  IMFileHelper.m
//  R&B
//
//  Created by hjc on 15/12/4.
//  Copyright © 2015年 hjc. All rights reserved.
//

#import "IMFileHelper.h"
#import "NSString+MD5.h"

@implementation IMFileHelper

+ (instancetype) shareInstance {
    static IMFileHelper *shareInstance = nil;
    if (!shareInstance) {
        shareInstance = [[IMFileHelper alloc] initPrivate];
    }
    return shareInstance;
}

- (instancetype) init {
    @throw [NSException exceptionWithName:@"singleton" reason:@"use +[IMFileHelper shareInstance]" userInfo:nil];
    return nil;
}

- (instancetype) initPrivate {
    self = [super init];
    return self;
}


- (NSString *) getRootDocument {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

- (NSString *) getPathWithName: (NSString *) name {
    NSString *filePath = nil;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *urlStr = [self getRootDocument];
    NSArray *prefixArray = [name componentsSeparatedByString:@"."];
    
    if (prefixArray.count > 1) {
        name = [[prefixArray subarrayWithRange:NSMakeRange(0, prefixArray.count-1)] componentsJoinedByString:@"."];
        name = [name stringByReplacingOccurrencesOfString:@"." withString:@"_"];
        
        NSArray *pathArr = [name componentsSeparatedByString:@"-"];
        if (pathArr.count > 1) {
            filePath = [urlStr stringByAppendingPathComponent: [pathArr componentsJoinedByString: @"/"]];
        } else {
            int filePathPartLength = (int) (name.length / 3);
            NSMutableArray *pathArr = [[NSMutableArray alloc] init];
            for (int i=0; i < 3; i++) {
                NSString *filePathPart = nil;
                if (i < 2) {
                    filePathPart = [name substringWithRange:NSMakeRange(i*filePathPartLength, filePathPartLength)];
                } else {
                    filePathPart = [name substringFromIndex:i*filePathPartLength-1];
                }
                [pathArr addObject:filePathPart];
            }
            filePath = [urlStr stringByAppendingPathComponent: [pathArr componentsJoinedByString: @"/"]];
        }
        
        name = [NSString stringWithFormat:@"%@.%@", name, [prefixArray lastObject]];
    } else {
        NSArray *pathArr = [name componentsSeparatedByString:@"-"];
        if (pathArr.count > 1) {
            filePath = [urlStr stringByAppendingPathComponent: [pathArr componentsJoinedByString: @"/"]];
        } else {
            int filePathPartLength = (int) (name.length / 3);
            NSMutableArray *pathArr = [[NSMutableArray alloc] init];
            for (int i=0; i < 3; i++) {
                NSString *filePathPart = nil;
                if (i < 2) {
                    filePathPart = [name substringWithRange:NSMakeRange(i*filePathPartLength, filePathPartLength)];
                } else {
                    filePathPart = [name substringFromIndex:i*filePathPartLength-1];
                }
                [pathArr addObject:filePathPart];
            }
            filePath = [urlStr stringByAppendingPathComponent: [pathArr componentsJoinedByString: @"/"]];
        }
    }
    
    [fileManager createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:nil];
    return [filePath stringByAppendingFormat:@"/%@", name];
}

- (NSString *) getPathWithURL: (NSString *) url {
    NSString *filePath = nil;
    NSString *urlStr = [self getRootDocument];
    
    NSString *hash = [url MD5];
    int part = 4;
    long length = hash.length/4;
    NSMutableArray *pathArray = [[NSMutableArray alloc] init];
    for (long i=0; i<part-1; i++) {
        [pathArray addObject:[hash substringWithRange:NSMakeRange(i*length, length)]];
    }
    
    filePath = [urlStr stringByAppendingPathComponent: [pathArray componentsJoinedByString: @"/"]];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:nil];
    
    [pathArray addObject:[hash substringWithRange:NSMakeRange((part-1)*length, length)]];
    filePath = [urlStr stringByAppendingPathComponent: [pathArray componentsJoinedByString: @"/"]];
    NSArray *prefixArray = [url componentsSeparatedByString:@"."];
    if (prefixArray.count > 1) {
        filePath = [NSString stringWithFormat:@"%@.%@", filePath, [prefixArray lastObject]];
    }
    
    return filePath;
}


- (NSString *) getThumbPathWithName: (NSString *) name {
    return [[self getPathWithName:name] stringByAppendingString:@".thumb"];
}

- (NSString *) getPathWithName: (NSString *) name prefix:(NSString *) prefix {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *urlStr = [self getRootDocument];
    NSString *filePath = [urlStr stringByAppendingPathComponent: [[name componentsSeparatedByString:@"-"] componentsJoinedByString: @"/"]];
    [fileManager createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:nil];
    return [filePath stringByAppendingFormat:@"/%@.%@", name, prefix];
}

- (NSString *) contentTypeForImageData:(NSData *)data {
    uint8_t c;
    [data getBytes:&c length:1];
    
    switch (c) {
        case 0xFF:
            return @"image/jpeg";
        case 0x89:
            return @"image/png";
        case 0x47:
            return @"image/gif";
        case 0x49:
        case 0x4D:
            return @"image/tiff";
    }
    return nil;
}

+(BOOL)downloadFile:(NSString *)urlstr path:(NSString *)savePath {
    NSURL *url=[NSURL URLWithString:urlstr];
    NSURLRequest *request=[NSURLRequest requestWithURL:url];
    NSError *error=nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
    if([data length]>0) {
        NSLog(@"下载成功");
        if([data writeToFile:savePath atomically:YES]) {
            NSLog(@"保存成功");
        } else {
            NSLog(@"保存失败");
        }
        return YES;
    } else {
        NSLog(@"下载失败，失败原因：%@",error);
        return NO;
    }
}


@end
