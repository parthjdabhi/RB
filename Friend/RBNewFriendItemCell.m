//
//  NewFriendCell.m
//  RB
//
//  Created by hjc on 15/12/15.
//  Copyright © 2015年 hjc. All rights reserved.
//

#import "RBNewFriendItemCell.h"

@implementation RBNewFriendItemCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (IBAction)handleBtnOnClick:(id)sender {
    NSDictionary *dict = @{@"uid": @(_uid)};
    [self.delegate btnOnClick:dict];
}

@end
