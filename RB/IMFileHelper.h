//
//  IMFileHelper.h
//  R&B
//
//  Created by hjc on 15/12/4.
//  Copyright © 2015年 hjc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IMFileHelper : NSObject

+ (instancetype) shareInstance;

- (NSString *) getRootDocument;
- (NSString *) getPathWithName: (NSString *) name;
- (NSString *) getThumbPathWithName: (NSString *) name;
- (NSString *) getPathWithName: (NSString *) name prefix:(NSString *) prefix;
- (NSString *) getPathWithURL: (NSString *) url;

- (NSString *)contentTypeForImageData:(NSData *)data;
+(BOOL)downloadFile:(NSString *)urlstr path:(NSString *)savePath;

@end
