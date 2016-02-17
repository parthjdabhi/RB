//
//  GroupMemberCell.h
//  RB
//
//  Created by hjc on 15/12/23.
//  Copyright © 2015年 hjc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DialogMemberCell : UITableViewCell

@property (assign, nonatomic) id delegate;

- (void)setMember:(NSArray *) members;

@end

@protocol DialogMemberCellDelegate <NSObject>

- (void) go2FriendSelectController;

@end
