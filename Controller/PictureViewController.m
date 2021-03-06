//
//  PictureViewController.m
//  R&B
//
//  Created by hjc on 15/12/5.
//  Copyright © 2015年 hjc. All rights reserved.
//

#import "PictureViewController.h"
#import "IMFileHelper.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface PictureViewController ()

@end

@implementation PictureViewController

-(instancetype) init {
    self = [super init];
    
    [self initScrollView];
    
    return self;
}

-(instancetype) initWithImages:(NSMutableArray*) images index:(NSInteger) index {
    
    _imgArr = images;
    _currentIndex = index;
    
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationController setNavigationBarHidden:YES animated:TRUE];
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dissmissPicture:)]];
}

- (void)viewWillAppear:(BOOL)animated {
//    NSString *path = [_imgArr[_currentIndex] mutableCopy];
//    if ([path hasPrefix:@"http"]) {
//        NSString *key = [[path componentsSeparatedByString:@"/"] lastObject];
//        NSString *downloadPath = [[IMFileHelper shareInstance] getThumbPathWithName:key];
//        if (![[NSFileManager defaultManager] fileExistsAtPath:downloadPath]) {
//            [IMFileHelper downloadFile:path path:downloadPath];
//        }
//        path = key;
//    }
    [self refreshScrollView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) dissmissPicture:(NSNotification *)note {
    [self.navigationController popViewControllerAnimated:YES];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

-(void) refreshScrollView {
    int imageCount = 0;
    long index = 0;
    
    for (int i = 0; i <= 2; i++) {
        index = _currentIndex+i-1;
        int offset = i;
        if (index>=0 && index < _imgArr.count && _imgArr[index]) {
            if (_currentIndex == 0) {
                offset--;
            }
            
//            NSLog(@"x:%f", _scrollView.frame.origin.x+_scrollView.frame.size.width*offset);
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(_scrollView.frame.origin.x+_scrollView.frame.size.width*offset, _scrollView.frame.origin.y, _scrollView.frame.size.width, _scrollView.frame.size.height)];
            [imageView setContentMode: UIViewContentModeScaleAspectFit];
            
            NSURL *url = [NSURL URLWithString:_imgArr[index]];
            [imageView sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"avater_default.png"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                
            }];

            [_scrollView addSubview: imageView];
            imageCount++;
        }
    }
    
    if (imageCount > 1) {
        _scrollView.pagingEnabled = YES;
    }
    _scrollView.contentSize = CGSizeMake(_scrollView.frame.size.width * imageCount, _scrollView.frame.size.height);
    
    [_scrollView setContentOffset:CGPointMake(_scrollView.frame.origin.x+_scrollView.frame.size.width*(_currentIndex==0?0:1), 0) animated:YES];
//    NSLog(@"x:%f", _scrollView.frame.origin.x+_scrollView.frame.size.width*(_currentIndex==0?0:1));
}

#pragma mark -- 实例化ScrollView
-(void) initScrollView {
    [_scrollView setShowsVerticalScrollIndicator:NO];
    [_scrollView setShowsHorizontalScrollIndicator:NO];
    
    _scrollView.delegate = self;
    [self.view addSubview:_scrollView];
}

#pragma mark -- scrollView的代理方法
-(void) scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    [self scrollViewDidEndDecelerating:scrollView];
}

- (void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (_scrollView.contentOffset.x == 0) {
        _currentIndex--;
    } else {
        _currentIndex++;
    }
    [self refreshScrollView];
}

-(void) scrollViewDidScroll:(UIScrollView *)scrollView{
    if (_scrollView.contentOffset.x == 0) {
        _currentIndex--;
    } else {
        _currentIndex++;
    }
    [self refreshScrollView];
}

@end
