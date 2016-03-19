//
//  IMDAO.m
//  ByteBuffer
//
//  Created by hjc on 14-8-3.
//  Copyright (c) 2014年 hjc. All rights reserved.
//

#import "IMDAO.h"
#import "FMDatabase.h"

@interface IMDAO()
{
    FMDatabase *commonDB;
    FMDatabase *userDB;
}

@end

@implementation IMDAO

static IMDAO *sharedInstance;

+(IMDAO *) shareInstance
{
    static BOOL initialized = NO;
	if (!initialized)
	{
		initialized = YES;
		
		sharedInstance = [[IMDAO alloc] init];
	}
    
    return sharedInstance;
}

-(id) init
{
    self = [super init];
    
    [self initCommonDB];
    [self initUserDB];
    
    return self;
}

-(void) initUserDB
{
    userDB = [FMDatabase databaseWithPath:[self userDBPath]];
    [userDB open];
    
    NSString *profileTableSql = @"CREATE TABLE IF NOT EXISTS profile(key VARCHAR(50), val VARCHAR(500));";
    [userDB executeUpdate:profileTableSql];
    
    NSString *dialogTableSql = @"CREATE TABLE IF NOT EXISTS dialog(uid integer, name VARCHAR(50), description VARCHAR(100), type integer, avater VARCHAR(200), is_read interger, unread_count integer, stamp TIMESTAMP)";
    [userDB executeUpdate:dialogTableSql];
    
    NSString *table = @"user";
    NSString *userTableSql = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (uid integer, nickname VARCHAR(50), avater_url VARCHAR(200), signature VARCHAR(200), stamp TIMESTAMP)", table];
    [userDB executeUpdate:userTableSql];
    
    NSString *friendTableSql = @"CREATE TABLE IF NOT EXISTS friend(uid integer, comment_name VARCHAR(50), stamp TIMESTAMP);";
    [userDB executeUpdate:friendTableSql];
    
    NSString *newfriendTableSql = @"CREATE TABLE IF NOT EXISTS newfriend(uid integer, nickname VARCHAR(50), comment VARCHAR(50), source integer, is_friend integer, stamp TIMESTAMP);";
    [userDB executeUpdate:newfriendTableSql];
    
    NSString *groupTableSql = @"CREATE TABLE IF NOT EXISTS group_info(id integer, name VARCHAR(50), avater_url VARCHAR(200), master_id integer, members text, stamp TIMESTAMP);";
    [userDB executeUpdate:groupTableSql];
}

-(void) initCommonDB
{
    commonDB = [FMDatabase databaseWithPath:[self commonDBPath]];
    [commonDB open];
    
    NSString *profileTableSql = @"CREATE TABLE IF NOT EXISTS login_info(key VARCHAR(50), val VARCHAR(500));";
    [commonDB executeUpdate:profileTableSql];
}

-(NSString *) commonDBPath
{
    return [NSString stringWithFormat:@"%@/Documents/%@", NSHomeDirectory(), @"common.sqlite"];
}

-(NSString *) userDBPath
{
    return [NSString stringWithFormat:@"%@/Documents/user_%ld%@", NSHomeDirectory(), (long)[MUser currentUser].uid, @".sqlite"];
}

#pragma mark user

-(void) saveUser:(MUser *) user
{
    if (![self getUserWithUid:user.uid]) {        
        NSString *sql = @"INSERT INTO user (uid, nickname, avater_url, signature) VALUES (?,?,?,?)";
        [userDB executeUpdate:sql, [NSNumber numberWithInteger:user.uid], user.nickname, user.avatarUrl, user.signature];
    } else {
        NSString *sql = @"UPDATE user set nickname=?,avater_url=?,signature=? WHERE uid=?";
        [userDB executeUpdate:sql, user.nickname, user.avatarUrl, user.signature, [NSNumber numberWithInteger:user.uid]];
    }
}
-(void) saveUsers:(NSArray<MUser *> *) users
{
    for (MUser *u in users) {
        [self saveUser:u];
    }
}

-(NSArray *) getUsersWithUid:(NSInteger) uid {
    NSString *sql = @"SELECT * FROM user";
    FMResultSet *res = [userDB executeQuery:sql];
    
    NSMutableArray *arr = [NSMutableArray array];
    
    while ([res next])
    {
        MUser *user = [[MUser alloc] init];
        user.uid = [res intForColumn:@"uid"];
        user.nickname = [res stringForColumn:@"nickname"];
        user.avatarUrl = [res stringForColumn:@"avater_url"];
        user.signature = [res stringForColumn:@"signature"];
        
        [arr addObject:user];
    }
    
    return arr;
}

-(MUser *) getUserWithUid:(NSInteger) uid {
    NSString *sql = @"SELECT * FROM user WHERE uid=?";
    FMResultSet *res = [userDB executeQuery:sql, [NSNumber numberWithInteger:uid]];
    
    MUser *user = nil;
    
    while ([res next])
    {
        user = [[MUser alloc] init];
        user.uid = [res intForColumn:@"uid"];
        user.nickname = [res stringForColumn:@"nickname"];
        user.avatarUrl = [res stringForColumn:@"avater_url"];
        user.signature = [res stringForColumn:@"signature"];
    }
    
    return user;
}

