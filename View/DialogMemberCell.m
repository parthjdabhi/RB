//
//  GroupMemberCell.m
//  RB
//
//  Created by hjc on 15/12/23.
//  Copyright © 2015年 hjc. All rights reserved.
//

#import "DialogMemberCell.h"
#import "User.h"
#import <SDWebImage/UIImageView+WebCache.h>

@implementation DialogMemberCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setMember:(NSArray *) members {
    int index = 0;
    for (User *user in members) {
        if (index >= 5) {
            break;
        }
        
        UIImageView *photo = [[UIImageView alloc]initWithFrame:CGRectMake(10 + 60 * index, 5, 50, 50)];
        NSURL *url = [NSURL URLWithString:user.avaterUrl];
        [photo sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"avater_default.png"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            
        }];
//        photo.image = [UIImage imageNamed:[NSString stringWithFormat:@"avater_%d.jpg", user.uid]];
        [self.contentView addSubview:photo];
        
        index++;
    }
    
    UIButton *addMemberBtn = [[UIButton alloc] initWithFrame:CGRectMake(10 + 60 * index, 5, 50, 50)];
    [addMemberBtn setImage:[UIImage imageNamed:@"iconfont-plus.png"] forState:UIControlStateNormal];
    [addMemberBtn addTarget:self action:@selector(go2FriendSelectController) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:addMemberBtn];
}

- (void)go2FriendSelectController {
    [_delegate go2FriendSelectController];
}

@end
