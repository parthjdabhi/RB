//
//  NewFriendCell.h
//  RB
//
//  Created by hjc on 15/12/15.
//  Copyright © 2015年 hjc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewFriendCell : UITableViewCell

@property NSInteger uid;

@property (strong, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *commentLabel;
@property (strong, nonatomic) IBOutlet UIButton *handleBtn;

@property (assign, nonatomic) id delegate;

@end

@protocol NewFriendCellDelegate <NSObject>

- (void) btnOnClick:(NSDictionary *) dict;

@end