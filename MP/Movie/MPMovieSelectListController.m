//
//  MPMovieListController.m
//  RB
//
//  Created by hjc on 16/3/14.
//  Copyright © 2016年 hjc. All rights reserved.
//

#import "MPMovieSelectListController.h"

#import "MPMovieItemCell.h"
#import "MPMovieController.h"
#import "MPMoviePostAddController.h"

#import <SDWebImage/UIImageView+WebCache.h>

@interface MPMovieSelectListController ()
{
    NSArray *_movieArray;
}
@end

@implementation MPMovieSelectListController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];
    
    self.navigationItem.title = @"选择电影";
}

-(void) initData {
    NSString *moviesFilePath=[[NSBundle mainBundle] pathForResource:@"movies" ofType:@"json"];
    NSError *error;
    NSDictionary *contentDict = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:moviesFilePath]
                                                                options:NSJSONReadingMutableLeaves
                                                                  error:&error];
    NSArray *ms = contentDict[@"data"][@"returnValue"];
    
    NSMutableArray *movies = [[NSMutableArray alloc] init];
    for (NSDictionary *m in ms) {
        
        MPMovie *movie = [[MPMovie alloc] init];
        movie.name = m[@"showName"];
        movie.poster = [NSString stringWithFormat:@"http://img1.tbcdn.cn/tsfcom/%@_336x336", m[@"poster"]];
        movie.desc = m[@"highlight"];
        movie.actors = m[@"leadingRole"];
        movie.score = [[m objectForKey:@"remark"] floatValue];
        
        [movies addObject:movie];
    }
    
    _movieArray = movies;
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _movieArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *) indexPath {
    return 110;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MPMovieItemCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MPMovieItem" forIndexPath:indexPath];
    
    MPMovie *movie = [_movieArray objectAtIndex:indexPath.row];
    
    [cell.movieImageView sd_setImageWithURL:[NSURL URLWithString:movie.poster]];
    cell.titleLabel.text = movie.name;
    cell.descriptionLabel.text = movie.desc;
    cell.actorLabel.text = movie.actors;
    cell.ratingView.score = movie.score / 10;
    cell.scoreLabel.text = @(movie.score).stringValue;
    
    cell.movieButton.titleLabel.text = @"参加";
    cell.movieButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [cell.movieButton.layer setMasksToBounds:YES];
    [cell.movieButton.layer setCornerRadius:3];
    [cell.movieButton.layer setBorderWidth:1.0];
    
    UIColor *color = [UIColor colorWithRed:0/255 green:107.0/255 blue:238.0/255 alpha:1];
    [cell.movieButton setTitleColor:color forState:UIControlStateNormal];
    cell.movieButton.layer.borderColor = color.CGColor;
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    [tableView deselectRowAtIndexPath:indexPath animated:TRUE];
    MPMovie *movie = _movieArray[indexPath.row];
    [self.delegate selectMovie:movie];
//    [self.navigationController popViewControllerAnimated:TRUE];
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController isKindOfClass:[MPMovieController class]]) {
        MPMovieSelectDetailController *mc = (MPMovieSelectDetailController *)segue.destinationViewController;
        
        NSInteger row = self.tableView.indexPathForSelectedRow.row;
        mc.movie = _movieArray[row];
        
        
    }
}

@end

@implementation MPMovieSelectDetailController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UINavigationItem *item = self.navigationItem;
    item.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(ensureSelect:)];
    
    [self initData];
    [self initDisplayView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void) initData {
    NSString *moviesFilePath=[[NSBundle mainBundle] pathForResource:@"detail" ofType:@"json"];
    NSError *error;
    NSDictionary *contentDict = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:moviesFilePath]
                                                                options:NSJSONReadingMutableLeaves
                                                                  error:&error];
    NSDictionary *m = contentDict[@"data"][@"returnValue"];
    
    MPMovie *movie = [[MPMovie alloc] init];
    movie.name = m[@"showName"];
    movie.enName = m[@"showNameEn"];
    movie.poster = [NSString stringWithFormat:@"http://img1.tbcdn.cn/tsfcom/%@_336x336", m[@"poster"]];
    movie.type = m[@"type"];
    movie.desc = m[@"description"];
    movie.actors = m[@"leadingRole"];
    movie.score = [[m objectForKey:@"remark"] floatValue]/10;
    movie.showMark = m[@"showMark"];
    movie.country = m[@"country"];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    movie.openDay = [dateFormatter dateFromString:m[@"openDay"]];
    
    _movie = movie;
}

-(void) initDisplayView {
    self.nameLabel.text = _movie.name;
    self.enNameLabel.text = _movie.enName;
    [self.posterImageView sd_setImageWithURL:[NSURL URLWithString:_movie.poster]];
    
    [self.posterBGImageView sd_setImageWithURL:[NSURL URLWithString:_movie.poster]];
    self.posterBGImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.posterBGImageView.clipsToBounds = TRUE;
    
    // 毛玻璃效果
    UIVisualEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVisualEffectView *visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    visualEffectView.frame = self.posterBGImageView.bounds;
    [self.posterBGImageView addSubview:visualEffectView];
    
    self.typeLabel.text = _movie.type;
    self.descTextView.text = _movie.desc;
    [self.scoreView setScore:_movie.score];
    self.countryLabel.text = _movie.country;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    self.openDayLabel.text = [dateFormatter stringFromDate:_movie.openDay];
}

- (IBAction)showAllDescription:(id)sender {
    
    if ([_descTextButton.titleLabel.text isEqualToString:@"展开"]) {
        
        CGRect frame = self.descTextView.frame;
        _descTextViewHeightConstraint.constant = 100;
        
        NSLog(@"%@", NSStringFromCGRect(frame));
        [self.descTextView zoomToRect:CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, 100) animated:TRUE];
        
        [_descTextButton setTitle:@"收起" forState:UIControlStateNormal];
    } else {
        
        CGRect frame = self.descTextView.frame;
        _descTextViewHeightConstraint.constant = 60;
        
        NSLog(@"%@", NSStringFromCGRect(frame));
        [self.descTextView zoomToRect:CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, 60) animated:TRUE];
        
        [_descTextButton setTitle:@"展开" forState:UIControlStateNormal];
    }
    
}

- (void) ensureSelect:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:TRUE];
}

@end
