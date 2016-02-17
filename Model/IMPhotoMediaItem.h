//
//  IMPhotoMediaItem.h
//  RB
//
//  Created by hjc on 16/1/28.
//  Copyright © 2016年 hjc. All rights reserved.
//

#import "JSQMediaItem.h"

@interface IMPhotoMediaItem : JSQMediaItem<JSQMessageMediaData, NSCoding, NSCopying>

@property (nonatomic, strong) NSURL *fileURL;
@property (nonatomic, strong) NSURL *thumbURL;
@property BOOL isUploading;

- (instancetype)initWithFileURL:(NSURL *)fileURL;
- (instancetype)initWithThumbURL:(NSURL *)fileURL;
- (instancetype)initWithImage:(UIImage *) image isUploading:(BOOL) isUploading;
- (void) didFinishUpload;

@end
