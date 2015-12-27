//
//  IMImageStore.h
//  R&B
//
//  Created by hjc on 15/12/4.
//  Copyright © 2015年 hjc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <SDWebImage/UIImageView+WebCache.h>

@interface IMImageStore : NSObject

@property SDImageCache *imageCache;

+ (instancetype) shareStore;
- (void) initImage: (UIImage *) image withKey:(NSString *) key;
- (void) setImage: (UIImage *) image forKey:(NSString *) key;
- (UIImage *) imageForKey:(NSString *) key;
- (void) deleteImageForKey:(NSString *) key;

@end
