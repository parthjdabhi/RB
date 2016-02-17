//
//  DialogItemCell.h
//  R&B
//
//  Created by hjc on 15/11/28.
//  Copyright © 2015年 hjc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DialogItemCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIImageView *avatar;
@property (strong, nonatomic) IBOutlet UILabel *title;
@property (strong, nonatomic) IBOutlet UILabel *subTitle;
@property (strong, nonatomic) IBOutlet UILabel *time;
@property (strong, nonatomic) IBOutlet UILabel *unreadLabel;

-(void) setUnreadCount:(int) count;

@end
