//
//  IMImageStore.h
//  R&B
//
//  Created by hjc on 15/12/4.
//  Copyright © 2015年 hjc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface IMImageStore : NSObject

+ (instancetype) shareStore;
- (void) setImage: (UIImage *) image forKey:(NSString *) key;
- (UIImage *) imageForKey:(NSString *) key;
- (void) deleteImageForKey:(NSString *) key;

@end
