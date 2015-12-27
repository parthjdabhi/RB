//
//  GroupMemberCell.h
//  RB
//
//  Created by hjc on 15/12/23.
//  Copyright © 2015年 hjc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GroupMemberCell : UITableViewCell

@property (assign, nonatomic) id delegate;

- (void)setGroupMember:(NSArray *) members;

@end

@protocol GroupMemberCellDelegate <NSObject>

- (void) go2FriendSelectController;

@end
