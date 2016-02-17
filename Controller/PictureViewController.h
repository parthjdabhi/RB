//
//  PictureViewController.h
//  R&B
//
//  Created by hjc on 15/12/5.
//  Copyright © 2015年 hjc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PictureViewController : UIViewController<UIScrollViewDelegate>

@property (strong, nonatomic) IBOutlet UIImageView *imageView;

@property (strong, nonatomic) NSMutableArray *imageViews;
@property NSString* imageUrl;
@property (assign) CGRect mViewFrame;
/**
 
 *  接收图片数组，数组类型可以是url数组，image数组
 
 */

@property (nonatomic,strong) NSMutableArray *imgArr;

/**
 
 *  显示scrollView
 
 */

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;

/**
 
 *  显示下标
 
 */

@property (nonatomic,strong) UILabel *sliderLabel;

/**
 
 *  接收当前图片的序号,默认的是0
 
 */

@property (nonatomic,assign) NSInteger currentIndex;

-(instancetype) initWithImages:(NSMutableArray*) images index:(NSInteger) index;

@end