#pragma mark dialog

-(void) saveDialog:(MDialog *) dialog
{
    NSString *sql = @"INSERT INTO dialog (uid, name, description, type, avater, is_read, unread_count, stamp) VALUES (?,?,?,?,?,?,?,?)";
    [userDB executeUpdate:sql, @(dialog.uid), dialog.name, dialog.desc, @(dialog.type), dialog.avatar, [NSNumber numberWithUnsignedInt:dialog.unreadCount>0?0:1], [NSNumber numberWithUnsignedInt:dialog.unreadCount], [NSNumber numberWithUnsignedLongLong:dialog.stamp/1000]];
}

-(void) saveDialogs:(NSArray *) dialogs
{
    
}

-(void) deleteDialogWithId:(NSInteger) _id
{
    [userDB executeUpdate:[NSString stringWithFormat:@"delete FROM dialog where uid=%ld", (long)_id]];
    [userDB executeUpdate:[NSString stringWithFormat:@"drop table msg_%ld", (long)_id]];
}

-(NSArray *) getDialogs
{
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM dialog ORDER BY is_read ASC, stamp DESC"];
    FMResultSet *res = [userDB executeQuery:sql];
    
    NSMutableArray *arr = [NSMutableArray array];
    MDialog *dialog = nil;
    
    while ([res next])
    {
        dialog = [[MDialog alloc] init];
        dialog.uid = [res intForColumn:@"uid"];
        dialog.name = [res stringForColumn:@"name"];
        dialog.desc = [res stringForColumn:@"description"];
        dialog.type = [res intForColumn:@"type"];
        dialog.avatar = [res stringForColumn:@"avater"];
        dialog.unreadCount = [res intForColumn:@"unread_count"];
        dialog.stamp = [res longLongIntForColumn:@"stamp"];
        [arr addObject:dialog];
    }
    
    return arr;
}

-(MDialog *) getDiaglogWithUid:(NSInteger) uid
{
    NSString *sql = @"SELECT * FROM dialog WHERE uid=? and type=1";
    FMResultSet *res = [userDB executeQuery:sql, [NSNumber numberWithInteger:uid]];
    
    MDialog *dialog = nil;
    
    while ([res next])
    {
        dialog = [[MDialog alloc] init];
        dialog.uid = [res intForColumn:@"uid"];
        dialog.name = [res stringForColumn:@"name"];
        dialog.desc = [res stringForColumn:@"description"];
        dialog.type = [res intForColumn:@"type"];
        dialog.avatar = [res stringForColumn:@"avater"];
        dialog.unreadCount = [res intForColumn:@"unread_count"];
        dialog.stamp = [res longLongIntForColumn:@"stamp"];
    }
    
    return dialog;
}

-(MDialog *) getDiaglogWithGid:(NSInteger) gid
{
    NSString *sql = @"SELECT * FROM dialog WHERE uid=? and type=2";
    FMResultSet *res = [userDB executeQuery:sql, [NSNumber numberWithInteger:gid]];
    
    MDialog *dialog = nil;
    
    while ([res next])
    {
        dialog = [[MDialog alloc] init];
        dialog.uid = [res intForColumn:@"uid"];
        dialog.name = [res stringForColumn:@"name"];
        dialog.desc = [res stringForColumn:@"description"];
        dialog.type = [res intForColumn:@"type"];
        dialog.avatar = [res stringForColumn:@"avater"];
        dialog.unreadCount = [res intForColumn:@"unread_count"];
        dialog.stamp = [res longLongIntForColumn:@"stamp"];
    }
    
    return dialog;
}

-(void) updateDiaglog:(MDialog *) dialog
{
    NSString *sql = @"UPDATE dialog SET name=?, description=?, type=?, avater=?, unread_count=?, stamp=? WHERE uid=?";
    [userDB executeUpdate:sql, dialog.name, dialog.description, @(dialog.type), dialog.avatar, [NSNumber numberWithUnsignedInt:dialog.unreadCount], [NSNumber numberWithUnsignedLongLong:dialog.stamp/1000], @(dialog.uid)];
}

#pragma mark message

