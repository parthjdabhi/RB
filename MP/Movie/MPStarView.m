//
//  MPStarView.m
//  RB
//
//  Created by hjc on 16/3/9.
//  Copyright © 2016年 hjc. All rights reserved.
//

#import "MPStarView.h"

@implementation MPStarView

-(void) setScore:(float) score {
    int maxScore = 5;
    
    score = score * maxScore;
    
    int scoreInt = floor(score);
    
    CGSize size = self.frame.size;
    int width = size.width/maxScore;
    
    for (int i=0; i<scoreInt; i++) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(i*width, 0, width, width)];
        imageView.image = [UIImage imageNamed:@"star2"];
        [self addSubview:imageView];
    }
    
    if (score > scoreInt) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(scoreInt*width, 0, width, width)];
        imageView.image = [UIImage imageNamed:@"star1"];
        [self addSubview:imageView];
    }
    
    for (int i=ceil(score); i<maxScore; i++) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(i*width, 0, width, width)];
        imageView.image = [UIImage imageNamed:@"star0"];
        [self addSubview:imageView];
    }
    
    self.backgroundColor = [UIColor clearColor];
}

@end
