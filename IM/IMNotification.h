//
//  IMNotification.h
//  RB
//
//  Created by hjc on 15/12/17.
//  Copyright © 2015年 hjc. All rights reserved.
//

#import "Message.h"

@interface IMNotification : Message

// 通知类型,
// 好友通知：0默认，1请求添加，2同意，3删除
// 群通知:10默认，11创建，12邀请，13移除，14解散，15退出，16修改群名称
@property(nonatomic, assign) int32_t uid;
@property(nonatomic, assign) int32_t gid;

-(instancetype) initWithFrom:(int32_t) from
                          to:(int32_t) to
                      target:(int32_t) target
                        type:(Byte) messageType
                       stamp:(int64_t) stamp
                 contentType:(int32_t) contentType
              messageContent:(NSString *) messageContent
                         uid:(int32_t) uid;

-(instancetype) initWithFrom:(int32_t) from
                          to:(int32_t) to
                      target:(int32_t) target
                        type:(Byte) messageType
                       stamp:(int64_t) stamp
                 contentType:(int32_t) contentType
              messageContent:(NSString *) messageContent
                         gid:(int32_t) gid;

+(instancetype) initWithMessage:(Message *) message;

@end
