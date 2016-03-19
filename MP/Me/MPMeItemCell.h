//
//  MPMeItemCell.h
//  RB
//
//  Created by hjc on 16/3/15.
//  Copyright © 2016年 hjc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MPMeItemCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (strong, nonatomic) IBOutlet UILabel *nickname;
@property (strong, nonatomic) IBOutlet UILabel *signature;

@property (strong, nonatomic) IBOutlet UIButton *albumButton;
@property (strong, nonatomic) IBOutlet UIButton *favouriteButton;
@property (strong, nonatomic) IBOutlet UIButton *clubMemberButton;

@end