-(void) saveRecvMessage:(Message *) message
{
    int uid = message.from;
    NSString *table = [NSString stringWithFormat:@"msg_%d", uid];
    if (message.messageType == 2) {
        uid = message.to;
        table = [NSString stringWithFormat:@"msg_g%d", message.to];
    }
    
    NSString *messageTableSql = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (fid integer, tid integer, type integer, ct integer, content VARCHAR(1000), stamp TIMESTAMP)", table];
    [userDB executeUpdate:messageTableSql];
    
    NSString *sql = [NSString stringWithFormat:@"INSERT INTO %@ (fid, tid, type, ct, content, stamp) VALUES (?,?,?,?,?,?)", table];
    [userDB executeUpdate:sql, [NSNumber numberWithUnsignedInt:message.from], [NSNumber numberWithUnsignedInt:message.to], [NSNumber numberWithUnsignedInt:message.messageType], [NSNumber numberWithUnsignedInt:message.contentType], message.messageBody, [NSNumber numberWithUnsignedLongLong:message.stamp/1000]];
    
//    NSString *description = message.messageContent;
//    if (message.contentType == 2) {
//        description = @"[语音]";
//    } else if(message.contentType == 3) {
//        description = @"[图片]";
//    }
//    
//    MDialog *dialog = nil;
//    if (message.messageType == 2) {
//        dialog = [self getDiaglogWithGid:uid];
//    } else {
//        dialog = [self getDiaglogWithUid:uid];
//    }
//    
//    if (dialog == nil) {
//        NSString *dialogName = nil;
//        if (message.messageType == 2) {
//            dialogName = [self getGroupWithId:uid].name;
//        } else {
//            dialogName = [self getUserWithUid:uid].nickname;
//        }
//        
//        dialog = [[MDialog alloc] init];
//        dialog.uid = uid;
//        dialog.name = dialogName;
//        dialog.desc = description;
//        dialog.unreadCount = 1;
//        dialog.type = message.messageType;
//        dialog.stamp = message.stamp;
//        [self saveDialog:dialog];
//    } else {
//        sql = @"UPDATE dialog SET description=?, is_read=0, unread_count=unread_count+1, stamp=? WHERE uid=? and type=?";
//        [userDB executeUpdate:sql, description, [NSNumber numberWithUnsignedLongLong:message.stamp/1000], [NSNumber numberWithUnsignedInt:uid], [NSNumber numberWithUnsignedInt:message.messageType]];
//    }
}


-(void) saveRecvMessages:(NSArray *) messages
{
}

-(void) saveSendMessage:(Message *) message
{
    int uid = message.to;
    NSString *table = [NSString stringWithFormat:@"msg_%d", uid];
    if (message.messageType == 2) {
        table = [NSString stringWithFormat:@"msg_g%d", message.to];
    }
    
    NSString *messageTableSql = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (fid integer, tid integer, type integer, ct integer, content VARCHAR(1000), stamp TIMESTAMP)", table];
    [userDB executeUpdate:messageTableSql];
    
    NSString *sql = [NSString stringWithFormat:@"INSERT INTO %@ (fid, tid, type, ct, content, stamp) VALUES (?,?,?,?,?,?)", table];
    [userDB executeUpdate:sql, [NSNumber numberWithUnsignedInt:message.from], [NSNumber numberWithUnsignedInt:message.to], [NSNumber numberWithUnsignedInt:message.messageType], [NSNumber numberWithUnsignedInt:message.contentType], message.messageBody, [NSNumber numberWithUnsignedLongLong:message.stamp/1000]];
    
//    NSString *description = message.messageContent;
//    if (message.contentType == 2) {
//        description = @"[语音]";
//    } else if(message.contentType == 3) {
//        description = @"[图片]";
//    }
//    
//    MDialog *dialog = nil;
//    if (message.messageType == 2) {
//        dialog = [self getDiaglogWithGid:uid];
//    } else {
//       dialog = [self getDiaglogWithUid:uid];
//    }
//    
//    if (dialog == nil) {
//        NSString *dialogName = nil;
//        if (message.messageType == 2) {
//            dialogName = [self getGroupWithId:uid].name;
//        } else {
//            dialogName = [self getUserWithUid:uid].nickname;
//        }
//        dialog = [[MDialog alloc] init];
//        dialog.uid = uid;
//        dialog.name = dialogName;
//        dialog.desc = description;
//        dialog.unreadCount = 0;
//        dialog.type = message.messageType;
//        dialog.stamp = message.stamp;
//        [self saveDialog:dialog];
//    } else {            
//        sql = @"UPDATE dialog SET description=?, stamp=? WHERE uid=? and type=?";
//        [userDB executeUpdate:sql, description, [NSNumber numberWithUnsignedLongLong:message.stamp/1000], [NSNumber numberWithUnsignedInt:uid], [NSNumber numberWithUnsignedInt:message.messageType]];
//    }
    
}

