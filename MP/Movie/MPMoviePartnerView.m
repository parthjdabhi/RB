//
//  MPMoviePartnerView.m
//  RB
//
//  Created by hjc on 16/3/10.
//  Copyright © 2016年 hjc. All rights reserved.
//

#define MOVIE_PARNTER_VIEW_HEIGHT 44.0f
#define MOVIE_PARNTER_AVATAR_WIDTH 34.0f
#define MOVIE_PARNTER_AVATAR_MARGIN 5.0f

#import "MPMoviePartnerView.h"

#import "MUser.h"
#import <SDWebImage/UIImageView+WebCache.h>

@implementation MPMoviePartnerView

-(void) setPartners:(NSArray *)partners {
    CGSize size = self.frame.size;
    float avatar_margin = MOVIE_PARNTER_AVATAR_MARGIN * size.height / MOVIE_PARNTER_VIEW_HEIGHT;
    float avatar_width = MOVIE_PARNTER_AVATAR_WIDTH * size.height / MOVIE_PARNTER_VIEW_HEIGHT;
    
    for (int i=0; i<partners.count; i++) {
        MUser *user = [partners objectAtIndex:i];
        
        if (user != nil) {
            UIImageView *avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(i * avatar_width + (i+1) * avatar_margin, avatar_margin, avatar_width, avatar_width)];

            NSURL *url = [NSURL URLWithString:user.avatarThumbUrl];
            [avatarImageView sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"avater_default.png"]];
            [self addSubview:avatarImageView];
        }
    }
    
    self.backgroundColor = [UIColor clearColor];
}

@end
