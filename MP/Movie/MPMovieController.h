//
//  MPMovieController.h
//  RB
//
//  Created by hjc on 16/3/11.
//  Copyright © 2016年 hjc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MPMovie.h"
#import "MPStarView.h"

@interface MPMovieController : UIViewController

@property MPMovie *movie;

@property (strong, nonatomic) IBOutlet UIImageView *posterBGImageView;
@property (strong, nonatomic) IBOutlet UIImageView *posterImageView;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *enNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *typeLabel;
@property (strong, nonatomic) IBOutlet UILabel *countryLabel;
@property (strong, nonatomic) IBOutlet UILabel *openDayLabel;
@property (strong, nonatomic) IBOutlet MPStarView *scoreView;
@property (strong, nonatomic) IBOutlet UILabel *scoreLabel;

@property (strong, nonatomic) IBOutlet UIButton *likeButton;
@property (strong, nonatomic) IBOutlet UIButton *commentButton;

@property (strong, nonatomic) IBOutlet UITextView *descTextView;
@property (strong, nonatomic) IBOutlet UIButton *descTextButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *descTextViewHeightConstraint;


@end
