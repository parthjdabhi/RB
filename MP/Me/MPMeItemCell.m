//
//  MPMeItemCell.m
//  RB
//
//  Created by hjc on 16/3/15.
//  Copyright © 2016年 hjc. All rights reserved.
//

#import "MPMeItemCell.h"

@implementation MPMeItemCell

- (instancetype) init {
    self = [super init];
    
    [self initButton];
    
    return self;
}

- (void)awakeFromNib {
   [self initButton];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)initButton {
    [self initButton:self.albumButton imageName:@"menuIconAlbum"];
    [self initButton:self.favouriteButton imageName:@"menuIconFavourite"];
    [self initButton:self.clubMemberButton imageName:@"menuIconClubMember"];
}

- (void)initButton:(UIButton *) button imageName:(NSString *) imageName {
    UIImage *image = [[UIImage imageNamed:imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIImage *selectedImage = [[UIImage imageNamed:imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    [button setImage:image forState:UIControlStateNormal];
    [button setImage:selectedImage forState:UIControlStateHighlighted];
    button.imageEdgeInsets = UIEdgeInsetsMake(0, 30, 0, 60);
    button.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0);
    button.titleLabel.font = [UIFont systemFontOfSize:14];
}

@end
