//
//  NoticeCell.h
//  RB
//
//  Created by hjc on 15/12/13.
//  Copyright © 2015年 hjc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NoticeCell : UITableViewCell

@property (nonatomic, strong) UILabel *noticeLabel;

- (void) initWithData:(NSMutableDictionary *) dict;

@end
