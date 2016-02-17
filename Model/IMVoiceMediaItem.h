#import "JSQMediaItem.h"

@interface IMVoiceMediaItem : JSQMediaItem <JSQMessageMediaData, NSCoding, NSCopying>

@property (nonatomic, strong) NSURL *fileURL;

@property (nonatomic, assign) NSInteger duration;

@property (nonatomic, assign) BOOL isPlaying;
@property (nonatomic, assign) BOOL isUploading;

/**
 *  A boolean value that specifies whether or not the video is ready to be played.
 * 
 *  @discussion When set to `YES`, the video is ready. When set to `NO` it is not ready.
 */
@property (nonatomic, assign) BOOL isReadyToPlay;

- (instancetype)initWithFileURL:(NSURL *)fileURL duration:(NSInteger)duration;
- (instancetype)initWithFileURL:(NSURL *)fileURL duration:(NSInteger)duration isUploading:(BOOL) isUploading;

- (void) play;
- (void) stopPlay;
- (void) didFinishUpload;

@end
