//
//  UserInfoCell.h
//  RB
//
//  Created by hjc on 16/1/19.
//  Copyright © 2016年 hjc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserInfoCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIImageView *avatar;
@property (strong, nonatomic) IBOutlet UILabel *displayNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *nicknameLabel;

@end
