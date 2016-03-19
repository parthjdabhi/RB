//
//  MPMovieMainController.m
//  RB
//
//  Created by hjc on 16/3/8.
//  Copyright © 2016年 hjc. All rights reserved.
//

#import "MPMovieMainController.h"

#import "MPNavigationController.h"
#import "MPPostItemCell.h"
#import "MPMoviePost.h"
#import "MPMovieAdvertise.h"

#import "IMDAO.h"

#import "AFHTTPRequestOperationManager.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface MPMovieMainController ()<UIScrollViewDelegate>
{
    NSArray *_postArray;
    NSArray *_advertiseArray;
    UIScrollView *_bannerScrollView;
    UIPageControl *_bannerPageControl;
}
@end

@implementation MPMovieMainController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSArray *users = [[IMDAO shareInstance] getFriendsWithUid:[MUser currentUser].uid];
    
    NSMutableArray *posts = [[NSMutableArray alloc] init];
    MPMoviePost *post = [[MPMoviePost alloc] init];
    MPMovie *movie = [[MPMovie alloc] init];
    movie.name = @"卧虎藏龙：青冥宝剑";
    movie.desc = @"江湖有你，久别重逢";
    movie.actors = @"袁和平 甄子丹 杨紫琼";
    movie.score = 7.1;
    post.movie = movie;
    post.partners = users;
    
    [posts addObject:post];
    
    post = [[MPMoviePost alloc] init];
    movie = [[MPMovie alloc] init];
    movie.name = @"西游记之孙悟空三打白骨精";
    movie.desc = @"重要的妖精打三遍！金猴献瑞全家约";
    movie.actors = @"郑宝瑞 郭富城 巩俐";
    movie.score = 8.2;
    post.movie = movie;
    post.partners = users;
    
    [posts addObject:post];
    
    
    _postArray = posts;
    
    self.tableView.estimatedRowHeight = 44.0f;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    [self initData];
}

-(void) initData {
    
//    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//    // 设置请求格式
//    //    manager.requestSerializer = [AFJSONRequestSerializer serializer];
//    // 设置返回格式
//    manager.responseSerializer = [AFJSONResponseSerializer serializer];
//    manager.securityPolicy.allowInvalidCertificates = YES;
//    manager.securityPolicy.validatesDomainName = NO;
//    
//    [manager.requestSerializer setValue:@"4.0" forHTTPHeaderField:@"m-pv"];
//    [manager.requestSerializer setValue:@"23086819" forHTTPHeaderField:@"m-appkey"];
//    [manager.requestSerializer setValue:@"1a34abfe9b2ed28457297e7b1f21222e71ea45d9" forHTTPHeaderField:@"m-sign"];
//    [manager.requestSerializer setValue:@"1457684892" forHTTPHeaderField:@"m-t"];
//    
//    [manager GET:@"https://api.m.taobao.com/gw/mtop.film.mtopshowapi.getshowsbycitycode/4.0?wua=i002w%2BP3qAoHE5wUhDhTvLjNMNWZ9wG2%2Fj0ei1xAMRw2u6YgZ0q2KTT2YZxTjoSd%2B3JejhnnSL92%2BEsk8KC9a8mHmVIgY4LTW%2FUUq4IU0guyBKrFZDTgoSdk5k6ssPpWZaDkJ9MPLbjzVv0PDre7lNT68kMxBs0qTWdpkcMGqsXNBsRu3q64VvilNrOGk8w7xr1fri6cpc07%2FwoYoolTqFqWpd1nqCS5OmB%2Fm2spmp%2FB3lsMKAGzt3zM2SINmqPeM6RPmrQZwHZTZvy55272aNExsz8L8KiBSAu%2BjdG7V8znoUjQHS%2FSUL%2FGlDGgkKxU97yPvZw2c1F5dTlBWUzyGkPzepvRbfJkF9M%2B20GJfRqPnWFVKpE0nXduZOwdw91XVbtrP1fQXgeeffPn%2BUTwJLcI7ca3XNvBOu8Mc80VjjSA3fhT%2FGxKDybjBdbgnbclCMWuspZbQFkWqlfFi%2FrTdj4G3qeT6O3mqVWz9kO2OBq6i15HfVwnvJWYeP%2BSLbM557utAI1Rx4LFVz80WHOTuokr4JqNyMYmDPBueE8hoTqIqYfjzGrImSJx2PkPsoE%2BJwL8RntXl7R1nmuP1KEYfTSFpg%3D%3D&rnd=597F10EEE0CE574288DA2523F4D1EC77&data=%7B%22citycode%22%3A%22440300%22%2C%22asac%22%3A%22D679AU6J95PHQT67G0B5%22%2C%22pageCode%22%3A%22SHOW%22%2C%22field%22%3A%22i%3Aid%3BshowName%3BshowNameEn%3Bhighlight%3Bposter%3Bdirector%3BleadingRole%3Btype%3Bduration%3BopenDay%3Bactivities%3Bremark%3BremarkCount%3BshowMark%3Bcountry%3BopenCountry%3BspecialSchedules%3BwantCount%3BopenTime%3Bpreview%3BalipayH5Url%3BderivationList%3Bfantastic%22%2C%22platform%22%3A%2232768%22%7D"
//      parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        //查看返回数据
//        NSString *result = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
//        NSLog(@"%@", result);
//
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        NSLog(@"%@", error);
//    }];
    
    NSString *moviesFilePath=[[NSBundle mainBundle] pathForResource:@"movies" ofType:@"json"];
    NSError *error;
    NSDictionary *contentDict = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:moviesFilePath]
                                                                options:NSJSONReadingMutableLeaves
                                                                  error:&error];
    NSArray *movies = contentDict[@"data"][@"returnValue"];

    NSMutableArray *posts = [[NSMutableArray alloc] init];
    NSArray *users = [[IMDAO shareInstance] getFriendsWithUid:[MUser currentUser].uid];
    for (NSDictionary *m in movies) {

        MPMoviePost *post = [[MPMoviePost alloc] init];
        MPMovie *movie = [[MPMovie alloc] init];
        movie.name = m[@"showName"];
        movie.poster = [NSString stringWithFormat:@"http://img1.tbcdn.cn/tsfcom/%@_336x336", m[@"poster"]];
        movie.desc = m[@"highlight"];
        movie.actors = m[@"leadingRole"];
        movie.score = [[m objectForKey:@"remark"] floatValue];
        post.movie = movie;
        post.partners = users;
        
        [posts addObject:post];
    }
    
    _postArray = posts;
    
    
    NSString *adFilePath=[[NSBundle mainBundle] pathForResource:@"ads" ofType:@"json"];
    contentDict = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:adFilePath]
                                                                options:NSJSONReadingMutableLeaves
                                                                  error:&error];
    
    NSMutableArray *ads = [[NSMutableArray alloc] init];
    for (NSDictionary *a in contentDict[@"data"][@"returnValue"]) {
        MPMovieAdvertise *ad = [[MPMovieAdvertise alloc] init];
        ad.pictureUrl = [NSString stringWithFormat:@"http://img1.tbcdn.cn/tsfcom/%@_790x420", a[@"smallPicUrl"]];
        [ads addObject:ad];
    }
    
    _advertiseArray = ads;
}