-(void) saveMessage:(MMessage *) message
{
    NSInteger uid = message.isOutput?message.receiverId:message.senderId;
    
    NSString *table;
    if (message.type == MESSAGE_TYPE_DIALOG) {
        table = [NSString stringWithFormat:@"mmsg_%ld", (long)uid];
    } else if (message.type == MESSAGE_TYPE_GROUP) {
        uid = message.receiverId;
        table = [NSString stringWithFormat:@"mmsg_g%ld", (long)uid];
    } else {
        return;
    }
    
    NSString *createTableSql = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (sender_id integer, receiver_id integer, content_type integer, content VARCHAR(1000), status integer, stamp TIMESTAMP)", table];
    [userDB executeUpdate:createTableSql];
    
    NSString *sql = [NSString stringWithFormat:@"INSERT INTO %@ (sender_id, receiver_id, content_type, content, status, stamp) VALUES (?,?,?,?,?,?)", table];
    [message packRawContent];
    [userDB executeUpdate:sql, @(message.senderId), @(message.receiverId), @(message.contentType), message.rawContent, @(message.status), @(message.stamp)];
    
    NSString *description = message.text;
    if (message.contentType == MESSAGE_CONTENT_AUDIO) {
        description = @"[语音]";
    } else if(message.contentType == MESSAGE_CONTENT_IMAGE) {
        description = @"[图片]";
    }
    
    MDialog *dialog = nil;
    if (message.type == MESSAGE_TYPE_GROUP) {
        dialog = [self getDiaglogWithGid:uid];
    } else {
        dialog = [self getDiaglogWithUid:uid];
    }
    
    if (dialog == nil) {
        NSString *dialogName = nil;
        if (message.type == MESSAGE_TYPE_GROUP) {
            dialogName = [self getGroupWithId:uid].name;
        } else {
            dialogName = [self getUserWithUid:uid].nickname;
        }
        dialog = [[MDialog alloc] init];
        dialog.uid = uid;
        dialog.name = dialogName;
        dialog.desc = description;
        dialog.unreadCount = 0;
        dialog.type = message.type;
        dialog.stamp = message.stamp;
        [self saveDialog:dialog];
    } else {
        if (message.isOutput) {
            sql = @"UPDATE dialog SET description=?, stamp=? WHERE uid=? and type=?";
        } else {
            sql = @"UPDATE dialog SET description=?, is_read=0, unread_count=unread_count+1, stamp=? WHERE uid=? and type=?";
        }

        [userDB executeUpdate:sql, description, @(message.stamp), @(uid), @(message.type)];
    }
}

-(void) updateMessage:(MMessage *) message {
    NSInteger uid = message.isOutput?message.receiverId:message.senderId;
    
    NSString *table;
    if (message.type == MESSAGE_TYPE_DIALOG) {
        table = [NSString stringWithFormat:@"mmsg_%ld", (long)uid];
    } else if (message.type == MESSAGE_TYPE_GROUP) {
        uid = message.receiverId;
        table = [NSString stringWithFormat:@"mmsg_g%ld", (long)uid];
    } else {
        return;
    }
    
    if (!message.stamp) {
        return;
    }
    
    NSString *sql = [NSString stringWithFormat:@"UPDATE %@ SET status=? WHERE stamp=?", table];
    [userDB executeUpdate:sql, @(message.status), @(message.stamp)];
}

-(void) deleteMessage:(MMessage *) message {
    NSInteger uid = message.isOutput?message.receiverId:message.senderId;
    
    NSString *table;
    if (message.type == MESSAGE_TYPE_DIALOG) {
        table = [NSString stringWithFormat:@"mmsg_%ld", (long)uid];
    } else if (message.type == MESSAGE_TYPE_GROUP) {
        uid = message.receiverId;
        table = [NSString stringWithFormat:@"mmsg_g%ld", (long)uid];
    } else {
        return;
    }
    
    if (!message.stamp) {
        return;
    }
    
    NSString *sql = [NSString stringWithFormat:@"DELETE FROM %@ WHERE stamp=?", table];
    [userDB executeUpdate:sql, @(message.stamp)];
}

-(NSArray *) getMessageWithUid:(NSInteger) uid
{
//    NSString *table = [NSString stringWithFormat:@"msg_%ld", (long)uid];
//    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ ORDER BY stamp ASC", table];
//    FMResultSet *res = [userDB executeQuery:sql];
//    
//    NSMutableArray *arr = [NSMutableArray array];
//    Message *message = nil;
//    
//    while ([res next])
//    {
//        if ([res intForColumn:@"type"] < 3) {
//            if ([res intForColumn:@"ct"] == 2) {
//                message = [[VoiceMessage alloc] init];
//            } else if ([res intForColumn:@"ct"] == 3) {
//                message = [[PictureMessage alloc] init];
//            } else {
//                message = [[Message alloc] init];
//            }
//        } else if ([res intForColumn:@"type"] == 3) {
//            message = [[IMNotification alloc] init];
//        }
//
//        message.from = [res intForColumn:@"fid"];
//        message.to = [res intForColumn:@"tid"];
//        message.messageType = [res intForColumn:@"type"];
//        message.contentType = [res intForColumn:@"ct"];
//        message.messageBody = [res stringForColumn:@"content"];
//        message.stamp = [res longLongIntForColumn:@"stamp"];
//        [message parseMessageBody];
//        [arr addObject:message];
//    }
//    
//    return arr;
    
    NSString *table = [NSString stringWithFormat:@"mmsg_%ld", (long)uid];
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ ORDER BY stamp ASC", table];
    FMResultSet *res = [userDB executeQuery:sql];
    
    NSMutableArray *arr = [NSMutableArray array];
    while ([res next]) {
        MMessage *message = [[MMessage alloc] init];
        message.senderId = [res intForColumn:@"sender_id"];
        message.receiverId = [res intForColumn:@"receiver_id"];
        message.type = MESSAGE_TYPE_DIALOG;
        message.contentType = [res intForColumn:@"content_type"];
        message.rawContent = [res stringForColumn:@"content"];
        message.stamp = [res longLongIntForColumn:@"stamp"];
        message.status = [res intForColumn:@"status"];
        [arr addObject:message];
    }
    
    return arr;
}

