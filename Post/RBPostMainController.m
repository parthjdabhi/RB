//
//  RBPostMainController.m
//  RB
//
//  Created by hjc on 16/3/7.
//  Copyright © 2016年 hjc. All rights reserved.
//

#import "RBPostMainController.h"

#import "MUser.h"
#import "RBPostItemCell.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface RBPostMainController ()
{
    NSArray *_postArray;
}
@end

@implementation RBPostMainController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    _postArray 
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _postArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath{
    if (indexPath.section == 0 && indexPath.row == 0) {
        
        return 300;
    }
    
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RBPostItemCell *cell = nil;
    
    if (indexPath.section == 0 && indexPath.row == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"RBPostBanner" forIndexPath:indexPath];
        cell.nameLabel.text = [MUser currentUser].nickname;
        cell.bannerImageView.image = [UIImage imageNamed:@"postBanner.jpg"];
//        cell.bannerImageView.contentMode = UIViewContentModeScaleAspectFit;
        
        NSURL *url = [NSURL URLWithString:[MUser currentUser].avatarThumbUrl];
        [cell.avatarImageView sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"avater_default.png"]];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    } else {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        
        cell.text = @"xxxx";
        
        return cell;
    }
    
    return cell;
    
}

@end