//-(void)viewWillAppear:(BOOL)animated {
//    if ([self.navigationController isKindOfClass:[MPNavigationController class]]) {
//        MPNavigationController *nc = (MPNavigationController *)self.navigationController;
//        nc.navigationView.hidden = FALSE;
//    }
//}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _postArray.count+1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath{
    if (indexPath.section == 0 && indexPath.row == 0) {
        
        return 152;
    }
    
    return 155;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MPPostItemCell *cell = nil;
    
    if (indexPath.section == 0 && indexPath.row == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"MPMovieBanner" forIndexPath:indexPath];
        _bannerScrollView = cell.bannerScrollView;
        _bannerPageControl = cell.bannerPageControl;
        
        CGRect bounds = self.view.frame;

        cell.bannerScrollViewWidthConstraint.constant = bounds.size.width;
//        cell.bannerContentWidthConstraint.constant = bounds.size.width * 5;
        [_bannerScrollView setContentSize:CGSizeMake(bounds.size.width * _advertiseArray.count, 152)];
        _bannerScrollView.pagingEnabled = YES;  //设为YES时，会按页滑动
        _bannerScrollView.bounces = NO; //取消UIScrollView的弹性属性，这个可以按个人喜好来定
        [_bannerScrollView setDelegate:self];//UIScrollView的delegate函数在本类中定义
        
        
//        [_bannerPageControl setPageIndicatorTintColor:[UIColor redColor]];
//        [_bannerPageControl setCurrentPageIndicatorTintColor:[UIColor blackColor]];
        
        for (int i = 0; i < _advertiseArray.count; i++) {
            MPMovieAdvertise *ad = _advertiseArray[i];
            
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(i*bounds.size.width, 0, bounds.size.width, 152)];
            [imageView sd_setImageWithURL:[NSURL URLWithString:ad.pictureUrl]];

            [_bannerScrollView addSubview:imageView];
        }
        
        _bannerPageControl.numberOfPages = _advertiseArray.count;//总的图片页数
        _bannerPageControl.currentPage = 0; //当前页

        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"MPMovieItem" forIndexPath:indexPath];
        
        MPMoviePost *post = [_postArray objectAtIndex:(indexPath.row - 1)];
        
        [cell.movieImageView sd_setImageWithURL:[NSURL URLWithString:post.movie.poster]];
        cell.titleLabel.text = post.movie.name;
        cell.descriptionLabel.text = post.movie.desc;
        cell.actorLabel.text = post.movie.actors;
        cell.ratingView.score = post.movie.score / 10;
        cell.scoreLabel.text = @(post.movie.score).stringValue;
        
        cell.movieButton.titleLabel.text = @"参加";
        cell.movieButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [cell.movieButton.layer setMasksToBounds:YES];
        [cell.movieButton.layer setCornerRadius:3];
        [cell.movieButton.layer setBorderWidth:1.0];
        
        UIColor *color = [UIColor colorWithRed:0/255 green:107.0/255 blue:238.0/255 alpha:1];
        [cell.movieButton setTitleColor:color forState:UIControlStateNormal];
        cell.movieButton.layer.borderColor = color.CGColor;
        
        if (post.partners != nil) {
            cell.parnterView.partners = post.partners;
        }
        
        return cell;
    }
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:TRUE];
}

#pragma mark - UIScrollView delegate method
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    int page = scrollView.contentOffset.x / scrollView.frame.size.width;
    _bannerPageControl.currentPage = page;
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    segue.destinationViewController.hidesBottomBarWhenPushed = TRUE;

//    if ([self.navigationController isKindOfClass:[MPNavigationController class]]) {
//        MPNavigationController *nc = (MPNavigationController *)self.navigationController;
//        nc.navigationView.hidden = TRUE;
//    }
}

@end