-(NSArray *) getMessageWithGid:(NSInteger) gid {
    NSString *table = [NSString stringWithFormat:@"msg_g%ld", (long)gid];
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ ORDER BY stamp ASC", table];
    FMResultSet *res = [userDB executeQuery:sql];
    
    NSMutableArray *arr = [NSMutableArray array];
    Message *message = nil;
    
    while ([res next])
    {
        if ([res intForColumn:@"ct"] == 2) {
            message = [[VoiceMessage alloc] init];
        } else if ([res intForColumn:@"ct"] == 3) {
            message = [[PictureMessage alloc] init];
        } else {
            message = [[Message alloc] init];
        }
        
        message.from = [res intForColumn:@"fid"];
        message.to = [res intForColumn:@"tid"];
        message.messageType = [res intForColumn:@"type"];
        message.contentType = [res intForColumn:@"ct"];
        message.messageBody = [res stringForColumn:@"content"];
        message.stamp = [res longLongIntForColumn:@"stamp"];
        [message parseMessageBody];
        [arr addObject:message];
    }
    
    return arr;
}

-(void) saveRecvNotification:(IMNotification *) message {
    int uid = message.uid;
    NSString *table = [NSString stringWithFormat:@"msg_%d", uid];
    if (message.contentType >= 10 && message.gid > 0) {
        table = [NSString stringWithFormat:@"msg_g%d", message.gid];
    }
    
    NSString *messageTableSql = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (fid integer, tid integer, type integer, ct integer, content VARCHAR(1000), stamp TIMESTAMP)", table];
    [userDB executeUpdate:messageTableSql];
    
    NSString *sql = [NSString stringWithFormat:@"INSERT INTO %@ (fid, tid, type, ct, content, stamp) VALUES (?,?,?,?,?,?)", table];
    [userDB executeUpdate:sql, [NSNumber numberWithUnsignedInt:message.from], [NSNumber numberWithUnsignedInt:message.to], [NSNumber numberWithUnsignedInt:message.messageType], [NSNumber numberWithUnsignedInt:message.contentType], message.messageBody, [NSNumber numberWithUnsignedLongLong:message.stamp/1000]];
    
    NSString *description = message.messageContent;
//    if (message.contentType == 2) {
//        description = @"[语音]";
//    } else if(message.contentType == 3) {
//        description = @"[图片]";
//    }
    
    MDialog *dialog = nil;
    int messageType = 0;
    if (message.contentType >= 10 && message.gid > 0) {
        dialog = [self getDiaglogWithGid:message.gid];
        messageType = 2;
    } else {
        // 打招呼不生成dialog记录
        if (message.contentType == 1) {
            return;
        }
        dialog = [self getDiaglogWithUid:message.uid];
        messageType = 1;
    }
    
    if (dialog == nil) {
        NSString *dialogName = nil;
        if (message.contentType >= 10 && message.gid > 0) {
            dialogName = [self getGroupWithId:uid].name;
        } else {
            dialogName = [self getUserWithUid:uid].nickname;
        }
        dialog = [[MDialog alloc] init];
        dialog.uid = uid;
        dialog.name = dialogName;
        dialog.desc = description;
        dialog.unreadCount = 1;
        dialog.type = messageType;
        dialog.stamp = message.stamp;
        
        [self saveDialog:dialog];
    } else {
        if (message.contentType == 2) {
            sql = @"UPDATE dialog SET description=?, stamp=?,is_read=0, unread_count=unread_count+1 WHERE uid=? and type=?";
            [userDB executeUpdate:sql, description, [NSNumber numberWithUnsignedLongLong:message.stamp/1000], [NSNumber numberWithUnsignedInt:uid], [NSNumber numberWithUnsignedInt:messageType]];
        } else {
            sql = @"UPDATE dialog SET description=?, stamp=? WHERE uid=? and type=?";
            [userDB executeUpdate:sql, description, [NSNumber numberWithUnsignedLongLong:message.stamp/1000], [NSNumber numberWithUnsignedInt:uid], [NSNumber numberWithUnsignedInt:messageType]];
        }

    }
}

#pragma mark unread message count
-(int) getUnreadCountWithUid:(NSInteger) uid {
    MDialog *d = [self getDiaglogWithUid:uid];
    
    if (d) {
        return d.unreadCount;
    }
    return 0;
}

