//
//  MPMoviePost.h
//  RB
//
//  Created by hjc on 16/3/8.
//  Copyright © 2016年 hjc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MPMovie.h"

@interface MPMoviePost : NSObject

@property(nonatomic, strong) MPMovie *movie;
@property(nonatomic, strong) NSArray *partners;

@end
