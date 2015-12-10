//
//  IMDAO.h
//  ByteBuffer
//
//  Created by hjc on 14-8-3.
//  Copyright (c) 2014年 hjc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"
#import "Friend.h"
#import "Dialog.h"
#import "Message.h"
#import "VoiceMessage.h"
#import "PictureMessage.h"

@interface IMDAO : NSObject

+(IMDAO *) shareInstance;

-(void) saveUser:(User *) user;
-(void) saveUsers:(NSArray *) users;
-(User *) getUserWithUid:(int) uid;

-(void) saveDialog:(Dialog *) dialog;
-(void) saveDialogs:(NSArray *) dialogs;
-(NSArray *) getDialogs;
-(Dialog *) getDiaglogWithUid:(unsigned int) uid;
-(void) updateDiaglog:(Dialog *) dialog;
-(void) deleteDialogWithId:(int) _id;

-(void) saveRecvMessage:(Message *) message;
-(void) saveRecvMessages:(NSArray *) messages;

-(void) saveSendMessage:(Message *) message;

-(NSArray *) getMessageWithUid:(int) uid;

-(int) getUnreadCountWithUid:(int) uid;
-(void) clearUnreadCountWithUid:(int) uid;

-(int) getUnreadCount;
-(void) setUnreadCount:(int) count;

-(void) saveFriend:(Friend *) f;
-(void) saveFriends:(NSArray<User *> *) arr;
-(NSArray *) getFriendsWithUid:(int) uid;
-(Friend *) getFriendWithId:(int) uid;

@end