-(void) clearUnreadCountWithUid:(NSInteger) uid {
    NSString *sql = @"UPDATE dialog SET unread_count=0, is_read=1 WHERE uid=? and type=1";
    [userDB executeUpdate:sql, [NSNumber numberWithInteger:uid]];
}

-(int) getUnreadCountWithGid:(NSInteger) gid {
    MDialog *d = [self getDiaglogWithGid:gid];
    
    if (d) {
        return d.unreadCount;
    }
    return 0;
}

-(void) clearUnreadCountWithGid:(NSInteger) gid {
    NSString *sql = @"UPDATE dialog SET unread_count=0, is_read=1 WHERE uid=? and type=2";
    [userDB executeUpdate:sql, [NSNumber numberWithInteger:gid]];
}

-(int) getMsgUnreadCount {
    NSString *sql = @"SELECT * FROM profile WHERE key='msg_unread_count'";
    FMResultSet *res = [userDB executeQuery:sql];
    
    while ([res next])
    {
        return [res intForColumn:@"val"];
    }
    
    sql = @"INSERT into profile (key, val) VALUES ('msg_unread_count', 0)";
    [userDB executeUpdate:sql];
    return 0;
}

-(void) setMsgUnreadCount:(int) count {
    [userDB executeUpdate:@"UPDATE profile SET val=? WHERE key='msg_unread_count'", [NSString stringWithFormat:@"%d", count]];
}

-(int) getNoticeUnreadCount {
    NSString *sql = @"SELECT * FROM profile WHERE key='notice_unread_count'";
    FMResultSet *res = [userDB executeQuery:sql];
    
    while ([res next])
    {
        return [res intForColumn:@"val"];
    }
    
    sql = @"INSERT into profile (key, val) VALUES ('notice_unread_count', 0)";
    [userDB executeUpdate:sql];
    return 0;
}

-(void) setNoticeUnreadCount:(int) count {
    [userDB executeUpdate:@"UPDATE profile SET val=? WHERE key='notice_unread_count'", [NSString stringWithFormat:@"%d", count]];
}


#pragma mark friend
-(void) saveFriend:(MFriend *) f {
    if (![self getFriendWithId:f.uid]) {
        NSString *sql = @"INSERT INTO friend (uid, comment_name, stamp) VALUES (?,?,?)";
        [userDB executeUpdate:sql, [NSNumber numberWithInteger:f.uid], f.commentName, [NSNumber numberWithUnsignedLongLong:f.stamp/1000]];
    }
}

-(void) saveFriends:(NSArray *) arr {
    for (MFriend *f in arr) {
        [self saveFriend:f];
    }
}

-(NSArray *) getFriendsWithUid:(NSInteger) uid {
    NSMutableArray *arr = [NSMutableArray array];
    
    NSString *sql = @"SELECT * FROM friend";
    FMResultSet *res = [userDB executeQuery:sql];
    
    while ([res next])
    {
        MFriend *f = [[MFriend alloc] init];
        f.uid = [res intForColumn:@"uid"];
        f.commentName = [res stringForColumn:@"comment_name"];
        
        MUser *u = [self getUserWithUid:f.uid];
        f.nickname = u.nickname;
        f.avatarUrl = u.avatarUrl;
        f.signature = u.signature;
        
        [arr addObject:f];
    }
    return arr;
}

-(MFriend *) getFriendWithId:(NSInteger) uid {
    NSString *sql = @"SELECT * FROM friend WHERE uid=?";
    FMResultSet *res = [userDB executeQuery:sql, [NSNumber numberWithInteger:uid]];
    
    while ([res next])
    {
        MFriend *f = [[MFriend alloc] init];
        f.uid = [res intForColumn:@"uid"];
        f.commentName= [res stringForColumn:@"comment_name"];
        
        MUser *u = [self getUserWithUid:f.uid];
        f.nickname = u.nickname;
        f.avatarUrl = u.avatarUrl;
        f.signature = u.signature;
        
        return f;
    }
    return nil;
}

-(void) updateFriend:(MFriend *) f {
    [userDB executeUpdate:@"UPDATE friend set comment_name=? WHERE uid=?", f.commentName, @(f.uid)];
}

-(void) delFriendWithId:(NSInteger) uid {
    [userDB executeUpdate:@"DELETE FROM friend WHERE uid=?", @(uid)];
}

#pragma mark group
-(void) saveGroup:(MGroup *) g {
    NSMutableArray *memberIds = [[NSMutableArray alloc] init];
    
    for (MUser *u in g.members) {
        [memberIds addObject:[NSDictionary dictionaryWithObjectsAndKeys: [NSString stringWithFormat:@"%ld", (long)u.uid], @"id", nil]];
    }
    
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:memberIds
                                                       options:NSJSONWritingPrettyPrinted error:&error];
    
    if ([jsonData length] > 0 && error == nil){
        NSString *memberStr = [[NSString alloc] initWithData:jsonData
                                                    encoding:NSUTF8StringEncoding];
        NSString *sql = @"INSERT INTO group_info (id, name, avater_url, master_id, members, stamp) VALUES (?,?,?,?,?,?)";
        [userDB executeUpdate:sql, [NSNumber numberWithInteger:g._id], g.name, g.avatarUrl, [NSNumber numberWithInteger:g.masterId], memberStr, [NSNumber numberWithUnsignedLongLong:g.stamp/1000]];
    }else{
    }
    

}

