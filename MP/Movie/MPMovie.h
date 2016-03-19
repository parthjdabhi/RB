//
//  MPMovie.h
//  RB
//
//  Created by hjc on 16/3/8.
//  Copyright © 2016年 hjc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MPMovie : NSObject

@property(nonatomic) NSString *name;
@property(nonatomic) NSString *enName;
@property(nonatomic) NSString *type;
@property(nonatomic) NSString *poster;
@property(nonatomic) NSString *showMark;
@property(nonatomic) NSString *country;
@property(nonatomic) NSString *duration;
@property(nonatomic) NSDate *openDay;
@property(nonatomic) NSString *desc;
@property(nonatomic) NSString *actors;

@property(nonatomic) float score;
@property(nonatomic) int commentCount;

@end
