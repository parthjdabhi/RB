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
@property unsigned int uid;
@property unsigned int gid;

-(instancetype) initWithFrom:(unsigned int) from
                          to:(unsigned int) to
                      target:(unsigned int) target
                        type:(Byte) messageType
                       stamp:(long long) stamp
                 contentType:(unsigned int) contentType
              messageContent:(NSString *) messageContent
                         uid:(unsigned int) uid;

-(instancetype) initWithFrom:(unsigned int) from
                          to:(unsigned int) to
                      target:(unsigned int) target
                        type:(Byte) messageType
                       stamp:(long long) stamp
                 contentType:(unsigned int) contentType
              messageContent:(NSString *) messageContent
                         gid:(unsigned int) gid;

+(instancetype) initWithMessage:(Message *) message;

@end
