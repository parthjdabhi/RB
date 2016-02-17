//
//  MMessage.h
//  RB
//
//  Created by hjc on 16/2/9.
//  Copyright © 2016年 hjc. All rights reserved.
//

#define MESSAGE_TYPE_DIALOG 1
#define MESSAGE_TYPE_GROUP 2
#define MESSAGE_TYPE_NOTICE 3

#define MESSAGE_CONTENT_UNKNOWN 0
#define MESSAGE_CONTENT_TEXT 1
#define MESSAGE_CONTENT_AUDIO 2
#define MESSAGE_CONTENT_IMAGE 3

#define MESSAGE_STATUS_OK 0
#define MESSAGE_STATUS_UNSEND 1
#define MESSAGE_STATUS_ATTACH_UNUPLOAD 2

#import <Foundation/Foundation.h>

@interface MMessage : NSObject

@property(nonatomic) NSInteger senderId;
@property(nonatomic) NSInteger receiverId;
@property(nonatomic) BOOL isOutput;
@property(nonatomic) NSInteger type;
@property(nonatomic) NSInteger stamp;
@property(nonatomic) NSInteger contentType;
@property(nonatomic, copy) NSString *rawContent;
@property(nonatomic) NSInteger status;

@property NSString *text;

@property NSString *thumbUrl;
@property NSString *imageUrl;

@property NSString *audioUrl;
@property NSInteger duration;

-(void) packRawContent;

@end
