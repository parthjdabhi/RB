//
//  RBPostItemCell.h
//  RB
//
//  Created by hjc on 16/3/7.
//  Copyright © 2016年 hjc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RBPostItemCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *bannerImageView;
@property (strong, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;

@property (strong, nonatomic) IBOutlet UITextView *postContent;
@property (strong, nonatomic) IBOutlet UILabel *timeLabel;

@end
