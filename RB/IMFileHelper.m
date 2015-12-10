//
//  IMFileHelper.m
//  R&B
//
//  Created by hjc on 15/12/4.
//  Copyright © 2015年 hjc. All rights reserved.
//

#import "IMFileHelper.h"

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
        filePath = [urlStr stringByAppendingPathComponent: [[name componentsSeparatedByString:@"-"] componentsJoinedByString: @"/"]];
        name = [NSString stringWithFormat:@"%@.%@", name, [prefixArray lastObject]];
    } else {
        filePath = [urlStr stringByAppendingPathComponent: [[name componentsSeparatedByString:@"-"] componentsJoinedByString: @"/"]];
    }
    
    [fileManager createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:nil];
    return [filePath stringByAppendingFormat:@"/%@", name];
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

@end
