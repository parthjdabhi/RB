//
//  UserInfoCell.h
//  RB
//
//  Created by hjc on 16/1/19.
//  Copyright © 2016年 hjc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserInfoCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIImageView *avater;
@property (strong, nonatomic) IBOutlet UILabel *nicknameLabel;
@property (strong, nonatomic) IBOutlet UILabel *commentLabel;

@end
