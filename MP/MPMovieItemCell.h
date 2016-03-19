//
//  MPMovieItemCell.h
//  RB
//
//  Created by hjc on 16/3/14.
//  Copyright © 2016年 hjc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MPStarView.h"

@interface MPMovieItemCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *movieImageView;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (strong, nonatomic) IBOutlet UILabel *actorLabel;

@property (strong, nonatomic) IBOutlet UIImageView *movieIconImageView;
@property (strong, nonatomic) IBOutlet UIButton *movieButton;
@property (strong, nonatomic) IBOutlet MPStarView *ratingView;
@property (strong, nonatomic) IBOutlet UILabel *scoreLabel;

@end
