#import "IMVoiceMediaItem.h"

#import "JSQMessagesMediaPlaceholderView.h"
#import "JSQMessagesMediaViewBubbleImageMasker.h"

#import "UIImage+JSQMessages.h"
#import "UIColor+JSQMessages.h"


@interface IMVoiceMediaItem ()

@property (strong, nonatomic) UIView *cachedVoiceImageView;
@property (strong, nonatomic) UIView *playIconView;
@property (strong, nonatomic) UIView *voiceStatusView;

@end


@implementation IMVoiceMediaItem

#pragma mark - Initialization

- (instancetype)initWithFileURL:(NSURL *)fileURL duration:(NSInteger)duration {
    return [self initWithFileURL:fileURL duration:duration isUploading:FALSE];
}

- (instancetype)initWithFileURL:(NSURL *)fileURL duration:(NSInteger)duration isUploading:(BOOL) isUploading {
    self = [super init];
    if (self) {
        _fileURL = [fileURL copy];
        _duration = duration;
        _isPlaying = FALSE;
        _isUploading = isUploading;
        _cachedVoiceImageView = nil;
    }
    return self;
}

- (void)clearCachedMediaViews
{
    [super clearCachedMediaViews];
    _cachedVoiceImageView = nil;
}

- (void) play {
    _isPlaying = TRUE;
    [_playIconView.layer addAnimation:[self opacityForever_Animation:0.5] forKey:nil];
}

- (void) stopPlay {
    _isPlaying = FALSE;
    [_playIconView.layer removeAllAnimations];
}

- (void) didFinishUpload {
    _isUploading = FALSE;
    CGSize size = [self mediaViewDisplaySize];
    CGRect frame = CGRectMake(self.appliesMediaViewMaskAsOutgoing?-30:size.width, 0, 30, size.height);
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.text = [NSString stringWithFormat:@"%ld''", (long)self.duration];
    label.textColor = [UIColor grayColor];
    label.font = [UIFont systemFontOfSize:13];
    label.textAlignment = NSTextAlignmentCenter;
    label.backgroundColor = [UIColor clearColor];
    _voiceStatusView = label;
}

#pragma mark === 永久闪烁的动画 ======
-(CABasicAnimation *)opacityForever_Animation:(float)time
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];//必须写opacity才行。
    animation.fromValue = [NSNumber numberWithFloat:1.0f];
    animation.toValue = [NSNumber numberWithFloat:0.0f];//这是透明度。
    animation.autoreverses = YES;
    animation.duration = time;
    animation.repeatCount = MAXFLOAT;
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    animation.timingFunction=[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];///没有的话是均匀的动画。
    return animation;
}

#pragma mark - Setters

- (void)setFileURL:(NSURL *)fileURL
{
    _fileURL = [fileURL copy];
    _cachedVoiceImageView = nil;
}

- (void)setIsReadyToPlay:(BOOL)isReadyToPlay
{
    _isReadyToPlay = isReadyToPlay;
    _cachedVoiceImageView = nil;
}

- (void)setAppliesMediaViewMaskAsOutgoing:(BOOL)appliesMediaViewMaskAsOutgoing
{
    [super setAppliesMediaViewMaskAsOutgoing:appliesMediaViewMaskAsOutgoing];
    _cachedVoiceImageView = nil;
}


#pragma mark - JSQMessageMediaData protocol

- (UIView *)mediaView
{
    if (!_cachedVoiceImageView) {
        CGSize size = [self mediaViewDisplaySize];
        UIImage *playIcon = [UIImage imageNamed:self.appliesMediaViewMaskAsOutgoing?@"SenderVoiceNodePlaying":@"ReceiverVoiceNodePlaying"];
        _playIconView = [[UIImageView alloc] initWithImage:playIcon];
        _playIconView.frame = CGRectMake(self.appliesMediaViewMaskAsOutgoing?size.width-playIcon.size.width-20.0f:20.0f, (size.height-playIcon.size.height)/2, playIcon.size.width, playIcon.size.height);
//        _playIconView.contentMode = UIViewContentModeCenter;
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, size.width, size.height)];
        [imageView addSubview:_playIconView];
        imageView.backgroundColor = self.appliesMediaViewMaskAsOutgoing?[UIColor jsq_messageBubbleGreenColor]:[UIColor jsq_messageBubbleLightGrayColor];
        imageView.clipsToBounds = YES;
        [JSQMessagesMediaViewBubbleImageMasker applyBubbleImageMaskToMediaView:imageView isOutgoing:self.appliesMediaViewMaskAsOutgoing];
        
        if (self.isUploading) {
            UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            indicator.frame = CGRectMake(self.appliesMediaViewMaskAsOutgoing?-30:size.width, 0, 30, size.height);
            [indicator startAnimating];
            _voiceStatusView = indicator;
        } else {
            [self didFinishUpload];
        }
        
        UIView *returnView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
        [returnView addSubview:imageView];
        [returnView addSubview:_voiceStatusView];
        _cachedVoiceImageView = returnView;
    }
    
    return _cachedVoiceImageView;
}

- (CGSize)mediaViewDisplaySize
{
    //根据语音长度
    float minwidth = 66;
    float width = minwidth;
    if (self.duration < 3) {
    } else if (self.duration < 7) {
        width += (self.duration-3)*25;
    } else if (self.duration < 15) {
        width += 3*25 + (self.duration-6)*10;
    } else {
        width += 3*25 + 90;
    }
    
    return CGSizeMake(width, 42.0f);
}

- (NSUInteger)mediaHash
{
    return self.hash;
}

#pragma mark - NSObject

- (BOOL)isEqual:(id)object
{
    if (![super isEqual:object]) {
        return NO;
    }
    
    IMVoiceMediaItem *voiceItem = (IMVoiceMediaItem *)object;
    
    return [self.fileURL isEqual:voiceItem.fileURL]
            && self.duration == voiceItem.duration;
}

- (NSUInteger)hash
{
    return super.hash ^ self.fileURL.hash;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: fileURL=%@, isReadyToPlay=%@, appliesMediaViewMaskAsOutgoing=%@>",
            [self class], self.fileURL, @(self.isReadyToPlay), @(self.appliesMediaViewMaskAsOutgoing)];
}

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        _fileURL = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(fileURL))];
        _isReadyToPlay = [aDecoder decodeBoolForKey:NSStringFromSelector(@selector(isReadyToPlay))];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.fileURL forKey:NSStringFromSelector(@selector(fileURL))];
    [aCoder encodeBool:self.isReadyToPlay forKey:NSStringFromSelector(@selector(isReadyToPlay))];
}

#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone
{
    IMVoiceMediaItem *copy = [[[self class] allocWithZone:zone] initWithFileURL:self.fileURL duration:self.duration];
    copy.appliesMediaViewMaskAsOutgoing = self.appliesMediaViewMaskAsOutgoing;
    return copy;
}

@end
