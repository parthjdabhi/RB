//
//  IMImageStore.m
//  R&B
//
//  Created by hjc on 15/12/4.
//  Copyright © 2015年 hjc. All rights reserved.
//

#import "IMImageStore.h"

@interface IMImageStore()

@property (nonatomic, strong) NSMutableDictionary *dictionary;

@end

@implementation IMImageStore

+ (instancetype) shareStore {
    static IMImageStore *shareStore = nil;
    if (!shareStore) {
        shareStore = [[IMImageStore alloc] initPrivate];
    }
    
    return shareStore;
}

- (instancetype) init {
    @throw [NSException exceptionWithName:@"singleton" reason:@"use +[IMImageStrore shareStore]" userInfo:nil];
    return nil;
}

- (instancetype) initPrivate {
    self = [super init];
    if (self) {
        _dictionary = [[NSMutableDictionary alloc] init];
        _imageCache = [[SDImageCache alloc] initWithNamespace:@"IM"];
    }
    return self;
}

- (void) initImage: (UIImage *) image withKey:(NSString *) key {
//    SDWebImageQueryCompletedBlock doneBlock = ^(UIImage *i, SDImageCacheType cacheType) {
//        if (i) {
//            image = i;
//        } else {
//            
//        }
//    };
//    
//    [_imageCache queryDiskCacheForKey:key done:doneBlock];
}

- (void) setImage: (UIImage *) image forKey:(NSString *) key {
    [self.dictionary setObject:image forKey:key];
}

- (UIImage *) imageForKey:(NSString *) key {
    return [self.dictionary objectForKey:key];
}

- (void) deleteImageForKey:(NSString *) key {
    if (!key) {
        return;
    }
    
    [self.dictionary removeObjectForKey:key];
}


@end
