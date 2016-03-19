//
//  IMDAO.h
//  ByteBuffer
//
//  Created by hjc on 14-8-3.
//  Copyright (c) 2014年 hjc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MUser.h"
#import "MFriend.h"
#import "MGroup.h"
#import "MDialog.h"
#import "Message.h"
#import "MMessage.h"
#import "VoiceMessage.h"
#import "PictureMessage.h"
#import "IMNotification.h"

@interface IMDAO : NSObject

+(IMDAO *) shareInstance;

-(void) saveUser:(MUser *) user;
-(void) saveUsers:(NSArray *) users;
-(NSArray *) getUsersWithUid:(NSInteger) uid;
-(MUser *) getUserWithUid:(NSInteger) uid;

#pragma mark dialog
-(void) saveDialog:(MDialog *) dialog;
-(void) saveDialogs:(NSArray *) dialogs;
-(NSArray *) getDialogs;
-(MDialog *) getDiaglogWithUid:(NSInteger) uid;
-(void) updateDiaglog:(MDialog *) dialog;
-(void) deleteDialogWithId:(NSInteger) _id;

#pragma mark message
-(void) saveRecvMessage:(Message *) message;
-(void) saveRecvMessages:(NSArray *) messages;
-(void) saveSendMessage:(Message *) message;

-(void) saveMessage:(MMessage *) message;
-(void) updateMessage:(MMessage *) message;
-(void) deleteMessage:(MMessage *) message;

-(NSArray *) getMessageWithUid:(NSInteger) uid;
-(NSArray *) getMessageWithGid:(NSInteger) gid;

-(void) saveRecvNotification:(IMNotification *) message;

#pragma mark unread message count
-(int) getUnreadCountWithUid:(NSInteger) uid;
-(void) clearUnreadCountWithUid:(NSInteger) uid;
-(int) getUnreadCountWithGid:(NSInteger) gid;
-(void) clearUnreadCountWithGid:(NSInteger) gid;

-(int) getMsgUnreadCount;
-(void) setMsgUnreadCount:(int) count;
-(int) getNoticeUnreadCount;
-(void) setNoticeUnreadCount:(int) count;

#pragma mark friend
-(void) saveFriend:(MFriend *) f;
-(void) saveFriends:(NSArray<MUser *> *) arr;
-(NSArray *) getFriendsWithUid:(NSInteger) uid;
-(MFriend *) getFriendWithId:(NSInteger) uid;
-(void) updateFriend:(MFriend *) f;
-(void) delFriendWithId:(NSInteger) uid;

#pragma mark group
-(void) saveGroup:(MGroup *) f;
-(void) saveGroups:(NSArray<MGroup *> *) arr;
-(NSArray *) getGroupsWithUid:(NSInteger) uid;
-(MGroup *) getGroupWithId:(NSInteger) uid;
-(void) addMembers:(NSArray *) members ToGid:(NSInteger) gid;
-(void) deleteGroupWithId:(NSInteger) gid;
-(void) quitGroupWithUid:(NSInteger) uid Gid:(NSInteger) gid;

#pragma mark make friend record
-(void) saveMakeFriendRecord:(MUser *) user;
-(void) updateMakeFriendRecord:(MUser *) user;
-(NSArray *) getMakeFriendRecordsByUid:(NSInteger) uid;
-(void) delMakeFriendRecordWithId:(NSInteger) uid;

#pragma mark account
-(void) login:(MUser *) user;
-(MUser *) getLoginUser;
-(void) logout;

-(void) updateUser:(MUser *) user;

-(MUser *) getDemoUser;

@end
