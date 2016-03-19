//
//  MPDiscoverMainController.m
//  RB
//
//  Created by hjc on 16/3/10.
//  Copyright © 2016年 hjc. All rights reserved.
//

#import "MPDiscoverMainController.h"

#import "MPDiscover.h"
#import "MPDiscoverItemCell.h"

#import <SDWebImage/UIImageView+WebCache.h>

@interface MPDiscoverMainController ()
{
    NSArray *_discoverArray;
}
@end

@implementation MPDiscoverMainController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSMutableArray *discovers = [[NSMutableArray alloc] init];
    MPDiscover *discover = [[MPDiscover alloc] init];
    discover.moduleName = @"动画片";
    discover.title = @"即将创下新的口碑逆袭神话——《疯狂动物城》";
    discover.content = @"疯狂动物城的票房3月4号开始上映，然后345连续三天的逆跌，在5号出现了一个高峰，8号出现了第二个高峰。楼主5号去看完电影就";
    discover.moviePosterUrl = @"https://img3.doubanio.com/view/thing_review/large/public/p102626.jpg";
    discover.author = [MUser currentUser];
    
    [discovers addObject:discover];
    [discovers addObject:discover];
    [discovers addObject:discover];
    
    _discoverArray = discovers;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _discoverArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath{
    return 450;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MPDiscoverItemCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MPDiscoverItem" forIndexPath:indexPath];


    MPDiscover *discover = [_discoverArray objectAtIndex:indexPath.row];
    [cell.contentImageView sd_setImageWithURL:[NSURL URLWithString:discover.moviePosterUrl]];
    cell.moduleLabel.text = [NSString stringWithFormat:@"/ %@", discover.moduleName];
    cell.titleTextView.text = discover.title;
    cell.titleTextView.font = [UIFont systemFontOfSize:17];
    cell.contentTextView.text = discover.content;
    cell.authorLabel.text = discover.author.nickname;
    [cell.avatarImageView sd_setImageWithURL:[NSURL URLWithString:discover.author.avatarUrl]  placeholderImage:[UIImage imageNamed:@"avater_default.png"]];
    
    return cell;
}

@end