-(void) saveGroups:(NSArray<MGroup *> *) arr {
    for (MGroup *g in arr) {
        [self saveGroup:g];
    }
}

-(NSArray *) getGroupsWithUid:(NSInteger) uid {
    NSMutableArray *arr = [NSMutableArray array];
    
    NSString *sql = @"SELECT * FROM group_info";
    FMResultSet *res = [userDB executeQuery:sql];
    
    while ([res next]) {
        MGroup *g = [[MGroup alloc] init];
        g._id = [res intForColumn:@"id"];
        g.name= [res stringForColumn:@"name"];
        g.masterId = [res intForColumn:@"master_id"];
        g.avatarUrl = [res stringForColumn:@"avater_url"];
        
        [arr addObject:g];
    }
    return arr;
}

-(MGroup *) getGroupWithId:(NSInteger) uid {
    NSString *sql = @"SELECT * FROM group_info WHERE id=?";
    FMResultSet *res = [userDB executeQuery:sql, [NSNumber numberWithInteger:uid]];
    
    while ([res next]) {
        MGroup *g = [[MGroup alloc] init];
        g._id = [res intForColumn:@"id"];
        g.name= [res stringForColumn:@"name"];
        g.masterId = [res intForColumn:@"master_id"];
        g.avatarUrl = [res stringForColumn:@"avater_url"];
        
        NSError *error = nil;
        NSArray *memberIds = [NSJSONSerialization JSONObjectWithData:[[res stringForColumn:@"members"]
                                                   dataUsingEncoding:NSUTF8StringEncoding]
                                                             options:NSJSONReadingMutableLeaves
                                                               error:&error];
        
        if (!error) {
            NSMutableArray *members = [[NSMutableArray alloc] init];
            for (NSDictionary *dict in memberIds) {
                NSInteger userId = [[dict valueForKey:@"id"] integerValue];
                MUser *u = [self getUserWithUid:userId];
                if (u) {
                    [members addObject:u];
                }
            }
            g.members = members;
        }

        return g;
    }
    return nil;
}

-(void) addMembers:(NSArray *) members ToGid:(NSInteger) gid {
//    MGroup *group = [self getGroupWithId:gid];
    NSMutableArray *memberIds = [[NSMutableArray alloc] init];
    
//    for (MUser *u in group.members) {
//        [memberIds addObject:[NSDictionary dictionaryWithObjectsAndKeys: [NSString stringWithFormat:@"%ld", (long)u.uid], @"id", nil]];
//    }    
    for (MUser *u in members) {
        [memberIds addObject:[NSDictionary dictionaryWithObjectsAndKeys: [NSString stringWithFormat:@"%ld", (long)u.uid], @"id", nil]];
    }
    
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:memberIds
                                                       options:NSJSONWritingPrettyPrinted error:&error];
    
    if ([jsonData length] > 0 && error == nil){
        NSString *memberStr = [[NSString alloc] initWithData:jsonData
                                                    encoding:NSUTF8StringEncoding];
        NSString *sql = @"UPDATE group_info set members=? WHERE id=?";
        [userDB executeUpdate:sql, memberStr, [NSNumber numberWithInteger:gid]];
    }else{
    }
}

-(void) deleteGroupWithId:(NSInteger) gid {
    NSString *sql = @"DELETE FROM group_info WHERE id=?";
    [userDB executeUpdate:sql, @(gid)];
}

-(void) quitGroupWithUid:(NSInteger) uid Gid:(NSInteger) gid {
    MGroup *group = [self getGroupWithId:gid];
    NSMutableArray *memberIds = [[NSMutableArray alloc] init];
    for (MUser *u in group.members) {
        if (u.uid != uid) {
            [memberIds addObject:[NSDictionary dictionaryWithObjectsAndKeys: [NSString stringWithFormat:@"%ld", (long)u.uid], @"id", nil]];
        }
    }
    
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:memberIds
                                                       options:NSJSONWritingPrettyPrinted error:&error];
    
    if ([jsonData length] > 0 && error == nil){
        NSString *memberStr = [[NSString alloc] initWithData:jsonData
                                                    encoding:NSUTF8StringEncoding];
        NSString *sql = @"UPDATE group_info set members=? WHERE id=?";
        [userDB executeUpdate:sql, memberStr, [NSNumber numberWithInteger:gid]];
    }else{
    }
}

