//
//  IMPhotoMediaItem.m
//  RB
//
//  Created by hjc on 16/1/28.
//  Copyright © 2016年 hjc. All rights reserved.
//

#import "IMPhotoMediaItem.h"
#import "JSQMessagesMediaPlaceholderView.h"
#import "JSQMessagesMediaViewBubbleImageMasker.h"

#import "MBProgressHUD.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "UIImage+ResizeMagick.h"

@interface IMPhotoMediaItem ()

@property (strong, nonatomic) UIView *cachedView;
@property (strong, nonatomic) UIImageView *cachedImageView;
@property (strong, nonatomic) UIImage *image;

@end

@implementation IMPhotoMediaItem

- (instancetype)initWithFileURL:(NSURL *)fileURL {
    self = [super init];
    if (self) {
        _fileURL = fileURL;
        _cachedView = nil;
        self.isUploading = FALSE;
    }
    return self;
}

- (instancetype)initWithThumbURL:(NSURL *)fileURL {
    self = [super init];
    if (self) {
        _thumbURL = fileURL;
        _cachedView = nil;
        self.isUploading = FALSE;
    }
    return self;
}

- (instancetype)initWithImage:(UIImage *) image isUploading:(BOOL) isUploading {
    self = [super init];
    if (self) {
        self.image = image;
        self.isUploading = isUploading;
    }
    return self;
}

#pragma mark - Setters

- (void)setAppliesMediaViewMaskAsOutgoing:(BOOL)appliesMediaViewMaskAsOutgoing
{
    [super setAppliesMediaViewMaskAsOutgoing:appliesMediaViewMaskAsOutgoing];
    _cachedView = nil;
}

- (UIView *)mediaView
{
//    if (self.image == nil) {
//        return nil;
//    }
    
    if (self.cachedImageView) {
        return self.cachedImageView;
    }
    
    if (self.image != nil) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 210, 150)];        
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.image = [self.image resizedImageWithMaximumSize:CGSizeMake(210.0f, 150.0f)];
//        [imageView setBackgroundColor:[UIColor blackColor]];
//        imageView.clipsToBounds = YES;
        
        if (self.isUploading) {
            [MBProgressHUD showHUDAddedTo:imageView animated:YES];
        } else {
            [MBProgressHUD hideHUDForView:imageView animated:YES];
        }
        
        [JSQMessagesMediaViewBubbleImageMasker applyBubbleImageMaskToMediaView:imageView isOutgoing:self.appliesMediaViewMaskAsOutgoing];

        self.cachedImageView = imageView;
        
    } else if (self.thumbURL) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 210, 150)];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        [imageView sd_setImageWithURL:[NSURL URLWithString:self.thumbURL.absoluteString]
                            completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {                    
                                self.image = [image resizedImageWithMaximumSize:CGSizeMake(210.0f, 150.0f)];
                                
//                                CGSize size = CGSizeMake(210.0f, 150.0f);
//                                int width = self.image.size.width;
//                                int height = self.image.size.height;
//                                
//                                if (height > size.height) {
//                                    width = size.height / self.image.size.height * self.image.size.width;
//                                    height = size.height;
//                                }
//                                
//                                if (width > size.width) {
//                                    height = size.width / self.image.size.width * self.image.size.height;
//                                    width = size.width;
//                                }
//                                
//                                int x = self.appliesMediaViewMaskAsOutgoing?size.width-width:0;
//                                imageView.frame = CGRectMake(x, 0, width, height);
//                                imageView.bounds = CGRectMake(x, 0, width, height);
//                                imageView.contentMode = UIViewContentModeScaleAspectFit;
                                
                                [JSQMessagesMediaViewBubbleImageMasker applyBubbleImageMaskToMediaView:imageView isOutgoing:self.appliesMediaViewMaskAsOutgoing];
                            }];
        
        self.cachedImageView = imageView;
    }

    return self.cachedImageView;
}

//-(CGSize)onScreenPointSizeOfImageInImageView:(UIImageView *)imageView {
//    CGFloat scale;
//    if (imageView.frame.size.width > imageView.frame.size.height) {
//        if (imageView.image.size.width > imageView.image.size.height) {
//            scale = imageView.image.size.height / imageView.frame.size.height;
//        } else {
//            scale = imageView.image.size.width / imageView.frame.size.width;
//        }
//    } else {
//        if (imageView.image.size.width > imageView.image.size.height) {
//            scale = imageView.image.size.width / imageView.frame.size.width;
//        } else {
//            scale = imageView.image.size.height / imageView.frame.size.height;
//        }
//    }
//    return CGSizeMake(imageView.image.size.width / scale, imageView.image.size.height / scale);
//}

- (void) didFinishUpload {
    [MBProgressHUD hideHUDForView:self.cachedImageView animated:YES];
}

- (NSUInteger)mediaHash
{
    return self.hash;
}

#pragma mark - NSObject

- (NSUInteger)hash
{
    return super.hash ^ self.fileURL.hash;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: image=%@, appliesMediaViewMaskAsOutgoing=%@>",
            [self class], self.fileURL, @(self.appliesMediaViewMaskAsOutgoing)];
}

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        _fileURL = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(fileURL))];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.fileURL forKey:NSStringFromSelector(@selector(fileURL))];
}

#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone
{
    IMPhotoMediaItem *copy = [[IMPhotoMediaItem allocWithZone:zone] initWithFileURL:self.fileURL];
    copy.appliesMediaViewMaskAsOutgoing = self.appliesMediaViewMaskAsOutgoing;
    return copy;
}


@end
