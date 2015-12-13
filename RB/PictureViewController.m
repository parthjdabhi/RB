//
//  PictureViewController.m
//  R&B
//
//  Created by hjc on 15/12/5.
//  Copyright © 2015年 hjc. All rights reserved.
//

#import "PictureViewController.h"
#import "IMFileHelper.h"

@interface PictureViewController ()

@end

@implementation PictureViewController

-(instancetype) init {
    self = [super init];
    
    [self initScrollView];
    
    return self;
}

-(instancetype) initWithImages:(NSMutableArray*) images index:(NSUInteger) index {
    
    _imgArr = images;
    _currentIndex = index;
    
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSMutableDictionary *dict = [_imgArr[_currentIndex] mutableCopy];
    NSString *path = [dict objectForKey:@"url"];
    if ([path hasPrefix:@"http"]) {
        NSString *key = [[path componentsSeparatedByString:@"/"] lastObject];
        NSString *downloadPath = [[IMFileHelper shareInstance] getThumbPathWithName:key];
        if (![[NSFileManager defaultManager] fileExistsAtPath:downloadPath]) {
            [IMFileHelper downloadFile:path path:downloadPath];
        }
        path = key;
    }
    _imgArr[_currentIndex] = dict;
    
    [self.navigationController setNavigationBarHidden:YES animated:TRUE];
    
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dissmissPicture:)]];
    
    [self refreshScrollView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) dissmissPicture:(NSNotification *)note {
    [self.navigationController popViewControllerAnimated:YES];
    [self.navigationController setNavigationBarHidden:NO animated:TRUE];
}

-(void) refreshScrollView {
    int imageCount = 0;
    signed int index = 0;
    
    for (int i = 0; i <= 2; i++) {
        index = _currentIndex+i-1;
        int offset = i;
        if (index>=0 && index < _imgArr.count && _imgArr[index]) {
            if (_currentIndex == 0) {
                offset--;
            }
            
            NSLog(@"x:%f", _scrollView.frame.origin.x+_scrollView.frame.size.width*offset);
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(_scrollView.frame.origin.x+_scrollView.frame.size.width*offset, _scrollView.frame.origin.y, _scrollView.frame.size.width, _scrollView.frame.size.height)];
            [imageView setContentMode: UIViewContentModeScaleAspectFit];
            NSString *url = [[IMFileHelper shareInstance] getPathWithName:[_imgArr[index] objectForKey:@"url"]];
            imageView.image = [UIImage imageWithContentsOfFile:url];

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
-(void) initScrollView{
//    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, _mViewFrame.origin.y, _mViewFrame.size.width, _mViewFrame.size.height)];        _scrollView.backgroundColor = [UIColor grayColor];
    [_scrollView setShowsVerticalScrollIndicator:NO];
    [_scrollView setShowsHorizontalScrollIndicator:NO];
    
    _scrollView.delegate = self;
    [self.view addSubview:_scrollView];
}

#pragma mark -- scrollView的代理方法
-(void) scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
