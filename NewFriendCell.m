//
//  NewFriendCell.m
//  RB
//
//  Created by hjc on 15/12/15.
//  Copyright © 2015年 hjc. All rights reserved.
//

#import "NewFriendCell.h"

@implementation NewFriendCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (IBAction)handleBtnOnClick:(id)sender {
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", _uid], @"uid", nil];
    [self.delegate btnOnClick:dict];
}

@end