#pragma mark make friend record
-(void) saveMakeFriendRecord:(MUser *) u {
    NSString *sql = @"SELECT * FROM newfriend where uid=?";
    // 记录已存在的话不重复插入
    if ([[userDB executeQuery:sql, [NSNumber numberWithInteger:u.uid]] next]) {
        return;
    }
    
    sql = @"INSERT INTO newfriend (uid, nickname, comment, source, is_friend, stamp) VALUES (?,?,?,?,?,?)";
    [userDB executeUpdate:sql, @(u.uid), u.nickname, u.comment
     , [NSNumber numberWithUnsignedInt:u.source], [NSNumber numberWithUnsignedInt:u.isFriend], [NSNumber numberWithUnsignedLongLong:[[NSDate date] timeIntervalSince1970]]];
}

-(void) updateMakeFriendRecord:(MUser *) u {
    NSString *sql = @"UPDATE newfriend SET is_friend=? WHERE uid=?";
    [userDB executeUpdate:sql, [NSNumber numberWithUnsignedInt:u.isFriend], [NSNumber numberWithInteger:u.uid]];
}

-(NSArray *) getMakeFriendRecordsByUid:(NSInteger) uid {
    NSMutableArray *arr = [NSMutableArray array];
    
    NSString *sql = @"SELECT * FROM newfriend";
    FMResultSet *res = [userDB executeQuery:sql];
    
    while ([res next]) {
        MUser *u = [self getUserWithUid:[res intForColumn:@"uid"]];
        
        if (u != nil) {
            u.nickname= [res stringForColumn:@"nickname"];
            u.source = [res intForColumn:@"source"];
            u.comment = [res stringForColumn:@"comment"];
            u.isFriend = [res intForColumn:@"is_friend"];
            
            [arr addObject:u];
        }
    }
    return arr;
}

-(void) delMakeFriendRecordWithId:(NSInteger) uid {
    NSString *sql = @"DELETE FROM newfriend WHERE uid=?";
    [userDB executeUpdate:sql, [NSNumber numberWithInteger:uid]];
}

#pragma mark account
-(void) login:(MUser *) user {
    [MUser setCurrentUser:user];
    [self initUserDB];
    [self updateUser:user];
    [self saveUser:user];
}
-(MUser *) getLoginUser {
    NSString *sql = @"SELECT val FROM login_info WHERE key='login_info'";
    FMResultSet *res = [commonDB executeQuery:sql];
    while ([res next]) {
        NSString *json = [res stringForColumn:@"val"];
        
        NSError *error = nil;
        NSDictionary *contentDict = [NSJSONSerialization JSONObjectWithData:[json dataUsingEncoding:NSUTF8StringEncoding]
                                                                    options:NSJSONReadingMutableLeaves
                                                                      error:&error];
        if (!error) {
            MUser *u = [[MUser alloc] initWithId:[[contentDict objectForKey:@"uid"] integerValue]];
            u.nickname = [contentDict objectForKey:@"nickname"];
            u.accessToken = [contentDict objectForKey:@"token"];
            u.avatarUrl = [contentDict objectForKey:@"avatar_url"];
            u.avatarThumbUrl = [contentDict objectForKey:@"avatar_thumb"];
            
            [MUser setCurrentUser:u];
            [self initUserDB];
            return u;
        }
    }
    return nil;
}

-(void) logout {
    NSString *sql = @"DELETE FROM login_info WHERE key='login_info'";
    [commonDB executeUpdate:sql];
}

-(void) updateUser:(MUser *) user {
    NSString *jsonStr = nil;
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          [NSString stringWithFormat:@"%ld", (long)user.uid], @"uid",
                          user.nickname, @"nickname",
                          user.accessToken, @"token",
                          user.avatarUrl, @"avatar_url",
                          user.avatarThumbUrl, @"avatar_thumb",
                          nil];
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    
    if ([jsonData length] > 0 && error == nil){
        jsonStr = [[NSString alloc] initWithData:jsonData
                                        encoding:NSUTF8StringEncoding];
    } else {
        return;
    }
    
    if ([self getLoginUser]) {
        NSString *sql = @"UPDATE login_info SET val=? WHERE key='login_info'";
        [commonDB executeUpdate:sql, jsonStr];
    } else {
        NSString *sql = @"INSERT INTO login_info VALUES ('login_info', ?)";
        [commonDB executeUpdate:sql, jsonStr];
    }
}

-(MUser *) getDemoUser {
    MUser *u = [self getInitDemoUserData];
    
    if (u == nil) {
        u = [self getInitDemoUserData];
    }
    
    [MUser setCurrentUser:u];
    [self initUserDB];
    return u;
}

-(MUser *) getInitDemoUserData {
    MUser *user = [[MUser alloc] init];
    user.uid = 101;
    user.nickname = @"test";
    user.avatarUrl = @"http://ec2-54-88-205-144.compute-1.amazonaws.com/res/face/10/101.jpg";
    user.avatarThumbUrl = @"http://ec2-54-88-205-144.compute-1.amazonaws.com/res/face/10/101.jpg";
    user.accessToken = @"101_64744254081454207531_0672fd1141";
    [self saveUser:user];
    
    return user;
}

@end
