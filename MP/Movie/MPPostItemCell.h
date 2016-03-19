//
//  MPPostItemCell.h
//  MP
//
//  Created by hjc on 16/3/7.
//  Copyright © 2016年 hjc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MPStarView.h"
#import "MPMoviePartnerView.h"

@interface MPPostItemCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIScrollView *bannerScrollView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bannerScrollViewWidthConstraint;
//@property (strong, nonatomic) IBOutlet UIView *bannerScrollContentView;
//@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bannerContentWidthConstraint;
@property (strong, nonatomic) IBOutlet UIPageControl *bannerPageControl;

@property (strong, nonatomic) IBOutlet UIImageView *movieImageView;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (strong, nonatomic) IBOutlet UILabel *actorLabel;

@property (strong, nonatomic) IBOutlet UIImageView *movieIconImageView;
@property (strong, nonatomic) IBOutlet UIButton *movieButton;
@property (strong, nonatomic) IBOutlet MPStarView *ratingView;
@property (strong, nonatomic) IBOutlet UILabel *scoreLabel;
@property (strong, nonatomic) IBOutlet MPMoviePartnerView *parnterView;


@end
