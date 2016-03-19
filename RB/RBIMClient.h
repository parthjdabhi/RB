//
//  RBIMClient.h
//  RB
//
//  Created by hjc on 16/3/17.
//  Copyright © 2016年 hjc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RBIMClient : NSObject

+(RBIMClient *) instance;

- (void) connectIM;

@end
