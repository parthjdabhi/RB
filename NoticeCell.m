#import "NoticeCell.h"
#import "IMFileHelper.h"
#import <QuartzCore/QuartzCore.h>

@implementation NoticeCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _noticeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 375, 0)];
        [self.contentView addSubview:_noticeLabel];
    }
    return self;
}

- (void) initWithData:(NSMutableDictionary *) dict {
    _noticeLabel.text = [dict objectForKey:@"stamp"];
    CGSize size = [_noticeLabel.text sizeWithAttributes:
                       @{NSFontAttributeName: [UIFont systemFontOfSize:13.0f]}];
    _noticeLabel.backgroundColor = [UIColor lightGrayColor];
    _noticeLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:13];
    _noticeLabel.layer.cornerRadius = 3;
    _noticeLabel.clipsToBounds = YES;
    _noticeLabel.frame = CGRectMake(0, 0, size.width, size.height);
    [_noticeLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_noticeLabel
                                                                 attribute:NSLayoutAttributeCenterX
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeCenterX
                                                                multiplier:1.0f
                                                                  constant:00.0f]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_noticeLabel
                                                                 attribute:NSLayoutAttributeCenterY
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeCenterY
                                                                multiplier:1.0f
                                                                  constant:00.0f]];
}

@end
