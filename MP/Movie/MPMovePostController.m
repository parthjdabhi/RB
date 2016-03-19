//
//  MPMovePostController.m
//  RB
//
//  Created by hjc on 16/3/16.
//  Copyright © 2016年 hjc. All rights reserved.
//

#import "MPMovePostController.h"

#import "IMDAO.h"

#import <SDWebImage/UIImageView+WebCache.h>

@interface MPMovePostController ()

@end

@implementation MPMovePostController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initData];
    [self initDisplayView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) initData {
    
    _moviePost = [[MPMoviePost alloc] init];
    
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
    
    NSArray *users = [[IMDAO shareInstance] getFriendsWithUid:[MUser currentUser].uid];
    _moviePost.partners = users;
    
    _moviePost.movie = movie;
}

-(void) initDisplayView {
    MPMovie *_movie = _moviePost.movie;
    
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
    
    [self.moviePartnerView setPartners:_moviePost.partners];
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

@end
