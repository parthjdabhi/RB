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
#import "Group.h"
#import "Dialog.h"
#import "Message.h"
#import "VoiceMessage.h"
#import "PictureMessage.h"
#import "IMNotification.h"

@interface IMDAO : NSObject

+(IMDAO *) shareInstance;

-(void) saveUser:(User *) user;
-(void) saveUsers:(NSArray *) users;
-(NSArray *) getUsersWithUid:(int) uid;
-(User *) getUserWithUid:(int) uid;

#pragma mark dialog
-(void) saveDialog:(Dialog *) dialog;
-(void) saveDialogs:(NSArray *) dialogs;
-(NSArray *) getDialogs;
-(Dialog *) getDiaglogWithUid:(unsigned int) uid;
-(void) updateDiaglog:(Dialog *) dialog;
-(void) deleteDialogWithId:(int) _id;

#pragma mark message
-(void) saveRecvMessage:(Message *) message;
-(void) saveRecvMessages:(NSArray *) messages;
-(void) saveSendMessage:(Message *) message;

-(NSArray *) getMessageWithUid:(int) uid;
-(NSArray *) getMessageWithGid:(int) gid;

-(void) saveRecvNotification:(IMNotification *) message;

#pragma mark unread message count
-(int) getUnreadCountWithUid:(int) uid;
-(void) clearUnreadCountWithUid:(int) uid;
-(int) getUnreadCountWithGid:(int) gid;
-(void) clearUnreadCountWithGid:(int) gid;

-(int) getMsgUnreadCount;
-(void) setMsgUnreadCount:(int) count;
-(int) getNoticeUnreadCount;
-(void) setNoticeUnreadCount:(int) count;

#pragma mark friend
-(void) saveFriend:(Friend *) f;
-(void) saveFriends:(NSArray<User *> *) arr;
-(NSArray *) getFriendsWithUid:(int) uid;
-(Friend *) getFriendWithId:(int) uid;
-(void) delFriendWithId:(int) uid;

#pragma mark group
-(void) saveGroup:(Group *) f;
-(void) saveGroups:(NSArray<Group *> *) arr;
-(NSArray *) getGroupsWithUid:(int) uid;
-(Group *) getGroupWithId:(int) uid;
-(void) addMembers:(NSArray *) members ToGid:(int) gid;

#pragma mark make friend record
-(void) saveMakeFriendRecord:(User *) user;
-(void) updateMakeFriendRecord:(User *) user;
-(NSArray *) getMakeFriendRecordsByUid:(int) uid;
-(void) delMakeFriendRecordWithId:(int) uid;

@end
